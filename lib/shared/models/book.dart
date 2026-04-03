import 'dart:convert';

enum BookStatus { reading, read, toRead, abandoned }

extension BookStatusX on BookStatus {
  String get label {
    switch (this) {
      case BookStatus.reading:
        return 'Leyendo';
      case BookStatus.read:
        return 'Leído';
      case BookStatus.toRead:
        return 'Por leer';
      case BookStatus.abandoned:
        return 'Abandonado';
    }
  }

  String get storageValue {
    switch (this) {
      case BookStatus.reading:
        return 'reading';
      case BookStatus.read:
        return 'read';
      case BookStatus.toRead:
        return 'toRead';
      case BookStatus.abandoned:
        return 'abandoned';
    }
  }

  static BookStatus fromStorage(String value) {
    return BookStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => BookStatus.toRead,
    );
  }
}

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.categories,
    required this.description,
    required this.coverUrl,
    required this.totalPages,
    required this.status,
    required this.currentPage,
    required this.rating,
    required this.review,
    required this.createdAt,
    required this.updatedAt,
    this.googleBookId,
    this.startedAt,
    this.finishedAt,
  });

  final String id;
  final String title;
  final List<String> authors;
  final List<String> categories;
  final String description;
  final String coverUrl;
  final int totalPages;
  final BookStatus status;
  final int currentPage;
  final double rating;
  final String review;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? googleBookId;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  double get progress {
    if (totalPages <= 0) return 0;
    return (currentPage / totalPages).clamp(0, 1);
  }

  String get authorsLabel =>
      authors.isEmpty ? 'Autor desconocido' : authors.join(', ');

  Book copyWith({
    String? id,
    String? title,
    List<String>? authors,
    List<String>? categories,
    String? description,
    String? coverUrl,
    int? totalPages,
    BookStatus? status,
    int? currentPage,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? googleBookId,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? finishedAt,
    bool clearFinishedAt = false,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      categories: categories ?? this.categories,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      googleBookId: googleBookId ?? this.googleBookId,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      finishedAt: clearFinishedAt ? null : finishedAt ?? this.finishedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'categories': categories,
      'description': description,
      'coverUrl': coverUrl,
      'totalPages': totalPages,
      'status': status.storageValue,
      'currentPage': currentPage,
      'rating': rating,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'googleBookId': googleBookId,
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      authors: List<String>.from(map['authors'] as List? ?? const []),
      categories: List<String>.from(map['categories'] as List? ?? const []),
      description: map['description'] as String? ?? '',
      coverUrl: map['coverUrl'] as String? ?? '',
      totalPages: map['totalPages'] as int? ?? 0,
      status: BookStatusX.fromStorage(map['status'] as String? ?? 'toRead'),
      currentPage: map['currentPage'] as int? ?? 0,
      rating: (map['rating'] as num? ?? 0).toDouble(),
      review: map['review'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      googleBookId: map['googleBookId'] as String?,
      startedAt: map['startedAt'] == null
          ? null
          : DateTime.tryParse(map['startedAt'] as String),
      finishedAt: map['finishedAt'] == null
          ? null
          : DateTime.tryParse(map['finishedAt'] as String),
    );
  }

  static String encodeList(List<Book> books) {
    return jsonEncode(books.map((book) => book.toMap()).toList());
  }

  static List<Book> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Book.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
