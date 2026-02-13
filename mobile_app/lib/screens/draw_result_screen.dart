import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../models/player_model.dart';
import '../widgets/star_rating.dart';

class DrawResultScreen extends StatefulWidget {
  final List<Team> teams;
  final List<Player> subs;
  final List<String> warnings;

  const DrawResultScreen({
    super.key,
    required this.teams,
    required this.subs,
    required this.warnings,
  });

  @override
  State<DrawResultScreen> createState() => _DrawResultScreenState();
}

class _DrawResultScreenState extends State<DrawResultScreen> {
  late List<Team> _teams;
  late List<Player> _subs;

  @override
  void initState() {
    super.initState();
    _teams = widget.teams;
    _subs = widget.subs;
  }

  void _removePlayerFromTeam(Team team, Player player) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Jogador'),
        content: Text(
          'Deseja remover ${player.name} do ${team.name}?\n\nIsso irá desbalancear os times.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        final teamIndex = _teams.indexWhere((t) => t.name == team.name);
        if (teamIndex != -1) {
          final updatedPlayers = List<Player>.from(_teams[teamIndex].players);
          updatedPlayers.removeWhere((p) => p.id == player.id);
          _teams[teamIndex] = Team(
            name: _teams[teamIndex].name,
            players: updatedPlayers,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${player.name} foi removido do ${team.name}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _acceptDrawAndGoToMatch() {
    // Validação: pelo menos 2 times com jogadores
    final teamsWithPlayers = _teams.where((t) => t.players.isNotEmpty).length;
    if (teamsWithPlayers < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'É necessário pelo menos 2 times com jogadores para iniciar o racha',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => MatchScreen(
          teams: _teams.where((t) => t.players.isNotEmpty).toList(),
          subs: _subs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Times Sorteados'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sortear Novamente',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Warnings se houver
          if (widget.warnings.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Avisos:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...widget.warnings.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(left: 32, bottom: 4),
                      child: Text(
                        '• $w',
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Estatísticas gerais
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  icon: Icons.groups,
                  label: 'Times',
                  value: '${_teams.length}',
                  color: Colors.white,
                ),
                _buildStatCard(
                  icon: Icons.person_outline,
                  label: 'Reservas',
                  value: '${_subs.length}',
                  color: Colors.white,
                ),
                _buildStatCard(
                  icon: Icons.analytics_outlined,
                  label: 'Variação',
                  value: _getBalanceText(),
                  color: Colors.amber.shade300,
                ),
              ],
            ),
          ),

          // Lista de times
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: _teams.length + (_subs.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _teams.length) {
                  return _buildTeamCard(_teams[index], index);
                } else {
                  return _buildSubsCard();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'accept',
            onPressed: _acceptDrawAndGoToMatch,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.check_circle),
            label: const Text('Aceitar e Iniciar Racha'),
            elevation: 6,
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'back',
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade700,
            child: const Icon(Icons.arrow_back),
          ),
        ],
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
          style: TextStyle(color: color.withOpacity(0.9), fontSize: 11),
        ),
      ],
    );
  }

  String _getBalanceText() {
    if (_teams.isEmpty) return '0.0';

    List<double> averages = _teams.map((t) => t.averageRating).toList();
    double maxAvg = averages.reduce((a, b) => a > b ? a : b);
    double minAvg = averages.reduce((a, b) => a < b ? a : b);
    double diff = maxAvg - minAvg;

    return diff.toStringAsFixed(1);
  }

  Widget _buildTeamCard(Team team, int index) {
    // Paleta de cores mais suaves e modernas
    final gradients = [
      [Color(0xFF667eea), Color(0xFF764ba2)], // Roxo
      [Color(0xFFf093fb), Color(0xFFf5576c)], // Rosa
      [Color(0xFF4facfe), Color(0xFF00f2fe)], // Azul claro
      [Color(0xFF43e97b), Color(0xFF38f9d7)], // Verde água
      [Color(0xFFfa709a), Color(0xFFfee140)], // Rosa/Amarelo
      [Color(0xFF30cfd0), Color(0xFF330867)], // Azul/Roxo
    ];

    final gradient = gradients[index % gradients.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          // Cabeçalho do time
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.groups,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${team.players.length} jogadores',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(
                        team.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de jogadores
          if (team.players.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time vazio',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: team.players.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, idx) {
                final player = team.players[idx];
                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            player.position +
                                (player.secondPosition != 'Nenhuma'
                                    ? ' / ${player.secondPosition}'
                                    : ''),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StarRating(rating: player.rating, size: 14),
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                      onPressed: () => _removePlayerFromTeam(team, player),
                      tooltip: 'Remover jogador',
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubsCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.orange.shade200, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.people_outline,
                    color: Colors.orange.shade700,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Reservas (${_subs.length})',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _subs.length,
            separatorBuilder: (_, __) => const Divider(height: 20),
            itemBuilder: (context, idx) {
              final player = _subs[idx];
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          player.position +
                              (player.secondPosition != 'Nenhuma'
                                  ? ' / ${player.secondPosition}'
                                  : ''),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StarRating(rating: player.rating, size: 14),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Tela temporária do Match - será implementada completamente depois
class MatchScreen extends StatelessWidget {
  final List<Team> teams;
  final List<Player> subs;

  const MatchScreen({super.key, required this.teams, required this.subs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Racha em Andamento'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_volleyball, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Tela de Racha',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${teams.length} times • ${subs.length} reservas',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Aqui será implementado o controle de pontuação, rotação de jogadores reservas, e histórico das partidas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
