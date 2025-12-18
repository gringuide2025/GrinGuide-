const { defineString } = require('firebase-functions/params');

// Define parameters that can be set during deployment or in the dashboard
// For sensitive keys, secrets are preferred, but params are easier to start.
const ONESIGNAL_APP_ID = defineString('ONESIGNAL_APP_ID', { default: "48d29f47-c4fa-4e66-86fc-304ffbeff598" });
const ONESIGNAL_REST_KEY = defineString('ONESIGNAL_REST_KEY');

module.exports = {
    oneSignal: {
        appId: ONESIGNAL_APP_ID,
        restKey: ONESIGNAL_REST_KEY
    }
};
