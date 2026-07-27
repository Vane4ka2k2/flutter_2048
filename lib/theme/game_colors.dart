import 'package:flutter/material.dart';

class GameColors {
  // App Background & Board Colors
  static const Color background = Color(0xFFFAF8EF);
  static const Color boardBackground = Color(0xFFBBADA0);
  static const Color emptyCell = Color(0xFFCDC1B4);
  static const Color textDark = Color(0xFF776E65);
  static const Color textLight = Color(0xFFF9F6F2);
  static const Color buttonBackground = Color(0xFF8F7A66);

  // Dark Theme Options
  static const Color darkBackground = Color(0xFF121216);
  static const Color darkBoardBackground = Color(0xFF24252E);
  static const Color darkEmptyCell = Color(0xFF333543);

  static Color getTileColor(int value, {bool isDark = false}) {
    switch (value) {
      case 2:
        return isDark ? const Color(0xFF3D3D4E) : const Color(0xFFEEE4DA);
      case 4:
        return isDark ? const Color(0xFF4A4B60) : const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      case 4096:
        return const Color(0xFF65D077);
      case 8192:
        return const Color(0xFF28B486);
      case 16384:
        return const Color(0xFF2FA8D2);
      case 32768:
        return const Color(0xFF7B52DA);
      case 65536:
        return const Color(0xFFD644A0);
      case 131072:
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF212121);
    }
  }

  static Color getTileTextColor(int value, {bool isDark = false}) {
    if (value <= 4) {
      return isDark ? const Color(0xFFF9F6F2) : const Color(0xFF776E65);
    }
    return const Color(0xFFF9F6F2);
  }
}
