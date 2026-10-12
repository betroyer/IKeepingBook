import 'package:flutter_test/flutter_test.dart';
import 'package:i_keeping_books/models/borrow_record.dart';

BorrowRecord _loan({required DateTime due}) {
  return BorrowRecord(
    bookId: 1,
    bookName: 'Sample',
    studentFullName: 'Ana Cruz',
    studentId: '2025',
    studentEmail: 'ana@school.test',
    emailVerified: true,
    studentLevel: StudentLevel.college,
    program: 'BSIT',
    yearLevel: '2nd Year',
    borrowedAt: due.subtract(const Duration(days: 7)),
    dueDate: due,
  );
}

void main() {
  test('penalty is 50 pesos per day after the due date', () {
    final today = DateTime.now();
    final dueYesterday = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 1));
    final record = _loan(due: dueYesterday);
    expect(record.isOverdue, isTrue);
    expect(record.daysOverdue, 1);
    expect(record.penaltyPesos, 50);

    final dueTwoDaysAgo = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 2));
    expect(_loan(due: dueTwoDaysAgo).penaltyPesos, 100);
  });

  test('no penalty on the due date itself', () {
    final today = DateTime.now();
    final dueToday = DateTime(today.year, today.month, today.day);
    final record = _loan(due: dueToday);
    expect(record.isOverdue, isFalse);
    expect(record.penaltyPesos, 0);
  });
}
