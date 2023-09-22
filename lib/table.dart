import 'dart:math';

import 'package:minesweeper/cell.dart';

class GameTable {
  List<Cell> cells = [];
  int tableSizeX;
  int tableSizeY;
  int minesCount;

  GameTable({required this.tableSizeX, required this.tableSizeY, required this.minesCount}) {
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
    for (int i = 0; i < minesCount; i++) {
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
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
