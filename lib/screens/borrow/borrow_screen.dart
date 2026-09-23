import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/borrow_record.dart';
import '../../providers/book_provider.dart';
import '../../providers/borrow_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/case_route.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/signal_lamp.dart';
import 'due_alerts_screen.dart';
import 'new_borrow_screen.dart';

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  final _search = TextEditingController();
  final _dateFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<BorrowProvider>().runReminders();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BorrowProvider>();
    final records = provider.visibleRecords;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewBorrow(context),
        icon: const Icon(Icons.assignment_ind_outlined),
        label: const Text('New borrow'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            title: const Text('Borrow'),
            actions: [
              IconButton(
                tooltip: 'Due-soon alerts',
                onPressed: () {
                  Navigator.of(context).push(
                    casePaneRoute(const DueAlertsScreen()),
                  );
                },
                icon: Badge(
                  isLabelVisible: provider.dueSoonCount + provider.overdueCount > 0,
                  label: Text(
                    '${provider.dueSoonCount + provider.overdueCount}',
                  ),
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  if (provider.dueSoonCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        onTap: () =>
                            provider.setFilter(BorrowFilter.dueSoon),
                        borderColor:
                            AppColors.signalAmber.withValues(alpha: 0.55),
                        child: Row(
                          children: [
                            const SignalLamp(status: SignalStatus.amber),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${provider.dueSoonCount} student'
                                '${provider.dueSoonCount == 1 ? '' : 's'} '
                                'due tomorrow',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                  CustomSearchBar(
                    controller: _search,
                    hint: 'Search student, ID, email, or book',
                    onChanged: provider.setSearch,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final f in BorrowFilter.values)
                        FilterChip(
                          label: Text(_filterLabel(f, provider)),
                          selected: provider.filter == f,
                          onSelected: (_) => provider.setFilter(f),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : records.isEmpty
                ? EmptyState(
                    title: 'No borrow records',
                    message:
                        'Record a student loan with name, ID, email, '
                        'course/strand & year, and dates.',
                    actionLabel: 'New borrow',
                    onAction: () => _openNewBorrow(context),
                    icon: Icons.assignment_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    itemCount: records.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _BorrowCard(
                        record: record,
                        dateFormat: _dateFormat,
                        onReturn: record.isReturned
                            ? null
                            : () => _confirmReturn(context, record),
                      );
                    },
                  ),
      ),
    );
  }

  String _filterLabel(BorrowFilter f, BorrowProvider p) => switch (f) {
        BorrowFilter.active => 'Active (${p.activeCount})',
        BorrowFilter.dueSoon => 'Due soon (${p.dueSoonCount})',
        BorrowFilter.returned => 'Returned',
        BorrowFilter.all => 'All',
      };

  Future<void> _openNewBorrow(BuildContext context) async {
    final ok = await Navigator.of(context).push<bool>(
      casePaneRoute(const NewBorrowScreen()),
    );
    if (ok == true && context.mounted) {
      await context.read<BookProvider>().load();
    }
  }

  Future<void> _confirmReturn(
    BuildContext context,
    BorrowRecord record,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as returned?'),
        content: Text(
          'Confirm that ${record.studentFullName} returned “${record.bookName}”. '
          'One copy will be added back to stock.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Returned'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final borrow = context.read<BorrowProvider>();
      final books = context.read<BookProvider>();
      final success = await borrow.markReturned(record);
      if (success) {
        await books.load();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Book marked as returned'
                  : (borrow.error ?? 'Could not mark return'),
            ),
          ),
        );
      }
    }
  }
}

class _BorrowCard extends StatelessWidget {
  const _BorrowCard({
    required this.record,
    required this.dateFormat,
    this.onReturn,
  });

  final BorrowRecord record;
  final DateFormat dateFormat;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final SignalStatus status;
    final String statusLabel;
    if (record.isReturned) {
      status = SignalStatus.green;
      statusLabel = 'Returned';
    } else if (record.isOverdue) {
      status = SignalStatus.red;
      statusLabel = 'Overdue';
    } else if (record.isDueSoon) {
      status = SignalStatus.amber;
      statusLabel = 'Due tomorrow';
    } else {
      status = SignalStatus.green;
      statusLabel = 'On loan';
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SignalLamp(status: status),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.labelMuted,
                ),
              ),
              const Spacer(),
              if (onReturn != null)
                TextButton(
                  onPressed: onReturn,
                  child: const Text('Return'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            record.studentFullName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'ID: ${record.studentId}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.labelMuted,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 14,
                color: AppColors.labelMuted.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  record.studentEmail.isEmpty
                      ? 'No email'
                      : record.studentEmail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.labelMuted,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${record.studentLevel.label} · ${record.programSummary}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.labelMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            record.bookName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Borrowed ${dateFormat.format(record.borrowedAt)} · '
            'Due ${dateFormat.format(record.dueDate)}'
            '${record.returnedAt != null ? ' · Returned ${dateFormat.format(record.returnedAt!)}' : ''}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.labelMuted,
            ),
          ),
        ],
      ),
    );
  }
}
