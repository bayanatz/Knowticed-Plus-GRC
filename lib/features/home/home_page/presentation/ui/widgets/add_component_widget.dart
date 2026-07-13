import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class AddComponentWidget extends StatelessWidget {
  AddComponentWidget(
      {required this.columnIndex, required this.rowIndex, super.key});
  int columnIndex;
  int rowIndex;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.sp),
      child: DottedBorder(
          padding: EdgeInsets.all(0.sp),
          color: AppColors.primary,
          strokeWidth: 1,
          borderType: BorderType.RRect,
          radius: Radius.circular(8.sp),
          dashPattern: [10, 5],
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.sp),
              border: Border.all(color: AppColors.border, width: 1.sp),
              color: AppColors.field,
            ),
            height: 137.sp,
            width: 125.sp,
            child: Center(
              child: Icon(Icons.add, size: 24.sp, color: AppColors.text),
            ),
          )),
    );
  }
}
