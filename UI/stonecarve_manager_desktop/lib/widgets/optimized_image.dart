import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized image widget with caching and loading states
/// Improves performance by caching images and showing placeholders
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            color: Colors.grey[200],
            child: const Icon(
              Icons.broken_image,
              size: 48,
              color: Colors.grey,
            ),
          ),
      // Performance optimizations
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      // Limit memory cache
      memCacheHeight: 400,
      memCacheWidth: 400,
    );
  }
}

/// Optimized circular avatar with image caching
class OptimizedCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? fallbackChild;
  final Color? backgroundColor;

  const OptimizedCircleAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.fallbackChild,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: fallbackChild,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      backgroundImage: CachedNetworkImageProvider(
        imageUrl!,
        maxHeight: (radius * 2 * MediaQuery.of(context).devicePixelRatio).toInt(),
        maxWidth: (radius * 2 * MediaQuery.of(context).devicePixelRatio).toInt(),
      ),
      onBackgroundImageError: (exception, stackTrace) {
        // Silently handle error, fallback to color background
      },
      child: null,
    );
  }
}
