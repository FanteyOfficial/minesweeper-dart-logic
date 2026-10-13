void main() {
  List<List<int>> board = [
    [0, 1, 0],
    [1, 1, 1],
    [0, 1, 0]
  ];
}

int print_board(List<List<int>> board) {
  for (var row in board) {
    print(row);
  }
  return 0;
}
