/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: menu_button.dart
/// Description: `MenuDropdown` widget, state and UI of the `MenuDropdown` widget, `_MenuItemLabel` widget and 1 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

// created by Mohamed Elrashidy
// created at 29-1-2024
// last edit at 31-1-2024
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/menu.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';

class MenuDropdown extends StatefulWidget {
  const MenuDropdown(
      {super.key,
      required this.items,
      required this.currentEnumValue,
      required this.onChanged,
      this.customIcon,
      this.iconWidth = 35,
      this.yOffset = -110,
      this.xOffset = 0,
      this.alignment = AlignmentDirectional.centerStart});
  final List<MenuEnum> items;
  final MenuEnum? currentEnumValue;
  final void Function(dynamic) onChanged;
  final double iconWidth;
  final double yOffset;
  final double xOffset;
  final Widget? customIcon;
  final AlignmentDirectional alignment;
  @override
  State<MenuDropdown> createState() => _AppDropDownButtonState();
}

class _AppDropDownButtonState extends State<MenuDropdown> {
  @override
  void initState() {
    super.initState();
  }

  /// Every menu entry is gated by its Form Permissions switch, through
  /// FormBuilderAccess (section master toggle AND switch).
  /// from five inline `isHasPermission` calls.
  List<MenuEnum> _getFilteredItems() {
    return widget.items
        .where((item) => switch (item) {
              MenuEnum.duplicate => FormBuilderAccess.canDuplicateForm,
              MenuEnum.convertToPDF => FormBuilderAccess.canConvertToPdf,
              MenuEnum.edit => FormBuilderAccess.canEditForm,
              MenuEnum.delete => FormBuilderAccess.canDeleteForm,
              MenuEnum.restore => FormBuilderAccess.canRestoreForm,
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // The menu opens to the start side: negative offset in English.
    final double startYOffset = Get.locale?.languageCode == "en"
        ? -1 * widget.yOffset.abs()
        : widget.yOffset.abs();

    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButton2(
      menuItemStyleData: MenuItemStyleData(
        height: (filteredItems.length == 1) ? 24.h : 32.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary;
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.transparent;
            }
            return AppColors.transparent;
          },
        ),
      ),
      // button decoration
      customButton: widget.customIcon ??
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomSvgImage.natural(
                assetPath: AppAssets.menu,
                width: 20.sp,
                colorFilter:
                    ColorFilter.mode(AppColors.fullBlack, BlendMode.srcIn),
              ),
            ],
          ),

      // dropdown menu decoration
      dropdownStyleData: DropdownStyleData(
        maxHeight: 190.h,
        // The menu's default list padding (8 top and
        // bottom) showed the dark menu background above and below the
        // hovered row, so a yellow (AppColors.primary) row sat inside a black
        // frame. Zero padding lets the hover fill reach the menu's edges.
        padding: EdgeInsets.zero,
        offset: Offset(startYOffset.sp, widget.xOffset),
        width: 130.sp,
        elevation: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.background,
        ),
      ),
      value: _getSelectedValue(),
      style: StyleText.fontSize14Weight500,
      underline: Container(color: AppColors.transparent),
      items: filteredItems.map<DropdownMenuItem<dynamic>>((dynamic value) {
        return DropdownMenuItem<dynamic>(
          alignment: widget.alignment,
          value: value,
          // CHANGED: was a bare `Text` with a fixed colour. `menuItemStyleData`
          // paints AppColors.primary behind the row under the pointer, but the
          // label knew nothing about that, so the highlighted row kept its
          // resting dark/red text on the yellow. See [_MenuItemLabel].
          child: _MenuItemLabel(
            text: getItemListText(value),
            restingColor: (value == MenuEnum.delete)
                ? AppColors.red
                : AppColors.secondaryBlack,
          ),
        );
      }).toList(),

      onChanged: (value) {
        widget.onChanged(value);
        setState(() {});
      },
    );
  }

  String getSelectedText() {
    final MenuEnum? current = widget.currentEnumValue;
    return current?.label ?? "";
  }

  /// This used to be `item as Enum; return item.name;`.
  /// Casting to `Enum` first made `.name` resolve to `dart:core`'s `Enum.name`
  /// rather than the extension, so the menu rendered raw identifiers
  /// ("convertToPDF") instead of a label — and never translated either.
  /// [MenuEnumExtension.label] is the localized text.
  String getItemListText<T>(MenuEnum item) {
    return item.label;
  }

  dynamic _getSelectedValue() {
    return widget.currentEnumValue;
  }
}

/// One row's label, repainted when the pointer is over that row.
///
/// ADDED: `DropdownMenuItem` builds its child once and hands it no pointer
/// state, so a `Text` inside it cannot react to the highlight that
/// `MenuItemStyleData.overlayColor` paints on hover. The row went yellow
/// (AppColors.primary) while its label stayed `secondaryBlack` — or red, for
/// Delete — which is the mismatch in the screenshot.
///
/// Hovered, the label is [AppColors.textButton]: the colour the app already
/// pairs with a primary-coloured surface everywhere else (see `customButton` /
/// `customButtonWithSvg`), so a highlighted menu row now reads like every other
/// primary-filled control.
class _MenuItemLabel extends StatefulWidget {
  const _MenuItemLabel({required this.text, required this.restingColor});

  final String text;

  /// Colour when the pointer is elsewhere — red for Delete, secondaryBlack for
  /// everything else, exactly as before.
  final Color restingColor;

  @override
  State<_MenuItemLabel> createState() => _MenuItemLabelState();
}

class _MenuItemLabelState extends State<_MenuItemLabel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        // Full row width on purpose. `DropdownMenuItem` sizes its child to the
        // text, so without this the pointer would only count as "on this row"
        // while it was literally over the glyphs — the label would flick back
        // to its resting colour in the empty space the highlight still covers.
        width: double.infinity,
        child: Text(
          widget.text,
          style: StyleText.fontSize14Weight500.copyWith(
            color: _hovered ? AppColors.textButton : widget.restingColor,
          ),
        ),
      ),
    );
  }
}
