const oneSignal = require('./services/onesignal');

async function sendTargetedMorningBrush() {
    console.log('📢 Sending targeted Morning Brush notification...');

    // Using player ID directly from Firestore
    const payload = {
        include_player_ids: ["YOUR_PLAYER_ID_HERE"], // We'll need to get this from Firestore
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

sendTargetedMorningBrush();
