const oneSignal = require('../services/onesignal');
const moment = require('moment');
const { formatTimeForOneSignal } = require('../utils/time_utils');

async function run(scheduleTime) {
    // Only run on Sunday (0)
    const today = moment();
    if (today.day() !== 0) {
        console.log("📅 Today is not Sunday. Skipping Weekly Report notification.");
        return;
    }

    console.log(`📊 Today is Sunday. Scheduling Weekly Report for ${scheduleTime || 'Now'}.`);

    const payload = {
        included_segments: ["Total Subscriptions"],
        headings: { "en": "Weekly Progress Report 📊" },
        contents: { "en": "Your child's dental report is ready! Check out their progress." },
        buttons: [
            { "id": "view_report", "text": "View Report" }
        ],
        data: {
            task: 'weeklyReport',
            page: "/reports"
        }
    };

    if (scheduleTime) {
        payload.delayed_option = "timezone";
        payload.delivery_time_of_day = formatTimeForOneSignal(scheduleTime);
    }

    try {
        await oneSignal.sendNotification(payload);
        console.log("✅ Weekly Report notification sent.");
    } catch (e) {
        console.error("❌ Failed to send Weekly Report notification:", e);
    }
}

module.exports = { run };
