const oneSignal = require('./services/onesignal');

async function sendMorningBrushWithButtons() {
    console.log('📢 Sending Morning Brush notification with action buttons...');

    const payload = {
        included_segments: ["Total Subscriptions"],
        headings: { "en": "☀️ Morning Brush Time!" },
        contents: { "en": "Time to brush your teeth for 2 minutes. Did you brush?" },
        buttons: [
            { "id": "done", "text": "✅ Done" },
            { "id": "not_done", "text": "❌ Not Done" }
        ],
        data: {
            type: "morning_brush",
            page: "/dashboard"
        }
    };

    try {
        const response = await oneSignal.sendNotification(payload);
        console.log('✅ Notification sent successfully!');
        console.log('Notification ID:', response.id);
        console.log('Recipients:', response.recipients);
    } catch (error) {
        console.error('❌ Failed to send notification:', error.message);
        if (error.response) {
            console.error('Response data:', error.response.data);
        }
    }
}

sendMorningBrushWithButtons();
