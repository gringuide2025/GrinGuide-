import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "GrinGuide Terms & Conditions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              """
GrinGuide – Terms & Conditions

Last updated: December 18, 2025

Please read these Terms & Conditions ("Terms") carefully before using the GrinGuide mobile application (the "App"). By downloading or using the App, you agree to be bound by these Terms.

1. General Usage
GrinGuide is a personal health companion designed to help track oral hygiene and development.
- **Eligibility:** You must be at least 13 years old to manage your own account. Parents/Gardians must manage accounts for children.
- **License:** We grant you a limited, non-exclusive, non-transferable license to use the App for personal, non-commercial purposes.

2. Medical Disclaimer (Crucial)
**The App and its Chatbot do NOT provide medical advice.**
- **Information Only:** All content (including text, graphics, images, and Chatbot responses) is for informational purposes only.
- **No Doctor-Patient Relationship:** Use of this App does not establish a doctor-patient relationship.
- **Consult Professionals:** Always seek the advice of your dentist or physician with any questions regarding a medical condition. Never disregard professional medical advice because of something you have read on this App.

3. User Accounts & Security
- **Account Creation:** You may need to sign in using a Google Account.
- **Responsibility:** You are responsible for maintaining the confidentiality of your login credentials. You accept responsibility for all activities that occur under your account.
- **Data Accuracy:** You agree to provide accurate and current information (e.g., date of birth) to ensure App features work correctly.

4. Chatbot & Third-Party Services
- **Automated Chatbot:** The chatbot retrieves information from a pre-defined database based on keywords. It does not "think" or provide custom medical analysis.
- **Firebase:** We use Firebase for backend services. By using the App, you acknowledge that data processing occurs on Google's cloud infrastructure.

5. User Conduct
You agree NOT to:
- Use the App for any illegal purpose.
- Attempt to reverse-engineer, decompile, or disassemble the App.
- Harass, threaten, or infringe strictly upon the rights of others.
- Upload viruses or malicious code.

6. Intellectual Property
- **App Content:** All rights, title, and interest in the App (excluding user-generated content) belong to GrinGuide.
- **User Content:** You retain ownership of your profile photos. By uploading, you grant us a license to store and display them solely for your use within the App.

7. Termination
We reserve the right to suspend or terminate your access to the App immediately, without prior notice, for any violation of these Terms or for any other reason.

8. Limitation of Liability
To the maximum extent permitted by law, GrinGuide and its developers shall NOT be liable for any indirect, incidental, or consequential damages arising from your use of the App, including but not limited to loss of data, service interruptions, or medical outcomes.

9. Changes to Terms
We reserve the right to modify these Terms at any time. Updates will be posted within the App. Continued use constitutes acceptance of the new Terms.

10. Contact Us
For any questions regarding these Terms:
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
