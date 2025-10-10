import 'dart:io';
import 'package:flutter/material.dart';

/// Universal Image Widget that handles both local files and network URLs
class UniversalImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;

  const UniversalImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
  });

  bool get isNetworkImage =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (isNetworkImage) {
      return Image.network(
        imagePath,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _defaultPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _defaultErrorWidget();
        },
      );
    } else {
      // Local file
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _defaultErrorWidget();
          },
        );
      } else {
        return errorWidget ?? _defaultErrorWidget();
      }
    }
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }
}

/// Grid Thumbnail Widget for profile posts/reels
class GridThumbnail extends StatelessWidget {
  final String imagePath;
  final bool isVideo;
  final int? playCount;
  final bool hasMultipleImages;
  final VoidCallback? onTap;

  const GridThumbnail({
    super.key,
    required this.imagePath,
    this.isVideo = false,
    this.playCount,
    this.hasMultipleImages = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          UniversalImage(
            imagePath: imagePath,
            fit: BoxFit.cover,
            errorWidget: Container(
              color: isVideo ? Colors.grey[800] : Colors.grey[300],
              child: Icon(
                isVideo ? Icons.play_circle_outline : Icons.image,
                size: 50,
                color: isVideo ? Colors.white : Colors.grey,
              ),
            ),
          ),

          // Video play icon overlay
          if (isVideo)
            const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
                shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
            ),

          // Multiple images indicator
          if (hasMultipleImages)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.collections,
                color: Colors.white,
                size: 20,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),

          // Play count for videos
          if (isVideo && playCount != null)
            Positioned(
              bottom: 8,
              left: 8,
              child: Row(
                children: [
                  const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(playCount!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
