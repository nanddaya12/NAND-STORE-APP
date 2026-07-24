class InputValidators {
  // Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) return 'Invalid email address format';
    return null;
  }

  // Validate password complexity
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Password must contain a capital letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Password must contain a digit';
    return null;
  }

  // Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value.trim())) return 'Invalid phone number format';
    return null;
  }

  // Validate credit card number using Luhn Algorithm
  static String? validateCreditCard(String? value) {
    if (value == null || value.trim().isEmpty) return 'Card number is required';
    final cleanValue = value.replaceAll(RegExp(r'\s+|-'), '');
    if (cleanValue.length < 13 || cleanValue.length > 19) return 'Invalid card number length';
    
    int sum = 0;
    bool alternate = false;
    for (int i = cleanValue.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanValue[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      sum += digit;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) return 'Invalid credit card number';
    return null;
  }

  // Validate CVV
  static String? validateCvv(String? value) {
    if (value == null || value.trim().isEmpty) return 'CVV is required';
    final cvvRegExp = RegExp(r'^[0-9]{3,4}$');
    if (!cvvRegExp.hasMatch(value.trim())) return 'Invalid CVV (3 or 4 digits)';
    return null;
  }

  // Validate general inputs
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
