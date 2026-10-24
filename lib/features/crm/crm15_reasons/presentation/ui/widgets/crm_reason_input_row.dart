// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reason_input_row.dart
// Purpose: Responsive bilingual editable row for a CRM reason
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmReasonInputRow extends StatefulWidget {
  final String initialNameEn;
  final String initialNameAr;
  final bool readOnly;
  final bool canDelete;
  final ValueChanged<String> onNameEnChanged;
  final ValueChanged<String> onNameArChanged;
  final VoidCallback onDelete;

  const CrmReasonInputRow({
    super.key,
    required this.initialNameEn,
    required this.initialNameAr,
    required this.readOnly,
    required this.canDelete,
    required this.onNameEnChanged,
    required this.onNameArChanged,
    required this.onDelete,
  });

  @override
  State<CrmReasonInputRow> createState() => _CrmReasonInputRowState();
}

class _CrmReasonInputRowState extends State<CrmReasonInputRow> {
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
    final Widget english = CustomTextField(
      controller: _nameEnController,
      hint: 'Text Here',
      readOnly: widget.readOnly,
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
        onChanged: widget.onNameArChanged,
      ),
    );
    final Widget remove = customButtonWithSvg(
      title: '',
      function: widget.onDelete,
      color: AppColors.transparent,
      colorBorder: AppColors.transparent,
      image: AppAssets.minusCircle,
      widthImage: 18.sp,
      heightImage: 18.sp,
      textStyle: StyleText.fontSize12Weight400,
    );
    if (kpIsPhoneLayout(context)) {
      return Padding(
        padding: EdgeInsets.only(bottom: 10.sp),
        child: Column(children: <Widget>[
          english,
          SizedBox(height: 8.sp),
          Row(children: <Widget>[
            Expanded(child: arabic),
            if (!widget.readOnly && widget.canDelete) ...<Widget>[
              SizedBox(width: 8.sp),
              remove,
            ],
          ]),
        ]),
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 10.sp),
      child: Row(children: <Widget>[
        Expanded(child: english),
        SizedBox(width: 16.sp),
        Expanded(child: arabic),
        if (!widget.readOnly && widget.canDelete) ...<Widget>[
          SizedBox(width: 8.sp),
          remove,
        ],
      ]),
    );
  }
}
