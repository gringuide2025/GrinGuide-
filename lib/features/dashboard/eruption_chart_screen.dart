import 'package:flutter/material.dart';

class EruptionChartScreen extends StatefulWidget {
  const EruptionChartScreen({super.key});

  @override
  State<EruptionChartScreen> createState() => _EruptionChartScreenState();
}

class _EruptionChartScreenState extends State<EruptionChartScreen> {
  // 0 = Primary, 1 = Permanent
  int _tabIndex = 0;

  final List<Map<String, String>> primaryUpper = [
    {'name': 'Central Incisor', 'erupt': '8-12 mos'},
    {'name': 'Lateral Incisor', 'erupt': '9-13 mos'},
    {'name': 'Canine (Cuspid)', 'erupt': '16-22 mos'},
    {'name': 'First Molar', 'erupt': '13-19 mos'},
    {'name': 'Second Molar', 'erupt': '25-33 mos'},
  ];

  final List<Map<String, String>> primaryLower = [
    {'name': 'Second Molar', 'erupt': '23-31 mos'},
    {'name': 'First Molar', 'erupt': '14-18 mos'},
    {'name': 'Canine (Cuspid)', 'erupt': '17-23 mos'},
    {'name': 'Lateral Incisor', 'erupt': '10-16 mos'},
    {'name': 'Central Incisor', 'erupt': '6-10 mos'},
  ];

  final List<Map<String, String>> permanentUpper = [
    {'name': 'Central Incisor', 'erupt': '7-8 yrs'},
    {'name': 'Lateral Incisor', 'erupt': '8-9 yrs'},
    {'name': 'Canine (Cuspid)', 'erupt': '11-12 yrs'},
    {'name': 'First Premolar', 'erupt': '10-11 yrs'},
    {'name': 'Second Premolar', 'erupt': '10-12 yrs'},
    {'name': 'First Molar', 'erupt': '6-7 yrs'},
    {'name': 'Second Molar', 'erupt': '12-13 yrs'},
    {'name': 'Third Molar', 'erupt': '17-21 yrs'},
  ];

  final List<Map<String, String>> permanentLower = [
    {'name': 'Third Molar', 'erupt': '17-21 yrs'},
    {'name': 'Second Molar', 'erupt': '11-13 yrs'},
    {'name': 'First Molar', 'erupt': '6-7 yrs'},
    {'name': 'Second Premolar', 'erupt': '11-12 yrs'},
    {'name': 'First Premolar', 'erupt': '10-12 yrs'},
    {'name': 'Canine', 'erupt': '9-10 yrs'},
    {'name': 'Lateral Incisor', 'erupt': '7-8 yrs'},
    {'name': 'Central Incisor', 'erupt': '6-7 yrs'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eruption Chart 🦷"),
      ),
      body: Column(
        children: [
          // Toggle
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                _buildTab("Baby Teeth", 0),
                _buildTab("Adult Teeth", 1),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display tooth diagram image
                  Card(
                    elevation: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _tabIndex == 0 
                          ? 'assets/images/baby_teeth_diagram.png'
                          : 'assets/images/permanent_teeth_diagram.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Image not available'),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    "Detailed Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader("Upper Jaw (Top)"),
                  _buildTable(_tabIndex == 0 ? primaryUpper : permanentUpper),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Lower Jaw (Bottom)"),
                  _buildTable(_tabIndex == 0 ? primaryLower : permanentLower),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title, 
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)
      ),
    );
  }

  Widget _buildTable(List<Map<String, String>> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade200)),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFF3E5F5)),
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text("Tooth", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
                Padding(padding: EdgeInsets.all(8.0), child: Text("Erupts", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
              ],
            ),
            ...data.map((item) {
              return TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item['name']!)),
                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item['erupt']!, style: const TextStyle(color: Colors.green))),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
