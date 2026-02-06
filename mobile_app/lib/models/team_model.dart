import '../models/player_model.dart';

class Team {
  final String name;
  final List<Player> players;

  Team({required this.name, required this.players});

  double get averageRating {
    if (players.isEmpty) return 0.0;
    final sum = players.fold(0.0, (prev, p) => prev + p.rating);
    return sum / players.length;
  }

  bool get hasSetter {
    return players.any(
      (p) => p.position == 'Levantador' || p.secondPosition == 'Levantador',
    );
  }
}
