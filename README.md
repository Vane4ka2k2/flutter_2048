<div align="center">

# 🎮 2048 Grandmaster AI & Flutter Edition

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![AI Engine](https://img.shields.io/badge/AI-Expectimax_Search-FF6F00?style=for-the-badge&logo=cpu&logoColor=white)](#-ai-bot-architecture)
[![Platforms](https://img.shields.io/badge/Platforms-Android_%7C_Windows_%7C_Web-42A5F5?style=for-the-badge)](#-installation--running)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

*A sleek, highly optimized 2048 puzzle game built with **Flutter**, featuring a high-performance **Expectimax AI Bot**, dynamic theme modes, game persistence, and multi-platform support (Android, Windows, Web).*

[Key Features](#-key-features) • [AI Bot Engine](#-ai-bot-architecture) • [Getting Started](#-installation--running) • [Project Structure](#-project-structure)

</div>

---

## ✨ Key Features

- 🤖 **Grandmaster Expectimax AI Bot**:
  - Autonomous solver capable of reaching **2048, 4096, 8192, and 16384+**.
  - **Adaptive Search Depth**: Expands up to 5 steps ahead when the board gets crowded ($\le 3$ empty cells).
  - **Logarithmic Snake Matrix**: Anchors maximum tiles to the top-left corner and maintains monotonic tile chains.
  - **Turbo Mode ⚡**: Toggle between Normal (150ms) and Turbo (50ms) auto-play speeds.

- 🎨 **Modern UI & Fluid Animations**:
  - Crisp Material 3 design with built-in **Light & Dark Theme** toggle.
  - **Zero-Lag Animations**: 60fps tile sliding (`AnimatedPositioned`) and scale pulses (`AnimatedScale`).
  - **Auto-Scaling Typography**: Font sizes automatically shrink to fit 5-digit and 6-digit values (up to 131,072).
  - Extended color palette for tiles from **2** up to **131,072**.

- 💾 **State Persistence & Quality of Life**:
  - **Auto-Save**: Game state, high score, and current score automatically persist across restarts via `SharedPreferences`.
  - **Undo Feature**: One-tap move rollback to recover from mis-swipes.
  - **Keep Playing Mode**: Continue playing beyond tile 2048 without losing momentum.

- ⌨️ **Cross-Platform Control**:
  - **Mobile**: Touch swipe gestures with velocity & distance thresholding.
  - **Desktop / Web**: Arrow keys and WASD keyboard controls via `KeyboardListener`.

---

## 🧠 AI Bot Architecture

The AI engine uses an optimized **Expectimax Search** algorithm combined with memoization (Transposition Table) and dynamic heuristics:

```
                  [ Player Node (Max) ]
                       /    |    \
             (Left)   /  (Down)   \   (Right)
                     v      v      v
              [ Chance Node (Expected Value) ]
                     /              \
           (90% Spawn 2)          (10% Spawn 4)
                  /                    \
                 v                      v
        [ Next Player Node ]   [ Next Player Node ]
```

### Heuristic Evaluation Function ($E$)

$$E = \text{SnakeScore} + \text{EmptyBonus} + \text{CornerLockBonus} + \text{Monotonicity} + \text{Smoothness}$$

1. **Snake Weight Matrix**: Multiplies logarithmic tile values ($\log_2(\text{tile})$) by a fixed snake gradient matrix anchored at $(0,0)$.
2. **Adaptive Depth**:
   - $\text{Empty Cells} > 6 \implies \text{Depth } 2$
   - $3 < \text{Empty Cells} \le 6 \implies \text{Depth } 3$
   - $\text{Empty Cells} \le 3 \implies \text{Depth } 4\text{--}5$
3. **Corner Lock**: Gives a steady $+150$ bonus when the largest tile remains in $(0, 0)$ and a penalty if displaced.

---

## 🛠 Project Structure

```
lib/
├── controllers/
│   ├── ai_bot.dart          # Expectimax AI Solver & Transposition Table
│   └── game_controller.dart # Main Game Logic, State Management & Persistence
├── models/
│   └── tile.dart            # Tile Data Model (row, col, value, merge flags)
├── theme/
│   └── game_colors.dart     # Color tokens for Light/Dark mode & tile spectrum
└── views/
    ├── game_screen.dart     # Responsive Scaffold & Action Header
    └── widgets/
        ├── board_grid.dart          # Interactive Grid, Gestures & KeyboardListener
        ├── game_over_overlay.dart   # Win / Game Over Dialog
        ├── score_box.dart            # Animated Score / Best Display
        └── tile_widget.dart          # Animated Position & Scale Widget
```

---

## 🚀 Installation & Running

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0 or higher)
- Dart SDK (v3.0 or higher)

### Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Vane4ka2k2/flutter_2048.git
   cd flutter_2048
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on target platform**:
   - **Chrome / Web**:
     ```bash
     flutter run -d chrome
     ```
   - **Windows Desktop**:
     ```bash
     flutter run -d windows
     ```
   - **Android Device / Emulator**:
     ```bash
     flutter run
     ```

---

## 📦 Building Releases

- **Android APK**:
  ```bash
  flutter build apk --release
  ```
  *Output*: `build/app/outputs/flutter-apk/app-release.apk`

- **Windows Desktop (.exe)**:
  ```bash
  flutter build windows
  ```
  *Output*: `build/windows/x64/runner/Release/`

- **Web (HTML5)**:
  ```bash
  flutter build web
  ```
  *Output*: `build/web/`

---

## 🧪 Testing

Run static analysis and automated unit/widget tests:

```bash
# Static analysis
flutter analyze

# Execute test suite (9/9 passed)
flutter test
```

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
