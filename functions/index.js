const { onSchedule } = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

// Initialize Admin once
admin.initializeApp();

// Import Tasks (We will create these next)
const habitsTask = require('./tasks/daily_habits');
const foodTask = require('./tasks/daily_food');
const personalTask = require('./tasks/personal_reminders');
const reportTask = require('./tasks/weekly_report');

// 1. Morning Routine -> 7:00 AM (Daily)
exports.morningHabits = onSchedule("0 7 * * *", async (event) => {
    logger.info("Executing Morning Habits Schedule");
    await habitsTask.run('morning_routine');
});

// 2. Healthy Food -> 8:00 AM (Daily)
exports.dailyFood = onSchedule("0 8 * * *", async (event) => {
    logger.info("Executing Daily Food Schedule");
    await foodTask.run();
});

// 3. Vaccines -> 8:05 AM (Daily)
exports.vaccineReminders = onSchedule("5 8 * * *", async (event) => {
    logger.info("Executing Vaccine Reminders Schedule");
    await personalTask.run('vaccine');
});

// 4. Dental Appointments -> 8:10 AM (Daily)
exports.dentalReminders = onSchedule("10 8 * * *", async (event) => {
    logger.info("Executing Dental Reminders Schedule");
    await personalTask.run('dental');
});

// 5. Night Routine -> 9:00 PM (Daily)
exports.nightHabits = onSchedule("0 21 * * *", async (event) => {
    logger.info("Executing Night Habits Schedule");
    await habitsTask.run('night_routine');
});

// 6. Weekly Report -> 10:00 AM (Sundays)
exports.weeklyReport = onSchedule("0 10 * * 0", async (event) => {
    logger.info("Executing Weekly Report Schedule");
    await reportTask.run();
});
