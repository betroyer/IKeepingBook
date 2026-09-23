import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/borrow_record.dart';
import '../services/borrow_service.dart';

enum BorrowFilter { active, returned, all }

class BorrowProvider extends ChangeNotifier {
  BorrowProvider({BorrowService? service})
      : _service = service ?? BorrowService();

  final BorrowService _service;

  List<BorrowRecord> _records = [];
  bool _loading = true;
  String _searchQuery = '';
  BorrowFilter _filter = BorrowFilter.active;
  String? _error;

  List<BorrowRecord> get records => List.unmodifiable(_records);
  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  BorrowFilter get filter => _filter;
  String? get error => _error;

  int get activeCount => _records.where((r) => !r.isReturned).length;
  int get overdueCount => _records.where((r) => r.isOverdue).length;

  List<BorrowRecord> get visibleRecords {
    Iterable<BorrowRecord> list = _records;
    switch (_filter) {
      case BorrowFilter.active:
        list = list.where((r) => !r.isReturned);
      case BorrowFilter.returned:
        list = list.where((r) => r.isReturned);
      case BorrowFilter.all:
        break;
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where(
        (r) =>
            r.studentFullName.toLowerCase().contains(q) ||
            r.studentId.toLowerCase().contains(q) ||
            r.bookName.toLowerCase().contains(q),
      );
    }
    final result = list.toList()
      ..sort((a, b) => b.borrowedAt.compareTo(a.borrowedAt));
    return result;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _records = await _service.fetchAll();
    } catch (_) {
      _error = 'Could not load borrow records.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(BorrowFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<bool> createLoan({
    required Book book,
    required String studentFullName,
    required String studentId,
    required StudentLevel studentLevel,
    required String program,
    required String yearLevel,
    required DateTime borrowedAt,
    required DateTime dueDate,
  }) async {
    try {
      final record = await _service.createLoan(
        book: book,
        studentFullName: studentFullName,
        studentId: studentId,
        studentLevel: studentLevel,
        program: program,
        yearLevel: yearLevel,
        borrowedAt: borrowedAt,
        dueDate: dueDate,
      );
      _records = [record, ..._records];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> markReturned(BorrowRecord record) async {
    try {
      final updated = await _service.markReturned(record);
      _records = _records
          .map((r) => r.id == updated.id ? updated : r)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
