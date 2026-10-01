import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/borrow_record.dart';
import 'email_service.dart';
import 'notification_service.dart';
import 'smtp_settings.dart';

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final _dateFormat = DateFormat.yMMMd();

  /// Librarian device alerts + student Gmail notices (library Gmail SMTP).
  Future<ReminderRunResult> runDueSoonPass(List<BorrowRecord> records) async {
    final dueSoon = records.where((r) => r.isDueSoon).toList();
    final overdue = records.where((r) => r.isOverdue).toList();

    await NotificationService.instance.init();
    if (dueSoon.isNotEmpty) {
      await NotificationService.instance.showDueSoonSummary(dueSoon);
    }

    final smtp = await SmtpSettingsStore.load();
    var emailsSent = 0;
    var emailErrors = 0;

    if (smtp.isConfigured) {
      for (final record in dueSoon) {
        if (record.studentEmail.isEmpty ||
            record.reminderSent ||
            record.id == null) {
          continue;
        }
        try {
          await EmailService.instance.sendDueSoonReminder(
            toEmail: record.studentEmail,
            studentName: record.studentFullName,
            bookName: record.bookName,
            dueDateLabel: _dateFormat.format(record.dueDate),
          );
          await DatabaseHelper.instance.markReminderSent(record.id!);
          emailsSent++;
        } catch (_) {
          emailErrors++;
        }
      }
    }

    return ReminderRunResult(
      dueSoonCount: dueSoon.length,
      overdueCount: overdue.length,
      emailsSent: emailsSent,
      emailErrors: emailErrors,
      smtpConfigured: smtp.isConfigured,
    );
  }
}

class ReminderRunResult {
  const ReminderRunResult({
    required this.dueSoonCount,
    required this.overdueCount,
    required this.emailsSent,
    required this.emailErrors,
    required this.smtpConfigured,
  });

  final int dueSoonCount;
  final int overdueCount;
  final int emailsSent;
  final int emailErrors;
  final bool smtpConfigured;
}
