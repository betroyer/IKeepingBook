import 'package:flutter_test/flutter_test.dart';
import 'package:i_keeping_books/utils/validators.dart';

void main() {
  test('book name validation', () {
    expect(Validators.bookName(null), isNotNull);
    expect(Validators.bookName(''), isNotNull);
    expect(Validators.bookName('  '), isNotNull);
    expect(Validators.bookName('Cosmos'), isNull);
  });

  test('quantity validation', () {
    expect(Validators.quantity('0'), isNotNull);
    expect(Validators.quantity('-1'), isNotNull);
    expect(Validators.quantity('abc'), isNotNull);
    expect(Validators.quantity('3'), isNull);
  });

  test('category validation', () {
    expect(Validators.category(null), isNotNull);
    expect(Validators.category(''), isNotNull);
    expect(Validators.category('Fiction Books'), isNull);
  });
}
