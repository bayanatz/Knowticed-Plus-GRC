import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
// vector_graphics is a transitive dependency of flutter_svg and provides the
// low-level `vg.loadPicture` API used to rasterize an SVG into a ui.Image.
// ignore: depend_on_referenced_packages
import 'package:vector_graphics/vector_graphics.dart' as vg_lib;

/// Returns the correct [ImageProvider] for a given path.
///
/// - `http`/`https` urls  -> [NetworkImage]
/// - asset paths ending in `.svg` -> [SvgImageProvider] (rasterizes the SVG)
/// - everything else (png/jpg/... asset) -> [AssetImage]
///
/// This lets existing `AssetImage(path)` / `backgroundImage:` / `DecorationImage`
/// call sites keep working even when the path now points to an `.svg` file.
ImageProvider appImageProvider(String path) {
  if (path.startsWith('http')) {
    return NetworkImage(path);
  }
  if (path.toLowerCase().endsWith('.svg')) {
    return SvgImageProvider(path);
  }
  return AssetImage(path);
}

/// Returns a widget that renders [path] whether it is an svg asset, a raster
/// asset, or a network image. Use this to replace raw `Image.asset(path)` calls
/// that may now receive an `.svg` path.
Widget appImageWidget(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
  Color? color,
}) {
  if (path.startsWith('http')) {
    return Image.network(path, width: width, height: height, fit: fit);
  }
  if (path.toLowerCase().endsWith('.svg')) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
  return Image.asset(path, width: width, height: height, fit: fit, color: color);
}

/// An [ImageProvider] that loads an SVG asset and rasterizes it so it can be
/// used anywhere a normal [ImageProvider] is expected (e.g.
/// `CircleAvatar.backgroundImage`, `DecorationImage`, `Image(image: ...)`).
@immutable
class SvgImageProvider extends ImageProvider<SvgImageProvider> {
  const SvgImageProvider(this.assetName, {this.scale = 1.0, this.pixelSize});

  /// The asset path of the `.svg` file.
  final String assetName;

  /// Output scale passed to the produced [ImageInfo].
  final double scale;

  /// Optional rasterization size (width == height) in pixels. Defaults to the
  /// SVG's intrinsic size.
  final int? pixelSize;

  @override
  Future<SvgImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<SvgImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    SvgImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      _loadAsync(key),
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('SVG asset: $assetName'),
      ],
    );
  }

  Future<ImageInfo> _loadAsync(SvgImageProvider key) async {
    final SvgAssetLoader loader = SvgAssetLoader(assetName);
    final vg_lib.PictureInfo pictureInfo =
        await vg_lib.vg.loadPicture(loader, null);

    final ui.Size size = pictureInfo.size;
    int width = pixelSize ?? size.width.ceil();
    int height = pixelSize ?? size.height.ceil();
    if (width <= 0) width = 1;
    if (height <= 0) height = 1;

    final ui.Image image = pictureInfo.picture.toImageSync(width, height);
    pictureInfo.picture.dispose();

    return ImageInfo(image: image, scale: key.scale);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SvgImageProvider &&
        other.assetName == assetName &&
        other.scale == scale &&
        other.pixelSize == pixelSize;
  }

  @override
  int get hashCode => Object.hash(assetName, scale, pixelSize);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SvgImageProvider')}("$assetName", scale: $scale)';
}
