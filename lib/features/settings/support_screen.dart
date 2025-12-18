import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'gringuide2025@gmail.com',
      query: 'subject=GrinGuide Support Request',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text("How can we help you?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: const Text("Email Support"),
            subtitle: const Text("gringuide2025@gmail.com"),
            onTap: _sendEmail,
          ),
          const Divider(),
          const ExpansionTile(
            title: Text("FAQ: How do I track brushing?"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Go to the Dashboard and tap the current day's checklist items (Brush Morning/Night)."),
              )
            ],
          ),
          const ExpansionTile(
            title: Text("FAQ: How does the timer work?"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Tap 'Timer' on the dashboard. Follow the visual guide for 2 minutes of brushing."),
              )
            ],
          ),
          const ExpansionTile(
            title: Text("FAQ: Is my data safe?"),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Yes, we use Firebase authentication and secure cloud storage to protect your family's data."),
              )
            ],
          ),
        ],
      ),
    );
  }
}
