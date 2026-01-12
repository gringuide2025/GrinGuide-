import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HealthyJunkScreen extends StatefulWidget {
  const HealthyJunkScreen({super.key});

  @override
  State<HealthyJunkScreen> createState() => _HealthyJunkScreenState();
}

class _HealthyJunkScreenState extends State<HealthyJunkScreen> {
  int _score = 0;
  int _lives = 3;
  bool _isPlaying = false;
  bool _isGameOver = false;
  _FoodItem? _currentItem;
  Timer? _spawnTimer;

  final Random _random = Random();

  void _startGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _isPlaying = true;
      _isGameOver = false;
      _spawnItem();
    });
  }

  void _spawnItem() {
    if (!_isPlaying) return;
    setState(() {
      _currentItem = _FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isHealthy: _random.nextBool(),
        emoji: _getRandomFoodEmoji(_random.nextBool()),
      );
    });
  }
  
  String _getRandomFoodEmoji(bool healthy) {
    if (healthy) {
      const food = ['🍎', '🥦', '🥕', '🍌', '🍇', '🥑'];
      return food[_random.nextInt(food.length)];
    } else {
      const junk = ['🍭', '🍬', '🍫', '🧁', '🥤', '🍩'];
      return junk[_random.nextInt(junk.length)];
    }
  }

  void _handleDrop(bool isHealthyTarget) {
    if (_currentItem == null) return;
    
    bool correct = _currentItem!.isHealthy == isHealthyTarget;
    
    setState(() {
      if (correct) {
        _score += 10;
      } else {
        _lives--;
        if (_lives <= 0) {
          _isPlaying = false;
          _isGameOver = true;
        }
      }
      _currentItem = null;
    });
    
    if (_isPlaying) {
      Future.delayed(const Duration(milliseconds: 500), _spawnItem);
    }
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.green.shade50,
      appBar: AppBar(
        title: Text("Healthy vs Junk 🍎", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
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
          Column(
            children: [
              // Score HUD
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Score: $_score", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    Row(children: List.generate(3, (index) => Icon(Icons.favorite, color: index < _lives ? Colors.red : Colors.grey))),
                  ],
                ),
              ),
              const Spacer(),
              // Targets
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTarget(true), // Healthy Target
                    _buildTarget(false), // Junk Target
                  ],
                ),
              ),
            ],
          ),
          
          // Draggable Item
          if (_isPlaying && _currentItem != null)
             Align(
              alignment: const Alignment(0, -0.2),
              child: Draggable<bool>(
                data: _currentItem!.isHealthy,
                feedback: _buildFoodCard(_currentItem!.emoji, 1.2),
                childWhenDragging: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), shape: BoxShape.circle)),
                child: _buildFoodCard(_currentItem!.emoji, 1.0),
              ),
            ),

          // Overlay
          if (!_isPlaying)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   if (_isGameOver) ...[
                      const Text("GAME OVER", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      Text("Score: $_score", style: const TextStyle(color: Colors.white, fontSize: 24)),
                      const SizedBox(height: 20),
                    ],
                  ElevatedButton(
                    onPressed: _startGame,
                    child: Text(_isGameOver ? "Try Again" : "Start Sorting"),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Drag Healthy food to the Happy Tooth!\nDrag Junk food to the Trash!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTarget(bool visibleHealthy) {
     return DragTarget<bool>(
       onAccept: (data) => _handleDrop(visibleHealthy),
       builder: (context, candidates, rejected) {
         final isHovering = candidates.isNotEmpty;
         return Transform.scale(
           scale: isHovering ? 1.1 : 1.0,
           child: Container(
             width: 100,
             height: 100,
             decoration: BoxDecoration(
               color: visibleHealthy ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
               borderRadius: BorderRadius.circular(20),
               border: Border.all(color: visibleHealthy ? Colors.green : Colors.red, width: 3),
             ),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(visibleHealthy ? "🦷" : "🗑️", style: const TextStyle(fontSize: 40)),
                 Text(visibleHealthy ? "Healthy" : "Junk", style: TextStyle(fontWeight: FontWeight.bold, color: visibleHealthy ? Colors.green : Colors.red)),
               ],
             ),
           ),
         );
       },
     );
  }

  Widget _buildFoodCard(String emoji, double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 40, decoration: TextDecoration.none)),
      ),
    );
  }
}

class _FoodItem {
  String id;
  bool isHealthy;
  String emoji;
  _FoodItem({required this.id, required this.isHealthy, required this.emoji});
}
