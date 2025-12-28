const { formatTimeForOneSignal, getISTDate } = require('../utils/time_utils');
const oneSignal = require('../services/onesignal');

async function run(scheduleTime = "10:00 AM") {
    // Only run on Sunday (0) in IST
    const istNow = getISTDate();

    if (istNow.getUTCDay() !== 0) {
        console.log("📅 Today is not Sunday in IST. Skipping Weekly Report notification.");
        return;
    }

    console.log(`📊 Today is Sunday (IST). Scheduling Weekly Report for ${scheduleTime}.`);

    // 0. Init IDEMPOTENCY LOCK
    const { init } = require('../services/firebase');
    const admin = init();
    const db = admin.firestore();

    // Use current date (YYYY-MM-DD) as key. 
    // Since it's a broadcast to "Total Subscriptions" (logic in this file), we just need a GLOBAL lock for the day.
    const todayStr = istNow.toISOString().split('T')[0];
    const lockId = `weekly_report_${todayStr}`;
    const lockRef = db.collection('scheduled_tasks').doc(lockId);

    const lockDoc = await lockRef.get();
    if (lockDoc.exists) {
        console.log(`⏭️ Weekly Report already sent for ${todayStr}. Skipping.`);
        return;
    }

    // ... Payload ...
    const payload = {
        included_segments: ["Total Subscriptions"],
        headings: { "en": "Weekly Progress Report 📊" },
        contents: { "en": "Your child's dental report is ready! Check out their progress." },
        buttons: [
            { "id": "view_report", "text": "View Report" }
        ],
        data: {
            task: 'weeklyReport',
            page: "/reports",
            sentDate: todayStr
        }
    };

    if (scheduleTime) {
        // ... (existing schedule logic)
        payload.delayed_option = "timezone";
        payload.delivery_time_of_day = formatTimeForOneSignal(scheduleTime);
    }

    try {
        await oneSignal.sendNotification(payload);
        console.log("✅ Weekly Report notification sent.");

        // MARK AS SENT
        await lockRef.set({
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            type: 'weekly_report',
            date: todayStr
        });

    } catch (e) {
        console.error("❌ Failed to send Weekly Report notification:", e);
    }
}

module.exports = { run };
