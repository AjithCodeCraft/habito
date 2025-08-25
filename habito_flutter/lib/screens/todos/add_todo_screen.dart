import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/validators.dart';
import '../../widgets/widgets.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedPriority = 2; // Medium priority by default
  DateTime? _selectedDueDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _clearDueDate() {
    setState(() {
      _selectedDueDate = null;
    });
  }

  Future<void> _submitTodo() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user can create more todos
    final canCreate = await TodoService.canCreateMoreTodos();
    if (!canCreate) {
      setState(() {
        _errorMessage = 'You can only have 3 priority tasks at a time. Please complete or delete an existing task first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final createTodo = CreateTodo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );

      await TodoService.createTodo(createTodo);

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
        title: const Text('Add Task'),
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
                            'You can have up to 3 priority tasks at a time to stay focused.',
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
                
                // Task Title
                CustomTextFormField(
                  controller: _titleController,
                  labelText: 'Task Title',
                  hintText: 'What needs to be done?',
                  prefixIcon: Icons.check_box_outline_blank,
                  validator: Validators.todoTitle,
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 16),
                
                // Description (Optional)
                CustomTextFormField(
                  controller: _descriptionController,
                  labelText: 'Description (Optional)',
                  hintText: 'Add more details about this task...',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  validator: Validators.todoDescription,
                  textInputAction: TextInputAction.done,
                ),
                
                const SizedBox(height: 16),
                
                // Priority Selection
                Text(
                  'Priority',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriorityChip(1, 'High', Colors.red, Icons.arrow_upward),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityChip(2, 'Medium', Colors.orange, Icons.remove),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityChip(3, 'Low', Colors.green, Icons.arrow_downward),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Due Date
                Text(
                  'Due Date (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _selectedDueDate != null
                          ? _selectedDueDate!.toString().split(' ')[0]
                          : 'No due date set',
                    ),
                    trailing: _selectedDueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearDueDate,
                          )
                        : const Icon(Icons.arrow_forward_ios),
                    onTap: _selectDueDate,
                  ),
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
                  onPressed: _isLoading ? null : _submitTodo,
                  isLoading: _isLoading,
                  child: const Text('Create Task'),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(int priority, String label, Color color, IconData icon) {
    final isSelected = _selectedPriority == priority;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : null,
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}