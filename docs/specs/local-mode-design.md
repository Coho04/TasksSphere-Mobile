# Local Mode — Design Spec

## Overview

Add offline/local storage mode to TasksSphere Mobile. Users choose at first launch:
- **Cloud**: Login with CodeSphere account (existing behavior)
- **Local**: Use app without account, SQLite storage on device

Later login migrates local data to cloud (one-time upload, then cloud-only).

## Storage Architecture

### Repository Pattern

Abstract data access behind `TaskRepository` interface. Two implementations:

```
TaskProvider → TaskRepository (interface)
                ├── CloudTaskRepository (existing API via Dio)
                └── LocalTaskRepository (SQLite via sqflite)
```

### Storage Mode

`SharedPreferences` key `storage_mode`:
- `null` → first launch, show onboarding
- `local` → use LocalTaskRepository
- `cloud` → use CloudTaskRepository

### SQLite Schema (sqflite)

**`tasks` table:**
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK AUTOINCREMENT | |
| title | TEXT NOT NULL | |
| description | TEXT | |
| due_at | TEXT (ISO8601) | |
| completed_at | TEXT (ISO8601) | |
| is_active | INTEGER DEFAULT 1 | |
| is_archived | INTEGER DEFAULT 0 | |
| recurrence_rule | TEXT (JSON) | |
| recurrence_timezone | TEXT | |
| task_list_id | INTEGER | FK to task_lists |
| created_at | TEXT | |
| updated_at | TEXT | |

**`task_completions` table:**
| Column | Type |
|--------|------|
| id | INTEGER PK AUTOINCREMENT |
| task_id | INTEGER NOT NULL |
| planned_at | TEXT |
| completed_at | TEXT |
| is_skipped | INTEGER DEFAULT 0 |

**`task_lists` table:**
| Column | Type |
|--------|------|
| id | INTEGER PK AUTOINCREMENT |
| title | TEXT NOT NULL |
| description | TEXT |
| type | TEXT DEFAULT 'checklist' |
| icon | TEXT |
| color | TEXT |
| position | INTEGER DEFAULT 0 |
| created_at | TEXT |
| updated_at | TEXT |

**`list_items` table:**
| Column | Type |
|--------|------|
| id | INTEGER PK AUTOINCREMENT |
| task_list_id | INTEGER NOT NULL |
| title | TEXT NOT NULL |
| note | TEXT |
| is_completed | INTEGER DEFAULT 0 |
| position | INTEGER DEFAULT 0 |
| created_at | TEXT |
| updated_at | TEXT |

## Repository Interface

```dart
abstract class TaskRepository {
  Future<List<Map<String, dynamic>>> getOccurrences(DateTime start, DateTime end);
  Future<List<Map<String, dynamic>>> getCompletedTasks();
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data);
  Future<void> completeTask(int taskId, String? plannedAt);
  Future<void> updateTask(int taskId, Map<String, dynamic> data);
  Future<void> deleteTask(int taskId);
}
```

## UI Changes

### Onboarding Screen (new)
- Shown on first launch (`storage_mode == null`)
- App logo/name at top
- Two cards:
  - "Mit Account" → navigates to LoginScreen
  - "Lokal nutzen" → sets `storage_mode = local`, navigates to TasksScreen
- Brief description under each option

### Login Screen (modified)
- Add "Ohne Account fortfahren" text button at bottom
- Tapping sets `storage_mode = local`, navigates to TasksScreen

### Tasks Screen (modified)
- In local mode: hide team switcher, profile sync
- Show subtle indicator "Lokaler Modus" in app bar or settings

### Settings/Profile (modified)
- In local mode: show "Mit Cloud verbinden" button
- Tapping opens LoginScreen
- After login: migration runs, mode switches to cloud

## Migration (Local → Cloud)

When user logs in from local mode:
1. Authenticate via API (get token)
2. Read all local tasks from SQLite
3. POST each task to API `/tasks`
4. Read all local task_lists from SQLite
5. POST each to API `/task-lists`
6. Read all local list_items
7. POST each to API `/task-lists/{id}/items`
8. Delete local SQLite database
9. Set `storage_mode = cloud`
10. Refresh from API

Error handling: if migration fails mid-way, keep local data, show error, let user retry.

## Files to Create/Modify

### New Files
- `lib/services/database_service.dart` — SQLite setup, migrations
- `lib/repositories/task_repository.dart` — interface
- `lib/repositories/cloud_task_repository.dart` — wraps ApiService
- `lib/repositories/local_task_repository.dart` — wraps DatabaseService
- `lib/services/migration_service.dart` — local→cloud migration
- `lib/screens/onboarding_screen.dart` — first-launch choice

### Modified Files
- `lib/main.dart` — routing logic for onboarding, repository injection
- `lib/providers/task_provider.dart` — use repository instead of direct API
- `lib/providers/auth_provider.dart` — handle local mode, migration trigger
- `lib/screens/login_screen.dart` — add "without account" option
- `lib/screens/tasks_screen.dart` — local mode indicator
- `pubspec.yaml` — add sqflite, path dependency

## Not in Local Mode
- Push notifications (no FCM)
- Team/Company features
- Profile sync
- Multi-device sync

## Package Dependencies
- `sqflite: ^2.4.0` — SQLite for Flutter
- `path: ^1.9.0` — path manipulation for DB location
