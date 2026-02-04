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
    _rating = initialRating < 0.5 ? 0.5 : initialRating;
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
                      color: Colors.blueAccent,
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
              const Divider(thickness: 1.5),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Jogador',
                  hintText: 'Digite o nome completo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Colors.blueAccent,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome do Jogador';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _position,
                      decoration: InputDecoration(
                        labelText: 'Posição Principal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.sports_volleyball,
                          color: Colors.blueAccent,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _positions.map((pos) {
                        return DropdownMenuItem(
                          value: pos,
                          child: Text(
                            pos,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _position = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _secondPosition,
                      decoration: InputDecoration(
                        labelText: 'Posição Secundária',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.sports_volleyball_outlined,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _secondPositions.map((pos) {
                        return DropdownMenuItem(
                          value: pos,
                          child: Text(
                            pos,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _secondPosition = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Avaliação',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.blueAccent,
                        inactiveTrackColor: Colors.blueAccent.withValues(
                          alpha: 0.3,
                        ),
                        thumbColor: Colors.blueAccent,
                        overlayColor: Colors.blueAccent.withValues(alpha: 0.2),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 20,
                        ),
                      ),
                      child: Slider(
                        value: _rating < 0.5 ? 0.5 : _rating,
                        min: 0.5,
                        max: 5.0,
                        divisions: 9,
                        label: _rating.toStringAsFixed(1),
                        onChanged: (val) => setState(() => _rating = val),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        if (_rating >= index + 1) {
                          return const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 28,
                          );
                        }
                        if (_rating >= index + 0.5) {
                          return const Icon(
                            Icons.star_half,
                            color: Colors.amber,
                            size: 28,
                          );
                        }
                        return Icon(
                          Icons.star_border,
                          color: Colors.amber.shade200,
                          size: 28,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
