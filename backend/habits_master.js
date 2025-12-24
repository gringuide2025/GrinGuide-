const habitsTask = require('./tasks/daily_habits');

async function runHabits() {
    console.log("🚀 Starting 11:30 PM Habit Schedule (Brush/Floss)...");
    try {
        // 1. Morning Brush & Floss -> 7:00 AM
        await habitsTask.run('morning_routine', "7:00 AM");

        // 2. Night Brush & Floss -> 9:00 PM
        await habitsTask.run('night_routine', "9:00 PM");

        console.log("✅ Habit Tasks Scheduled Successfully!");
    } catch (e) {
        console.error("❌ Error in Habit Schedule:", e);
    }
}

runHabits();
