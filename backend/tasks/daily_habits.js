const oneSignal = require('../services/onesignal');
const { init } = require('../services/firebase');

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
    },
    // Keep legacy for safety, though unused in new loop
    brush_morning: { title: "Morning Brush ☀️", baseBody: "Time to shine!", task: "brushMorning" }
};

async function run(type, scheduleTime, targetUid, force = false) {
    // 1. Init Firebase (if not already)
    const admin = init();
    const db = admin.firestore();

    const config = MESSAGES[type];
    if (!config) {
        console.error(`❌ Unknown habit type: ${type}`);
        return;
    }

    console.log(`📢 Starting Personalized Broadcast for: ${config.title}${targetUid ? ' (Targeting: ' + targetUid + ')' : ''} ${force ? '[FORCE MODE]' : ''}`);

    // 2. Fetch All Parents (Users)
    // We actually need children to know names.
    // Efficient way: Fetch all children, group by Parent ID.
    const kidsSnap = await db.collection('children').get();

    // 3. Send Notification to each Child Individually
    let sentCount = 0;
    const todayStr = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

    for (const doc of kidsSnap.docs) {
        const data = doc.data();
        const parentId = data.parentId;
        if (!parentId) continue;

        // --- TESTING FILTER ---
        if (targetUid && parentId !== targetUid) {
            continue;
        }

        const childId = doc.id;
        const childName = data.name || "Kiddo";

        // Idempotency Key - PER CHILD
        const lockId = `${childId}_${type}_${todayStr}`;
        const lockRef = db.collection('scheduled_tasks').doc(lockId);

        const lockDoc = await lockRef.get();
        if (lockDoc.exists && !targetUid && !force) {
            console.log(`⏭️ Skipping ${childName} (Already sent today)`);
            continue;
        }

        // Construct Personalized Body for Single Child
        const personalBody = `Hey ${childName}, ${config.baseBody.toLowerCase()}`;

        // Prepare Payload
        const payload = {
            include_external_user_ids: [parentId],
            headings: { "en": config.title },
            contents: { "en": personalBody },
            buttons: [
                { "id": "done", "text": "Done ✓" },
                { "id": "not_done", "text": "Not Done" }
            ],
            data: {
                task: config.task,
                childId: childId, // Important: Pass childId so action knows which child!
                page: "/dashboard",
            }
        };

        if (scheduleTime) {
            payload.delayed_option = "timezone";
            payload.delivery_time_of_day = scheduleTime;
        }

        // Send via OneSignal
        try {
            await oneSignal.sendNotification(payload);
            sentCount++;

            // Safety Delay: Avoid clashing for multiple children
            await new Promise(resolve => setTimeout(resolve, 1000));

            // Mark as sent
            await lockRef.set({
                sentAt: admin.firestore.FieldValue.serverTimestamp(),
                childId: childId,
                parentId: parentId,
                type: type
            });

        } catch (e) {
            console.error(`Failed to send to ${parentId} for ${childName}:`, e.message);
        }
    }

    console.log(`✅ Sent personalized habits to ${sentCount} children.`);
}

module.exports = { run };
