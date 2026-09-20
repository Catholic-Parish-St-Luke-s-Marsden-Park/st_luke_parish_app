// Push notification backend: stores device FCM tokens in Firestore and sends
// notifications to them through Firebase Cloud Messaging.
//   POST /tokens     - called by the app to register a device token (no auth)
//   POST /send       - send to one token       (requires x-api-key)
//   POST /broadcast  - send to all stored tokens (requires x-api-key)
//   GET  /health     - liveness check for the host (no auth, no side effects)

const crypto = require('crypto');
require('dotenv').config(); // must run before any process.env reads below
const express = require('express');
const admin = require('firebase-admin');
const helmet = require('helmet');
const { rateLimit } = require('express-rate-limit');
const { getFirestore } = require('firebase-admin/firestore');
const path = require('path');

// Credential lookup order:
//   1. FIREBASE_SERVICE_ACCOUNT - the whole JSON key as a string. Used on the
//      hosted backend (e.g. Render), where there's no key file to mount.
//   2. GOOGLE_APPLICATION_CREDENTIALS - path to a downloaded key file (local dev).
//   3. ./service-account.json next to this file (local dev fallback).
// Never commit the key file.
let credential;
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  credential = admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT));
} else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  credential = admin.credential.applicationDefault();
} else {
  credential = admin.credential.cert(require(path.join(__dirname, './service-account.json')));
}
admin.initializeApp({ credential });

// The project's database is named rather than "(default)", so it must be selected explicitly.
const FIRESTORE_DATABASE_ID = process.env.FIRESTORE_DATABASE_ID;
if (!FIRESTORE_DATABASE_ID) {
  throw new Error('FIRESTORE_DATABASE_ID env var is required to select the Firestore database');
}
const db = getFirestore(FIRESTORE_DATABASE_ID);
const messaging = admin.messaging();

const app = express();
// Render (and most hosts) put one reverse proxy in front of the app. Without
// this, every request appears to come from the proxy's IP and the rate limiter
// below would throttle all users as one client.
app.set('trust proxy', 1);
// Sets defensive HTTP response headers (this API returns no HTML, so the
// defaults are safe).
app.use(helmet());
// Every legitimate request body here is tiny; a small cap stops oversized junk.
app.use(express.json({ limit: '10kb' }));

const API_KEY = process.env.API_KEY;
if (!API_KEY) {
  throw new Error('API_KEY env var is required to protect /send and /broadcast');
}

// Middleware guarding the routes that can push notifications to devices.
function requireApiKey(req, res, next) {
  const provided = req.header('x-api-key') ?? '';
  const a = Buffer.from(provided);
  const b = Buffer.from(API_KEY);
  // timingSafeEqual throws on unequal lengths, so compare lengths first. It
  // also avoids leaking how much of the key matched through response timing.
  if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
    res.status(401).send('Invalid or missing API key');
    return;
  }
  next();
}

// Each document is keyed by the FCM token itself, so re-registering the same
// token is an idempotent upsert rather than a duplicate.
const TOKENS_COLLECTION = 'deviceTokens';

// /tokens has no auth (the app can't hold a secret), so cap how fast one client
// can write to Firestore. A real device registers a handful of times at most.
const tokenRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
});

// FCM tokens are URL-safe strings of letters, digits, ':', '_' and '-'. The
// token becomes a Firestore document ID, so reject anything else (notably '/').
const FCM_TOKEN_PATTERN = /^[A-Za-z0-9:_-]{1,1024}$/;

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

// Called by the app itself (no auth) whenever it has a fresh FCM token.
// Errors are logged here and only a generic message is returned, so Firestore
// internals never reach the client.
app.post('/tokens', tokenRateLimiter, async (req, res) => {
  const token = req.body?.fcm_token;
  if (typeof token !== 'string' || !FCM_TOKEN_PATTERN.test(token)) {
    res.status(400).send('Missing or invalid "fcm_token"');
    return;
  }

  try {
    await db.collection(TOKENS_COLLECTION).doc(token).set(
      { token, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true },
    );
    res.status(204).send();
  } catch (err) {
    console.error('Token registration failed', err);
    res.status(500).send('Failed to register token');
  }
});

// Liveness probe for the host (e.g. Render's health check). Deliberately does
// not touch Firestore or FCM so it stays cheap and can't be used to burn quota.
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// FCM error codes meaning the token can never receive a push again (app
// uninstalled, token rotated, or token malformed). Such tokens are deleted.
const STALE_TOKEN_ERROR_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

// Best-effort delete: failure to prune must never fail the request that found
// the stale token.
async function pruneToken(token) {
  try {
    await db.collection(TOKENS_COLLECTION).doc(token).delete();
    return true;
  } catch (err) {
    console.error('Failed to prune stale token', err);
    return false;
  }
}

// Builds the FCM payload shared by /send and /broadcast. FCM requires every
// value in `data` to be a string, so values are coerced.
function buildMessage({ title, body, data }) {
  return {
    notification: { title, body },
    data: data
      ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)]))
      : undefined,
  };
}

// Sends to one specific device token. Requires the shared API key since
// anyone who could call this could spam an arbitrary device.
app.post('/send', requireApiKey, async (req, res) => {
  const { token, title, body, data } = req.body ?? {};
  if (!isNonEmptyString(token)) {
    res.status(400).send('Missing or invalid "token"');
    return;
  }
  if (!isNonEmptyString(title) || !isNonEmptyString(body)) {
    res.status(400).send('Missing or invalid "title" or "body"');
    return;
  }

  try {
    const messageId = await messaging.send({ token, ...buildMessage({ title, body, data }) });
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

// Sends the same notification to every stored token. FCM's multicast call
// caps out at 500 tokens per request, so large registries are sent in
// batches; any token FCM reports as no-longer-registered is pruned from
// Firestore so future broadcasts don't keep paying for dead devices.
app.post('/broadcast', requireApiKey, async (req, res) => {
  const { title, body, data } = req.body ?? {};
  if (!isNonEmptyString(title) || !isNonEmptyString(body)) {
    res.status(400).send('Missing or invalid "title" or "body"');
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

    for (let i = 0; i < tokens.length; i += 500) {
      const batch = tokens.slice(i, i + 500);
      const response = await messaging.sendEachForMulticast({ tokens: batch, ...message });
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

const port = process.env.PORT ?? 8080;
app.listen(port, () => console.log(`Listening on port ${port}`));