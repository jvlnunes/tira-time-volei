import 'package:flutter/material.dart';
import '../models/player_model.dart';

class PlayerFormSheet extends StatefulWidget {
  final Player? player;

  const PlayerFormSheet({super.key, this.player});

  @override
  State<PlayerFormSheet> createState() => _PlayerFormSheetState();
}

class _PlayerFormSheetState extends State<PlayerFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late String _position;
  late String _secondPosition;
  late double _rating;

  final List<String> _positions = [
    'Levantador',
    'Ponteiro',
    'Oposto',
    'Líbero',
    'Qualquer',
  ];

  final List<String> _secondPositions = [
    'Levantador',
    'Ponteiro',
    'Oposto',
    'Líbero',
    'Qualquer',
    'Nenhuma',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.player?.name ?? '');
    _position = widget.player?.position ?? _positions.last;
    _secondPosition = widget.player?.secondPosition ?? _secondPositions.last;
    double initialRating = double.tryParse(widget.player?.rating ?? '') ?? 3.0;
    if (initialRating < 0.5) {
      _rating = 0.5;
    } else {
      _rating = initialRating;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newPlayer = Player(
        id: widget.player?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        position: _position,
        secondPosition: _secondPosition,
        rating: _rating.toString(),
      );

      Navigator.of(context).pop(newPlayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  Text(
                    widget.player == null ? 'Novo Jogador' : 'Editar Jogador',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 28,
                    ),
                    onPressed: _submit,
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Jogador',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome do Jogador';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _position,
                      decoration: InputDecoration(
                        labelText: 'Posição Principal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.sports_volleyball),
                      ),
                      items: _positions.map((pos) {
                        return DropdownMenuItem(value: pos, child: Text(pos));
                      }).toList(),
                      onChanged: (value) => setState(() => _position = value!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _secondPosition,
                      decoration: InputDecoration(
                        labelText: 'Posição Secundária',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.sports_volleyball),
                      ),
                      items: _positions.map((pos) {
                        return DropdownMenuItem(value: pos, child: Text(pos));
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _secondPosition = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nota',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _rating < 0.5 ? 0.5 : _rating,
                    min: 0.5,
                    max: 5.0,
                    divisions: 9,
                    label: _rating.toString(),
                    activeColor: Colors.blueAccent,
                    onChanged: (val) => setState(() => _rating = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      if (_rating >= index + 1) {
                        return const Icon(Icons.star, color: Colors.amber);
                      }
                      if (_rating >= index + 0.5) {
                        return const Icon(Icons.star_half, color: Colors.amber);
                      }
                      return const Icon(Icons.star_border, color: Colors.amber);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
