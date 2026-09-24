// Route tests for app.js against in-memory fakes of Firestore and FCM, so no
// Firebase project or credentials are needed. Run with `npm test`.

const { test, describe, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const { createApp, buildMessage, TOKENS_COLLECTION } = require('../app');

const API_KEY = 'test-api-key';
const TIMESTAMP = 'server-timestamp';

// Minimal Firestore fake: one collection of docs keyed by id.
function createFakeDb() {
  const docs = new Map();
  return {
    docs,
    collection(name) {
      assert.equal(name, TOKENS_COLLECTION);
      return {
        doc: (id) => ({
          set: async (value) => {
            docs.set(id, value);
          },
          delete: async () => {
            docs.delete(id);
          },
        }),
        get: async () => ({
          docs: [...docs.keys()].map((id) => ({ id })),
        }),
      };
    },
  };
}

// FCM fake that records what was sent. `staleTokens` fail with the
// not-registered code FCM uses for uninstalled apps.
function createFakeMessaging(staleTokens = new Set()) {
  const sent = [];
  const multicasts = [];
  const staleError = () =>
    Object.assign(new Error('not registered'), {
      code: 'messaging/registration-token-not-registered',
    });
  return {
    sent,
    multicasts,
    async send(message) {
      if (staleTokens.has(message.token)) throw staleError();
      sent.push(message);
      return 'message-id-1';
    },
    async sendEachForMulticast(message) {
      multicasts.push(message);
      const responses = message.tokens.map((t) =>
        staleTokens.has(t) ? { success: false, error: staleError() } : { success: true },
      );
      const failureCount = responses.filter((r) => !r.success).length;
      return {
        successCount: responses.length - failureCount,
        failureCount,
        responses,
      };
    },
  };
}

let server;
let baseUrl;
let db;
let messaging;

async function start({ staleTokens } = {}) {
  db = createFakeDb();
  messaging = createFakeMessaging(staleTokens);
  const app = createApp({
    db,
    messaging,
    apiKey: API_KEY,
    serverTimestamp: () => TIMESTAMP,
  });
  await new Promise((resolve) => {
    server = app.listen(0, resolve);
  });
  baseUrl = `http://127.0.0.1:${server.address().port}`;
}

function post(path, body, { apiKey } = {}) {
  const headers = { 'Content-Type': 'application/json' };
  if (apiKey !== undefined) headers['x-api-key'] = apiKey;
  return fetch(`${baseUrl}${path}`, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });
}

afterEach(async () => {
  if (!server) return;
  await new Promise((resolve) => server.close(resolve));
  server = undefined;
});

describe('buildMessage', () => {
  test('sends Android data-only at high priority and iOS a visible alert', () => {
    const message = buildMessage({
      title: 'Mass update',
      body: 'Vigil Mass moved to 6pm',
      data: { screen: 'masses', count: 3 },
    });

    // A top-level notification block would make Android post a duplicate.
    assert.equal(message.notification, undefined);
    assert.deepEqual(message.android, { priority: 'high' });
    assert.deepEqual(message.apns.payload.aps.alert, {
      title: 'Mass update',
      body: 'Vigil Mass moved to 6pm',
    });
    assert.equal(message.apns.payload.aps.sound, 'default');
    assert.deepEqual(message.data, {
      screen: 'masses',
      count: '3',
      title: 'Mass update',
      body: 'Vigil Mass moved to 6pm',
    });
  });

  test('works without data', () => {
    const message = buildMessage({ title: 't', body: 'b' });

    assert.deepEqual(message.data, { title: 't', body: 'b' });
  });
});

describe('POST /tokens', () => {
  beforeEach(() => start());

  test('stores a valid token and returns 204', async () => {
    const res = await post('/tokens', { fcm_token: 'abc:DEF_123-x' });

    assert.equal(res.status, 204);
    assert.deepEqual(db.docs.get('abc:DEF_123-x'), {
      token: 'abc:DEF_123-x',
      updatedAt: TIMESTAMP,
    });
  });

  test('rejects a missing or malformed token', async () => {
    assert.equal((await post('/tokens', {})).status, 400);
    assert.equal((await post('/tokens', { fcm_token: 'a/b' })).status, 400);
    assert.equal((await post('/tokens', { fcm_token: 42 })).status, 400);
    assert.equal(db.docs.size, 0);
  });
});

describe('GET /health', () => {
  beforeEach(() => start());

  test('returns ok', async () => {
    const res = await fetch(`${baseUrl}/health`);

    assert.equal(res.status, 200);
    assert.deepEqual(await res.json(), { status: 'ok' });
  });
});

describe('POST /send', () => {
  const valid = { token: 'device-1', title: 'Hello', body: 'World' };

  test('requires the API key', async () => {
    await start();

    assert.equal((await post('/send', valid)).status, 401);
    assert.equal((await post('/send', valid, { apiKey: 'wrong' })).status, 401);
    assert.equal(messaging.sent.length, 0);
  });

  test('sends with the right key', async () => {
    await start();

    const res = await post('/send', valid, { apiKey: API_KEY });

    assert.equal(res.status, 200);
    assert.deepEqual(await res.json(), { messageId: 'message-id-1' });
    assert.equal(messaging.sent[0].token, 'device-1');
    assert.ok(messaging.sent[0].apns.payload.aps.alert);
  });

  test('rejects missing title/body and non-object data', async () => {
    await start();
    const opts = { apiKey: API_KEY };

    assert.equal((await post('/send', { ...valid, title: ' ' }, opts)).status, 400);
    assert.equal((await post('/send', { ...valid, data: 'x' }, opts)).status, 400);
    assert.equal((await post('/send', { ...valid, data: [1] }, opts)).status, 400);
    assert.equal((await post('/send', { ...valid, data: null }, opts)).status, 400);
    assert.equal(messaging.sent.length, 0);
  });

  test('prunes a stale token and returns 404', async () => {
    await start({ staleTokens: new Set(['device-1']) });
    await post('/tokens', { fcm_token: 'device-1' });

    const res = await post('/send', valid, { apiKey: API_KEY });

    assert.equal(res.status, 404);
    assert.equal(db.docs.has('device-1'), false);
  });
});

describe('POST /broadcast', () => {
  const valid = { title: 'Hello', body: 'World' };

  test('requires the API key', async () => {
    await start();

    assert.equal((await post('/broadcast', valid)).status, 401);
  });

  test('returns zero counts with no stored tokens', async () => {
    await start();

    const res = await post('/broadcast', valid, { apiKey: API_KEY });

    assert.deepEqual(await res.json(), { sent: 0, failed: 0, pruned: 0 });
    assert.equal(messaging.multicasts.length, 0);
  });

  test('rejects non-object data', async () => {
    await start();

    const res = await post('/broadcast', { ...valid, data: 'x' }, { apiKey: API_KEY });

    assert.equal(res.status, 400);
  });

  test('batches by 500 and prunes stale tokens', async () => {
    await start({ staleTokens: new Set(['t-3', 't-600']) });
    for (let i = 0; i < 650; i++) db.docs.set(`t-${i}`, {});

    const res = await post('/broadcast', valid, { apiKey: API_KEY });

    assert.equal(res.status, 200);
    assert.deepEqual(await res.json(), { sent: 648, failed: 2, pruned: 2 });
    assert.deepEqual(
      messaging.multicasts.map((m) => m.tokens.length),
      [500, 150],
    );
    assert.equal(db.docs.has('t-3'), false);
    assert.equal(db.docs.has('t-600'), false);
    assert.equal(db.docs.size, 648);
  });
});
