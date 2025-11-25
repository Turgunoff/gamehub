import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimallashtirilgan image widget'i
/// Network image'larni cache qiladi va placeholder ko'rsatadi
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _defaultErrorWidget(),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: Colors.grey.withOpacity(0.2),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
        ),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      child: const Icon(
        Icons.person,
        color: Color(0xFF6C5CE7),
        size: 40,
      ),
    );
  }
}

