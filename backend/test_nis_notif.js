const admin = require('firebase-admin');
const { init } = require('./services/firebase');
const personalTask = require('./tasks/personal_reminders');
const moment = require('moment');

async function run() {
    const app = init();
    const db = admin.firestore();

    console.log("🛠️ Preparing NIS Notification Test...");

    // 1. Find a target vaccine
    const snap = await db.collection('vaccines').limit(1).get();
    if (snap.empty) {
        console.error("❌ No vaccines found! Did you open the app to generate them?");
        return;
    }

    const doc = snap.docs[0];
    const data = doc.data();
    console.log(`🎯 Targeted Vaccine: ${data.vaccineName} (Current Date: ${data.scheduledDate})`);

    // 2. Set date to TODAY
    const todayStr = moment().format('YYYY-MM-DD');
    // We need to keep the time part or just use ISO string matching the app format
    // App uses .toIso8601String(). Backend parses via moment(iso).
    // So setting it to strictly today's ISO start is fine.
    const newDate = moment().startOf('day').add(9, 'hours').toISOString(); // 9 AM today

    await doc.ref.update({
        scheduledDate: newDate,
        isDone: false // Ensure it's pending
    });

    console.log(`✅ Updated ${data.vaccineName} date to: ${newDate} (Today)`);

    // 3. Run the Reminder Task
    console.log("🚀 Triggering Personal Reminders Task...");
    await personalTask.run();
}

run().catch(console.error);
