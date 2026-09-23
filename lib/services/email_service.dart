import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

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
  }) async {
    final settings = await SmtpSettingsStore.load();
    if (!settings.isConfigured) {
      throw Exception(
        'Library Gmail is not set up. Open More → Email reminders '
        'and add a Gmail account with an App Password.',
      );
    }
    await _send(
      settings: settings,
      toEmail: toEmail,
      subject: 'Library borrow receipt — $bookName',
      body: '''
Hello $studentName,

This is a confirmation from your school library (I-Keeping Books).

You borrowed: $bookName
Borrowed on: $borrowedLabel
Return due: $dueDateLabel

Please return the book on or before the due date. You will also receive a reminder by email 1 day before it is due.

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

Please return the book on or before the due date. Thank you!
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
