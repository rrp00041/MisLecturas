import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final searchState = ref.watch(searchControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descubre tu siguiente lectura',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Importa metadatos desde Google Books y cuida tu biblioteca sin salir de la app.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'Título, autor o ISBN',
                            prefixIcon: Icon(Icons.manage_search_rounded),
                          ),
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonalIcon(
                        onPressed: _submit,
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: searchState.when(
                data: (results) {
                  if (results.isEmpty) {
                    return EmptyState(
                      icon: Icons.menu_book_rounded,
                      title: 'Búsqueda lista',
                      message:
                          'Escribe un título o ISBN para traer portadas, autores y géneros desde Google Books.',
                      action: FilledButton.tonal(
                        onPressed: () {
                          _searchController.text = 'Ursula K. Le Guin';
                          _submit();
                        },
                        child: const Text('Probar con una sugerencia'),
                      ),
                    );
                  }

                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 420),
                          child: SlideAnimation(
                            verticalOffset: 28,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        BookCover(
                                          imageUrl: result.coverUrl,
                                          width: 78,
                                          height: 112,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                result.title,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleLarge,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                result.authors.isEmpty
                                                    ? 'Autor desconocido'
                                                    : result.authors.join(', '),
                                              ),
                                              const SizedBox(height: 10),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  for (final genre
                                                      in result.categories.take(
                                                        3,
                                                      ))
                                                    Chip(label: Text(genre)),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                result.description.isEmpty
                                                    ? 'Sin descripción disponible.'
                                                    : result.description,
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 14),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: FilledButton.icon(
                                                  onPressed: () async {
                                                    final book = await ref
                                                        .read(
                                                          booksControllerProvider
                                                              .notifier,
                                                        )
                                                        .addFromSearch(result);
                                                    if (!context.mounted) {
                                                      return;
                                                    }
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
                                                  icon: const Icon(
                                                    Icons.library_add_rounded,
                                                  ),
                                                  label: const Text('Guardar'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Sin conexión o respuesta inválida',
                  message:
                      'No he podido consultar Google Books. ${error.toString()}',
                  action: FilledButton.tonal(
                    onPressed: _submit,
                    child: const Text('Reintentar'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    await ref
        .read(searchControllerProvider.notifier)
        .search(_searchController.text);
  }
}
