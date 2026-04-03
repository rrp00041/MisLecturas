import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/search_result.dart';

class GoogleBooksService {
  GoogleBooksService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<SearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': trimmed,
      'maxResults': '20',
      'printType': 'books',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Google Books devolvió ${response.statusCode}.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final items = payload['items'] as List<dynamic>? ?? const [];
    return items.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final volume = Map<String, dynamic>.from(
        map['volumeInfo'] as Map? ?? const <String, dynamic>{},
      );
      final images = Map<String, dynamic>.from(
        volume['imageLinks'] as Map? ?? const <String, dynamic>{},
      );
      return SearchResult(
        id:
            map['id'] as String? ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: volume['title'] as String? ?? 'Sin título',
        authors: List<String>.from(volume['authors'] as List? ?? const []),
        categories: List<String>.from(
          volume['categories'] as List? ?? const [],
        ),
        description: volume['description'] as String? ?? '',
        coverUrl: (images['thumbnail'] as String? ?? '').replaceFirst(
          'http://',
          'https://',
        ),
        pageCount: volume['pageCount'] as int? ?? 0,
      );
    }).toList();
  }
}
