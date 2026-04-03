import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../shared/models/book.dart';
import '../../shared/widgets/book_cover.dart';
import 'presentation/books_controller.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pagesController;
  late TextEditingController _reviewController;
  BookStatus? _status;
  double _rating = 0;
  DateTime? _startedAt;
  DateTime? _finishedAt;

  @override
  void initState() {
    super.initState();
    _pagesController = TextEditingController();
    _reviewController = TextEditingController();
  }

  @override
  void dispose() {
    _pagesController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(bookByIdProvider(widget.bookId));
    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Libro no encontrado.')),
      );
    }

    _pagesController.text = book.currentPage.toString();
    _reviewController.text = book.review;
    _status ??= book.status;
    if (_rating == 0) {
      _rating = book.rating;
    }
    _startedAt ??= book.startedAt;
    _finishedAt ??= book.finishedAt;

    return Scaffold(
      appBar: AppBar(title: const Text('Ficha del libro')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCover(imageUrl: book.coverUrl, width: 92, height: 132),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(book.authorsLabel),
                          const SizedBox(height: 12),
                          Text(
                            book.description.isEmpty
                                ? 'Sin descripción disponible.'
                                : book.description,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguimiento',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<BookStatus>(
                      initialValue: _status,
                      items: [
                        for (final status in BookStatus.values)
                          DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                      ],
                      onChanged: (value) => setState(() => _status = value),
                      decoration: const InputDecoration(labelText: 'Estado'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pagesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Página actual',
                        helperText: book.totalPages == 0
                            ? 'Total de páginas desconocido.'
                            : 'Total: ${book.totalPages}',
                      ),
                      validator: (value) {
                        final pages = int.tryParse(value ?? '');
                        if (pages == null || pages < 0) {
                          return 'Introduce un número válido.';
                        }
                        if (book.totalPages > 0 && pages > book.totalPages) {
                          return 'No puede superar el total de páginas.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Valoración',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Slider(
                      value: _rating,
                      divisions: 10,
                      label: _rating.toStringAsFixed(1),
                      min: 0,
                      max: 5,
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Reseña personal',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _DateButton(
                          label: 'Inicio',
                          value: _startedAt,
                          onPressed: () async {
                            final picked = await _pickDate(context, _startedAt);
                            if (picked != null) {
                              setState(() => _startedAt = picked);
                            }
                          },
                        ),
                        _DateButton(
                          label: 'Fin',
                          value: _finishedAt,
                          onPressed: () async {
                            final picked = await _pickDate(
                              context,
                              _finishedAt,
                            );
                            if (picked != null) {
                              setState(() => _finishedAt = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final page = int.parse(_pagesController.text);
                          final now = DateTime.now();
                          final updatedBook = book.copyWith(
                            status: _status,
                            currentPage: page,
                            rating: _rating,
                            review: _reviewController.text.trim(),
                            updatedAt: now,
                            startedAt: _startedAt,
                            finishedAt: _finishedAt,
                            clearStartedAt: _startedAt == null,
                            clearFinishedAt: _finishedAt == null,
                          );
                          await ref
                              .read(booksControllerProvider.notifier)
                              .updateBook(updatedBook);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Libro actualizado.'),
                              ),
                            );
                            context.pop();
                          }
                        },
                        icon: const Icon(Icons.save_outlined),
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

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initialDate) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
      initialDate: initialDate ?? now,
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Sin fecha'
        : DateFormat('dd/MM/yyyy').format(value!);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.event_outlined),
      label: Text('$label: $text'),
    );
  }
}
