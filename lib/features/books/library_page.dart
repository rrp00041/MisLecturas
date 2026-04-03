import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/book.dart';
import '../../shared/widgets/book_cover.dart';
import '../../shared/widgets/empty_state.dart';
import '../auth/presentation/auth_controller.dart';
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
    final booksAsync = ref.watch(booksControllerProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            tooltip: 'Buscar libros',
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: booksAsync.when(
        data: (books) {
          final filteredBooks = _filter == null
              ? books
              : books.where((book) => book.status == _filter).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user == null
                          ? 'Sin sesión activa'
                          : 'Hola, ${user.name}. ${books.length} libros guardados.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Todos'),
                            selected: _filter == null,
                            onSelected: (_) => setState(() => _filter = null),
                          ),
                          const SizedBox(width: 8),
                          for (final status in BookStatus.values) ...[
                            FilterChip(
                              label: Text(status.label),
                              selected: _filter == status,
                              onSelected: (_) =>
                                  setState(() => _filter = status),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredBooks.isEmpty
                    ? const EmptyState(
                        icon: Icons.library_books_outlined,
                        title: 'Biblioteca vacía',
                        message:
                            'Busca un libro y añádelo a tu colección para empezar.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filteredBooks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          return Card(
                            child: ListTile(
                              onTap: () =>
                                  context.go('/library/book/${book.id}'),
                              contentPadding: const EdgeInsets.all(14),
                              leading: BookCover(imageUrl: book.coverUrl),
                              title: Text(book.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(book.authorsLabel),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(value: book.progress),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${book.status.label} · ${book.currentPage}/${book.totalPages == 0 ? '?' : book.totalPages} páginas',
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/search'),
        icon: const Icon(Icons.add),
        label: const Text('Añadir libro'),
      ),
    );
  }
}
