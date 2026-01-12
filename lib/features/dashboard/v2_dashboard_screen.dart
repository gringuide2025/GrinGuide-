import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../profile/profile_repository.dart';
import '../profile/models/child_model.dart';
import 'dashboard_repository.dart';
import 'models/daily_checklist_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_drawer.dart';
import 'vaccine_screen.dart';
import 'dental_screen.dart';
import 'insights_screen.dart';
import 'report_screen.dart';
import 'eruption_chart_screen.dart';
import 'vaccine_repository.dart';
import 'models/vaccine_model.dart';
import 'models/dental_appointment_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class V2DashboardScreen extends ConsumerStatefulWidget {
  const V2DashboardScreen({super.key});

  @override
  ConsumerState<V2DashboardScreen> createState() => _V2DashboardScreenState();
}

class _V2DashboardScreenState extends ConsumerState<V2DashboardScreen> {
  String? _selectedChildId;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _insightsSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenProvider);

    return Scaffold(
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

          final selectedChildId = _selectedChildId ?? children.first.id;
          final activeChild = children.firstWhere(
            (c) => c.id == selectedChildId,
            orElse: () => children.first,
          );

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.05),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(children, activeChild),
                  if (_selectedIndex != 3)
                     _buildChildSelector(children, activeChild),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() => _selectedIndex = index),
                      children: [
                        _buildV2DailyTab(activeChild),
                        VaccineBody(child: activeChild),
                        DentalBody(child: activeChild),
                        InsightsScreen(searchController: _insightsSearchController),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildV2DailyTab(ChildModel activeChild) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedSection(
            delay: 0,
            child: _buildActionGrid(context, activeChild),
          ),
          const SizedBox(height: 24),
          _buildAnimatedSection(
            delay: 150,
            child: _buildGrowthTracker(activeChild),
          ),
          const SizedBox(height: 24),
          _buildAnimatedSection(
            delay: 300,
            child: _buildDailyChecklist(activeChild),
          ),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
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

  Widget _buildHeader(List<ChildModel> children, ChildModel activeChild) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png', 
                      height: 24,
                      width: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedIndex == 3 ? "Insights" : "Welcome, ${activeChild.name}!",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                    // (logic preserved)
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Generating Health Record..."), duration: Duration(seconds: 2)));
                      final vaccinesFuture = ref.read(vaccineRepositoryProvider).getVaccines(activeChild.id, activeChild.parentId).first;
                      final dentalFuture = ref.read(dentalRepositoryProvider).getAppointments(activeChild.id, activeChild.parentId).first;
                      final results = await Future.wait([vaccinesFuture, dentalFuture]);
                      final vaccines = results[0] as List<VaccineModel>;
                      final appointments = results[1] as List<DentalAppointmentModel>;
                      if (vaccines.isEmpty && appointments.isEmpty) throw Exception("No health records found to export.");
                      await _generateCombinedHealthPdf(activeChild, vaccines, appointments);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Export Error: $e"), backgroundColor: Colors.red));
                    }
                  },
                ),
            ],
          ),
        ),
        if (_selectedIndex == 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _insightsSearchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search dental insights...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.orange.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionChip({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label, 
              style: TextStyle(
                color: color, 
                fontWeight: FontWeight.w900, 
                fontSize: 12,
                letterSpacing: 0.5
              )
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateCombinedHealthPdf(ChildModel child, List<VaccineModel> vaccines, List<DentalAppointmentModel> appointments) async {
    final pdf = pw.Document();
    
    // Group vaccines logic
    final groupedVaccines = <String, List<VaccineModel>>{};
    for (var v in vaccines) {
       String ageLabel = "Scheduled";
       final diff = v.scheduledDate.difference(child.dob).inDays;
       if (diff < 2) ageLabel = "At Birth";
       else if (diff < 50) ageLabel = "6 Weeks";
       else if (diff < 80) ageLabel = "10 Weeks";
       else if (diff < 110) ageLabel = "14 Weeks";
       else if (diff < 200) ageLabel = "6 Months";
       else if (diff < 300) ageLabel = "9 Months";
       else if (diff < 400) ageLabel = "12 Months";
       else if (diff < 500) ageLabel = "15 Months";
       else if (diff < 600) ageLabel = "18 Months";
       else if (diff < 800) ageLabel = "2 Years";
       else if (diff < 2500) ageLabel = "4-5 Years";
       else ageLabel = "School Age";

       if (!groupedVaccines.containsKey(ageLabel)) groupedVaccines[ageLabel] = [];
       groupedVaccines[ageLabel]!.add(v);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Child Health Record", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                    pw.Text("GrinGuide", style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Child Name: ${child.name}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Date of Birth: ${DateFormat.yMMMd().format(child.dob)}", style: const pw.TextStyle(fontSize: 12)),
                    pw.Text("Report Date: ${DateFormat.yMMMd().format(DateTime.now())}", style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // 1. VACCINES
              pw.Header(level: 1, text: "Vaccination History"),
              if (vaccines.isEmpty)
                 pw.Paragraph(text: "No vaccination records found.")
              else 
                 ...groupedVaccines.entries.map((entry) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                        child: pw.Text(entry.key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Table.fromTextArray(
                        context: context,
                        border: pw.TableBorder.all(color: PdfColors.grey400),
                        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        cellHeight: 25,
                        columnWidths: {
                           0: const pw.FlexColumnWidth(2),
                           1: const pw.FlexColumnWidth(1.2),
                           2: const pw.FlexColumnWidth(1.5),
                           3: const pw.FlexColumnWidth(0.8),
                           4: const pw.FlexColumnWidth(1.2),
                        },
                        data: <List<String>>[
                          <String>['Vaccine', 'Scheduled', 'Doctor', 'Status', 'Given Date'],
                          ...entry.value.map((v) {
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
                      pw.SizedBox(height: 15),
                    ],
                  );
                }),
                
              pw.SizedBox(height: 20),

              // 2. DENTAL APPOINTMENTS
              pw.Header(level: 1, text: "Dental Appointments"),
              if (appointments.isEmpty)
                pw.Paragraph(text: "No dental appointments found.")
              else
                pw.Table.fromTextArray(
                  context: context,
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  data: <List<String>>[
                    <String>['Doctor/Clinic', 'Purpose', 'Date', 'Time'],
                    ...appointments.map((a) {
                      return [
                        a.doctorName,
                        a.purpose,
                        DateFormat('yyyy-MM-dd').format(a.appointmentDate),
                        DateFormat.jm().format(a.appointmentDate),
                      ];
                    }),
                  ],
                ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'health_record_${child.name}.pdf');
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

  Widget _buildGrowthTracker(ChildModel child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Growth Tracker",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getBmiColor(child.bmi).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _getBmiColor(child.bmi).withOpacity(0.3)),
                ),
                child: Text(
                  _getBmiStatusText(child.bmi),
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.w900, 
                    color: _getBmiColor(child.bmi),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGrowthStatColumn("HEIGHT", "📏 ${child.height} cm", Colors.blue),
              _buildGrowthStatColumn("WEIGHT", "⚖️ ${child.weight} kg", Colors.orange),
              _buildGrowthStatColumn("BMI", "💪 ${child.bmi.toStringAsFixed(1)}", Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthStatColumn(String label, String value, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, 
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value, 
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getBmiStatusText(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi <= 25.0) return "Normal";
    return "Overweight";
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi <= 25.0) return Colors.green;
    return Colors.red;
  }

  Widget _buildActionGrid(BuildContext context, ChildModel child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text("Quick Actions",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.33, // Makes height ~0.75 of width
          children: [
            _buildActionCard(
                "Timer", Icons.timer_rounded, Colors.blue, () => context.push('/timer', extra: child)),
            _buildActionCard("Stories", Icons.auto_stories_rounded, Colors.indigo, () => context.push('/stories', extra: child)),
            _buildActionCard("Eruption Chart", Icons.child_care_rounded, Colors.teal, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EruptionChartScreen()))),
            _buildActionCard("Chatbot", Icons.smart_toy_rounded, Colors.purple, () => context.push('/chatbot')),
            _buildActionCard("Dentist", Icons.location_on_rounded, Colors.orange, () => _launchMaps("Pediatric Dentist")),
            _buildActionCard("Doctor", Icons.medical_services_rounded, Colors.red, () => _launchMaps("Pediatrician near me")),
          ],
        ),
      ],
    );
  }

  Future<void> _launchMaps(String query) async {
    // 1. Check/Request Permission
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    // 2. Check Location Services
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Location is Off"),
            content: const Text("Please turn on location to find the best specialists near you."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
              ElevatedButton(
                onPressed: () {
                  Geolocator.openLocationSettings();
                  Navigator.pop(context);
                },
                child: const Text("TURN ON"),
              ),
            ],
          ),
        );
      }
      return; 
    }

    // 3. Launch Maps
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open maps.")),
        );
      }
    }
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChecklist(ChildModel child) {
    final checklistAsync = ref.watch(dailyChecklistProvider(child));

    return checklistAsync.when(
      data: (checklist) {
        final isComplete = checklist.brushMorning &&
            checklist.brushNight &&
            checklist.flossMorning &&
            checklist.flossNight &&
            checklist.healthyFood;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Checklist",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Text("All Done! ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        Icon(Icons.stars_rounded, color: Colors.orange, size: 16),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCheckItem("Morning Brush ☀️", checklist.brushMorning,
                () => _toggleHabit(checklist, 'brushMorning')),
            _buildCheckItem("Floss Morning 🧵", checklist.flossMorning,
                () => _toggleHabit(checklist, 'flossMorning')),
            _buildCheckItem("Healthy Food 🍎", checklist.healthyFood,
                () => _toggleHabit(checklist, 'healthyFood')),
            _buildCheckItem("Night Brush 🌙", checklist.brushNight,
                () => _toggleHabit(checklist, 'brushNight')),
            _buildCheckItem("Floss Night 🧵", checklist.flossNight,
                () => _toggleHabit(checklist, 'flossNight')),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text("Error: $e"),
    );
  }

  void _toggleHabit(DailyChecklistModel checklist, String field) {
    DailyChecklistModel updated;
    switch(field) {
      case 'brushMorning': updated = checklist.copyWith(brushMorning: !checklist.brushMorning); break;
      case 'flossMorning': updated = checklist.copyWith(flossMorning: !checklist.flossMorning); break;
      case 'healthyFood': updated = checklist.copyWith(healthyFood: !checklist.healthyFood); break;
      case 'brushNight': updated = checklist.copyWith(brushNight: !checklist.brushNight); break;
      case 'flossNight': updated = checklist.copyWith(flossNight: !checklist.flossNight); break;
      default: return;
    }
    ref.read(dashboardRepositoryProvider).updateChecklist(updated);
  }

  Widget _buildCheckItem(String title, bool isDone, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.glassDecoration(context).copyWith(
          border: Border.all(
            color: isDone ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(isDone ? Icons.check_circle : Icons.circle_outlined,
                color: isDone ? Colors.blue : Colors.grey, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title, 
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDone 
                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
              ),
            ),
            if (isDone)
              const Icon(Icons.auto_awesome, color: Colors.orange, size: 16),
          ],
        ),
      ),
    );
  }
}
