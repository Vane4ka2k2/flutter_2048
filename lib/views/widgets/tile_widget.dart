import 'package:flutter/material.dart';
import '../../models/tile.dart';
import '../../theme/game_colors.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double tileSize;
  final double tileMargin;
  final bool isDarkMode;

  const TileWidget({
    super.key,
    required this.tile,
    required this.tileSize,
    required this.tileMargin,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final top = tile.row * (tileSize + tileMargin) + tileMargin;
    final left = tile.col * (tileSize + tileMargin) + tileMargin;

    final bgColor = GameColors.getTileColor(tile.value, isDark: isDarkMode);
    final textColor = GameColors.getTileTextColor(tile.value, isDark: isDarkMode);

    double fontSize = tileSize * 0.45;
    if (tile.value >= 100 && tile.value < 1000) {
      fontSize = tileSize * 0.35;
    } else if (tile.value >= 1000 && tile.value < 10000) {
      fontSize = tileSize * 0.28;
    } else if (tile.value >= 10000 && tile.value < 100000) {
      fontSize = tileSize * 0.22;
    } else if (tile.value >= 100000) {
      fontSize = tileSize * 0.18;
    }

    return AnimatedPositioned(
      key: ValueKey(tile.id),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      top: top,
      left: left,
      width: tileSize,
      height: tileSize,
      child: AnimatedScale(
        scale: tile.isMerged ? 1.15 : (tile.isNew ? 1.0 : 1.0),
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (tile.value >= 8)
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '${tile.value}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
