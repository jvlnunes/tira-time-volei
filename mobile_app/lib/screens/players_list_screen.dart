import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../widgets/star_rating.dart';
import 'player_form_sheet.dart';
import 'pre_draw_screen.dart';

enum SortOption { nameAsc, ratingDesc, ratingAsc, positionMain, positionSec }

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({super.key});

  @override
  State<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  List<Player> _players = [
    Player(
      id: '1',
      name: 'Jv Nunes',
      rating: 4.5,
      position: 'Levantador',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '2',
      name: 'Ph Nunes',
      rating: 4,
      position: 'Ponteiro',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '3',
      name: 'Royce',
      rating: 5,
      position: 'Oposto',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '4',
      name: 'Gabi',
      rating: 2,
      position: 'Líbero',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '5',
      name: 'Felipe',
      rating: 4.5,
      position: 'Qualquer',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '6',
      name: 'Rauan',
      rating: 3.5,
      position: 'Qualquer',
      secondPosition: 'Levantador',
    ),
  ];

  Set<String> _selectedPlayerIds = {};
  String _searchQuery = '';
  SortOption _currentSort = SortOption.nameAsc;
  final TextEditingController _searchController = TextEditingController();

  List<Player> get _filteredAndSortedPlayers {
    List<Player> list = _players.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_currentSort) {
      case SortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.ratingDesc:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.ratingAsc:
        list.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case SortOption.positionMain:
        list.sort((a, b) => a.position.compareTo(b.position));
        break;
      case SortOption.positionSec:
        list.sort((a, b) => a.secondPosition.compareTo(b.secondPosition));
        break;
    }

    return list;
  }

  void _openPlayerForm(Player? player) async {
    final Player? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlayerFormSheet(player: player),
    );

    if (result != null) {
      setState(() {
        if (player == null) {
          _players.add(result);
          _selectedPlayerIds.add(result.id);
        } else {
          final index = _players.indexWhere((p) => p.id == result.id);
          if (index != -1) _players[index] = result;
        }
      });
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedPlayerIds.contains(id)) {
        _selectedPlayerIds.remove(id);
      } else {
        _selectedPlayerIds.add(id);
      }
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.sort, color: Colors.blueAccent),
                  SizedBox(width: 12),
                  Text(
                    'Ordenar por',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            _buildSortOption(
              SortOption.nameAsc,
              'Ordem Alfabética',
              Icons.sort_by_alpha,
            ),
            _buildSortOption(
              SortOption.ratingDesc,
              'Maior Nota',
              Icons.trending_up,
            ),
            _buildSortOption(
              SortOption.ratingAsc,
              'Menor Nota',
              Icons.trending_down,
            ),
            _buildSortOption(
              SortOption.positionMain,
              'Posição Principal',
              Icons.location_on,
            ),
            _buildSortOption(
              SortOption.positionSec,
              'Posição Secundária',
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(SortOption option, String label, IconData icon) {
    final isSelected = _currentSort == option;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blueAccent : Colors.grey.shade600,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blueAccent : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blueAccent)
          : null,
      onTap: () {
        setState(() => _currentSort = option);
        Navigator.pop(context);
      },
    );
  }

  String _getSortLabel() {
    switch (_currentSort) {
      case SortOption.nameAsc:
        return 'Nome (A-Z)';
      case SortOption.ratingDesc:
        return 'Maior Nota';
      case SortOption.ratingAsc:
        return 'Menor Nota';
      case SortOption.positionMain:
        return 'Posição Principal';
      case SortOption.positionSec:
        return 'Posição Secundária';
    }
  }

  IconData _getSortIcon() {
    switch (_currentSort) {
      case SortOption.nameAsc:
        return Icons.sort_by_alpha;
      case SortOption.ratingDesc:
        return Icons.trending_up;
      case SortOption.ratingAsc:
        return Icons.trending_down;
      case SortOption.positionMain:
        return Icons.location_on;
      case SortOption.positionSec:
        return Icons.location_on_outlined;
    }
  }

  void _goToPreDraw() {
    if (_selectedPlayerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um jogador para sortear times'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedPlayers = _players
        .where((player) => _selectedPlayerIds.contains(player.id))
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PreDrawScreen(selectedPlayers: selectedPlayers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredAndSortedPlayers;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_volleyball, size: 28),
            SizedBox(width: 8),
            Text('Racha Vôlei'),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, size: 28),
            tooltip: 'Adicionar Jogador',
            onPressed: () => _openPlayerForm(null),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          InkWell(
            onTap: _showSortOptions,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getSortIcon(), color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Ordenado por: ${_getSortLabel()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.expand_more, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar jogador...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedPlayerIds.length} selecionados',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${displayList.length} total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        final allIds = displayList.map((e) => e.id).toSet();
                        if (_selectedPlayerIds.containsAll(allIds)) {
                          _selectedPlayerIds.removeAll(allIds);
                        } else {
                          _selectedPlayerIds.addAll(allIds);
                        }
                      });
                    },
                    icon: Icon(
                      _selectedPlayerIds.containsAll(
                            displayList.map((e) => e.id),
                          )
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    label: const Text('Todos'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: displayList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum jogador encontrado',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(
                      bottom: 80,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: displayList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final player = displayList[index];
                      final isSelected = _selectedPlayerIds.contains(player.id);

                      return Dismissible(
                        key: Key(player.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirmar Exclusão'),
                              content: Text('Deseja excluir ${player.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          setState(() {
                            _players.removeWhere((p) => p.id == player.id);
                            _selectedPlayerIds.remove(player.id);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${player.name} foi removido'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Card(
                          elevation: isSelected ? 4 : 2,
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.white,
                          shadowColor: isSelected
                              ? Colors.blueAccent.withValues(alpha: 0.3)
                              : Colors.black12,
                          shape: RoundedRectangleBorder(
                            side: isSelected
                                ? const BorderSide(
                                    color: Colors.blueAccent,
                                    width: 2,
                                  )
                                : BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openPlayerForm(player),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.3,
                                    child: Checkbox(
                                      value: isSelected,
                                      activeColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) =>
                                          _toggleSelection(player.id),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            _buildBadge(
                                              player.position,
                                              Colors.blueAccent,
                                              Icons.sports_volleyball,
                                            ),
                                            if (player.secondPosition !=
                                                'Nenhuma')
                                              _buildBadge(
                                                player.secondPosition,
                                                Colors.grey.shade600,
                                                Icons
                                                    .sports_volleyball_outlined,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  StarRating(rating: player.rating, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToPreDraw,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.shuffle),
        label: const Text('Sortear Times'),
        elevation: 4,
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
