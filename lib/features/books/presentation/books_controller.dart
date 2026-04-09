import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../shared/models/book.dart';
import '../../search/domain/search_result.dart';
import '../data/books_repository.dart';
import '../data/isar_books_repository.dart';

final booksRepositoryProvider = Provider<BooksRepository>(
  (ref) => IsarBooksRepository(ref.watch(isarProvider)),
);

final booksControllerProvider =
    StreamNotifierProvider<BooksController, List<Book>>(BooksController.new);

final bookByIdProvider = Provider.family<Book?, String>((ref, bookId) {
  final books =
      ref.watch(booksControllerProvider).valueOrNull ?? const <Book>[];
  for (final book in books) {
    if (book.id == bookId) {
      return book;
    }
  }
  return null;
});

final libraryStatsProvider = Provider<LibraryStats>((ref) {
  final books =
      ref.watch(booksControllerProvider).valueOrNull ?? const <Book>[];
  return LibraryStats.fromBooks(books);
});

class BooksController extends StreamNotifier<List<Book>> {
  BooksRepository get _repository => ref.read(booksRepositoryProvider);

  @override
  Stream<List<Book>> build() {
    return _repository.watchBooks();
  }

  Future<Book> addFromSearch(SearchResult result) {
    return _repository.addFromSearch(result);
  }

  Future<void> updateBook(Book book) {
    return _repository.updateBook(book);
  }
}

class LibraryStats {
  const LibraryStats({
    required this.pagesPerMonth,
    required this.genreDistribution,
    required this.totalBooks,
    required this.readBooks,
    required this.favoriteBooks,
    required this.currentStreak,
    required this.timeline,
  });

  final Map<int, int> pagesPerMonth;
  final Map<String, int> genreDistribution;
  final int totalBooks;
  final int readBooks;
  final int favoriteBooks;
  final int currentStreak;
  final List<ReadingTimelineEvent> timeline;

  factory LibraryStats.fromBooks(List<Book> books) {
    final currentYear = DateTime.now().year;
    final pagesPerMonth = <int, int>{
      for (var month = 1; month <= 12; month++) month: 0,
    };
    final genreDistribution = <String, int>{};
    final timeline = <ReadingTimelineEvent>[];

    for (final book in books) {
      timeline.addAll(book.timeline);
      for (final event in book.timeline) {
        if (event.pagesDelta > 0 && event.occurredAt.year == currentYear) {
          pagesPerMonth[event.occurredAt.month] =
              (pagesPerMonth[event.occurredAt.month] ?? 0) + event.pagesDelta;
        }
      }

      for (final genre in book.categories) {
        final normalized = genre.trim();
        if (normalized.isEmpty) {
          continue;
        }
        genreDistribution[normalized] =
            (genreDistribution[normalized] ?? 0) + 1;
      }
    }

    timeline.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return LibraryStats(
      pagesPerMonth: pagesPerMonth,
      genreDistribution: genreDistribution,
      totalBooks: books.length,
      readBooks: books.where((book) => book.status == BookStatus.read).length,
      favoriteBooks: books.where((book) => book.isFavorite).length,
      currentStreak: _calculateStreak(timeline),
      timeline: timeline,
    );
  }

  static int _calculateStreak(List<ReadingTimelineEvent> events) {
    final days =
        events
            .where((event) => event.pagesDelta > 0)
            .map(
              (event) => DateTime(
                event.occurredAt.year,
                event.occurredAt.month,
                event.occurredAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (days.isEmpty) {
      return 0;
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final first = days.first;
    if (normalizedToday.difference(first).inDays > 1) {
      return 0;
    }

    var streak = 1;
    for (var index = 0; index < days.length - 1; index++) {
      if (days[index].difference(days[index + 1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
