/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: check_box_pdf_preview_widget.dart
/// Description: `CheckBoxPdfPreviewWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/arrangement.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/check_box_field_model.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';

class CheckBoxPdfPreviewWidget extends StatelessWidget {
  const CheckBoxPdfPreviewWidget({super.key, required this.model});

  final CheckBoxFieldModel model;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: model.alignment.alignment,
      child: SizedBox(
        width: _calculateWidth(context, model),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextRequiredWidget(isRequired: model.isRequired, text: model.title),
            verticalSpace(8),
            _buildCheckBoxOptions(model),
          ],
        ),
      ),
    );
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context, CheckBoxFieldModel model) {
    return model.alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  /// Build checkbox options based on arrangement
  Widget _buildCheckBoxOptions(CheckBoxFieldModel model) {
    return model.arrangement == Arrangement.vertical.name
        ? _buildVerticalCheckBoxes(model)
        : _buildHorizontalCheckBoxes(model);
  }

  /// Build vertical checkbox options
  Column _buildVerticalCheckBoxes(CheckBoxFieldModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _buildCheckBoxRows(model),
    );
  }

  /// Build horizontal checkbox options
  Wrap _buildHorizontalCheckBoxes(CheckBoxFieldModel model) {
    return Wrap(children: _buildCheckBoxRows(model));
  }

  /// Generate checkbox rows with options
  List<Widget> _buildCheckBoxRows(CheckBoxFieldModel model) {
    return model.options.asMap().entries.map<Widget>((entry) {
      var option = entry.value;

      return Container(
        margin: EdgeInsetsDirectional.only(bottom: 8.h, end: 8.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSvgImage.natural(assetPath: AppAssets.checkbox),
            horizontalSpace(5),
            Flexible(
              child: Text(
                option,
                style: StyleText.fontSize14Weight400,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
