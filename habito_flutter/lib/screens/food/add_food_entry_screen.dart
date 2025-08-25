import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/validators.dart';
import '../../widgets/widgets.dart';

class AddFoodEntryScreen extends StatefulWidget {
  const AddFoodEntryScreen({super.key});

  @override
  State<AddFoodEntryScreen> createState() => _AddFoodEntryScreenState();
}

class _AddFoodEntryScreenState extends State<AddFoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _notesController = TextEditingController();

  MealCategory _selectedMealCategory = MealCategory.breakfast;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _servingSizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final createFoodEntry = CreateFoodEntry(
        foodName: _foodNameController.text.trim(),
        quantity: double.tryParse(_servingSizeController.text) ?? 1.0,
        calories: int.parse(_caloriesController.text),
        mealCategory: _selectedMealCategory,
        loggedAt: DateTime.now(),
      );

      await FoodService.createFoodEntry(createFoodEntry);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
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
        title: const Text('Add Food Entry'),
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
                
                // Food Name
                CustomTextFormField(
                  controller: _foodNameController,
                  labelText: 'Food Name',
                  prefixIcon: Icons.restaurant,
                  validator: Validators.foodName,
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 16),
                
                // Calories
                CustomTextFormField(
                  controller: _caloriesController,
                  labelText: 'Calories',
                  prefixIcon: Icons.local_fire_department,
                  keyboardType: TextInputType.number,
                  validator: Validators.calories,
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 16),
                
                // Quantity
                CustomTextFormField(
                  controller: _servingSizeController,
                  labelText: 'Quantity',
                  hintText: 'e.g., 1.5, 2, 0.5',
                  prefixIcon: Icons.straighten,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.positiveNumber,
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 16),
                
                // Meal Category
                Text(
                  'Meal Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<MealCategory>(
                      value: _selectedMealCategory,
                      isExpanded: true,
                      items: MealCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(_getMealIcon(category), size: 20),
                              const SizedBox(width: 12),
                              Text(_getMealLabel(category)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMealCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Notes (Optional)
                CustomTextFormField(
                  controller: _notesController,
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional notes...',
                  prefixIcon: Icons.note,
                  maxLines: 3,
                  validator: Validators.notes,
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
                  onPressed: _isLoading ? null : _submitFood,
                  isLoading: _isLoading,
                  child: const Text('Add Food Entry'),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMealIcon(MealCategory category) {
    switch (category) {
      case MealCategory.breakfast:
        return Icons.wb_sunny;
      case MealCategory.lunch:
        return Icons.wb_sunny_outlined;
      case MealCategory.dinner:
        return Icons.nightlight_round;
      case MealCategory.snack:
        return Icons.cookie;
    }
  }

  String _getMealLabel(MealCategory category) {
    switch (category) {
      case MealCategory.breakfast:
        return 'Breakfast';
      case MealCategory.lunch:
        return 'Lunch';
      case MealCategory.dinner:
        return 'Dinner';
      case MealCategory.snack:
        return 'Snack';
    }
  }
}