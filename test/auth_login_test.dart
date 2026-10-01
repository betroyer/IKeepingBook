import 'package:flutter_test/flutter_test.dart';
import 'package:i_keeping_books/database/database_helper.dart';
import 'package:i_keeping_books/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Fresh in-memory DB per test via resetting the singleton's cached db
    // by opening a unique path is hard; use authenticate against createUser.
  });

  test('sign up then login succeeds with FFI database', () async {
    final helper = DatabaseHelper.instance;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final email = 'librarian$stamp@library.test';
    const password = 'secret1';

    final created = await helper.createUser(
      name: 'Test Librarian',
      email: email,
      password: password,
    );
    expect(created.email, email.toLowerCase());

    final auth = AuthProvider(helper: helper);
    final login = await auth.login(email: email, password: password);
    expect(login, AuthResult.success);
    expect(auth.isAuthenticated, isTrue);

    final bad = await auth.login(email: email, password: 'wrong!!');
    expect(bad, AuthResult.invalidCredentials);
  });
}
