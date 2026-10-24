/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_title_status_row.dart
/// Purpose: Displays a row with a colored status circle and a label, allowing customization of the appearance based on various conditions.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget presents a circle (status indicator) followed by a label (text). The color of the circle,
///              the text size, and the alignment can be customized dynamically. The widget is adaptable to different screen sizes,
///              including tablets and portrait/landscape orientations.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';

// ignore: must_be_immutable
class QiyasTitleStatusRow extends StatefulWidget {
  QiyasTitleStatusRow({
    super.key,
    required this.dataColor,
    required this.textData,
  });
  Color dataColor;
  String textData;

  @override
  State<QiyasTitleStatusRow> createState() => _QiyasTitleStatusRowState();
}

class _QiyasTitleStatusRowState extends State<QiyasTitleStatusRow> {
  //AddDepartmentController addDepartmentController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.circle, size: 15.sp, color: widget.dataColor),
        SizedBox(width: 10.sp),
        SizedBox(
          child: Text(widget.textData,
              style: context.isPhone
                  ? StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.text,
                    )
                  : StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.text,
                    )),
        ),
      ],
    );
  }
}
