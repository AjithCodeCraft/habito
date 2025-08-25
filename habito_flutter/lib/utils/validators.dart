class Validators {
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (value.trim().length > 20) {
      return 'Username must not exceed 20 characters';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    if (value.length > 100) {
      return 'Password must not exceed 100 characters';
    }
    
    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  static String? number(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Value must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Value must not exceed $max';
    }
    
    return null;
  }

  static String? positiveNumber(String? value) {
    return number(value, min: 0.01);
  }

  static String? integer(String? value, {int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    
    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid whole number';
    }
    
    if (min != null && number < min) {
      return 'Value must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Value must not exceed $max';
    }
    
    return null;
  }

  static String? positiveInteger(String? value) {
    return integer(value, min: 1);
  }

  static String? calories(String? value) {
    return integer(value, min: 1, max: 10000);
  }

  static String? sleepHours(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sleep duration is required';
    }
    
    final hours = double.tryParse(value.trim());
    if (hours == null) {
      return 'Please enter a valid number';
    }
    
    if (hours < 0.1) {
      return 'Sleep duration must be at least 0.1 hours';
    }
    
    if (hours > 24) {
      return 'Sleep duration cannot exceed 24 hours';
    }
    
    return null;
  }

  static String? rating(String? value) {
    return integer(value, min: 1, max: 10);
  }

  static String? priority(String? value) {
    return integer(value, min: 1, max: 3);
  }

  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value != null && value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  static String? foodName(String? value) {
    final requiredResult = required(value, 'Food name');
    if (requiredResult != null) return requiredResult;
    
    return maxLength(value, 100, 'Food name');
  }

  static String? habitName(String? value) {
    final requiredResult = required(value, 'Habit name');
    if (requiredResult != null) return requiredResult;
    
    return maxLength(value, 100, 'Habit name');
  }

  static String? todoTitle(String? value) {
    final requiredResult = required(value, 'Task title');
    if (requiredResult != null) return requiredResult;
    
    return maxLength(value, 200, 'Task title');
  }

  static String? todoDescription(String? value) {
    return maxLength(value, 500, 'Description');
  }

  static String? notes(String? value) {
    return maxLength(value, 500, 'Notes');
  }
}