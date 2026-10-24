/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: preview_all_custom_page_builders_2.dart
/// Description: UI builder methods of `_PreviewAllCustomPageState` — split out of `preview.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../preview.dart';

// Split from preview.dart to keep every file under 700 lines.

extension _PreviewAllCustomPageStateBuilders2 on _PreviewAllCustomPageState {
  /// Shared section wrapper: title + a bordered card holding the demo widget.
  Widget _section(String title, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          // Demos sit on a card, as on real screens: fields fill with
          // AppColors.background and were invisible on the bare page.
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            // Start-aligned so fixed-size customs (38 icon buttons, sort,
            // chips) show at their real size instead of being stretched.
            alignment: AlignmentDirectional.centerStart,
            child: child,
          ),
        ],
      ),
    );
  }
}
