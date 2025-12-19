const path = require('path');
require('dotenv').config();

module.exports = {
    oneSignal: {
        appId: process.env.ONESIGNAL_APP_ID || "48d29f47-c4fa-4e66-86fc-304ffbeff598",
        restKey: process.env.ONESIGNAL_REST_KEY,
    },
    firebase: {
        // Support file-based key for local dev and JSON-string for GitHub Actions
        credentialPath: path.join(__dirname, "serviceAccountKey.json"),
        serviceAccountJson: process.env.FIREBASE_SERVICE_ACCOUNT
    },
    validate() {
        if (!this.oneSignal.restKey) {
            console.warn("⚠️ Warning: ONESIGNAL_REST_KEY is missing from environment.");
        }
        if (!this.firebase.serviceAccountJson && !require('fs').existsSync(this.firebase.credentialPath)) {
            console.warn("⚠️ Warning: Firebase credentials missing (both JSON env and file).");
        }
    }
};
