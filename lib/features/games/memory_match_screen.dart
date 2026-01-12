import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  // 4x4 Grid = 16 cards = 8 pairs
  final List<String> _emojis = ['🦷', '🍎', '🪥', '🧴', '😁', '🦠', '⭐', '🧚‍♀️'];
  List<String> _cards = [];
  List<bool> _revealed = [];
  List<bool> _solved = [];
  
  int _firstFlipped = -1;
  bool _processing = false;
  int _moves = 0;
  
  @override
  void initState() {
    super.initState();
    _resetGame();
  }
  
  void _resetGame() {
    List<String> combined = [..._emojis, ..._emojis];
    combined.shuffle();
    setState(() {
      _cards = combined;
      _revealed = List.filled(16, false);
      _solved = List.filled(16, false);
      _moves = 0;
      _firstFlipped = -1;
      _processing = false;
    });
  }

  void _onCardTap(int index) {
    if (_processing || _revealed[index] || _solved[index]) return;
    
    setState(() {
      _revealed[index] = true;
    });
    
    if (_firstFlipped == -1) {
      _firstFlipped = index;
    } else {
      // Second flip
      _moves++;
      _processing = true;
      if (_cards[_firstFlipped] == _cards[index]) {
        // Match
        _solved[_firstFlipped] = true;
        _solved[index] = true;
        _firstFlipped = -1;
        _processing = false;
        _checkWin();
      } else {
        // Mismatch
        Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            _revealed[_firstFlipped] = false;
            _revealed[index] = false;
            _firstFlipped = -1;
            _processing = false;
          });
        });
      }
    }
  }
  
  void _checkWin() {
    if (_solved.every((s) => s)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("You Win! 🎉"),
          content: Text("Solved in $_moves moves!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              }, 
              child: const Text("Play Again")
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.amber.shade50,
      appBar: AppBar(
        title: Text("Memory Match 🧠", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Moves: $_moves", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.brown)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _revealed[index] || _solved[index] ? Colors.white : Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(2, 2))
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _revealed[index] || _solved[index] 
                      ? Text(_cards[index], style: const TextStyle(fontSize: 32))
                      : const Text("?", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: ElevatedButton.icon(
              onPressed: _resetGame, 
              icon: const Icon(Icons.refresh), 
              label: const Text("Reset Game"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
