# Backend Notification Setup 🥗

This folder contains a standalone script to send "Daily Healthy Food" notifications via OneSignal.

## 1. Prerequisites
- **Node.js** installed on your system (or server).
- Your **OneSignal REST API Key** (Found in OneSignal Dashboard > Settings > Keys & IDs).

## 2. Files
- `foods.json`: A list of healthy foods that cycles daily.
- `daily_push.js`: The logic to pick a food and call OneSignal API.

## 3. How to Run (Testing)
Run this command in your terminal (replace `YOUR_KEY` with the real key):

**Windows (PowerShell):**
```powershell
$env:ONESIGNAL_REST_KEY="your_rest_api_key_here"; node backend/daily_push.js
```

**CMD:**
```cmd
set ONESIGNAL_REST_KEY=your_rest_api_key_here && node backend/daily_push.js
```

## 4. How to Automate (Production)
To make this run every day automatically:

### Option B: Heroku + Heroku Scheduler (Recommended for Cloud)
1.  **Deploy**: Create a new Heroku app and push the `backend` folder.
2.  **Add-on**: Add the "Heroku Scheduler" (Free).
3.  **Command**: Set a daily job with the following command:
    ```bash
    npm run master
    ```
4.  **Timing**: Set it to run once per day (e.g., 1:00 AM UTC). This script will "queue" all notifications for the next 24 hours based on your users' timezones.

### Option C: GitHub Actions (Completely Free)
1.  Push this code to GitHub.
2.  Add `ONESIGNAL_REST_KEY`, `ONESIGNAL_APP_ID`, and your Firebase `serviceAccountKey.json` contents to GitHub Secrets.
3.  Use the `.github/workflows/daily_master.yml` script to run `npm run master` daily.
