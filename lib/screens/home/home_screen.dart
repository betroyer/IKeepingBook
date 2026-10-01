import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/book_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/case_route.dart';
import '../../widgets/book_card.dart' show copiesLabel;
import '../../widgets/case_shelf_rail.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/signal_lamp.dart';
import '../../widgets/statistic_card.dart';
import '../../widgets/glass_card.dart';
import '../books/add_book_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenBooks});

  final VoidCallback? onOpenBooks;

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BookProvider>();
    final theme = Theme.of(context);

    if (books.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (books.totalBooks == 0) {
      return EmptyState(
        title: 'No books yet',
        message:
            'Add your first title to begin managing this library.',
        actionLabel: 'Add book',
        onAction: () => _openAdd(context),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('I-Keeping Books'),
          actions: [
            TextButton.icon(
              onPressed: () => _openAdd(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (books.showingSampleNotice) ...[
                  GlassCard(
                    padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                    borderColor:
                        AppColors.caseIndigo.withValues(alpha: 0.35),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sample titles are loaded for first launch. Replace them with your own inventory.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.labelMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Dismiss',
                          onPressed: books.dismissSampleNotice,
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  'Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.28,
            children: [
              StatisticCard(
                label: 'Titles',
                value: '${books.totalBooks}',
                icon: Icons.menu_book_rounded,
                status: SignalStatus.green,
                onTap: onOpenBooks,
              ),
              StatisticCard(
                label: 'Copies',
                value: '${books.totalCopies}',
                icon: Icons.layers_rounded,
                status: SignalStatus.green,
              ),
              StatisticCard(
                label: 'Categories',
                value: '${books.categoryCount}',
                icon: Icons.category_outlined,
              ),
              StatisticCard(
                label: 'Low stock',
                value: '${books.lowStockCount}',
                icon: Icons.warning_amber_rounded,
                status: books.lowStockCount > 0
                    ? SignalStatus.amber
                    : SignalStatus.green,
                onTap: onOpenBooks,
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  'Recently added',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onOpenBooks,
                  child: const Text('See all'),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: CaseShelfRail()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList.separated(
            itemCount: books.recentlyAdded.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final book = books.recentlyAdded[index];
              return GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SignalLamp(
                      status: book.isLowStock
                          ? SignalStatus.amber
                          : SignalStatus.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${book.category} · ${copiesLabel(book.quantity)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.labelMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openAdd(BuildContext context) async {
    await Navigator.of(context).push(
      casePaneRoute(const AddBookScreen()),
    );
  }
}
