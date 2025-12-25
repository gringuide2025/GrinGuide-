const minimist = require('minimist');
const args = minimist(process.argv.slice(2));

// Load Tasks
const habitsTask = require('./tasks/daily_habits');
const foodTask = require('./tasks/daily_food');
const personalTask = require('./tasks/personal_reminders');
const reportTask = require('./tasks/weekly_report');

async function run() {
    const taskName = args.task;
    const targetUid = args.target_uid;

    console.log(`🚀 Starting Scheduler Task: ${taskName || 'NONE'}${targetUid ? ' (Targeting: ' + targetUid + ')' : ''}`);

    try {
        switch (taskName) {
            case 'habits':
                // Usage: node scheduler.js --task=habits --type=morning_routine --time="7:00 AM"
                await habitsTask.run(args.type, args.time, targetUid, args.force === 'true' || args.force === true);
                break;

            case 'food':
                // Usage: node scheduler.js --task=food --time="8:00 AM"
                await foodTask.run(args.time);
                break;

            case 'personal':
                // Usage: node scheduler.js --task=personal --category=vaccine
                await personalTask.run(args.category);
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
