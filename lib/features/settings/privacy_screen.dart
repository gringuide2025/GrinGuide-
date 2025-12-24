import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              """
GrinGuide – Privacy Policy

Last updated: December 24, 2025

GrinGuide ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application (the "App"). Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.

1. Information We Collect

We utilize Firebase (Google) services to provide a secure and robust experience. We collect the following types of information:

a) Personal Data (User-Provided)
When you register or use features of the App, we may process:
- Identity Data: Name, Email address.
- Health & Profile Data: Date of birth (for age-appropriate content), child name, brushing/flossing habits, dental appointment dates, and vaccination records.
- Story Interaction: Participation in educational stories (GrinStories) and progress tracking.
- Chat Data: Text queries you send to the Chatbot.

⚠️ We do NOT collect Government IDs, Financial Information, or Sensitive biometric data.

b) Device & Usage Information
- Device ID, Model, Operating System version.
- App usage interaction (features used, screens visited).
- Push Notification Tokens: To send you reminders via OneSignal.

c) Permissions Requested
- Camera & Storage: To allow you to upload relevant health documents or screenshots of dental charts if needed.
- Location: To help you find nearby dentists or doctors using Google Maps.
- Notification Access: To send scheduled reminders for oral hygiene habits and appointments.

2. How We Use Your Information

We use the collected data for the following purposes:
- Account Management: To create and manage your account via Firebase Authentication.
- Core Functionality: To store your habits, appointments, and progress securely using Cloud Firestore.
- Chatbot Services: To provide instant answers using an internal database of dental topics. (Queries are processed locally on your device).
- Notifications: To send timely reminders for brushing, flossing, and appointments via OneSignal.
- Educational Content: To provide illustrated stories and dental health education via GrinStories.
- Reports: To generate healthy habit reports for your viewing.

3. Third-Party Services & Data Sharing

We may share information with the following third-party service providers solely to facilitate our App's services:
- Firebase (Google): For authentication, database, analytics, and crash reporting.
- OneSignal: For delivering push notifications.

We do NOT sell, lease, or rent your personal data to advertisers or third parties.

4. Data Retention & Security
- Retention: We retain your personal data stored in Firebase only for as long as your account is active or moves through the necessary backup cycles.
- Security: We use industry-standard encryption (HTTPS/TLS) and secure firebase security rules to protect your data. However, no method of transmission over the internet is 100% secure.

5. Chatbot Disclaimer

The "Dental Assistant" chat feature is a Rule-Based System using verifiable dental information.
- Not Medical Advice: Responses are pre-programmed based on keywords. They are for education only.
- Privacy: Do not share sensitive personal information (PII) or specific health records in the chat.

6. Children's Privacy

While GrinGuide promotes children's oral health, it is intended to be managed by parents or guardians. We do not knowingly collect personal data directly from children under 13 without parental consent.

7. Your Rights & Data Deletion

You have the right to:
- Access the data we hold about you.
- Update specific information within the app settings.
- Delete Your Account: You can request account deletion directly within the App settings. This will remove your personal data from our database.

8. Contact Us

If you have questions about this Privacy Policy, please contact us:
📧 Email: gringuide2025@gmail.com
              """,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
