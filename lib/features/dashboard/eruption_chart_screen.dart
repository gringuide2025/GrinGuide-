import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EruptionChartScreen extends StatefulWidget {
  const EruptionChartScreen({super.key});

  @override
  State<EruptionChartScreen> createState() => _EruptionChartScreenState();
}

class _EruptionChartScreenState extends State<EruptionChartScreen> {
  // 0 = Primary, 1 = Permanent
  int _tabIndex = 0;
  Set<String> _eruptedTeeth = {};

  @override
  void initState() {
    super.initState();
    _loadEruptedTeeth();
  }

  Future<void> _loadEruptedTeeth() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('erupted_teeth') ?? [];
    setState(() {
      _eruptedTeeth = list.toSet();
    });
  }

  Future<void> _saveEruptedTeeth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('erupted_teeth', _eruptedTeeth.toList());
  }

  void _toggleErupted(String toothName) {
    setState(() {
      if (_eruptedTeeth.contains(toothName)) {
        _eruptedTeeth.remove(toothName);
      } else {
        _eruptedTeeth.add(toothName);
      }
    });
    _saveEruptedTeeth();
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Custom Premium Header
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10, 
                  bottom: 15
                ),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).iconTheme.color),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Eruption Chart 🦷",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Toggle
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    _buildTab("Baby Teeth", 0),
                    _buildTab("Adult Teeth", 1),
                  ],
                ),
              ),

              // Content Area
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display tooth diagram image
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 360, 
                          width: double.infinity,
                          color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
                          child: InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 3.0,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/teeth_chart.png',
                                    filterQuality: FilterQuality.high,
                                    height: 320, 
                                  ),
                                  const Text("Pinch to zoom chart", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      "Detailed Information",
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.w900, 
                        color: Theme.of(context).primaryColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader("Upper Jaw (Top)"),
                    _buildTable(_tabIndex == 0 ? primaryUpper : permanentUpper),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Lower Jaw (Bottom)"),
                    _buildTable(_tabIndex == 0 ? primaryLower : permanentLower),
                    const SizedBox(height: 80), // Padding for bottom
                  ],
                ),
              ),
            ],
          ),
        ),
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
          boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
          gradient: isSelected 
            ? LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withBlue(255)]) 
            : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.grey.shade700),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
        ),
        child: Text(
          title, 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.black, color: Theme.of(context).primaryColor, letterSpacing: 0.5)
        ),
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
            2: FlexColumnWidth(0.8),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text("Tooth", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
                Padding(padding: EdgeInsets.all(8.0), child: Text("Erupts", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
                Padding(padding: EdgeInsets.all(8.0), child: Text("Got it?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
              ],
            ),
            ...data.map((item) {
              final isErupted = _eruptedTeeth.contains(item['name']!);
              return TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item['name']!)),
                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item['erupt']!, style: const TextStyle(color: Colors.green))),
                  Checkbox(
                    value: isErupted,
                    onChanged: (_) => _toggleErupted(item['name']!),
                    activeColor: Colors.purple,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
