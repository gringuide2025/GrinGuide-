const personalTask = require('./tasks/personal_reminders');

async function runReminders() {
    console.log("🚀 Starting 12:30 AM Personal Reminders (Vaccines & Dental)...");
    try {
        // Vaccines & Dental -> Schedules for 8:05 AM and 8:10 AM respectively.
        await personalTask.run();

        console.log("✅ Reminder Tasks Triggered Successfully!");
    } catch (e) {
        console.error("❌ Error in Reminder Tasks:", e);
    }
}

runReminders();
