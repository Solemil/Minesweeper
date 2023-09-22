import 'dart:math';

import 'package:minesweeper/cell.dart';

class GameTable {
  List<Cell> cells = [];
  int cellDisvoered = 0;
  int minesCount = 10;
  int tableSizeX = 10;
  int tableSizeY = 10;
  bool gameisOver = false;
  bool gameisStarted = false;
  bool? gameisWon;
  GameDifficulty gameDifficulty = GameDifficulty.medium;

  GameTable() {
    loadCells();
    loadMines();
    loadNumbers();
  }

  void loadCells() {
    for (int i = 0; i < tableSizeX; i++) {
      for (int j = 0; j < tableSizeY; j++) {
        cells.add(Cell(posX: i, posY: j));
      }
    }
  }

  void loadMines() {
    for (int i = 0; i < minesCount - 1; i++) {
      var random = Random();
      var index = random.nextInt(tableSizeX * tableSizeY);
      cells[index].cellType = CellType.mine;
    }
  }

  void loadNumbers() {
    for (final cell in cells) {
      if (cell.cellType == CellType.mine) {
        continue;
      }
      var adjentMines = 0;
      for (final adjentCell in getAdjentCells(cell)) {
        if (adjentCell.cellType == CellType.mine) {
          adjentMines++;
        }
      }
      cell.adjentMines = adjentMines;
      if (adjentMines > 0) {
        cell.cellType = CellType.number;
      }
    }
  }

  List<Cell> getAdjentCells(Cell cell) {
    List<Cell> adjentCells = <Cell>[];
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) {
          continue;
        }
        Cell? adjentCell = cells
            .firstWhereOrNull((cellInTable) => cellInTable.posX == cell.posX + i && cellInTable.posY == cell.posY + j);
        if (adjentCell != null) {
          adjentCells.add(adjentCell);
        }
      }
    }
    return adjentCells;
  }

  void discoverCell(Cell cell) {
    if (gameisStarted == false) {
      gameisStarted = true;
    }
    if (cell.isDiscovered || cell.isFlagged || gameisOver) {
      return;
    }
    cell.isDiscovered = true;
    cellDisvoered++;
    if (cell.cellType == CellType.empty) {
      List<Cell> adjentCells = getAdjentCells(cell);
      for (final adjentCell in adjentCells) {
        discoverCell(adjentCell);
      }
    }
    if (cell.cellType == CellType.mine) {
      endGame(false);
    }
    if (cellDisvoered == cells.length - minesCount) {
      endGame(true);
    }
  }

  void flagCell(Cell cell) {
    if (cell.isDiscovered || gameisOver) {
      return;
    }
    cell.isFlagged = !cell.isFlagged;
  }

  void resetGame() {
    cells = [];
    cellDisvoered = 0;
    gameisOver = false;
    gameisStarted = false;
    gameisWon = null;
    switch (gameDifficulty) {
      case GameDifficulty.easy:
        minesCount = 3;
        tableSizeX = 5;
        tableSizeY = 5;
        break;
      case GameDifficulty.medium:
        minesCount = 10;
        tableSizeX = 10;
        tableSizeY = 10;
        break;
      case GameDifficulty.hard:
        minesCount = 20;
        tableSizeX = 15;
        tableSizeY = 15;
        break;
    }
    loadCells();
    loadMines();
    loadNumbers();
  }

  void changeDifficulty(GameDifficulty difficulty) {
    if (gameDifficulty == difficulty) return;
    gameDifficulty = difficulty;
    resetGame();
  }

  void endGame(bool isWin) {
    gameisOver = true;
    gameisStarted = false;
    if (isWin) {
      gameisWon = true;
    } else {
      gameisWon = false;
    }
  }
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
