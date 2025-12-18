const admin = require('firebase-admin');
const oneSignal = require('../services/onesignal');

const MESSAGES = {
    morning_routine: {
        title: "Morning Routine ☀️",
        baseBody: "Time to brush & floss! Keep those teeth sparkling! 🦷✨",
        task: "morningRoutine"
    },
    night_routine: {
        title: "Night Routine 🌙",
        baseBody: "Brush & floss before bed! Sweet dreams start with clean teeth! 😴🦷",
        task: "nightRoutine"
    }
};

async function run(type) {
    const db = admin.firestore();
    const config = MESSAGES[type];
    if (!config) return;

    const todayStr = new Date().toISOString().split('T')[0];
    const kidsSnap = await db.collection('children').get();

    for (const doc of kidsSnap.docs) {
        const data = doc.data();
        const parentId = data.parentId;
        if (!parentId) continue;

        const childId = doc.id;
        const childName = data.name || "Kiddo";

        const lockId = `notif_${childId}_${type}_${todayStr}`;
        const lockRef = db.collection('scheduled_tasks').doc(lockId);

        const lockDoc = await lockRef.get();
        if (lockDoc.exists) continue;

        await oneSignal.sendNotification({
            include_external_user_ids: [parentId],
            headings: { "en": config.title },
            contents: { "en": `Hey ${childName}, ${config.baseBody}` },
            buttons: [
                { "id": "done", "text": "Done ✓" },
                { "id": "not_done", "text": "Not Done" }
            ],
            data: {
                task: config.task,
                childId: childId,
                page: "/dashboard",
            }
        });

        await lockRef.set({
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            type: type
        });

        // Add 1-second delay between children as requested
        await new Promise(resolve => setTimeout(resolve, 1000));
    }
}

module.exports = { run };
