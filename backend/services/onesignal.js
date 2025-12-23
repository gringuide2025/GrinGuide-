const config = require('../config');
const axios = require('axios');
const { formatTimeForOneSignal } = require('../utils/time_utils');

// Run initial validation
config.validate();

const API_URL = "https://onesignal.com/api/v1/notifications";

async function sendNotification(payload) {
    if (!config.oneSignal.restKey) {
        throw new Error("❌ Missing ONESIGNAL_REST_KEY env variable.");
    }

    // 🔍 SECURITY & VALIDATION
    // 1. Strip whitespace and quotes (common copy-paste errors)
    const cleanKey = config.oneSignal.restKey.trim().replace(/^['"]|['"]$/g, '');

    // 2. Validate Key Format (Basic check)
    // OneSignal Keys are typically 48 chars (Legacy) or start with os_ (New)
    // But for REST API, we MUST use 'Basic' per documentation requirements.

    // Diagnostic info (NEVER Log full key)
    const keyPrefix = cleanKey.substring(0, 5);
    const keyLength = cleanKey.length;

    console.log(`📡 Preparing Push (ID: ${payload.app_id || config.oneSignal.appId})`);
    console.log(`🔑 Auth Debug: Prefix=${keyPrefix}... Length=${keyLength} Scheme=Basic`);

    const headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": `Basic ${cleanKey}`
    };

    // Add App ID if not present
    if (!payload.app_id) {
        payload.app_id = config.oneSignal.appId;
    }

    // Ensure Deep Link & Channel
    if (!payload.data) payload.data = {};
    if (!payload.data.page) payload.data.page = "/dashboard";

    // Safety: Only set android_channel_id if specifically requested or default to null (let OS decide)
    // If 'sound_chime' doesn't exist on the DASHBOARD, this causes 400 Error.
    // Better to strip it if not sure, or verify it exists.
    // For now, let's omit it from the default payload to guarantee delivery.
    // Specifying a non-existent channel ID is a fatal error in OneSignal.
    if (!payload.android_channel_id) {
        // payload.android_channel_id = "sound_chime"; // CAUSING 400 ERROR
        // Removing explicit default mapping to prevent crash.
    }

    try {
        const response = await axios.post(API_URL, payload, { headers });

        let logMsg = `✅ Push Sent. ID=${response.data.id}, Recipients=${response.data.recipients}`;
        if (payload.delayed_option === 'timezone') {
            logMsg += ` (Scheduled: ${payload.delivery_time_of_day} Local Time)`;
        } else if (payload.send_after) {
            logMsg += ` (Scheduled UTC: ${payload.send_after})`;
        } else {
            logMsg += ` (Sent: IMMEDIATELY)`;
        }

        console.log(logMsg);
        if (response.data.errors) {
            console.warn("⚠️ OneSignal Response Warnings:", response.data.errors);
        }
        return response.data;
    } catch (error) {
        const respData = error.response ? error.response.data : error.message;
        console.error("❌ OneSignal API Error:", respData);

        if (error.response && error.response.status === 403) {
            console.error("💡 TIP: This usually means your ONESIGNAL_REST_KEY is invalid for this App ID, or you are using the wrong key type.");
            console.error("   - Ensure Key matches App ID: " + payload.app_id);
            console.error("   - Rotate Key in OneSignal -> Settings -> Keys & IDs");
        }
        throw error;
    }
}

async function broadcast(title, body) {
    return sendNotification({
        included_segments: ["Total Subscriptions"],
        headings: { "en": title },
        contents: { "en": body },
        android_channel_id: 'sound_chime'
    });
}

async function sendToUser(userId, title, body) {
    // Targeting via External User ID (which should match Firebase UID)
    const basePayload = {
        include_external_user_ids: [userId],
        headings: { "en": title },
        contents: { "en": body }
    };
    return sendNotification(basePayload);
}

// Helper to send targeted batches for sounds
async function sendWithSoundSegments(basePayload) {
    const sounds = ['sound_chime', 'sound_magic', 'sound_pop', 'sound_bird', 'sound_power'];
    const results = [];

    // 1. Send for each Custom Sound
    for (const sound of sounds) {
        // Clone payload
        const p = { ...basePayload };
        // Deep copy data/buttons/headings if needed, but shallow is okay for top level
        // Ideally deep clone to be safe:
        p.data = { ...basePayload.data };
        if (basePayload.buttons) p.buttons = [...basePayload.buttons];
        if (basePayload.headings) p.headings = { ...basePayload.headings };
        if (basePayload.contents) p.contents = { ...basePayload.contents };

        p.filters = [
            { "field": "tag", "key": "notification_sound", "relation": "=", "value": sound }
        ];

        // Remove included_segments if we use filters
        delete p.included_segments;

        try {
            const res = await sendNotification(p);
            results.push(res);
        } catch (e) {
            console.error(`Failed to send batch for ${sound}`, e.message);
        }
    }

    // 2. Default Batch (Everyone Else)
    const pDefault = { ...basePayload };
    pDefault.data = { ...basePayload.data };
    if (basePayload.buttons) pDefault.buttons = [...basePayload.buttons];
    if (basePayload.headings) pDefault.headings = { ...basePayload.headings };
    if (basePayload.contents) pDefault.contents = { ...basePayload.contents };

    pDefault.filters = [
        { "field": "tag", "key": "notification_sound", "relation": "not_exists" }
    ];
    delete pDefault.included_segments;

    try {
        const res = await sendNotification(pDefault);
        results.push(res);
    } catch (e) { console.error("Failed default batch", e.message); }

    return results;
}

async function broadcastWithButtons(title, body, taskType) {
    const taskMap = {
        'brush_morning': 'brushMorning',
        'floss_morning': 'flossMorning',
        'brush_night': 'brushNight',
        'floss_night': 'flossNight'
    };

    const basePayload = {
        included_segments: ["Total Subscriptions"], // Will be removed by helper
        headings: { "en": title },
        contents: { "en": body },
        buttons: [
            { "id": "done", "text": "Done ✓" },
            { "id": "not_done", "text": "Not Done" }
        ],
        data: {
            task: taskMap[taskType] || taskType,
            page: "/dashboard"
        }
    };

    return sendWithSoundSegments(basePayload);
}

async function broadcastDailyFood(foodName, foodBenefit, scheduleTime) {
    const payload = {
        included_segments: ["Total Subscriptions"],
        headings: { "en": `🥗 Today's Super Food: ${foodName}` },
        contents: { "en": `${foodBenefit} \nDid you eat it today?` },
        buttons: [
            { "id": "done", "text": "I Ate It! 😋" },
            { "id": "dismiss", "text": "Dismiss" }
        ],
        data: {
            task: 'healthyFood',
            foodItem: foodName,
            page: "/dashboard"
        }
    };

    if (scheduleTime) {
        payload.delayed_option = "timezone";
        payload.delivery_time_of_day = formatTimeForOneSignal(scheduleTime);
    }

    return sendWithSoundSegments(payload);
}

module.exports = { sendNotification, broadcast, sendToUser, broadcastWithButtons, broadcastDailyFood };
