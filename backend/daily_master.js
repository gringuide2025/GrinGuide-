const habitsTask = require('./tasks/daily_habits');
const foodTask = require('./tasks/daily_food');
const personalTask = require('./tasks/personal_reminders'); // Vaccines & Dental
const reportTask = require('./tasks/weekly_report');

async function runAll() {
    console.log("🚀 Starting Daily Master Schedule...");

    try {
        // 1. Morning Brush & Floss -> 7:00 AM
        await habitsTask.run('morning_routine', "7:00 AM");

        // 2. Healthy Food -> 8:00 AM
        await foodTask.run("8:00 AM");

        // 3. Vaccines -> 8:05 AM (And Dental -> 8:10 AM)
        // Note: personalTask now creates scheduled notifications inside itself
        // It uses hardcoded 8:05 AM and 8:10 AM as requested in previous step.
        await personalTask.run();

        // 4. Weekly Report -> 10:00 AM (Sundays only)
        await reportTask.run("10:00 AM");

        // 5. Night Brush & Floss -> 9:00 PM
        await habitsTask.run('night_routine', "9:00 PM");

        console.log("✅ All Daily Tasks Scheduled Successfully!");
    } catch (e) {
        console.error("❌ Error in Daily Master Schedule:", e);
    }
}

runAll();
