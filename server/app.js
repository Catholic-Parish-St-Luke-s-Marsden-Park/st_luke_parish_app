// Express app for the push notification backend. Kept free of Firebase
// initialisation and process.env reads so it can be built with fake `db` and
// `messaging` objects in tests; index.js wires in the real ones.
//   POST /tokens     - called by the app to register a device token (no auth)
//   POST /send       - send to one token       (requires x-api-key)
//   POST /broadcast  - send to all stored tokens (requires x-api-key)
//   GET  /health     - liveness check for the host (no auth, no side effects)

const crypto = require('crypto');
const express = require('express');
const helmet = require('helmet');
const { rateLimit } = require('express-rate-limit');

// Each document is keyed by the FCM token itself, so re-registering the same
// token is an idempotent upsert rather than a duplicate.
const TOKENS_COLLECTION = 'deviceTokens';

// FCM tokens are URL-safe strings of letters, digits, ':', '_' and '-'. The
// token becomes a Firestore document ID, so reject anything else (notably '/').
const FCM_TOKEN_PATTERN = /^[A-Za-z0-9:_-]{1,1024}$/;

// FCM error codes meaning the token can never receive a push again (app
// uninstalled, token rotated, or token malformed). Such tokens are deleted.
const STALE_TOKEN_ERROR_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

// FCM's multicast call caps out at 500 tokens per request.
const MULTICAST_BATCH_SIZE = 500;

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

// `data` is optional, but when present it must be a flat JSON object: spreading
// a string or array into the FCM payload would produce index keys.
function isValidData(value) {
  return (
    value === undefined ||
    (typeof value === 'object' && value !== null && !Array.isArray(value))
  );
}

// Builds the FCM payload shared by /send and /broadcast.
//
// There is deliberately no top-level `notification` block: on Android that
// would make the FCM SDK auto-post a tray notification *and* run the app's
// background handler, which posts its own — two notifications per push. So
// Android gets data only (high priority, or Doze defers it) and the app shows
// it. iOS drops or throttles data-only pushes, so APNs gets its own visible
// alert via the `apns` override, which Android never sees.
//
// FCM requires every value in `data` to be a string, so values are coerced.
function buildMessage({ title, body, data }) {
  return {
    data: Object.fromEntries(
      Object.entries({ ...data, title, body }).map(([k, v]) => [k, String(v)]),
    ),
    android: { priority: 'high' },
    apns: {
      payload: {
        aps: { alert: { title, body }, sound: 'default' },
      },
    },
  };
}

// Returns an error message for an invalid /send or /broadcast body, or null.
function validateMessageBody({ title, body, data }) {
  if (!isNonEmptyString(title) || !isNonEmptyString(body)) {
    return 'Missing or invalid "title" or "body"';
  }
  if (!isValidData(data)) {
    return '"data" must be a JSON object';
  }
  return null;
}

function createApp({ db, messaging, apiKey, serverTimestamp }) {
  if (!apiKey) {
    throw new Error('apiKey is required to protect /send and /broadcast');
  }

  const app = express();
  // Render (and most hosts) put one reverse proxy in front of the app. Without
  // this, every request appears to come from the proxy's IP and the rate
  // limiter below would throttle all users as one client.
  app.set('trust proxy', 1);
  // Sets defensive HTTP response headers (this API returns no HTML, so the
  // defaults are safe).
  app.use(helmet());
  // Every legitimate request body here is tiny; a small cap stops oversized junk.
  app.use(express.json({ limit: '10kb' }));

  // Middleware guarding the routes that can push notifications to devices.
  function requireApiKey(req, res, next) {
    const provided = req.header('x-api-key') ?? '';
    const a = Buffer.from(provided);
    const b = Buffer.from(apiKey);
    // timingSafeEqual throws on unequal lengths, so compare lengths first. It
    // also avoids leaking how much of the key matched through response timing.
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
      res.status(401).send('Invalid or missing API key');
      return;
    }
    next();
  }

  // /tokens has no auth (the app can't hold a secret), so cap how fast one
  // client can write to Firestore. A real device registers a handful of times.
  const tokenRateLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 20,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
  });

  // Best-effort delete: failure to prune must never fail the request that
  // found the stale token.
  async function pruneToken(token) {
    try {
      await db.collection(TOKENS_COLLECTION).doc(token).delete();
      return true;
    } catch (err) {
      console.error('Failed to prune stale token', err);
      return false;
    }
  }

  // Called by the app itself (no auth) whenever it has a fresh FCM token.
  // Errors are logged here and only a generic message is returned, so
  // Firestore internals never reach the client.
  app.post('/tokens', tokenRateLimiter, async (req, res) => {
    const token = req.body?.fcm_token;
    if (typeof token !== 'string' || !FCM_TOKEN_PATTERN.test(token)) {
      res.status(400).send('Missing or invalid "fcm_token"');
      return;
    }

    try {
      await db
        .collection(TOKENS_COLLECTION)
        .doc(token)
        .set({ token, updatedAt: serverTimestamp() }, { merge: true });
      res.status(204).send();
    } catch (err) {
      console.error('Token registration failed', err);
      res.status(500).send('Failed to register token');
    }
  });

  // Liveness probe for the host (e.g. Render's health check). Deliberately
  // does not touch Firestore or FCM so it stays cheap and can't burn quota.
  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
  });

  // Sends to one specific device token. Requires the shared API key since
  // anyone who could call this could spam an arbitrary device.
  app.post('/send', requireApiKey, async (req, res) => {
    const { token, title, body, data } = req.body ?? {};
    if (!isNonEmptyString(token)) {
      res.status(400).send('Missing or invalid "token"');
      return;
    }
    const invalid = validateMessageBody({ title, body, data });
    if (invalid) {
      res.status(400).send(invalid);
      return;
    }

    try {
      const messageId = await messaging.send({
        token,
        ...buildMessage({ title, body, data }),
      });
      res.status(200).json({ messageId });
    } catch (err) {
      if (STALE_TOKEN_ERROR_CODES.has(err.code)) {
        await pruneToken(token);
        res.status(404).send('Token is no longer registered');
        return;
      }
      console.error('Send failed', err);
      res.status(500).send('Send failed');
    }
  });

  // Sends the same notification to every stored token, in batches of 500.
  // Any token FCM reports as no-longer-registered is pruned from Firestore so
  // future broadcasts don't keep paying for dead devices.
  app.post('/broadcast', requireApiKey, async (req, res) => {
    const { title, body, data } = req.body ?? {};
    const invalid = validateMessageBody({ title, body, data });
    if (invalid) {
      res.status(400).send(invalid);
      return;
    }

    try {
      const snapshot = await db.collection(TOKENS_COLLECTION).get();
      const tokens = snapshot.docs.map((doc) => doc.id);
      if (tokens.length === 0) {
        res.status(200).json({ sent: 0, failed: 0, pruned: 0 });
        return;
      }

      const message = buildMessage({ title, body, data });
      let sent = 0;
      let failed = 0;
      const staleTokens = [];

      for (let i = 0; i < tokens.length; i += MULTICAST_BATCH_SIZE) {
        const batch = tokens.slice(i, i + MULTICAST_BATCH_SIZE);
        const response = await messaging.sendEachForMulticast({
          tokens: batch,
          ...message,
        });
        sent += response.successCount;
        failed += response.failureCount;
        response.responses.forEach((r, idx) => {
          if (!r.success && STALE_TOKEN_ERROR_CODES.has(r.error?.code)) {
            staleTokens.push(batch[idx]);
          }
        });
      }

      const pruneResults = await Promise.all(staleTokens.map(pruneToken));
      const pruned = pruneResults.filter(Boolean).length;

      res.status(200).json({ sent, failed, pruned });
    } catch (err) {
      console.error('Broadcast failed', err);
      res.status(500).send('Broadcast failed');
    }
  });

  return app;
}

module.exports = { createApp, buildMessage, TOKENS_COLLECTION };
