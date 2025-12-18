const admin = require('firebase-admin');
const oneSignal = require('../services/onesignal');
const moment = require('moment');

async function run() {
    // Only run on Sunday (0)
    const today = moment();
    if (today.day() !== 0) return;

    await oneSignal.sendNotification({
        included_segments: ["Total Subscriptions"],
        headings: { "en": "Weekly Progress Report 📊" },
        contents: { "en": "Your child's dental report is ready! Check out their progress." },
        buttons: [{ "id": "view_report", "text": "View Report" }],
        data: {
            task: 'weeklyReport',
            page: "/reports"
        }
    });
}

module.exports = { run };
