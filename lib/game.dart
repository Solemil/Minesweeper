import 'package:flutter/material.dart';

import 'package:minesweeper/cell.dart';
import 'package:minesweeper/table.dart';
import 'package:minesweeper/shared_pref.dart';

class Game with ChangeNotifier {
  GameDifficulty gameDifficulty;
  bool gameisOver = false;
  bool gameisStarted = false;
  bool? gameisWon;
  int cellDisvoered = 0;
  final SharedPref sharedPref = SharedPref();
  late GameTable gameTable;

  Game(this.gameDifficulty) {
    gameTable = createGameTable(gameDifficulty);
    loadGame();
  }

  GameTable createGameTable(GameDifficulty gameDifficulty) {
    return switch (gameDifficulty) {
      GameDifficulty.easy => gameTable = GameTable(minesCount: 3, tableSizeX: 5, tableSizeY: 5),
      GameDifficulty.medium => gameTable = GameTable(minesCount: 10, tableSizeX: 10, tableSizeY: 10),
      GameDifficulty.hard => gameTable = GameTable(minesCount: 20, tableSizeX: 15, tableSizeY: 15),
    };
  }

  bool isDiscovered(int index) => gameTable.cells[index].isDiscovered ? true : false;

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
      List<Cell> adjentCells = gameTable.getAdjentCells(cell);
      for (final adjentCell in adjentCells) {
        discoverCell(adjentCell);
      }
    }
    if (cell.cellType == CellType.mine) {
      endGame(false);
    }
    if (cellDisvoered == gameTable.cells.length - gameTable.minesCount) {
      endGame(true);
    }
    notifyListeners();
  }

  void flagCell(Cell cell) {
    if (cell.isDiscovered || gameisOver) {
      return;
    }
    cell.isFlagged = !cell.isFlagged;
    notifyListeners();
  }

  Future<void> saveGame() async {
    await sharedPref.saveToSharedPred(this);
  }

  Future<void> loadGame() async {
    await sharedPref.loadfromSharedPref(this);
    notifyListeners();
  }

  Future<void> deleteSave() async {
    await sharedPref.deleteFromSharedPref();
  }

  void changeDifficulty(GameDifficulty difficulty) {
    if (gameDifficulty == difficulty) return;
    gameDifficulty = difficulty;
    resetGame();
  }

  void resetGame() {
    gameTable.cells = [];
    cellDisvoered = 0;
    gameisOver = false;
    gameisStarted = false;
    gameisWon = null;
    createGameTable(gameDifficulty);
    notifyListeners();
  }

  void endGame(bool isWin) {
    gameisOver = true;
    gameisStarted = false;
    if (isWin) {
      gameisWon = true;
    } else {
      gameisWon = false;
    }
    for (final cell in gameTable.cells) {
      if (cell.cellType == CellType.mine) {
        cell.isDiscovered = true;
      }
    }
  }
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}
