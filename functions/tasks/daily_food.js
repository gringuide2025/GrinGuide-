const admin = require('firebase-admin');
const oneSignal = require('../services/onesignal');

// Simple food logic (cycles daily)
const healthyFoods = [
    { name: "Carrots 🥕", benefit: "Carrots are high in vitamin A for strong gums!" },
    { name: "Cheese 🧀", benefit: "Cheese helps neutralize plaque acid!" },
    { name: "Apples 🍎", benefit: "Apples act like natural toothbrushes!" },
    { name: "Milk 🥛", benefit: "Calcium in milk strengthens your tooth enamel!" },
    { name: "Broccoli 🥦", benefit: "Broccoli creates a protective film on teeth!" }
];

async function run() {
    const dayOfYear = Math.floor((new Date() - new Date(new Date().getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24);
    const food = healthyFoods[dayOfYear % healthyFoods.length];

    await oneSignal.sendNotification({
        included_segments: ["Total Subscriptions"],
        headings: { "en": "Today's Super Food: " + food.name },
        contents: { "en": food.benefit + "\nDid you eat it today?" },
        buttons: [{ "id": "done", "text": "I Ate It! 😋" }],
        data: {
            task: 'healthyFood',
            foodItem: food.name,
            page: "/dashboard"
        }
    });
}

module.exports = { run };
