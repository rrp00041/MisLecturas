import 'package:isar/isar.dart';

import '../../../shared/models/book.dart';
import '../../../shared/models/book_record.dart';
import '../../search/domain/search_result.dart';
import 'books_repository.dart';

class IsarBooksRepository implements BooksRepository {
  IsarBooksRepository(this._isar);

  final Isar _isar;

  @override
  Stream<List<Book>> watchBooks() {
    final query = _isar.bookRecords.where().build();
    return query.watch(fireImmediately: true).map((records) {
      final books = records.map((record) => record.toDomain()).toList();
      books.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return books;
    });
  }

  @override
  Future<Book> addFromSearch(SearchResult result) async {
    final now = DateTime.now();
    final book = Book(
      id: '${result.id}-${now.microsecondsSinceEpoch}',
      title: result.title,
      authors: result.authors,
      categories: result.categories,
      description: result.description,
      coverUrl: result.coverUrl,
      totalPages: result.pageCount,
      status: BookStatus.toRead,
      currentPage: 0,
      rating: 0,
      review: '',
      createdAt: now,
      updatedAt: now,
      tags: [],
      timeline: [
        ReadingTimelineEvent(
          type: 'created',
          label: 'Añadido a la biblioteca',
          occurredAt: now,
        ),
      ],
      googleBookId: result.id,
    );

    await _isar.writeTxn(() async {
      await _isar.bookRecords.put(book.toRecord());
    });

    return book;
  }

  @override
  Future<void> updateBook(Book book) async {
    final existing = await _isar.bookRecords
        .filter()
        .externalIdEqualTo(book.id)
        .findFirst();

    if (existing == null) {
      await _isar.writeTxn(() async {
        await _isar.bookRecords.put(book.toRecord());
      });
      return;
    }

    final previous = existing.toDomain();
    final now = DateTime.now();
    final nextTimeline = [...book.timeline];
    var startedAt = book.startedAt;
    var finishedAt = book.finishedAt;

    if (previous.status != book.status) {
      nextTimeline.add(
        ReadingTimelineEvent(
          type: 'status',
          label: 'Estado actualizado a ${book.status.label}',
          occurredAt: now,
        ),
      );
      if (book.status == BookStatus.reading && startedAt == null) {
        startedAt = now;
        nextTimeline.add(
          ReadingTimelineEvent(
            type: 'started',
            label: 'Empezado el ${_formatDate(now)}',
            occurredAt: now,
          ),
        );
      }
      if (book.status == BookStatus.read && finishedAt == null) {
        finishedAt = now;
        nextTimeline.add(
          ReadingTimelineEvent(
            type: 'finished',
            label: 'Terminado el ${_formatDate(now)}',
            occurredAt: now,
          ),
        );
      }
    }

    if (book.currentPage > previous.currentPage) {
      nextTimeline.add(
        ReadingTimelineEvent(
          type: 'progress',
          label: 'Leídas ${book.currentPage - previous.currentPage} páginas',
          occurredAt: now,
          pagesDelta: book.currentPage - previous.currentPage,
        ),
      );
      startedAt ??= previous.startedAt ?? now;
      if (previous.startedAt == null) {
        nextTimeline.add(
          ReadingTimelineEvent(
            type: 'started',
            label: 'Empezado el ${_formatDate(startedAt)}',
            occurredAt: startedAt,
          ),
        );
      }
    }

    final normalized = book.copyWith(
      timeline: nextTimeline,
      startedAt: startedAt,
      finishedAt: book.status == BookStatus.read ? finishedAt : null,
      clearFinishedAt: book.status != BookStatus.read,
      updatedAt: now,
    );

    await _isar.writeTxn(() async {
      await _isar.bookRecords.put(normalized.toRecord(existing: existing));
    });
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'hoy';
    }
    return '${value.day}/${value.month}/${value.year}';
  }
}
