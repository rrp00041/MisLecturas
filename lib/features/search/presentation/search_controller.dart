import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/google_books_service.dart';
import '../domain/search_result.dart';

final googleBooksServiceProvider = Provider<GoogleBooksService>(
  (ref) => GoogleBooksService(),
);

final searchControllerProvider =
    AsyncNotifierProvider<SearchController, List<SearchResult>>(
      SearchController.new,
    );

class SearchController extends AsyncNotifier<List<SearchResult>> {
  GoogleBooksService get _service => ref.read(googleBooksServiceProvider);

  @override
  Future<List<SearchResult>> build() async {
    return const [];
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.search(query));
  }

  void clear() {
    state = const AsyncData([]);
  }
}
