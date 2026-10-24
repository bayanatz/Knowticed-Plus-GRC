/// Module: form_builder_module/f8_convert_pdf
///
///*************************** FILE INFO ****************************///
/// File Name: address_pdf_preview_widget.dart
/// Description: `AddressPdfPreviewWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/10/2026 - Bug report p.62: colons, eye icons, hint colour.
library;

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/address_field_model.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';

class AddressPdfPreviewWidget extends StatelessWidget {
  const AddressPdfPreviewWidget({super.key, required this.model});

  final AddressFieldModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRequiredWidget(
          isRequired: model.isRequired,
          text: S.of(context).address,
        ),
        _buildAddressInputFields(model),
      ],
    );
  }

  /// Build address input fields in a wrap layout
  Widget _buildAddressInputFields(AddressFieldModel model) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _generateAddressInputRows(model),
    );
  }

  /// Generate rows of address input fields
  List<Widget> _generateAddressInputRows(AddressFieldModel model) {
    List<Widget> rows = [];
    for (int i = 0; i < model.hints.length; i += 2) {
      String? sec;
      if (i + 1 < model.hints.length) {
        sec = model.hints[i + 1];
      } else {
        sec = null;
      }
      rows.add(
        _buildAddressInputRow(firstAddress: model.hints[i], secondAddress: sec),
      );
    }
    return rows;
  }

  /// Build a row with two address input fields
  Widget _buildAddressInputRow({
    required String firstAddress,
    String? secondAddress,
  }) {
    return Row(
      children: [
        Expanded(child: _buildSingleAddressInput(firstAddress)),
        if (secondAddress != null) ...[
          horizontalSpace(15),
          Expanded(child: _buildSingleAddressInput(secondAddress)),
        ],
      ],
    );
  }

  /// Build single address input field
  Widget _buildSingleAddressInput(String hintText) {
    return CustomTextField(
      height: 36,
      contentPadding: EdgeInsets.symmetric(
        vertical: 12.sp,
        horizontal: 10.sp,
      ), // form bug report #40
      // No trailing ": " on the hint,
      // the default hint colour instead of secondaryBlack, and no
      // `obscureText: true` — it made every address box a password field,
      // which is what drew the eye icons.
      hint: hintText,
      maxLines: 1,
      readOnly: true,
      valueStyle: StyleText.fontSize12Weight400,
      fillColor: AppColors.background,
      width: double.infinity,
    );
  }
}
