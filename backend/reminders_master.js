const personalTask = require('./tasks/personal_reminders');
const reportTask = require('./tasks/weekly_report');

async function runReminders() {
    console.log("🚀 Starting 12:30 AM Reminders (Vaccines, Dental, Weekly Report)...");
    try {
        // 1. Vaccines & Dental -> Schedules for 8:05 AM and 8:10 AM IST
        await personalTask.run();

        // 2. Weekly Report -> Schedules for 10:00 AM IST (If Sunday)
        await reportTask.run("10:00 AM");

        console.log("✅ Reminder Tasks Triggered Successfully!");
    } catch (e) {
        console.error("❌ Error in Reminder Tasks:", e);
    }
}

runReminders();
