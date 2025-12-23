import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'models/story_model.dart';
import '../profile/models/child_model.dart';

class StoryPlayerScreen extends StatefulWidget {
  final StoryModel story;
  final ChildModel child;

  const StoryPlayerScreen({
    super.key,
    required this.story,
    required this.child,
  });

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen> {
  late AudioPlayer _audioPlayer;
  int _currentSceneIndex = 0;
  bool _isTamil = true; // Default to Tamil based on user preference
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playCurrentScene();
    
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_currentSceneIndex < widget.story.scenes.length - 1) {
        setState(() {
          _currentSceneIndex++;
        });
        _playCurrentScene();
      } else {
        setState(() {
          _isPlaying = false;
        });
        _showStoryEndDialog();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playCurrentScene() async {
    final scene = widget.story.scenes[_currentSceneIndex];
    final audioPath = _isTamil ? scene.tamilAudio : scene.englishAudio;
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(audioPath));
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint("❌ Audio playback error: $e");
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isTamil = !_isTamil;
    });
    _playCurrentScene();
  }

  void _showStoryEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_isTamil ? "அருமை!" : "Great Job!"),
        content: Text(_isTamil 
          ? "டைமருக்குச் சென்று கேப்டனுடன் பல் துலக்கத் தயாரா?" 
          : "Ready to go to the timer and brush with the hero?"),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(_isTamil ? "பிறகு" : "Later"),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.push('/timer', extra: widget.child);
            },
            child: Text(_isTamil ? "துவங்கு" : "Start Brushing"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.story.scenes[_currentSceneIndex];
    final subtitle = _isTamil ? scene.tamilText : scene.englishText;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.story.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _toggleLanguage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isTamil ? "English 🇬🇧" : "Tamil 🇮🇳",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Hero(
                    tag: 'story_${widget.story.id}',
                    child: Image.asset(
                      scene.imagePath,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      ),
                    ),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                  onPressed: _currentSceneIndex > 0 
                    ? () {
                        setState(() => _currentSceneIndex--);
                        _playCurrentScene();
                      }
                    : null,
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 64),
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.resume();
                    }
                    setState(() => _isPlaying = !_isPlaying);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                  onPressed: _currentSceneIndex < widget.story.scenes.length - 1 
                    ? () {
                        setState(() => _currentSceneIndex++);
                        _playCurrentScene();
                      }
                    : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
