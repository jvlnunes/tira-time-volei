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
          _selectedPlayerIds.add(
            result.id,
          ); // Já seleciona o novo jogador por conveniência
        } else {
          final index = _players.indexWhere((p) => p.id == result.id);
          if (index != -1) _players[index] = result;
        }
      });
    }
  }

  // Toggle Checkbox
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedPlayerIds.contains(id)) {
        _selectedPlayerIds.remove(id);
      } else {
        _selectedPlayerIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredAndSortedPlayers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Racha Vôlei'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // Menu de Ordenação
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (SortOption item) {
              setState(() => _currentSort = item);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem(
                value: SortOption.nameAsc,
                child: Text('Ordem Alfabética'),
              ),
              const PopupMenuItem(
                value: SortOption.ratingDesc,
                child: Text('Maior Nota'),
              ),
              const PopupMenuItem(
                value: SortOption.ratingAsc,
                child: Text('Menor Nota'),
              ),
              const PopupMenuItem(
                value: SortOption.positionMain,
                child: Text('Agrupar Posição (Princ.)'),
              ),
              const PopupMenuItem(
                value: SortOption.positionSec,
                child: Text('Agrupar Posição (Sec.)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Barra de Pesquisa ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar jogador...',
                prefixIcon: const Icon(Icons.search),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // --- Contador de Selecionados ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedPlayerIds.length} selecionados',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Selecionar/Deselecionar todos da lista filtrada
                    setState(() {
                      final allIds = displayList.map((e) => e.id).toSet();
                      if (_selectedPlayerIds.containsAll(allIds)) {
                        _selectedPlayerIds.removeAll(allIds);
                      } else {
                        _selectedPlayerIds.addAll(allIds);
                      }
                    });
                  },
                  child: const Text('Selecionar Todos'),
                ),
              ],
            ),
          ),

          // --- Lista de Jogadores ---
          Expanded(
            child: displayList.isEmpty
                ? const Center(child: Text('Nenhum jogador encontrado.'))
                : ListView.separated(
                    padding: const EdgeInsets.only(
                      bottom: 80,
                      left: 10,
                      right: 10,
                    ),
                    itemCount: displayList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (ctx, index) {
                      final player = displayList[index];
                      final isSelected = _selectedPlayerIds.contains(player.id);

                      return Card(
                        elevation: isSelected ? 4 : 1,
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
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
                          onTap: () => _openPlayerForm(
                            player,
                          ), // Editar ao clicar no corpo
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Checkbox
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: isSelected,
                                    activeColor: Colors.blueAccent,
                                    shape: const CircleBorder(),
                                    onChanged: (val) =>
                                        _toggleSelection(player.id),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Infos do Jogador
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
                                      const SizedBox(height: 4),
                                      // Badges de Posição
                                      Wrap(
                                        spacing: 4,
                                        children: [
                                          _buildBadge(
                                            player.position,
                                            Colors.blueAccent,
                                          ),
                                          if (player.secondPosition !=
                                              'Nenhuma')
                                            _buildBadge(
                                              player.secondPosition,
                                              Colors.grey,
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPlayerForm(null),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
