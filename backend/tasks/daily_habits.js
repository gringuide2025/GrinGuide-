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

function calculateDeliveryTime(scheduleTime) {
    if (!scheduleTime) return null;

    // 1. Get current time in IST
    const now = new Date();
    const istOffset = 5.5 * 60 * 60 * 1000;
    const nowIst = new Date(now.getTime() + istOffset);

    // 2. Parse input time (e.g., "7:00 AM" or "9:00 PM")
    const [time, period] = scheduleTime.split(' ');
    let [hours, minutes] = time.split(':').map(Number);
    if (period === 'PM' && hours !== 12) hours += 12;
    if (period === 'AM' && hours === 12) hours = 0;

    // 3. Create target time in IST (starting today)
    const targetIst = new Date(nowIst.getTime());
    targetIst.setUTCHours(hours, minutes, 0, 0);

    // 4. If target is in the past, move to tomorrow
    if (targetIst < nowIst) {
        targetIst.setUTCDate(targetIst.getUTCDate() + 1);
    }

    // 5. Convert target IST back to real UTC for OneSignal
    const finalUtc = new Date(targetIst.getTime() - istOffset);

    return finalUtc;
}

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

    console.log(`🔎 Found ${kidsSnap.size} children in database.`);

    // 3. Send Notification to each Child Individually
    let sentCount = 0;
    const todayStr = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

    for (const doc of kidsSnap.docs) {
        // ... (existing loop logic) ...
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

        // ... (payload construction) ...

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
                parentId: parentId, // Added for security rules & direct access
                page: "/dashboard",
            }
        };

        // Use precise scheduling with send_after instead of delayed_option
        if (scheduleTime) {
            const deliveryTime = calculateDeliveryTime(scheduleTime);
            if (deliveryTime) {
                payload.send_after = deliveryTime.toISOString();
                console.log(`   📅 [DEBUG] Setting send_after: ${payload.send_after} (IST Input: ${scheduleTime})`);
            } else {
                console.warn(`   ⚠️ [DEBUG] calculateDeliveryTime returned null for ${scheduleTime}`);
            }
        } else {
            console.log(`   🚀 [DEBUG] No scheduleTime provided, sending IMMEDIATELY`);
        }

        // Send via OneSignal
        try {
            await oneSignal.sendNotification(payload);
            sentCount++;
            console.log(`✅ Sent to ${childName} (Parent: ${parentId})`);

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

    // FAIL if 0 sent in FORCE/TEST mode
    if (sentCount === 0 && (force || targetUid)) {
        throw new Error("❌ No notifications were sent! (Database empty or all skipped?)");
    }
}

module.exports = { run };
