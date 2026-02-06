class Player {
  final String id;
  final String name;
  final double rating;
  final String position;
  final String secondPosition;

  Player({
    required this.id,
    required this.name,
    required this.rating,
    required this.position,

    this.secondPosition = 'Nenhuma',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'position': position,
      'secondPosition': secondPosition,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      rating: (map['rating'] as num).toDouble(),
      position: map['position'] as String,
      secondPosition: map['secondPosition'] as String ?? 'Nenhuma',
    );
  }
}
