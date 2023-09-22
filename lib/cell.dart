class Cell {
  int posX;
  int posY;
  CellType cellType = CellType.empty;
  bool isDiscovered = false;
  bool isFlagged = false;
  int? adjentMines;

  Cell({required this.posX, required this.posY});
}

enum CellType {
  mine,
  number,
  empty,
}
