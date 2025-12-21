const { init } = require('./services/firebase');

async function checkUsersClean() {
    const admin = init();
    const db = admin.firestore();

    const usersSnap = await db.collection('users').get();

    console.log('Total Users:', usersSnap.size);
    console.log('');

    let withOneSignal = 0;
    let withoutOneSignal = 0;

    for (const userDoc of usersSnap.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const playerIds = userData.oneSignalPlayerIds || [];

        const childrenSnap = await db.collection('children')
            .where('parentId', '==', userId)
            .get();

        const childrenCount = childrenSnap.size;
        const childNames = childrenSnap.docs.map(d => d.data().name).join(', ');

        if (childrenCount > 0) {
            const status = playerIds.length > 0 ? 'YES' : 'NO';
            console.log(`User: ${userData.email || 'No email'}`);
            console.log(`  Children: ${childrenCount} (${childNames})`);
            console.log(`  OneSignal: ${status} (${playerIds.length} Player ID(s))`);
            console.log('');

            if (playerIds.length > 0) {
                withOneSignal++;
            } else {
                withoutOneSignal++;
            }
        }
    }

    console.log('=== SUMMARY ===');
    console.log(`Users with children AND OneSignal: ${withOneSignal}`);
    console.log(`Users with children but NO OneSignal: ${withoutOneSignal}`);
}

checkUsersClean().catch(console.error);
