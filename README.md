# MisLecturas

Aplicación Flutter local-first para gestionar lecturas, progreso, etiquetas y analíticas personales desde una única base de código.

## Enfoque

- Privado de verdad: no hay cuentas ni backend. Todo vive en la base de datos local.
- Rendimiento: Isar como persistencia reactiva y rápida.
- Experiencia premium: modo oscuro profundo, tarjetas redondeadas, animaciones suaves y transiciones `Hero`.
- Analítica útil: páginas leídas por mes, géneros y racha calculados desde eventos reales.

## Stack

- Flutter multiplataforma
- Riverpod para estado reactivo
- GoRouter para navegación
- Isar para base de datos local
- Google Books API para búsqueda e importación
- fl_chart para visualizaciones
- google_fonts + flutter_staggered_animations para UI/UX

## Estructura principal

- `lib/main.dart`: inicializa Isar y arranca la app.
- `lib/core/`: router, tema y proveedores globales.
- `lib/features/books/`: biblioteca, ficha de lectura, repositorio Isar y analytics derivados.
- `lib/features/search/`: búsqueda remota en Google Books.
- `lib/shared/models/`: modelo de dominio y esquema Isar.
- `lib/shared/widgets/`: componentes reutilizables de UI.

## Flujo del producto

1. Buscar un libro en Google Books.
2. Guardarlo en la biblioteca local.
3. Actualizar progreso, etiquetas, rating y notas.
4. Consultar panel de estadísticas calculado desde la cronología de lectura.

## Comandos útiles

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```
