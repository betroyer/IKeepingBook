import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/borrow_record.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    } catch (_) {
      // Fall back to default local zone if available.
    }
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const init = InitializationSettings(android: android);
      await _plugin.initialize(init);
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      _ready = true;
      // Clear a corrupt scheduled-notification cache that can throw
      // "Missing type parameter" on cancel/load in release builds.
      await _safeCancelAll();
    } catch (e) {
      debugPrint('Notification init failed: $e');
      _ready = false;
    }
  }

  Future<void> showDueSoonSummary(List<BorrowRecord> dueSoon) async {
    if (!_ready || dueSoon.isEmpty) return;
    final names = dueSoon
        .take(3)
        .map((r) => '${r.studentFullName} — ${r.bookName}')
        .join('\n');
    final more = dueSoon.length > 3 ? '\n+${dueSoon.length - 3} more' : '';
    const details = AndroidNotificationDetails(
      'due_soon',
      'Due soon',
      channelDescription: 'Students with books due tomorrow',
      importance: Importance.high,
      priority: Priority.high,
    );
    try {
      await _plugin.show(
        91001,
        '${dueSoon.length} loan${dueSoon.length == 1 ? '' : 's'} due tomorrow',
        '$names$more',
        const NotificationDetails(android: details),
      );
    } catch (e) {
      debugPrint('Could not show due-soon summary: $e');
    }
  }

  Future<void> scheduleLoanReminder(BorrowRecord record) async {
    if (!_ready || record.id == null || record.isReturned) return;
    final due = DateTime(
      record.dueDate.year,
      record.dueDate.month,
      record.dueDate.day,
      9,
    );
    final remindAt = due.subtract(const Duration(days: 1));
    final id = 92000 + record.id!;
    final title = 'Due tomorrow: ${record.bookName}';
    final body =
        '${record.studentFullName} should return this book by ${_fmt(record.dueDate)}.';
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'due_soon',
        'Due soon',
        channelDescription: 'Students with books due tomorrow',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    try {
      if (!remindAt.isAfter(DateTime.now())) {
        await _plugin.show(id, title, body, details);
        return;
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(remindAt, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Could not schedule reminder: $e');
    }
  }

  Future<void> cancelLoanReminder(int borrowId) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(92000 + borrowId);
    } catch (e) {
      debugPrint('Could not cancel reminder $borrowId: $e');
      // Gson "Missing type parameter" usually means a bad cache entry —
      // wipe scheduled notifications so Return / Borrow can continue.
      await _safeCancelAll();
    }
  }

  Future<void> _safeCancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Could not clear notification cache: $e');
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
