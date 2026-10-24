/// Module: core / custom / helpers
///
/// A line icon whose stroke is drawn at the SAME thickness on screen whatever
/// its source file says (Moataz 23/10/2026: the Settings menu icons "do not
/// have the same thickness"). The assets carry `stroke-width` from 0.89 to
/// 1.5 in viewBoxes from 15 to 29 wide, and each is drawn at a different
/// size, so on screen their lines differ. Every `stroke-width` in the file is
/// rewritten to [targetStroke] / (drawn scale) when it is loaded; the asset
/// files themselves are untouched. Filled icons are unaffected.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NormalizedStrokeSvg extends StatefulWidget {
  const NormalizedStrokeSvg({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.targetStroke = 0.9,
    this.outlineFilled = 0,
    this.equalArea = 22,
  });

  final String assetPath;
  final double width;
  final double height;
  final BoxFit fit;
  final Color? color;

  /// Wanted line thickness on screen, in logical pixels.
  final double targetStroke;

  /// For icons drawn with filled shapes (no stroke): an outline of this many
  /// logical pixels is added in the shape's own colour, so they are not
  /// thinner than the line icons beside them. 0 = leave as is.
  final double outlineFilled;

  /// Every icon is drawn so that the square root of its width × height is this
  /// many logical pixels (a wide icon and a tall icon then look the same size
  /// by eye), never wider or taller than the box. 0 = just fit the box.
  final double equalArea;

  static final Map<String, String> _raw = <String, String>{};

  @override
  State<NormalizedStrokeSvg> createState() => _NormalizedStrokeSvgState();
}

class _NormalizedStrokeSvgState extends State<NormalizedStrokeSvg> {
  String? _svg;
  double _drawW = 0;
  double _drawH = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(NormalizedStrokeSvg old) {
    super.didUpdateWidget(old);
    if (old.assetPath != widget.assetPath ||
        old.width != widget.width ||
        old.height != widget.height ||
        old.targetStroke != widget.targetStroke ||
        old.outlineFilled != widget.outlineFilled ||
        old.equalArea != widget.equalArea) {
      _load();
    }
  }

  Future<void> _load() async {
    final String path = widget.assetPath;
    String raw =
        NormalizedStrokeSvg._raw[path] ?? await rootBundle.loadString(path);
    NormalizedStrokeSvg._raw[path] = raw;

    final RegExpMatch? vb =
        RegExp(r'viewBox="[\d.\-]+\s+[\d.\-]+\s+([\d.]+)\s+([\d.]+)"')
            .firstMatch(raw);
    final double vbW = double.tryParse(vb?.group(1) ?? '') ?? 24;
    final double vbH = double.tryParse(vb?.group(2) ?? '') ?? 24;
    double scale = widget.fit == BoxFit.fill
        ? (widget.width / vbW + widget.height / vbH) / 2
        : (widget.width / vbW < widget.height / vbH
            ? widget.width / vbW
            : widget.height / vbH);
    if (widget.equalArea > 0 && widget.fit != BoxFit.fill) {
      final double byArea = widget.equalArea.sp / math.sqrt(vbW * vbH);
      if (byArea < scale) scale = byArea;
    }
    _drawW = vbW * scale;
    _drawH = vbH * scale;
    final String wanted = (widget.targetStroke / scale).toStringAsFixed(4);
    raw = raw.replaceAll(
        RegExp(r'stroke-width="[\d.]+"'), 'stroke-width="$wanted"');
    if (widget.outlineFilled > 0) {
      final String outline = (widget.outlineFilled / scale).toStringAsFixed(4);
      raw = raw.replaceAllMapped(
        RegExp(r'<path(?![^>]*stroke=)([^>]*?)fill="(#[0-9A-Fa-f]{3,8})"'),
        (Match m) =>
            '<path${m.group(1)}fill="${m.group(2)}" stroke="${m.group(2)}" stroke-width="$outline" stroke-linejoin="round"',
      );
    }
    if (mounted && path == widget.assetPath) setState(() => _svg = raw);
  }

  @override
  Widget build(BuildContext context) {
    final String? svg = _svg;
    if (svg == null) {
      return SizedBox(width: widget.width, height: widget.height);
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: SvgPicture.string(
          svg,
          width: _drawW > 0 ? _drawW : widget.width,
          height: _drawH > 0 ? _drawH : widget.height,
          fit: widget.fit,
          colorFilter: widget.color == null
              ? null
              : ColorFilter.mode(widget.color!, BlendMode.srcIn),
        ),
      ),
    );
  }
}
