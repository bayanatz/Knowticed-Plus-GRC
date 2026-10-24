/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets/approvals_details_screen.sections
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_details_sections_builders.dart
/// Description: UI builder methods of `_ApprovalsDetailsSections` — split out of `approvals_details_screen.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/approvals_details_screen.dart';

// Split from approvals_details_screen.sections.dart to keep every file under 700 lines.

mixin _ApprovalsDetailsSectionsBuilders
    on State<ApprovalsDetailsScreen>, _ApprovalsDetailsSections {
  /// ✅ Build user data info row — two "icon Key value" items, stacked on a
  /// phone and side by side on wider screens.
  Widget buildUserDataInfo({
    required String firstKey,
    required String firstValue,
    required String secondKey,
    required String secondValue,
    required Widget firstIcon,
    required Widget secondIcon,
    required bool isMobile,
    required bool lightMode,
    Widget? userPhoto,
  }) {
    if (isMobile) {
      return Column(
        children: [
          _userInfoItem(
            icon: firstIcon,
            label: firstKey,
            value: firstValue,
            leading: userPhoto,
            gap: 4.w,
          ),
          SizedBox(height: 12.h),
          _userInfoItem(
            icon: secondIcon,
            label: secondKey,
            value: secondValue,
            gap: 4.w,
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _userInfoItem(
            icon: SizedBox(height: 16.h, width: 16.w, child: firstIcon),
            label: firstKey,
            value: firstValue,
            leading: userPhoto,
            gap: 3.w,
          ),
        ),
        Expanded(
          child: _userInfoItem(
            icon: SizedBox(height: 16.h, width: 16.w, child: secondIcon),
            label: secondKey,
            value: FormatHelper.capitalize(secondValue),
            gap: 3.w,
          ),
        ),
      ],
    );
  }

  /// One "icon Key value" item, with an optional photo before the value.
  Widget _userInfoItem({
    required Widget icon,
    required String label,
    required String value,
    required double gap,
    Widget? leading,
  }) {
    return Row(
      children: [
        icon,
        SizedBox(width: gap),
        Text(
          label,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.secondaryText.withValues(alpha: .7),
          ),
        ),
        if (leading != null) ...[leading, SizedBox(width: 4.w)],
        Expanded(
          child: Text(
            value,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.blackButton,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
