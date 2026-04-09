import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../shared/models/book.dart';
import '../../shared/widgets/book_cover.dart';
import '../../shared/widgets/empty_state.dart';
import 'presentation/books_controller.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  final _reviewController = TextEditingController();
  final _tagController = TextEditingController();

  String? _seededBookId;
  BookStatus _status = BookStatus.toRead;
  double _rating = 0;
  int _currentPage = 0;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  List<String> _tags = [];

  @override
  void dispose() {
    _reviewController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final book = ref.watch(bookByIdProvider(widget.bookId));

    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.menu_book_rounded,
          title: 'Libro no encontrado',
          message:
              'Puede que se haya eliminado o la navegación haya quedado obsoleta.',
        ),
      );
    }

    _seed(book);

    final totalPages = book.totalPages <= 0 ? 100 : book.totalPages;
    final progressValue = (_currentPage / totalPages)
        .clamp(0.0, 1.0)
        .toDouble();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              title: const Text('Ficha de lectura'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BookCover(
                                  imageUrl: book.coverUrl,
                                  width: 118,
                                  height: 172,
                                  heroTag: 'book-cover-${book.id}',
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        book.authorsLabel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          for (final category
                                              in book.categories.take(3))
                                            Chip(label: Text(category)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              book.description.isEmpty
                                  ? 'Sin descripción disponible.'
                                  : book.description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progreso',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 18),
                            SegmentedButton<BookStatus>(
                              segments: [
                                for (final status in BookStatus.values)
                                  ButtonSegment<BookStatus>(
                                    value: status,
                                    label: Text(status.label),
                                  ),
                              ],
                              selected: {_status},
                              onSelectionChanged: (selection) {
                                setState(() => _status = selection.first);
                              },
                            ),
                            const SizedBox(height: 20),
                            if (book.totalPages > 0) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Página actual',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '$_currentPage / ${book.totalPages}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Slider(
                                value: _currentPage.toDouble().clamp(
                                  0,
                                  book.totalPages.toDouble(),
                                ),
                                max: book.totalPages.toDouble(),
                                divisions: book.totalPages > 1
                                    ? book.totalPages
                                    : 1,
                                label: '$_currentPage',
                                onChanged: (value) {
                                  setState(() => _currentPage = value.round());
                                },
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progressValue,
                                  minHeight: 12,
                                  backgroundColor:
                                      scheme.surfaceContainerHighest,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(progressValue * 100).round()}% completado',
                              ),
                            ] else
                              Text(
                                'El libro no informa del total de páginas, así que el progreso visual no está disponible.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            const SizedBox(height: 18),
                            Text(
                              'Valoración',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Slider(
                              value: _rating,
                              min: 0,
                              max: 5,
                              divisions: 10,
                              label: _rating.toStringAsFixed(1),
                              onChanged: (value) =>
                                  setState(() => _rating = value),
                            ),
                            TextField(
                              controller: _reviewController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Notas y reseña',
                                hintText:
                                    'Qué te está pareciendo, citas, impresiones...',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Etiquetas y cronología',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final tag in _tags)
                                  InputChip(
                                    label: Text(tag),
                                    selected: true,
                                    onDeleted: () {
                                      setState(() {
                                        _tags.remove(tag);
                                      });
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nueva etiqueta',
                                      hintText: 'Favorito, Prestado, Terror...',
                                    ),
                                    onSubmitted: (_) => _addTag(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                FilledButton.tonal(
                                  onPressed: _addTag,
                                  child: const Text('Añadir'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _DateCard(label: 'Inicio', value: _startedAt),
                                _DateCard(label: 'Fin', value: _finishedAt),
                              ],
                            ),
                            const SizedBox(height: 18),
                            if (book.timeline.isEmpty)
                              Text(
                                'Todavía no hay eventos registrados para este libro.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            else
                              Column(
                                children: [
                                  for (final event in book.timeline.take(6))
                                    _TimelineTile(event: event),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final normalizedStatus = _normalizeStatus(
                            _status,
                            _currentPage,
                            book.totalPages,
                          );
                          final updatedBook = book.copyWith(
                            status: normalizedStatus,
                            currentPage: _currentPage,
                            rating: _rating,
                            review: _reviewController.text.trim(),
                            tags: _tags,
                            startedAt:
                                _startedAt ??
                                (normalizedStatus == BookStatus.reading
                                    ? now
                                    : null),
                            finishedAt: normalizedStatus == BookStatus.read
                                ? (_finishedAt ?? now)
                                : null,
                            clearFinishedAt:
                                normalizedStatus != BookStatus.read,
                          );
                          await ref
                              .read(booksControllerProvider.notifier)
                              .updateBook(updatedBook);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ficha actualizada')),
                          );
                          context.pop();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Guardar cambios'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _seed(Book book) {
    if (_seededBookId == book.id) {
      return;
    }
    _seededBookId = book.id;
    _status = book.status;
    _rating = book.rating;
    _currentPage = book.currentPage;
    _startedAt = book.startedAt;
    _finishedAt = book.finishedAt;
    _tags = [...book.tags];
    _reviewController.text = book.review;
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) {
      return;
    }
    if (_tags.any((existing) => existing.toLowerCase() == tag.toLowerCase())) {
      _tagController.clear();
      return;
    }
    setState(() {
      _tags = [..._tags, tag];
      _tagController.clear();
    });
  }

  BookStatus _normalizeStatus(
    BookStatus status,
    int currentPage,
    int totalPages,
  ) {
    if (totalPages > 0 && currentPage >= totalPages) {
      return BookStatus.read;
    }
    if (currentPage > 0 && status == BookStatus.toRead) {
      return BookStatus.reading;
    }
    return status;
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.label, required this.value});

  final String label;
  final DateTime? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Text(
            value == null
                ? 'Sin fecha'
                : DateFormat('dd MMM yyyy', 'es').format(value!),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event});

  final ReadingTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat(
                    'dd MMM yyyy · HH:mm',
                    'es',
                  ).format(event.occurredAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
