import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/book.dart';
import 'books_repository.dart';

class LocalBooksRepository extends BooksRepository {
  LocalBooksRepository(this._preferences);

  final SharedPreferences _preferences;

  static const _storageKey = 'library.books';

  @override
  Future<List<Book>> loadBooks() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    return Book.decodeList(raw);
  }

  @override
  Future<void> saveBooks(List<Book> books) async {
    await _preferences.setString(_storageKey, Book.encodeList(books));
  }
}
