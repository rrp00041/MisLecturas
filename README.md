# MyPersonal Library App

Aplicación privada de gestión de lectura con sincronización en la nube, disponible en Android (APK) y Web/Desktop desde una sola base de código Flutter.

## Enfoque
- **Privado primero**: autenticación obligatoria, datos aislados por usuario.
- **Rendimiento**: diseño orientado a consultas agregadas y lecturas rápidas.
- **Analítica profunda**: métricas de hábitos de lectura y proyecciones.

## Stack
- **Frontend**: Flutter (Android + Web + Desktop)
- **Auth/Backend**: Firebase Authentication + Cloud Firestore + Cloud Storage
- **Analíticas visuales**: `fl_chart` (o Chart.js si se monta dashboard web embebido)
- **Estado**: Riverpod (recomendado)

## Documentación técnica
- Arquitectura: `docs/arquitectura.md`
- Modelo de datos Firestore: `docs/firestore-schema.md`
- Plan de implementación: `docs/roadmap.md`

## Estructura inicial
- `lib/main.dart`: bootstrap de app y tema claro/oscuro.
- `lib/core/router.dart`: rutas principales.
- `lib/features/auth/`: login con Firebase Auth.
- `lib/features/books/`: buscador Google Books + colección personal.
- `lib/features/analytics/`: dashboard de gráficas e insights.

## Próximos pasos
1. Crear proyecto Firebase y configurar Android/Web.
2. Habilitar Email/Password en Firebase Auth.
3. Crear índices compuestos en Firestore (ver documento de esquema).
4. Implementar ingestión de Google Books con caché local.
5. Construir dashboard con consultas agregadas por periodo.
