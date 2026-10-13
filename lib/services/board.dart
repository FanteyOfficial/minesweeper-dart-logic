import 'dart:math';
import 'package:minesweeper/models/cell.dart';

class Board {
  final int rows;
  final int cols;
  final int totalMines;
  late List<List<Cell>> cells;
  bool _isFirstClick = true;

  Board(this.rows, this.cols, this.totalMines) {
    cells = List.generate(
      rows,
      (r) => List.generate(cols, (c) => Cell()),
    );
  }

  // 1. Posizionamento delle mine (escludendo il primo click)
  void _placeMines(int safeRow, int safeCol) {
    int minesPlaced = 0;
    final random = Random();

    while (minesPlaced < totalMines) {
      int r = random.nextInt(rows);
      int c = random.nextInt(cols);

      // Evitiamo di mettere una mina sulla cella cliccata o se c'è già
      if ((r == safeRow && c == safeCol) || cells[r][c].isMine) {
        continue;
      }

      cells[r][c].isMine = true;
      minesPlaced++;
    }

    // Una volta piazzate le mine, calcoliamo i numeri vicini
    _calculateNeighbors();
  }

  // 2. Calcolo delle mine vicine per ogni cella
  void _calculateNeighbors() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (cells[r][c].isMine) continue;

        int count = 0;
        // Controlliamo le 8 celle circostanti
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            int nr = r + dr;
            int nc = c + dc;

            if (isValidCoord(nr, nc) && cells[nr][nc].isMine) {
              count++;
            }
          }
        }
        cells[r][c].neighborMines = count;
      }
    }
  }

  // Metodo principale per scoprire una cella
  bool revealCell(int row, int col) {
    if (!isValidCoord(row, col) || cells[row][col].isRevealed || cells[row][col].isFlagged) {
      return true; // Già scoperta, con bandierina o non valida, non facciamo nulla
    }

    // Se è il primo click, generiamo le mine adesso!
    if (_isFirstClick) {
      _isFirstClick = false;
      _placeMines(row, col);
    }

    // Se becca una mina, il gioco è perso
    if (cells[row][col].isMine) {
      cells[row][col].isRevealed = true;
      return false; // Ritorna false = hai perso
    }

    // 3. Scopriamo la cella
    cells[row][col].isRevealed = true;

    // Se la cella ha 0 mine vicine, applichiamo il Flood Fill (apertura a catena)
    if (cells[row][col].neighborMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          int nr = row + dr;
          int nc = col + dc;
          if (isValidCoord(nr, nc) && !cells[nr][nc].isRevealed) {
            revealCell(nr, nc); // Chiamata ricorsiva
          }
        }
      }
    }

    return true; // Gioco continua
  }

  // Metodo per il Chording (click su una cella numerata già scoperta)
  bool chordCell(int row, int col) {
    // La cella deve essere valida e già scoperta (e avere un numero > 0)
    if (!isValidCoord(row, col)) return true;
    var cell = cells[row][col];

    if (!cell.isRevealed || cell.isMine || cell.neighborMines == 0) {
      return true; // Non è una cella numerata valida per il chording
    }

    // 1. Contiamo quante bandierine ci sono attorno a questa cella
    int flagCount = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        int nr = row + dr;
        int nc = col + dc;
        if (isValidCoord(nr, nc) && cells[nr][nc].isFlagged) {
          flagCount++;
        }
      }
    }

    // 2. Se il numero di bandierine corrisponde al numero della cella, procediamo ad aprire il resto
    if (flagCount == cell.neighborMines) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          int nr = row + dr;
          int nc = col + dc;

          if (isValidCoord(nr, nc)) {
            var neighborCell = cells[nr][nc];
            // Apriamo solo se non è bandierinata e non è scoperta
            if (!neighborCell.isFlagged && !neighborCell.isRevealed) {
              bool keepGoing = revealCell(nr, nc);
              if (!keepGoing) {
                return false; // Abbiamo beccato una mina nascosta male! Game Over
              }
            }
          }
        }
      }
    }

    return true;
  }

  void toggleFlag(int row, int col) {
    if (isValidCoord(row, col) && !cells[row][col].isRevealed) {
      cells[row][col].isFlagged = !cells[row][col].isFlagged;
    }
  }

  // Controlla se il giocatore ha vinto
  bool checkWinCondition() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        var cell = cells[r][c];
        // Se c'è una cella che NON ha una mina e NON è ancora scoperta, non abbiamo ancora vinto
        if (!cell.isMine && !cell.isRevealed) {
          return false;
        }
      }
    }
    return true; // Tutte le celle sicure sono state scoperte!
  }

  bool isValidCoord(int r, int c) {
    return r >= 0 && r < rows && c >= 0 && c < cols;
  }

  void printBoard({bool revealAll = false}) {
    print('\n    ' + List.generate(cols, (i) => '$i').join(' '));
    print('   ' + '-' * (cols * 2 + 1));

    for (int r = 0; r < rows; r++) {
      var rowStr = cells[r].map((cell) {
        if (revealAll || cell.isRevealed) {
          if (cell.isMine) return 'M';
          return cell.neighborMines == 0 ? '.' : '${cell.neighborMines}';
        } else if (cell.isFlagged) {
          return 'P';
        } else {
          return '■';
        }
      }).join(' ');

      print('$r | $rowStr |');
    }
    print('   ' + '-' * (cols * 2 + 1) + '\n');
  }
}
