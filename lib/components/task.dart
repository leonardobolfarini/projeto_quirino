import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Minhas Tarefas',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Estudar Flutter'),
              subtitle: const Text('Avançar no projeto de tarefas e recompensas'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // placeholder de edição
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Lavar louça'),
              subtitle: const Text('Ajuda em casa'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // placeholder de edição
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // placeholder de adicionar
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
