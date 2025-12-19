const { init } = require('./services/firebase');

async function cleanData() {
    const admin = init();
    const db = admin.firestore();

    const strayId = 'nQVqqmGSZJzk93xLDvW7c96-56186b7718bf';
    console.log(`🧹 Attempting to delete stray dental appointment: ${strayId}`);

    try {
        await db.collection('dental_appointments').doc(strayId).delete();
        console.log("✅ Deleted successfully.");
    } catch (e) {
        console.error("❌ Failed to delete:", e.message);
    }

    process.exit(0);
}

cleanData();
