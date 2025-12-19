const { init } = require('./services/firebase');

async function testFetch() {
    const admin = init();
    const db = admin.firestore();
    const userId = 'RaMKCOnYtPVnUbiwVQ41BDmrcK32';

    console.log(`🔍 Checking children for UID: ${userId}`);
    const snap = await db.collection('children').where('parentId', '==', userId).get();

    if (snap.empty) {
        console.log("❌ No children found for this UID.");
    } else {
        console.log(`✅ Found ${snap.docs.length} children.`);
        snap.docs.forEach(doc => {
            console.log(` - ${doc.data().name} (${doc.id})`);
        });
    }

    console.log(`\n🔍 Checking User Document...`);
    const userDoc = await db.collection('users').doc(userId).get();
    if (userDoc.exists) {
        console.log("✅ User document exists.");
        console.log("Data:", userDoc.data());
    } else {
        console.log("❌ User document NOT found.");
    }

    process.exit(0);
}

testFetch();
