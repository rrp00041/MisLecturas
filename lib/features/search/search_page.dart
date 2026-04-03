import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/book_cover.dart';
import '../../shared/widgets/empty_state.dart';
import '../books/presentation/books_controller.dart';
import 'presentation/search_controller.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar libros')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Título, autor o ISBN',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: _submit, child: const Text('Buscar')),
              ],
            ),
          ),
          Expanded(
            child: searchState.when(
              data: (results) {
                if (results.isEmpty) {
                  return const EmptyState(
                    icon: Icons.travel_explore_outlined,
                    title: 'Sin resultados',
                    message:
                        'Busca un libro en Google Books y añádelo a tu biblioteca.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BookCover(imageUrl: result.coverUrl),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    result.authors.isEmpty
                                        ? 'Autor desconocido'
                                        : result.authors.join(', '),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    result.description.isEmpty
                                        ? 'Sin descripción'
                                        : result.description,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: FilledButton.icon(
                                      onPressed: () async {
                                        final book = await ref
                                            .read(
                                              booksControllerProvider.notifier,
                                            )
                                            .addFromSearch(result);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${book.title} añadido a la biblioteca.',
                                            ),
                                          ),
                                        );
                                        context.go('/library');
                                      },
                                      icon: const Icon(Icons.library_add),
                                      label: const Text('Añadir'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                icon: Icons.wifi_off_outlined,
                title: 'No se pudo buscar',
                message: error.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    await ref
        .read(searchControllerProvider.notifier)
        .search(_searchController.text);
  }
}
