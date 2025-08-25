import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import 'add_sleep_entry_screen.dart';

class SleepOverviewScreen extends StatelessWidget {
  const SleepOverviewScreen({super.key});

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
                  'Sleep Tracking',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddSleepEntryScreen(),
                      ),
                    );
                    if (result == true) {
                      // Sleep entry was added successfully
                      // TODO: Refresh the sleep entries list
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Log Sleep'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const EmptySleepEntries(),
          ],
        ),
      ),
    );
  }
}