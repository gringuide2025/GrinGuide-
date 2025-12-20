const fs = require('fs');
const path = require('path');
const { init } = require('../services/firebase');
const oneSignal = require('../services/onesignal');

// Helper function to calculate tomorrow's delivery time
function calculateDeliveryTime(scheduleTime) {
    if (!scheduleTime) return null;

    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Parse time like "8:00 AM"
    const [time, period] = scheduleTime.split(' ');
    let [hours, minutes] = time.split(':').map(Number);

    // Convert to 24-hour format
    if (period === 'PM' && hours !== 12) hours += 12;
    if (period === 'AM' && hours === 12) hours = 0;

    // Convert IST to UTC (IST = UTC + 5:30)
    hours -= 5;
    minutes -= 30;
    if (minutes < 0) {
        minutes += 60;
        hours -= 1;
    }
    if (hours < 0) {
        hours += 24;
        tomorrow.setDate(tomorrow.getDate() - 1);
    }

    tomorrow.setUTCHours(hours, minutes, 0, 0);
    return tomorrow;
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
                foodItem: selectedFood.name,
                page: "/dashboard"
            }
        };

        // Use precise scheduling with send_after
        if (scheduleTime) {
            const deliveryTime = calculateDeliveryTime(scheduleTime);
            if (deliveryTime) {
                payload.send_after = deliveryTime.toISOString();
                console.log(`   📅 Scheduled for: ${deliveryTime.toISOString()} (${scheduleTime} IST)`);
            }
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
