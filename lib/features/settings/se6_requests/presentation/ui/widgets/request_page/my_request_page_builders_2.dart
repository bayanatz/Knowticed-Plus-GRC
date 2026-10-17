/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_page_builders_2.dart
/// Description: UI builder methods of `_MyRequestPageState` — split out of `request_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/request_page.dart';

// Split from request_page.dart to keep every file under 700 lines.

extension _MyRequestPageStateBuilders2 on _MyRequestPageState {
  Widget _statusChip(String count, String label,
      {required bool isSelected,
      required Color labelColor,
      required VoidCallback onTap}) {
    var light = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight400.copyWith(
                        color: light
                            ? isSelected
                                ? AppColors.textButton
                                : AppColors.secondaryText
                            : isSelected
                                ? AppColors.textButton
                                : AppColors.grey,
                      )
                    : StyleText.fontSize20Weight500.copyWith(
                        color: light
                            ? isSelected
                                ? AppColors.textButton
                                : AppColors.secondaryText
                            : isSelected
                                ? AppColors.textButton
                                : AppColors.grey,
                      ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          SizedBox(
            child: Text(
              label,
              style: isMobile
                  ? StyleText.fontSize14Weight600.copyWith(color: labelColor)
                  : StyleText.fontSize16Weight600.copyWith(color: labelColor),
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}
