# GrinGuide Cloud Functions 🚀

This folder contains the automated notification system for GrinGuide, migrated to Firebase Cloud Functions for seamless integration and reliability.

## 📋 Prerequisites
1.  **Firebase CLI**: Install it via `npm install -g firebase-tools`.
2.  **Blaze Plan**: Your Firebase project **must** be on the "Blaze" (Pay-as-you-go) plan. 
    *   *Why?* Firebase requires Blaze to make requests to external APIs like OneSignal.
    *   *Cost:* The free tier within the Blaze plan is very generous (first 2 million invocations per month are free).

## 🚀 Deployment Instructions

### 1. Set Environment Variables
Run these commands in your terminal to securely set your OneSignal keys:

```bash
firebase functions:secrets:set ONESIGNAL_REST_KEY
# Enter your OneSignal REST API Key when prompted

firebase functions:secrets:set ONESIGNAL_APP_ID
# Enter your OneSignal App ID when prompted
```

### 2. Install Dependencies
Run this inside the `functions` folder:
```bash
npm install
```

### 3. Deploy
Run from the root of your project:
```bash
firebase deploy --only functions
```

## ⏰ Scheduled Tasks
Once deployed, the following functions will run automatically:
- `morningHabits`: Daily at 7:00 AM.
- `dailyFood`: Daily at 8:00 AM.
- `vaccineReminders`: Daily at 8:05 AM (Week / Day before / Same Day).
- `dentalReminders`: Daily at 8:10 AM (Week / Day before / Same Day).
- `weeklyReport`: Sundays at 10:00 AM.
- `nightHabits`: Daily at 9:00 PM.

## 🛠️ Maintenance
- You can view logs in the **Firebase Console > Functions > Logs**.
- You can manually trigger a function for testing via the **Firebase Dashboard**.
