import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/validators.dart';
import '../../widgets/widgets.dart';

class AddSleepEntryScreen extends StatefulWidget {
  const AddSleepEntryScreen({super.key});

  @override
  State<AddSleepEntryScreen> createState() => _AddSleepEntryScreenState();
}

class _AddSleepEntryScreenState extends State<AddSleepEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _bedTime = TimeOfDay.now();
  TimeOfDay _wakeTime = TimeOfDay.now().replacing(hour: (TimeOfDay.now().hour + 8) % 24);
  int? _qualityRating;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calculateDuration();
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateDuration() {
    final bedTimeMinutes = _bedTime.hour * 60 + _bedTime.minute;
    var wakeTimeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    
    // If wake time is earlier than bed time, assume next day
    if (wakeTimeMinutes <= bedTimeMinutes) {
      wakeTimeMinutes += 24 * 60;
    }
    
    final durationMinutes = wakeTimeMinutes - bedTimeMinutes;
    final hours = durationMinutes / 60;
    
    _durationController.text = hours.toStringAsFixed(1);
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime(bool isBedTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isBedTime ? _bedTime : _wakeTime,
    );
    
    if (time != null) {
      setState(() {
        if (isBedTime) {
          _bedTime = time;
        } else {
          _wakeTime = time;
        }
        _calculateDuration();
      });
    }
  }

  Future<void> _submitSleep() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Convert TimeOfDay to DateTime
      final bedtime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _bedTime.hour,
        _bedTime.minute,
      );
      
      var wakeDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _wakeTime.hour,
        _wakeTime.minute,
      );
      
      // If wake time is earlier than bed time, assume next day
      if (wakeDateTime.isBefore(bedtime)) {
        wakeDateTime = wakeDateTime.add(const Duration(days: 1));
      }

      final createSleepEntry = CreateSleepEntry(
        bedtime: bedtime,
        wakeTime: wakeDateTime,
        qualityRating: _qualityRating,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await SleepService.createSleepEntry(createSleepEntry);

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
        title: const Text('Log Sleep'),
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
                
                // Date Selection
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Sleep Date'),
                    subtitle: Text(_selectedDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _selectDate,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Time Selection
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.bedtime),
                          title: const Text('Bed Time'),
                          subtitle: Text(_bedTime.format(context)),
                          onTap: () => _selectTime(true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.wb_sunny),
                          title: const Text('Wake Time'),
                          subtitle: Text(_wakeTime.format(context)),
                          onTap: () => _selectTime(false),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Duration (Auto-calculated)
                CustomTextFormField(
                  controller: _durationController,
                  labelText: 'Sleep Duration (hours)',
                  prefixIcon: Icons.access_time,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.sleepHours,
                  readOnly: true,
                ),
                
                const SizedBox(height: 16),
                
                // Quality Rating
                Text(
                  'Sleep Quality (1-10)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(10, (index) {
                    final rating = index + 1;
                    final isSelected = _qualityRating == rating;
                    
                    return FilterChip(
                      label: Text('$rating'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _qualityRating = selected ? rating : null;
                        });
                      },
                    );
                  }),
                ),
                
                const SizedBox(height: 16),
                
                // Notes
                CustomTextFormField(
                  controller: _notesController,
                  labelText: 'Notes (Optional)',
                  hintText: 'How was your sleep?',
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
                  onPressed: _isLoading ? null : _submitSleep,
                  isLoading: _isLoading,
                  child: const Text('Log Sleep Entry'),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}