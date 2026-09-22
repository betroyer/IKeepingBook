import 'package:flutter_test/flutter_test.dart';
import 'package:i_keeping_books/utils/password_hasher.dart';
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

  test('email validation', () {
    expect(Validators.email(null), isNotNull);
    expect(Validators.email('bad'), isNotNull);
    expect(Validators.email('you@library.test'), isNull);
  });

  test('password validation', () {
    expect(Validators.password('123'), isNotNull);
    expect(Validators.password('secret1'), isNull);
    expect(Validators.confirmPassword('a', 'b'), isNotNull);
    expect(Validators.confirmPassword('secret1', 'secret1'), isNull);
  });

  test('password hasher verifies', () {
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash('secret1', salt);
    expect(PasswordHasher.verify('secret1', salt, hash), isTrue);
    expect(PasswordHasher.verify('wrong', salt, hash), isFalse);
  });
}
