import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderSize = 44,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double placeholderSize;

  @override
  Widget build(BuildContext context) {
    final source = imageUrl.trim();
    if (source.isEmpty) return _placeholder();

    final uri = Uri.tryParse(source);
    final isNetwork =
        uri != null && (uri.isScheme('http') || uri.isScheme('https'));
    if (isNetwork) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    final file = File(source);
    if (!file.existsSync()) return _placeholder();
    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: placeholderSize,
        color: AppColors.textHint,
      ),
    );
  }
}
