import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ToothFairyScreen extends StatefulWidget {
  const ToothFairyScreen({super.key});

  @override
  State<ToothFairyScreen> createState() => _ToothFairyScreenState();
}

class _ToothFairyScreenState extends State<ToothFairyScreen> {
  // Simple logic: Fairy Y position. Obstacles X position.
  double _fairyY = 0.0; // -1.0 to 1.0 (Top to Bottom)
  double _velocity = 0.0;
  List<_Obstacle> _obstacles = [];
  bool _isPlaying = false;
  int _score = 0;
  Timer? _gameLoop;
  
  void _startGame() {
    setState(() {
      _fairyY = 0.0;
      _velocity = 0.0;
      _score = 0;
      _obstacles.clear();
      _isPlaying = true;
    });
    _gameLoop = Timer.periodic(const Duration(milliseconds: 30), _updateGame);
  }
  
  void _jump() {
    setState(() {
      _velocity = -0.05; // Jump up
    });
  }
  
  void _updateGame(Timer timer) {
    if (!_isPlaying) return;
    
    setState(() {
      // Physics
      _velocity += 0.003; // Gravity
      _fairyY += _velocity;
      
      // Bounds
      if (_fairyY > 1.1 || _fairyY < -1.1) {
        _endGame();
      }
      
      // Spawn Obstacles
      if (Random().nextDouble() < 0.05) {
        _obstacles.add(_Obstacle(x: 1.5, y: Random().nextDouble() * 2 - 1, isCoin: Random().nextBool()));
      }
      
      // Move Obstacles
      for (var ob in _obstacles) {
        ob.x -= 0.03; 
      }
      // Remove off-screen
      _obstacles.removeWhere((ob) => ob.x < -1.5);
      
      // Collisions
      for (var ob in _obstacles) {
        // Simple AABB
        if ((ob.x - 0).abs() < 0.2 && (ob.y - _fairyY).abs() < 0.2) {
          if (ob.isCoin) {
             _score++;
             ob.x = -100; // Remove
          } else {
             _endGame();
          }
        }
      }
    });
  }
  
  void _endGame() {
    _isPlaying = false;
    _gameLoop?.cancel();
    setState(() {});
  }
  
  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isPlaying ? _jump : null,
      child: Scaffold(
        backgroundColor: Colors.indigo.shade900,
        appBar: AppBar(
          title: const Text("Tooth Fairy Run 🧚‍♀️", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Stack(
          children: [
            // Fairy
            Align(
              alignment: Alignment(-0.5, _fairyY),
              child: const Text("🧚‍♀️", style: TextStyle(fontSize: 40)),
            ),
            
            // Obstacles
            ..._obstacles.map((ob) => Align(
              alignment: Alignment(ob.x, ob.y),
              child: Text(ob.isCoin ? "🦷" : "🍭", style: const TextStyle(fontSize: 30)),
            )),
            
            // Score
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("Teeth: $_score", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            
            if (!_isPlaying)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Game Over\nScore: $_score", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 30)),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _startGame, child: const Text("Fly Again")),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _Obstacle {
  double x;
  double y;
  bool isCoin;
  _Obstacle({required this.x, required this.y, required this.isCoin});
}
