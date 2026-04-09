import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../shared/widgets/empty_state.dart';
import '../books/presentation/books_controller.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final stats = ref.watch(libraryStatsProvider);
    final genres = stats.genreDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (stats.totalBooks == 0) {
      return const Scaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.insights_rounded,
            title: 'Aún no hay señales de lectura',
            message:
                'Cuando guardes tus primeros libros, aquí aparecerán páginas por mes, géneros y tu racha.',
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: AnimationLimiter(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 420),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 28,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                Text(
                  'Analytics local-first',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Todo este panel se calcula desde tu base de datos local, sin mocks ni servicios remotos.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _KpiCard(
                      label: 'Libros',
                      value: stats.totalBooks.toString(),
                    ),
                    _KpiCard(
                      label: 'Leídos',
                      value: stats.readBooks.toString(),
                    ),
                    _KpiCard(
                      label: 'Racha actual',
                      value: '${stats.currentStreak} días',
                    ),
                    _KpiCard(
                      label: 'Favoritos',
                      value: stats.favoriteBooks.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Páginas leídas por mes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Conteo real a partir de cada avance registrado en la ficha.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 250,
                          child: BarChart(
                            BarChartData(
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 20,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: scheme.outlineVariant,
                                  strokeWidth: 1,
                                ),
                                drawVerticalLine: false,
                              ),
                              borderData: FlBorderData(show: false),
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 34,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const labels = [
                                        'E',
                                        'F',
                                        'M',
                                        'A',
                                        'M',
                                        'J',
                                        'J',
                                        'A',
                                        'S',
                                        'O',
                                        'N',
                                        'D',
                                      ];
                                      final index = value.toInt();
                                      if (index < 0 || index >= labels.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(labels[index]),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(12, (index) {
                                final month = index + 1;
                                final value = stats.pagesPerMonth[month] ?? 0;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: value.toDouble(),
                                      width: 16,
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          scheme.primary,
                                          scheme.tertiary,
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Géneros predominantes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 18),
                        if (genres.isEmpty)
                          Text(
                            'Todavía no hay géneros suficientes para componer el gráfico.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 220,
                                  child: PieChart(
                                    PieChartData(
                                      centerSpaceRadius: 54,
                                      sectionsSpace: 4,
                                      sections: [
                                        for (
                                          var index = 0;
                                          index < genres.length;
                                          index++
                                        )
                                          PieChartSectionData(
                                            value: genres[index].value
                                                .toDouble(),
                                            color: _palette(index, scheme),
                                            title: genres[index].value
                                                .toString(),
                                            radius: 88,
                                            titleStyle: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(color: Colors.white),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  children: [
                                    for (
                                      var index = 0;
                                      index < genres.length;
                                      index++
                                    )
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: _palette(index, scheme),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(genres[index].key),
                                            ),
                                            Text(
                                              genres[index].value.toString(),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _palette(int index, ColorScheme scheme) {
    final colors = [
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      scheme.error,
      scheme.primaryContainer,
    ];
    return colors[index % colors.length];
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 10),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
