import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/book.dart';
import '../models/borrow_record.dart';
import '../services/borrow_service.dart';
import '../services/email_service.dart';
import '../services/notification_service.dart';
import '../services/reminder_service.dart';

enum BorrowFilter { active, dueSoon, returned, all }

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
  int get dueSoonCount => _records.where((r) => r.isDueSoon).length;

  List<BorrowRecord> get dueSoonRecords =>
      _records.where((r) => r.isDueSoon).toList();

  List<BorrowRecord> get visibleRecords {
    Iterable<BorrowRecord> list = _records;
    switch (_filter) {
      case BorrowFilter.active:
        list = list.where((r) => !r.isReturned);
      case BorrowFilter.dueSoon:
        list = list.where((r) => r.isDueSoon);
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
            r.bookName.toLowerCase().contains(q) ||
            r.studentEmail.toLowerCase().contains(q),
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

  Future<ReminderRunResult> runReminders() async {
    final result = await ReminderService.instance.runDueSoonPass(_records);
    if (result.emailsSent > 0) {
      await load();
    }
    return result;
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
    required String studentEmail,
    required StudentLevel studentLevel,
    required String program,
    required String yearLevel,
    required DateTime borrowedAt,
    required DateTime dueDate,
  }) async {
    _error = null;
    try {
      final record = await _service.createLoan(
        book: book,
        studentFullName: studentFullName,
        studentId: studentId,
        studentEmail: studentEmail,
        emailVerified: true,
        studentLevel: studentLevel,
        program: program,
        yearLevel: yearLevel,
        borrowedAt: borrowedAt,
        dueDate: dueDate,
      );
      _records = [record, ..._records];
      notifyListeners();
      await NotificationService.instance.scheduleLoanReminder(record);

      final email = studentEmail.trim();
      if (email.isNotEmpty) {
        try {
          final fmt = DateFormat.yMMMd();
          await EmailService.instance.sendBorrowConfirmation(
            toEmail: email,
            studentName: studentFullName.trim(),
            bookName: book.name,
            borrowedLabel: fmt.format(borrowedAt),
            dueDateLabel: fmt.format(dueDate),
          );
        } catch (e) {
          _error =
              'Borrow saved, but could not email the student: '
              '${e.toString().replaceFirst('Exception: ', '')}';
          notifyListeners();
        }
      }
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
      if (record.id != null) {
        await NotificationService.instance.cancelLoanReminder(record.id!);
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
