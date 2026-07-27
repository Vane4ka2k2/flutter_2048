import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import '../../theme/game_colors.dart';

class GameOverOverlay extends StatelessWidget {
  final GameController controller;

  const GameOverOverlay({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.isGameOver && !controller.isWon) {
      return const SizedBox.shrink();
    }

    final isWon = controller.isWon && !controller.isGameOver;
    final title = isWon ? 'You Win!' : 'Game Over!';

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: controller.isDarkMode ? GameColors.darkBoardBackground : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: isWon ? const Color(0xFFEDC22E) : const Color(0xFFF65E3B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Final Score: ${controller.score}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: controller.isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWon) ...[
                    ElevatedButton.icon(
                      onPressed: () => controller.continuePlaying(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEDC22E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text(
                        'Keep Playing',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  ElevatedButton.icon(
                    onPressed: () => controller.initGame(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameColors.buttonBackground,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      isWon ? 'New Game' : 'Try Again',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
