/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: image_pdf_preview_widget.dart
/// Description: `ImagePdfPreviewWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/image_field_model.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;

class ImagePdfPreviewWidget extends StatelessWidget {
  const ImagePdfPreviewWidget({
    super.key,
    required this.model,
  });
  final ImageFieldModel model;
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
        SizedBox(
          width: double.infinity,
          child: Wrap(
            children:
                List.generate(model.limitation.toEnglishNumber(), (index) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.all(Radius.circular(4))),
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 45,
                    width: 45,
                    // AppAssets.image is a PNG; SvgPicture drew nothing.
                    child: Image.asset(
                      AppAssets.image,
                      color: AppColors.text,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
