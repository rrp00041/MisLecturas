# Arquitectura

## Principios

- Local-first: la aplicación funciona sin autenticación y sin sincronización remota.
- Reactiva: Riverpod observa los cambios de Isar y actualiza la UI sin recargas manuales.
- Modular: cada feature encapsula su UI, su lógica y su acceso a datos.

## Capas

### Core

- Tema visual premium con variantes clara y oscura.
- Router con `StatefulShellRoute` para Biblioteca, Buscar y Panel.
- Proveedores globales como la instancia de Isar.

### Features

- `books`: biblioteca, detalle del libro, repositorio Isar y métricas.
- `search`: integración con Google Books API.
- `analytics`: visualización de páginas por mes, géneros y racha actual.

### Shared

- Modelo de dominio `Book`.
- Modelo persistente `BookRecord` para Isar.
- Widgets reutilizables como `BookCover`, `EmptyState` y la shell inferior.

## Persistencia

- Isar almacena libros, etiquetas y cronología de eventos.
- Cada actualización de progreso o estado puede generar un evento de timeline.
- Las analíticas se calculan a partir de esos eventos en lugar de datos mockeados.

## Navegación

- `/library`: biblioteca principal.
- `/library/book/:bookId`: ficha de lectura con transición personalizada.
- `/search`: búsqueda remota.
- `/analytics`: panel de estadísticas.
