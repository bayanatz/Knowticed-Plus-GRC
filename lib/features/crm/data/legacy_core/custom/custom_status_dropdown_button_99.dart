// ****************** FILE INFO ******************
// File Name: custom_status_dropdown_button_99.dart
// Purpose: Generic, customizable status pill dropdown button using AppAssets.arrowDown & arrowUp with flexible sizing, colors, and popup menu
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_haptic.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Item descriptor for [CustomStatusDropdownButton].
class StatusDropdownItem<T> {
  final T value;
  final String label;
  final Color? color;
  final Color? textColor;
  final String? svgIcon;
  final IconData? icon;
  final Widget? customLeading;
  final VoidCallback? onTap;

  const StatusDropdownItem({
    required this.value,
    required this.label,
    this.color,
    this.textColor,
    this.svgIcon,
    this.icon,
    this.customLeading,
    this.onTap,
  });
}

/// Generic, highly-customizable status pill dropdown button widget.
///
/// Uses [AppAssets.arrowDown] and [AppAssets.arrowUp] for dynamic arrow state,
/// supports custom colors, SVG leading icons, custom text styling,
/// fixed or responsive sizing (via [ButtonSizing]), and clean popup menu.
class CustomStatusDropdownButton<T> extends StatefulWidget {
  final T? value;
  final List<StatusDropdownItem<T>> items;
  final ValueChanged<T>? onChanged;
  final String? title;
  final Color? color;
  final Color? textColor;
  final TextStyle? textStyle;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? fixedWidth;
  final double? fixedHeight;
  final EdgeInsetsGeometry? padding;
  final bool useButtonSizing;
  final String? leadingSvg;
  final IconData? leadingIcon;
  final Widget? leadingWidget;
  final Color? leadingIconColor;
  final double? leadingIconSize;
  final String? trailingSvg;
  final String? trailingSvgOpen;
  final IconData? trailingIcon;
  final Widget? trailingWidget;
  final Color? trailingIconColor;
  final double? trailingIconSize;
  final bool showTrailingIcon;
  final double iconSpacing;
  final bool isEnabled;
  final String? tooltip;
  final bool showItemColorDots;
  final ShapeBorder? menuShape;
  final Color? menuColor;
  final Offset? menuOffset;
  final Widget Function(BuildContext context, StatusDropdownItem<T> item)?
      menuItemBuilder;

  const CustomStatusDropdownButton({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.title,
    this.color,
    this.textColor,
    this.textStyle,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.fixedWidth,
    this.fixedHeight,
    this.padding,
    this.useButtonSizing = false,
    this.leadingSvg,
    this.leadingIcon,
    this.leadingWidget,
    this.leadingIconColor,
    this.leadingIconSize,
    this.trailingSvg,
    this.trailingSvgOpen,
    this.trailingIcon,
    this.trailingWidget,
    this.trailingIconColor,
    this.trailingIconSize,
    this.showTrailingIcon = true,
    this.iconSpacing = 8,
    this.isEnabled = true,
    this.tooltip = '',
    this.showItemColorDots = false,
    this.menuShape,
    this.menuColor,
    this.menuOffset,
    this.menuItemBuilder,
  });

  @override
  State<CustomStatusDropdownButton<T>> createState() =>
      _CustomStatusDropdownButtonState<T>();
}

class _CustomStatusDropdownButtonState<T>
    extends State<CustomStatusDropdownButton<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final StatusDropdownItem<T>? activeItem = _resolveActiveItem();

    final Color effectiveBgColor = widget.color ??
        activeItem?.color ??
        (widget.isEnabled ? AppColors.primary : AppColors.disabledGrey);

    final Color effectiveTextColor =
        widget.textColor ?? activeItem?.textColor ?? AppColors.white;

    final TextStyle effectiveTextStyle = widget.textStyle ??
        StyleText.fontSize14Weight500.copyWith(
          color: effectiveTextColor,
          fontWeight: FontWeight.bold,
        );

    final String displayTitle = widget.title ??
        activeItem?.label ??
        (widget.value != null ? '${widget.value}' : '');

    final double effectiveHeight = widget.fixedHeight ??
        (widget.useButtonSizing ? ButtonSizing.height : 38.sp);

    final double effectiveRadius = widget.borderRadius ??
        (widget.useButtonSizing ? ButtonSizing.radius : 8.r);

    final double? effectiveWidth = widget.fixedWidth ??
        (widget.useButtonSizing
            ? ButtonSizing.width(
                context,
                title: displayTitle,
                textStyle: effectiveTextStyle,
                fixedWidth: widget.fixedWidth,
              )
            : null);

    final Widget buttonContent = Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: widget.padding ??
          EdgeInsets.symmetric(
            horizontal: 14.sp,
            vertical: 8.sp,
          ),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: widget.borderColor != null
            ? Border.all(
                color: widget.borderColor!,
                width: widget.borderWidth ?? 1.sp,
              )
            : null,
      ),
      child: Row(
        mainAxisSize:
            effectiveWidth != null ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Leading Icon
          _buildLeading(effectiveTextColor),

          // Title Label
          Flexible(
            child: Text(
              displayTitle,
              style: effectiveTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          // Trailing Arrow Icon (using AppAssets.arrowDown / arrowUp)
          if (widget.showTrailingIcon) ...<Widget>[
            SizedBox(width: widget.iconSpacing.sp),
            _buildTrailing(effectiveTextColor),
          ],
        ],
      ),
    );

    if (!widget.isEnabled || widget.items.isEmpty) {
      return buttonContent;
    }

    return PopupMenuButton<T>(
      enabled: widget.isEnabled,
      tooltip: widget.tooltip ?? '',
      onOpened: () {
        setState(() => _isOpen = true);
        hapticController.triggerHapticFeedback();
      },
      onCanceled: () {
        setState(() => _isOpen = false);
      },
      onSelected: (T selectedValue) {
        setState(() => _isOpen = false);
        hapticController.triggerHapticFeedback();
        widget.onChanged?.call(selectedValue);
        final StatusDropdownItem<T>? item =
            widget.items.cast<StatusDropdownItem<T>?>().firstWhere(
                  (StatusDropdownItem<T>? it) => it?.value == selectedValue,
                  orElse: () => null,
                );
        item?.onTap?.call();
      },
      offset: widget.menuOffset ?? Offset(0, 42.sp),
      shape: widget.menuShape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
      color: widget.menuColor ?? AppColors.white,
      itemBuilder: (BuildContext context) {
        return widget.items.map((StatusDropdownItem<T> item) {
          final bool isSelectedItem = item.value == widget.value;
          return PopupMenuItem<T>(
            value: item.value,
            child: widget.menuItemBuilder != null
                ? widget.menuItemBuilder!(context, item)
                : _buildDefaultMenuItem(item, isSelectedItem),
          );
        }).toList();
      },
      child: buttonContent,
    );
  }

  StatusDropdownItem<T>? _resolveActiveItem() {
    if (widget.value == null) return null;
    return widget.items.cast<StatusDropdownItem<T>?>().firstWhere(
          (StatusDropdownItem<T>? item) => item?.value == widget.value,
          orElse: () => null,
        );
  }

  Widget _buildLeading(Color fallbackColor) {
    if (widget.leadingWidget != null) {
      return Padding(
        padding: EdgeInsets.only(right: widget.iconSpacing.sp),
        child: widget.leadingWidget,
      );
    }
    if (widget.leadingSvg != null && widget.leadingSvg!.isNotEmpty) {
      final double size = widget.leadingIconSize ?? 16.sp;
      return Padding(
        padding: EdgeInsets.only(right: widget.iconSpacing.sp),
        child: CustomSvgImage(
          assetPath: widget.leadingSvg!,
          width: size,
          height: size,
          color: widget.leadingIconColor ?? fallbackColor,
        ),
      );
    }
    if (widget.leadingIcon != null) {
      final double size = widget.leadingIconSize ?? 16.sp;
      return Padding(
        padding: EdgeInsets.only(right: widget.iconSpacing.sp),
        child: Icon(
          widget.leadingIcon,
          size: size,
          color: widget.leadingIconColor ?? fallbackColor,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTrailing(Color fallbackColor) {
    if (widget.trailingWidget != null) {
      return widget.trailingWidget!;
    }
    if (widget.trailingIcon != null) {
      final double size = widget.trailingIconSize ?? 14.sp;
      return Icon(
        widget.trailingIcon,
        size: size,
        color: widget.trailingIconColor ?? fallbackColor,
      );
    }
    // Default: AppAssets.arrowDown (or AppAssets.arrowUp when opened)
    final String asset = _isOpen
        ? (widget.trailingSvgOpen ?? AppAssets.arrowUp)
        : (widget.trailingSvg ?? AppAssets.arrowDown);
    final double size = widget.trailingIconSize ?? 12.sp;
    return CustomSvgImage(
      assetPath: asset,
      width: size,
      height: size,
      color: widget.trailingIconColor ?? fallbackColor,
      fit: BoxFit.contain,
    );
  }

  Widget _buildDefaultMenuItem(
      StatusDropdownItem<T> item, bool isSelectedItem) {
    return Row(
      children: <Widget>[
        if (widget.showItemColorDots && item.color != null) ...<Widget>[
          Container(
            width: 10.sp,
            height: 10.sp,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.sp),
        ] else if (item.svgIcon != null &&
            item.svgIcon!.isNotEmpty) ...<Widget>[
          CustomSvgImage(
            assetPath: item.svgIcon!,
            width: 16.sp,
            height: 16.sp,
            color: item.textColor ?? AppColors.black,
          ),
          SizedBox(width: 10.sp),
        ] else if (item.icon != null) ...<Widget>[
          Icon(
            item.icon,
            size: 16.sp,
            color: item.textColor ?? AppColors.black,
          ),
          SizedBox(width: 10.sp),
        ],
        Expanded(
          child: Text(
            item.label,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Helper function mirroring the pre-built button style (`customButtonWithSvg`).
Widget customStatusDropdownButton<T>({
  required T value,
  required List<StatusDropdownItem<T>> items,
  required ValueChanged<T> onChanged,
  String? title,
  Color? color,
  Color? textColor,
  TextStyle? textStyle,
  Color? borderColor,
  double? borderRadius,
  double? fixedWidth,
  double? fixedHeight,
  String? leadingSvg,
  IconData? leadingIcon,
  String? trailingSvg,
  String? trailingSvgOpen,
  IconData? trailingIcon,
  Color? iconColor,
  bool showTrailingIcon = true,
  bool useButtonSizing = false,
  bool showItemColorDots = false,
}) {
  return CustomStatusDropdownButton<T>(
    value: value,
    items: items,
    onChanged: onChanged,
    title: title,
    color: color,
    textColor: textColor,
    textStyle: textStyle,
    borderColor: borderColor,
    borderRadius: borderRadius,
    fixedWidth: fixedWidth,
    fixedHeight: fixedHeight,
    leadingSvg: leadingSvg,
    leadingIcon: leadingIcon,
    trailingSvg: trailingSvg,
    trailingSvgOpen: trailingSvgOpen,
    trailingIcon: trailingIcon,
    trailingIconColor: iconColor,
    leadingIconColor: iconColor,
    showTrailingIcon: showTrailingIcon,
    useButtonSizing: useButtonSizing,
    showItemColorDots: showItemColorDots,
  );
}
