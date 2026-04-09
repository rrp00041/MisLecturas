# Esquema Local (Isar)

Este documento conserva la ruta histórica, pero el proyecto actual ya no usa Firestore. La persistencia está implementada con Isar.

## Colección `BookRecord`

- `externalId`: identificador estable del libro en la app.
- `title`
- `authors`
- `categories`
- `tags`
- `description`
- `coverUrl`
- `totalPages`
- `status`
- `currentPage`
- `rating`
- `review`
- `createdAt`
- `updatedAt`
- `googleBookId`
- `startedAt`
- `finishedAt`
- `timeline`

## Objeto embebido `ReadingTimelineRecord`

- `type`: `created`, `started`, `progress`, `status`, `finished`
- `label`: texto legible para la UI
- `occurredAt`
- `pagesDelta`

## Uso del timeline

- Permite calcular páginas leídas por mes.
- Permite calcular la racha actual.
- Sirve como cronología visible dentro de la ficha del libro.
