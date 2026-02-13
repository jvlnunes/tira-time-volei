import 'package:flutter/material.dart';

class GameDayManagerScreen extends StatelessWidget {
  const GameDayManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Rachas'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_volleyball,
                size: 80,
                color: Colors.purple.shade300,
              ),
              const SizedBox(height: 24),
              const Text(
                'Gerenciador de Rachas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta funcionalidade será implementada em breve.\n\nAqui você poderá:\n• Criar rachas salvos\n• Gerenciar times\n• Acompanhar placar\n• Ver histórico',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
