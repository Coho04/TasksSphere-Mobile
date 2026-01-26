import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TaskProvider>(context, listen: false).fetchTasks());
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neuer Task'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Was ist zu tun?',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Details (optional)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen', style: TextStyle(color: Color(0xFF6b7280))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final success = await Provider.of<TaskProvider>(context, listen: false)
                    .createTask(titleController.text, descController.text, null);
                if (success && mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/taskssphere_only_logo.png', height: 28),
            const SizedBox(width: 10),
            const Text('Meine Aufgaben'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => taskProvider.fetchTasks(),
              child: taskProvider.tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Keine Aufgaben gefunden',
                            style: TextStyle(color: Colors.grey[600], fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: taskProvider.tasks.length,
                      itemBuilder: (ctx, i) {
                        final task = taskProvider.tasks[i];
                        final bool isCompleted = task.completedAt != null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isCompleted ? 0 : 2,
                          color: isCompleted ? Colors.white.withValues(alpha: 0.6) : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: GestureDetector(
                              onTap: () {
                                if (!isCompleted) {
                                  taskProvider.completeTask(task);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isCompleted
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                  color: isCompleted ? Colors.green : Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: isCompleted
                                      ? const Icon(Icons.check, size: 20, color: Colors.white)
                                      : Icon(Icons.circle,
                                          size: 20, color: Colors.transparent),
                                ),
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.grey : Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.description != null && task.description!.isNotEmpty)
                                  Text(
                                    task.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isCompleted ? Colors.grey : Colors.black54,
                                    ),
                                  ),
                                if (task.plannedAt != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: Colors.blueGrey),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('dd.MM.yyyy HH:mm').format(task.plannedAt!),
                                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            isThreeLine: task.description != null && task.description!.isNotEmpty,
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
