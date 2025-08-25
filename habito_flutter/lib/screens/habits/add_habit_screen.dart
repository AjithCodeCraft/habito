import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/validators.dart';
import '../../widgets/widgets.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitHabit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user can create more habits
    final canCreate = await HabitService.canCreateMoreHabits();
    if (!canCreate) {
      setState(() {
        _errorMessage = 'You can only have 3 active habits at a time. Please deactivate an existing habit first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final createHabit = CreateHabit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      await HabitService.createHabit(createHabit);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
        centerTitle: true,
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Info Card
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can have up to 3 active habits at a time to maintain focus.',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Habit Name
                CustomTextFormField(
                  controller: _nameController,
                  labelText: 'Habit Name',
                  hintText: 'e.g., Drink 8 glasses of water',
                  prefixIcon: Icons.task_alt,
                  validator: Validators.habitName,
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 16),
                
                // Description (Optional)
                CustomTextFormField(
                  controller: _descriptionController,
                  labelText: 'Description (Optional)',
                  hintText: 'Why is this habit important to you?',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  validator: (value) => Validators.maxLength(value, 500, 'Description'),
                  textInputAction: TextInputAction.done,
                ),
                
                const SizedBox(height: 24),
                
                // Error Message
                if (_errorMessage != null)
                  ValidationErrorWidget(
                    message: _errorMessage!,
                    onDismiss: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                  ),
                
                // Submit Button
                CustomElevatedButton(
                  onPressed: _isLoading ? null : _submitHabit,
                  isLoading: _isLoading,
                  child: const Text('Create Habit'),
                ),
                
                const SizedBox(height: 16),
                
                // Tips Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tips for Success',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTip('Start small - choose habits you can do in 2 minutes'),
                        _buildTip('Be specific - "Exercise for 10 minutes" vs "Exercise more"'),
                        _buildTip('Stack habits - attach new habits to existing routines'),
                        _buildTip('Track consistently - even if you miss a day, get back on track'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}