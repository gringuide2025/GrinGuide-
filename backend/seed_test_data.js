const { init } = require('./services/firebase');
const moment = require('moment');

async function seed() {
    const admin = init();
    const db = admin.firestore();

    console.log("🌱 Seeding Test Data...");

    // 1. Get ALL Children
    const kidsSnap = await db.collection('children').get();
    if (kidsSnap.empty) {
        console.error("❌ No children found in DB. Cannot seed.");
        process.exit(1);
    }

    console.log(`Found ${kidsSnap.size} children. Creating appointments for all...`);

    const today = moment().format('YYYY-MM-DD');

    for (const child of kidsSnap.docs) {
        const childId = child.id;
        const childData = child.data();
        console.log(`👉 Processing Child: ${childData.name} (${childId})`);

        // 3. Create Dummy Dental Appointment
        const denRef = await db.collection('dental_appointments').add({
            childId: childId,
            doctorName: "Dr. Tooth Fairy 🧚",
            appointmentDate: today,
            isDone: false,
            notes: "Multi-child Test"
        });
        console.log(`   ✅ Created Dental Appt: ${denRef.id}`);
    }

    console.log("🚀 Run 'node scheduler.js --task=personal' to test now.");
}

seed().then(() => {
    // wait a bit for firestore
    setTimeout(() => process.exit(0), 2000);
});
