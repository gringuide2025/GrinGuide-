const foodTask = require('./tasks/daily_food');

async function runFood() {
    console.log("🚀 Starting 12:30 AM Food Notification Task...");
    try {
        // Healthy Food -> 8:00 AM
        // The task itself (daily_food.js) has a build-in lock to prevent duplicate sends on the same day.
        await foodTask.run("8:00 AM");

        console.log("✅ Food Task Triggered Successfully!");
    } catch (e) {
        console.error("❌ Error in Food Task:", e);
    }
}

runFood();
