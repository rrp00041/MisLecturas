# Arquitectura Propuesta

## 1) Plataforma y módulos

### Cliente único Flutter
- **Targets**: Android APK y Web/Desktop.
- **Capas**:
  - Presentación (Widgets + navegación)
  - Dominio (casos de uso)
  - Datos (Firestore, Auth, Google Books API)

### Servicios externos
- Firebase Auth: login seguro y simple.
- Cloud Firestore: persistencia en tiempo real.
- Cloud Storage: almacenamiento de carátulas personalizadas (si aplica).
- Google Books API: búsqueda/importación de metadatos.

## 2) Flujo de datos
1. Usuario inicia sesión.
2. Se carga perfil y configuración.
3. En buscador se consulta Google Books.
4. Al importar, se genera documento de libro + entrada de progreso.
5. Cada avance actualiza progreso diario para analíticas.
6. Dashboard consulta agregados por periodos.

## 3) Seguridad y privacidad
- Reglas Firestore por `request.auth.uid`.
- Todas las colecciones bajo `/users/{uid}/...`.
- Sin características sociales ni datos compartidos.
- Logout y revocación de sesión local.

## 4) Estrategia de sincronización
- Firestore offline persistence habilitado.
- Resolución de conflictos por `updatedAt` (last-write-wins).
- Cola local para operaciones sin conexión.

## 5) Rendimiento
- Paginación en listados de biblioteca.
- Índices para filtros por estado, tags y fechas.
- Materialización opcional de métricas diarias (`daily_stats`) para dashboard rápido.

## 6) UX/UI
- Diseño minimalista, modo oscuro/claro, tipografía legible.
- Gestos Android: swipe para cambiar estado y actualizar progreso.
- Acciones de un toque para mover entre listas dinámicas.
