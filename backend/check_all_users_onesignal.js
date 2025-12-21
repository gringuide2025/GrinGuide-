const { init } = require('./services/firebase');

async function checkAllUsers() {
    console.log('🔍 Checking OneSignal registration for ALL users...\n');

    const admin = init();
    const db = admin.firestore();

    // Get all users
    const usersSnap = await db.collection('users').get();
    console.log(`Found ${usersSnap.size} users in database\n`);

    const results = {
        registered: [],
        notRegistered: [],
        noChildren: []
    };

    for (const userDoc of usersSnap.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const email = userData.email || 'No email';
        const playerIds = userData.oneSignalPlayerIds || [];

        // Check children count
        const childrenSnap = await db.collection('children')
            .where('parentId', '==', userId)
            .get();

        const childrenCount = childrenSnap.size;
        const childNames = childrenSnap.docs.map(d => d.data().name || 'Unnamed').join(', ');

        const userInfo = {
            userId,
            email,
            playerIds,
            childrenCount,
            childNames
        };

        if (childrenCount === 0) {
            results.noChildren.push(userInfo);
        } else if (playerIds && playerIds.length > 0) {
            results.registered.push(userInfo);
        } else {
            results.notRegistered.push(userInfo);
        }
    }

    // Print Results
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ USERS WITH ONESIGNAL REGISTERED:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (results.registered.length === 0) {
        console.log('   ❌ NONE! No users have OneSignal registered!\n');
    } else {
        results.registered.forEach(user => {
            console.log(`📱 User: ${user.email}`);
            console.log(`   UID: ${user.userId}`);
            console.log(`   Children: ${user.childrenCount} (${user.childNames})`);
            console.log(`   Player IDs: ${user.playerIds.join(', ')}`);
            console.log('');
        });
    }

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('❌ USERS WITHOUT ONESIGNAL (WILL NOT RECEIVE NOTIFICATIONS):');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (results.notRegistered.length === 0) {
        console.log('   ✅ All users with children are registered!\n');
    } else {
        results.notRegistered.forEach(user => {
            console.log(`⚠️  User: ${user.email}`);
            console.log(`   UID: ${user.userId}`);
            console.log(`   Children: ${user.childrenCount} (${user.childNames})`);
            console.log(`   ❌ NO PLAYER ID - Notifications will FAIL!`);
            console.log('');
        });
    }

    if (results.noChildren.length > 0) {
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('ℹ️  USERS WITH NO CHILDREN:');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        results.noChildren.forEach(user => {
            console.log(`   User: ${user.email} (UID: ${user.userId})`);
        });
        console.log('');
    }

    // Summary
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 SUMMARY:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`   Total Users: ${usersSnap.size}`);
    console.log(`   ✅ Registered with OneSignal: ${results.registered.length}`);
    console.log(`   ❌ NOT Registered (will miss notifications): ${results.notRegistered.length}`);
    console.log(`   ℹ️  Users with no children: ${results.noChildren.length}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Warning if issues found
    if (results.notRegistered.length > 0) {
        console.log('⚠️  WARNING: Some users are missing OneSignal Player IDs!');
        console.log('   These users will NOT receive any notifications.');
        console.log('   They need to:');
        console.log('   1. Log out and log back in');
        console.log('   2. Or reinstall the app');
        console.log('   3. Grant notification permissions\n');
    }
}

checkAllUsers().catch(console.error);
