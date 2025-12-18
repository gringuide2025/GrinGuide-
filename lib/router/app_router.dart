import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/parent_edit_screen.dart';
import '../features/profile/child_edit_screen.dart';
import '../features/profile/models/child_model.dart';
import '../features/dashboard/vaccine_screen.dart';
import '../features/dashboard/dental_screen.dart';
import '../features/dashboard/insights_screen.dart';
import '../features/dashboard/insight_detail_screen.dart';

import '../features/reports/weekly_reports_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/widgets/main_layout.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/timer/timer_screen.dart';
import '../features/chatbot/chatbot_screen.dart';
import '../features/settings/terms_screen.dart';
import '../features/settings/privacy_screen.dart';
import '../features/settings/support_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    // Authenticated Routes with Drawer
    ShellRoute(
      builder: (context, state, child) {
        // Determine title based on current path
        String title = 'GrinGuide';
        final location = state.uri.toString();
        if (location.contains('dashboard')) title = 'Dashboard';
        if (location.contains('profile')) title = 'Profile';
        if (location.contains('reports')) title = 'Weekly Reports';
        if (location.contains('settings')) title = 'Settings';
        
        return MainLayout(title: title, child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
          routes: [
             GoRoute(
              path: 'vaccines',
              builder: (context, state) {
                final child = state.extra as ChildModel;
                return VaccineScreen(child: child);
              },
            ),
             GoRoute(
              path: 'dental',
              builder: (context, state) {
                final child = state.extra as ChildModel;
                return DentalScreen(child: child);
              },
            ),
             GoRoute(
              path: 'insights',
              builder: (context, state) => InsightsScreen(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, String>;
                    // extra now contains 'title' and 'contentId'
                    return InsightDetailScreen(title: extra['title']!, contentId: extra['contentId']!);
                  },
                ),
              ]
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit-parent',
              builder: (context, state) => const ParentEditScreen(),
            ),
             GoRoute(
              path: 'add-child',
              builder: (context, state) => const ChildEditScreen(),
            ),
             GoRoute(
              path: 'edit-child',
               builder: (context, state) {
                final child = state.extra as ChildModel?; // Pass child object for editing
                return ChildEditScreen(child: child);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const WeeklyReportsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'terms',
              builder: (context, state) => const TermsScreen(),
            ),
             GoRoute(
              path: 'privacy',
              builder: (context, state) => const PrivacyScreen(),
            ),
             GoRoute(
              path: 'support',
              builder: (context, state) => const SupportScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/timer',
          builder: (context, state) => const TimerScreen(),
        ),
        GoRoute(
          path: '/chatbot',
          builder: (context, state) => const ChatbotScreen(),
        ),
      ],
    ),
  ],
);
