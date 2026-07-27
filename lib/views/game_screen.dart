import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../theme/game_colors.dart';
import 'widgets/board_grid.dart';
import 'widgets/game_over_overlay.dart';
import 'widgets/score_box.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isDark = _controller.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? GameColors.darkBackground : GameColors.background,
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // Top Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '2048',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : GameColors.textDark,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Join tiles to get 2048!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : GameColors.textDark.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => _controller.toggleTheme(),
                                icon: Icon(
                                  isDark ? Icons.light_mode : Icons.dark_mode,
                                  color: isDark ? Colors.yellow : GameColors.textDark,
                                ),
                                tooltip: 'Toggle Theme',
                              ),
                              const SizedBox(width: 4),
                              ScoreBox(
                                title: 'Score',
                                score: _controller.score,
                                isDarkMode: isDark,
                              ),
                              const SizedBox(width: 4),
                              ScoreBox(
                                title: 'Best',
                                score: _controller.bestScore,
                                isDarkMode: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Swipe to play',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white54 : GameColors.textDark.withValues(alpha: 0.6),
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _controller.toggleAutoPlay(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _controller.isAutoPlaying
                                      ? const Color(0xFFF65E3B)
                                      : (isDark ? const Color(0xFF3D3D4E) : const Color(0xFF8F7A66)),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: Icon(
                                  _controller.isAutoPlaying ? Icons.pause : Icons.smart_toy,
                                  size: 18,
                                ),
                                label: Text(
                                  _controller.isAutoPlaying ? 'Pause' : 'AI Bot',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _controller.toggleAutoPlaySpeed(),
                                icon: Icon(
                                  _controller.isTurboSpeed ? Icons.bolt : Icons.speed,
                                  color: _controller.isTurboSpeed ? const Color(0xFFEDC22E) : (isDark ? Colors.white70 : GameColors.textDark),
                                  size: 20,
                                ),
                                tooltip: _controller.isTurboSpeed ? 'Turbo Mode (50ms)' : 'Normal Mode (150ms)',
                              ),
                              const SizedBox(width: 4),
                              if (_controller.canUndo) ...[
                                ElevatedButton.icon(
                                  onPressed: () => _controller.undo(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? const Color(0xFF3D3D4E) : const Color(0xFFCDC1B4),
                                    foregroundColor: isDark ? Colors.white : GameColors.textDark,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.undo, size: 18),
                                  label: const Text(
                                    'Undo',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              ElevatedButton.icon(
                                onPressed: () => _controller.initGame(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GameColors.buttonBackground,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text(
                                  'New',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Board Area
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: BoardGrid(controller: _controller),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Game Over / Win Overlay
                GameOverOverlay(controller: _controller),
              ],
            ),
          ),
        );
      },
    );
  }
}
