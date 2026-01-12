import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
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
  int _currentSceneIndex = 0;
  bool _isTamil = true; // Default to Tamil based on user preference
  bool _isPlaying = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      _onAudioComplete();
    });
    
    // Start playing first scene
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playCurrentScene();
    });
  }

  void _onAudioComplete() {
    if (_currentSceneIndex < widget.story.scenes.length - 1) {
      if (mounted) {
        setState(() {
          _currentSceneIndex++;
        });
        _playCurrentScene();
      }
    } else {
      if (mounted) {
        setState(() => _isPlaying = false);
        _showStoryEndDialog();
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playCurrentScene() async {
    final scene = widget.story.scenes[_currentSceneIndex];
    final audioPath = _isTamil ? scene.tamilAudio : scene.englishAudio;

    debugPrint("🎵 Attempting to play audio: $audioPath");

    try {
      await _audioPlayer.stop();
      setState(() => _isPlaying = true);
      
      // AssetSource starts from 'assets/' folder level
      // Using setSource + resume for more control/debug
      await _audioPlayer.setSource(AssetSource(audioPath));
      await _audioPlayer.resume();
      
      debugPrint("✅ Audio started playing");
    } catch (e) {
      debugPrint("❌ Error playing audio ($audioPath): $e");
      setState(() => _isPlaying = false);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.story.title, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
        actions: [
          TextButton(
            onPressed: _toggleLanguage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45, // Simi-transparent dark for better contrast
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
        child: Column(
          children: [
            const SizedBox(height: 100),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'story_${widget.story.id}',
                      child: Image.asset(
                        scene.imagePath,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    // Adaptive background: Darker in Dark Mode, White with shadow in Light Mode
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.black54 
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: Theme.of(context).brightness == Brightness.light 
                        ? [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))] 
                        : null,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // Adaptive Text: White in Dark Mode, Black in Light Mode
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, 
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
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
                  icon: Icon(Icons.skip_previous, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87, 
                    size: 40),
                  onPressed: _currentSceneIndex > 0 
                    ? () {
                        setState(() => _currentSceneIndex--);
                        _playCurrentScene();
                      }
                    : null,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.orange,
                    size: 64,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                      setState(() => _isPlaying = false);
                    } else {
                      if (_audioPlayer.state == PlayerState.paused) {
                        _audioPlayer.resume();
                        setState(() => _isPlaying = true);
                      } else {
                        _playCurrentScene();
                      }
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87, 
                    size: 40),
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
    ),
  );
}
}
