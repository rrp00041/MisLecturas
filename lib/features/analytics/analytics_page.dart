import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Dashboard', style: TextStyle(fontSize: 24)),
        SizedBox(height: 12),
        _MetricCard(
          title: 'Volumen',
          description: 'Libros leídos por mes/año (barras).',
        ),
        _MetricCard(
          title: 'Ritmo de lectura',
          description: 'Páginas por día/semana (línea).',
        ),
        _MetricCard(
          title: 'Taxonomía',
          description: 'Distribución por géneros y autores (donut).',
        ),
        _MetricCard(
          title: 'Mapa de calor',
          description: 'Intensidad de lectura por día de semana.',
        ),
        _MetricCard(
          title: 'Predicción ETA',
          description: 'Estimación con velocidad de últimos 7 días.',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.insights),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
