import 'package:isar/isar.dart';

import 'book.dart';

part 'book_record.g.dart';

@embedded
class ReadingTimelineRecord {
  ReadingTimelineRecord();

  String type = '';
  String label = '';
  DateTime occurredAt = DateTime.now();
  int pagesDelta = 0;
}

@collection
class BookRecord {
  BookRecord();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String externalId;

  late String title;
  List<String> authors = [];
  List<String> categories = [];
  List<String> tags = [];
  late String description;
  late String coverUrl;
  late int totalPages;
  late String status;
  late int currentPage;
  late double rating;
  late String review;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? googleBookId;
  DateTime? startedAt;
  DateTime? finishedAt;
  List<ReadingTimelineRecord> timeline = [];
}

extension BookRecordMapping on BookRecord {
  Book toDomain() {
    return Book(
      id: externalId,
      title: title,
      authors: authors,
      categories: categories,
      description: description,
      coverUrl: coverUrl,
      totalPages: totalPages,
      status: BookStatusX.fromStorage(status),
      currentPage: currentPage,
      rating: rating,
      review: review,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
      timeline: timeline
          .map(
            (event) => ReadingTimelineEvent(
              type: event.type,
              label: event.label,
              occurredAt: event.occurredAt,
              pagesDelta: event.pagesDelta,
            ),
          )
          .toList(),
      googleBookId: googleBookId,
      startedAt: startedAt,
      finishedAt: finishedAt,
    );
  }
}

extension BookMapping on Book {
  BookRecord toRecord({BookRecord? existing}) {
    final record = existing ?? BookRecord();
    record.externalId = id;
    record.title = title;
    record.authors = authors;
    record.categories = categories;
    record.tags = tags;
    record.description = description;
    record.coverUrl = coverUrl;
    record.totalPages = totalPages;
    record.status = status.storageValue;
    record.currentPage = currentPage;
    record.rating = rating;
    record.review = review;
    record.createdAt = createdAt;
    record.updatedAt = updatedAt;
    record.googleBookId = googleBookId;
    record.startedAt = startedAt;
    record.finishedAt = finishedAt;
    record.timeline = timeline.map((event) {
      final recordEvent = ReadingTimelineRecord();
      recordEvent.type = event.type;
      recordEvent.label = event.label;
      recordEvent.occurredAt = event.occurredAt;
      recordEvent.pagesDelta = event.pagesDelta;
      return recordEvent;
    }).toList();
    return record;
  }
}
