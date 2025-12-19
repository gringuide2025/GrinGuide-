import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/utils/image_helper.dart';
import '../profile/models/child_model.dart';
import '../profile/profile_controller.dart';
import 'dashboard_repository.dart';
import 'models/daily_checklist_model.dart';
import 'vaccine_screen.dart';
import 'dental_screen.dart';
import 'eruption_chart_screen.dart';
import 'insights_screen.dart';
import 'report_screen.dart';
import 'dart:convert';
import '../../shared/services/notification_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'vaccine_repository.dart';
import 'models/vaccine_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  String? _selectedChildId;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _checkSessionExpiry();
    _registerOneSignalPlayerId();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper Methods Restored
  Future<void> _registerOneSignalPlayerId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('⚠️ No user logged in, skipping OneSignal registration');
        return;
      }
      // Wait longer for OneSignal to fully initialize
      await Future.delayed(const Duration(seconds: 5));
      final externalUserId = await OneSignal.User.getExternalId();
      if (externalUserId == null || externalUserId.isEmpty) {
        OneSignal.login(user.uid);
      } else if (externalUserId != user.uid) {
        OneSignal.login(user.uid);
      }
      
      String? subscriptionId = OneSignal.User.pushSubscription.id;
      // Retry logic
      int retryCount = 0;
      while ((subscriptionId == null || subscriptionId.isEmpty) && retryCount < 3) {
        retryCount++;
        await Future.delayed(const Duration(seconds: 2));
        subscriptionId = OneSignal.User.pushSubscription.id;
      }
      
      if (subscriptionId != null && subscriptionId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'oneSignalPlayerIds': FieldValue.arrayUnion([subscriptionId]),
            'lastOneSignalUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('❌ Failed to save Player ID: $e');
        }
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
    for(int i=1; i<=5; i++) await notifService.cancelNotification(i);
    
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
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text("GrinGuide"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Weekly Report',
            onPressed: () {
              final children = childrenAsync.valueOrNull;
              if (children != null && children.isNotEmpty) {
                 final activeChild = children.firstWhere(
                   (c) => c.id == _selectedChildId, 
                   orElse: () => children.first
                 );
                 Navigator.of(context).push(
                   MaterialPageRoute(builder: (_) => ReportScreen(child: activeChild)),
                 );
              }
            },
          ),
          if (_selectedIndex != 1) // Hide in Vaccine Tab, show in Checklist, Dental, Insights
            IconButton(
              icon: const Icon(Icons.grid_on_rounded),
              tooltip: 'Eruption Chart',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EruptionChartScreen()),
                );
              },
            ),
          if (_selectedIndex == 1) // Vaccine Tab
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Vaccine Report',
              onPressed: () async {
                 final children = childrenAsync.valueOrNull;
                 if (children != null && children.isNotEmpty) {
                     final activeChild = children.firstWhere(
                       (c) => c.id == _selectedChildId, 
                       orElse: () => children.first
                     );
                     // Fetch vaccines (using a simple workaround if stream is issue)
                     final vaccines = await ref.read(vaccineRepositoryProvider).getVaccines(activeChild.id).first;
                     _generateVaccinePdf(activeChild, vaccines);
                 }
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
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

          // Schedule Notifications for ALL children
          WidgetsBinding.instance.addPostFrameCallback((_) {
             _scheduleMultiChildNotifications(children);
          });

          // Ensure selection
          final selectedChild = children.firstWhere(
            (c) => c.id == _selectedChildId, 
            orElse: () => children.first
          );
          final activeChild = selectedChild;

          return Column(
            children: [
              if (children.length > 1) 
                Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
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
                       return Padding(
                         padding: const EdgeInsets.only(right: 12),
                         child: ChoiceChip(
                           avatar: CircleAvatar(
                             backgroundImage: getProfileImageProvider(child.profilePhotoUrl),
                             child: child.profilePhotoUrl == null ? const Icon(Icons.face, size: 16) : null,
                           ),
                           label: Text(child.name),
                           selected: isSelected,
                           onSelected: (selected) {
                             if (selected) {
                               setState(() => _selectedChildId = child.id);
                             }
                           },
                         ),
                       );
                     },
                   ),
                  ),
                ),
              
              const Divider(height: 1),

              // Main Content Body with PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  children: [
                    _DailyChecklistTab(child: activeChild),
                    VaccineBody(child: activeChild),
                    DentalBody(child: activeChild),
                    InsightsScreen(),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(
            index, 
            duration: const Duration(milliseconds: 300), 
            curve: Curves.easeInOut
          );
        },
        destinations: [
           NavigationDestination(icon: const Icon(Icons.check_circle_outline), label: 'Checklist'),
           NavigationDestination(icon: const Icon(Icons.medical_services_outlined), label: 'Vaccines'),
           NavigationDestination(icon: const Icon(Icons.calendar_month_outlined), label: 'Dental'), 
           NavigationDestination(icon: const Icon(Icons.lightbulb_outline), label: 'Insights'),
        ],
      ),
      ),
    );
  }

  Widget _buildBody(ChildModel child) {
    switch (_selectedIndex) {
      case 0: return _DailyChecklistTab(child: child);
      case 1: return VaccineBody(child: child);
      case 2: return DentalBody(child: child);
      case 3: return InsightsScreen();
      default: return const SizedBox.shrink();
    }
  }

  Future<void> _generateVaccinePdf(ChildModel child, List<VaccineModel> vaccines) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
              pw.Header(
                level: 0,
                child: pw.Text("Vaccination Record", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Child Name: ${child.name}", style: const pw.TextStyle(fontSize: 18)),
              pw.Text("Date: ${DateFormat.yMMMd().format(DateTime.now())}", style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                columnWidths: {
                   0: const pw.FlexColumnWidth(2),
                   1: const pw.FlexColumnWidth(1.5),
                   2: const pw.FlexColumnWidth(1.5),
                   3: const pw.FlexColumnWidth(1),
                   4: const pw.FlexColumnWidth(1.5),
                },
                data: <List<String>>[
                  <String>['Vaccine', 'Scheduled', 'Doctor', 'Status', 'Given Date'],
                  ...vaccines.map((v) {
                    return [
                      v.vaccineName,
                      DateFormat('yyyy-MM-dd').format(v.scheduledDate),
                      v.doctorName ?? '-',
                      v.isDone ? 'Done' : 'Pending',
                      v.actualDate != null ? DateFormat('yyyy-MM-dd').format(v.actualDate!) : '-',
                    ];
                  }),
                ],
              ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'vaccine_record_${child.name}.pdf');
  }

  Future<void> _openMapUrl(String query) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
       debugPrint("Could not launch $url");
    }
  }

}

class _DailyChecklistTab extends ConsumerWidget {
  final ChildModel child;
  const _DailyChecklistTab({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistAsync = ref.watch(dailyChecklistProvider(child));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            children: [
              Text("Daily Checklist (${DateFormat('MMM d').format(DateTime.now())})", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          // BMI Info
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
               padding: const EdgeInsets.all(16),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                 children: [
                    Column(children: [Text("Height"), Text("${child.height} cm", style: const TextStyle(fontWeight: FontWeight.bold))]),
                    Column(children: [Text("Weight"), Text("${child.weight} kg", style: const TextStyle(fontWeight: FontWeight.bold))]),
                    Column(children: [Text("BMI"), Text(child.bmi.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
                 ],
               ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions (New Features)
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildActionCard(context, "Timer ⏳", Colors.blue.shade100, () => context.push('/timer')),
                const SizedBox(width: 10),
                _buildActionCard(context, "Find Dentist 🦷", Colors.teal.shade100, () => _launchMap(context, "pediatric dentist near me")),
                const SizedBox(width: 10),
                _buildActionCard(context, "Find Doc 🩺", Colors.red.shade100, () => _launchMap(context, "pediatrician near me")),
                const SizedBox(width: 10),
                _buildActionCard(context, "Chatbot 🤖", Colors.purple.shade100, () => context.push('/chatbot')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          checklistAsync.when(
            data: (checklist) {
               final foodEmojis = {
                 'Banana': '🍌', 'Carrots': '🥕', 'Curd': '🥣', 
                 'Nuts': '🥜', 'Spinach': '🥬', 'Apple': '🍎', 'Broccoli': '🥦'
               };
               final emoji = foodEmojis[checklist.healthyFoodItem] ?? '🍽️';
               
               return Column(
              children: [
                _buildCheckItem(ref, checklist, "Brush Morning ☀️", (val) => checklist.copyWith(brushMorning: val), checklist.brushMorning),
                _buildCheckItem(ref, checklist, "Floss Morning", (val) => checklist.copyWith(flossMorning: val), checklist.flossMorning),
                _buildCheckItem(ref, checklist, "Brush Night 🌙", (val) => checklist.copyWith(brushNight: val), checklist.brushNight),
                _buildCheckItem(ref, checklist, "Floss Night", (val) => checklist.copyWith(flossNight: val), checklist.flossNight),
                _buildCheckItem(ref, checklist, "Eat ${checklist.healthyFoodItem} $emoji", (val) => checklist.copyWith(healthyFood: val), checklist.healthyFood, icon: Icons.restaurant),
              ],
            );
            },
            loading: () => const Center(child: LinearProgressIndicator(),),
            error: (e,_) => Text("Error loading checklist: $e"),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(WidgetRef ref, DailyChecklistModel currentModel, String title, DailyChecklistModel Function(bool) updateFn, bool value, {IconData? icon}) {
    return Card(
      child: CheckboxListTile(
        value: value,
        title: Text(title),
        secondary: Icon(icon ?? Icons.check_circle_outline, color: value ? Colors.green : Colors.grey),
        onChanged: (newValue) {
          if (newValue != null) {
             final updatedModel = updateFn(newValue);
             ref.read(dashboardRepositoryProvider).updateChecklist(updatedModel);
          }
        },
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
      ),
    );
  }



  Future<void> _launchMap(BuildContext context, String query) async {
    // Request location permission first
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Location Services Disabled"),
              content: const Text("Please enable location services to find nearby dentists/doctors."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Geolocator.openLocationSettings();
                  },
                  child: const Text("Open Settings"),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Permission Required"),
                content: const Text("Location permission is required to find nearby dentists/doctors."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Permission Blocked"),
              content: const Text("Location permission is permanently denied. Please enable it in app settings."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Geolocator.openAppSettings();
                  },
                  child: const Text("Open App Settings"),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Launch Google Maps with current location and query
      final uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$query&center=${position.latitude},${position.longitude}"
      );
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch Maps"))
          );
        }
      }
    } catch (e) {
      debugPrint("Map Launch Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"))
        );
      }
    }
  }
}
