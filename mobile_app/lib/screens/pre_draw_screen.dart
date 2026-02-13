import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../models/team_model.dart';
import '../services/draw_service.dart';
import 'draw_result_screen.dart';

class PreDrawScreen extends StatefulWidget {
  final List<Player> selectedPlayers;
  final bool isQuickDraw;

  const PreDrawScreen({
    super.key,
    required this.selectedPlayers,
    this.isQuickDraw = false,
  });

  @override
  State<PreDrawScreen> createState() => _PreDrawScreenState();
}

class _PreDrawScreenState extends State<PreDrawScreen> {
  int _numberOfTeams = 2;
  final int _standardPlayersPerTeam = 6;

  bool _balanceByRating = true;
  bool _ensureSetterPerTeam = true;
  bool _useOptimizedDraw = true;

  double get _averageRating {
    if (widget.selectedPlayers.isEmpty) return 0;
    double sum = widget.selectedPlayers.fold(
      0,
      (prev, player) => prev + player.rating,
    );
    return sum / widget.selectedPlayers.length;
  }

  int get _totalSlots => _numberOfTeams * _standardPlayersPerTeam;

  int get _reservePlayers {
    if (widget.selectedPlayers.length > _totalSlots) {
      return widget.selectedPlayers.length - _totalSlots;
    }
    return 0;
  }

  String get _realPlayersPerTeamText {
    if (widget.selectedPlayers.isEmpty) return "0";

    int base = widget.selectedPlayers.length ~/ _numberOfTeams;
    int resto = widget.selectedPlayers.length % _numberOfTeams;

    if (base >= 6) return "6";
    if (resto == 0) return "$base";
    return "$base a ${base + 1}";
  }

  void _performDraw() async {
    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // Aguarda um pouco para dar sensaÃ§Ã£o de processamento
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      Map<String, dynamic> result;

      if (_useOptimizedDraw) {
        result = DrawService.drawTeamsOptimized(
          players: widget.selectedPlayers,
          numberOfTeams: _numberOfTeams,
          ensureSetters: _ensureSetterPerTeam,
          balanceRatings: _balanceByRating,
          attempts: 20,
        );
      } else {
        result = DrawService.drawTeams(
          players: widget.selectedPlayers,
          numberOfTeams: _numberOfTeams,
          ensureSetters: _ensureSetterPerTeam,
          balanceRatings: _balanceByRating,
        );
      }

      if (!mounted) return;

      // Remove loading
      Navigator.pop(context);

      // Navega para resultado
      final shouldRedraw = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => DrawResultScreen(
            teams: result['teams'] as List<Team>,
            subs: result['subs'] as List<Player>,
            warnings: result['warnings'] as List<String>,
          ),
        ),
      );

      // Se retornou true, faz novo sorteio
      if (shouldRedraw == true && mounted) {
        _performDraw();
      }
    } catch (e) {
      if (!mounted) return;

      // Remove loading
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sortear times: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCustomTeamDialog() {
    TextEditingController customController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('NÃºmero de Times'),
        content: TextField(
          controller: customController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Digite a quantidade',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final int? val = int.tryParse(customController.text);
              if (val != null && val > 0) {
                setState(() => _numberOfTeams = val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Definir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Configurar Sorteio'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  icon: Icons.people,
                  label: 'Selecionados',
                  value: '${widget.selectedPlayers.length}',
                  color: Colors.white,
                ),
                _buildStatCard(
                  icon: Icons.groups,
                  label: 'Times',
                  value: '$_numberOfTeams',
                  color: Colors.white,
                ),
                _buildStatCard(
                  icon: Icons.star,
                  label: 'MÃ©dia Geral',
                  value: _averageRating.toStringAsFixed(1),
                  color: Colors.amber,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('NÃºmero de Times'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTeamOption(2),
                              _buildTeamOption(3),
                              _buildTeamOption(4),
                              _buildCustomTeamOption(),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_numberOfTeams > 4)
                            Text(
                              'Modo Personalizado: $_numberOfTeams times',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Estrutura dos Times'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sports_volleyball,
                              color: Colors.purple,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FormaÃ§Ã£o',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _realPlayersPerTeamText,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 6,
                                        left: 4,
                                      ),
                                      child: Text(
                                        '  jogadores em quadra',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_reservePlayers > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '+ $_reservePlayers reserva(s) rodando',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Regras do Sorteio'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text(
                            'Equilibrar por Habilidade',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _balanceByRating
                                ? 'Tenta manter a mÃ©dia de estrelas igual.'
                                : 'Sorteio totalmente aleatÃ³rio.',
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: _balanceByRating,
                          activeThumbColor: Colors.green,
                          secondary: const Icon(
                            Icons.balance,
                            color: Colors.green,
                          ),
                          onChanged: (val) =>
                              setState(() => _balanceByRating = val),
                        ),
                        const Divider(height: 1),

                        SwitchListTile(
                          title: const Text(
                            'Garantir Levantadores',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Pelo menos 1 levantador por time (se houver).',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _ensureSetterPerTeam,
                          activeThumbColor: Colors.blueAccent,
                          secondary: const Icon(
                            Icons.pan_tool_alt,
                            color: Colors.blueAccent,
                          ),
                          onChanged: (val) =>
                              setState(() => _ensureSetterPerTeam = val),
                        ),
                        const Divider(height: 1),

                        SwitchListTile(
                          title: const Text(
                            'Sorteio Otimizado',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Testa vÃ¡rias combinaÃ§Ãµes e escolhe a melhor.',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _useOptimizedDraw,
                          activeThumbColor: Colors.purple,
                          secondary: const Icon(
                            Icons.auto_awesome,
                            color: Colors.purple,
                          ),
                          onChanged: (val) =>
                              setState(() => _useOptimizedDraw = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Visualizando ${widget.selectedPlayers.length} jogadores disponÃ­veis',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _performDraw,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.shuffle, size: 28),
                  label: const Text(
                    'Gerar Times',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTeamOption(int number) {
    final isSelected = _numberOfTeams == number;
    return InkWell(
      onTap: () => setState(() => _numberOfTeams = number),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTeamOption() {
    final isCustom = _numberOfTeams > 4;
    return InkWell(
      onTap: _showCustomTeamDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isCustom ? Colors.blueAccent : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCustom ? Colors.blueAccent : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 30,
            color: isCustom ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
