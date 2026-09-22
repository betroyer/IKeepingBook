class Book {
  const Book({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final int quantity;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => quantity <= 5;

  Book copyWith({
    int? id,
    String? name,
    int? quantity,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
