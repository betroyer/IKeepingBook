import 'package:flutter/material.dart';

import '../models/book.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'signal_lamp.dart';

String copiesLabel(int quantity) =>
    quantity == 1 ? '1 copy' : '$quantity copies';

/// Specimen label card — printed fields, signal lamp, no icon plaque.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  final Book book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: SignalLamp(
              status: book.isLowStock
                  ? SignalStatus.amber
                  : SignalStatus.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.labelMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book.isLowStock
                      ? '${copiesLabel(book.quantity)} · low stock'
                      : copiesLabel(book.quantity),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.labelMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.signalRed.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
