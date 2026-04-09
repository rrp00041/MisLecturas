import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 170,
                width: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 12,
                      left: 28,
                      child: _Orb(
                        color: scheme.tertiary.withValues(alpha: 0.35),
                        size: 72,
                      ),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 12,
                      child: _Orb(
                        color: scheme.secondary.withValues(alpha: 0.28),
                        size: 94,
                      ),
                    ),
                    Container(
                      width: 146,
                      height: 146,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(44),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scheme.surface,
                            scheme.surfaceContainerHighest.withValues(
                              alpha: 0.85,
                            ),
                          ],
                        ),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Icon(icon, size: 56, color: scheme.primary),
                    ),
                  ],
                ),
              ),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (action != null) ...[const SizedBox(height: 22), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 34,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}
