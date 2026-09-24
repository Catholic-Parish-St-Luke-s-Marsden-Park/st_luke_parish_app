// Push notification backend entry point: initialises Firebase from the
// environment and starts the Express app defined in app.js. See app.js for
// the routes.

require('dotenv').config({ quiet: true }); // must run before any process.env reads below
const { initializeApp, cert, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const path = require('path');
const { createApp } = require('./app');

// Credential lookup order:
//   1. FIREBASE_SERVICE_ACCOUNT - the whole JSON key as a string. Used on the
//      hosted backend (e.g. Render), where there's no key file to mount.
//   2. GOOGLE_APPLICATION_CREDENTIALS - path to a downloaded key file (local dev).
//   3. ./service-account.json next to this file (local dev fallback).
// Never commit the key file.
let credential;
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  credential = cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT));
} else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  credential = applicationDefault();
} else {
  credential = cert(require(path.join(__dirname, './service-account.json')));
}
initializeApp({ credential });

// The project's database is named rather than "(default)", so it must be selected explicitly.
const FIRESTORE_DATABASE_ID = process.env.FIRESTORE_DATABASE_ID;
if (!FIRESTORE_DATABASE_ID) {
  throw new Error('FIRESTORE_DATABASE_ID env var is required to select the Firestore database');
}

const API_KEY = process.env.API_KEY;
if (!API_KEY) {
  throw new Error('API_KEY env var is required to protect /send and /broadcast');
}

const app = createApp({
  db: getFirestore(FIRESTORE_DATABASE_ID),
  messaging: getMessaging(),
  apiKey: API_KEY,
  serverTimestamp: () => FieldValue.serverTimestamp(),
});

const port = process.env.PORT ?? 8080;
app.listen(port, () => console.log(`Listening on port ${port}`));
