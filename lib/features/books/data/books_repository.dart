import '../../../shared/models/book.dart';
import '../../search/domain/search_result.dart';

abstract class BooksRepository {
  Future<List<Book>> loadBooks();
  Future<void> saveBooks(List<Book> books);

  Future<Book> addFromSearch(SearchResult result) async {
    final currentBooks = await loadBooks();
    final now = DateTime.now();
    final book = Book(
      id: '${result.id}-${now.microsecondsSinceEpoch}',
      title: result.title,
      authors: result.authors,
      categories: result.categories,
      description: result.description,
      coverUrl: result.coverUrl,
      totalPages: result.pageCount,
      status: BookStatus.toRead,
      currentPage: 0,
      rating: 0,
      review: '',
      createdAt: now,
      updatedAt: now,
      googleBookId: result.id,
    );
    await saveBooks([book, ...currentBooks]);
    return book;
  }

  Future<Book> updateBook(Book updatedBook) async {
    final books = await loadBooks();
    final nextBooks = books
        .map((book) => book.id == updatedBook.id ? updatedBook : book)
        .toList();
    await saveBooks(nextBooks);
    return updatedBook;
  }
}
