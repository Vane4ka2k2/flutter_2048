import 'dart:math';
import '../models/tile.dart';
import 'game_controller.dart';

class TwentyFortyEightBot {
  static const int gridSize = 4;

  // Transposition table for memoizing evaluated states within a single move decision
  static final Map<String, double> _transpositionTable = {};

  /// Logarithmic Snake Weight Matrix anchored to top-left corner
  static const List<List<double>> _snakeMatrix = [
    [16.0, 15.0, 14.0, 13.0],
    [ 9.0, 10.0, 11.0, 12.0],
    [ 8.0,  7.0,  6.0,  5.0],
    [ 1.0,  2.0,  3.0,  4.0],
  ];

  /// Determines the best move direction for the current tiles configuration.
  static MoveDirection? getBestMove(List<Tile> tiles) {
    _transpositionTable.clear();
    final board = _tilesToGrid(tiles);

    int emptyCells = 0;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (board[r][c] == 0) emptyCells++;
      }
    }

    // Adaptive depth: deeper search when the board gets crowded
    int depth = _getAdaptiveDepth(emptyCells);

    MoveDirection? bestMove;
    double bestScore = -double.infinity;

    // Evaluate directions in order: Left, Down, Up, Right
    const preferredOrder = [
      MoveDirection.left,
      MoveDirection.down,
      MoveDirection.up,
      MoveDirection.right,
    ];

    for (final dir in preferredOrder) {
      final simulated = _simulateMove(board, dir);
      if (simulated == null) continue; // Invalid move (no change)

      double score = _expectimax(simulated.grid, depth: depth, isPlayer: false) + (simulated.points * 0.1);

      if (score > bestScore) {
        bestScore = score;
        bestMove = dir;
      }
    }

    return bestMove;
  }

  static int _getAdaptiveDepth(int emptyCells) {
    if (emptyCells <= 3) return 4;
    if (emptyCells <= 7) return 3;
    return 2;
  }

  static List<List<int>> _tilesToGrid(List<Tile> tiles) {
    final grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    for (final tile in tiles) {
      if (tile.row >= 0 && tile.row < gridSize && tile.col >= 0 && tile.col < gridSize) {
        grid[tile.row][tile.col] = tile.value;
      }
    }
    return grid;
  }

  static _MoveResult? _simulateMove(List<List<int>> grid, MoveDirection direction) {
    final newGrid = List.generate(gridSize, (r) => List<int>.from(grid[r]));
    bool moved = false;
    int pointsEarned = 0;

    int dx = 0;
    int dy = 0;
    switch (direction) {
      case MoveDirection.left:
        dx = -1;
        break;
      case MoveDirection.right:
        dx = 1;
        break;
      case MoveDirection.up:
        dy = -1;
        break;
      case MoveDirection.down:
        dy = 1;
        break;
    }

    List<int> rowRange = List.generate(gridSize, (i) => i);
    List<int> colRange = List.generate(gridSize, (i) => i);
    if (direction == MoveDirection.right) colRange = colRange.reversed.toList();
    if (direction == MoveDirection.down) rowRange = rowRange.reversed.toList();

    final merged = List.generate(gridSize, (_) => List.filled(gridSize, false));

    for (int r in rowRange) {
      for (int c in colRange) {
        if (newGrid[r][c] == 0) continue;

        int val = newGrid[r][c];
        int nextR = r;
        int nextC = c;

        while (true) {
          int targetR = nextR + dy;
          int targetC = nextC + dx;

          if (targetR < 0 || targetR >= gridSize || targetC < 0 || targetC >= gridSize) {
            break;
          }

          if (newGrid[targetR][targetC] == 0) {
            nextR = targetR;
            nextC = targetC;
            moved = true;
          } else if (newGrid[targetR][targetC] == val && !merged[targetR][targetC]) {
            nextR = targetR;
            nextC = targetC;
            newGrid[r][c] = 0;
            newGrid[nextR][nextC] = val * 2;
            merged[nextR][nextC] = true;
            pointsEarned += val * 2;
            moved = true;
            break;
          } else {
            break;
          }
        }

        if ((nextR != r || nextC != c) && newGrid[nextR][nextC] != val * 2) {
          newGrid[r][c] = 0;
          newGrid[nextR][nextC] = val;
          moved = true;
        }
      }
    }

    if (!moved) return null;
    return _MoveResult(newGrid, pointsEarned);
  }

  static double _expectimax(List<List<int>> grid, {required int depth, required bool isPlayer}) {
    if (depth == 0) {
      return evaluateBoard(grid);
    }

    final key = _hashGrid(grid, depth, isPlayer);
    if (_transpositionTable.containsKey(key)) {
      return _transpositionTable[key]!;
    }

    double resultScore;

    if (isPlayer) {
      double maxScore = -double.infinity;
      bool hasMove = false;

      for (final dir in MoveDirection.values) {
        final result = _simulateMove(grid, dir);
        if (result != null) {
          hasMove = true;
          double score = _expectimax(result.grid, depth: depth - 1, isPlayer: false) + (result.points * 0.1);
          if (score > maxScore) {
            maxScore = score;
          }
        }
      }

      resultScore = hasMove ? maxScore : evaluateBoard(grid) - 5000.0;
    } else {
      final emptyCells = <Point<int>>[];
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (grid[r][c] == 0) {
            emptyCells.add(Point(r, c));
          }
        }
      }

      if (emptyCells.isEmpty) {
        resultScore = evaluateBoard(grid);
      } else {
        double expectedScore = 0.0;
        final weightPerCell = 1.0 / emptyCells.length;

        // Sample up to 4 empty cells for fast evaluation
        final cellsToTest = emptyCells.length > 4 ? emptyCells.sublist(0, 4) : emptyCells;

        for (final cell in cellsToTest) {
          final grid2 = List.generate(gridSize, (r) => List<int>.from(grid[r]));
          grid2[cell.x][cell.y] = 2;
          double s2 = _expectimax(grid2, depth: depth - 1, isPlayer: true);

          final grid4 = List.generate(gridSize, (r) => List<int>.from(grid[r]));
          grid4[cell.x][cell.y] = 4;
          double s4 = _expectimax(grid4, depth: depth - 1, isPlayer: true);

          expectedScore += (0.9 * s2 + 0.1 * s4) * weightPerCell;
        }

        resultScore = expectedScore;
      }
    }

    _transpositionTable[key] = resultScore;
    return resultScore;
  }

  static String _hashGrid(List<List<int>> grid, int depth, bool isPlayer) {
    final buffer = StringBuffer();
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        buffer.write('${grid[r][c]},');
      }
    }
    buffer.write('${depth}_$isPlayer');
    return buffer.toString();
  }

  /// Balanced, logarithmic evaluation function for 2048
  static double evaluateBoard(List<List<int>> grid) {
    int emptyCount = 0;
    int maxTile = 0;
    int maxR = 0;
    int maxC = 0;

    double snakeScore = 0.0;
    double smoothness = 0.0;
    double monotonicity = 0.0;

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final val = grid[r][c];
        if (val == 0) {
          emptyCount++;
          continue;
        }

        if (val > maxTile) {
          maxTile = val;
          maxR = r;
          maxC = c;
        }

        final logVal = log(val) / ln2;
        snakeScore += logVal * _snakeMatrix[r][c];

        // Smoothness with right neighbor
        if (c + 1 < gridSize && grid[r][c + 1] > 0) {
          final rightLog = log(grid[r][c + 1]) / ln2;
          smoothness -= (logVal - rightLog).abs();
        }
        // Smoothness with bottom neighbor
        if (r + 1 < gridSize && grid[r + 1][c] > 0) {
          final bottomLog = log(grid[r + 1][c]) / ln2;
          smoothness -= (logVal - bottomLog).abs();
        }
      }
    }

    // Monotonicity along rows and columns
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize - 1; c++) {
        if (grid[r][c] >= grid[r][c + 1]) monotonicity += 5.0;
        if (grid[c][r] >= grid[c + 1][r]) monotonicity += 5.0;
      }
    }

    // Moderate corner bonus/penalty anchored to top-left (0,0)
    double cornerBonus = 0.0;
    if (maxR == 0 && maxC == 0) {
      cornerBonus = 150.0;
    } else {
      cornerBonus = -200.0;
    }

    // Exponential empty cells reward
    double emptyBonus = emptyCount * emptyCount * 25.0;

    return snakeScore + emptyBonus + cornerBonus + (monotonicity * 10.0) + (smoothness * 15.0);
  }
}

class _MoveResult {
  final List<List<int>> grid;
  final int points;
  _MoveResult(this.grid, this.points);
}
