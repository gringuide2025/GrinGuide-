const axios = require('axios');
const config = require('../config');

const API_URL = "https://onesignal.com/api/v1/notifications";

async function sendNotification(payload) {
    const restKey = config.oneSignal.restKey.value();
    const appId = config.oneSignal.appId.value();

    if (!restKey) {
        throw new Error("Missing ONESIGNAL_REST_KEY");
    }

    const headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": `Basic ${restKey}`
    };

    if (!payload.app_id) {
        payload.app_id = appId;
    }

    // Ensure Deep Link to Dashboard
    if (!payload.data) payload.data = {};
    if (!payload.data.page) payload.data.page = "/dashboard";

    try {
        const response = await axios.post(API_URL, payload, { headers });
        console.log(`✅ Push Sent: ${response.data.id}`);
        return response.data;
    } catch (error) {
        console.error("❌ Push Failed:", error.response ? error.response.data : error.message);
        throw error;
    }
}

module.exports = { sendNotification };
