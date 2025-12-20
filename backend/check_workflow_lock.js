const { init } = require('./services/firebase');
const minimist = require('minimist');
const args = minimist(process.argv.slice(2));

async function checkLock() {
    const admin = init();
    const db = admin.firestore();

    const taskType = args.task || 'daily_scheduler';
    const todayStr = new Date().toISOString().split('T')[0];
    const lockId = `workflow_lock_${taskType}_${todayStr}`;
    const lockRef = db.collection('workflow_execution_locks').doc(lockId);

    try {
        const lockDoc = await lockRef.get();

        if (lockDoc.exists) {
            const lastRun = lockDoc.data().lastRun.toDate();
            const minutesSinceLastRun = (Date.now() - lastRun.getTime()) / (1000 * 60);

            if (minutesSinceLastRun < 30) {
                console.error(`❌ Workflow ran ${minutesSinceLastRun.toFixed(1)} minutes ago.`);
                console.error(`   Preventing duplicate execution.`);
                console.error(`   Last run: ${lastRun.toISOString()}`);
                process.exit(1);
            }

            console.log(`✓ Lock check passed (last run: ${minutesSinceLastRun.toFixed(1)} min ago)`);
        }

        // Create/update lock
        await lockRef.set({
            lastRun: admin.firestore.FieldValue.serverTimestamp(),
            taskType: taskType,
            source: 'github_actions',
            timestamp: new Date().toISOString()
        });

        console.log('✅ Lock acquired successfully');
        process.exit(0);

    } catch (e) {
        console.error('❌ Lock check failed:', e.message);
        process.exit(1);
    }
}

checkLock();
