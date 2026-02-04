class Player {
  final String id;
  final String name;
  final String rating;
  final String position;
  final String secondPosition;

  Player({
    required this.id,
    required this.name,
    required this.rating,
    required this.position,

    this.secondPosition = 'Nenhuma',
  });
}
