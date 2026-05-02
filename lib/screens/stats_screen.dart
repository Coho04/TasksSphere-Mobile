import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final completedTasks = taskProvider.completedTasks;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Completed today
    final completedToday = completedTasks.where((c) {
      final d = c.completedAt;
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    }).length;

    // Completed this week
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final completedThisWeek = completedTasks.where((c) {
      final d = DateTime(c.completedAt.year, c.completedAt.month, c.completedAt.day);
      return !d.isBefore(weekStart) && !d.isAfter(today);
    }).length;

    // Completed this month
    final monthStart = DateTime(today.year, today.month, 1);
    final completedThisMonth = completedTasks.where((c) {
      final d = DateTime(c.completedAt.year, c.completedAt.month, c.completedAt.day);
      return !d.isBefore(monthStart) && !d.isAfter(today);
    }).length;

    // Completion rate (tasks due that were completed)
    final totalTasks = taskProvider.tasks.length + completedTasks.length;
    final completionRate = totalTasks > 0
        ? ((completedTasks.length / totalTasks) * 100).round()
        : 0;

    // Streak calculation
    int streak = 0;
    DateTime checkDay = today;
    while (true) {
      final hasCompletion = completedTasks.any((c) {
        final d = c.completedAt;
        return d.year == checkDay.year &&
            d.month == checkDay.month &&
            d.day == checkDay.day;
      });
      if (hasCompletion) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Statistik',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Erledigte Aufgaben',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9ca3af))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(context, 'Heute', '$completedToday',
                    const Color(0xFF10b981))),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, 'Diese Woche',
                    '$completedThisWeek', const Color(0xFF3b82f6))),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, 'Diesen Monat',
                    '$completedThisMonth', const Color(0xFF8b5cf6))),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Leistung',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9ca3af))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      context, 'Abschlussrate', '$completionRate%',
                      const Color(0xFFf59e0b)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                      context, 'Streak', '$streak Tage',
                      const Color(0xFFef4444)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Icon(
                    streak > 0 ? Icons.local_fire_department : Icons.emoji_events_outlined,
                    size: 48,
                    color: streak > 0 ? const Color(0xFFef4444) : const Color(0xFFf59e0b),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    streak > 0
                        ? 'Weiter so! $streak Tage in Folge!'
                        : 'Erledige eine Aufgabe, um deinen Streak zu starten!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6b7280),
            ),
          ),
        ],
      ),
    );
  }
}
