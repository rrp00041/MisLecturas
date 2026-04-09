import 'package:flutter_test/flutter_test.dart';

import 'package:mis_lecturas/features/books/presentation/books_controller.dart';
import 'package:mis_lecturas/shared/models/book.dart';

void main() {
  test('library stats calculate streak and pages per month from timeline', () {
    final now = DateTime.now();
    final book = Book(
      id: 'book-1',
      title: 'Test Book',
      authors: const ['Author'],
      categories: const ['Fantasy'],
      description: 'Example',
      coverUrl: '',
      totalPages: 300,
      status: BookStatus.reading,
      currentPage: 42,
      rating: 4,
      review: 'Great',
      createdAt: now,
      updatedAt: now,
      tags: const ['Favorito'],
      timeline: [
        ReadingTimelineEvent(
          type: 'progress',
          label: 'Leídas 20 páginas',
          occurredAt: now,
          pagesDelta: 20,
        ),
        ReadingTimelineEvent(
          type: 'progress',
          label: 'Leídas 22 páginas',
          occurredAt: now.subtract(const Duration(days: 1)),
          pagesDelta: 22,
        ),
      ],
    );

    final stats = LibraryStats.fromBooks([book]);

    expect(stats.totalBooks, 1);
    expect(stats.favoriteBooks, 1);
    expect(stats.currentStreak, 2);
    expect(stats.genreDistribution['Fantasy'], 1);
    expect(stats.pagesPerMonth[now.month], 42);
  });
}
