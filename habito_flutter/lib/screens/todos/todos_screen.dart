import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import 'add_todo_screen.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ResponsiveWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTodoScreen(),
                      ),
                    );
                    if (result == true) {
                      // Task was added successfully
                      // TODO: Refresh the tasks list
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Stay organized with your daily tasks (Maximum 3 priority tasks)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            const EmptyTodos(),
          ],
        ),
      ),
    );
  }
}