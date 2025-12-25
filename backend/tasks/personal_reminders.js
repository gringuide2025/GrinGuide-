const { init } = require('../services/firebase');
const oneSignal = require('../services/onesignal');
const moment = require('moment');
const { formatTimeForOneSignal, getISTDate } = require('../utils/time_utils');

async function run(categoryFilter = null) {
    const admin = init();
    if (!admin.firestore) {
        console.error("❌ Firebase Admin not initialized. Skipping personal checks.");
        return;
    }
    const db = admin.firestore();

    const istDate = getISTDate();
    const today = moment(istDate).startOf('day');
    const tomorrow = moment(istDate).add(1, 'days').startOf('day');
    const nextWeek = moment(istDate).add(7, 'days').startOf('day');

    const todayStr = today.format('YYYY-MM-DD');

    console.log(`🔍 Scanning for Personal Reminders (Filter: ${categoryFilter || 'ALL'})...`);

    // 1. VACCINES 💉
    if (!categoryFilter || categoryFilter === 'vaccine') {
        console.log("💉 Checking Vaccines...");
        try {
            const vSnap = await db.collection('vaccines').where('isDone', '==', false).get();
            let vCount = 0;

            for (const doc of vSnap.docs) {
                const data = doc.data();
                if (!data.scheduledDate) continue;

                const sDate = moment(data.scheduledDate).startOf('day');
                let trigger = null;

                if (sDate.isSame(today)) trigger = "Today";
                else if (sDate.isSame(tomorrow)) trigger = "Tomorrow";
                else if (sDate.isSame(nextWeek)) trigger = "In 1 Week";

                if (trigger) {
                    const lockId = `${data.childId}_vaccine_${todayStr}`;
                    const lockRef = db.collection('scheduled_tasks').doc(lockId);
                    const lockDoc = await lockRef.get();

                    if (lockDoc.exists) continue;

                    if (data.remindersSent && data.remindersSent.includes(todayStr)) continue;

                    const childDoc = await db.collection('children').doc(data.childId).get();
                    if (childDoc.exists) {
                        const childData = childDoc.data();
                        const parentId = childData.parentId;
                        const childName = childData.name || "Kiddo";

                        if (parentId) {
                            try {
                                await oneSignal.sendNotification({
                                    include_external_user_ids: [parentId],
                                    headings: { "en": "Vaccine Reminder 💉" },
                                    contents: { "en": `Hey ${childName}, it is time to get your ${data.vaccineName} vaccine! 💉` },
                                    buttons: [
                                        { "id": "done", "text": "Mark Done ✓" },
                                        { "id": "reschedule", "text": "Reschedule 📅" }
                                    ],
                                    delayed_option: "timezone",
                                    delivery_time_of_day: formatTimeForOneSignal("8:05 AM"),
                                    data: {
                                        task: 'vaccine',
                                        docId: doc.id,
                                        childId: data.childId,
                                        parentId: parentId,
                                        vaccineName: data.vaccineName
                                    }
                                });

                                await db.collection('vaccines').doc(doc.id).update({
                                    remindersSent: admin.firestore.FieldValue.arrayUnion(todayStr)
                                });
                                await lockRef.set({
                                    sentAt: admin.firestore.FieldValue.serverTimestamp(),
                                    childId: data.childId,
                                    parentId: parentId,
                                    type: 'vaccine'
                                });
                                vCount++;
                            } catch (e) {
                                console.error(`❌ Failed to send vaccine reminder for ${childName}:`, e.message);
                            }
                        }
                    }
                }
            }
            console.log(`✅ Sent ${vCount} Vaccine reminders.`);
        } catch (e) {
            console.error("❌ Error processing vaccines:", e);
        }
    }

    // 2. DENTAL 🦷
    if (!categoryFilter || categoryFilter === 'dental') {
        console.log("🦷 Checking Dental Appointments...");
        try {
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
                    const lockId = `${data.childId}_dental_${todayStr}`;
                    const lockRef = db.collection('scheduled_tasks').doc(lockId);
                    const lockDoc = await lockRef.get();

                    if (lockDoc.exists) continue;

                    if (data.remindersSent && data.remindersSent.includes(todayStr)) continue;

                    const childDoc = await db.collection('children').doc(data.childId).get();
                    if (childDoc.exists) {
                        const childData = childDoc.data();
                        const parentId = childData.parentId;
                        const childName = childData.name || "Kiddo";

                        if (parentId) {
                            try {
                                await oneSignal.sendNotification({
                                    include_external_user_ids: [parentId],
                                    headings: { "en": "Dental Appointment 🦷" },
                                    contents: { "en": `Hey ${childName}, it is time for your appointment with ${data.doctorName}. 🦷` },
                                    buttons: [
                                        { "id": "done", "text": "Mark Done ✓" },
                                        { "id": "reschedule", "text": "Reschedule 📅" }
                                    ],
                                    delayed_option: "timezone",
                                    delivery_time_of_day: formatTimeForOneSignal("8:10 AM"),
                                    data: {
                                        task: 'dental',
                                        docId: doc.id,
                                        parentId: parentId,
                                        childId: data.childId
                                    }
                                });

                                await db.collection('dental_appointments').doc(doc.id).update({
                                    remindersSent: admin.firestore.FieldValue.arrayUnion(todayStr)
                                });
                                await lockRef.set({
                                    sentAt: admin.firestore.FieldValue.serverTimestamp(),
                                    childId: data.childId,
                                    parentId: parentId,
                                    type: 'dental'
                                });
                                dCount++;
                            } catch (e) {
                                console.error(`❌ Failed to send dental reminder for ${childName}:`, e.message);
                            }
                        }
                    }
                }
            }
            console.log(`✅ Sent ${dCount} Dental reminders.`);
        } catch (e) {
            console.error("❌ Error processing dental appointments:", e);
        }
    }
}

module.exports = { run };
