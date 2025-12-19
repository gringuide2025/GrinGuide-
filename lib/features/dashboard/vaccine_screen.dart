import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../profile/models/child_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'models/vaccine_model.dart';
import 'vaccine_repository.dart';

class VaccineScreen extends StatelessWidget {
  final ChildModel child;
  const VaccineScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vaccinations - ${child.name}"),
        actions: [
          // PDF Exporter
          Consumer(
            builder: (context, ref, _) {
              return IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: "Generate Report",
                onPressed: () async {
                   final vaccines = await ref.read(vaccineRepositoryProvider).getVaccines(child.id, child.parentId).first;
                   _generateVaccinePdf(child, vaccines);
                },
              );
            }
          )
        ],
      ),
      body: VaccineBody(child: child),
    );
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

    return vaccinesAsync.when(
      data: (vaccines) {
         if (vaccines.isEmpty) return const Center(child: Text("Loading Schedule..."));
         
         // Group by Date
         final grouped = <DateTime, List<VaccineModel>>{};
         for (var v in vaccines) {
           final date = DateUtils.dateOnly(v.scheduledDate);
           if (!grouped.containsKey(date)) grouped[date] = [];
           grouped[date]!.add(v);
         }
         
         final dates = grouped.keys.toList()..sort();

         return ListView.builder(
           itemCount: dates.length,
           padding: const EdgeInsets.all(16),
           itemBuilder: (context, index) {
             final date = dates[index];
             final groupVaccines = grouped[date]!;
             final isAllDone = groupVaccines.every((v) => v.isDone);
             
             // Determine Age Label (approx)
             String ageLabel = "Scheduled";
             final diff = date.difference(widget.child.dob).inDays;
             if (diff < 2) {
               ageLabel = "At Birth";
             } else if (diff < 50) ageLabel = "6 Weeks"; // Keeping others English for now or add keys later if requested
             else if (diff < 80) ageLabel = "10 Weeks";
             else if (diff < 110) ageLabel = "14 Weeks";
             else if (diff < 200) ageLabel = "6 Months";
             else if (diff < 300) ageLabel = "9 Months";
             else if (diff < 400) ageLabel = "12 Months";
             else if (diff < 500) ageLabel = "15 Months";
             else if (diff < 600) ageLabel = "18 Months";
             else if (diff < 800) ageLabel = "2 Years";
             else ageLabel = "4-5 Years";

             return Card(
               margin: const EdgeInsets.only(bottom: 16),
               color: isAllDone ? Colors.green.withOpacity(0.15) : null,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Header
                   ListTile(
                     tileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                     title: Text("$ageLabel Visit", style: const TextStyle(fontWeight: FontWeight.bold)),
                     subtitle: Text(DateFormat.yMMMd().format(date)),
                     trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         // Doctor Icon
                         IconButton(
                           icon: const Icon(Icons.medical_services_outlined, color: Colors.teal),
                           tooltip: "Set Doctor",
                           onPressed: () => _showDoctorDialog(context, groupVaccines),
                         ),
                         // Date Icon
                         IconButton(
                           icon: const Icon(Icons.edit_calendar, color: Colors.blue),
                           tooltip: "Reschedule",
                           onPressed: () async {
                             final newDate = await showDatePicker(
                               context: context, 
                               initialDate: date, 
                               firstDate: widget.child.dob, 
                               lastDate: DateTime(2100)
                             );
                             if (newDate != null) {
                               // Update all in group
                               for (var v in groupVaccines) {
                                 ref.read(vaccineRepositoryProvider).updateVaccineDate(v.id, newDate);
                               }
                             }
                           },
                         ),
                       ],
                     ),
                   ),
                   const Divider(height: 1),
                   // Vaccines
                   ...groupVaccines.map((vaccine) => CheckboxListTile(
                     title: Row(
                       children: [
                         Expanded(child: Text(vaccine.vaccineName, style: TextStyle(decoration: vaccine.isDone ? TextDecoration.lineThrough : null))),
                         if (vaccine.doctorName != null && vaccine.doctorName!.isNotEmpty)
                           Chip(
                             label: Text(vaccine.doctorName!, style: const TextStyle(fontSize: 10)), 
                             visualDensity: VisualDensity.compact,
                             padding: EdgeInsets.zero,
                           )
                       ],
                     ),
                     value: vaccine.isDone,
                     onChanged: (val) {
                        if (val != null) {
                           ref.read(vaccineRepositoryProvider).updateVaccineStatus(
                             vaccine.id, 
                             val, 
                             val ? DateTime.now() : null
                           );
                        }
                     },
                     secondary: Icon(Icons.vaccines, size: 20, color: vaccine.isDone ? Colors.green : null),
                   )),
                 ],
               ),
             );
           },
         );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
    );
  }

  void _showDoctorDialog(BuildContext context, List<VaccineModel> vaccines) {
    final controller = TextEditingController(text: vaccines.first.doctorName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set Doctor/Clinic"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Doctor's Name", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                // Update all
                for(var v in vaccines) {
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
}

final vaccinesProvider = StreamProvider.family((ref, ChildModel child) {
  return ref.watch(vaccineRepositoryProvider).getVaccines(child.id, child.parentId);
});
