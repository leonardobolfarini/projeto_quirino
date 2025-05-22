import 'package:flutter/material.dart';

class Reward {
  String title;
  String description;
  int points;

  Reward({required this.title, required this.description, required this.points});
}

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final List<Reward> _rewards = [
    Reward(title: 'Chocolate', description: 'hm fome', points: 15),
    Reward(title: '10h de Minecraft', description: 'mine com os crias', points: 30),
  ];

  bool _fabExpanded = false;

  void _toggleFab() {
    setState(() => _fabExpanded = !_fabExpanded);
  }

  void _addReward() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String description = '';
        String pointsStr = '';
        return AlertDialog(
          title: const Text('Nova Recompensa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Título'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                onChanged: (value) => description = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Pontos'),
                keyboardType: TextInputType.number,
                onChanged: (value) => pointsStr = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && description.isNotEmpty && int.tryParse(pointsStr) != null) {
                  setState(() {
                    _rewards.add(Reward(
                      title: title,
                      description: description,
                      points: int.parse(pointsStr),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _removeReward() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover Recompensa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _rewards.asMap().entries.map((entry) {
              final index = entry.key;
              final reward = entry.value;
              return ListTile(
                title: Text(reward.title),
                subtitle: Text('${reward.description}'),
                trailing: const Icon(Icons.delete),
                onTap: () {
                  setState(() => _rewards.removeAt(index));
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _editReward() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Função de edição ainda não implementada')),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    return Card(
      child: ListTile(
        title: Text(reward.title),
        subtitle: Text(reward.description),
        trailing: CircleAvatar(
          backgroundColor: Colors.orange.shade200,
          child: Text(
            reward.points.toString(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Minhas Recompensas', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final reward in _rewards) _buildRewardCard(reward),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_fabExpanded) ...[
            FloatingActionButton(
              heroTag: 'addReward',
              mini: true,
              onPressed: _addReward,
              child: const Icon(Icons.add),
              tooltip: 'Adicionar',
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'editReward',
              mini: true,
              onPressed: _editReward,
              child: const Icon(Icons.edit),
              tooltip: 'Editar',
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'removeReward',
              mini: true,
              onPressed: _removeReward,
              child: const Icon(Icons.delete),
              tooltip: 'Remover',
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            onPressed: _toggleFab,
            child: Icon(_fabExpanded ? Icons.close : Icons.menu),
            tooltip: 'Menu',
          ),
        ],
      ),
    );
  }
}
