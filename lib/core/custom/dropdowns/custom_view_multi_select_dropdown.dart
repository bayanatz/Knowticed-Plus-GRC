/// Module: services_management_module
/// Description: Master multi-select dropdown widget (checkbox list, single- or
///              multi-select modes, RTL/LTR aware) used across the services
///              module's create/edit forms.
/// Author: Amr Mesbah
/// Created at: 2026-07-02
/// Dependencies: dropdown_button2, flutter_screenutil, flutter_svg, get,
///               core/custom/25-custom_check_box.dart, core/theme/app_colors.dart,
///               core/theme/app_theme.dart, presentation/ui/widgets/custom_check_box.dart
/// Revision History: Initial version
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/cards/custom_person_chips.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CustomMultiSelectField extends StatefulWidget {
  const CustomMultiSelectField({
    super.key,
    required this.onChanged,
    required this.items,
    required this.textButton,
    required this.selectedItems,
    this.singleSelect = false,
    this.end,
    this.hintText,
    this.value,
    this.customSpacing,
    this.menuWidth,
    this.width,
    this.height,
    this.textColor,
    this.splashColorOn = true,
    this.showDropdownIcon = true,
    this.validator,
    this.fillColor,
    this.buttonRadius,
    this.svgIconPath,
    this.textStyle,
    this.menuItemHeight,
    this.showErrorBorder = false,
    this.iconOnly = false,
    this.itemLabel,
    this.onSelectionChanged,
    this.showSelectedBelow = true,
  });

  final bool singleSelect;
  final bool iconOnly; // NEW: Flag for icon-only mode
  final double? menuItemHeight;
  final Function(dynamic) onChanged;
  final List<String> selectedItems;
  final List<String> items;

  /// The text shown for an item. Null shows the item itself, so callers can
  /// keep stable ids in [items] and show translated labels.
  final String Function(String item)? itemLabel;

  /// ADDED 17/10/2026: the full picked list after every tap / chip removal.
  /// `onChanged` still receives the single toggled item (older screens).
  final ValueChanged<List<String>>? onSelectionChanged;

  /// ADDED 17/10/2026 (Moataz: "I cannot select and see the labels down"):
  /// the picked values show BELOW the field as removable chips (red ⊖).
  final bool showSelectedBelow;
  final String? textButton;
  final String? hintText;
  final dynamic value;
  final Widget? customSpacing;
  final bool splashColorOn, showErrorBorder;
  final bool showDropdownIcon;
  final Color? textColor;
  final String? svgIconPath;
  final TextStyle? textStyle;
  final String? Function(dynamic)? validator;
  final double? height, width, menuWidth;
  final double? end;
  final Color? fillColor;

  /// Corner radius of the closed button. Null keeps the historical 4.r.
  /// ADDED 25/9/2026 for the My Requests department filter (8.r).
  final double? buttonRadius;

  @override
  State<CustomMultiSelectField> createState() =>
      _AppMultiSelectDropdownMasterState();
}

class _AppMultiSelectDropdownMasterState extends State<CustomMultiSelectField> {
  late List<String> _selected = List<String>.of(widget.selectedItems);

  @override
  void didUpdateWidget(CustomMultiSelectField old) {
    super.didUpdateWidget(old);
    _selected = List<String>.of(widget.selectedItems);
  }

  void _toggle(String item) {
    setState(() {
      if (widget.singleSelect) {
        _selected = <String>[item];
      } else if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
    widget.onChanged(item);
    widget.onSelectionChanged?.call(List<String>.of(_selected));
  }

  @override
  Widget build(BuildContext context) {
    final Widget field = _buildField(context);
    if (!widget.showSelectedBelow || widget.singleSelect || _selected.isEmpty) {
      return field;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final String item in _selected)
              CustomRemovableChip(
                label: widget.itemLabel?.call(item) ?? item,
                onRemove: () => _toggle(item),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(BuildContext context) {
    Localizations.localeOf(context).languageCode == 'ar';
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            isDense: true,
            items: widget.items.map((item) {
              return DropdownMenuItem(
                value: item,
                enabled: false, // keep false (we handle taps)
                child: StatefulBuilder(
                  builder: (context, menuSetState) {
                    final isSelected = _selected.contains(item);
                    return InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        HapticController.low(); // menu row (X-117)
                        _toggle(item);

                        // For single select: close menu immediately
                        if (widget.singleSelect) {
                          // Parent will set selectedItems = [item]; we just close.
                          Navigator.pop(context);
                        } else {
                          // Multi-select visual refresh
                          setState(() {});
                          menuSetState(() {});
                        }
                      },
                      child: SizedBox(
                        height: double.infinity,
                        child: Directionality(
                          textDirection:
                              isEnglish ? TextDirection.ltr : TextDirection.rtl,
                          child: Row(
                            children: [
                              // Hide checkbox in single-select mode
                              if (!widget.singleSelect)
                                CustomCheckBox(isSelected: isSelected),
                              if (!widget.singleSelect) SizedBox(width: 8.sp),
                              Expanded(
                                child: Text(
                                  widget.itemLabel?.call(item) ?? item,
                                  style: StyleText.fontSize12Weight400.copyWith(
                                    color: AppColors.secondaryBlack,
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            onChanged: (_) {}, // unused; we handle in InkWell
            onMenuStateChange: (isOpen) {
              if (!isOpen) setState(() {});
            },
            customButton: Container(
              decoration: BoxDecoration(
                color: widget.fillColor ?? AppColors.card,
                borderRadius: BorderRadius.circular(widget.buttonRadius ?? 4.r),
              ),
              width: widget.width,
              height: widget.height ?? 36.h,
              child: widget.iconOnly
                  ? _buildIconOnlyButton()
                  : Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 10.sp,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.svgIconPath != null) _buildIconSection(),
                          // text takes all available space from the START
                          Expanded(child: _buildDropdownText()),
                          if (widget.showDropdownIcon)
                            Padding(
                              padding: EdgeInsetsDirectional.only(start: 8.w),
                              child: CustomSvgImage.natural(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg",
                                height: 22.sp,
                                width: 22.sp,
                                colorFilter: ColorFilter.mode(
                                  AppColors.secondaryBlack,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          if (widget.customSpacing != null)
                            widget.customSpacing!,
                        ],
                      ),
                    ),
            ),

            menuItemStyleData: MenuItemStyleData(
              // 18/10/2026: room between the checkbox rows (was 25 — the
              // boxes touched).
              height: widget.menuItemHeight ?? 36.sp,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              padding: EdgeInsets.symmetric(horizontal: 4.sp),
            ),
            value: widget.value,
            dropdownStyleData: DropdownStyleData(
              width: widget.menuWidth,
              maxHeight: 300,
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: widget.fillColor ?? AppColors.card,
              ),
            ),
            hint: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.hintText ?? S.of(context).chooseHere,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NEW: Build icon-only button (centered icon, no text)
  Widget _buildIconOnlyButton() {
    return Center(
      child: CustomSvgImage.natural(
        assetPath: widget.svgIconPath!,
        height: 20.sp,
        width: 20.sp,
        colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
      ),
    );
  }

  Row _buildDropdownText() {
    // 18/10/2026 (Moataz): the closed field shows WHAT IS SELECTED — it used
    // to show only the static label, so a choice was visible only with the
    // menu open. One item → its name; more → "first +N"; none → the label.
    if (_selected.isNotEmpty) {
      final String first =
          widget.itemLabel?.call(_selected.first) ?? _selected.first;
      final String shown =
          _selected.length == 1 ? first : '$first +${_selected.length - 1}';
      return Row(
        children: [
          Flexible(
            child: Text(
              shown,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    final displayText =
        widget.textButton ?? widget.hintText ?? S.of(context).chooseHere2;
    final isHintMode = widget.textButton == null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          textAlign: TextAlign.start,
          displayText,
          style: (StyleText.fontSize12Weight400).copyWith(
            color: isHintMode
                ? AppColors.text.withValues(alpha: .5)
                : AppColors.text.withValues(alpha: .5),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildIconDropdown() {
    return CustomSvgImage.natural(
      assetPath: widget.svgIconPath!,
      colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
    );
  }

  Row _buildIconSection() {
    return Row(
      children: [
        SizedBox(width: 11.sp),
        _buildIconDropdown(),
      ],
    );
  }
}
