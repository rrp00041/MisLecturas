class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.authors,
    required this.categories,
    required this.description,
    required this.coverUrl,
    required this.pageCount,
  });

  final String id;
  final String title;
  final List<String> authors;
  final List<String> categories;
  final String description;
  final String coverUrl;
  final int pageCount;
}
