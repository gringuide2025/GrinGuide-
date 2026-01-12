import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialService {
  static void showDashboardTour(
    BuildContext context, {
    required GlobalKey menuKey,
    required GlobalKey reportKey,
    required GlobalKey eruptionKey,
    required GlobalKey storiesKey,
    required GlobalKey bmiKey,
    required GlobalKey timerKey,
    required GlobalKey dentistKey,
    required GlobalKey chatbotKey,
    required GlobalKey checklistKey,
    required GlobalKey vaccineTabKey,
    required GlobalKey dentalTabKey,
    required GlobalKey insightsTabKey,
    required VoidCallback onFinish,
  }) {
    List<TargetFocus> targets = [
      _buildTarget("menu", menuKey, "GrinGuide 🏠", "Your home for dental health. Access everything from this dashboard.", ContentAlign.bottom),
      _buildTarget("report", reportKey, "Weekly Reports 📊", "Track brushing and flossing progress over the week.", ContentAlign.bottom),
      _buildTarget("eruption", eruptionKey, "Tools 🛠️", "Access the Eruption Chart or generate Vaccine reports depending on which tab you are on.", ContentAlign.bottom),
      _buildTarget("stories", storiesKey, "GrinStories 📖", "Enjoy educational dental stories with your child.", ContentAlign.bottom),
      _buildTarget("bmi", bmiKey, "BMI Tracker 📏", "Monitor your child's growth and health metrics.", ContentAlign.bottom),
      _buildTarget("timer", timerKey, "Brushing Timer ⏳", "Use the interactive timer to make brushing fun!", ContentAlign.bottom),
      _buildTarget("dentist", dentistKey, "Find Dentist 🦷", "Locate nearby pediatric dentists with one tap.", ContentAlign.bottom),
      _buildTarget("chatbot", chatbotKey, "Dental Chatbot 🤖", "Ask our AI assistant any dental health questions.", ContentAlign.bottom),
      _buildTarget("checklist", checklistKey, "Daily Checklist ✅", "Complete morning and night habits to keep teeth sparkling!", ContentAlign.bottom),
      _buildTarget("vaccine", vaccineTabKey, "Vaccines 💉", "Keep track of all important vaccinations here.", ContentAlign.top),
      _buildTarget("dental", dentalTabKey, "Dental Records 🏥", "Log and view dental appointments and history.", ContentAlign.top),
      _buildTarget("insights", insightsTabKey, "Parent Insights 💡", "Expert tips and localized guides for dental care.", ContentAlign.top),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.blue.shade900,
      textSkip: "SKIP ALL",
      paddingFocus: 10,
      opacityShadow: 0.85,
      hideSkip: false,
      onFinish: onFinish,
      onSkip: () {
        onFinish();
        return true;
      },
    ).show(context: context);
  }

  static TargetFocus _buildTarget(String id, GlobalKey key, String title, String desc, ContentAlign align) {
    return TargetFocus(
      identify: id,
      keyTarget: key,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return _buildTutorialContent(title, desc, controller);
          },
        ),
      ],
    );
  }

  static Widget _buildTutorialContent(String title, String description, TutorialCoachMarkController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => controller.skip(),
                child: const Text("Skip", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.next(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
