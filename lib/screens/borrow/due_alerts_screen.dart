import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/borrow_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/case_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/signal_lamp.dart';

class DueAlertsScreen extends StatelessWidget {
  const DueAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BorrowProvider>();
    final dueSoon = provider.records.where((r) => r.isDueSoon).toList();
    final overdue = provider.records.where((r) => r.isOverdue).toList();
    final dateFormat = DateFormat.yMMMd();

    return CaseBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Due alerts'),
          actions: [
            IconButton(
              tooltip: 'Refresh reminders',
              onPressed: () async {
                final result = await provider.runReminders();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.dueSoonCount == 0 && result.overdueCount == 0
                          ? 'No due-soon or overdue loans right now'
                          : 'Alerts updated · '
                              '${result.dueSoonCount} due tomorrow · '
                              '${result.overdueCount} overdue'
                              '${result.smtpConfigured ? ' · ${result.emailsSent} email(s) sent' : ' · configure SMTP to email students'}',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: (dueSoon.isEmpty && overdue.isEmpty)
            ? const EmptyState(
                title: 'All clear',
                message:
                    'No students are due tomorrow or overdue. '
                    'Verified emails get a reminder 1 day before return when SMTP is set up.',
                icon: Icons.notifications_none_rounded,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (dueSoon.isNotEmpty) ...[
                    Text(
                      'Due tomorrow',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...dueSoon.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          borderColor:
                              AppColors.signalAmber.withValues(alpha: 0.5),
                          child: _AlertRow(
                            recordName: r.studentFullName,
                            detail:
                                '${r.bookName}\nDue ${dateFormat.format(r.dueDate)}'
                                '${r.studentEmail.isEmpty ? '' : ' · ${r.studentEmail}'}',
                            status: SignalStatus.amber,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (overdue.isNotEmpty) ...[
                    Text(
                      'Overdue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...overdue.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          borderColor:
                              AppColors.signalRed.withValues(alpha: 0.45),
                          child: _AlertRow(
                            recordName: r.studentFullName,
                            detail:
                                '${r.bookName}\nWas due ${dateFormat.format(r.dueDate)}',
                            status: SignalStatus.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.recordName,
    required this.detail,
    required this.status,
  });

  final String recordName;
  final String detail;
  final SignalStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SignalLamp(status: status),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recordName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.labelMuted,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
