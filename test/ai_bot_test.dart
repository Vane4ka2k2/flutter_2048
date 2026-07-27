import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_2048/controllers/ai_bot.dart';
import 'package:flutter_2048/models/tile.dart';

void main() {
  group('TwentyFortyEightBot Tests', () {
    test('Bot returns a valid MoveDirection for simple board', () {
      final tiles = [
        Tile(id: 't1', value: 2, row: 0, col: 0),
        Tile(id: 't2', value: 2, row: 0, col: 1),
      ];

      final move = TwentyFortyEightBot.getBestMove(tiles);
      expect(move, isNotNull);
    });

    test('Bot evaluates corner weights correctly', () {
      final tilesCorner = [
        Tile(id: 't1', value: 1024, row: 0, col: 0),
        Tile(id: 't2', value: 512, row: 0, col: 1),
        Tile(id: 't3', value: 256, row: 0, col: 2),
        Tile(id: 't4', value: 128, row: 0, col: 3),
      ];

      final grid = List.generate(4, (_) => List.filled(4, 0));
      for (final t in tilesCorner) {
        grid[t.row][t.col] = t.value;
      }

      final score = TwentyFortyEightBot.evaluateBoard(grid);
      expect(score, greaterThan(0.0));
    });
  });
}
