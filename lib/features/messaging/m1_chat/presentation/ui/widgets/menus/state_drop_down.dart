/// Module: messaging / chat / presentation/ui/widgets/menus/state_drop_down.dart
/// Purpose: Overflow menu driven by an enum. Renders [customButton] as the
///          trigger and one row per enum value, highlighting [currentValue].
///
/// Built on PopupMenuButton rather than a dropdown widget because the trigger
/// here is an arbitrary widget (the "⋮" icon), which CustomDropdown — which
/// always renders its own field-style trigger — can't express.
///
/// Lives in the messaging feature rather than lib/core because it resolves
/// labels through ChatActionsEnum, a messaging domain type.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';

import '../../../../domain/enum/chat_actions.dart';

class StateDropDown extends StatelessWidget {
  const StateDropDown({
    required this.items,
    required this.currentValue,
    required this.customButton,
    this.yOffset = 0,
    required this.textButton,
    this.menuWidth,
    this.xOffset = 0,
    required this.onChanged,
    super.key,
  });

  final List<Enum> items;
  final Enum? currentValue;
  final Widget? customButton;
  final double yOffset;

  /// Kept for source compatibility; the trigger is [customButton].
  final String textButton;

  final double? menuWidth;
  final double xOffset;
  final void Function(Enum) onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isAr = context.isArabic;

    return PopupMenuButton<Enum>(
      offset: Offset(xOffset, yOffset),
      color: AppColors.card,
      elevation: 4,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      constraints: menuWidth == null
          ? null
          : BoxConstraints(minWidth: menuWidth!, maxWidth: menuWidth!),
      onSelected: onChanged,
      itemBuilder: (_) => items.map((Enum value) {
        final bool isSelected = currentValue == value;
        final String label =
            value is ChatActionsEnum ? value.getLabel(isAr) : value.name;

        return PopupMenuItem<Enum>(
          value: value,
          height: 35.sp,
          padding: EdgeInsets.zero,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            width: double.infinity,
            height: double.infinity,
            color: isSelected ? AppColors.primary : AppColors.background,
            child: Text(
              label,
              style: isSelected
                  ? AppTextStyles.font14BlackCairo
                  : AppTextStyles.font14SecondaryBlackCairo,
            ),
          ),
        );
      }).toList(),
      child: customButton ??
          Container(
            width: 70.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(AppAssets.sort),
                Text(
                  isAr ? 'ترتيب' : 'Sort',
                  style: AppTextStyles.font14SecondaryBlackCairo,
                ),
              ],
            ),
          ),
    );
  }
}
