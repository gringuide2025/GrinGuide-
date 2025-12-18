const oneSignal = require('./services/onesignal');

async function sendBroadcastTest() {
    console.log('📢 Sending broadcast notification to ALL users...');

    try {
        await oneSignal.broadcast(
            "🦷 Test Notification",
            "Testing OneSignal push notifications! If you see this, it works! 🎉"
        );
        console.log('✅ Broadcast sent successfully!');
    } catch (error) {
        console.error('❌ Failed to send broadcast:', error.message);
        if (error.response) {
            console.error('Response data:', error.response.data);
        }
    }
}

sendBroadcastTest();
