/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: helper_widget.dart
/// Purpose: Measures the width of a one-line text, for the tab bar underline.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

double getTextWidth(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: ui.TextDirection.ltr,
  )..layout();
  return textPainter.size.width;
}
