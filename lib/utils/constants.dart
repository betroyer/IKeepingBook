class AppConstants {
  AppConstants._();

  static const appName = 'I-Keeping Books';
  static const appVersion = '1.1.0';
  static const dbName = 'ikeeping_books.db';
  static const lowStockThreshold = 5;

  static const categories = <String>[
    'Textbooks',
    'Fiction Books',
    'Reference Books',
    'Science Books',
    'Technology Books',
  ];

  static const collegeYears = <String>[
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year',
  ];

  static const highSchoolYears = <String>[
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12',
  ];

  static const collegeCourses = <String>[
    'BS Computer Science',
    'BS Information Technology',
    'BS Education',
    'BS Business Administration',
    'BS Nursing',
    'BS Accountancy',
    'Other',
  ];

  static const highSchoolStrands = <String>[
    'STEM',
    'ABM',
    'HUMSS',
    'GAS',
    'TVL',
    'Arts and Design',
    'Sports',
    'Other',
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
