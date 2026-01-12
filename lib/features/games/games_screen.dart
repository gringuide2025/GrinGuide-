import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Define the games list
    final games = [
      _GameItem(
        title: "Plaque Attack",
        description: "Tap the germs away!",
        icon: Icons.bug_report_rounded,
        color: Colors.redAccent,
        route: '/games/plaque-attack',
      ),
      _GameItem(
        title: "Healthy vs. Junk",
        description: "Catch the good food!",
        icon: Icons.local_dining_rounded,
        color: Colors.green,
        route: '/games/healthy-junk',
      ),
      _GameItem(
        title: "Floss Ninja",
        description: "Slice candy, save apples!",
        icon: Icons.cut_rounded,
        color: Colors.cyanAccent,
        route: '/games/floss-ninja',
      ),
      _GameItem(
        title: "Sugar War",
        description: "Defend the teeth!",
        icon: Icons.shield_rounded,
        color: Colors.blueGrey,
        route: '/games/sugar-war',
      ),
      _GameItem(
        title: "Memory Match",
        description: "Find the pairs!",
        icon: Icons.grid_view_rounded,
        color: Colors.orangeAccent,
        route: '/games/memory-match',
      ),
      _GameItem(
        title: "Cavity Hunter",
        description: "Find hidden germs",
        icon: Icons.search_rounded,
        color: Colors.yellow,
        route: '/games/cavity-hunter',
      ),
      _GameItem(
        title: "Bacteria Bounce",
        description: "Keep the ball flying",
        icon: Icons.sports_tennis_rounded,
        color: Colors.blue,
        route: '/games/bacteria-bounce',
      ),
      _GameItem(
        title: "Smiles in Space",
        description: "Dodge asteroids!",
        icon: Icons.rocket_launch_rounded,
        color: Colors.deepPurpleAccent,
        route: '/games/smiles-in-space',
      ),
      _GameItem(
        title: "Germ Whack",
        description: "Whack-a-mole fun",
        icon: Icons.gavel_rounded,
        color: Colors.pinkAccent,
        route: '/games/germ-whack',
      ),
      _GameItem(
        title: "Sparkle Painter",
        description: "Color your smile",
        icon: Icons.palette_rounded,
        color: Colors.tealAccent,
        route: '/games/sparkle-painter',
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return _buildGameCard(context, game, isDark);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : Colors.black87),
          ),
          const Expanded(
            child: Text(
              "Game Center 🎮",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, _GameItem game, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (game.route.isNotEmpty) {
           context.push(game.route);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Launching ${game.title}...")),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: game.color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: game.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(game.icon, size: 40, color: game.color),
            ),
            const SizedBox(height: 16),
            Text(
              game.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                game.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  _GameItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
