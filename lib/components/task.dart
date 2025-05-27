import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class Task {
  String id;
  String title;
  String description;
  int points;
  bool completed;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.completed = false,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      points: data['points'] ?? 0,
      completed: data['completed'] ?? false,
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final DatabaseService _db = DatabaseService();
  bool _fabExpanded = false;
  final Map<String, bool> _processingTasks = {};

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
                if (title.isNotEmpty &&
                    description.isNotEmpty &&
                    int.tryParse(pointsStr) != null) {
                  _db.createTask(title, description, int.parse(pointsStr));
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
          content: StreamBuilder<QuerySnapshot>(
            stream: _db.getUserTasks(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks =
                  snapshot.data!.docs
                      .map((doc) => Task.fromFirestore(doc))
                      .toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    tasks.map((task) {
                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.description),
                        trailing: const Icon(Icons.delete),
                        onTap: () {
                          _db.deleteTask(task.id);
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

  void _editTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecionar Tarefa'),
          content: StreamBuilder<QuerySnapshot>(
            stream: _db.getUserTasks(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks =
                  snapshot.data!.docs
                      .map((doc) => Task.fromFirestore(doc))
                      .toList();

              if (tasks.isEmpty) {
                return const Text('Nenhuma tarefa encontrada');
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    tasks.map((task) {
                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.description),
                        trailing: Text('${task.points} pontos'),
                        onTap: () {
                          Navigator.pop(context);
                          _showEditDialog(task);
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

  void _showEditDialog(Task task) {
    String title = task.title;
    String description = task.description;
    String pointsStr = task.points.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Tarefa'),
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
                  _db.updateTask(
                    task.id,
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

  Widget buildTaskCard(Task task) {
    final isProcessing = _processingTasks[task.id] ?? false;

    return Card(
      child: InkWell(
        onTap:
            isProcessing
                ? null
                : () async {
                  setState(() {
                    _processingTasks[task.id] = true;
                  });

                  try {
                    if (task.completed) {
                      await _db.uncompleteTask(task.id);
                    } else {
                      await _db.completeTask(task.id);
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _processingTasks[task.id] = false;
                      });
                    }
                  }
                },
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(task.description),
          trailing: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade200,
                child:
                    isProcessing
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                        : Text(
                          task.points.toString(),
                          style: const TextStyle(color: Colors.black),
                        ),
              ),
            ],
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
            'Minhas Tarefas',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _db.getUserTasks(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks =
                  snapshot.data?.docs
                      .map((doc) => Task.fromFirestore(doc))
                      .toList() ??
                  [];

              if (tasks.isEmpty) {
                return const Center(child: Text('Nenhuma tarefa encontrada'));
              }

              return Column(
                children: tasks.map((task) => buildTaskCard(task)).toList(),
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
              heroTag: 'addTask',
              mini: true,
              onPressed: _addTask,
              tooltip: 'Adicionar',
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'editTask',
              mini: true,
              onPressed: _editTask,
              tooltip: 'Editar',
              child: const Icon(Icons.edit),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'removeTask',
              mini: true,
              onPressed: _removeTask,
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
