# Modelo de Datos (Firestore)

## Estructura principal

```text
users/{uid}
  profile/{profileDoc}
  books/{bookId}
  lists/{listId}
  reading_sessions/{sessionId}
  daily_stats/{yyyyMMdd}
```

## users/{uid}/books/{bookId}
Campos recomendados:
- `title` (string)
- `authors` (array<string>)
- `genre` (array<string>)
- `coverUrl` (string)
- `googleBookId` (string)
- `isbn10` (string?)
- `isbn13` (string?)
- `status` (enum: reading|pending|read|rereading|dropped)
- `customLists` (array<listId>)
- `startedAt` (timestamp?)
- `finishedAt` (timestamp?)
- `review` (string)
- `tags` (array<string>)
- `rating` (double, 0.0..5.0)
- `currentPage` (number)
- `totalPages` (number)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

## users/{uid}/lists/{listId}
- `name` (string)
- `color` (string hex)
- `icon` (string)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

## users/{uid}/reading_sessions/{sessionId}
Representa lectura diaria para analítica fina.
- `bookId` (string)
- `date` (timestamp)
- `pagesRead` (number)
- `durationMinutes` (number?)
- `createdAt` (timestamp)

## users/{uid}/daily_stats/{yyyyMMdd}
Documento agregado por día para dashboard.
- `date` (timestamp)
- `pagesRead` (number)
- `booksFinished` (number)
- `sessions` (number)
- `weekday` (number, 1..7)

## Consultas clave
1. Libros leídos por mes/año: `books` filtrado por `finishedAt` rango.
2. Páginas por día/semana: `daily_stats` por fechas.
3. Géneros/autores más leídos: agregación cliente sobre `books` con `status=read`.
4. Heatmap semanal: `daily_stats` agrupado por `weekday`.
5. Predicción fin de libro: media móvil 7 días en `daily_stats` y `remainingPages`.

## Índices sugeridos
- `books(status, updatedAt desc)`
- `books(status, finishedAt desc)`
- `books(tags array-contains, updatedAt desc)`
- `books(customLists array-contains, updatedAt desc)`
