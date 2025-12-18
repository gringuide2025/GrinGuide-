const axios = require('axios');

const PLAYER_ID = "92e3e399-ada9-4046-9b9d-2ecafdf1640d";
const APP_ID = "48d29f47-c4fa-4e66-86fc-304ffbeff598"; // Correct UUID format
const REST_KEY = process.env.ONESIGNAL_REST_KEY;

if (!REST_KEY) {
    console.error("❌ ONESIGNAL_REST_KEY not set");
    process.exit(1);
}

async function sendTestNotification() {
    const payload = {
        app_id: APP_ID,
        include_player_ids: [PLAYER_ID],
        headings: { "en": "Test: Morning Routine ☀️" },
        contents: { "en": "Time to brush & floss! Keep those teeth sparkling! 🦷✨" },
        buttons: [
            { "id": "done", "text": "Done ✓" },
            { "id": "not_done", "text": "Not Done" }
        ],
        data: {
            task: "morningRoutine",
            page: "/dashboard"
        }
    };

    try {
        const response = await axios.post(
            "https://onesignal.com/api/v1/notifications",
            payload,
            {
                headers: {
                    "Content-Type": "application/json; charset=utf-8",
                    "Authorization": `Basic ${REST_KEY}`
                }
            }
        );
        console.log("✅ Notification sent successfully!");
        console.log("Notification ID:", response.data.id);
        console.log("Recipients:", response.data.recipients);
    } catch (error) {
        console.error("❌ Failed to send notification:");
        console.error(error.response ? error.response.data : error.message);
    }
}

sendTestNotification();
