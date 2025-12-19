const path = require('path');
require('dotenv').config();

module.exports = {
    oneSignal: {
        appId: process.env.ONESIGNAL_APP_ID || "48d29f47-c4fa-4e66-86fc-304ffbeff598",
        restKey: process.env.ONESIGNAL_REST_KEY,
    },
    firebase: {
        // Local dev: physical file
        credentialPath: path.join(__dirname, "serviceAccountKey.json"),
        // Production (GitHub Actions): Individual secrets for maximum safety
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        // CRITICAL: GitHub Secrets escape \n as \\n. We must unescape.
        privateKey: process.env.FIREBASE_PRIVATE_KEY
            ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
            : undefined,
    },
    validate() {
        if (!this.oneSignal.restKey) {
            console.warn("⚠️ Warning: ONESIGNAL_REST_KEY is missing from environment.");
        }

        const hasEnvAuth = this.firebase.projectId && this.firebase.clientEmail && this.firebase.privateKey;
        const hasFileAuth = require('fs').existsSync(this.firebase.credentialPath);

        if (!hasEnvAuth && !hasFileAuth) {
            console.warn("⚠️ Warning: Firebase credentials missing (No individual secrets OR serviceAccountKey.json found).");
        } else if (hasEnvAuth) {
            console.log("✅ Using secure environment secrets for Firebase authentication.");
        } else {
            console.log("ℹ️ Using local serviceAccountKey.json for Firebase authentication.");
        }
    }
};
