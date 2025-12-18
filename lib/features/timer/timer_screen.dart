import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 120; // 2 minutes
  int _secondsRemaining = _totalSeconds;
  Timer? _timer;
  bool _isActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Animation
  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    // Brushing Animation (Left <-> Right) -- SLOWER SPEED (1200ms)
    _animController = AnimationController(
       duration: const Duration(milliseconds: 1200),
       vsync: this,
    )..repeat(reverse: true); // Loop back and forth
    
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0.0),
      end: const Offset(0.2, 0.0),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
    
    // Pause initially
    _animController.stop(); 
  }

  void _startTimer() {
    if (_timer != null) return;
    setState(() => _isActive = true);
    
    // Play Music (Slow Melody Lullaby)
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(UrlSource('https://www.orangefreesounds.com/wp-content/uploads/2015/05/Soothing-music-for-kids.mp3')).catchError((e) {
      debugPrint("Error playing audio: $e");
    });

    // Play Animation
    if (!_animController.isAnimating) {
      _animController.repeat(reverse: true);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _stopTimer();
        _showCelebration();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _audioPlayer.stop();
    _animController.stop();
    setState(() => _isActive = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _secondsRemaining = _totalSeconds);
    _animController.reset();
  }

  void _showCelebration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Great Job! 🎉"),
        content: const Text("You brushed for 2 minutes! Your teeth are sparkling clean! ✨"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop(); // Go back to dashboard
            },
            child: const Text("Awesome!"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _animController.dispose();
    super.dispose();
  }

  String get _timerString {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getToothEmoji() {
    final progress = 1 - (_secondsRemaining / _totalSeconds);
    
    if (!_isActive && _secondsRemaining == _totalSeconds) {
      // Not started - show dirty tooth
      return '🦷'; // Will add stains overlay
    } else if (_secondsRemaining == 0) {
      // Completed - show clean smiling tooth
      return '😁'; // Smiling face represents clean teeth
    } else if (progress < 0.5) {
      // First half - still dirty, being cleaned
      return '🦷';
    } else {
      // Second half - getting cleaner
      return '🦷';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Brushing Timer 🦷"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             _stopTimer();
             context.pop();
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Video Area
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                      alignment: Alignment.center,
                      children: [
                         // 1. The Tooth
                         const Text("🦷", style: TextStyle(fontSize: 120)),
                         
                         // 2. The Brush (Animated)
                         SlideTransition(
                           position: _offsetAnimation,
                           child: const Padding(
                             padding: EdgeInsets.only(bottom: 40), // Adjust to be ON the tooth
                             child: Text("🪥", style: TextStyle(fontSize: 80)),
                           ),
                         ),
                         
                         // 3. Bubbles/Sparkles (Optional static for now)
                         if (_isActive)
                            const Positioned(top: 20, right: 40, child: Text("✨", style: TextStyle(fontSize: 30))),
                      ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Timer & Text
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Text(
                    _timerString,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _isActive 
                        ? "Brush in circles! 🔄" 
                        : "Ready to brush? Let's go!",
                      key: ValueKey(_isActive),
                      style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const Spacer(),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isActive && _secondsRemaining != 0)
                        FloatingActionButton.extended(
                          heroTag: 'start_btn',
                          onPressed: _startTimer, 
                          label: const Text("Start Brushing"),
                          icon: const Icon(Icons.play_arrow),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      
                      if (_isActive)
                        FloatingActionButton.extended(
                          heroTag: 'pause_btn',
                          onPressed: _stopTimer, 
                          label: const Text("Pause"),
                          icon: const Icon(Icons.pause),
                          backgroundColor: Colors.orange,
                        ),

                      if (_secondsRemaining != _totalSeconds) ...[
                        const SizedBox(width: 20),
                        FloatingActionButton(
                          heroTag: 'reset_btn',
                          onPressed: _resetTimer,
                          mini: true,
                          backgroundColor: Colors.grey,
                          child: const Icon(Icons.refresh),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
