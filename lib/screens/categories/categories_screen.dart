import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/book_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, required this.onOpenBooks});

  final VoidCallback onOpenBooks;

  static const _icons = <String, IconData>{
    'Textbooks': Icons.school_outlined,
    'Fiction Books': Icons.auto_stories_outlined,
    'Reference Books': Icons.menu_book_outlined,
    'Science Books': Icons.science_outlined,
    'Technology Books': Icons.memory_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          title: Text('Categories'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList.separated(
            itemCount: AppConstants.categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final category = AppConstants.categories[index];
              return CategoryCard(
                title: category,
                count: provider.countInCategory(category),
                icon: _icons[category] ?? Icons.category_outlined,
                onTap: () {
                  provider.setCategoryFilter(category);
                  provider.setSearch('');
                  onOpenBooks();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
