import 'package:flutter/material.dart';

class CategoryMeta {
  final String title;
  final IconData icon;
  final List<Color> gradient;

  const CategoryMeta({
    required this.title,
    required this.icon,
    required this.gradient,
  });

  static Map<String, CategoryMeta> get mapping => {
        'Pedodontics': const CategoryMeta(
          title: 'Child Dentistry',
          icon: Icons.child_care_rounded,
          gradient: [Color(0xFF64B5F6), Color(0xFF2196F3)],
        ),
        'Orthodontics': const CategoryMeta(
          title: 'Braces & Clips',
          icon: Icons.grid_view_rounded,
          gradient: [Color(0xFF81C784), Color(0xFF4CAF50)],
        ),
        'Periodontics': const CategoryMeta(
          title: 'Gum Health',
          icon: Icons.opacity_rounded,
          gradient: [Color(0xFFFF8A65), Color(0xFFF4511E)],
        ),
        'Endodontics': const CategoryMeta(
          title: 'Root Canal',
          icon: Icons.biotech_rounded,
          gradient: [Color(0xFFBA68C8), Color(0xFF9C27B0)],
        ),
        'Oral Medicine': const CategoryMeta(
          title: 'Oral Medicine',
          icon: Icons.medical_information_rounded,
          gradient: [Color(0xFF4DB6AC), Color(0xFF009688)],
        ),
        'Oral Surgery': const CategoryMeta(
          title: 'Oral Surgery',
          icon: Icons.medical_services_rounded,
          gradient: [Color(0xFFE57373), Color(0xFFC62828)],
        ),
        'Prosthodontics': const CategoryMeta(
          title: 'Tooth Replacement',
          icon: Icons.settings_suggest_rounded,
          gradient: [Color(0xFF9575CD), Color(0xFF673AB7)],
        ),
        'General': const CategoryMeta(
          title: 'General Hygiene',
          icon: Icons.auto_awesome_rounded,
          gradient: [Color(0xFFFFD54F), Color(0xFFFFB300)],
        ),
        'dental_tips': const CategoryMeta(
          title: 'Dental Tips',
          icon: Icons.tips_and_updates_rounded,
          gradient: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
        ),
        'growth_dev': const CategoryMeta(
          title: 'Growth & Dev',
          icon: Icons.trending_up_rounded,
          gradient: [Color(0xFFAED581), Color(0xFF689F38)],
        ),
        'diet_nutrition': const CategoryMeta(
          title: 'Diet & Food',
          icon: Icons.restaurant_rounded,
          gradient: [Color(0xFFFFB74D), Color(0xFFF57C00)],
        ),
        'eruption_guide': const CategoryMeta(
          title: 'Eruption Guide',
          icon: Icons.calendar_month_rounded,
          gradient: [Color(0xFFDCE775), Color(0xFFAFB42B)],
        ),
        'emergency_aid': const CategoryMeta(
          title: 'Emergency Aid',
          icon: Icons.emergency_rounded,
          gradient: [Color(0xFFFF5252), Color(0xFFFF1744)],
        ),
        'abuse_neglect': const CategoryMeta(
          title: 'Safety & Care',
          icon: Icons.health_and_safety_rounded,
          gradient: [Color(0xFF90A4AE), Color(0xFF455A64)],
        ),
      };
}
