import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.iconSize = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 32),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyFoodEntries extends StatelessWidget {
  final VoidCallback? onAddFood;

  const EmptyFoodEntries({
    super.key,
    this.onAddFood,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.restaurant_menu,
      title: 'No food entries yet',
      message: 'Start tracking your meals to see your nutrition progress',
      action: onAddFood != null
          ? ElevatedButton.icon(
              onPressed: onAddFood,
              icon: const Icon(Icons.add),
              label: const Text('Add Food Entry'),
            )
          : null,
    );
  }
}

class EmptySleepEntries extends StatelessWidget {
  final VoidCallback? onAddSleep;

  const EmptySleepEntries({
    super.key,
    this.onAddSleep,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.bedtime,
      title: 'No sleep records yet',
      message: 'Track your sleep to monitor your rest patterns',
      action: onAddSleep != null
          ? ElevatedButton.icon(
              onPressed: onAddSleep,
              icon: const Icon(Icons.add),
              label: const Text('Add Sleep Entry'),
            )
          : null,
    );
  }
}

class EmptyHabits extends StatelessWidget {
  final VoidCallback? onAddHabit;

  const EmptyHabits({
    super.key,
    this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.task_alt,
      title: 'No habits yet',
      message: 'Create healthy habits to build a better routine',
      action: onAddHabit != null
          ? ElevatedButton.icon(
              onPressed: onAddHabit,
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            )
          : null,
    );
  }
}

class EmptyTodos extends StatelessWidget {
  final VoidCallback? onAddTodo;

  const EmptyTodos({
    super.key,
    this.onAddTodo,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.checklist,
      title: 'No tasks yet',
      message: 'Add tasks to stay organized and productive',
      action: onAddTodo != null
          ? ElevatedButton.icon(
              onPressed: onAddTodo,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            )
          : null,
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  final String searchQuery;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No results found',
      message: 'No results found for "$searchQuery".\nTry adjusting your search terms.',
    );
  }
}

class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      message: 'Please check your internet connection and try again',
      action: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          : null,
    );
  }
}