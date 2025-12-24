const oneSignal = require('../services/onesignal');
const moment = require('moment');
const { formatTimeForOneSignal } = require('../utils/time_utils');

async function run(scheduleTime = "10:00 AM") {
    // Only run on Sunday (0) in IST
    const istOffset = 5.5 * 60 * 60 * 1000;
    const nowIst = new Date(new Date().getTime() + istOffset);

    if (nowIst.getUTCDay() !== 0) {
        console.log("📅 Today is not Sunday in IST. Skipping Weekly Report notification.");
        return;
    }

    console.log(`📊 Today is Sunday (IST). Scheduling Weekly Report for ${scheduleTime}.`);

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
