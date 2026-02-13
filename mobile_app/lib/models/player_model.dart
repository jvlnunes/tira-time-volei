class Player {
  final String id;
  final String name;
  final double rating;
  final String position;
  final String secondPosition;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.rating,
    required this.position,

    this.secondPosition = 'Nenhuma',

    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'position': position,
      'secondPosition': secondPosition,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      rating: (map['rating'] as num).toDouble(),
      position: map['position'] as String,
      secondPosition: map['secondPosition'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMicrosecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }
}
