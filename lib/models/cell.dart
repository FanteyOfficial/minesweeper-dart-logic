class Cell {
  bool isMine;
  bool isRevealed; // Ho rinominato in isRevealed (o isTapped, come preferisci)
  bool isFlagged;
  int neighborMines; // Ci servirà per i numeri vicini!

  Cell({
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.neighborMines = 0,
  });
}
