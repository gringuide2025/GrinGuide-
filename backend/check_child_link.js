const { init } = require('./services/firebase');
const admin = init();
const db = admin.firestore();

async function check() {
    console.log("🔍 Checking Children for Parent Links...");
    const snap = await db.collection('children').get();

    if (snap.empty) {
        console.log("❌ No children found in database.");
        return;
    }

    snap.docs.forEach(doc => {
        const data = doc.data();
        console.log(`👶 Child: ${data.name || 'Unnamed'} (ID: ${doc.id})`);
        console.log(`   ➡ Parent ID: ${data.parentId ? data.parentId : '❌ MISSING'}`);
        console.log(`   ➡ DOB: ${data.dob ? data.dob : '❌ MISSING'}`);
    });
}

check();
