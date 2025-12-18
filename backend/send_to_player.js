const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const oneSignal = require('./services/onesignal');

// Initialize Firebase
const firebaseService = require('./services/firebase');
firebaseService.init();
const db = getFirestore();

async function sendToUserWithPlayerId() {
    const userId = 'RaMKCOnYtPVnUbiwVQ41BDmrcK32';

    console.log('🔍 Fetching player ID from Firestore...');

    try {
        const userDoc = await db.collection('users').doc(userId).get();

        if (!userDoc.exists) {
            console.error('❌ User document not found in Firestore');
            return;
        }

        const userData = userDoc.data();
        const playerIds = userData.oneSignalPlayerIds;

        if (!playerIds || playerIds.length === 0) {
            console.error('❌ No player IDs found for user');
            return;
        }

        const playerId = playerIds[0];
        console.log('✅ Found player ID:', playerId);
        console.log('📢 Sending notification...');

        const payload = {
            include_player_ids: [playerId],
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

        const response = await oneSignal.sendNotification(payload);
        console.log('✅ Notification sent successfully!');
        console.log('Notification ID:', response.id);
        console.log('Recipients:', response.recipients);

    } catch (error) {
        console.error('❌ Error:', error.message);
        if (error.response) {
            console.error('Response data:', error.response.data);
        }
    }
}

sendToUserWithPlayerId();
