const foodTask = require('./tasks/daily_food');
const personalTask = require('./tasks/personal_reminders');

async function runFoodAndReminders() {
    console.log("🚀 Starting 12:30 AM Food & Reminders Schedule...");
    try {
        // 1. Healthy Food -> 8:00 AM
        await foodTask.run("8:00 AM");

        // 2. Vaccines & Dental -> 8:05 AM & 8:10 AM
        await personalTask.run();

        console.log("✅ 12:30 AM Food & Reminder Tasks Scheduled Successfully!");
    } catch (e) {
        console.error("❌ Error in Food/Reminders Schedule (12:30 AM):", e);
    }
}

runFoodAndReminders();
