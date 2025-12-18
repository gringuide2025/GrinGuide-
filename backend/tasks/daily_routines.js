const admin = require('firebase-admin');
const https = require('https');
const config = require('../config');

/**
 * Send Morning Routine Notification (Brush + Floss)
 * Runs at 7:00 AM daily
 */
async function sendMorningRoutineNotifications() {
    console.log('🌅 Sending Morning Routine notifications...');

    try {
        // Get all children from Firestore
        const childrenSnapshot = await admin.firestore().collection('children').get();

        if (childrenSnapshot.empty) {
            console.log('No children found in database');
            return;
        }

        const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

        // Send notification for each child
        for (const childDoc of childrenSnapshot.docs) {
            const child = childDoc.data();
            const childId = childDoc.id;

            // Get parent's OneSignal player ID
            const parentDoc = await admin.firestore().collection('users').doc(child.parentId).get();
            if (!parentDoc.exists) continue;

            const parent = parentDoc.data();
            const playerIds = parent.oneSignalPlayerIds || [];

            if (playerIds.length === 0) {
                console.log(`No OneSignal player IDs for parent of ${child.name}`);
                continue;
            }

            // Prepare notification
            const notification = {
                app_id: config.oneSignal.appId,
                include_player_ids: playerIds,
                headings: { "en": "Good Morning! ☀️ Time to Brush & Floss" },
                contents: { "en": `Let's start the day fresh, ${child.name}! Brush for 2 minutes and floss between teeth.` },
                data: {
                    childId: childId,
                    task: 'morningRoutine',
                    date: today,
                    type: 'daily_habit'
                },
                buttons: [
                    { "id": "done", "text": "Done" },
                    { "id": "not_done", "text": "Not Done" }
                ],
                android_channel_id: "daily_habits"
            };

            await sendOneSignalNotification(notification);
            console.log(`✅ Sent morning routine notification for ${child.name}`);

            // Small delay to prevent spam
            await sleep(1000);
        }

        console.log('✅ All morning routine notifications sent');
    } catch (error) {
        console.error('❌ Error sending morning routine notifications:', error);
    }
}

/**
 * Send Healthy Food Notification
 * Runs at 8:00 AM daily
 */
async function sendHealthyFoodNotifications() {
    console.log('🍎 Sending Healthy Food notifications...');

    try {
        const childrenSnapshot = await admin.firestore().collection('children').get();
        if (childrenSnapshot.empty) return;

        const today = new Date().toISOString().split('T')[0];

        for (const childDoc of childrenSnapshot.docs) {
            const child = childDoc.data();
            const childId = childDoc.id;

            // Get today's checklist to find the healthy food item
            const checklistDoc = await admin.firestore()
                .collection('daily_checklist')
                .doc(`${childId}_${today}`)
                .get();

            let foodItem = 'a healthy breakfast';
            if (checklistDoc.exists) {
                const checklist = checklistDoc.data();
                foodItem = checklist.healthyFoodItem || foodItem;
            }

            // Get parent's player IDs
            const parentDoc = await admin.firestore().collection('users').doc(child.parentId).get();
            if (!parentDoc.exists) continue;

            const playerIds = parentDoc.data().oneSignalPlayerIds || [];
            if (playerIds.length === 0) continue;

            const notification = {
                app_id: config.oneSignal.appId,
                include_player_ids: playerIds,
                headings: { "en": "Healthy Food Time! 🍎" },
                contents: { "en": `Time for ${child.name} to eat ${foodItem}! A healthy breakfast makes you strong!` },
                data: {
                    childId: childId,
                    task: 'healthyFood',
                    foodItem: foodItem,
                    date: today,
                    type: 'daily_habit'
                },
                buttons: [
                    { "id": "done", "text": "Done" },
                    { "id": "not_done", "text": "Not Done" }
                ],
                android_channel_id: "daily_habits"
            };

            await sendOneSignalNotification(notification);
            console.log(`✅ Sent healthy food notification for ${child.name} (${foodItem})`);
            await sleep(1000);
        }

        console.log('✅ All healthy food notifications sent');
    } catch (error) {
        console.error('❌ Error sending healthy food notifications:', error);
    }
}

/**
 * Send Night Routine Notification (Brush + Floss)
 * Runs at 9:00 PM daily
 */
async function sendNightRoutineNotifications() {
    console.log('🌙 Sending Night Routine notifications...');

    try {
        const childrenSnapshot = await admin.firestore().collection('children').get();
        if (childrenSnapshot.empty) return;

        const today = new Date().toISOString().split('T')[0];

        for (const childDoc of childrenSnapshot.docs) {
            const child = childDoc.data();
            const childId = childDoc.id;

            const parentDoc = await admin.firestore().collection('users').doc(child.parentId).get();
            if (!parentDoc.exists) continue;

            const playerIds = parentDoc.data().oneSignalPlayerIds || [];
            if (playerIds.length === 0) continue;

            const notification = {
                app_id: config.oneSignal.appId,
                include_player_ids: playerIds,
                headings: { "en": "Bedtime Routine! 🌙" },
                contents: { "en": `Before bed, ${child.name}! Brush for 2 minutes and floss for a perfect night's sleep.` },
                data: {
                    childId: childId,
                    task: 'nightRoutine',
                    date: today,
                    type: 'daily_habit'
                },
                buttons: [
                    { "id": "done", "text": "Done" },
                    { "id": "not_done", "text": "Not Done" }
                ],
                android_channel_id: "daily_habits"
            };

            await sendOneSignalNotification(notification);
            console.log(`✅ Sent night routine notification for ${child.name}`);
            await sleep(1000);
        }

        console.log('✅ All night routine notifications sent');
    } catch (error) {
        console.error('❌ Error sending night routine notifications:', error);
    }
}

/**
 * Send OneSignal notification via REST API
 */
function sendOneSignalNotification(payload) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify(payload);

        const options = {
            hostname: 'onesignal.com',
            port: 443,
            path: '/api/v1/notifications',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': `Basic ${config.oneSignal.restKey}`
            }
        };

        const req = https.request(options, (res) => {
            let responseData = '';

            res.on('data', (chunk) => {
                responseData += chunk;
            });

            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve(JSON.parse(responseData));
                } else {
                    reject(new Error(`OneSignal API error: ${res.statusCode} - ${responseData}`));
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        req.write(data);
        req.end();
    });
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

module.exports = {
    sendMorningRoutineNotifications,
    sendHealthyFoodNotifications,
    sendNightRoutineNotifications
};
