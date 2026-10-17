/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_svg_image.dart
/// Purpose: Declares `CustomSvgImage`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The single entry point for rendering SVG assets.
///
/// Nothing outside this file should call [SvgPicture] directly — that keeps
/// sizing, tinting and fit behaviour consistent across the app, and gives us
/// one place to adapt if flutter_svg's API shifts again.
///
/// Sizing:
///  * [CustomSvgImage] falls back to 12.sp when no width/height is given.
///  * [CustomSvgImage.natural] renders at the asset's own intrinsic size instead.
///
/// Tinting: pass [color] to tint the whole glyph (equivalent to the old
/// `SvgPicture.color`), or [colorFilter] for full control. [colorFilter] wins
/// when both are supplied. A null tint leaves the asset's own colours intact,
/// except `currentColor`: neutral icons (greys/black) are saved with
/// `currentColor`, which resolves to [color] or else [AppColors.icon], so
/// untinted icons follow the theme and dark mode (asset clean-up 17/10/2026).
class CustomSvgImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final ColorFilter? colorFilter;
  final Alignment alignment;
  final String? semanticsLabel;

  /// When true, width/height fall through as null so the asset renders at its
  /// intrinsic size rather than the 12.sp default.
  final bool useNaturalSize;

  const CustomSvgImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.scaleDown,
    this.color,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.semanticsLabel,
  }) : useNaturalSize = false;

  /// Renders at the asset's intrinsic size. Any [width]/[height] passed here is
  /// still honoured; omitting them means "whatever the asset declares".
  const CustomSvgImage.natural({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorFilter,
    this.alignment = Alignment.center,
    this.semanticsLabel,
  }) : useNaturalSize = true;

  ColorFilter? get _filter {
    if (colorFilter != null) return colorFilter;
    if (color != null) return ColorFilter.mode(color!, BlendMode.srcIn);
    return null;
  }

  /// True for a PNG / JPG / WebP / GIF path. ADDED 17/10/2026: ~47 callers
  /// pass the raster avatar `ic_user_avatar_male.png`; drawn as SVG its bytes
  /// threw `XmlParserException ">" expected at 8:21` and left an empty circle.
  bool get _isRaster =>
      RegExp(r'\.(png|jpe?g|webp|gif)$', caseSensitive: false)
          .hasMatch(assetPath);

  @override
  Widget build(BuildContext context) {
    // A raster keeps its own colours (it is a picture, not a line icon), so
    // [color] / [colorFilter] tint SVGs only.
    if (_isRaster) {
      return Image.asset(
        assetPath,
        width: useNaturalSize ? width : (width ?? 12.sp),
        height: useNaturalSize ? height : (height ?? 12.sp),
        fit: fit,
        alignment: alignment,
        semanticLabel: semanticsLabel,
      );
    }
    return SvgPicture.asset(
      assetPath,
      width: useNaturalSize ? width : (width ?? 12.sp),
      height: useNaturalSize ? height : (height ?? 12.sp),
      fit: fit,
      alignment: alignment,
      colorFilter: _filter,
      theme: SvgTheme(currentColor: color ?? AppColors.icon),
      semanticsLabel: semanticsLabel,
    );
  }
}
