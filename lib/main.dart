import 'package:flutter/material.dart';
import 'package:minesweeper/game.dart';
import 'package:minesweeper/cell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MinesweeperMainPage(title: 'MineSweeper'),
    );
  }
}

class MinesweeperMainPage extends StatefulWidget {
  const MinesweeperMainPage({super.key, required this.title});
  final String title;

  @override
  State<MinesweeperMainPage> createState() => _MinesweeperMainPageState();
}

class _MinesweeperMainPageState extends State<MinesweeperMainPage> {
  Game game = Game(GameDifficulty.medium);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListenableBuilder(
          listenable: game,
          builder: (BuildContext context, Widget? child) {
            return Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: game.gameisOver ? 0.5 : 1,
                      child: Center(
                        child: SizedBox(
                          height: 500,
                          width: 500,
                          child: GridView.builder(
                              itemCount: game.gameTable.cells.length,
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: game.gameTable.tableSizeX),
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: switch (game.gameDifficulty) {
                                    GameDifficulty.easy => const EdgeInsets.all(4),
                                    GameDifficulty.medium => const EdgeInsets.all(2),
                                    GameDifficulty.hard => const EdgeInsets.all(1),
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      game.discoverCell(game.gameTable.cells[index]);
                                    },
                                    onSecondaryTap: () {
                                      game.flagCell(game.gameTable.cells[index]);
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      color: game.isDiscovered(index) ? Colors.grey : Colors.black12,
                                      child: Center(
                                        child: game.gameTable.cells[index].isDiscovered
                                            ? switch (game.gameTable.cells[index].cellType) {
                                                CellType.number =>
                                                  Text(game.gameTable.cells[index].adjentMines.toString()),
                                                CellType.empty => null,
                                                CellType.mine => Icon(Icons.brightness_high, color: Colors.redAccent)
                                              }
                                            : game.gameTable.cells[index].isFlagged
                                                ? Icon(Icons.flag, color: Theme.of(context).colorScheme.primary)
                                                : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ),
                    game.gameisOver
                        ? game.gameisWon!
                            ? Text(
                                'You Won',
                                style: TextStyle(color: Colors.green, fontSize: 48, fontWeight: FontWeight.bold),
                              )
                            : Text(
                                'Game Over',
                                style: TextStyle(color: Colors.red, fontSize: 48, fontWeight: FontWeight.bold),
                              )
                        : SizedBox(),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    changeDifficultyButton(context, game, GameDifficulty.easy),
                    SizedBox(width: 12),
                    changeDifficultyButton(context, game, GameDifficulty.medium),
                    SizedBox(width: 12),
                    changeDifficultyButton(context, game, GameDifficulty.hard)
                  ],
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    game.resetGame();
                  },
                  child: Text('Restart'),
                ),
              ],
            );
          }),
    );
  }
}

Widget changeDifficultyButton(BuildContext context, Game game, GameDifficulty difficulty) {
  return ElevatedButton(
    style: difficulty == game.gameDifficulty
        ? ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          )
        : null,
    onPressed: () {
      if (game.gameDifficulty != difficulty) {
        if (game.gameisStarted) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'Restart Game',
                textAlign: TextAlign.center,
              ),
              content: const Text('Are you sure you want to restart the game?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    game.changeDifficulty(difficulty);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          game.changeDifficulty(difficulty);
        }
      }
    },
    child: switch (difficulty) {
      GameDifficulty.easy => Text('Easy'),
      GameDifficulty.medium => Text('Medium'),
      GameDifficulty.hard => Text('Hard'),
    },
  );
}
