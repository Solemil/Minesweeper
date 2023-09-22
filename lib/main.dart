import 'package:flutter/material.dart';
import 'package:minesweeper/cell.dart';
import 'package:minesweeper/table.dart';

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
      home: const MyHomePage(title: 'MineSweeper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GameTable gameTable = GameTable();

  void setStateCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: gameTable.gameisOver ? 0.5 : 1,
              child: Center(
                child: SizedBox(
                  height: 500,
                  width: 500,
                  child: GridView.builder(
                      itemCount: gameTable.cells.length,
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gameTable.tableSizeX),
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: switch (gameTable.gameDifficulty) {
                            GameDifficulty.easy => const EdgeInsets.all(4),
                            GameDifficulty.medium => const EdgeInsets.all(2),
                            GameDifficulty.hard => const EdgeInsets.all(1),
                          },
                          child: GestureDetector(
                            onTap: () {
                              gameTable.discoverCell(gameTable.cells[index]);
                              setState(() {});
                            },
                            onDoubleTap: () {
                              gameTable.flagCell(gameTable.cells[index]);
                              setState(() {});
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              color: gameTable.cells[index].isDiscovered ? Colors.grey : Colors.black12,
                              child: Center(
                                child: gameTable.cells[index].isDiscovered
                                    ? switch (gameTable.cells[index].cellType) {
                                        CellType.number => Text(gameTable.cells[index].adjentMines.toString()),
                                        CellType.empty => null,
                                        CellType.mine => Text('X'),
                                      }
                                    : gameTable.cells[index].isFlagged
                                        ? Text('F')
                                        : null,
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
            gameTable.gameisOver
                ? gameTable.gameisWon!
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
            changeDifficultyButton(context, gameTable, GameDifficulty.easy, setStateCallback),
            SizedBox(width: 12),
            changeDifficultyButton(context, gameTable, GameDifficulty.medium, setStateCallback),
            SizedBox(width: 12),
            changeDifficultyButton(context, gameTable, GameDifficulty.hard, setStateCallback)
          ],
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            gameTable.resetGame();
            setState(() {});
          },
          child: Text('Reset'),
        ),
      ]),
    );
  }
}

Widget changeDifficultyButton(
    BuildContext context, GameTable gameTable, GameDifficulty difficulty, Function setStateCallback) {
  return ElevatedButton(
    style: difficulty == gameTable.gameDifficulty
        ? ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          )
        : null,
    onPressed: () {
      if (gameTable.gameDifficulty != difficulty) {
        if (gameTable.gameisStarted) {
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
                    gameTable.changeDifficulty(difficulty);
                    Navigator.pop(context);
                    setStateCallback();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          gameTable.changeDifficulty(difficulty);
          setStateCallback();
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
