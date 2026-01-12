import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- GAME 6: CAVITY HUNTER ---
class CavityHunterScreen extends StatefulWidget {
  const CavityHunterScreen({super.key});

  @override
  State<CavityHunterScreen> createState() => _CavityHunterScreenState();
}

class _CavityHunterScreenState extends State<CavityHunterScreen> {
  int _score = 0;
  List<Offset> _germPositions = [];
  bool _isPlaying = false;
  Offset _torchPos = const Offset(100, 100);

  void _startGame() {
    setState(() {
      _score = 0;
      _isPlaying = true;
      _germPositions = List.generate(5, (_) => Offset(
         Random().nextDouble() * 300 + 20, 
         Random().nextDouble() * 500 + 100
      ));
    });
  }

  void _checkTap(TapDownDetails details) {
    if (!_isPlaying) return;
    final pos = details.localPosition;
    
    // Check if tapped on a germ
    int hitIndex = -1;
    for (int i = 0; i < _germPositions.length; i++) {
      if ((pos - _germPositions[i]).distance < 40) {
        hitIndex = i;
        break;
      }
    }
    
    if (hitIndex != -1) {
      setState(() {
        _score++;
        _germPositions.removeAt(hitIndex);
        _germPositions.add(Offset(Random().nextDouble() * 300 + 20, Random().nextDouble() * 500 + 100)); // Respawn
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Got one!"), duration: Duration(milliseconds: 300)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (d) => setState(() => _torchPos = d.localPosition),
      onTapDown: _checkTap,
      child: Scaffold(
        backgroundColor: Colors.black, // Dark mouth
        body: Stack(
          children: [
            // Safe Area / HUD
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => context.pop()),
                    Text("Score: $_score", style: const TextStyle(color: Colors.white, fontSize: 24)),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
            
            if (_isPlaying)
              // Torch Mask Logic (Simplified for Flutter: ColorFilter or ClipPath is heavy, using simpler Overlay approach)
              // Actually complex masking is hard. Let's do a "Lantern" overlay.
              CustomPaint(
                painter: _FlashlightPainter(_torchPos, _germPositions),
                child: Container(),
              ),
              
             if (!_isPlaying)
               Center(
                 child: ElevatedButton(onPressed: _startGame, child: const Text("Start Hunting")),
               )
          ],
        ),
      ),
    );
  }
}

class _FlashlightPainter extends CustomPainter {
  final Offset pos;
  final List<Offset> germs;
  _FlashlightPainter(this.pos, this.germs);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill black
    final bg = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, bg);
    
    // 2. Clear circle at torch pos (The "Light")
    final lightRadius = 100.0;
    canvas.saveLayer(Offset.zero & size, Paint()); // New layer
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black); // Dark again
    
    // Cut out circle
    canvas.drawCircle(pos, lightRadius, Paint()..blendMode = BlendMode.clear);
    
    // Draw visible germs inside the light? 
    // Actually, simpler: Draw germs first, then cover everything with black excluding the circle.
    canvas.restore();
    
    // Okay, let's do: Draw all germs. Then draw a huge black rect with a hole.
    for (var g in germs) {
      final textPainter = TextPainter(text: const TextSpan(text: "🦠", style: TextStyle(fontSize: 40)), textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, g - const Offset(20, 20));
    }
    
    // The Mask
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: pos, radius: lightRadius))
      ..fillType = PathFillType.evenOdd;
      
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.95));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- GAME 7: BACTERIA BOUNCE (Pong) ---
class BacteriaBounceScreen extends StatefulWidget {
  const BacteriaBounceScreen({super.key});
  @override
  State<BacteriaBounceScreen> createState() => _BacteriaBounceScreenState();
}
class _BacteriaBounceScreenState extends State<BacteriaBounceScreen> with SingleTickerProviderStateMixin {
  // Simple Pong Logic
  double _ballX = 0, _ballY = 0;
  double _ballDX = 2, _ballDY = 4;
  double _paddleX = 0;
  List<Rect> _bricks = [];
  bool _isPlaying = false;
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _controller.addListener(_update);
  }
  
  void _start() {
    _bricks = List.generate(10, (i) => Rect.fromLTWH((i % 5) * 70.0 + 20, (i ~/ 5) * 40.0 + 100, 60, 30));
    _ballX = 200; _ballY = 400;
    _isPlaying = true;
  }
  
  void _update() {
    if (!_isPlaying) return;
    setState(() {
      _ballX += _ballDX;
      _ballY += _ballDY;
      
      // Walls
      if (_ballX < 0 || _ballX > 350) _ballDX *= -1;
      if (_ballY < 0) _ballDY *= -1;
      
      // Paddle
      if (_ballY > 600 && (_ballX - _paddleX).abs() < 50) _ballDY *= -1;
      
      // Bricks
      for (int i=0; i<_bricks.length; i++) {
        if (_bricks[i].contains(Offset(_ballX, _ballY))) {
          _bricks.removeAt(i);
          _ballDY *= -1;
          break;
        }
      }
      
      // Loss
      if (_ballY > 800) _isPlaying = false;
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (d) => setState(() => _paddleX += d.delta.dx),
      child: Scaffold(
        backgroundColor: Colors.blue.shade900,
        body: Stack(
          children: [
             if (!_isPlaying) Center(child: ElevatedButton(onPressed: _start, child: const Text("Start Bouncing"))),
             
             // Paddle
             Positioned(bottom: 50, left: _paddleX, child: Container(width: 100, height: 20, color: Colors.white)),
             
             // Ball
             Positioned(left: _ballX, top: _ballY, child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle))),
             
             // Bricks
             ..._bricks.map((b) => Positioned(left: b.left, top: b.top, child: Container(width: b.width, height: b.height, color: Colors.green))),
             
             SafeArea(child: BackButton(color: Colors.white, onPressed: () => context.pop())),
          ],
        ),
      ),
    );
  }
}

// --- GAME 8: SMILES IN SPACE ---
// Very simple vertical scroller implementation
class SmilesInSpaceScreen extends StatefulWidget {
  const SmilesInSpaceScreen({super.key});
  @override
  State<SmilesInSpaceScreen> createState() => _SmilesInSpaceScreenState();
}
class _SmilesInSpaceScreenState extends State<SmilesInSpaceScreen> {
  double _shipX = 0.0; // -1 to 1
  List<Offset> _asteroids = []; 
  bool _isPlaying = false;
  int _score = 0;
  
  void _start() {
     _isPlaying = true;
     _score = 0;
     Timer.periodic(const Duration(milliseconds: 30), (t) {
        if (!mounted || !_isPlaying) { t.cancel(); return; }
        setState(() {
          // Spawn
          if (Random().nextDouble() < 0.1) _asteroids.add(Offset(Random().nextDouble() * 2 - 1, -1.2));
          // Move
          for(int i=0; i<_asteroids.length; i++) {
             _asteroids[i] += const Offset(0, 0.05);
          }
           // Collide
          for(var a in _asteroids) {
            if ((a.dy - 0.8).abs() < 0.1 && (a.dx - _shipX).abs() < 0.3) {
              _isPlaying = false;
            }
          }
          if (_isPlaying) _score++;
        });
     });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) => setState(() => _shipX = d.globalPosition.dx > MediaQuery.of(context).size.width/2 ? 0.5 : -0.5),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Stars bg
            ...List.generate(20, (i) => Align(alignment: Alignment(Random().nextDouble()*2-1, Random().nextDouble()*2-1), child: const Text("." , style: TextStyle(color: Colors.white)))),
            
            // Ship
            Align(alignment: Alignment(_shipX, 0.8), child: const Text("🚀", style: TextStyle(fontSize: 40))),
             
            // Asteroids
            ..._asteroids.map((a) => Align(alignment: Alignment(a.dx, a.dy), child: const Text("🪨", style: TextStyle(fontSize: 30)))),
             
            if (!_isPlaying) Center(child: ElevatedButton(onPressed: _start, child: Text("Fly! Score: $_score"))),
             SafeArea(child: BackButton(color: Colors.white, onPressed: () => context.pop())),
          ],
        ),
      ),
    );
  }
}

// --- GAME 9: GERM WHACK ---
class GermWhackScreen extends StatefulWidget {
  const GermWhackScreen({super.key});
  @override
  State<GermWhackScreen> createState() => _GermWhackState();
}

class _GermWhackState extends State<GermWhackScreen> {
  int _score = 0;
  List<bool> _holes = List.filled(9, false); // 3x3 grid
  Timer? _timer;
  
  void _start() {
    _score = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _holes = List.filled(9, false);
        _holes[Random().nextInt(9)] = true;
      });
    });
  }
  
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(title: const Text("Whack a Germ 🔨"), centerTitle: true),
      body: Column(
        children: [
          Text("Score: $_score", style: const TextStyle(fontSize: 30)),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (_holes[index]) {
                      setState(() { _score++; _holes[index] = false; });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                    child: _holes[index] ? const Center(child: Text("🦠", style: TextStyle(fontSize: 40))) : null,
                  ),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: _start, child: const Text("Start")),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

// --- GAME 10: SPARKLE PAINTER ---
class SparklePainterScreen extends StatefulWidget {
  const SparklePainterScreen({super.key});
  @override
  State<SparklePainterScreen> createState() => _SparklePainterState();
}
class _SparklePainterState extends State<SparklePainterScreen> {
  Color _selectedColor = Colors.blue;
  // Simplified coloring: Only 3 sections
  Color _c1 = Colors.white, _c2 = Colors.white, _c3 = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sparkle Painter 🎨"), centerTitle: true),
      body: Column(
        children: [
           Expanded(
             child: Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   GestureDetector(onTap: () => setState(() => _c1 = _selectedColor), child: Container(width: 100, height: 100, color: _c1, child: const Center(child: Text("Tooth Body")))),
                   GestureDetector(onTap: () => setState(() => _c2 = _selectedColor), child: Container(width: 100, height: 50, color: _c2, child: const Center(child: Text("Gums")))),
                   GestureDetector(onTap: () => setState(() => _c3 = _selectedColor), child: Container(width: 50, height: 50, color: _c3, child: const Center(child: Text("Hat")))),
                 ],
               ),
             ),
           ),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.purple].map((c) => 
               GestureDetector(onTap: () => setState(() => _selectedColor = c), child: Container(
                 width: 50, 
                 height: 50, 
                 decoration: BoxDecoration(
                   color: c, 
                   border: _selectedColor == c ? Border.all(width: 3, color: Colors.black) : null
                 ),
               ))
             ).toList(),
           ),
           const SizedBox(height: 50),
        ],
      ),
    );
  }
}
