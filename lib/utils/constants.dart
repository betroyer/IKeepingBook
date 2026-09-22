class AppConstants {
  AppConstants._();

  static const appName = 'I-Keeping Books';
  static const appVersion = '1.0.0';
  static const dbName = 'ikeeping_books.db';
  static const lowStockThreshold = 5;

  static const categories = <String>[
    'Textbooks',
    'Fiction Books',
    'Reference Books',
    'Science Books',
    'Technology Books',
  ];
}

enum BookSort {
  nameAsc,
  nameDesc,
  quantityHigh,
  quantityLow,
  recentlyAdded,
}

extension BookSortLabel on BookSort {
  String get label => switch (this) {
        BookSort.nameAsc => 'A–Z',
        BookSort.nameDesc => 'Z–A',
        BookSort.quantityHigh => 'Highest Quantity',
        BookSort.quantityLow => 'Lowest Quantity',
        BookSort.recentlyAdded => 'Recently Added',
      };
}
