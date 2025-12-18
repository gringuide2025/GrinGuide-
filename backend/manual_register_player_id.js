// Manual Player ID Registration Script
// This is a workaround while build issues are being resolved

const { init } = require('./services/firebase');

async function manuallyRegisterPlayerId() {
    console.log('🔧 Manual Player ID Registration');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    const USER_ID = 'RaMKCOnYtPVnUbiwVQ41BDmrcK32';

    // You'll need to get this from OneSignal dashboard or the running app
    const PLAYER_ID = process.argv[2];

    if (!PLAYER_ID) {
        console.log('❌ Error: Player ID not provided');
        console.log('\nUsage:');
        console.log('  node manual_register_player_id.js <player-id>');
        console.log('\nHow to get Player ID:');
        console.log('1. Open the app on emulator');
        console.log('2. Go to Settings → Check OneSignal Status');
        console.log('3. Copy the Subscription ID');
        console.log('4. Run: node manual_register_player_id.js <subscription-id>');
        console.log('\nOR check OneSignal Dashboard → Audience → All Users\n');
        process.exit(1);
    }

    try {
        const admin = init();

        if (!admin.firestore) {
            console.log('❌ Firebase not initialized');
            return;
        }

        const db = admin.firestore();

        console.log(`User ID: ${USER_ID}`);
        console.log(`Player ID: ${PLAYER_ID}\n`);

        // Register player ID
        await db.collection('users').doc(USER_ID).set({
            oneSignalPlayerIds: admin.firestore.FieldValue.arrayUnion(PLAYER_ID),
            lastOneSignalUpdate: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        console.log('✅ Player ID successfully registered to Firestore!');
        console.log(`   User: ${USER_ID}`);
        console.log(`   Player ID: ${PLAYER_ID}\n`);

        // Verify
        const userDoc = await db.collection('users').doc(USER_ID).get();
        const userData = userDoc.data();

        console.log('📊 Verification:');
        console.log('   oneSignalPlayerIds:', userData.oneSignalPlayerIds);
        console.log('   lastOneSignalUpdate:', userData.lastOneSignalUpdate?.toDate().toLocaleString());

        console.log('\n✅ Done! You can now send push notifications to this user.');

    } catch (error) {
        console.error('❌ Error:', error.message);
    }

    process.exit(0);
}

manuallyRegisterPlayerId();
