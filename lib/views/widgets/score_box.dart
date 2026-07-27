import 'package:flutter/material.dart';
import '../../theme/game_colors.dart';

class ScoreBox extends StatelessWidget {
  final String title;
  final int score;
  final bool isDarkMode;

  const ScoreBox({
    super.key,
    required this.title,
    required this.score,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? GameColors.darkBoardBackground : GameColors.buttonBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEEE4DA),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
