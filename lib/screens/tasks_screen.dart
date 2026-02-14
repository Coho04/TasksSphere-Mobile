import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

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
    DateTime? selectedDate = DateTime.now();
    TimeOfDay? selectedTime = TimeOfDay.now();
    String frequency = 'none';
    int interval = 1;
    List<int> selectedWeekdays = [];
    List<String> times = [];
    TimeOfDay? tempTime;
    String? recurrenceTimezone = 'Europe/Berlin'; // Default

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              AppLocalizations.of(context)!.newTask,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.whatToDo,
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.detailsOptional,
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  Text(AppLocalizations.of(context)!.dateAndTime,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          fontSize: 14)),
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
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 20),
                      label: Text(
                        selectedDate == null
                            ? AppLocalizations.of(context)!.noDate
                            : DateFormat('dd.MM.yyyy').format(selectedDate!),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  if (frequency == 'none') ...[
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
                          if (time != null) {
                            setState(() => selectedTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time, size: 20),
                        label: Text(
                          selectedTime == null
                              ? '--:--'
                              : selectedTime!.format(context),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  // Wiederholung Sektion
                  Text(AppLocalizations.of(context)!.repetition,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          fontSize: 14)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'none',
                          child: Text(AppLocalizations.of(context)!.once)),
                      DropdownMenuItem(
                          value: 'hourly',
                          child: Text(AppLocalizations.of(context)!.hourly)),
                      DropdownMenuItem(
                          value: 'daily',
                          child: Text(AppLocalizations.of(context)!.daily)),
                      DropdownMenuItem(
                          value: 'weekly',
                          child: Text(AppLocalizations.of(context)!.weekly)),
                      DropdownMenuItem(
                          value: 'monthly',
                          child: Text(AppLocalizations.of(context)!.monthly)),
                    ],
                    onChanged: (val) => setState(() => frequency = val!),
                  ),

                  if (frequency != 'none') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Intervall:",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: interval.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              final i = int.tryParse(val);
                              if (i != null) interval = i;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (frequency == 'weekly') ...[
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!.weekdays,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700])),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [1, 2, 3, 4, 5, 6, 7].map((day) {
                        final isSelected = selectedWeekdays.contains(day);
                        final dayLabels = {
                          1: 'Mo',
                          2: 'Di',
                          3: 'Mi',
                          4: 'Do',
                          5: 'Fr',
                          6: 'Sa',
                          7: 'So'
                        };
                        return FilterChip(
                          label: Text(dayLabels[day]!),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue[600],
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedWeekdays.add(day);
                              } else {
                                selectedWeekdays.remove(day);
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        );
                      }).toList(),
                    ),
                  ],

                  if (frequency != 'none') ...[
                    const SizedBox(height: 24),
                    Text(AppLocalizations.of(context)!.addTime,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: tempTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() => tempTime = time);
                              }
                            },
                            icon: const Icon(Icons.access_time, size: 22),
                            label: Text(
                              tempTime == null
                                  ? '--:--'
                                  : tempTime!.format(context),
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          onPressed: () {
                            if (tempTime != null) {
                              final timeStr =
                                  '${tempTime!.hour.toString().padLeft(2, '0')}:${tempTime!.minute.toString().padLeft(2, '0')}';
                              if (!times.contains(timeStr)) {
                                setState(() {
                                  times.add(timeStr);
                                  times.sort();
                                  tempTime = null;
                                });
                              }
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.add,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    if (times.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(AppLocalizations.of(context)!.timesForInterval,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700])),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: times.map((t) {
                          return Chip(
                            label: Text(
                                '$t ${AppLocalizations.of(context)!.uhr}',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                )),
                            backgroundColor: Colors.blue[50],
                            deleteIcon: Icon(Icons.close,
                                size: 18, color: Colors.blue[800]),
                            onDeleted: () => setState(() => times.remove(t)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.blue[200]!),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(color: Color(0xFF6b7280))),
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

                  Map<String, dynamic>? recurrenceRule;
                  if (frequency != 'none') {
                    recurrenceRule = {
                      'frequency': frequency,
                      'interval': interval,
                      'times': times,
                      'weekdays':
                          frequency == 'weekly' ? selectedWeekdays : [],
                    };
                  }

                  final success =
                      await Provider.of<TaskProvider>(context, listen: false)
                          .createTask(
                    titleController.text,
                    descController.text,
                    dueAt,
                    recurrenceRule: recurrenceRule,
                    recurrenceTimezone: recurrenceTimezone,
                  );
                  if (success && mounted) Navigator.of(ctx).pop();
                }
              },
              child: Text(AppLocalizations.of(context)!.create),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<dynamic>> _groupTasks(List<dynamic> tasks) {
    final Map<String, List<dynamic>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    for (var task in tasks) {
      if (task.plannedAt == null) {
        groups.putIfAbsent(AppLocalizations.of(context)!.noDate, () => []).add(task);
        continue;
      }

      final plannedDate = DateTime(
          task.plannedAt!.year, task.plannedAt!.month, task.plannedAt!.day);

      if (plannedDate.isBefore(today)) {
        groups.putIfAbsent(AppLocalizations.of(context)!.overdue, () => []).add(task);
      } else if (plannedDate.isAtSameMomentAs(today)) {
        groups.putIfAbsent(AppLocalizations.of(context)!.today, () => []).add(task);
      } else if (plannedDate.isAtSameMomentAs(tomorrow)) {
        groups.putIfAbsent(AppLocalizations.of(context)!.tomorrow, () => []).add(task);
      } else if (plannedDate.isBefore(nextWeek)) {
        final dayName = DateFormat('EEEE, dd.MM.', Localizations.localeOf(context).toString()).format(plannedDate);
        groups.putIfAbsent(dayName, () => []).add(task);
      } else {
        groups.putIfAbsent(AppLocalizations.of(context)!.later, () => []).add(task);
      }
    }
    return groups;
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? 'Benutzer'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.task_alt),
            title: Text(AppLocalizations.of(context)!.tasks),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(AppLocalizations.of(context)!.editProfile),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(AppLocalizations.of(context)!.logout, style: const TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              authProvider.logout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final groupedTasks = _groupTasks(taskProvider.tasks);
    final todayCount = taskProvider.tasks.where((t) => t.plannedAt != null &&
        t.plannedAt!.year == DateTime.now().year &&
        t.plannedAt!.month == DateTime.now().month &&
        t.plannedAt!.day == DateTime.now().day).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context, authProvider),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            floating: false,
            pinned: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.taskOverview,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.tasksToday(todayCount),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4b5563), // Gray-600
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (taskProvider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (taskProvider.tasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noTasksTitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.of(context)!.noTasksSubtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ...groupedTasks.entries.map((entry) {
              final groupTitle = entry.key;
              final tasks = entry.value;
              final Color groupColor = groupTitle == AppLocalizations.of(context)!.overdue
                  ? const Color(0xFFdc2626) // Red-600
                  : (groupTitle == AppLocalizations.of(context)!.today
                      ? const Color(0xFF2563eb) // Blue-600
                      : (groupTitle == AppLocalizations.of(context)!.tomorrow
                          ? const Color(0xFF4f46e5) // Indigo-600
                          : const Color(0xFF4b5563))); // Gray-600

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: groupColor.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              groupTitle.toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: groupColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: groupColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${tasks.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: groupColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final task = tasks[i];
                          final bool isCompleted = task.completedAt != null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                // Detailansicht oder Editieren
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (!isCompleted) {
                                          taskProvider.completeTask(task);
                                        }
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isCompleted
                                                ? const Color(0xFF10b981) // Green-500
                                                : const Color(0xFFe5e7eb), // Gray-200
                                            width: 2,
                                          ),
                                          color: isCompleted
                                              ? const Color(0xFF10b981)
                                              : const Color(0xFFf9fafb),
                                        ),
                                        child: isCompleted
                                            ? const Icon(Icons.check, size: 20, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                                              color: isCompleted
                                                  ? const Color(0xFF9ca3af) // Gray-400
                                                  : Theme.of(context).colorScheme.onSurface,
                                            ),
                                          ),
                                          if (task.description != null && task.description!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2.0),
                                              child: Text(
                                                task.description!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: const Color(0xFF6b7280), // Gray-500
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (task.plannedAt != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              DateFormat('H:mm').format(task.plannedAt!),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF2563eb),
                                                fontSize: 18,
                                                decoration: TextDecoration.underline,
                                                decorationThickness: 2,
                                                decorationColor: Color(0xFF2563eb),
                                              ),
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!.uhr,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF9ca3af),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: tasks.length,
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (taskProvider.completedTasks.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10b981), // Green-500
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.completedRecently,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final completion = taskProvider.completedTasks[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF10b981), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    completion.task.title,
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Color(0xFF6b7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.completedAtMinutes(completion.completedAt.difference(DateTime.now()).abs().inMinutes),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: taskProvider.completedTasks.length,
                ),
              ),
            ),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
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
