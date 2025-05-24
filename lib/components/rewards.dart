import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class Reward {
  String id;
  String title;
  String description;
  int points;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
  });

  factory Reward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reward(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      points: data['points'] ?? 0,
    );
  }
}

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final DatabaseService _db = DatabaseService();
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
                if (title.isNotEmpty &&
                    description.isNotEmpty &&
                    int.tryParse(pointsStr) != null) {
                  _db.createReward(title, description, int.parse(pointsStr));
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
          content: StreamBuilder<QuerySnapshot>(
            stream: _db.getUserRewards(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final rewards =
                  snapshot.data!.docs
                      .map((doc) => Reward.fromFirestore(doc))
                      .toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    rewards.map((reward) {
                      return ListTile(
                        title: Text(reward.title),
                        subtitle: Text(reward.description),
                        trailing: const Icon(Icons.delete),
                        onTap: () {
                          _db.deleteReward(reward.id);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  void _editReward() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecionar Recompensa'),
          content: StreamBuilder<QuerySnapshot>(
            stream: _db.getUserRewards(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final rewards =
                  snapshot.data!.docs
                      .map((doc) => Reward.fromFirestore(doc))
                      .toList();

              if (rewards.isEmpty) {
                return const Text('Nenhuma recompensa encontrada');
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    rewards.map((reward) {
                      return ListTile(
                        title: Text(reward.title),
                        subtitle: Text(reward.description),
                        trailing: Text('${reward.points} pontos'),
                        onTap: () {
                          Navigator.pop(context);
                          _showEditDialog(reward);
                        },
                      );
                    }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditDialog(Reward reward) {
    String title = reward.title;
    String description = reward.description;
    String pointsStr = reward.points.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Recompensa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Título'),
                controller: TextEditingController(text: title),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                controller: TextEditingController(text: description),
                onChanged: (value) => description = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Pontos'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: pointsStr),
                onChanged: (value) => pointsStr = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty &&
                    description.isNotEmpty &&
                    int.tryParse(pointsStr) != null) {
                  _db.updateReward(
                    reward.id,
                    title,
                    description,
                    int.parse(pointsStr),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _redeemReward(Reward reward) async {
    final canRedeem = await _db.canRedeemReward(reward.points);

    if (!canRedeem) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pontos insuficientes para resgatar esta recompensa!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Resgatar Recompensa'),
            content: Text(
              'Deseja resgatar "${reward.title}" por ${reward.points} pontos?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final success = await _db.redeemReward(
                      reward.id,
                      reward.points,
                    );
                    if (success) {
                      await _db.deleteReward(reward.id);
                    }

                    if (!mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Recompensa resgatada com sucesso!'
                              : 'Erro ao resgatar recompensa.',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao resgatar recompensa: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Resgatar'),
              ),
            ],
          ),
    );
  }

  Widget buildRewardCard(Reward reward) {
    return Card(
      child: InkWell(
        onTap: () => _redeemReward(reward),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Minhas Recompensas',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _db.getUserRewards(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final rewards =
                  snapshot.data?.docs
                      .map((doc) => Reward.fromFirestore(doc))
                      .toList() ??
                  [];

              if (rewards.isEmpty) {
                return const Center(
                  child: Text('Nenhuma recompensa encontrada'),
                );
              }

              return Column(
                children:
                    rewards.map((reward) => buildRewardCard(reward)).toList(),
              );
            },
          ),
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
              tooltip: 'Adicionar',
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'editReward',
              mini: true,
              onPressed: _editReward,
              tooltip: 'Editar',
              child: const Icon(Icons.edit),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'removeReward',
              mini: true,
              onPressed: _removeReward,
              tooltip: 'Remover',
              child: const Icon(Icons.delete),
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            onPressed: _toggleFab,
            tooltip: 'Menu',
            child: Icon(_fabExpanded ? Icons.close : Icons.menu),
          ),
        ],
      ),
    );
  }
}
