import 'dart:math';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'smtp_settings.dart';

class EmailService {
  EmailService._();
  static final EmailService instance = EmailService._();

  String generateVerificationCode() {
    final n = Random.secure().nextInt(900000) + 100000;
    return n.toString();
  }

  Future<void> sendVerificationCode({
    required String toEmail,
    required String studentName,
    required String code,
  }) async {
    final settings = await SmtpSettingsStore.load();
    if (!settings.isConfigured) {
      throw Exception(
        'Email SMTP is not configured. Open More → Email reminders to set it up, '
        'or use on-device verification.',
      );
    }
    await _send(
      settings: settings,
      toEmail: toEmail,
      subject: 'Verify your email — I-Keeping Books',
      body: '''
Hello $studentName,

Your library email verification code is:

$code

Enter this code in I-Keeping Books to verify your email for borrow reminders.
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
      throw Exception('Email SMTP is not configured.');
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
    final server = SmtpServer(
      settings.host,
      port: settings.port,
      ssl: settings.useSsl,
      username: settings.username,
      password: settings.password,
    );
    final message = Message()
      ..from = Address(settings.username, settings.fromName)
      ..recipients.add(toEmail.trim())
      ..subject = subject
      ..text = body;

    await send(message, server);
  }
}
