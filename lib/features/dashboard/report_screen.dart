import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../profile/models/child_model.dart';
import 'dashboard_repository.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'vaccine_repository.dart';
import 'dental_screen.dart'; 

class ReportScreen extends ConsumerStatefulWidget {
  final ChildModel child;
  const ReportScreen({super.key, required this.child});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(weeklyLogsProvider(widget.child.id));

    return Scaffold(
      appBar: AppBar(
        title: Text("Weekly Report - ${widget.child.name}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(logsAsync.valueOrNull ?? []),
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text("No data for this week yet. Start your habits!"));
          }
          
          int totalBrushed = 0;
          int totalFlossed = 0;
          int totalHealthy = 0;
          
          for(var log in logs) {
            if(log['brushedMorning'] == true) totalBrushed++;
            if(log['brushedNight'] == true) totalBrushed++;
            
            if(log['flossedMorning'] == true) totalFlossed++;
            if(log['flossedNight'] == true) totalFlossed++;
            
            if(log['ateHealthy'] == true) totalHealthy++;
          }

          // Max possible for 7 days
          // Brush: 2 * 7 = 14
          // Floss: 2 * 7 = 14
          // Healthy: 1 * 7 = 7
          // But logs might be less than 7 if just started.
          // We'll just show raw counts for now or % based on days logged?
          // User asked for "progress should be shown".
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(totalBrushed, totalFlossed, totalHealthy),
                const SizedBox(height: 20),
                Text("Last 7 Days", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final date = DateTime.parse(log['date']);
                    final isFullDay = (log['brushedMorning'] && log['flossedMorning'] && 
                                     log['ateHealthy'] && 
                                     log['brushedNight'] && log['flossedNight']);
                                     
                    return Card(
                      color: isFullDay 
                        ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50) 
                        : null,
                      child: ListTile(
                        leading: Text(DateFormat.E().format(date), style: const TextStyle(fontWeight: FontWeight.bold)), // Mon, Tue
                        title: Text(DateFormat.MMMd().format(date)),
                        subtitle: Row(
                          children: [
                            if(log['brushedMorning']) const Text("☀️🦷 "),
                            if(log['flossedMorning']) const Text("☀️🧵 "),
                            if(log['ateHealthy']) const Text("🍎 "),
                            if(log['brushedNight']) const Text("🌙🦷 "),
                            if(log['flossedNight']) const Text("🌙🧵 "),
                          ],
                        ),
                        trailing: isFullDay ? const Icon(Icons.star, color: Colors.amber) : null,
                      ),
                    );
                  },
                )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error loading report: $e")),
      ),
    );
  }

  Widget _buildSummaryCard(int brush, int floss, int food) {
    // Basic calculation for pie chart: 
    // Total habit opportunities = (2 brush + 2 floss + 1 food) * 7 days = 35 total "points" max per week.
    // Or just compare the raw counts relative to each other?
    // User wants "result... like pie chart".
    
    // Let's maximize the chart visual.
    // We will show distribution of good habits.
    final total = brush + floss + food;
    
    return Card(
      elevation: 4,
      // color: Colors.white, // Use default Theme card color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Weekly Progress", style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade900
            )),
            const SizedBox(height: 20),
            
            if (total == 0) 
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("No habits logged yet this week."),
              )
            else
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.blue,
                        value: brush.toDouble(),
                        title: '$brush',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        badgeWidget: const _Badge(Icons.cleaning_services, size: 40, color: Colors.blue),
                        badgePositionPercentageOffset: .98,
                      ),
                      PieChartSectionData(
                        color: Colors.purple,
                        value: floss.toDouble(),
                        title: '$floss',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        badgeWidget: const _Badge(Icons.linear_scale, size: 40, color: Colors.purple),
                        badgePositionPercentageOffset: .98,
                      ),
                      PieChartSectionData(
                        color: Colors.green,
                        value: food.toDouble(),
                        title: '$food',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        badgeWidget: const _Badge(Icons.apple, size: 40, color: Colors.green),
                        badgePositionPercentageOffset: .98,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legendItem(Colors.blue, "Brushes ($brush)"),
                _legendItem(Colors.purple, "Flosses ($floss)"),
                _legendItem(Colors.green, "Healthy Food ($food)"),
              ],
            ),
             const SizedBox(height: 10),
            if(total > 15)
               const Text("Great job! Keep it up! 🌟", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
            else 
               const Text("Keep going! You can do better! 💪", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }




  Future<void> _exportPdf(List<Map<String, dynamic>> logs) async {
    // 1. Fetch Vaccine & Dental Data
    // We use .first to get the current snapshot of the stream
    final vaccines = await ref.read(vaccineRepositoryProvider).getVaccines(widget.child.id, widget.child.parentId).first;
    final appointments = await ref.read(dentalRepositoryProvider).getAppointments(widget.child.id, widget.child.parentId).first;

    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage( // Use MultiPage to handle long lists
        build: (pw.Context context) {
          return [
              pw.Header(
                level: 0,
                child: pw.Text("GrinGuide Health Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Child Name: ${widget.child.name}", style: const pw.TextStyle(fontSize: 18)),
              pw.Text("Date: ${DateFormat.yMMMd().format(DateTime.now())}", style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              
              // 1. Weekly Logs
              pw.Header(level: 1, child: pw.Text("Weekly Habits Progress")),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                data: <List<String>>[
                  <String>['Date', 'Brushed (AM)', 'Flossed (AM)', 'Healthy Food', 'Brushed (PM)', 'Flossed (PM)'],
                  ...logs.map((log) {
                      final date = DateTime.parse(log['date']);
                      return [
                        DateFormat('MM-dd').format(date),
                        log['brushedMorning'] ? 'Yes' : 'No',
                        log['flossedMorning'] ? 'Yes' : 'No',
                        log['ateHealthy'] ? 'Yes' : 'No',
                        log['brushedNight'] ? 'Yes' : 'No',
                        log['flossedNight'] ? 'Yes' : 'No',
                      ];
                  }),
                ],
              ),
              pw.SizedBox(height: 20),

              // 2. Vaccination Records
              pw.Header(level: 1, child: pw.Text("Vaccination History")),
              if (vaccines.isEmpty)
                pw.Paragraph(text: "No vaccination records found.")
              else
                pw.Table.fromTextArray(
                  context: context,
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  data: <List<String>>[
                    <String>['Vaccine', 'Scheduled', 'Doctor', 'Status', 'Date Given'],
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
              pw.SizedBox(height: 20),

              // 3. Dental Appointments
              pw.Header(level: 1, child: pw.Text("Dental Appointments")),
              if (appointments.isEmpty)
                pw.Paragraph(text: "No dental appointments found.")
              else
                pw.Table.fromTextArray(
                  context: context,
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
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
              pw.SizedBox(height: 20),
              pw.Paragraph(text: "Keep up the great work! Consistent habits lead to a healthy smile."),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'grin_guide_report.pdf');
  }
}

final weeklyLogsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, childId) {
  return ref.watch(dashboardRepositoryProvider).getWeeklyLogs(childId);
});

class _Badge extends StatelessWidget {
  const _Badge(this.icon, {required this.size, required this.color});
  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Icon(icon, color: color, size: size * 0.6),
      ),
    );
  }
}
