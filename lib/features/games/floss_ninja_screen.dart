import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FlossNinjaScreen extends StatefulWidget {
  const FlossNinjaScreen({super.key});

  @override
  State<FlossNinjaScreen> createState() => _FlossNinjaScreenState();
}

class _FlossNinjaScreenState extends State<FlossNinjaScreen> with SingleTickerProviderStateMixin {
  int _score = 0;
  int _lives = 3;
  bool _isPlaying = false;
  bool _isGameOver = false;
  
  final List<_FlyingItem> _items = [];
  final List<Offset> _trailPoints = [];
  Timer? _gameLoop;
  Timer? _spawner;
  final Random _random = Random();

  @override
  void dispose() {
    _gameLoop?.cancel();
    _spawner?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _isPlaying = true;
      _isGameOver = false;
      _items.clear();
      _trailPoints.clear();
    });

    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), _updateGame);
    _spawner = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_isPlaying) _spawnItem();
    });
  }
  
  void _spawnItem() {
    // Spawn from bottom
    final isCandy = _random.nextBool(); // 50/50 chance
    // Random emoji
    final emoji = isCandy 
        ? ['🍬', '🍭', '🍫', '🍩'][_random.nextInt(4)]
        : ['🍎', '🥦', '🥕', '🍌'][_random.nextInt(4)];
        
    final startX = 50 + _random.nextDouble() * 300; // Random X
    final startY = 700.0; // Bottom (approx)
    
    // Velocity: Upwards and slightly sideways towards center
    final dx = (200 - startX) * 0.01 + (_random.nextDouble() - 0.5) * 2;
    final dy = -10.0 - _random.nextDouble() * 5; // Upward force
    
    setState(() {
      _items.add(_FlyingItem(
        id: DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000),
        x: startX,
        y: startY,
        dx: dx,
        dy: dy,
        emoji: emoji,
        isCandy: isCandy,
      ));
    });
  }

  void _updateGame(Timer timer) {
    if (!_isPlaying) return;

    setState(() {
      // 1. Update Physics
      for (var item in _items) {
        item.dy += 0.2; // Gravity
        item.x += item.dx;
        item.y += item.dy;
        item.rotation += 0.05;
      }
      
      // 2. Remove Off-screen
      _items.removeWhere((item) => item.y > 800); // Fell off bottom

      // 3. Update Trail (Fade out old points)
      if (_trailPoints.length > 15) {
        _trailPoints.removeAt(0);
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isPlaying) return;

    final pos = details.localPosition;
    setState(() {
      _trailPoints.add(pos);
      _checkSlice(pos);
    });
  }

  void _checkSlice(Offset touchPos) {
    for (var item in List.of(_items)) {
      if (item.sliced) continue;
      
      // Simple distance check
      final dx = touchPos.dx - item.x;
      final dy = touchPos.dy - item.y;
      final dist = sqrt(dx*dx + dy*dy);
      
      if (dist < 40) { // Hit radius
        setState(() {
          item.sliced = true;
          if (item.isCandy) {
            _score += 10;
            // Maybe split animation logic later
            _items.remove(item);
          } else {
            // Sliced healthy food! Oh no!
            _lives--;
            _items.remove(item);
            if (_lives <= 0) _gameOver();
          }
        });
      }
    }
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.cyan.shade50,
      body: Stack(
        children: [
          // Background - Maybe some faint Dojo pattern
          
          // Game Area with Gesture Detector
          GestureDetector(
            onPanStart: (d) => _onPanUpdate(DragUpdateDetails(localPosition: d.localPosition, globalPosition: d.globalPosition)),
            onPanUpdate: _onPanUpdate,
            child: Container(
              color: Colors.transparent, // Capture touches everywhere
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: _GamePainter(_items, _trailPoints, isDark),
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
                  // Back Button logic if needed, but gestures might conflict. 
                  // Let's put a small back button top left
                   IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black, shadows: const [Shadow(color: Colors.white, blurRadius: 10)]),
                    onPressed: () => context.pop(),
                  ),
                  Text("Score: $_score", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                  Row(children: List.generate(3, (index) => Icon(Icons.favorite, color: index < _lives ? Colors.red : Colors.grey))),
                ],
              ),
            ),
          ),
          
          // Game Over / Start Overlay
          if (!_isPlaying)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("FLOSS NINJA 🥷", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Slice the CANDY 🍬\nSave the APPLES 🍎", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 30),
                  if (_isGameOver) ...[
                    Text("Game Over!", style: const TextStyle(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
                    Text("Final Score: $_score", style: const TextStyle(color: Colors.white, fontSize: 24)),
                    const SizedBox(height: 20),
                  ],
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), backgroundColor: Colors.orange),
                    child: const Text("START SLICING", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FlyingItem {
  int id;
  double x;
  double y;
  double dx;
  double dy;
  String emoji;
  bool isCandy;
  double rotation = 0;
  bool sliced = false;

  _FlyingItem({required this.id, required this.x, required this.y, required this.dx, required this.dy, required this.emoji, required this.isCandy});
}

class _GamePainter extends CustomPainter {
  final List<_FlyingItem> items;
  final List<Offset> trail;
  final bool isDark;

  _GamePainter(this.items, this.trail, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Trail
    final trailPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    // Make trail look glowing?
    final path = Path();
    if (trail.isNotEmpty) {
      path.moveTo(trail.first.dx, trail.first.dy);
      for (var p in trail) path.lineTo(p.dx, p.dy);
      canvas.drawPath(path, trailPaint);
    }
    
    // Draw Items
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    for (var item in items) {
      if (item.sliced) continue; // Don't draw if sliced (removed in logic, but safety check)
      
      textPainter.text = TextSpan(text: item.emoji, style: const TextStyle(fontSize: 50));
      textPainter.layout();
      
      canvas.save();
      canvas.translate(item.x, item.y);
      canvas.rotate(item.rotation);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
