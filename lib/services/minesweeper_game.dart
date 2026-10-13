import 'package:minesweeper/services/board.dart';

class MinesweeperGame {
  late Board board;

  MinesweeperGame({int rows = 9, int cols = 9, int mines = 10}) {
    board = Board(rows, cols, mines);
  }
}
