import '../database/database_helper.dart';
import '../models/book.dart';
import '../models/borrow_record.dart';

class BorrowService {
  BorrowService({DatabaseHelper? helper})
      : _db = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  Future<List<BorrowRecord>> fetchAll() => _db.getAllBorrows();

  Future<BorrowRecord> createLoan({
    required Book book,
    required String studentFullName,
    required String studentId,
    required StudentLevel studentLevel,
    required String program,
    required String yearLevel,
    required DateTime borrowedAt,
    required DateTime dueDate,
  }) {
    return _db.createBorrow(
      book: book,
      studentFullName: studentFullName,
      studentId: studentId,
      studentLevel: studentLevel,
      program: program,
      yearLevel: yearLevel,
      borrowedAt: borrowedAt,
      dueDate: dueDate,
    );
  }

  Future<BorrowRecord> markReturned(BorrowRecord record) =>
      _db.returnBorrow(record);
}
