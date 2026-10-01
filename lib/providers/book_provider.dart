import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../services/book_service.dart';
import '../utils/constants.dart';

class BookProvider extends ChangeNotifier {
  BookProvider({BookService? service}) : _service = service ?? BookService();

  final BookService _service;

  List<Book> _books = [];
  bool _loading = true;
  String _searchQuery = '';
  BookSort _sort = BookSort.recentlyAdded;
  String? _categoryFilter;
  String? _error;
  bool _showingSampleNotice = false;

  List<Book> get books => List.unmodifiable(_books);
  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  BookSort get sort => _sort;
  String? get categoryFilter => _categoryFilter;
  String? get error => _error;
  bool get showingSampleNotice => _showingSampleNotice;

  int get totalBooks => _books.length;
  int get totalCopies => _books.fold(0, (sum, b) => sum + b.quantity);
  int get categoryCount =>
      _books.map((b) => b.category).toSet().length;
  int get lowStockCount =>
      _books.where((b) => b.isLowStock).length;

  List<Book> get recentlyAdded {
    final sorted = [..._books]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  List<Book> get visibleBooks {
    Iterable<Book> list = _books;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((b) => b.name.toLowerCase().contains(q));
    }
    if (_categoryFilter != null) {
      list = list.where((b) => b.category == _categoryFilter);
    }

    final result = list.toList();
    switch (_sort) {
      case BookSort.nameAsc:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case BookSort.nameDesc:
        result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case BookSort.quantityHigh:
        result.sort((a, b) => b.quantity.compareTo(a.quantity));
      case BookSort.quantityLow:
        result.sort((a, b) => a.quantity.compareTo(b.quantity));
      case BookSort.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  int countInCategory(String category) =>
      _books.where((b) => b.category == category).length;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _books = await _service.fetchAll();
      if (_books.isEmpty) {
        await _seedSampleLibrary();
        _books = await _service.fetchAll();
        _showingSampleNotice = true;
      }
    } catch (e) {
      _error = 'Could not open the library case. Try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _seedSampleLibrary() async {
    // Synthetic sample inventory for first launch — not a real collection.
    final samples = <(String, int, String)>[
      ('Introduction to Algorithms', 3, 'Textbooks'),
      ('The Left Hand of Darkness', 2, 'Fiction Books'),
      ('Oxford English Dictionary', 1, 'Reference Books'),
      ('Cosmos', 8, 'Science Books'),
      ('Clean Code', 12, 'Technology Books'),
      ('Discrete Mathematics', 4, 'Textbooks'),
      ('Neuromancer', 6, 'Fiction Books'),
    ];
    for (final s in samples) {
      await _service.add(name: s.$1, quantity: s.$2, category: s.$3);
    }
  }

  void dismissSampleNotice() {
    _showingSampleNotice = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSort(BookSort sort) {
    _sort = sort;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  Future<bool> addBook({
    required String name,
    required int quantity,
    required String category,
  }) async {
    try {
      final book = await _service.add(
        name: name,
        quantity: quantity,
        category: category,
      );
      _books = [book, ..._books];
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Could not add the book.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook(Book book) async {
    try {
      final updated = await _service.update(book);
      _books = _books
          .map((b) => b.id == updated.id ? updated : b)
          .toList();
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Could not update the book.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(int id) async {
    try {
      await _service.delete(id);
      _books = _books.where((b) => b.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Could not delete the book.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearAllBooks() async {
    try {
      await _service.clearAll();
      _books = [];
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Could not clear the library.';
      notifyListeners();
      return false;
    }
  }
}
