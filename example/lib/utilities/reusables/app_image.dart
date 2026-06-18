import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

/// Supported image sources
enum ImageType { svg, network, file, asset }

/// Detect image type from the provided string
extension ImageTypeExtension on String {
  ImageType get imageType {
    final lower = toLowerCase();

    // Network images
    if (startsWith('http')) {
      return lower.endsWith('.svg') ? ImageType.svg : ImageType.network;
    }

    // Local file
    if (startsWith('/') || startsWith('file://')) {
      return ImageType.file;
    }

    // SVG asset
    if (lower.endsWith('.svg')) {
      return ImageType.svg;
    }

    // Default asset image
    return ImageType.asset;
  }
}

/// Reusable image widget that supports:
/// Network, SVG, Asset and File images
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.color,
    this.radius,
    this.border,
    this.margin,
    this.alignment,
    this.onTap,
    this.placeholder = 'assets/images/no-image.jpeg',
    this.errorWidget,
    this.semanticLabel,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;

  final BorderRadius? radius;
  final BoxBorder? border;

  final EdgeInsetsGeometry? margin;
  final Alignment? alignment;

  final VoidCallback? onTap;

  /// Image used when url is null or fails
  final String placeholder;

  final Widget? errorWidget;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget image = _buildImage();

    // Apply clipping if radius exists
    image = ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: image,
    );

    // Optional border
    if (border != null) {
      image = Container(
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: image,
      );
    }

    // Optional tap interaction
    if (onTap != null) {
      image = InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: image,
      );
    }

    // Optional margin
    if (margin != null) {
      image = Padding(padding: margin!, child: image);
    }

    // Optional alignment
    if (alignment != null) {
      image = Align(alignment: alignment!, child: image);
    }

    return image;
  }

  /// Decides which image builder to use
  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }

    switch (imageUrl!.imageType) {
      case ImageType.svg:
        return _buildSvg();

      case ImageType.network:
        return _buildNetwork();

      case ImageType.file:
        return _buildFile();

      case ImageType.asset:
        return _buildAsset();
    }
  }

  /// SVG image builder
  Widget _buildSvg() {
    final isNetwork = imageUrl!.startsWith('http');

    return SizedBox(
      height: height,
      width: width,
      child: isNetwork
          ? SvgPicture.network(
              imageUrl!,
              height: height,
              width: width,
              fit: fit ?? BoxFit.contain,
              colorFilter: _colorFilter,
              placeholderBuilder: (_) => _shimmer(),
            )
          : SvgPicture.asset(
              imageUrl!,
              height: height,
              width: width,
              fit: fit ?? BoxFit.contain,
              colorFilter: _colorFilter,
            ),
    );
  }

  /// Cached network image builder
  Widget _buildNetwork() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      color: color,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (_, __) => _shimmer(),
      errorWidget: (_, __, ___) => errorWidget ?? _placeholder(),
    );
  }

  /// Local file image builder
  Widget _buildFile() {
    final path = imageUrl!.replaceFirst('file://', '');

    return Image.file(
      File(path),
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      color: color,
      semanticLabel: semanticLabel,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  /// Asset image builder
  Widget _buildAsset() {
    return Image.asset(
      imageUrl!,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      color: color,
      semanticLabel: semanticLabel,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  /// Apply color filter if color exists
  ColorFilter? get _colorFilter =>
      color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null;

  /// Default placeholder widget
  Widget _placeholder() {
    return SizedBox(
      height: height,
      width: width,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// Loading shimmer used for network images
  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height ?? double.infinity,
        width: width ?? double.infinity,
        color: Colors.white,
      ),
    );
  }
}
