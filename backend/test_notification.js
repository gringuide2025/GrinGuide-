const oneSignal = require('./services/onesignal');

async function sendTestNotification() {
    const userId = 'RaMKCOnYtPVnUbiwVQ41BDmrcK32'; // Your Firebase UID

    console.log(`📢 Sending test notification to user: ${userId}`);

    try {
        await oneSignal.sendToUser(
            userId,
            "🦷 Morning Brush Time!",
            "Good morning! Time to brush your teeth for 2 minutes ☀️"
        );
        console.log('✅ Notification sent successfully!');
    } catch (error) {
        console.error('❌ Failed to send notification:', error.message);
    }
}

sendTestNotification();
