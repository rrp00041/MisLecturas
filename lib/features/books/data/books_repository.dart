import '../../../shared/models/book.dart';
import '../../search/domain/search_result.dart';

abstract class BooksRepository {
  Stream<List<Book>> watchBooks();
  Future<Book> addFromSearch(SearchResult result);
  Future<void> updateBook(Book book);
}
