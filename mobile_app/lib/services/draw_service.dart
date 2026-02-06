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
        } else {}
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
    List<Player> subs = [];

    if (remainingPool.length + (numberOfTeams) > maxCapacity) {
      int slotsLeft =
          maxCapacity - teamsBuckets.fold(0, (sum, t) => sum + t.length);
      if (remainingPool.length > slotsLeft) {
        int cutIndex = slotsLeft;
      }
    }
  }
}
