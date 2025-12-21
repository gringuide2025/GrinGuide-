const { init } = require('../services/firebase');
const oneSignal = require('../services/onesignal');
const moment = require('moment');

async function run() {
    const admin = init();
    if (!admin.firestore) {
        console.error("❌ Firebase Admin not initialized. Skipping personal checks.");
        return;
    }
    const db = admin.firestore();

    const today = moment().startOf('day');
    const tomorrow = moment().add(1, 'days').startOf('day');
    const nextWeek = moment().add(7, 'days').startOf('day');

    // Deduplication Set: parentId|body
    const sentNotifications = new Set();

    // Helper to format Date for Firestore Query (Assuming stored as ISO Strings or Timestamp)
    // Firestore matches are tricky with Strings vs Timestamps. 
    // Codebase uses ISO strings for scheduledDate.

    const targetDates = [
        { label: "Today", date: today.format('YYYY-MM-DD') }, // Matches ISO substring? No, we need logic.
        // Firestore String query is usually Exact. 
        // If the app stores "2024-12-15T00:00:00.000", we need range or strict match.
        // Let's grab ALL vaccines/appointments and filter in memory for this MVP script 
        // (Scale concern: fine for <10k users).
    ];

    console.log("🔍 Scanning for Personal Reminders...");

    // 1. VACCINES 💉
    const vSnap = await db.collection('vaccines').where('isDone', '==', false).get();
    let vCount = 0;

    for (const doc of vSnap.docs) {
        const data = doc.data();
        if (!data.scheduledDate) continue;

        const sDate = moment(data.scheduledDate).startOf('day'); // normalize
        let trigger = null;

        if (sDate.isSame(today)) trigger = "Today";
        else if (sDate.isSame(tomorrow)) trigger = "Tomorrow";
        else if (sDate.isSame(nextWeek)) trigger = "In 1 Week";

        if (trigger) {
            // 1. Idempotency Check (PER CHILD & TYPE)
            const todayStr = today.format('YYYY-MM-DD');
            const lockId = `${data.childId}_vaccine_${todayStr}`;
            const lockRef = db.collection('scheduled_tasks').doc(lockId);
            const lockDoc = await lockRef.get();

            if (lockDoc.exists) {
                console.log(`⚠️ Reminder already sent for Vaccine ${data.vaccineName} today. Skipping.`);
                continue;
            }

            // 2. Legacy Check
            if (data.remindersSent && data.remindersSent.includes(todayStr)) {
                continue;
            }

            // Get Parent ID
            const childDoc = await db.collection('children').doc(data.childId).get();
            if (childDoc.exists) {
                const childData = childDoc.data();
                const parentId = childData.parentId;
                const childName = childData.name || "Kiddo";

                if (parentId) {
                    // Personalized Message
                    const body = `Hey ${childName}, it is time to get your ${data.vaccineName} vaccine! 💉`;

                    // Send with Action Buttons & Scheduling
                    await oneSignal.sendNotification({
                        include_external_user_ids: [parentId],
                        headings: { "en": "Vaccine Reminder 💉" },
                        contents: { "en": body },
                        buttons: [
                            { "id": "done", "text": "Mark Done ✓" },
                            { "id": "reschedule", "text": "Reschedule 📅" }
                        ],
                        // Schedule for 8:05 AM User's Time
                        delayed_option: "timezone",
                        delivery_time_of_day: "8:05 AM",
                        data: {
                            task: 'vaccine',
                            docId: doc.id,
                            childId: data.childId,
                            parentId: parentId,
                            vaccineName: data.vaccineName
                        }
                    });

                    // Mark as sent (both in doc and global lock)
                    const updateTask = db.collection('vaccines').doc(doc.id).update({
                        remindersSent: admin.firestore.FieldValue.arrayUnion(todayStr)
                    });
                    const lockTask = lockRef.set({
                        sentAt: admin.firestore.FieldValue.serverTimestamp(),
                        childId: data.childId,
                        parentId: parentId,
                        type: 'vaccine'
                    });
                    await Promise.all([updateTask, lockTask]);

                    vCount++;
                }
            }
        }
    }

    // 2. DENTAL 🦷
    const dSnap = await db.collection('dental_appointments').where('isDone', '==', false).get();
    let dCount = 0;

    for (const doc of dSnap.docs) {
        const data = doc.data();
        if (!data.appointmentDate) continue;

        const sDate = moment(data.appointmentDate).startOf('day');
        let trigger = null;

        if (sDate.isSame(today)) trigger = "Today";
        else if (sDate.isSame(tomorrow)) trigger = "Tomorrow";
        else if (sDate.isSame(nextWeek)) trigger = "In 1 Week";

        if (trigger) {
            // 1. Idempotency Check (PER CHILD & TYPE)
            const todayStr = today.format('YYYY-MM-DD');
            const lockId = `${data.childId}_dental_${todayStr}`;
            const lockRef = db.collection('scheduled_tasks').doc(lockId);
            const lockDoc = await lockRef.get();

            if (lockDoc.exists) {
                console.log(`⚠️ Reminder already sent for Dental Appointment today. Skipping.`);
                continue;
            }

            // 2. Legacy Check
            if (data.remindersSent && data.remindersSent.includes(todayStr)) {
                continue;
            }

            const childDoc = await db.collection('children').doc(data.childId).get();
            if (childDoc.exists) {
                const childData = childDoc.data();
                const parentId = childData.parentId;
                const childName = childData.name || "Kiddo";

                if (parentId) {
                    // Personalized Message
                    const body = `Hey ${childName}, it is time for your appointment with ${data.doctorName}. 🦷`;

                    // Send with Action Buttons & Scheduling
                    await oneSignal.sendNotification({
                        include_external_user_ids: [parentId],
                        headings: { "en": "Dental Appointment 🦷" },
                        contents: { "en": body },
                        buttons: [
                            { "id": "done", "text": "Mark Done ✓" },
                            { "id": "reschedule", "text": "Reschedule 📅" }
                        ],
                        // Schedule for 8:10 AM User's Time
                        delayed_option: "timezone",
                        delivery_time_of_day: "8:10 AM",
                        data: {
                            task: 'dental',
                            docId: doc.id,
                            parentId: parentId,
                            childId: data.childId
                        }
                    });

                    // Mark as sent
                    const updateTask = db.collection('dental_appointments').doc(doc.id).update({
                        remindersSent: admin.firestore.FieldValue.arrayUnion(todayStr)
                    });
                    const lockTask = lockRef.set({
                        sentAt: admin.firestore.FieldValue.serverTimestamp(),
                        childId: data.childId,
                        parentId: parentId,
                        type: 'dental'
                    });
                    await Promise.all([updateTask, lockTask]);

                    dCount++;
                }
            }
        }
    }

    console.log(`✅ Sent ${vCount} Vaccine & ${dCount} Dental reminders.`);
}

module.exports = { run };
