const minimist = require('minimist');
const args = minimist(process.argv.slice(2));

// Load Tasks
const habitsTask = require('./tasks/daily_habits');
const foodTask = require('./tasks/daily_food');
const personalTask = require('./tasks/personal_reminders');

async function run() {
    const taskName = args.task;

    console.log(`🚀 Starting Scheduler Task: ${taskName || 'NONE'}`);

    try {
        switch (taskName) {
            case 'habits':
                // Usage: node scheduler.js --task=habits --type=brush_morning
                await habitsTask.run(args.type);
                break;

            case 'food':
                // Usage: node scheduler.js --task=food
                await foodTask.run();
                break;

            case 'personal':
                // Usage: node scheduler.js --task=personal
                await personalTask.run();
                break;

            case 'weekly':
                // Usage: node scheduler.js --task=weekly
                await reportTask.run();
                break;

            default:
                console.error("❌ Unknown Task. Use --task=habits|food|personal");
        }
    } catch (e) {
        console.error("❌ Scheduler Critical Error:", e);
        process.exit(1);
    }
}

run();
