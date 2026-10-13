import 'dart:io';

import 'package:minesweeper/services/minesweeper_game.dart';
import 'package:minesweeper/services/score_service.dart';

void main(List<String> arguments) {
  print('=== BENVENUTO IN CAMPO MINATO (MINESWEEPER) ===');

  // Scegliamo la difficoltà (puoi personalizzarla)
  int rows = 9;
  int cols = 9;
  int mines = 10;
  String difficulty = 'Beginner';

  var game = MinesweeperGame(rows: rows, cols: cols, mines: mines);
  var stopwatch = Stopwatch()..start();

  bool isGameOver = false;
  bool hasWon = false;

  while (!isGameOver && !hasWon) {
    // 1. Mostriamo la griglia a schermo
    game.board.printBoard();

    // 2. Chiediamo l'azione all'utente
    stdout.write('Scegli azione - Scopri [S] o Bandierina [F]: ');
    String? actionInput = stdin.readLineSync()?.trim().toUpperCase();

    if (actionInput != 'S' && actionInput != 'F') {
      print('Azione non valida! Usa S per scoprire o F per la bandierina.');
      continue;
    }

    // 3. Chiediamo la riga
    stdout.write('Inserisci la riga (0 - ${rows - 1}): ');
    String? rowInput = stdin.readLineSync();
    int? r = int.tryParse(rowInput ?? '');

    // 4. Chiediamo la colonna
    stdout.write('Inserisci la colonna (0 - ${cols - 1}): ');
    String? colInput = stdin.readLineSync();
    int? c = int.tryParse(colInput ?? '');

    // Validazione coordinate
    if (r == null || c == null || !game.board.isValidCoord(r, c)) {
      print('Coordinate non valide! Riprova.');
      continue;
    }

    // 5. Eseguiamo l'azione scelta
    if (actionInput == 'S') {
      // Controlliamo se la cella è già scoperta
      if (game.board.cells[r][c].isRevealed) {
        // Proviamo a fare il chording
        bool keepGoing = game.board.chordCell(r, c);
        if (!keepGoing) {
          isGameOver = true;
        }
      } else {
        // Comportamento normale di scoperta
        bool keepGoing = game.board.revealCell(r, c);
        if (!keepGoing) {
          isGameOver = true;
        }
      }
    } else if (actionInput == 'F') {
      game.board.toggleFlag(r, c);
    }

    // 6. Controlliamo se ha vinto (se non ha perso)
    if (!isGameOver && game.board.checkWinCondition()) {
      hasWon = true;
    }
  }

  stopwatch.stop();
  int elapsedSeconds = stopwatch.elapsedMilliseconds ~/ 1000;

  // Mostriamo il risultato finale
  if (hasWon) {
    game.board.printBoard(revealAll: true);
    print('\n🎉 COMPLIMENTI! Hai vinto in $elapsedSeconds secondi!');

    // Salviamo il punteggio nella Top 5
    bool isNewRecord = ScoreService.addScore(difficulty, elapsedSeconds);
    if (isNewRecord) {
      print('🌟 Nuovo record inserito nella Top 5!');
    }

    // Mostriamo la classifica dei migliori tempi
    print('\n--- TOP 5 TEMPI ($difficulty) ---');
    var topScores = ScoreService.getTopScores(difficulty);
    for (int i = 0; i < topScores.length; i++) {
      print('${i + 1}° posto: ${topScores[i]} secondi');
    }
  } else {
    // Sconfitta: sveliamo tutte le mine per far vedere dove stavano
    game.board.printBoard(revealAll: true);
    print('\n💥 BOOM! Hai calpestato una mina. Game Over.');
  }
}
