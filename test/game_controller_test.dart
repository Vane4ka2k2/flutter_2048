import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_2048/controllers/game_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('2048 GameController Tests', () {
    late GameController controller;

    setUp(() {
      controller = GameController();
      controller.initGame(clearSaved: true);
    });

    test('Initial game state has 2 tiles and score 0', () {
      expect(controller.tiles.length, 2);
      expect(controller.score, 0);
      expect(controller.isGameOver, false);
      expect(controller.isWon, false);
      expect(controller.canUndo, false);
    });

    test('Restarting game resets score and tiles', () {
      controller.move(MoveDirection.left);
      controller.initGame(clearSaved: true);
      expect(controller.tiles.length, 2);
      expect(controller.score, 0);
      expect(controller.canUndo, false);
    });

    test('Theme toggle switches mode', () {
      final initial = controller.isDarkMode;
      controller.toggleTheme();
      expect(controller.isDarkMode, !initial);
    });

    test('Moving creates undo state', () {
      expect(controller.canUndo, false);
      controller.move(MoveDirection.left);
      expect(controller.canUndo, true);
    });

    test('Undo restores previous score and tiles', () {
      final initialScore = controller.score;
      final initialTileCount = controller.tiles.length;

      controller.move(MoveDirection.left);
      expect(controller.canUndo, true);

      controller.undo();
      expect(controller.score, initialScore);
      expect(controller.tiles.length, initialTileCount);
      expect(controller.canUndo, false);
    });

    test('Continue playing mode disables isWon overlay', () {
      controller.continuePlaying();
      expect(controller.isWon, false);
    });
  });
}
