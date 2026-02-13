import '../models/player_model.dart';
import '../models/team_model.dart';
import 'dart:math';

class DrawService {
  static Map<String, dynamic> drawTeams({
    required List<Player> players,
    required int numberOfTeams,
    bool ensureSetters = true,
    bool balanceRatings = true,
  }) {
    if (players.isEmpty || numberOfTeams <= 0) {
      return {
        'teams': <Team>[],
        'subs': <Player>[],
        'warnings': ['Dados inválidos para sorteio'],
      };
    }

    List<Player> pool = List.from(players);
    List<List<Player>> teamsBuckets = List.generate(numberOfTeams, (_) => []);
    List<String> warnings = [];

    List<Player> mainSetters = [];
    List<Player> backupSetters = [];
    List<Player> others = [];

    for (var p in pool) {
      if (p.position == 'Levantador') {
        mainSetters.add(p);
      } else if (p.secondPosition == 'Levantador') {
        backupSetters.add(p);
      } else {
        others.add(p);
      }
    }

    others.shuffle();
    mainSetters.shuffle();
    backupSetters.shuffle();

    if (ensureSetters) {
      for (int i = 0; i < numberOfTeams; i++) {
        if (mainSetters.isNotEmpty) {
          teamsBuckets[i].add(mainSetters.removeAt(0));
        } else if (backupSetters.isNotEmpty) {
          teamsBuckets[i].add(backupSetters.removeAt(0));
        }
      }

      int teamsWithoutSetter = numberOfTeams;
      for (var bucket in teamsBuckets) {
        if (bucket.isNotEmpty) teamsWithoutSetter--;
      }

      if (teamsWithoutSetter > 0) {
        warnings.add(
          'Não há levantadores suficientes para todos os times ($teamsWithoutSetter sem levantador).',
        );
      }
    }

    List<Player> remainingPool = [...mainSetters, ...backupSetters, ...others];

    if (balanceRatings) {
      remainingPool.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      remainingPool.shuffle();
    }

    int standardSize = 6;
    int maxCapacity = numberOfTeams * standardSize;
    int currentOccupied = teamsBuckets.fold(0, (sum, t) => sum + t.length);
    List<Player> subs = [];

    if (remainingPool.length + currentOccupied > maxCapacity) {
      int slotsLeft = maxCapacity - currentOccupied;
      if (remainingPool.length > slotsLeft && slotsLeft >= 0) {
        subs = remainingPool.sublist(slotsLeft);
        remainingPool = remainingPool.sublist(0, slotsLeft);
        warnings.add('${subs.length} jogador(es) ficarão como reserva.');
      }
    }

    for (var player in remainingPool) {
      teamsBuckets.sort((a, b) {
        double sumA = a.fold(0.0, (sum, p) => sum + p.rating);
        double sumB = b.fold(0.0, (sum, p) => sum + p.rating);

        if (sumA != sumB) {
          return sumA.compareTo(sumB);
        }

        return a.length.compareTo(b.length);
      });

      teamsBuckets.first.add(player);
    }

    List<Team> finalTeams = [];
    for (int i = 0; i < numberOfTeams; i++) {
      final t = Team(name: 'Time ${i + 1}', players: teamsBuckets[i]);
      finalTeams.add(t);

      if (ensureSetters && !t.hasSetter) {
        warnings.add('O ${t.name} não tem levantador!');
      }
    }

    return {'teams': finalTeams, 'subs': subs, 'warnings': warnings};
  }

  static double calculateTeamBalance(List<Team> teams) {
    if (teams.length < 2) return 0.0;

    List<double> averages = teams.map((t) => t.averageRating).toList();
    double maxAvg = averages.reduce(max);
    double minAvg = averages.reduce(min);

    return maxAvg - minAvg;
  }

  static Map<String, dynamic> drawTeamsOptimized({
    required List<Player> players,
    required int numberOfTeams,
    bool ensureSetters = true,
    bool balanceRatings = true,
    int attempts = 10,
  }) {
    Map<String, dynamic>? bestDraw;
    double bestBalance = double.infinity;

    for (int i = 0; i < attempts; i++) {
      var draw = drawTeams(
        players: players,
        numberOfTeams: numberOfTeams,
        ensureSetters: ensureSetters,
        balanceRatings: balanceRatings,
      );

      List<Team> teams = draw['teams'] as List<Team>;
      double balance = calculateTeamBalance(teams);

      if (balance < bestBalance) {
        bestBalance = balance;
        bestDraw = draw;
      }

      // Se encontrou equilíbrio perfeito, retorna imediatamente
      if (balance < 0.1) break;
    }

    return bestDraw!;
  }
}
