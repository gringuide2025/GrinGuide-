import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaqueAttackScreen extends StatefulWidget {
  const PlaqueAttackScreen({super.key});

  @override
  State<PlaqueAttackScreen> createState() => _PlaqueAttackScreenState();
}

class _PlaqueAttackScreenState extends State<PlaqueAttackScreen> with SingleTickerProviderStateMixin {
  int _score = 0;
  int _lives = 3;
  bool _isPlaying = false;
  bool _isGameOver = false;
  
  final List<_Germ> _germs = [];
  Timer? _spawnTimer;
  Timer? _gameLoopTimer;
  final Random _random = Random();
  
  // Game Difficulty configuration
  double _spawnRate = 1000; // ms
  double _germSpeed = 1.0;

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameLoopTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _isPlaying = true;
      _isGameOver = false;
      _germs.clear();
      _spawnRate = 1000;
    });

    _scheduleSpawn();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 50), _updateGame);
  }

  void _scheduleSpawn() {
    _spawnTimer = Timer(Duration(milliseconds: _spawnRate.toInt()), () {
      if (_isPlaying) {
        _spawnGerm();
        // Increase difficulty
        if (_spawnRate > 400) _spawnRate *= 0.98;
        _scheduleSpawn();
      }
    });
  }

  void _spawnGerm() {
    setState(() {
      // Random position (assuming a 300x400 play area for simplicity, clamped later)
      _germs.add(_Germ(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        x: _random.nextDouble() * 300, 
        y: _random.nextDouble() * 400,
        type: _random.nextInt(3), // 0: Green, 1: Purple, 2: Red
        scale: 0.0,
      ));
    });
  }

  void _updateGame(Timer timer) {
    if (!_isPlaying) return;

    setState(() {
      // Grow germs
      for (var germ in _germs) {
        if (germ.scale < 1.0) germ.scale += 0.05;
        
        // Germs disappear after a while (damage player?)
        // For this simple version, let's keep them until tapped or if we want "missed" mechanic
        // Let's make them fade out or damage if they get too big/stay too long?
        // Simplest: If too many germs accumulate (e.g. > 10), game over?
        // OR: Germs strictly stay until tapped.
      }
      
      // Lose condition: Too many germs?
      if (_germs.length >= 10) {
        _lives--;
        _germs.clear(); // Clear screen for a breather
        if (_lives <= 0) _gameOver();
      }
    });
  }

  void _handleTap(String id) {
    setState(() {
      _germs.removeWhere((g) => g.id == id);
      _score += 10;
    });
  }

  void _gameOver() {
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
    _spawnTimer?.cancel();
    _gameLoopTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.lightBlue.shade50,
      appBar: AppBar(
        title: Text(
          "Plaque Attack! 🦠",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background "Tooth" Surface
          Center(
            child: Container(
              width: 350,
              height: 500,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : const Color(0xFFF9F9F9), // Creamy white
                borderRadius: BorderRadius.circular(100), // Tooth-ish shape
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.blue.withOpacity(0.5),
                  width: 4,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Stack(
                  children: [
                    // Play Area
                    if (_isPlaying || _isGameOver)
                      ..._germs.map((germ) => Positioned(
                        left: germ.x,
                        top: germ.y,
                        child: GestureDetector(
                          onTap: () => _handleTap(germ.id),
                          child: Transform.scale(
                            scale: germ.scale,
                            child: _buildGerm(germ.type),
                          ),
                        ),
                      )),
                      
                    // Start/Game Over Overlay
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
                            ElevatedButton.icon(
                              onPressed: _startGame,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(_isGameOver ? "Try Again" : "Start Cleaning!"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (!_isGameOver)
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  "Tap the germs before they swarm the tooth!\nDon't let more than 10 accumulate!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: Text("Score: $_score", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                  ),
                  Row(
                    children: List.generate(3, (index) => Icon(
                      Icons.favorite, 
                      color: index < _lives ? Colors.red : Colors.grey,
                      size: 28,
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGerm(int type) {
    // Simple icon-based germs for minimal asset usage
    final Color color;
    switch(type) {
      case 0: color = Colors.green; break;
      case 1: color = Colors.purple; break;
      case 2: color = Colors.orange; break;
      default: color = Colors.grey;
    }
    
    return Container(
      width: 50, 
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Icon(Icons.bug_report_rounded, color: color, size: 45),
    );
  }
}

class _Germ {
  String id;
  double x;
  double y;
  int type;
  double scale;

  _Germ({required this.id, required this.x, required this.y, required this.type, required this.scale});
}
