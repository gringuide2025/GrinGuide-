import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialService {
  static void showDashboardTour(
    BuildContext context, {
    required GlobalKey reportKey,
    required GlobalKey storiesKey,
    required GlobalKey checklistKey,
    required GlobalKey navKey,
    required Function onFinish,
  }) {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "report_target",
        keyTarget: reportKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Weekly Reports 📊",
                "Track your child's brushing and flossing progress over the week right here!",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "stories_target",
        keyTarget: storiesKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                "GrinStories 📖",
                "Access our fun, educational dental stories to read with your child!",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "checklist_target",
        keyTarget: checklistKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Daily Habits ✅",
                "Mark off your child's morning and night dental routines here every day.",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "nav_target",
        keyTarget: navKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Navigation 🧭",
                "Switch between your Checklist, Vaccines, Dental records, and Insights easily.",
              );
            },
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () => onFinish(),
      onClickTarget: (target) {
        debugPrint('onClickTarget: $target');
      },
      onClickOverlay: (target) {
        debugPrint('onClickOverlay: $target');
      },
      onSkip: () {
        onFinish();
      },
    ).show(context: context);
  }

  static Widget _buildTutorialContent(String title, String description) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Divider(color: Colors.white),
        ),
        Text(
          description,
          style: const TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ],
    );
  }
}
