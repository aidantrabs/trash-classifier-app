import 'package:flutter_test/flutter_test.dart';
import 'package:trash_classifier_app/utils/validators.dart';

void main() {
  group('validateItemName', () {
    test('returns error for null', () {
      expect(validateItemName(null), 'Name cannot be empty');
    });

    test('returns error for empty string', () {
      expect(validateItemName(''), 'Name cannot be empty');
    });

    test('returns error for whitespace only string', () {
      expect(validateItemName('   '), 'Name cannot be empty');
    });

    test('returns error for forward slash', () {
      expect(validateItemName('foo/bar'), 'Name contains invalid characters');
    });

    test('returns error for backslash', () {
      expect(validateItemName(r'foo\bar'), 'Name contains invalid characters');
    });

    test('returns error for path traversal', () {
      expect(validateItemName('..'), 'Name contains invalid characters');
      expect(validateItemName('../etc'), 'Name contains invalid characters');
    });

    test('returns error for name over 100 characters', () {
      final longName = 'a' * 101;
      expect(validateItemName(longName), 'Name is too long');
    });

    test('accepts valid name', () {
      expect(validateItemName('My Bottle'), isNull);
    });

    test('accepts name at exactly 100 characters', () {
      final name = 'a' * 100;
      expect(validateItemName(name), isNull);
    });

    test('accepts name with special characters that are not path separators', () {
      expect(validateItemName('bottle (plastic)'), isNull);
      expect(validateItemName('item-123'), isNull);
      expect(validateItemName('my_item'), isNull);
    });
  });
}
