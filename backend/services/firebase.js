const admin = require('firebase-admin');
const config = require('../config');

let initialized = false;

function init() {
    if (initialized) return admin;

    try {
        let serviceAccount;

        if (config.firebase.serviceAccountJson) {
            // Priority: Load from Environment Variable (for GitHub Actions)
            serviceAccount = JSON.parse(config.firebase.serviceAccountJson);
        } else {
            // Fallback: Load from Local File (for local development)
            serviceAccount = require(config.firebase.credentialPath);
        }

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log("🔥 Firebase Admin Initialized");
        initialized = true;
    } catch (e) {
        console.warn("⚠️ Firebase Admin Init Failed:", e.message);
        console.warn("   Some features (Vaccines, Dental, Food History) will NOT work without it.");
    }
    return admin;
}

module.exports = { init, admin };
