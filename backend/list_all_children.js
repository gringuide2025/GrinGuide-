const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
}

const db = admin.firestore();

async function listAllChildren() {
    console.log(`Listing all children in the database:`);
    const childrenSnapshot = await db.collection('children').get();

    if (childrenSnapshot.empty) {
        console.log("No children found.");
        return;
    }

    console.log(`Found ${childrenSnapshot.size} total children:`);
    childrenSnapshot.forEach(doc => {
        const data = doc.data();
        console.log(`Child: ${data.name}, Gender: ${data.gender}, ParentId: ${data.parentId}`);
    });

    console.log("\nListing Parent UIDs:");
    const parentsSnapshot = await db.collection('parents').get();
    parentsSnapshot.forEach(doc => {
        const data = doc.data();
        console.log(`Parent: ${data.fatherName || 'No Name'}, Email: ${data.email || 'No Email'}, UID: ${doc.id}`);
    });
}

listAllChildren();
