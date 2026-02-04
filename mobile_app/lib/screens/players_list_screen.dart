import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../widgets/star_rating.dart';
import 'player_form_sheet.dart';

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
      rating: '4.5',
      position: 'Levantador',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '2',
      name: 'Ph Nunes',
      rating: '4',
      position: 'Ponteiro',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '3',
      name: 'Royce',
      rating: '5',
      position: 'Oposto',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '4',
      name: 'Gabi',
      rating: '2',
      position: 'Líbero',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '5',
      name: 'Felipe',
      rating: '4.5',
      position: 'Qualquer',
      secondPosition: 'Qualquer',
    ),
    Player(
      id: '6',
      name: 'Rauan',
      rating: '3.5',
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
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: (SortOption item) {
              setState(() => _currentSort = item);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem(
                value: SortOption.nameAsc,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 20),
                    SizedBox(width: 8),
                    Text('Ordem Alfabética'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.ratingDesc,
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 20),
                    SizedBox(width: 8),
                    Text('Maior Nota'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.ratingAsc,
                child: Row(
                  children: [
                    Icon(Icons.trending_down, size: 20),
                    SizedBox(width: 8),
                    Text('Menor Nota'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.positionMain,
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 20),
                    SizedBox(width: 8),
                    Text('Posição Principal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.positionSec,
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Posição Secundária'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
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
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Ordenado por: ${_getSortLabel()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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

                                  Column(
                                    children: [
                                      StarRating(
                                        rating: double.parse(player.rating),
                                        size: 16,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
        onPressed: () => _openPlayerForm(null),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        label: const Text('+'),
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
