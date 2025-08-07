import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: GameScreen(onToggleTheme: _toggleTheme),
    );
  }
}

class GameScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const GameScreen({super.key, required this.onToggleTheme});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  List<List<String>> board = List.generate(3, (_) => List.generate(3, (_) => ''));
  String currentPlayer = 'X';
  String? winner;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Offset>? winningLine;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _handleTap(int row, int col) {
    if (board[row][col] == '' && winner == null) {
      setState(() {
        board[row][col] = currentPlayer;
        var result = _checkWinner();
        if (result != null) {
          winner = result['winner'];
          winningLine = result['line'];
          _controller.forward(from: 0);
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  Map<String, dynamic>? _checkWinner() {
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != '' && board[i][0] == board[i][1] && board[i][1] == board[i][2]) {
        return {
          'winner': board[i][0],
          'line': [Offset(0, i + 0.5), Offset(3, i + 0.5)],
        };
      }
      if (board[0][i] != '' && board[0][i] == board[1][i] && board[1][i] == board[2][i]) {
        return {
          'winner': board[0][i],
          'line': [Offset(i + 0.5, 0), Offset(i + 0.5, 3)],
        };
      }
    }
    if (board[0][0] != '' && board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
      return {
        'winner': board[0][0],
        'line': [Offset(0, 0), Offset(3, 3)],
      };
    }
    if (board[0][2] != '' && board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
      return {
        'winner': board[0][2],
        'line': [Offset(0, 3), Offset(3, 0)],
      };
    }
    return null;
  }

  void _resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.generate(3, (_) => ''));
      currentPlayer = 'X';
      winner = null;
      winningLine = null;
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double boardSize = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          if (winner != null)
            Text(
              'Gʻolib: $winner',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          const SizedBox(height: 50),
          Center(
            child: GestureDetector(
              onTapUp: (details) {
                final cellSize = boardSize / 3;
                final dx = details.localPosition.dx;
                final dy = details.localPosition.dy;
                final col = (dx ~/ cellSize).clamp(0, 2);
                final row = (dy ~/ cellSize).clamp(0, 2);
                _handleTap(row, col);
              },
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: BoardPainter(
                        board: board,
                        winningLine: winningLine,
                        progress: _animation.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: _resetGame,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text('Qayta boshlash', style: TextStyle(fontSize: 24),),
            ),
          ),
        ],
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final List<List<String>> board;
  final List<Offset>? winningLine;
  final double progress;

  BoardPainter({required this.board, this.winningLine, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4;

    double cellSize = size.width / 3;

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(0, cellSize * i), Offset(size.width, cellSize * i), paint);
      canvas.drawLine(Offset(cellSize * i, 0), Offset(cellSize * i, size.height), paint);
    }

    final xPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6;
    final oPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final value = board[row][col];
        final center = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
        final halfSize = cellSize * 0.3;
        if (value == 'X') {
          canvas.drawLine(center.translate(-halfSize, -halfSize), center.translate(halfSize, halfSize), xPaint);
          canvas.drawLine(center.translate(-halfSize, halfSize), center.translate(halfSize, -halfSize), xPaint);
        } else if (value == 'O') {
          canvas.drawCircle(center, halfSize, oPaint);
        }
      }
    }

    if (winningLine != null) {
      final linePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 6;

      Offset p1 = Offset(winningLine![0].dx * cellSize, winningLine![0].dy * cellSize);
      Offset p2 = Offset(winningLine![1].dx * cellSize, winningLine![1].dy * cellSize);
      Offset animatedP2 = Offset.lerp(p1, p2, progress)!;

      canvas.drawLine(p1, animatedP2, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}