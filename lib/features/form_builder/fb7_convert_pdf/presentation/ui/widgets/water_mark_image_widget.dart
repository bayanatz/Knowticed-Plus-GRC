/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: water_mark_image_widget.dart
/// Description: `PdfWaterMarkImagePage` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';

class PdfWaterMarkImagePage extends StatelessWidget {
  const PdfWaterMarkImagePage(
      {super.key, required this.page, required this.model});

  /// The main page widget displayed beneath the watermark.
  final Widget page;
  final FormEntity model;
  @override
  Widget build(BuildContext context) {
    return _buildPageWithWatermark(context);
  }

  /// Builds the page with an optional watermark overlay.
  Widget _buildPageWithWatermark(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 342.h,
        ),
        child: Stack(
          children: [
            if (model.formHeadModel.watermark != null) _buildWatermarkOverlay(),
            page,
          ],
        ),
      ),
    );
  }

  /// Builds the watermark overlay.
  Widget _buildWatermarkOverlay() {
    return Positioned.fill(
      child: Transform.scale(
        scale: model.formHeadModel.watermarkSize! / 100,
        child: Opacity(
          opacity: model.formHeadModel.watermarkOpacity! / 100,
          child: (model.formHeadModel.watermark!.contains('http'))
              ? Image.network(
                  model.formHeadModel.watermark!,
                )
              : Image.file(
                  File(model.formHeadModel.watermark!),
                ),
        ),
      ),
    );
  }
}
