/// Module: knowledge_hub/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: kh_filter_fields.dart
/// Description: The ONE dropdown and the ONE date field every Knowledge Hub
///              filter dialog uses (Hub search, Submissions, Approvals).
/// Author: Amr Mesbah
/// Created at: 14/10/2026
///
/// Taken from the Submissions filter dialog, which is the approved look:
/// [kKhFilterFieldHeight] tall, 12.sp side padding, background fill, 12.sp
/// hint in the secondary colour, one line, text centred vertically, and a
/// 20.sp trailing glyph (chevron / calendar) that dims while empty.
/// Change the look here and every filter dialog follows.
library;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Height of every filter field (dropdown and date), in `.sp` units.
const double kKhFilterFieldHeight = 40;

EdgeInsetsGeometry _kFieldPadding() =>
    EdgeInsetsDirectional.symmetric(horizontal: 12.sp);

/// A filter dropdown. [items] are `{'key': value, 'value': label}` maps —
/// the shape every KH filter dialog already builds.
class KhFilterDropdown extends StatelessWidget {
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  final String hint;
  final double? maxOverlayHeight;

  const KhFilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    this.maxOverlayHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      height: kKhFilterFieldHeight,
      triggerPadding: EdgeInsets.symmetric(horizontal: 12.sp),
      value: value,
      items: items
          .map(
            (e) => DropdownItem<String>(
              value: e['key'] ?? '',
              label: e['value'] ?? '',
            ),
          )
          .toList(),
      onChanged: onChanged,
      hint: hint,
      hintStyle: StyleText.fontSize12Weight400.copyWith(
        color: AppColors.secondaryText,
      ),
      maxOverlayHeight: maxOverlayHeight,
      fillColor: AppColors.background,
    );
  }
}

/// A filter date field: tap opens the app date picker, the hint is the title.
/// Pass [onClear] to show a small × once a date is picked.
class KhFilterDateField extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final ValueChanged<DateTime> onPicked;
  final VoidCallback? onClear;

  const KhFilterDateField({
    super.key,
    required this.value,
    required this.hint,
    required this.onPicked,
    this.onClear,
  });

  Future<void> _pick(BuildContext context) async {
    final DateTime initial = value ?? DateTime.now();
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
      context,
      [initial],
      initial,
      CalendarDatePicker2Type.single,
    );
    if (picked != null && picked.isNotEmpty && picked.first != null) {
      final DateTime d = picked.first!;
      onPicked(DateTime(d.year, d.month, d.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => HapticController.low(),
      onTap: () => _pick(context),
      child: Container(
        height: kKhFilterFieldHeight.sp,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: AppColors.background,
        ),
        padding: _kFieldPadding(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue
                    // Month names and digits follow the UI language.
                    ? KhLocale.formatDate(context, value!, 'dd MMM yyyy')
                    : hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: hasValue
                      ? AppColors.blackButton
                      : AppColors.secondaryText,
                ),
              ),
            ),
            if (hasValue && onClear != null)
              GestureDetector(
                onTapDown: hapticDown(onClear, HapticLevel.high),
                onTap: onClear,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: 4.sp),
                  child: Icon(
                    Icons.close,
                    size: 16.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
              height: 20.sp,
              width: 20.sp,
              color: kDropdownTrailingIconColor(hasValue: hasValue),
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
