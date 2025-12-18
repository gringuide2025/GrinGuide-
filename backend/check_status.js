const axios = require('axios');
const config = require('./config');

const NOTIFICATION_ID = process.argv[2];
let API_URL;

if (!NOTIFICATION_ID) {
    console.log("⚠️ No ID provided. Fetching LATEST notification...");
    API_URL = `https://onesignal.com/api/v1/notifications?app_id=${config.oneSignal.appId}&limit=1`;
} else {
    API_URL = `https://onesignal.com/api/v1/notifications/${NOTIFICATION_ID}?app_id=${config.oneSignal.appId}`;
}

async function check() {
    try {
        const response = await axios.get(API_URL, {
            headers: {
                "Authorization": `Basic ${config.oneSignal.restKey}`
            }
        });

        let data = response.data;

        if (data.notifications && data.notifications.length > 0) {
            data = data.notifications[0];
            console.log("👇 LATEST NOTIFICATION FOUND 👇");
        } else if (data.notifications) {
            console.log("❌ No notifications found.");
            return;
        }

        console.log("--- Notification Status ---");
        console.log(`ID: ${data.id}`);
        console.log(`Heading: ${JSON.stringify(data.headings)}`);
        console.log(`Successful: ${data.successful}`);
        console.log(`Failed: ${data.failed}`);
        console.log(`Errored: ${data.errored}`);
        console.log(`Canceled: ${data.canceled}`);
        console.log(`Converted: ${data.converted}`); // Clicked
        console.log(`Remaining: ${data.remaining}`);

        if (data.platform_delivery_stats) {
            console.log("Platform Stats:", data.platform_delivery_stats);
        }
    } catch (e) {
        console.error("Error fetching status:", e.response ? e.response.data : e.message);
    }
}

check();
