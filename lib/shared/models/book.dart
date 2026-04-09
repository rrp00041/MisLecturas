enum BookStatus { reading, read, toRead, abandoned }

extension BookStatusX on BookStatus {
  String get label {
    switch (this) {
      case BookStatus.reading:
        return 'Leyendo';
      case BookStatus.read:
        return 'Leído';
      case BookStatus.toRead:
        return 'Pendiente';
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

class ReadingTimelineEvent {
  const ReadingTimelineEvent({
    required this.type,
    required this.label,
    required this.occurredAt,
    this.pagesDelta = 0,
  });

  final String type;
  final String label;
  final DateTime occurredAt;
  final int pagesDelta;
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
    required this.tags,
    required this.timeline,
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
  final List<String> tags;
  final List<ReadingTimelineEvent> timeline;
  final String? googleBookId;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  double get progress {
    if (totalPages <= 0) {
      return 0;
    }
    return (currentPage / totalPages).clamp(0, 1);
  }

  String get authorsLabel =>
      authors.isEmpty ? 'Autor desconocido' : authors.join(', ');

  bool get isFavorite =>
      tags.any((tag) => tag.trim().toLowerCase() == 'favorito');

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
    List<String>? tags,
    List<ReadingTimelineEvent>? timeline,
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
      tags: tags ?? this.tags,
      timeline: timeline ?? this.timeline,
      googleBookId: googleBookId ?? this.googleBookId,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      finishedAt: clearFinishedAt ? null : finishedAt ?? this.finishedAt,
    );
  }
}
