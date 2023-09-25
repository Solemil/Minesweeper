import 'package:minesweeper/cell.dart';
import 'package:minesweeper/game.dart';

List<String> cellToStringList(Cell cell) {
  return [
    cell.posX.toString(),
    cell.posY.toString(),
    cell.cellType.toString(),
    cell.isDiscovered.toString(),
    cell.isFlagged.toString(),
    cell.adjentMines.toString()
  ];
}

List<String> gameToStringList(Game game) {
  List<String> stringList = [];
  stringList.add(game.gameDifficulty.toString());
  stringList.add(game.gameTable.tableSizeX.toString());
  stringList.add(game.gameTable.tableSizeY.toString());
  stringList.add(game.gameTable.minesCount.toString());
  for (final cell in game.gameTable.cells) {
    stringList.addAll(cellToStringList(cell));
  }
  return stringList;
}

void fromStringList(List<String> stringList, Game game) {
  game.gameTable.cells = [];
  game.gameDifficulty = switch (stringList.removeAt(0)) {
    'GameDifficulty.easy' => GameDifficulty.easy,
    'GameDifficulty.medium' => GameDifficulty.medium,
    _ => GameDifficulty.hard,
  };
  game.gameTable.tableSizeX = int.parse(stringList.removeAt(0));
  game.gameTable.tableSizeY = int.parse(stringList.removeAt(0));
  game.gameTable.minesCount = int.parse(stringList.removeAt(0));
  for (int i = 0; i < game.gameTable.tableSizeX * game.gameTable.tableSizeY; i++) {
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
    game.gameTable.cells.add(cell);
  }
  game.gameisOver = false;
  game.gameisStarted = true;
  game.gameisWon = null;
}
