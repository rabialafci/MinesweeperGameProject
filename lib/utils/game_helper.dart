import 'dart:math';
import 'package:flutter/material.dart';
import 'package:miinesweeper/ui/screens/main_screen.dart';

class MinesweeperGame extends StatefulWidget {
  @override
  _MinesweeperGameState createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
  MinesweeperGameHelper? _currentGame;

  void _startGame(int rows, int columns, int totalMines, ) {
    setState(() {
      _currentGame = MinesweeperGameHelper(
        rows: rows,
        columns: columns,
        totalMines: totalMines,
      );
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(gameHelper: _currentGame!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _currentGame == null
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              _startGame(6,6, 5); // Beginner level
            },
            child: Text('Beginner'),
          ),
          ElevatedButton(
            onPressed: () {
              _startGame(8, 8, 7); // Intermediate level
            },
            child: Text('Intermediate'),
          ),
          ElevatedButton(
            onPressed: () {
              _startGame(10, 10, 10); // Expert level
            },
            child: Text('Expert'),
          ),
        ],
      ),
    )
        : GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _currentGame!.columns,
      ),
      itemBuilder: (context, index) {
        final int row = index ~/ _currentGame!.columns;
        final int col = index % _currentGame!.columns;
        final Cell cell = _currentGame!.map[row][col];
        return InkWell(
          onTap: () {
            // Handle cell tap here
            // You can call the corresponding function from MinesweeperGameHelper
            // based on the tapped cell's position (row, col)
          },
          child: Container(
            margin: EdgeInsets.all(2),
            color: Colors.grey,
            child: Center(
              child: Text(
                cell.reveal ? cell.content.toString() : '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
      itemCount: _currentGame!.rows * _currentGame!.columns,
    );
  }
}

class MinesweeperGameHelper {
  int rows;
  int columns;
  int totalMines;
  int remainingFlags;
  bool gameOver = false;
  bool gameWon = false;
  List<Cell> gameMap = [];
  List<List<Cell>> map = [];

  MinesweeperGameHelper({
    required this.rows,
    required this.columns,
    required this.totalMines,
  }) : remainingFlags = totalMines {
    map = List.generate(
        rows, (x) => List.generate(columns, (y) => Cell(x, y, "", false, false)));
    generateMap();
  }

  void generateMap() {
    placeMines(totalMines);
    gameMap = List<Cell>.generate(
        rows * columns,
            (index) {
          int row = index ~/ columns;
          int col = index % columns;
          return map[row][col];
        });
  }

  void resetGame() {
    map = List.generate(
        rows, (x) => List.generate(columns, (y) => Cell(x, y, "", false, false)));
    gameMap.clear();
    generateMap();
    gameOver = false;
    gameWon = false;
    remainingFlags = totalMines;
  }

  void placeMines(int minesNumber) {
    Random random = Random();
    for (int i = 0; i < minesNumber; i++) {
      int mineRow = random.nextInt(rows);
      int mineCol = random.nextInt(columns);
      while (map[mineRow][mineCol].content == "X") {
        mineRow = random.nextInt(rows);
        mineCol = random.nextInt(columns);
      }
      map[mineRow][mineCol] = Cell(mineRow, mineCol, "X", false, false);
    }
  }

  void showMines() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (map[i][j].content == "X") {
          map[i][j].reveal = true;
        }
      }
    }
  }

  void getClickedCell(Cell cell) {
    if (cell.isFlagged) return;

    if (cell.content == "X") {
      showMines();
      gameOver = true;
    } else {
      int mineCount = 0;
      int cellRow = cell.row;
      int cellCol = cell.col;

      for (int i = max(cellRow - 1, 0); i <= min(cellRow + 1, rows - 1); i++) {
        for (int j = max(cellCol - 1, 0); j <= min(cellCol + 1, columns - 1); j++) {
          if (map[i][j].content == "X") {
            mineCount++;
          }
        }
      }

      cell.content = mineCount;
      cell.reveal = true;
      if (mineCount == 0) {
        for (int i = max(cellRow - 1, 0); i <= min(cellRow + 1, rows - 1); i++) {
          for (int j = max(cellCol - 1, 0); j <= min(cellCol + 1, columns - 1); j++) {
            if (!map[i][j].reveal && !map[i][j].isFlagged) {
              getClickedCell(map[i][j]);
            }
          }
        }
      }
    }
  }

  void toggleFlag(Cell cell) {
    if (cell.reveal) return;
    if (cell.isFlagged) {
      cell.isFlagged = false;
      remainingFlags++;
    } else if (remainingFlags > 0) {
      cell.isFlagged = true;
      remainingFlags--;
    }
    checkWinCondition();
  }

  void checkWinCondition() {
    bool allMinesFlagged = true;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (map[i][j].content == "X" && !map[i][j].isFlagged) {
          allMinesFlagged = false;
          break;
        }
      }
    }
    if (allMinesFlagged) {
      gameWon = true;
      gameOver = true;
    }
  }
}

class Cell {
  int row;
  int col;
  dynamic content;
  bool reveal = false;
  bool isFlagged = false;
  Cell(this.row, this.col, this.content, this.reveal, this.isFlagged);
}