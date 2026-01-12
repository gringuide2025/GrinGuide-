import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../profile/models/child_model.dart';
import '../../shared/utils/date_input_formatter.dart';
import '../../core/theme/app_theme.dart';

import 'models/vaccine_model.dart';
import 'vaccine_repository.dart';

// --- DATA DEFINITIONS ---
final Map<String, String> vaccineIcons = {
  'BCG': '🧪',
  'OPV 0': '💧',
  'Hep-B': '💉',
  'OPV 1/2/3': '💧',
  'Pentavalent': '🛡️',
  'Rotavirus': '🌀',
  'PCV': '🦠',
  'IPV': '💉',
  'MR/Measles': '🍓',
  'DPT Booster': '🛡️',
  'Polio': '💧',
  'Vitamins': '💊',
  'Default': '💉',
};

final Map<String, String> vaccineTooltips = {
  'BCG': 'Protects against Tuberculosis (TB). Usually given at birth.',
  'OPV': 'Oral Polio Vaccine. Protects against Polio virus (liquid drops).',
  'Hep-B': 'Hepatitis B vaccine. Protects the liver from the Hep-B virus.',
  'Pentavalent': 'Combines 5 vaccines: Diphtheria, Pertussis, Tetanus, Hep-B, and Hib.',
  'Rotavirus': 'Protects infants from severe diarrhea caused by Rotavirus.',
  'PCV': 'Pneumococcal Conjugate Vaccine. Protects against pneumonia and meningitis.',
  'IPV': 'Inactivated Polio Vaccine. An injectable form of polio protection.',
  'MR': 'Measles and Rubella. Protects against these highly contagious viral rashes.',
  'DPT': 'Diphtheria, Pertussis, and Tetanus. Boosts immunity against these infections.',
  'Vitamin A': 'Essential for vision, immune function, and bone growth.',
  'Default': 'Essential vaccination for child health and immunity.'
};

class VaccineScreen extends StatelessWidget {
  final ChildModel child;
  const VaccineScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vaccinations - ${child.name}"),
        elevation: 0,
      ),
      body: VaccineBody(child: child),
    );
  }
}

class VaccineBody extends ConsumerStatefulWidget {
  final ChildModel child;
  const VaccineBody({super.key, required this.child});

  @override
  ConsumerState<VaccineBody> createState() => _VaccineBodyState();
}

class _VaccineBodyState extends ConsumerState<VaccineBody> {
  @override
  void initState() {
    super.initState();
    ref.read(vaccineRepositoryProvider).initializeVaccinesForChild(widget.child);
  }

  @override
  Widget build(BuildContext context) {
    final vaccinesAsync = ref.watch(vaccinesProvider(widget.child));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return vaccinesAsync.when(
      data: (vaccines) {
        if (vaccines.isEmpty) return const Center(child: Text("Loading Schedule..."));

        final doneCount = vaccines.where((v) => v.isDone).length;
        final progress = doneCount / vaccines.length;

        // Group by Date
        final grouped = <DateTime, List<VaccineModel>>{};
        for (var v in vaccines) {
          final date = DateUtils.dateOnly(v.scheduledDate);
          if (!grouped.containsKey(date)) grouped[date] = [];
          grouped[date]!.add(v);
        }

        final dates = grouped.keys.toList()..sort();
        final now = DateTime.now();
        
        // Find "Active" milestone (next upcoming or last pending)
        DateTime? activeDate;
        for (var date in dates) {
          if (!grouped[date]!.every((v) => v.isDone)) {
            activeDate = date;
            break;
          }
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.05),
                isDark ? Colors.black : Colors.white,
              ],
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            itemCount: dates.length + 1, // +1 for the header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildProgressHeader(progress, doneCount, vaccines.length);
              }
              
              final dateIndex = index - 1;
              final date = dates[dateIndex];
              final groupVaccines = grouped[date]!;
              final isAllDone = groupVaccines.every((v) => v.isDone);
              final isActive = date == activeDate;
              final isPast = date.isBefore(DateUtils.dateOnly(now));

              return _buildTimelineItem(
                index: dateIndex,
                total: dates.length,
                date: date,
                vaccines: groupVaccines,
                isDone: isAllDone,
                isActive: isActive,
                isPast: isPast,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildProgressHeader(double progress, int done, int total) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF1A237E), const Color(0xFF311B92)] // Deep Indigo/Purple for Dark Mode
            : [primaryColor, primaryColor.withBlue(255).withGreen(100)], // Vibrant Blue gradient for Light Mode
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                   SizedBox(
                    height: 70,
                    width: 70,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Vaccination Progress", 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: Colors.white)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$done of $total completed", 
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600)
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        progress >= 1.0 ? "🎉 Fully Protected" : "⏳ Stay on Track",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required int index,
    required int total,
    required DateTime date,
    required List<VaccineModel> vaccines,
    required bool isDone,
    required bool isActive,
    required bool isPast,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Age Label Logic
    String ageLabel = "Visit";
    final diff = date.difference(widget.child.dob).inDays;
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
    else ageLabel = "4-5 Years";

    return Stack(
      children: [
        // The Line - drawn behind the content
        Positioned(
          left: 10, // Same as center of icon
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: (isPast || isDone ? primaryColor : Colors.grey.withOpacity(0.3)),
          ),
        ),
        // The Content
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with its own background to "cut" the line
              Column(
                children: [
                  const SizedBox(height: 20), // Top spacing to align with header
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black : Colors.white, // Background matches screen to cut line
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? Colors.amber : (isDone ? primaryColor : Colors.grey.withOpacity(0.4)),
                        width: 2,
                      ),
                      boxShadow: isActive ? [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)] : null,
                    ),
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: isDone ? primaryColor : (isActive ? Colors.amber : Colors.white),
                      child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Visit Card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive ? Colors.amber.withOpacity(0.12) : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? Colors.amber.withOpacity(0.5) : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          tileColor: isActive ? Colors.amber.withOpacity(0.1) : null,
                          dense: true,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.amber.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isActive ? Icons.stars_rounded : Icons.calendar_today_rounded,
                              size: 18,
                              color: isActive ? Colors.amber.shade900 : primaryColor,
                            ),
                          ),
                          title: Text(
                            "$ageLabel Visit", 
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              color: isActive ? Colors.amber.shade900 : (isDark ? Colors.white : Colors.black87),
                              fontSize: 15,
                            )
                          ),
                          subtitle: Text(
                            DateFormat.yMMMd().format(date), 
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey : Colors.grey.shade700)
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.medical_services_rounded, size: 18, color: Colors.teal),
                                onPressed: () => _showDoctorDialog(context, vaccines),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_calendar_rounded, size: 18, color: Colors.blue),
                                onPressed: () => _showRescheduleDialog(context, vaccines, date),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        ...vaccines.map((v) => _buildVaccineRow(v)),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVaccineRow(VaccineModel vaccine) {
    final emoji = vaccineIcons.entries.firstWhere((e) => vaccine.vaccineName.contains(e.key), orElse: () => vaccineIcons.entries.last).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CheckboxListTile(
      value: vaccine.isDone,
      onChanged: (val) {
        if (val != null) {
          ref.read(vaccineRepositoryProvider).updateVaccineStatus(vaccine.id, val, val ? DateTime.now() : null);
        }
      },
      dense: true, // Make the tile more compact
      visualDensity: VisualDensity.compact, // Reduce vertical padding
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              vaccine.vaccineName, 
              style: TextStyle(
                fontSize: 13, // Slightly smaller font
                decoration: vaccine.isDone ? TextDecoration.lineThrough : null,
                color: vaccine.isDone ? Colors.grey : (isDark ? Colors.white : Colors.black87),
              )
            )
          ),
          IconButton(
            icon: Icon(
              Icons.info_rounded, 
              size: 16, 
              color: isDark ? Colors.lightBlueAccent : Colors.blue.shade700
            ),
            onPressed: () => _showInfoDialog(context, vaccine.vaccineName),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
      secondary: vaccine.isDone ? const Icon(Icons.check_circle, color: Colors.green, size: 18) : const Icon(Icons.radio_button_unchecked, size: 18),
      controlAffinity: ListTileControlAffinity.trailing,
      activeColor: Colors.green,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // Reduced padding
      subtitle: (vaccine.doctorName?.isNotEmpty ?? false) 
        ? Text("👨‍⚕️ ${vaccine.doctorName}", style: const TextStyle(fontSize: 10, color: Colors.grey))
        : null,
    );
  }

  void _showInfoDialog(BuildContext context, String name) {
    final description = vaccineTooltips.entries.firstWhere((e) => name.contains(e.key), orElse: () => vaccineTooltips.entries.last).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: primaryColor.withOpacity(0.2), width: 1)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.info_rounded, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87, fontSize: 18))),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.only(top: 8),
          child: SingleChildScrollView(
            child: Text(
              description, 
              style: TextStyle(height: 1.5, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800, fontSize: 14)
            )
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Got it!", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDoctorDialog(BuildContext context, List<VaccineModel> vaccines) {
    final controller = TextEditingController(text: vaccines.first.doctorName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set Doctor/Clinic"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: "Doctor's Name", border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                for (var v in vaccines) {
                  ref.read(vaccineRepositoryProvider).updateVaccineDoctor(v.id, name);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, List<VaccineModel> vaccines, DateTime currentDate) {
    final dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(currentDate));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reschedule Visit"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter new date for this visit:"),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                keyboardType: TextInputType.number,
                inputFormatters: [DateInputFormatter()],
                decoration: InputDecoration(
                  labelText: "DD/MM/YYYY",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: currentDate,
                        firstDate: widget.child.dob,
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        dateController.text = DateFormat('dd/MM/yyyy').format(d);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              try {
                final newDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
                for (var v in vaccines) {
                  ref.read(vaccineRepositoryProvider).updateVaccineDate(v.id, newDate);
                }
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Date!")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

final vaccinesProvider = StreamProvider.family((ref, ChildModel child) {
  return ref.watch(vaccineRepositoryProvider).getVaccines(child.id, child.parentId);
});
