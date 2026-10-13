class ScoreService {
  // Manteniamo una lista di tempi (in secondi) per ogni difficoltà
  static final Map<String, List<int>> _topScores = {
    'Beginner': [],
    'Intermediate': [],
    'Expert': [],
  };

  // Aggiunge il punteggio e mantiene solo i primi 5 in ordine crescente
  static bool addScore(String difficulty, int seconds) {
    if (!_topScores.containsKey(difficulty)) {
      _topScores[difficulty] = [];
    }

    var scores = _topScores[difficulty]!;
    scores.add(seconds);
    scores.sort(); // Ordina dal più veloce al più lento

    if (scores.length > 5) {
      scores.removeLast(); // Teniamo solo i primi 5
    }

    // Ritorna true se il punteggio è entrato nella top 5
    return scores.contains(seconds);
  }

  static List<int> getTopScores(String difficulty) {
    return _topScores[difficulty] ?? [];
  }
}
