import 'package:flutter/material.dart';

class Task {
  String title;
  String description;
  int points;

  Task({required this.title, required this.description, required this.points});
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<Task> _tasks = [
    Task(title: 'Estudar Flutter', description: 'Avançar no projeto', points: 20),
    Task(title: 'Lavar louça', description: 'Ajuda em casa', points: 10),
  ];

  bool _fabExpanded = false;

  void _toggleFab() {
    setState(() => _fabExpanded = !_fabExpanded);
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String description = '';
        String pointsStr = '';
        return AlertDialog(
          title: const Text('Nova Tarefa'),
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
                    _tasks.add(Task(
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

  void _removeTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: const Icon(Icons.delete),
                onTap: () {
                  setState(() => _tasks.removeAt(index));
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _editTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Função de edição ainda não implementada')),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description),
        trailing: CircleAvatar(
          backgroundColor: Colors.blue.shade200,
          child: Text(
            task.points.toString(),
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
          Text('Minhas Tarefas', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final task in _tasks) _buildTaskCard(task),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_fabExpanded) ...[
            FloatingActionButton(
              heroTag: 'addTask',
              mini: true,
              onPressed: _addTask,
              child: const Icon(Icons.add),
              tooltip: 'Adicionar',
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'editTask',
              mini: true,
              onPressed: _editTask,
              child: const Icon(Icons.edit),
              tooltip: 'Editar',
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'removeTask',
              mini: true,
              onPressed: _removeTask,
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
