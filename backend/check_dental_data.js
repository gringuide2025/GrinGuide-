const { init } = require('./services/firebase');

async function checkDental() {
    const admin = init();
    const db = admin.firestore();

    const targetUid = 'RaMKCOnYtPVnUbiwVQ41BDmrcK32';
    console.log(`🔍 Inspecting for UID: ${targetUid}`);

    console.log("\n📦 CHECKING CHILDREN...");
    const childrenSnap = await db.collection('children').get();
    const childIds = [];
    childrenSnap.forEach(doc => {
        const data = doc.data();
        if (data.parentId === targetUid) {
            console.log(`✅ Child [${doc.id}]: Name=${data.name}, ParentId=${data.parentId}`);
            childIds.push(doc.id);
        } else {
            // console.log(`⏩ Child [${doc.id}]: ParentId=${data.parentId} (Mismatch)`);
        }
    });

    if (childIds.length === 0) {
        console.log("❌ NO CHILDREN found for this parent UID.");
    }

    console.log("\n📦 CHECKING DENTAL APPOINTMENTS...");
    const dentalSnap = await db.collection('dental_appointments').get();
    let foundCount = 0;

    dentalSnap.forEach(doc => {
        const data = doc.data();
        const isTargetChild = childIds.includes(data.childId);

        if (isTargetChild || data.parentId === targetUid) {
            foundCount++;
            console.log(`- Appointment [${doc.id}]:`);
            console.log(`  ChildId : ${data.childId} (${isTargetChild ? 'MATCH' : 'MISMATCH'})`);
            console.log(`  ParentId: ${data.parentId || 'MISSING'}`);
            console.log(`  Purpose : ${data.purpose}`);
        }
    });

    if (foundCount === 0) {
        console.log("❌ NO dental appointments found for this parent/child set.");
    } else {
        console.log(`\n✅ Total dental appointments for target user: ${foundCount}`);
    }

    process.exit(0);
}

checkDental();
