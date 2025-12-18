const fs = require('fs');
const path = require('path');
const { init } = require('../services/firebase');
const oneSignal = require('../services/onesignal');

async function run(scheduleTime) {
    const admin = init();
    const db = admin.firestore ? admin.firestore() : null;

    // 1. Load Foods
    const foodsPath = path.join(__dirname, '..', 'foods.json');
    const foods = JSON.parse(fs.readFileSync(foodsPath, 'utf8'));

    // 2. Deterministic Selection
    // This MUST match the Flutter app logic: dayOfYear % count
    const dayOfYear = Math.floor((new Date() - new Date(new Date().getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24);
    selectedFood = foods[dayOfYear % foods.length];

    console.log(`🥕 Selected (Deterministic): ${selectedFood.name}`);

    // 3. Send Push with Actions & Schedule
    const todayStr = new Date().toISOString().split('T')[0];
    const lockId = `GLOBAL_food_${todayStr}`;
    const lockRef = db.collection('scheduled_tasks').doc(lockId);

    const lockDoc = await lockRef.get();
    if (lockDoc.exists) {
        console.log(`⚠️ Daily Food already scheduled for ${todayStr}. Skipping.`);
        return;
    }

    try {
        await oneSignal.broadcastDailyFood(selectedFood.name, selectedFood.benefit, scheduleTime);
        await lockRef.set({ sentAt: admin.firestore.FieldValue.serverTimestamp() });
    } catch (e) {
        console.error("❌ Failed to broadcast daily food:", e);
    }
}

module.exports = { run };

