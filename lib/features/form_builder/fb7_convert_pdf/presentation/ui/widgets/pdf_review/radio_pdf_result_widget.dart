/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: radio_pdf_result_widget.dart
/// Description: `RadioPdfResultWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/arrangement.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_field_model.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

class RadioPdfResultWidget extends StatelessWidget {
  const RadioPdfResultWidget({super.key, required this.model});

  final RadioFieldModel model;

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
            _buildRadioOptions(model),
          ],
        ),
      ),
    );
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context, RadioFieldModel model) {
    return model.alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  /// Build radio options based on arrangement (vertical or horizontal)
  Widget _buildRadioOptions(RadioFieldModel model) {
    return model.arrangement == Arrangement.vertical.name
        ? _buildVerticalRadios(model)
        : _buildHorizontalRadios(model);
  }

  /// Build vertical radio options
  Column _buildVerticalRadios(RadioFieldModel model) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: model.hints.map((option) => _buildRadioRow(option)).toList(),
    );
  }

  /// Build horizontal radio options
  Wrap _buildHorizontalRadios(RadioFieldModel model) {
    return Wrap(
      children: model.hints.map((option) => _buildRadioRow(option)).toList(),
    );
  }

  /// Build individual radio row with radio button and text
  Widget _buildRadioRow(String option) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8.0, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomSvgImage.natural(assetPath: AppAssets.radio),
          horizontalSpace(5),
          Flexible(child: Text(option, style: StyleText.fontSize14Weight500)),
        ],
      ),
    );
  }
}
