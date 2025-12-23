const admin = require('firebase-admin');
const config = require('./config');

if (!admin.apps.length) {
    try {
        let credential;
        if (config.firebase.privateKey) {
            console.log("Using ENV credentials");
            credential = admin.credential.cert({
                projectId: config.firebase.projectId,
                clientEmail: config.firebase.clientEmail,
                privateKey: config.firebase.privateKey
            });
        } else {
            console.log("Using Local credentials");
            credential = admin.credential.cert(require(config.firebase.credentialPath));
        }

        admin.initializeApp({
            credential: credential,
        });
    } catch (error) {
        console.error('Firebase Init Error:', error.message);
        process.exit(1);
    }
}

const db = admin.firestore();

async function checkLogs() {
    console.log('🔍 Checking recent scheduled tasks in Firestore...');

    try {
        const snapshot = await db.collection('scheduled_tasks')
            .orderBy('sentAt', 'desc')
            .limit(10)
            .get();

        if (snapshot.empty) {
            console.log('❌ No logs found.');
            return;
        }

        snapshot.forEach(doc => {
            const data = doc.data();
            const date = data.sentAt ? data.sentAt.toDate().toLocaleString() : 'Unknown Date';
            console.log(`\n------------------------------------------------`);
            console.log(`📅 Date: ${date}`);
            // doc.id is usually childId_type_date
            console.log(`🔑 ID: ${doc.id}`);
            console.log(`📝 Type: ${data.type}`);
            console.log(`🆔 Child: ${data.childId}`);
        });
        console.log(`\n------------------------------------------------`);

    } catch (error) {
        console.error('Error fetching logs:', error);
    }
}

checkLogs();
