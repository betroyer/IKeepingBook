enum StudentLevel { college, highSchool }

extension StudentLevelLabel on StudentLevel {
  String get label => switch (this) {
        StudentLevel.college => 'College',
        StudentLevel.highSchool => 'High school',
      };

  String get programFieldLabel => switch (this) {
        StudentLevel.college => 'Course',
        StudentLevel.highSchool => 'Strand',
      };

  String get yearFieldLabel => switch (this) {
        StudentLevel.college => 'Year',
        StudentLevel.highSchool => 'Year level',
      };

  static StudentLevel fromStorage(String value) {
    return value == 'high_school'
        ? StudentLevel.highSchool
        : StudentLevel.college;
  }

  String get storageValue => switch (this) {
        StudentLevel.college => 'college',
        StudentLevel.highSchool => 'high_school',
      };
}

class BorrowRecord {
  const BorrowRecord({
    this.id,
    required this.bookId,
    required this.bookName,
    required this.studentFullName,
    required this.studentId,
    required this.studentEmail,
    required this.emailVerified,
    required this.studentLevel,
    required this.program,
    required this.yearLevel,
    required this.borrowedAt,
    required this.dueDate,
    this.returnedAt,
    this.reminderSent = false,
  });

  final int? id;
  final int bookId;
  final String bookName;
  final String studentFullName;
  final String studentId;
  final String studentEmail;
  final bool emailVerified;
  final StudentLevel studentLevel;
  final String program;
  final String yearLevel;
  final DateTime borrowedAt;
  final DateTime dueDate;
  final DateTime? returnedAt;
  final bool reminderSent;

  bool get isReturned => returnedAt != null;

  bool get isOverdue {
    if (isReturned) return false;
    final today = DateTime.now();
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final now = DateTime(today.year, today.month, today.day);
    return now.isAfter(due);
  }

  /// Active loan due tomorrow (1 day before return).
  bool get isDueSoon {
    if (isReturned || isOverdue) return false;
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(now).inDays == 1;
  }

  String get programSummary =>
      '${studentLevel.programFieldLabel}: $program · ${studentLevel.yearFieldLabel}: $yearLevel';

  BorrowRecord copyWith({
    int? id,
    int? bookId,
    String? bookName,
    String? studentFullName,
    String? studentId,
    String? studentEmail,
    bool? emailVerified,
    StudentLevel? studentLevel,
    String? program,
    String? yearLevel,
    DateTime? borrowedAt,
    DateTime? dueDate,
    DateTime? returnedAt,
    bool? reminderSent,
    bool clearReturnedAt = false,
  }) {
    return BorrowRecord(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      studentFullName: studentFullName ?? this.studentFullName,
      studentId: studentId ?? this.studentId,
      studentEmail: studentEmail ?? this.studentEmail,
      emailVerified: emailVerified ?? this.emailVerified,
      studentLevel: studentLevel ?? this.studentLevel,
      program: program ?? this.program,
      yearLevel: yearLevel ?? this.yearLevel,
      borrowedAt: borrowedAt ?? this.borrowedAt,
      dueDate: dueDate ?? this.dueDate,
      returnedAt: clearReturnedAt ? null : (returnedAt ?? this.returnedAt),
      reminderSent: reminderSent ?? this.reminderSent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'book_name': bookName,
      'student_full_name': studentFullName,
      'student_id': studentId,
      'student_email': studentEmail,
      'email_verified': emailVerified ? 1 : 0,
      'student_level': studentLevel.storageValue,
      'program': program,
      'year_level': yearLevel,
      'borrowed_at': borrowedAt.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'returned_at': returnedAt?.toIso8601String(),
      'reminder_sent': reminderSent ? 1 : 0,
    };
  }

  factory BorrowRecord.fromMap(Map<String, dynamic> map) {
    return BorrowRecord(
      id: map['id'] as int?,
      bookId: map['book_id'] as int,
      bookName: map['book_name'] as String,
      studentFullName: map['student_full_name'] as String,
      studentId: map['student_id'] as String,
      studentEmail: (map['student_email'] as String?) ?? '',
      emailVerified: (map['email_verified'] as int?) == 1,
      studentLevel: StudentLevelLabel.fromStorage(map['student_level'] as String),
      program: map['program'] as String,
      yearLevel: map['year_level'] as String,
      borrowedAt: DateTime.parse(map['borrowed_at'] as String),
      dueDate: DateTime.parse(map['due_date'] as String),
      returnedAt: map['returned_at'] == null
          ? null
          : DateTime.parse(map['returned_at'] as String),
      reminderSent: (map['reminder_sent'] as int?) == 1,
    );
  }
}
