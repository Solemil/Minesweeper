import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minesweeper/cell.dart';
import 'package:minesweeper/game.dart';
import 'package:minesweeper/save_game.dart';
import 'package:minesweeper/change_difficulty_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineSweeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MinesweeperMainPage(title: 'MineSweeper'),
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
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final Game game = Game(GameDifficulty.medium);

  Future<void> saveGame() async {
    if (game.gameisOver) return;
    final SharedPreferences prefs = await _prefs;
    final gameTableJsonList = gameToStringList(game);
    await prefs.setStringList('MinesweeperGameTable', gameTableJsonList);
  }

  Future<void> loadGame() async {
    final SharedPreferences prefs = await _prefs;
    final gameTableStringList = prefs.getStringList('MinesweeperGameTable');
    if (gameTableStringList != null) game.loadSavedGame(gameTableStringList, game);
  }

  Future<void> deleteSave() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('MinesweeperGameTable');
  }

  @override
  void initState() {
    super.initState();
    loadGame();
  }

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
            if (game.gameisOver) deleteSave();
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
                                      saveGame();
                                    },
                                    onSecondaryTap: () {
                                      game.flagCell(game.gameTable.cells[index]);
                                      saveGame();
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
                    ChangeDifficultyButton(game: game, difficulty: GameDifficulty.easy),
                    SizedBox(width: 12),
                    ChangeDifficultyButton(game: game, difficulty: GameDifficulty.medium),
                    SizedBox(width: 12),
                    ChangeDifficultyButton(game: game, difficulty: GameDifficulty.hard),
                  ],
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    game.resetGame();
                  },
                  child: Text('Restart game'),
                ),
              ],
            );
          }),
    );
  }
}
