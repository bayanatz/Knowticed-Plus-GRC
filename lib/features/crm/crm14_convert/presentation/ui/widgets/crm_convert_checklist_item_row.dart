// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_checklist_item_row.dart
// Purpose: Responsive bilingual input row for conversion checklist items
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmConvertChecklistItemRow extends StatefulWidget {
  final int index;
  final String initialNameEn;
  final String initialNameAr;
  final bool readOnly;
  final bool canDelete;
  final ValueChanged<String> onNameEnChanged;
  final ValueChanged<String> onNameArChanged;
  final VoidCallback onDelete;

  const CrmConvertChecklistItemRow({
    super.key,
    this.index = 1,
    required this.initialNameEn,
    required this.initialNameAr,
    required this.readOnly,
    required this.canDelete,
    required this.onNameEnChanged,
    required this.onNameArChanged,
    required this.onDelete,
  });

  @override
  State<CrmConvertChecklistItemRow> createState() =>
      _CrmConvertChecklistItemRowState();
}

class _CrmConvertChecklistItemRowState
    extends State<CrmConvertChecklistItemRow> {
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(text: widget.initialNameEn);
    _nameArController = TextEditingController(text: widget.initialNameAr);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String itemLabel = FormatHelper.localizedString(
      englishName: 'Checklist ${widget.index}',
      arabicName: 'قائمة التحقق ${widget.index}',
    );

    final Widget english = CustomTextField(
      controller: _nameEnController,
      hint: 'Text Here',
      readOnly: widget.readOnly,
      fillColor: AppColors.background,
      onChanged: widget.onNameEnChanged,
    );

    final Widget arabic = Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        controller: _nameArController,
        hint: 'اكتب هنا',
        readOnly: widget.readOnly,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        fillColor: AppColors.background,
        onChanged: widget.onNameArChanged,
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 14.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                itemLabel,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
              if (!widget.readOnly && widget.canDelete)
                customButtonWithSvg(
                  title: '',
                  function: widget.onDelete,
                  color: AppColors.transparent,
                  colorBorder: AppColors.transparent,
                  image: AppAssets.minusCircle,
                  widthImage: 20.sp,
                  heightImage: 20.sp,
                  fixedWidth: 24.sp,
                  fixedHeight: 24.sp,
                  svgColor: AppColors.red,
                  textStyle: StyleText.fontSize12Weight400,
                ),
            ],
          ),
          SizedBox(height: 6.sp),
          buildResponsiveFields(
            context: context,
            left: english,
            right: arabic,
          ),
        ],
      ),
    );
  }
}
