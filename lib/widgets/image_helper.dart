import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';

/// Widget helper untuk menampilkan gambar dari URL network atau path file lokal.
/// Menggunakan CachedNetworkImage untuk efisiensi
Widget buildImageWidget(
  String imagePath, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  if (imagePath.isEmpty) return const SizedBox.shrink();

  // Gambar dari network (URL)
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, _) => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue),
        ),
      ),
      errorWidget: (_, _, _) => const Icon(Icons.broken_image, color: greyText),
    );
  }

  // Gambar dari asset lokal
  if (imagePath.startsWith('assets/')) {
    return Image.asset(
      imagePath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.broken_image, color: greyText),
    );
  }

  // Gambar dari file lokal
  return Image.file(
    File(imagePath),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (_, _, _) => const Icon(Icons.broken_image, color: greyText),
  );
}
