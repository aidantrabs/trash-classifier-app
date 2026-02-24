String? validateItemName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Name cannot be empty';
  }
  if (value.contains('/') || value.contains(r'\') || value.contains('..')) {
    return 'Name contains invalid characters';
  }
  if (value.trim().length > 100) {
    return 'Name is too long';
  }
  return null;
}
