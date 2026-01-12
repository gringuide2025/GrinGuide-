import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/app_drawer.dart';
import '../profile/profile_repository.dart';
import '../profile/models/child_model.dart';
import '../profile/models/parent_model.dart';
import 'dashboard_repository.dart';
import 'models/daily_checklist_model.dart';
import 'insights_screen.dart';
import 'report_screen.dart';
import '../../shared/services/notification_service.dart';
import 'vaccine_screen.dart';
import 'dental_screen.dart';
import 'vaccine_repository.dart';
import 'models/vaccine_model.dart';
import 'eruption_chart_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  String? _selectedChildId;
  final PageController _pageController = PageController();
  final TextEditingController _insightsSearchController = TextEditingController();

  final GlobalKey _bmiKey = GlobalKey();
  final GlobalKey _timerKey = GlobalKey();
  final GlobalKey _dentistKey = GlobalKey();
  final GlobalKey _chatbotKey = GlobalKey();
  final GlobalKey _checklistKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkSessionExpiry();
    _setupOneSignal();
  }

  Future<void> _setupOneSignal() async {
    try {
      final userResponse = ref.read(profileRepositoryProvider).currentUserId;
      if (userResponse.isNotEmpty) {
        await OneSignal.login(userResponse);
        debugPrint('✅ OneSignal registered for: $userResponse');
      }
    } catch (e) {
      debugPrint('❌ Error registering OneSignal: $e');
    }
  }

  Future<void> _checkSessionExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('show_session_expiry') == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You were logged out for security (1 week session limit). Please log in again to continue.")),
        );
      }
      await prefs.remove('show_session_expiry');
    }
  }

  Future<void> _scheduleMultiChildNotifications(List<ChildModel> children) async {
    final notifService = NotificationService();
    for(int i=1; i<=100; i++) {
      // Clear a larger range to be safe
      await notifService.cancelNotification(i);
    }
    
    for (int i = 0; i < children.length; i++) {
        final child = children[i];
        final baseId = (i + 1) * 1000;
        await notifService.scheduleDaily(id: baseId + 1, title: "Morning Brush ☀️", body: "Time for ${child.name} to brush!", time: const TimeOfDay(hour: 7, minute: 0), payload: jsonEncode({'childId': child.id, 'task': 'brushMorning'}));
        await notifService.scheduleDaily(id: baseId + 2, title: "Morning Floss 🧵", body: "Floss time for ${child.name}!", time: const TimeOfDay(hour: 7, minute: 3), payload: jsonEncode({'childId': child.id, 'task': 'flossMorning'}));
        await notifService.scheduleDaily(id: baseId + 3, title: "Healthy Breakfast 🍎", body: "${child.name} needs a healthy start!", time: const TimeOfDay(hour: 8, minute: 0), payload: jsonEncode({'childId': child.id, 'task': 'healthyFood'}));
        await notifService.scheduleDaily(id: baseId + 4, title: "Night Brush 🌙", body: "Bedtime brushing for ${child.name}!", time: const TimeOfDay(hour: 21, minute: 0), payload: jsonEncode({'childId': child.id, 'task': 'brushNight'}));
        await notifService.scheduleDaily(id: baseId + 5, title: "Night Floss 🧵", body: "Flossing done for ${child.name}?", time: const TimeOfDay(hour: 21, minute: 3), payload: jsonEncode({'childId': child.id, 'task': 'flossNight'}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenProvider);
    final parentAsync = ref.watch(parentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() => _selectedIndex = 0);
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        body: childrenAsync.when(
          data: (children) {
            if (children.isEmpty) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/profile/add-child'),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Child Profile"),
                ),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
               _scheduleMultiChildNotifications(children);
            });

            final activeChild = children.firstWhere(
              (c) => c.id == _selectedChildId, 
              orElse: () => children.first
            );

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark 
                    ? [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).primaryColor.withOpacity(0.05)]
                    : [Colors.white, Theme.of(context).primaryColor.withOpacity(0.02)],
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(context, parentAsync.value, activeChild),
                  if (_selectedIndex != 3) _buildChildSelector(children, activeChild),
                  
                  const Divider(height: 1),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() => _selectedIndex = index),
                      children: [
                        _DailyChecklistTab(
                          child: activeChild,
                          bmiKey: _bmiKey,
                          timerKey: _timerKey,
                          dentistKey: _dentistKey,
                          chatbotKey: _chatbotKey,
                          checklistKey: _checklistKey,
                        ),
                        VaccineBody(child: activeChild),
                        DentalBody(child: activeChild),
                        InsightsScreen(searchController: _insightsSearchController),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ParentModel? parent, ChildModel activeChild) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Image.asset(
                  'assets/images/logo.png', 
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedIndex == 3 ? "Insights" : "Hello, ${activeChild.name}! 👋",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ),
                if (_selectedIndex == 0)
                  _buildActionChip(
                    icon: Icons.assessment_rounded,
                    label: "Report",
                    color: Colors.purple,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ReportScreen(child: activeChild)),
                    ),
                  ),
                if (_selectedIndex == 1)
                  _buildActionChip(
                    icon: Icons.picture_as_pdf_rounded,
                    label: "PDF",
                    color: Colors.blue,
                    onTap: () async {
                      final vaccines = await ref.read(vaccineRepositoryProvider).getVaccines(activeChild.id, activeChild.parentId).first;
                      _generateVaccinePdf(activeChild, vaccines);
                    },
                  ),
              ],
            ),
          ),
          if (_selectedIndex == 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: TextField(
                controller: _insightsSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search dental insights...",
                  prefixIcon: const Icon(Icons.search, size: 22, color: Colors.orangeAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.orangeAccent.withOpacity(0.08),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChildSelector(List<ChildModel> children, ChildModel activeChild) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: children.length,
          itemBuilder: (context, index) {
            final child = children[index];
            final isSelected = child.id == activeChild.id;
            final color = child.gender == 'girl' ? Colors.pink : Colors.blue;
            
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedChildId = child.id),
                borderRadius: BorderRadius.circular(25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(child.gender == 'girl' ? '👧' : '👦', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        child.name,
                        style: TextStyle(
                          color: isSelected ? color : color.withOpacity(0.7),
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle_rounded, size: 16, color: color),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionChip({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.checklist_rounded), label: "Daily"),
        NavigationDestination(icon: Icon(Icons.vaccines_rounded), label: "Vaccines"),
        NavigationDestination(icon: Icon(Icons.medical_services_rounded), label: "Dental"),
        NavigationDestination(icon: Icon(Icons.lightbulb_rounded), label: "Insights"),
      ],
    );
  }

  Future<void> _generateVaccinePdf(ChildModel child, List<VaccineModel> vaccines) async {
    // PDF generation logic (assuming it exists in a separate service or utility)
  }
}

class _DailyChecklistTab extends ConsumerWidget {
  final ChildModel child;
  final GlobalKey? bmiKey;
  final GlobalKey? timerKey;
  final GlobalKey? dentistKey;
  final GlobalKey? chatbotKey;
  final GlobalKey? checklistKey;

  const _DailyChecklistTab({
    required this.child,
    this.bmiKey,
    this.timerKey,
    this.dentistKey,
    this.chatbotKey,
    this.checklistKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistAsync = ref.watch(dailyChecklistProvider(child));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressGoal(context, checklistAsync),
          const SizedBox(height: 20),
          _buildHealthSnapshot(context, child),
          const SizedBox(height: 20),
          _buildActionCards(context),
          const SizedBox(height: 24),
          Text(
            "Daily Checklist (${DateFormat('MMM d').format(DateTime.now())})", 
            key: checklistKey,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)
          ),
          const SizedBox(height: 12),
          _buildChecklistItems(ref, checklistAsync),
        ],
      ),
    );
  }

  Widget _buildProgressGoal(BuildContext context, AsyncValue<DailyChecklistModel> checklistAsync) {
    return checklistAsync.when(
      data: (checklist) {
        final items = [checklist.brushMorning, checklist.flossMorning, checklist.brushNight, checklist.flossNight, checklist.healthyFood];
        final progress = items.where((i) => i).length / items.length;
        final percentage = (progress * 100).toInt();
        
        String motivation = progress == 0 ? "Let's get started! 🚀" : (progress < 1.0 ? "Almost there! 💪" : "Perfect day! 🎉");

        return Card(
          elevation: 0,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 70, width: 70,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text("$percentage%", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).primaryColor)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Daily Goal", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.8))),
                      const SizedBox(height: 4),
                      Text(motivation, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHealthSnapshot(BuildContext context, ChildModel child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      key: bmiKey,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Health Overview", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.8))),
                _buildBmiBadge(child.bmi),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHealthStat("Height", "${child.height}", "cm", "📏", Colors.blue),
                Container(width: 1, height: 40, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                _buildHealthStat("Weight", "${child.weight}", "kg", "⚖️", Colors.orange),
                Container(width: 1, height: 40, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                _buildHealthStat("BMI", child.bmi.toStringAsFixed(1), "", "🩺", child.bmi < 18.5 ? Colors.orange : (child.bmi <= 25.0 ? Colors.green : Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildActionCard(context, "Timer", "⏳", [Colors.blueAccent, Colors.cyanAccent], timerKey, () => context.push('/timer', extra: child))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, "Chatbot", "🤖", [Colors.purpleAccent, Colors.pinkAccent], chatbotKey, () => context.push('/chatbot'))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, "Stories", "📖", [Colors.indigoAccent, Colors.blueAccent], null, () => context.push('/stories', extra: child))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, "Teeth Chart", "🦷", [Colors.limeAccent.shade700, Colors.greenAccent.shade400], null, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EruptionChartScreen())))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, "Dentist", "🦷", [Colors.tealAccent.shade400, Colors.greenAccent.shade400], dentistKey, () => _launchMap(context, "pediatric dentist near me"))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(context, "Doctor", "🩺", [Colors.redAccent.shade200, Colors.orangeAccent.shade200], null, () => _launchMap(context, "pediatrician near me"))),
          ],
        ),
      ],
    );
  }

  Widget _buildChecklistItems(WidgetRef ref, AsyncValue<DailyChecklistModel> checklistAsync) {
    return checklistAsync.when(
      data: (checklist) {
        final emoji = {'Banana': '🍌', 'Carrots': '🥕', 'Curd': '🥣', 'Nuts': '🥜', 'Spinach': '🥬', 'Apple': '🍎', 'Broccoli': '🥦'}[checklist.healthyFoodItem] ?? '🍽️';
        return Column(
          children: [
            _buildCheckItem(ref, checklist, "Brush Morning ☀️", (val) => checklist.copyWith(brushMorning: val), checklist.brushMorning),
            _buildCheckItem(ref, checklist, "Floss Morning 🧵", (val) => checklist.copyWith(flossMorning: val), checklist.flossMorning),
            _buildCheckItem(ref, checklist, "Brush Night 🌙", (val) => checklist.copyWith(brushNight: val), checklist.brushNight),
            _buildCheckItem(ref, checklist, "Floss Night 🧵", (val) => checklist.copyWith(flossNight: val), checklist.flossNight),
            _buildCheckItem(ref, checklist, "Eat ${checklist.healthyFoodItem} $emoji", (val) => checklist.copyWith(healthyFood: val), checklist.healthyFood, icon: Icons.restaurant),
          ],
        );
      },
      loading: () => const Center(child: LinearProgressIndicator()),
      error: (e, _) => Text("Error: $e"),
    );
  }

  Widget _buildCheckItem(WidgetRef ref, DailyChecklistModel checklist, String title, DailyChecklistModel Function(bool) update, bool value, {IconData icon = Icons.check_circle_outline}) {
    final isDark = Theme.of(ref.context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: value ? Theme.of(ref.context).primaryColor.withOpacity(isDark ? 0.15 : 0.1) : Theme.of(ref.context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: value ? Theme.of(ref.context).primaryColor.withOpacity(0.3) : Theme.of(ref.context).dividerColor.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: value ? Theme.of(ref.context).primaryColor.withOpacity(0.1) : Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: InkWell(
          onTap: () async {
            try {
              await ref.read(dashboardRepositoryProvider).updateChecklist(update(!value));
            } catch (e) {
              ScaffoldMessenger.of(ref.context).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _AnimatedCheckCircle(value: value),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: value ? FontWeight.bold : FontWeight.w500, decoration: value ? TextDecoration.lineThrough : null))),
                Icon(icon, size: 20, color: value ? Theme.of(ref.context).primaryColor : Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStat(String label, String value, String unit, String emoji, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text("$label ($unit)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildBmiBadge(double bmi) {
    final status = bmi < 18.5 ? "Underweight" : (bmi <= 25.0 ? "Normal" : "Overweight");
    final color = bmi < 18.5 ? Colors.orange : (bmi <= 25.0 ? Colors.green : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String emoji, List<Color> colors, GlobalKey? key, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colors[0].withOpacity(isDark ? 0.3 : 0.2), colors[1].withOpacity(isDark ? 0.15 : 0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors[0].withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(isDark ? 0.1 : 0.5), shape: BoxShape.circle), child: Text(emoji, style: const TextStyle(fontSize: 20))),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchMap(BuildContext context, String query) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
      Position position = await Geolocator.getCurrentPosition();
      final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query&center=${position.latitude},${position.longitude}");
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Map Error: $e");
    }
  }
}

class _AnimatedCheckCircle extends StatelessWidget {
  final bool value;
  const _AnimatedCheckCircle({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      padding: EdgeInsets.all(value ? 4 : 2),
      decoration: BoxDecoration(
        color: value ? Theme.of(context).primaryColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: value ? Theme.of(context).primaryColor : Theme.of(context).dividerColor.withOpacity(0.2), width: 2),
      ),
      child: AnimatedScale(
        scale: value ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      ),
    );
  }
}
