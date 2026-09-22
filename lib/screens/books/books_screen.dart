import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../utils/case_route.dart';
import '../../utils/constants.dart';
import '../../widgets/book_card.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state.dart';
import 'add_book_screen.dart';
import 'edit_book_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final books = provider.visibleBooks;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        tooltip: 'Add book',
        child: const Icon(Icons.add_rounded),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            title: Text(
              provider.categoryFilter == null
                  ? 'Books'
                  : provider.categoryFilter!,
            ),
            actions: [
              if (provider.categoryFilter != null)
                TextButton(
                  onPressed: () => provider.setCategoryFilter(null),
                  child: const Text('Clear filter'),
                ),
              PopupMenuButton<BookSort>(
                tooltip: 'Sort',
                icon: const Icon(Icons.sort_rounded),
                onSelected: provider.setSort,
                itemBuilder: (context) => BookSort.values
                    .map(
                      (s) => CheckedPopupMenuItem(
                        value: s,
                        checked: provider.sort == s,
                        child: Text(s.label),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: CustomSearchBar(
                controller: _search,
                onChanged: provider.setSearch,
              ),
            ),
          ),
        ],
        body: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : books.isEmpty
                ? EmptyState(
                    title: provider.searchQuery.isEmpty
                        ? 'No books yet'
                        : 'No books found',
                    message: provider.searchQuery.isEmpty
                        ? 'Add a title to place it in the case.'
                        : 'Try another name, or clear the search.',
                    actionLabel: provider.searchQuery.isEmpty
                        ? 'Add book'
                        : 'Clear search',
                    onAction: provider.searchQuery.isEmpty
                        ? () => _openAdd(context)
                        : () {
                            _search.clear();
                            provider.setSearch('');
                          },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: books.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return BookCard(
                        book: book,
                        onEdit: () => _openEdit(context, book),
                        onDelete: () => _confirmDelete(context, book),
                      );
                    },
                  ),
      ),
    );
  }

  Future<void> _openAdd(BuildContext context) async {
    await Navigator.of(context).push(
      casePaneRoute(const AddBookScreen()),
    );
  }

  Future<void> _openEdit(BuildContext context, Book book) async {
    await Navigator.of(context).push(
      casePaneRoute(EditBookScreen(book: book)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Book book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this book?'),
        content: Text(
          '“${book.name}” will be permanently removed from the library.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final success =
          await context.read<BookProvider>().deleteBook(book.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Book deleted successfully'
                  : 'Could not delete the book',
            ),
          ),
        );
      }
    }
  }
}
