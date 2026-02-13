import 'package:flutter/material.dart';
import 'players_list_screen.dart';
import 'gameday_manager_screen.dart';
import 'quick_draw_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_volleyball_sharp,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Racha Volei',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Organize seus Rachas de Vôlei',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    _buildMenuCard(
                      context: context,
                      title: 'Criar Racha',
                      subtitle: 'Organize um novo Racha',
                      icon: Icons.add_circle,
                      gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const GameDayManagerScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    _buildMenuCard(
                      context: context,
                      title: 'Sorteio Times',
                      subtitle: 'Faça um sorteio rápido',
                      icon: Icons.shuffle_rounded,
                      gradient: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const QuickDrawScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    _buildMenuCard(
                      context: context,
                      title: 'Ver Jogadores',
                      subtitle: 'Gerenciar cadastro',
                      icon: Icons.people,
                      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const PlayersListScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    _buildMenuCard(
                      context: context,
                      title: 'Configurações',
                      subtitle: 'Ajustes e preferências',
                      icon: Icons.settings,
                      gradient: [Color(0xFFfa709a), Color(0xFFfee140)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: .circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: .circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: .circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: .circular(16),
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),

              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: .bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
