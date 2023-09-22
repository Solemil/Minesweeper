class Cell {
  int posX;
  int posY;
  CellType cellType;
  bool isDiscovered;
  bool isFlagged;
  int adjentMines;

  Cell(
      {required this.posX,
      required this.posY,
      this.cellType = CellType.empty,
      this.isDiscovered = false,
      this.isFlagged = false,
      this.adjentMines = 0});

  List<String> toStringList() {
    return [
      posX.toString(),
      posY.toString(),
      cellType.toString(),
      isDiscovered.toString(),
      isFlagged.toString(),
      adjentMines.toString()
    ];
  }
}

enum CellType {
  mine,
  number,
  empty,
}
