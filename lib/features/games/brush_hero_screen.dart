import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BrushHeroScreen extends StatefulWidget {
  const BrushHeroScreen({super.key});

  @override
  State<BrushHeroScreen> createState() => _BrushHeroScreenState();
}

class _BrushHeroScreenState extends State<BrushHeroScreen> with SingleTickerProviderStateMixin {
  int _score = 0;
  bool _isPlaying = false;
  
  late AnimationController _controller;
  double _targetPosition = 0.0; // 0.0 to 1.0 (Top to Bottom)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleMiss();
        _controller.reset();
        _controller.forward();
      }
    });
    _controller.addListener(() {
      setState(() {
        _targetPosition = _controller.value;
      });
    });
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _isPlaying = true;
    });
    _controller.reset();
    _controller.forward();
  }
  
  void _handleMiss() {
    // Maybe decrease score or life?
  }

  void _handleTap() {
    if (!_isPlaying) return;
    
    // Check if target is in "Hit Zone" (e.g., > 0.8 and < 0.95)
    bool hit = _targetPosition > 0.8 && _targetPosition < 0.95;
    
    if (hit) {
      setState(() {
        _score += 10;
        // Speed up slightly
        _controller.duration = _controller.duration! * 0.95; 
      });
      _showFeedback("Perfect!");
    } else {
      _showFeedback("Miss!");
    }
    
    _controller.reset();
    _controller.forward();
  }
  
  void _showFeedback(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: const Duration(milliseconds: 300)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.purple.shade50,
      appBar: AppBar(
        title: Text("Brush Hero 🎵", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
           Center(
             child: Column(
               children: [
                 Text("Score: $_score", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple.shade300)),
                 const Spacer(),
                 // The "Lane"
                 Container(
                   width: 100,
                   height: 400,
                   decoration: BoxDecoration(
                     color: Colors.black12,
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Stack(
                     alignment: Alignment.topCenter,
                     children: [
                       // Falling Note
                       Positioned(
                         top: _targetPosition * 350, // 350 is max travel distance
                         child: const Icon(Icons.music_note, color: Colors.purple, size: 40),
                       ),
                       
                       // Hit Zone
                       Positioned(
                         bottom: 20,
                         child: Container(
                           width: 60,
                           height: 60,
                           decoration: BoxDecoration(
                             border: Border.all(color: Colors.green, width: 4),
                             shape: BoxShape.circle,
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: 20),
                 
                 // Tap Button
                 SizedBox(
                   width: 200,
                   height: 80,
                   child: ElevatedButton(
                     onPressed: _handleTap,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.purple,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                     ),
                     child: const Text("BRUSH!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                   ),
                 ),
                 const SizedBox(height: 50),
               ],
             ),
           ),
           
           if (!_isPlaying)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: ElevatedButton(onPressed: _startGame, child: const Text("Start Music")),
            ),
        ],
      ),
    );
  }
}
