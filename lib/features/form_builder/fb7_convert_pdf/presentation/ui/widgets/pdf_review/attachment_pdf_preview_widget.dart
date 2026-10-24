/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_pdf_preview_widget.dart
/// Description: `AttachmentPdfPreviewWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

// ignore_for_file: deprecated_member_use

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_field_model.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';

class AttachmentPdfPreviewWidget extends StatelessWidget {
  const AttachmentPdfPreviewWidget({super.key, required this.model});
  final AttachmentFieldModel model;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRequiredWidget(
          isRequired: model.isRequired,
          text: model.title,
        ),
        verticalSpace(8),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            alignment: Alignment.center,
            child: SizedBox(
              height: 45,
              width: 45,
              child: CustomSvgImage.natural(
                  assetPath: AppAssets.attachmentPdf,
                  colorFilter:
                      ColorFilter.mode(AppColors.text, BlendMode.srcIn)),
            ),
          ),
        )
      ],
    );
  }
}
