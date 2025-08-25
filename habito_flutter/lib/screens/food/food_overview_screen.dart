import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import 'add_food_entry_screen.dart';

class FoodOverviewScreen extends StatelessWidget {
  const FoodOverviewScreen({super.key});

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
                  'Food Tracking',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFoodEntryScreen(),
                      ),
                    );
                    if (result == true) {
                      // Food entry was added successfully
                      // TODO: Refresh the food entries list
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Food'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const EmptyFoodEntries(),
          ],
        ),
      ),
    );
  }
}