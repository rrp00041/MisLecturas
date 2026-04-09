import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/book.dart';
import '../../shared/widgets/book_cover.dart';
import '../../shared/widgets/empty_state.dart';
import 'presentation/books_controller.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  BookStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final booksAsync = ref.watch(booksControllerProvider);
    final stats = ref.watch(libraryStatsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/search'),
        icon: const Icon(Icons.add),
        label: const Text('Añadir libro'),
      ),
      body: SafeArea(
        child: booksAsync.when(
          data: (books) {
            final filteredBooks = _filter == null
                ? books
                : books.where((book) => book.status == _filter).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu santuario de lectura',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Biblioteca local, transiciones suaves y seguimiento preciso sin depender de la nube.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  scheme.primaryContainer.withValues(
                                    alpha: 0.85,
                                  ),
                                  scheme.tertiaryContainer.withValues(
                                    alpha: 0.75,
                                  ),
                                  scheme.secondaryContainer.withValues(
                                    alpha: 0.8,
                                  ),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Visión general',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    _MetricTile(
                                      label: 'Libros',
                                      value: stats.totalBooks.toString(),
                                    ),
                                    _MetricTile(
                                      label: 'Leídos',
                                      value: stats.readBooks.toString(),
                                    ),
                                    _MetricTile(
                                      label: 'Favoritos',
                                      value: stats.favoriteBooks.toString(),
                                    ),
                                    _MetricTile(
                                      label: 'Racha',
                                      value: '${stats.currentStreak} días',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 42,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _StatusChip(
                                label: 'Todos',
                                selected: _filter == null,
                                onTap: () => setState(() => _filter = null),
                              ),
                              const SizedBox(width: 8),
                              for (final status in BookStatus.values) ...[
                                _StatusChip(
                                  label: status.label,
                                  selected: _filter == status,
                                  onTap: () => setState(() => _filter = status),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (filteredBooks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.local_library_rounded,
                      title: 'Tu estantería todavía está vacía',
                      message:
                          'Importa un libro para empezar a construir un histórico de progreso, géneros y rachas.',
                      action: FilledButton.tonalIcon(
                        onPressed: () => context.go('/search'),
                        icon: const Icon(Icons.manage_search),
                        label: const Text('Buscar ahora'),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 420),
                          child: SlideAnimation(
                            verticalOffset: 32,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _LibraryBookCard(book: book),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'No pude cargar tu biblioteca',
            message: error.toString(),
          ),
        ),
      ),
    );
  }
}

class _LibraryBookCard extends StatelessWidget {
  const _LibraryBookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => context.go('/library/book/${book.id}'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              BookCover(
                imageUrl: book.coverUrl,
                width: 84,
                height: 122,
                heroTag: 'book-cover-${book.id}',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(label: book.status.label),
                        if (book.tags.isNotEmpty)
                          _MiniBadge(
                            label: book.tags.first,
                            foreground: scheme.onSecondaryContainer,
                            background: scheme.secondaryContainer,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authorsLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: book.progress,
                        backgroundColor: scheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${(book.progress * 100).round()}%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${book.currentPage}/${book.totalPages == 0 ? '?' : book.totalPages} páginas',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, this.background, this.foreground});

  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foreground ?? scheme.onTertiaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
