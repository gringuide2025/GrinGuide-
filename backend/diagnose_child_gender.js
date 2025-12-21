const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
}

const db = admin.firestore();

async function diagnoseUser(email) {
    console.log(`Diagnosing user: ${email}`);
    const userSnapshot = await db.collection('parents').where('email', '==', email).get();

    if (userSnapshot.empty) {
        console.log("No parent found with this email.");
        return;
    }

    const parent = userSnapshot.docs[0].data();
    console.log("Parent Data:", parent);

    const childrenSnapshot = await db.collection('children').where('parentId', '==', parent.uid).get();
    console.log(`Found ${childrenSnapshot.size} children:`);
    childrenSnapshot.forEach(doc => {
        console.log("- ", doc.data());
    });
}

// Replace with user's email if needed, or leave to catch recent
diagnoseUser('harishkanna04@gmail.com'); 
