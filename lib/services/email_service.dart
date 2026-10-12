import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../models/borrow_record.dart';
import 'smtp_settings.dart';

class EmailService {
  EmailService._();
  static final EmailService instance = EmailService._();

  Future<void> sendTestEmail({required String toEmail}) async {
    final settings = await SmtpSettingsStore.load();
    if (!settings.isConfigured) {
      throw Exception(
        'Save an enabled library Gmail and App Password first.',
      );
    }
    await _send(
      settings: settings,
      toEmail: toEmail,
      subject: 'I-Keeping Books — test email',
      body: '''
This is a test message from I-Keeping Books.

If you received this, library Gmail SMTP is working. Students can now get
borrow receipts and due-soon reminders from this account.
''',
    );
  }

  Future<void> sendBorrowConfirmation({
    required String toEmail,
    required String studentName,
    required String bookName,
    required String borrowedLabel,
    required String dueDateLabel,
    List<String>? bookNames,
  }) async {
    final settings = await SmtpSettingsStore.load();
    if (!settings.isConfigured) {
      throw Exception(
        'Library Gmail is not set up. Open More → Email reminders '
        'and add a Gmail account with an App Password.',
      );
    }
    final titles = (bookNames != null && bookNames.isNotEmpty)
        ? bookNames
        : [bookName];
    final bookList = titles.length == 1
        ? titles.first
        : titles.map((t) => '• $t').join('\n');
    final subject = titles.length == 1
        ? 'Library borrow receipt — ${titles.first}'
        : 'Library borrow receipt — ${titles.length} books';
    final borrowedLine = titles.length == 1
        ? 'You borrowed: $bookList'
        : 'You borrowed:\n$bookList';
    await _send(
      settings: settings,
      toEmail: toEmail,
      subject: subject,
      body: '''
Hello $studentName,

This is a confirmation from your school library (I-Keeping Books).

$borrowedLine
Borrowed on: $borrowedLabel
Return due: $dueDateLabel

Please return ${titles.length == 1 ? 'the book' : 'the books'} on or before the due date. You will also receive a reminder by email 1 day before each title is due.

If a book is still out the day after the due date, a penalty of ₱${BorrowRecord.dailyPenaltyPesos} is charged that day, then ₱${BorrowRecord.dailyPenaltyPesos} more for every extra day until it is returned.

Thank you!
''',
    );
  }

  Future<void> sendDueSoonReminder({
    required String toEmail,
    required String studentName,
    required String bookName,
    required String dueDateLabel,
  }) async {
    final settings = await SmtpSettingsStore.load();
    if (!settings.isConfigured) {
      throw Exception('Library Gmail is not set up.');
    }
    await _send(
      settings: settings,
      toEmail: toEmail,
      subject: 'Reminder: return “$bookName” tomorrow',
      body: '''
Hello $studentName,

This is a reminder from your school library (I-Keeping Books).

Book: $bookName
Return due: $dueDateLabel

Please return the book on or before the due date. If it is still out the next day, a penalty of ₱${BorrowRecord.dailyPenaltyPesos} applies, then ₱${BorrowRecord.dailyPenaltyPesos} more for every extra day until you return it. Thank you!
''',
    );
  }

  Future<void> sendOverduePenalty({
    required String toEmail,
    required String studentName,
    required String bookName,
    required String dueDateLabel,
    required int daysLate,
    required int penaltyPesos,
  }) async {
    final settings = await SmtpSettingsStore.load();
    if (!settings.isConfigured) {
      throw Exception('Library Gmail is not set up.');
    }
    final daily = BorrowRecord.dailyPenaltyPesos;
    final firstDay = daysLate <= 1;
    await _send(
      settings: settings,
      toEmail: toEmail,
      subject: firstDay
          ? 'Overdue penalty — “$bookName” (₱$penaltyPesos)'
          : 'Still overdue — ₱$daily/day on “$bookName” (₱$penaltyPesos due)',
      body: firstDay
          ? '''
Hello $studentName,

You passed the return due date for a library book (I-Keeping Books).

Book: $bookName
Was due: $dueDateLabel
Days late: $daysLate
Penalty today: ₱$penaltyPesos

A charge of ₱$daily starts the day after the due date. If you do not return the book, another ₱$daily is added every day until it is returned.

Please return the book as soon as you can.
'''
          : '''
Hello $studentName,

“$bookName” is still not returned. The library charges ₱$daily every day past the due date while the book is out.

Was due: $dueDateLabel
Days late: $daysLate
Charge so far: ₱$penaltyPesos (₱$daily × $daysLate days)

Return the book to stop the daily charge.
''',
    );
  }

  Future<void> _send({
    required SmtpSettings settings,
    required String toEmail,
    required String subject,
    required String body,
  }) async {
    final user = settings.username.trim();
    final server = settings.isGmail
        ? gmail(user, settings.password)
        : SmtpServer(
            settings.host,
            port: settings.port,
            ssl: settings.useSsl,
            username: user,
            password: settings.password,
          );
    final message = Message()
      ..from = Address(user, settings.fromName)
      ..recipients.add(toEmail.trim())
      ..subject = subject
      ..text = body;

    await send(message, server);
  }
}
