import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const ShimmerImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imageUrl.startsWith('http');

    // Use cached_network_image for better performance with network images
    if (isNetworkImage) {
      // Safe conversion to int, handling infinity and NaN cases
      final int? cacheWidth = (width.isFinite && width > 0) ? width.toInt() : null;
      final int? cacheHeight = (height.isFinite && height > 0) ? height.toInt() : null;
      final int? diskCacheWidth = (width.isFinite && width > 0) ? (width * 2).toInt() : null;
      final int? diskCacheHeight = (height.isFinite && height > 0) ? (height * 2).toInt() : null;

      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[850]!,
          highlightColor: Colors.grey[800]!,
          child: Container(
            width: width,
            height: height,
            color: Colors.black,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade800,
          child: const Icon(Icons.error_outline, color: Colors.white),
        ),
        // Enable memory cache and disk cache for smooth scrolling
        // Only set if values are valid (not infinity or NaN)
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        maxWidthDiskCache: diskCacheWidth,
        maxHeightDiskCache: diskCacheHeight,
      );
    }

    // For local files, use the original Image widget
    // Check if file exists, otherwise show placeholder
    final file = File(imageUrl);
    if (!file.existsSync()) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade800,
        child: const Icon(Icons.image_not_supported, color: Colors.white54),
      );
    }

    return Image(
      image: FileImage(file),
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: frame != null
              ? child
              : Shimmer.fromColors(
                  baseColor: Colors.grey[850]!,
                  highlightColor: Colors.grey[800]!,
                  child: Container(
                    width: width,
                    height: height,
                    color: Colors.black,
                  ),
                ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade800,
          child: const Icon(Icons.error_outline, color: Colors.white),
        );
      },
    );
  }
}
