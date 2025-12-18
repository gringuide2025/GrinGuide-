// Quick script to check if OneSignal Player ID exists for a specific user
// Run this with: node check_player_id.js

const { init } = require('./services/firebase');

async function checkPlayerIdForUser(userId) {
    console.log('🔍 Checking OneSignal Player ID for user:', userId);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    try {
        // Initialize Firebase
        const admin = init();

        if (!admin.firestore) {
            console.log('❌ Firebase Admin not initialized properly');
            console.log('   Make sure serviceAccountKey.json exists in backend folder');
            return;
        }

        const db = admin.firestore();

        // Get user document from Firestore
        const userDoc = await db.collection('users').doc(userId).get();

        if (!userDoc.exists) {
            console.log('❌ User document does NOT exist in Firestore');
            console.log('   This means the user has never logged into the app');
            console.log('   or the app has not created the user document yet.\n');
            return;
        }

        console.log('✅ User document EXISTS in Firestore\n');

        const userData = userDoc.data();

        // Check for OneSignal Player IDs
        const playerIds = userData.oneSignalPlayerIds;

        console.log('📊 User Data:');
        console.log('   Document ID:', userId);

        if (playerIds && Array.isArray(playerIds) && playerIds.length > 0) {
            console.log('   ✅ OneSignal Player IDs:', playerIds);
            console.log('   ✅ Number of Player IDs:', playerIds.length);

            if (userData.lastOneSignalUpdate) {
                const lastUpdate = userData.lastOneSignalUpdate.toDate();
                console.log('   ✅ Last Update:', lastUpdate.toLocaleString());
            }

            console.log('\n✅ SUCCESS: OneSignal Player ID is properly configured!');
            console.log('   You can now send push notifications to this user.');

        } else {
            console.log('   ❌ OneSignal Player IDs: NOT FOUND or EMPTY');
            console.log('\n❌ ISSUE: OneSignal Player ID has NOT been registered yet.');
            console.log('\n🔧 Possible Reasons:');
            console.log('   1. User has not opened the dashboard yet');
            console.log('   2. OneSignal initialization failed');
            console.log('   3. Notification permission was denied');
            console.log('   4. Network issues during registration');
            console.log('   5. App crashed before registration completed');
            console.log('\n💡 Solution:');
            console.log('   1. Open the app and login with this user');
            console.log('   2. Navigate to the Dashboard (wait 5-15 seconds)');
            console.log('   3. Go to Settings → "Check OneSignal Status"');
            console.log('   4. Run this script again to verify');
        }

        // Show relevant user data for debugging
        console.log('\n📋 Relevant User Fields:');
        const relevantData = {
            oneSignalPlayerIds: userData.oneSignalPlayerIds || null,
            lastOneSignalUpdate: userData.lastOneSignalUpdate ? userData.lastOneSignalUpdate.toDate().toISOString() : null,
            email: userData.email || null,
            createdAt: userData.createdAt ? userData.createdAt.toDate().toISOString() : null
        };
        console.log(JSON.stringify(relevantData, null, 2));

    } catch (error) {
        console.error('❌ Error checking user:', error.message);
    }

    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

// User ID to check
const USER_ID = 'RaMKCOnYtPVnUbiwVQ41BDmrcK32';

checkPlayerIdForUser(USER_ID)
    .then(() => {
        console.log('\n✅ Check complete');
        process.exit(0);
    })
    .catch(error => {
        console.error('❌ Fatal error:', error.message);
        process.exit(1);
    });
