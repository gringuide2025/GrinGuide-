import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SugarWarScreen extends StatefulWidget {
  const SugarWarScreen({super.key});

  @override
  State<SugarWarScreen> createState() => _SugarWarScreenState();
}

class _SugarWarScreenState extends State<SugarWarScreen> {
  int _score = 0;
  bool _isPlaying = false;
  bool _isGameOver = false;
  
  final List<_SugarCube> _cubes = [];
  final List<_Bullet> _bullets = [];
  
  Timer? _gameLoop;
  Timer? _spawner;
  
  // Cannon
  double _cannonAngle = 0; // Radians, straight up is -pi/2? No, let's say 0 is up.
  
  void _startGame() {
    setState(() {
      _score = 0;
      _isPlaying = true;
      _isGameOver = false;
      _cubes.clear();
      _bullets.clear();
    });
    
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), _updateGame);
    _spawner = Timer.periodic(const Duration(milliseconds: 1500), (t) {
      if (_isPlaying) _spawnCube();
    });
  }
  
  void _spawnCube() {
    // Random X at top
    final x = Random().nextDouble() * MediaQuery.of(context).size.width;
    setState(() {
      _cubes.add(_SugarCube(id: DateTime.now().millisecondsSinceEpoch, x: x, y: -50));
    });
  }
  
  void _shoot(TapDownDetails details) {
    if (!_isPlaying) return;
    
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final cannonX = screenW / 2;
    final cannonY = screenH - 100;
    
    // Calculate angle to touch point
    final dx = details.localPosition.dx - cannonX;
    final dy = details.localPosition.dy - cannonY;
    final angle = atan2(dy, dx);
    
    setState(() {
      _cannonAngle = angle;
      _bullets.add(_Bullet(x: cannonX, y: cannonY, angle: angle));
    });
  }
  
  void _updateGame(Timer timer) {
    if (!_isPlaying) return;
    
    setState(() {
      // 1. Move Bullets
      for (var b in _bullets) {
        b.x += cos(b.angle) * 10;
        b.y += sin(b.angle) * 10;
      }
      _bullets.removeWhere((b) => b.y < -50 || b.x < -50 || b.x > 1000); // Off screen
      
      // 2. Move Cubes
      for (var c in _cubes) {
        c.y += 2.0; // Slow fall
      }
      
      // 3. Collision Logic
      // Bullet vs Cube
      for (var b in List.of(_bullets)) {
        for (var c in List.of(_cubes)) {
          if ((b.x - c.x).abs() < 40 && (b.y - c.y).abs() < 40) {
            // Hit!
            b.active = false;
            c.active = false;
            _score += 10;
          }
        }
      }
      _bullets.removeWhere((b) => !b.active);
      _cubes.removeWhere((c) => !c.active);
      
      // Cube Hit Bottom (Game Over)
      for (var c in _cubes) {
        if (c.y > MediaQuery.of(context).size.height - 150) {
          _gameOver();
        }
      }
    });
  }
  
  void _gameOver() {
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
    _gameLoop?.cancel();
    _spawner?.cancel();
  }
  
  @override
  void dispose() {
    _gameLoop?.cancel();
    _spawner?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cannonX = size.width / 2;
    final cannonY = size.height - 100;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: GestureDetector(
        onTapDown: _shoot,
        child: Stack(
          children: [
            // Background
            
            // Bullets
            ..._bullets.map((b) => Positioned(
              left: b.x, top: b.y, 
              child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle)),
            )),
            
            // Cubes
            ..._cubes.map((c) => Positioned(
              left: c.x, top: c.y,
              child: const Text("⬜", style: TextStyle(fontSize: 30)), // Sugar Cube
            )),
            
            // Cannon (Toothpaste Tube)
            Positioned(
              left: cannonX - 25,
              top: cannonY - 25,
              child: Transform.rotate(
                angle: _cannonAngle + pi / 2, // Adjust emoji rotation
                child: const Text("🧴", style: TextStyle(fontSize: 50)),
              ),
            ),
            
            // Base / Tooth Line
            Positioned(
              bottom: 0,
              width: size.width,
              height: 80,
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: const Text("PROTECT THE TEETH!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
            ),
            
            // HUD
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => context.pop()),
                     Text("Score: $_score", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                   ],
                ),
              ),
            ),
            
            if (!_isPlaying)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("SUGAR WAR 🛡️", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text("Tap to Shoot!\nDon't let sugar hit the teeth.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _startGame, child: Text(_isGameOver ? "Replay" : "Start Defense")),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SugarCube {
  int id;
  double x;
  double y;
  bool active = true;
  _SugarCube({required this.id, required this.x, required this.y});
}

class _Bullet {
  double x;
  double y;
  double angle;
  bool active = true;
  _Bullet({required this.x, required this.y, required this.angle});
}
