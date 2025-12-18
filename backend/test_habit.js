const runner = require('./tasks/daily_habits');

console.log("🧪 Testing Morning Routine Personalization...");
runner.run('morning_routine').then(() => {
    setTimeout(() => process.exit(0), 2000);
});
