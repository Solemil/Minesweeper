import 'package:minesweeper/table.dart';
import 'package:flutter/material.dart';

import 'package:minesweeper/cell.dart';

class Game with ChangeNotifier {
  GameDifficulty gameDifficulty;
  bool gameisOver = false;
  bool gameisStarted = false;
  bool? gameisWon;
  int cellDisvoered = 0;
  late GameTable gameTable;

  Game(this.gameDifficulty) {
    gameTable = createGameTable(gameDifficulty);
  }

  GameTable createGameTable(GameDifficulty gameDifficulty) {
    return switch (gameDifficulty) {
      GameDifficulty.easy => gameTable = GameTable(minesCount: 3, tableSizeX: 5, tableSizeY: 5),
      GameDifficulty.medium => gameTable = GameTable(minesCount: 10, tableSizeX: 10, tableSizeY: 10),
      GameDifficulty.hard => gameTable = GameTable(minesCount: 20, tableSizeX: 15, tableSizeY: 15),
    };
  }

  List<String> toStringList() {
    List<String> stringList = [];
    stringList.add(gameDifficulty.toString());
    stringList.add(gameTable.tableSizeX.toString());
    stringList.add(gameTable.tableSizeY.toString());
    stringList.add(gameTable.minesCount.toString());
    for (final cell in gameTable.cells) {
      stringList.addAll(cell.toStringList());
    }
    return stringList;
  }

  void fromStringList(List<String> stringList) {
    gameTable.cells = [];
    gameDifficulty = switch (stringList.removeAt(0)) {
      'GameDifficulty.easy' => GameDifficulty.easy,
      'GameDifficulty.medium' => GameDifficulty.medium,
      _ => GameDifficulty.hard,
    };
    gameTable.tableSizeX = int.parse(stringList.removeAt(0));
    gameTable.tableSizeY = int.parse(stringList.removeAt(0));
    gameTable.minesCount = int.parse(stringList.removeAt(0));
    for (int i = 0; i < gameTable.tableSizeX * gameTable.tableSizeY; i++) {
      List<String> cellInfo = stringList.sublist(0, 6);
      stringList.removeRange(0, 6);
      final cell = Cell(
        posX: int.parse(cellInfo[0]),
        posY: int.parse(cellInfo[1]),
        cellType: switch (cellInfo[2]) {
          'CellType.mine' => CellType.mine,
          'CellType.number' => CellType.number,
          _ => CellType.empty,
        },
        isDiscovered: cellInfo[3] == 'true' ? true : false,
        isFlagged: cellInfo[4] == 'true' ? true : false,
        adjentMines: int.parse(cellInfo[5]),
      );
      gameTable.cells.add(cell);
    }
    gameisOver = false;
    gameisStarted = true;
    gameisWon = null;
    notifyListeners();
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

  void resetGame() {
    gameTable.cells = [];
    cellDisvoered = 0;
    gameisOver = false;
    gameisStarted = false;
    gameisWon = null;
    createGameTable(gameDifficulty);
    notifyListeners();
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
    for (final cell in gameTable.cells) {
      if (cell.cellType == CellType.mine) {
        cell.isDiscovered = true;
      }
    }
    notifyListeners();
  }
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}
