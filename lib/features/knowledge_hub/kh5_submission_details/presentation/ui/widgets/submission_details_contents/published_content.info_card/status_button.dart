/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/submission_details_contents/published_content.info_card
///
///*************************** FILE INFO ****************************///
/// File Name: status_button.dart
/// Description: `_buildStatusButton()`, `_showErrorDialog()` — split out of `published_content.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../published_content.dart';

// Split from build_published_content.info_card.dart to keep every file under 700 lines.

Widget _buildStatusButton({
  required Map<String, dynamic> statusInfo,
  required double width,
  required bool lightMode,
}) {
  return Container(
    height: 36.sp,
    width: width,
    decoration: BoxDecoration(
      color: AppColors.card,
      border: Border.all(color: statusInfo['color'], width: 2),
      borderRadius: BorderRadius.circular(8.r),
    ),
    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            color: statusInfo['color'],
            shape: BoxShape.circle,
          ),
          child: Center(child: statusInfo['widget']),
        ),
        SizedBox(width: 8.w),
        Text(
          statusInfo['text'],
          style: StyleText.fontSize16Weight500.copyWith(
            color: statusInfo['color'],
          ),
        ),
      ],
    ),
  );
}
