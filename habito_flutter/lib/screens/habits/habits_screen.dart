import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import 'add_habit_screen.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

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
                  'Habits',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddHabitScreen(),
                      ),
                    );
                    if (result == true) {
                      // Habit was added successfully
                      // TODO: Refresh the habits list
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Habit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Build healthy routines (Maximum 3 active habits)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            const EmptyHabits(),
          ],
        ),
      ),
    );
  }
}