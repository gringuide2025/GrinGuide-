const oneSignal = require('./services/onesignal');

async function notifyUpdate() {
    const title = "🚀 Important Update: GrinGuide v1.0.4+9";
    const body = "Please update GrinGuide from the Play Store now to fix notification timing and improve stability! 🦷✨";

    console.log("📢 Sending Update Broadcast to all users...");

    try {
        const result = await oneSignal.sendNotification({
            included_segments: ["Total Subscriptions"],
            headings: { "en": title },
            contents: { "en": body },
            data: { page: "/settings" }
        });
        console.log("✅ Update notification sent successfully!");
    } catch (e) {
        console.error("❌ Failed to broadcast update notification:", e.message);
    }
}

notifyUpdate();
