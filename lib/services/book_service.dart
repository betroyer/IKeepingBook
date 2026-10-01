import '../database/database_helper.dart';
import '../models/book.dart';

class BookService {
  BookService({DatabaseHelper? helper}) : _db = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  Future<List<Book>> fetchAll() => _db.getAllBooks();

  Future<Book> add({
    required String name,
    required int quantity,
    required String category,
  }) async {
    final now = DateTime.now();
    final book = Book(
      name: name.trim(),
      quantity: quantity,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
    final id = await _db.insertBook(book);
    return book.copyWith(id: id);
  }

  Future<Book> update(Book book) async {
    final updated = book.copyWith(updatedAt: DateTime.now());
    await _db.updateBook(updated);
    return updated;
  }

  Future<void> delete(int id) => _db.deleteBook(id);

  Future<void> clearAll() => _db.clearAll();

  Future<List<Book>> search(String query) {
    if (query.trim().isEmpty) return fetchAll();
    return _db.searchByName(query.trim());
  }
}
