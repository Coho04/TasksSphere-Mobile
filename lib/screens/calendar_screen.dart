import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
  }

  void _previousWeek() {
    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  }

  void _nextWeek() {
    setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
  }

  List<Task> _tasksForDay(List<Task> allTasks, DateTime day) {
    return allTasks.where((t) {
      if (t.plannedAt == null) return false;
      return t.plannedAt!.year == day.year &&
          t.plannedAt!.month == day.month &&
          t.plannedAt!.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days =
        List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Kalender',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          // Week navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousWeek,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${DateFormat('dd. MMM', 'de').format(_weekStart)} - ${DateFormat('dd. MMM yyyy', 'de').format(_weekStart.add(const Duration(days: 6)))}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  onPressed: _nextWeek,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          // Day headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: days.map((day) {
                final isToday = day.isAtSameMomentAs(today);
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E', 'de').format(day).substring(0, 2),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFF6b7280),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          // Task columns
          Expanded(
            child: taskProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: days.map((day) {
                          final dayTasks =
                              _tasksForDay(taskProvider.tasks, day);
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Column(
                                children: dayTasks.isEmpty
                                    ? [
                                        const SizedBox(height: 20),
                                        Icon(Icons.remove,
                                            size: 16,
                                            color: Colors.grey[400]),
                                      ]
                                    : dayTasks.map((task) {
                                        return _buildTaskChip(
                                            context, task, taskProvider);
                                      }).toList(),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskChip(
      BuildContext context, Task task, TaskProvider taskProvider) {
    return GestureDetector(
      onTap: () => _showTaskOptions(context, task, taskProvider),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (task.plannedAt != null)
              Text(
                DateFormat('H:mm').format(task.plannedAt!),
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTaskOptions(
      BuildContext context, Task task, TaskProvider taskProvider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline,
                  color: Color(0xFF10b981)),
              title: const Text('Erledigen'),
              onTap: () {
                Navigator.pop(ctx);
                taskProvider.completeTask(task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Bearbeiten'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditTaskDialog(context, task, taskProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text('Löschen', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Aufgabe löschen?'),
                    content: Text(
                        'Möchtest du "${task.title}" wirklich löschen?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Abbrechen')),
                      TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Löschen',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await taskProvider.deleteTask(task.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(
      BuildContext context, Task task, TaskProvider taskProvider) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description ?? '');
    DateTime? selectedDate = task.dueAt;
    TimeOfDay? selectedTime = task.dueAt != null
        ? TimeOfDay(hour: task.dueAt!.hour, minute: task.dueAt!.minute)
        : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Aufgabe bearbeiten',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Titel',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Beschreibung',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                      icon: const Icon(Icons.calendar_today, size: 20),
                      label: Text(
                        selectedDate == null
                            ? 'Kein Datum'
                            : DateFormat('dd.MM.yyyy').format(selectedDate!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (time != null) setState(() => selectedTime = time);
                      },
                      icon: const Icon(Icons.access_time, size: 20),
                      label: Text(
                        selectedTime == null
                            ? '--:--'
                            : selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Abbrechen',
                  style: TextStyle(color: Color(0xFF6b7280))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  DateTime? dueAt;
                  if (selectedDate != null) {
                    dueAt = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime?.hour ?? 0,
                      selectedTime?.minute ?? 0,
                    );
                  }
                  await taskProvider.updateTask(
                    task.id,
                    titleController.text,
                    descController.text.isEmpty ? null : descController.text,
                    dueAt,
                    recurrenceRule: task.recurrenceRule,
                    recurrenceTimezone: task.recurrenceTimezone,
                  );
                  if (mounted) Navigator.of(ctx).pop();
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
