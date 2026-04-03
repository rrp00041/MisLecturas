import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../shared/models/book.dart';
import '../../search/domain/search_result.dart';
import '../data/books_repository.dart';
import '../data/local_books_repository.dart';

final booksRepositoryProvider = Provider<BooksRepository>(
  (ref) => LocalBooksRepository(ref.watch(sharedPreferencesProvider)),
);

final booksControllerProvider =
    AsyncNotifierProvider<BooksController, List<Book>>(BooksController.new);

final libraryStatsProvider = Provider<LibraryStats>((ref) {
  final books =
      ref.watch(booksControllerProvider).valueOrNull ?? const <Book>[];
  return LibraryStats.fromBooks(books);
});

final bookByIdProvider = Provider.family<Book?, String>((ref, bookId) {
  final books =
      ref.watch(booksControllerProvider).valueOrNull ?? const <Book>[];
  for (final book in books) {
    if (book.id == bookId) return book;
  }
  return null;
});

class BooksController extends AsyncNotifier<List<Book>> {
  BooksRepository get _repository => ref.read(booksRepositoryProvider);

  @override
  Future<List<Book>> build() {
    return _repository.loadBooks();
  }

  Future<Book> addFromSearch(SearchResult result) async {
    final current = state.valueOrNull ?? const <Book>[];
    final book = await _repository.addFromSearch(result);
    state = AsyncData([book, ...current]);
    return book;
  }

  Future<void> updateBook(Book book) async {
    final current = [...(state.valueOrNull ?? const <Book>[])];
    await _repository.updateBook(book);
    final next = current
        .map((item) => item.id == book.id ? book : item)
        .toList();
    next.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = AsyncData(next);
  }
}

class LibraryStats {
  const LibraryStats({
    required this.readPerMonth,
    required this.genreDistribution,
    required this.totalBooks,
    required this.readBooks,
  });

  final Map<int, int> readPerMonth;
  final Map<String, int> genreDistribution;
  final int totalBooks;
  final int readBooks;

  factory LibraryStats.fromBooks(List<Book> books) {
    final readPerMonth = <int, int>{
      for (var month = 1; month <= 12; month++) month: 0,
    };
    final genreDistribution = <String, int>{};
    for (final book in books) {
      if (book.status == BookStatus.read && book.finishedAt != null) {
        readPerMonth[book.finishedAt!.month] =
            (readPerMonth[book.finishedAt!.month] ?? 0) + 1;
      }
      for (final genre in book.categories) {
        genreDistribution[genre] = (genreDistribution[genre] ?? 0) + 1;
      }
    }

    if (genreDistribution.isEmpty) {
      genreDistribution.addAll({'Ficción': 2, 'Ensayo': 1, 'Historia': 1});
    }

    return LibraryStats(
      readPerMonth: readPerMonth,
      genreDistribution: genreDistribution,
      totalBooks: books.length,
      readBooks: books.where((book) => book.status == BookStatus.read).length,
    );
  }
}
