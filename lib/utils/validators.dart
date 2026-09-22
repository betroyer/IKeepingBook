class Validators {
  Validators._();

  static String? bookName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Book name cannot be empty';
    }
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final n = int.tryParse(value.trim());
    if (n == null) return 'Enter a whole number';
    if (n <= 0) return 'Quantity must be greater than 0';
    return null;
  }

  static String? category(String? value) {
    if (value == null || value.isEmpty) {
      return 'Select a category';
    }
    return null;
  }
}
