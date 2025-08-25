import '../config/api_config.dart';
import '../models/models.dart';
import 'http_service.dart';

class TodoService {
  // Get todos with optional filters
  static Future<List<Todo>> getTodos({
    bool? isCompleted,
    int? priority,
    int skip = 0,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    if (isCompleted != null) queryParams['is_completed'] = isCompleted.toString();
    if (priority != null) queryParams['priority'] = priority.toString();

    return await HttpService.getList<Todo>(
      endpoint: ApiConfig.todos,
      fromJson: (json) => Todo.fromJson(json),
      queryParams: queryParams,
      requiresAuth: true,
    );
  }

  // Create new todo
  static Future<Todo> createTodo(CreateTodo todo) async {
    return await HttpService.post<Todo>(
      endpoint: ApiConfig.todos,
      fromJson: (json) => Todo.fromJson(json),
      body: todo.toJson(),
      requiresAuth: true,
    );
  }

  // Get specific todo
  static Future<Todo> getTodo(String id) async {
    return await HttpService.get<Todo>(
      endpoint: '${ApiConfig.todos}/$id',
      fromJson: (json) => Todo.fromJson(json),
      requiresAuth: true,
    );
  }

  // Update todo
  static Future<Todo> updateTodo(String id, UpdateTodo todo) async {
    return await HttpService.put<Todo>(
      endpoint: '${ApiConfig.todos}/$id',
      fromJson: (json) => Todo.fromJson(json),
      body: todo.toJson(),
      requiresAuth: true,
    );
  }

  // Delete todo
  static Future<void> deleteTodo(String id) async {
    await HttpService.delete(
      endpoint: '${ApiConfig.todos}/$id',
      requiresAuth: true,
    );
  }

  // Mark todo as complete
  static Future<Todo> completeTodo(String id) async {
    return await HttpService.post<Todo>(
      endpoint: '${ApiConfig.todos}/$id/complete',
      fromJson: (json) => Todo.fromJson(json),
      requiresAuth: true,
    );
  }

  // Mark todo as incomplete
  static Future<Todo> uncompleteTodo(String id) async {
    return await HttpService.post<Todo>(
      endpoint: '${ApiConfig.todos}/$id/uncomplete',
      fromJson: (json) => Todo.fromJson(json),
      requiresAuth: true,
    );
  }

  // Get active (incomplete) todos
  static Future<List<Todo>> getActiveTodos() async {
    return await getTodos(isCompleted: false);
  }

  // Get completed todos
  static Future<List<Todo>> getCompletedTodos() async {
    return await getTodos(isCompleted: true);
  }

  // Get todos by priority
  static Future<List<Todo>> getTodosByPriority(int priority) async {
    return await getTodos(priority: priority, isCompleted: false);
  }

  // Get high priority todos
  static Future<List<Todo>> getHighPriorityTodos() async {
    return await getTodosByPriority(1);
  }

  // Get medium priority todos
  static Future<List<Todo>> getMediumPriorityTodos() async {
    return await getTodosByPriority(2);
  }

  // Get low priority todos
  static Future<List<Todo>> getLowPriorityTodos() async {
    return await getTodosByPriority(3);
  }

  // Toggle todo completion status
  static Future<Todo> toggleTodoCompletion(Todo todo) async {
    if (todo.isCompleted) {
      return await uncompleteTodo(todo.id);
    } else {
      return await completeTodo(todo.id);
    }
  }

  // Check if user can create more todos (max 3 priority todos)
  static Future<bool> canCreateMoreTodos() async {
    final activeTodos = await getActiveTodos();
    final priorityTodos = activeTodos.where((todo) => todo.priority <= 3).toList();
    return priorityTodos.length < 3;
  }

  // Get overdue todos
  static Future<List<Todo>> getOverdueTodos() async {
    final allTodos = await getActiveTodos();
    final now = DateTime.now();
    
    return allTodos.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.isBefore(now);
    }).toList();
  }

  // Get todos due soon (within next 24 hours)
  static Future<List<Todo>> getTodosDueSoon() async {
    final allTodos = await getActiveTodos();
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    return allTodos.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.isAfter(now) && todo.dueDate!.isBefore(tomorrow);
    }).toList();
  }

  // Get todos statistics
  static Future<Map<String, dynamic>> getTodoStatistics() async {
    final allTodos = await getTodos();
    final activeTodos = allTodos.where((todo) => !todo.isCompleted).toList();
    final completedTodos = allTodos.where((todo) => todo.isCompleted).toList();
    
    final overdue = activeTodos.where((todo) => todo.isOverdue).length;
    final dueSoon = activeTodos.where((todo) => todo.isDueSoon).length;
    
    final priorityCounts = <int, int>{1: 0, 2: 0, 3: 0};
    for (final todo in activeTodos) {
      priorityCounts[todo.priority] = (priorityCounts[todo.priority] ?? 0) + 1;
    }

    return {
      'total': allTodos.length,
      'active': activeTodos.length,
      'completed': completedTodos.length,
      'overdue': overdue,
      'dueSoon': dueSoon,
      'highPriority': priorityCounts[1] ?? 0,
      'mediumPriority': priorityCounts[2] ?? 0,
      'lowPriority': priorityCounts[3] ?? 0,
    };
  }

  // Sort todos by priority and due date
  static List<Todo> sortTodos(List<Todo> todos) {
    final sortedList = List<Todo>.from(todos);
    
    sortedList.sort((a, b) {
      // First sort by completion status (incomplete first)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      
      // Then by priority (1 = highest priority)
      if (a.priority != b.priority) {
        return a.priority.compareTo(b.priority);
      }
      
      // Then by due date (overdue first, then closest due date)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1; // a has due date, b doesn't
      } else if (b.dueDate != null) {
        return 1; // b has due date, a doesn't
      }
      
      // Finally by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return sortedList;
  }
}