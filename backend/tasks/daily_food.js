const fs = require('fs');
const path = require('path');
const { init } = require('../services/firebase');
const oneSignal = require('../services/onesignal');
const { formatTimeForOneSignal } = require('../utils/time_utils');



function calculateDeliveryTime(scheduleTime) {
    if (!scheduleTime) return null;

    // 1. Get current time in IST
    const now = new Date();
    const istOffset = 5.5 * 60 * 60 * 1000;
    const nowIst = new Date(now.getTime() + istOffset);

    // 2. Parse input time (e.g., "8:00 AM" or "9:00 PM")
    const formatted = formatTimeForOneSignal(scheduleTime);
    const [hours, minutes] = formatted.split(':').map(Number);

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

async function run(scheduleTime) {
    const admin = init();
    const db = admin.firestore ? admin.firestore() : null;

    // 1. Load Foods
    const foodsPath = path.join(__dirname, '..', 'foods.json');
    const foods = JSON.parse(fs.readFileSync(foodsPath, 'utf8'));

    // 2. Deterministic Selection
    // This MUST match the Flutter app logic: dayOfYear % count
    const dayOfYear = Math.floor((new Date() - new Date(new Date().getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24);
    const selectedFood = foods[dayOfYear % foods.length];

    console.log(`🥕 Selected Food: ${selectedFood.name}`);
    console.log(`📢 Starting Per-Child Food Notifications...`);

    // 3. Fetch All Children
    const kidsSnap = await db.collection('children').get();
    console.log(`🔎 Found ${kidsSnap.size} children in database.`);

    // 4. Send Notification to each Child Individually
    let sentCount = 0;
    const todayStr = new Date().toISOString().split('T')[0];

    for (const doc of kidsSnap.docs) {
        const data = doc.data();
        const parentId = data.parentId;
        if (!parentId) continue;

        const childId = doc.id;
        const childName = data.name || "Kiddo";

        // Idempotency Key - PER CHILD
        const lockId = `${childId}_food_${todayStr}`;
        const lockRef = db.collection('scheduled_tasks').doc(lockId);

        const lockDoc = await lockRef.get();
        if (lockDoc.exists) {
            console.log(`⏭️ Skipping ${childName} (Already sent today)`);
            continue;
        }

        // Construct Personalized Message
        const personalBody = `Hey ${childName}, today's super food is ${selectedFood.name}! ${selectedFood.benefit} Did you eat it? 🥗`;

        // Prepare Payload
        const payload = {
            include_external_user_ids: [parentId],
            headings: { "en": `🥗 Today's Super Food: ${selectedFood.name}` },
            contents: { "en": personalBody },
            buttons: [
                { "id": "done", "text": "I Ate It! 😋" },
                { "id": "dismiss", "text": "Skip" }
            ],
            data: {
                task: "healthyFood",
                childId: childId,  // CRITICAL: Pass childId so action knows which child!
                parentId: parentId, // Added for security rules
                foodItem: selectedFood.name,
                page: "/dashboard"
            }
        };

        // Use OneSignal's built-in timezone-aware scheduling
        if (scheduleTime) {
            payload.delayed_option = "timezone";
            payload.delivery_time_of_day = formatTimeForOneSignal(scheduleTime);
            console.log(`   📅 [DEBUG] Scheduled for ${payload.delivery_time_of_day} (User's Local Time)`);
        } else {
            console.log(`   🚀 [DEBUG] No scheduleTime provided, sending IMMEDIATELY`);
        }

        // Send via OneSignal
        try {
            await oneSignal.sendNotification(payload);
            sentCount++;
            console.log(`✅ Sent to ${childName} (Parent: ${parentId})`);

            // Safety Delay
            await new Promise(resolve => setTimeout(resolve, 1000));

            // Mark as sent
            await lockRef.set({
                sentAt: admin.firestore.FieldValue.serverTimestamp(),
                childId: childId,
                parentId: parentId,
                type: 'food',
                foodItem: selectedFood.name
            });

        } catch (e) {
            console.error(`❌ Failed to send to ${parentId} for ${childName}:`, e.message);
        }
    }

    console.log(`✅ Sent daily food to ${sentCount} children.`);
}

module.exports = { run };
