const https = require('https');
const fs = require('fs');

// CONFIGURATION
const APP_ID = process.env.ONESIGNAL_APP_ID;
const REST_API_KEY = process.env.ONESIGNAL_REST_KEY;

if (!REST_API_KEY) {
    console.error("❌ ERROR: ONESIGNAL_REST_KEY environment variable is missing.");
    console.error("Usage: set ONESIGNAL_REST_KEY=your_key_here && node daily_push.js");
    process.exit(1);
}

const path = require('path');
// 1. Get Today's Food
const foods = JSON.parse(fs.readFileSync(path.join(__dirname, 'foods.json'), 'utf8'));
const dayOfYear = Math.floor((new Date() - new Date(new Date().getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24);
const foodItem = foods[dayOfYear % foods.length];

console.log(`📅 Today is Day ${dayOfYear}. Selected Food: ${foodItem.name}`);

// 2. Prepare Notification Payload
const data = JSON.stringify({
    app_id: APP_ID,
    included_segments: ["Total Subscriptions"], // Send to everyone
    headings: { "en": "🥗 Today's Healthy Food" },
    contents: { "en": `${foodItem.name} – ${foodItem.benefit}` },
    // Optional: Deep link to open app
    // data: { page: "/dashboard" } 
});

// 3. Send Request to OneSignal
const options = {
    hostname: "onesignal.com",
    port: 443,
    path: "/api/v1/notifications",
    method: "POST",
    headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": `Basic ${REST_API_KEY}`
    }
};

const req = https.request(options, (res) => {
    let responseData = '';

    res.on('data', (chunk) => {
        responseData += chunk;
    });

    res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
            console.log("✅ Notification Sent Successfully!");
            console.log("Response:", JSON.parse(responseData));
        } else {
            console.error("❌ Error Sending Notification:", res.statusCode);
            console.error("Response:", responseData);
        }
    });
});

req.on('error', (e) => {
    console.error("❌ Network Error:", e);
});

req.write(data);
req.end();
