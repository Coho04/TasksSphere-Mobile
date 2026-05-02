import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/list_provider.dart';
import '../models/task_list.dart';
import '../models/list_item.dart';

class ListDetailScreen extends StatefulWidget {
  final TaskList taskList;

  const ListDetailScreen({super.key, required this.taskList});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  List<ListItem> _items = [];
  bool _isLoading = true;
  final _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await Provider.of<ListProvider>(context, listen: false)
        .fetchItems(widget.taskList.id);
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _addItem() async {
    if (_addController.text.isEmpty) return;
    final success = await Provider.of<ListProvider>(context, listen: false)
        .addItem(widget.taskList.id, _addController.text);
    if (success) {
      _addController.clear();
      await _loadItems();
    }
  }

  Future<void> _toggleItem(ListItem item) async {
    await Provider.of<ListProvider>(context, listen: false)
        .toggleItem(widget.taskList.id, item.id, !item.isCompleted);
    await _loadItems();
  }

  Future<void> _deleteItem(ListItem item) async {
    await Provider.of<ListProvider>(context, listen: false)
        .deleteItem(widget.taskList.id, item.id);
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              widget.taskList.type == 'checklist'
                  ? Icons.checklist
                  : Icons.task_alt,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.taskList.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Text('Keine Einträge',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 16)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          itemBuilder: (ctx, i) {
                            final item = _items[i];
                            return Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                              ),
                              onDismissed: (_) => _deleteItem(item),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withValues(alpha: 0.1)),
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: item.isCompleted,
                                    onChanged: (_) => _toggleItem(item),
                                    activeColor:
                                        Theme.of(context).colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                  ),
                                  title: Text(
                                    item.title,
                                    style: TextStyle(
                                      decoration: item.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: item.isCompleted
                                          ? const Color(0xFF9ca3af)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                  ),
                                  subtitle: item.note != null &&
                                          item.note!.isNotEmpty
                                      ? Text(item.note!,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6b7280)))
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    border: Border(
                      top: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addController,
                          decoration: InputDecoration(
                            hintText: 'Neuer Eintrag...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _addItem(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).colorScheme.primary,
                        iconSize: 36,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }
}
