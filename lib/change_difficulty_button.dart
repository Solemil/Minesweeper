import 'package:flutter/material.dart';
import 'package:minesweeper/game.dart';

class ChangeDifficultyButton extends StatelessWidget {
  final GameDifficulty difficulty;
  final Game game;

  const ChangeDifficultyButton({Key? key, required this.game, required this.difficulty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
