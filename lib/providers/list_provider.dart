import 'package:flutter/material.dart';
import '../models/task_list.dart';
import '../models/list_item.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class ListProvider with ChangeNotifier {
  List<TaskList> _lists = [];
  bool _isLoading = false;
  bool _isLocalMode = false;
  final ApiService _apiService = ApiService();
  final DatabaseService _db = DatabaseService();

  List<TaskList> get lists => _lists;
  bool get isLoading => _isLoading;

  void setLocalMode(bool local) {
    _isLocalMode = local;
  }

  Future<void> fetchLists() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_isLocalMode) {
        final db = await _db.database;
        final maps = await db.query('task_lists', orderBy: 'position');
        _lists = maps
            .map((m) => TaskList(
                  id: m['id'] as int,
                  title: m['title'] as String,
                  description: m['description'] as String?,
                  type: (m['type'] as String?) ?? 'checklist',
                  icon: m['icon'] as String?,
                  color: m['color'] as String?,
                  position: (m['position'] as int?) ?? 0,
                ))
            .toList();
      } else {
        final response = await _apiService.dio.get('/task-lists');
        if (response.statusCode == 200) {
          _lists = (response.data as List)
              .map((j) => TaskList.fromJson(j))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Fetch lists error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createList(String title, String type,
      {String? description, String? icon, String? color}) async {
    try {
      if (_isLocalMode) {
        final db = await _db.database;
        await db.insert('task_lists', {
          'title': title,
          'type': type,
          'description': description,
          'icon': icon,
          'color': color,
          'position': _lists.length,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        await _apiService.dio.post('/task-lists', data: {
          'title': title,
          'type': type,
          'description': description,
          'icon': icon,
          'color': color,
        });
      }
      await fetchLists();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteList(int id) async {
    try {
      if (_isLocalMode) {
        final db = await _db.database;
        await db.delete('task_lists', where: 'id = ?', whereArgs: [id]);
      } else {
        await _apiService.dio.delete('/task-lists/$id');
      }
      await fetchLists();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ListItem>> fetchItems(int listId) async {
    try {
      if (_isLocalMode) {
        final db = await _db.database;
        final maps = await db.query('list_items',
            where: 'task_list_id = ?',
            whereArgs: [listId],
            orderBy: 'position');
        return maps
            .map((m) => ListItem(
                  id: m['id'] as int,
                  taskListId: m['task_list_id'] as int,
                  title: m['title'] as String,
                  note: m['note'] as String?,
                  isCompleted: (m['is_completed'] as int) == 1,
                  position: (m['position'] as int?) ?? 0,
                ))
            .toList();
      } else {
        final response =
            await _apiService.dio.get('/task-lists/$listId/items');
        if (response.statusCode == 200) {
          return (response.data as List)
              .map((j) => ListItem.fromJson(j))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Fetch items error: $e');
    }
    return [];
  }

  Future<bool> addItem(int listId, String title, {String? note}) async {
    try {
      if (_isLocalMode) {
        final db = await _db.database;
        final maxPos = (await db.rawQuery(
                'SELECT MAX(position) as p FROM list_items WHERE task_list_id = ?',
                [listId]))[0]['p'] as int? ??
            -1;
        await db.insert('list_items', {
          'task_list_id': listId,
          'title': title,
          'note': note,
          'is_completed': 0,
          'position': maxPos + 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        await _apiService.dio
            .post('/task-lists/$listId/items', data: {'title': title, 'note': note});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleItem(int listId, int itemId, bool completed) async {
    try {
      if (_isLocalMode) {
        final db = await _db.database;
        await db.update(
            'list_items',
            {
              'is_completed': completed ? 1 : 0,
              'updated_at': DateTime.now().toIso8601String()
            },
            where: 'id = ?',
            whereArgs: [itemId]);
      } else {
        await _apiService.dio.put('/task-lists/$listId/items/$itemId',
            data: {'is_completed': completed});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(int listId, int itemId) async {
    try {
      if (_isLocalMode) {
        final db = await _db.database;
        await db.delete('list_items', where: 'id = ?', whereArgs: [itemId]);
      } else {
        await _apiService.dio.delete('/task-lists/$listId/items/$itemId');
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
