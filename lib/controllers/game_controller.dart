import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tile.dart';
import 'ai_bot.dart';

enum MoveDirection { up, down, left, right }

class GameController extends ChangeNotifier {
  static const int gridSize = 4;
  final List<Tile> _tiles = [];
  final List<Tile> _dyingTiles = [];
  
  // Undo state
  List<Tile>? _previousTiles;
  int _previousScore = 0;
  bool _canUndo = false;

  // AI Bot state
  bool _isAutoPlaying = false;
  Timer? _autoPlayTimer;
  int _autoPlaySpeedMs = 150;

  int _score = 0;
  int _bestScore = 0;
  bool _isGameOver = false;
  bool _hasWonBefore = false;
  bool _keepPlaying = false;
  bool _isDarkMode = false;
  int _tileIdCounter = 0;

  List<Tile> get tiles => List.unmodifiable([..._tiles, ..._dyingTiles]);
  int get score => _score;
  int get bestScore => _bestScore;
  bool get isGameOver => _isGameOver;
  bool get isWon => _hasWonBefore && !_keepPlaying;
  bool get canUndo => _canUndo;
  bool get isDarkMode => _isDarkMode;
  bool get isAutoPlaying => _isAutoPlaying;
  bool get isTurboSpeed => _autoPlaySpeedMs <= 50;

  GameController() {
    _loadSavedData();
  }

  @override
  void dispose() {
    stopAutoPlay();
    super.dispose();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  void continuePlaying() {
    _keepPlaying = true;
    notifyListeners();
  }

  void toggleAutoPlaySpeed() {
    _autoPlaySpeedMs = (_autoPlaySpeedMs == 150) ? 50 : 150;
    if (_isAutoPlaying) {
      startAutoPlay(); // Restart timer with new speed
    } else {
      notifyListeners();
    }
  }

  void toggleAutoPlay() {
    if (_isAutoPlaying) {
      stopAutoPlay();
    } else {
      startAutoPlay();
    }
  }

  void startAutoPlay() {
    if (_isGameOver) return;
    _isAutoPlaying = true;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(
      Duration(milliseconds: _autoPlaySpeedMs),
      (_) => _autoPlayStep(),
    );
    notifyListeners();
  }

  void stopAutoPlay() {
    _isAutoPlaying = false;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    notifyListeners();
  }

  void _autoPlayStep() {
    if (_isGameOver || isWon) {
      stopAutoPlay();
      return;
    }

    final moveDirection = TwentyFortyEightBot.getBestMove(_tiles);
    if (moveDirection != null) {
      move(moveDirection);
    } else {
      stopAutoPlay();
    }
  }

  void initGame({bool clearSaved = true}) {
    stopAutoPlay();
    _tiles.clear();
    _dyingTiles.clear();
    _previousTiles = null;
    _canUndo = false;
    _score = 0;
    _isGameOver = false;
    _hasWonBefore = false;
    _keepPlaying = false;
    _spawnTile();
    _spawnTile();
    if (clearSaved) {
      _saveGameState();
    }
    notifyListeners();
  }

  void undo() {
    if (!_canUndo || _previousTiles == null) return;

    _tiles.clear();
    _dyingTiles.clear();
    for (final t in _previousTiles!) {
      _tiles.add(t.copyWith());
    }
    _score = _previousScore;
    _canUndo = false;
    _isGameOver = false;
    _saveGameState();
    notifyListeners();
  }

  void _spawnTile() {
    final emptyCells = <Point<int>>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (!_tiles.any((t) => t.row == r && t.col == c)) {
          emptyCells.add(Point(r, c));
        }
      }
    }

    if (emptyCells.isEmpty) return;

    final random = Random();
    final point = emptyCells[random.nextInt(emptyCells.length)];
    final value = random.nextDouble() < 0.9 ? 2 : 4;
    _tileIdCounter++;

    _tiles.add(Tile(
      id: 'tile_$_tileIdCounter',
      value: value,
      row: point.x,
      col: point.y,
      isNew: true,
    ));
  }

  void move(MoveDirection direction) {
    if (_isGameOver) return;

    _dyingTiles.clear();

    // Reset merged and new flags
    for (final tile in _tiles) {
      tile.prevRow = tile.row;
      tile.prevCol = tile.col;
      tile.isMerged = false;
      tile.isNew = false;
    }

    bool moved = false;

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

    // Process rows/columns in order depending on move direction
    List<int> rowRange = List.generate(gridSize, (i) => i);
    List<int> colRange = List.generate(gridSize, (i) => i);

    if (direction == MoveDirection.right) {
      colRange = colRange.reversed.toList();
    }
    if (direction == MoveDirection.down) {
      rowRange = rowRange.reversed.toList();
    }

    // Backup state for undo before applying changes
    final tempTilesBackup = _tiles.map((t) => t.copyWith()).toList();
    final tempScoreBackup = _score;

    for (int r in rowRange) {
      for (int c in colRange) {
        Tile? current = _getTileAt(r, c);
        if (current == null) continue;

        int nextR = r;
        int nextC = c;

        // Slide tile as far as possible
        while (true) {
          int targetR = nextR + dy;
          int targetC = nextC + dx;

          if (targetR < 0 || targetR >= gridSize || targetC < 0 || targetC >= gridSize) {
            break;
          }

          Tile? targetTile = _getTileAt(targetR, targetC);

          if (targetTile == null) {
            nextR = targetR;
            nextC = targetC;
            moved = true;
          } else if (targetTile.value == current.value && !targetTile.isMerged && !current.isMerged) {
            // Merge tiles
            nextR = targetR;
            nextC = targetC;

            // Keep targetTile temporarily in dyingTiles for smooth slide animation
            _dyingTiles.add(targetTile);
            _tiles.remove(targetTile);
            current.value *= 2;
            current.isMerged = true;
            _score += current.value;

            if (current.value >= 2048 && !_hasWonBefore) {
              _hasWonBefore = true;
            }

            moved = true;
            break;
          } else {
            break;
          }
        }

        if (current.row != nextR || current.col != nextC) {
          current.row = nextR;
          current.col = nextC;
          moved = true;
        }
      }
    }

    if (moved) {
      _previousTiles = tempTilesBackup;
      _previousScore = tempScoreBackup;
      _canUndo = true;

      if (_score > _bestScore) {
        _bestScore = _score;
      }

      _spawnTile();
      _checkGameOver();
      _saveGameState();
      notifyListeners();

      // Clear dying tiles after animation duration
      Future.delayed(const Duration(milliseconds: 160), () {
        if (_dyingTiles.isNotEmpty) {
          _dyingTiles.clear();
          notifyListeners();
        }
      });
    }
  }

  Tile? _getTileAt(int row, int col) {
    for (int i = 0; i < _tiles.length; i++) {
      final tile = _tiles[i];
      if (tile.row == row && tile.col == col) {
        return tile;
      }
    }
    return null;
  }

  void _checkGameOver() {
    // Check if empty space exists
    if (_tiles.length < gridSize * gridSize) {
      _isGameOver = false;
      return;
    }

    // Check if any adjacent tiles can merge
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        Tile? current = _getTileAt(r, c);
        if (current == null) continue;

        for (final dir in MoveDirection.values) {
          int nr = r + (dir == MoveDirection.up ? -1 : (dir == MoveDirection.down ? 1 : 0));
          int nc = c + (dir == MoveDirection.left ? -1 : (dir == MoveDirection.right ? 1 : 0));
          if (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
            Tile? neighbor = _getTileAt(nr, nc);
            if (neighbor != null && neighbor.value == current.value) {
              _isGameOver = false;
              return;
            }
          }
        }
      }
    }

    _isGameOver = true;
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bestScore = prefs.getInt('best_score') ?? 0;
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;

      final savedTiles = prefs.getStringList('saved_tiles');
      final savedScore = prefs.getInt('saved_score');

      if (savedTiles != null && savedTiles.isNotEmpty) {
        _tiles.clear();
        for (final raw in savedTiles) {
          final parts = raw.split(',');
          if (parts.length >= 3) {
            final val = int.tryParse(parts[0]) ?? 2;
            final r = int.tryParse(parts[1]) ?? 0;
            final c = int.tryParse(parts[2]) ?? 0;
            _tileIdCounter++;
            _tiles.add(Tile(
              id: 'tile_$_tileIdCounter',
              value: val,
              row: r,
              col: c,
              isNew: false,
            ));
          }
        }
        _score = savedScore ?? 0;
        _checkGameOver();
      } else {
        initGame(clearSaved: false);
      }
      notifyListeners();
    } catch (_) {
      initGame(clearSaved: false);
    }
  }

  Future<void> _saveGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('best_score', _bestScore);
      await prefs.setInt('saved_score', _score);
      final tileStrings = _tiles.map((t) => '${t.value},${t.row},${t.col}').toList();
      await prefs.setStringList('saved_tiles', tileStrings);
    } catch (_) {}
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (_) {}
  }
}
