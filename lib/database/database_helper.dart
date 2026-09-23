import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import '../models/book.dart';
import '../models/borrow_record.dart';
import '../utils/constants.dart';
import '../utils/password_hasher.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createBooks(db);
        await _createUsers(db);
        await _createBorrows(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createUsers(db);
        }
        if (oldVersion < 3) {
          await _createBorrows(db);
        }
        if (oldVersion < 4) {
          await _upgradeBorrowsToV4(db);
        }
      },
    );
  }

  Future<void> _createBooks(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createUsers(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createBorrows(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS borrows (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        book_name TEXT NOT NULL,
        student_full_name TEXT NOT NULL,
        student_id TEXT NOT NULL,
        student_email TEXT NOT NULL DEFAULT '',
        email_verified INTEGER NOT NULL DEFAULT 0,
        student_level TEXT NOT NULL,
        program TEXT NOT NULL,
        year_level TEXT NOT NULL,
        borrowed_at TEXT NOT NULL,
        due_date TEXT NOT NULL,
        returned_at TEXT,
        reminder_sent INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (book_id) REFERENCES books (id)
      )
    ''');
  }

  Future<void> _upgradeBorrowsToV4(Database db) async {
    final info = await db.rawQuery('PRAGMA table_info(borrows)');
    final names = info.map((r) => r['name'] as String).toSet();
    if (names.isEmpty) {
      await _createBorrows(db);
      return;
    }
    if (!names.contains('student_email')) {
      await db.execute(
        "ALTER TABLE borrows ADD COLUMN student_email TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!names.contains('email_verified')) {
      await db.execute(
        'ALTER TABLE borrows ADD COLUMN email_verified INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!names.contains('reminder_sent')) {
      await db.execute(
        'ALTER TABLE borrows ADD COLUMN reminder_sent INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<int> insertBook(Book book) async {
    final db = await database;
    return db.insert('books', book.toMap()..remove('id'));
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final rows = await db.query('books', orderBy: 'created_at DESC');
    return rows.map(Book.fromMap).toList();
  }

  Future<Book?> getBookById(int id) async {
    final db = await database;
    final rows = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Book.fromMap(rows.first);
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAll() async {
    final db = await database;
    return db.delete('books');
  }

  Future<List<Book>> searchByName(String query) async {
    final db = await database;
    final rows = await db.query(
      'books',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Book.fromMap).toList();
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<bool> emailExists(String email) async {
    return (await getUserByEmail(email)) != null;
  }

  Future<AppUser> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);
    final now = DateTime.now().toIso8601String();
    final id = await db.insert('users', {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password_hash': hash,
      'salt': salt,
      'created_at': now,
    });
    return AppUser(
      id: id,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      createdAt: DateTime.parse(now),
    );
  }

  Future<AppUser?> authenticate({
    required String email,
    required String password,
  }) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final ok = PasswordHasher.verify(
      password,
      row['salt'] as String,
      row['password_hash'] as String,
    );
    if (!ok) return null;
    return AppUser.fromMap(row);
  }

  Future<List<BorrowRecord>> getAllBorrows() async {
    final db = await database;
    final rows = await db.query('borrows', orderBy: 'borrowed_at DESC');
    return rows.map(BorrowRecord.fromMap).toList();
  }

  Future<BorrowRecord> createBorrow({
    required Book book,
    required String studentFullName,
    required String studentId,
    required String studentEmail,
    required bool emailVerified,
    required StudentLevel studentLevel,
    required String program,
    required String yearLevel,
    required DateTime borrowedAt,
    required DateTime dueDate,
  }) async {
    if (book.id == null) {
      throw Exception('Select a book from the library.');
    }
    final db = await database;
    return db.transaction((txn) async {
      final bookRows = await txn.query(
        'books',
        where: 'id = ?',
        whereArgs: [book.id],
        limit: 1,
      );
      if (bookRows.isEmpty) {
        throw Exception('That book is no longer in the library.');
      }
      final current = Book.fromMap(bookRows.first);
      if (current.quantity < 1) {
        throw Exception('No copies available to borrow.');
      }

      final record = BorrowRecord(
        bookId: current.id!,
        bookName: current.name,
        studentFullName: studentFullName.trim(),
        studentId: studentId.trim(),
        studentEmail: studentEmail.trim().toLowerCase(),
        emailVerified: emailVerified,
        studentLevel: studentLevel,
        program: program.trim(),
        yearLevel: yearLevel.trim(),
        borrowedAt: borrowedAt,
        dueDate: dueDate,
      );

      final id = await txn.insert('borrows', record.toMap()..remove('id'));
      final updated = current.copyWith(
        quantity: current.quantity - 1,
        updatedAt: DateTime.now(),
      );
      await txn.update(
        'books',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [current.id],
      );
      return record.copyWith(id: id);
    });
  }

  Future<void> markReminderSent(int borrowId) async {
    final db = await database;
    await db.update(
      'borrows',
      {'reminder_sent': 1},
      where: 'id = ?',
      whereArgs: [borrowId],
    );
  }

  Future<BorrowRecord> returnBorrow(BorrowRecord record) async {
    if (record.id == null) {
      throw Exception('Invalid borrow record.');
    }
    if (record.isReturned) {
      throw Exception('This book was already returned.');
    }
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        'borrows',
        where: 'id = ?',
        whereArgs: [record.id],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw Exception('Borrow record not found.');
      }
      final existing = BorrowRecord.fromMap(rows.first);
      if (existing.isReturned) {
        throw Exception('This book was already returned.');
      }

      final returned = existing.copyWith(returnedAt: DateTime.now());
      await txn.update(
        'borrows',
        returned.toMap(),
        where: 'id = ?',
        whereArgs: [returned.id],
      );

      final bookRows = await txn.query(
        'books',
        where: 'id = ?',
        whereArgs: [existing.bookId],
        limit: 1,
      );
      if (bookRows.isNotEmpty) {
        final book = Book.fromMap(bookRows.first);
        final updated = book.copyWith(
          quantity: book.quantity + 1,
          updatedAt: DateTime.now(),
        );
        await txn.update(
          'books',
          updated.toMap(),
          where: 'id = ?',
          whereArgs: [book.id],
        );
      }
      return returned;
    });
  }
}
