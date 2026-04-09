import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.imageUrl,
    this.width = 78,
    this.height = 112,
    this.heroTag,
  });

  final String imageUrl;
  final double width;
  final double height;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final child = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: imageUrl.isEmpty
            ? _FallbackCover(width: width, height: height)
            : CachedNetworkImage(
                imageUrl: imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    _FallbackCover(width: width, height: height, loading: true),
                errorWidget: (context, url, error) =>
                    _FallbackCover(width: width, height: height),
              ),
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: heroTag == null ? child : Hero(tag: heroTag!, child: child),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover({
    required this.width,
    required this.height,
    this.loading = false,
  });

  final double width;
  final double height;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.tertiaryContainer,
            scheme.primaryContainer,
            scheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: loading
            ? CircularProgressIndicator(
                color: scheme.onTertiaryContainer,
                strokeWidth: 2,
              )
            : Icon(
                Icons.auto_stories_rounded,
                color: scheme.onTertiaryContainer,
                size: width * 0.38,
              ),
      ),
    );
  }
}
