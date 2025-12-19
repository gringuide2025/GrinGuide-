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
        privateKey: (() => {
            const key = process.env.FIREBASE_PRIVATE_KEY;
            if (!key) return undefined;

            // 1. Remove outer quotes if present
            let cleanKey = key.replace(/^"|"$/g, '');

            // 2. Unescape newlines (handle both \\n and \n literal text)
            cleanKey = cleanKey.replace(/\\n/g, '\n');

            // 3. Debug formatting (Safe Hash / Check)
            const len = cleanKey.length;
            const start = cleanKey.substring(0, 10);
            const end = cleanKey.substring(len - 10);
            console.log(`🔑 Private Key Loaded: Len=${len}, Start='${start}...', End='...${end}'`);

            return cleanKey;
        })(),
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
