const admin = require('firebase-admin');
const config = require('../config');

let initialized = false;

function init() {
    if (initialized) return admin;

    try {
        let credential;

        if (config.firebase.projectId && config.firebase.clientEmail && config.firebase.privateKey) {
            // Priority: Load from individual Backend Environment Variables (Production)
            credential = admin.credential.cert({
                projectId: config.firebase.projectId,
                clientEmail: config.firebase.clientEmail,
                privateKey: config.firebase.privateKey,
            });
        } else {
            // Fallback: Load from Local File (Local Development)
            credential = admin.credential.cert(require(config.firebase.credentialPath));
        }

        admin.initializeApp({
            credential: credential
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
