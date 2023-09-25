class Cell {
  int posX;
  int posY;
  CellType cellType;
  bool isDiscovered;
  bool isFlagged;
  int adjentMines;

  Cell({
    required this.posX,
    required this.posY,
    this.cellType = CellType.empty,
    this.isDiscovered = false,
    this.isFlagged = false,
    this.adjentMines = 0,
  });
}

enum CellType {
  mine,
  number,
  empty,
}
