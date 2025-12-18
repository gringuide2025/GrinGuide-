const admin = require('firebase-admin');
const { init } = require('./services/firebase');
const moment = require('moment');

async function run() {
    const app = init();
    const db = admin.firestore();

    console.log("🔍 Inspecting Dental Appointments...");

    const snap = await db.collection('dental_appointments').get();
    if (snap.empty) {
        console.log("No dental appointments found.");
        return;
    }

    snap.docs.forEach(doc => {
        const data = doc.data();
        console.log(JSON.stringify({
            id: doc.id,
            childId: data.childId,
            date: data.appointmentDate,
            doctor: data.doctorName,
            isDone: data.isDone
        }, null, 2));
    });
}

run().catch(console.error);
