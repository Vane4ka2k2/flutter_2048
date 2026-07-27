import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/game_controller.dart';
import '../../theme/game_colors.dart';
import 'tile_widget.dart';

class BoardGrid extends StatefulWidget {
  final GameController controller;

  const BoardGrid({
    super.key,
    required this.controller,
  });

  @override
  State<BoardGrid> createState() => _BoardGridState();
}

class _BoardGridState extends State<BoardGrid> {
  late final FocusNode _focusNode;
  Offset _dragDistance = Offset.zero;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    _dragDistance = Offset.zero;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _dragDistance += details.delta;
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final dx = _dragDistance.dx;
    final dy = _dragDistance.dy;
    final vdx = velocity.dx;
    final vdy = velocity.dy;

    const minDistance = 20.0;
    const minVelocity = 150.0;

    final isHorizontalDrag = dx.abs() >= minDistance || vdx.abs() >= minVelocity;
    final isVerticalDrag = dy.abs() >= minDistance || vdy.abs() >= minVelocity;

    if (!isHorizontalDrag && !isVerticalDrag) return;

    final horizontalDominant = (dx.abs() != dy.abs())
        ? dx.abs() > dy.abs()
        : vdx.abs() > vdy.abs();

    if (horizontalDominant && isHorizontalDrag) {
      final isRight = dx != 0 ? dx > 0 : vdx > 0;
      widget.controller.move(isRight ? MoveDirection.right : MoveDirection.left);
    } else if (!horizontalDominant && isVerticalDrag) {
      final isDown = dy != 0 ? dy > 0 : vdy > 0;
      widget.controller.move(isDown ? MoveDirection.down : MoveDirection.up);
    }

    _dragDistance = Offset.zero;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        widget.controller.move(MoveDirection.left);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        widget.controller.move(MoveDirection.right);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        widget.controller.move(MoveDirection.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        widget.controller.move(MoveDirection.down);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        const margin = 12.0;
        final tileSize = (boardSize - (margin * 5)) / GameController.gridSize;

        final isDark = widget.controller.isDarkMode;

        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  color: isDark ? GameColors.darkBoardBackground : GameColors.boardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Grid cells background
                    for (int r = 0; r < GameController.gridSize; r++)
                      for (int c = 0; c < GameController.gridSize; c++)
                        Positioned(
                          top: r * (tileSize + margin) + margin,
                          left: c * (tileSize + margin) + margin,
                          width: tileSize,
                          height: tileSize,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? GameColors.darkEmptyCell : GameColors.emptyCell,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                    // Active Tiles overlay
                    for (final tile in widget.controller.tiles)
                      TileWidget(
                        key: ValueKey(tile.id),
                        tile: tile,
                        tileSize: tileSize,
                        tileMargin: margin,
                        isDarkMode: isDark,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
