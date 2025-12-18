const admin = require('firebase-admin');
const { init } = require('./services/firebase');

async function run() {
    const app = init();
    const db = admin.firestore();

    console.log("🗑️ Deleting all vaccine records to force schedule refresh...");

    const snapshot = await db.collection('vaccines').get();
    if (snapshot.empty) {
        console.log("No vaccines to delete.");
        return;
    }

    const batch = db.batch();
    let count = 0;
    snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        count++;
    });

    await batch.commit();
    console.log(`✅ Deleted ${count} vaccine records.`);
}

run().catch(console.error);
