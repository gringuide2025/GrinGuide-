const { init } = require('./services/firebase');

async function backfill() {
    const admin = init();
    const db = admin.firestore();

    const collections = ['vaccines', 'dental_appointments', 'daily_checklist'];

    console.log("🚀 Starting Backfill of parentId...");

    // Fetch all children once to create a mapping
    const childrenSnap = await db.collection('children').get();
    const childToParent = {};
    childrenSnap.forEach(doc => {
        childToParent[doc.id] = doc.data().parentId;
    });

    console.log(`✅ Loaded ${Object.keys(childToParent).length} children for mapping.`);

    for (const coll of collections) {
        console.log(`\n📦 Processing collection: ${coll}...`);
        const snap = await db.collection(coll).get();
        let count = 0;

        const batch = db.batch();
        let batchCount = 0;

        for (const doc of snap.docs) {
            const data = doc.data();
            if (data.parentId) continue; // Already has it

            const childId = data.childId;
            const parentId = childToParent[childId];

            if (parentId) {
                batch.update(doc.ref, { parentId: parentId });
                count++;
                batchCount++;

                if (batchCount >= 400) {
                    await batch.commit();
                    console.log(`  - Committed batch of ${batchCount}...`);
                    // Create new batch
                    // Note: batch is not reusable, need to re-instantiate
                }
            } else {
                console.log(`  ⚠️ No parent found for childId: ${childId} in doc: ${doc.id}`);
            }
        }

        if (batchCount > 0) {
            // Need to commit the last partial batch
            // Logic error above: batch is not re-instantiatable inside that loop easily without state.
            // Let's rewrite safely with a simpler loop for smaller datasets.
        }

        console.log(`✅ Updated ${count} documents in ${coll}.`);
    }

    process.exit(0);
}

// Safer version for backfill
async function backfillSafe() {
    const admin = init();
    const db = admin.firestore();
    const collections = ['vaccines', 'dental_appointments', 'daily_checklist'];

    console.log("🚀 Starting Safe Backfill...");

    const childrenSnap = await db.collection('children').get();
    const childToParent = {};
    childrenSnap.forEach(doc => {
        childToParent[doc.id] = doc.data().parentId;
    });

    for (const coll of collections) {
        const snap = await db.collection(coll).get();
        let updated = 0;
        console.log(`📦 Processing ${coll}...`);

        for (const doc of snap.docs) {
            const data = doc.data();
            if (data.parentId) continue;

            const parentId = childToParent[data.childId];
            if (parentId) {
                await doc.ref.update({ parentId: parentId });
                updated++;
            }
        }
        console.log(`✅ Updated ${updated} in ${coll}.`);
    }
    console.log("🏁 Backfill Complete.");
    process.exit(0);
}

backfillSafe();
