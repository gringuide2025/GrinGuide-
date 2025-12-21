const { init } = require('./services/firebase');
const fs = require('fs');

async function checkAllUsersSimple() {
    const admin = init();
    const db = admin.firestore();

    const usersSnap = await db.collection('users').get();
    const results = [];

    for (const userDoc of usersSnap.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const playerIds = userData.oneSignalPlayerIds || [];

        const childrenSnap = await db.collection('children')
            .where('parentId', '==', userId)
            .get();

        const children = childrenSnap.docs.map(d => ({
            id: d.id,
            name: d.data().name || 'Unnamed'
        }));

        results.push({
            userId: userId,
            email: userData.email || 'No email',
            hasOneSignal: playerIds.length > 0,
            playerIdCount: playerIds.length,
            childrenCount: children.length,
            childNames: children.map(c => c.name).join(', ') || 'None'
        });
    }

    const withOneSignal = results.filter(r => r.hasOneSignal && r.childrenCount > 0);
    const withoutOneSignal = results.filter(r => !r.hasOneSignal && r.childrenCount > 0);

    const report = {
        totalUsers: results.length,
        usersWithOneSignalAndChildren: withOneSignal.length,
        usersWithoutOneSignalButHaveChildren: withoutOneSignal.length,
        details: results
    };

    fs.writeFileSync('user_onesignal_report.json', JSON.stringify(report, null, 2));
    console.log('Report saved to user_onesignal_report.json');
}

checkAllUsersSimple().catch(console.error);
