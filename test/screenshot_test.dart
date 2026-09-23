import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_keeping_books/app_shell.dart';
import 'package:i_keeping_books/models/book.dart';
import 'package:i_keeping_books/models/borrow_record.dart';
import 'package:i_keeping_books/providers/book_provider.dart';
import 'package:i_keeping_books/providers/borrow_provider.dart';
import 'package:i_keeping_books/providers/theme_provider.dart';
import 'package:i_keeping_books/services/book_service.dart';
import 'package:i_keeping_books/services/borrow_service.dart';
import 'package:i_keeping_books/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBorrowService extends BorrowService {
  @override
  Future<List<BorrowRecord>> fetchAll() async => [];
}

class FakeBookService extends BookService {
  FakeBookService(this._books);
  final List<Book> _books;

  @override
  Future<List<Book>> fetchAll() async => List.of(_books);

  @override
  Future<Book> add({
    required String name,
    required int quantity,
    required String category,
  }) async {
    final now = DateTime.now();
    final book = Book(
      id: _books.length + 1,
      name: name,
      quantity: quantity,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
    _books.add(book);
    return book;
  }

  @override
  Future<Book> update(Book book) async => book;

  @override
  Future<void> delete(int id) async => _books.removeWhere((b) => b.id == id);

  @override
  Future<void> clearAll() async => _books.clear();
}

List<Book> sampleBooks() {
  final now = DateTime.now();
  return [
    Book(
      id: 1,
      name: 'Introduction to Algorithms',
      quantity: 3,
      category: 'Textbooks',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
    ),
    Book(
      id: 2,
      name: 'The Left Hand of Darkness',
      quantity: 2,
      category: 'Fiction Books',
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now,
    ),
    Book(
      id: 3,
      name: 'Clean Code',
      quantity: 12,
      category: 'Technology Books',
      createdAt: now,
      updatedAt: now,
    ),
    Book(
      id: 4,
      name: 'Cosmos',
      quantity: 8,
      category: 'Science Books',
      createdAt: now,
      updatedAt: now,
    ),
    Book(
      id: 5,
      name: 'Oxford English Dictionary',
      quantity: 1,
      category: 'Reference Books',
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

Future<void> loadFonts() async {
  final poppins = FontLoader('Poppins');
  for (final file in [
    'assets/fonts/Poppins-Regular.ttf',
    'assets/fonts/Poppins-Medium.ttf',
    'assets/fonts/Poppins-SemiBold.ttf',
    'assets/fonts/Poppins-Bold.ttf',
  ]) {
    final bytes = await File(file).readAsBytes();
    poppins.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await poppins.load();

  final icons = FontLoader('MaterialIcons');
  final iconBytes =
      await File('assets/fonts/MaterialIcons-Regular.otf').readAsBytes();
  icons.addFont(Future.value(ByteData.view(iconBytes.buffer)));
  await icons.load();
}

Future<BookProvider> readyProvider() async {
  final provider = BookProvider(service: FakeBookService(sampleBooks()));
  await provider.load();
  return provider;
}

Widget wrapShell(BookProvider books, {int tab = 0}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider.value(value: books),
      ChangeNotifierProvider(
        create: (_) => BorrowProvider(service: FakeBorrowService())..load(),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppShell(initialIndex: tab),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await loadFonts();
  });

  testWidgets('phone home golden', (tester) async {
    final binding = tester.binding;
    await binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => binding.setSurfaceSize(null));

    final books = await readyProvider();
    await tester.pumpWidget(wrapShell(books));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/phone_home.png'),
    );
  });

  testWidgets('phone books golden', (tester) async {
    final binding = tester.binding;
    await binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => binding.setSurfaceSize(null));

    final books = await readyProvider();
    await tester.pumpWidget(wrapShell(books, tab: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/phone_books.png'),
    );
  });
}
