const admin = require('firebase-admin');
const oneSignal = require('../services/onesignal');
const moment = require('moment');

// Helper for delay
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

async function run(category) {
    const db = admin.firestore();
    const today = moment().startOf('day');
    const todayStr = today.format('YYYY-MM-DD');

    // 1. Vaccines
    if (category === 'vaccine') {
        const vSnap = await db.collection('vaccines').where('isDone', '==', false).get();
        for (const doc of vSnap.docs) {
            const data = doc.data();
            if (!data.scheduledDate) continue;

            // Normalized Appointment Date
            const appointmentDate = moment(data.scheduledDate).startOf('day');

            // Calculate exact reminder trigger dates
            const reminderDates = [
                appointmentDate.clone(),                   // On the day
                appointmentDate.clone().subtract(1, 'day'), // 1 day before
                appointmentDate.clone().subtract(7, 'day')  // 1 week before
            ];

            // Check if TODAY matches any of the calculated reminder milestones
            const shouldNotify = reminderDates.some(rd => rd.isSame(today));

            if (shouldNotify) {
                if (data.remindersSent && data.remindersSent.includes(todayStr)) continue;

                const childDoc = await db.collection('children').doc(data.childId).get();
                if (childDoc.exists && childDoc.data().parentId) {
                    await oneSignal.sendNotification({
                        include_external_user_ids: [childDoc.data().parentId],
                        headings: { "en": "Vaccine Reminder 💉" },
                        contents: { "en": `Reminder for ${childDoc.data().name}'s ${data.vaccineName} vaccine!` },
                        data: { task: 'vaccine', docId: doc.id, childId: data.childId }
                    });

                    await db.collection('vaccines').doc(doc.id).update({
                        remindersSent: admin.firestore.FieldValue.arrayUnion(todayStr)
                    });

                    await sleep(1000); // 1-second delay
                }
            }
        }
    }

    // 2. Dental
    if (category === 'dental') {
        const dSnap = await db.collection('dental_appointments').where('isDone', '==', false).get();
        for (const doc of dSnap.docs) {
            const data = doc.data();
            if (!data.appointmentDate) continue;

            // Normalized Appointment Date
            const appointmentDate = moment(data.appointmentDate).startOf('day');

            // Calculate exact reminder trigger dates
            const reminderDates = [
                appointmentDate.clone(),                   // On the day
                appointmentDate.clone().subtract(1, 'day'), // 1 day before
                appointmentDate.clone().subtract(7, 'day')  // 1 week before
            ];

            // Check if TODAY matches any of the calculated reminder milestones
            const shouldNotify = reminderDates.some(rd => rd.isSame(today));

            if (shouldNotify) {
                if (data.remindersSent && data.remindersSent.includes(todayStr)) continue;

                const childDoc = await db.collection('children').doc(data.childId).get();
                if (childDoc.exists && childDoc.data().parentId) {
                    await oneSignal.sendNotification({
                        include_external_user_ids: [childDoc.data().parentId],
                        headings: { "en": "Dental Appointment 🦷" },
                        contents: { "en": `Reminder for ${childDoc.data().name}'s visit with ${data.doctorName}!` },
                        data: { task: 'dental', docId: doc.id, childId: data.childId }
                    });

                    await db.collection('dental_appointments').doc(doc.id).update({
                        remindersSent: admin.firestore.FieldValue.arrayUnion(todayStr)
                    });

                    await sleep(1000); // 1-second delay
                }
            }
        }
    }
}

module.exports = { run };
