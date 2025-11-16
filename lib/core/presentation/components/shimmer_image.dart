import 'dart:io';
import 'package:flutter/material.dart';
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

    ImageProvider imageProvider;
    if (isNetworkImage) {
      imageProvider = NetworkImage(imageUrl);
    } else {
      imageProvider = FileImage(File(imageUrl));
    }

    return Image(
      image: imageProvider,
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
                  baseColor: Colors.grey[850]!, // Darker base color for shimmer
                  highlightColor: Colors.grey[800]!, // Subtler highlight
                  child: Container(
                    width: width,
                    height: height,
                    color: Colors.black, // Background color of the shimmer area
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
