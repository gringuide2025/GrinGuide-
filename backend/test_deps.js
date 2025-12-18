try {
    console.log("Testing minimist...");
    require('minimist');
    console.log("✅ minimist OK");

    console.log("Testing axios...");
    require('axios');
    console.log("✅ axios OK");

    console.log("Testing firebase-admin...");
    require('firebase-admin');
    console.log("✅ firebase-admin OK");

    console.log("Testing config (path resolution)...");
    require('./config');
    console.log("✅ config OK");

    console.log("Testing services/firebase...");
    require('./services/firebase');
    console.log("✅ services/firebase OK");

} catch (e) {
    console.error("❌ ERROR:", e.message);
}
