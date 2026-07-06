/// ******************* FILE INFO *******************
/// File Name: custom_drop_down.dart
/// Description: this is custom normal dropdown can reuse
/// Created by: Amr Mesbah
/// Last Update: 01/5/2026

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:demo_app/core/enums/enum.dart' as FormatHelper;
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class CustomDropdownFormFieldInv extends StatefulWidget {
  final String? selectedValue;
  final double? widthIcon;
  final Color? dropdownColor;
  final double? heightIcon;
  final List<Map<String, String>> items;
  final Function(String?) onChanged;
  final String Function(String?)? validator;
  final double? width;
  final double? height;
  final double? spaceHeight;
  final double? dropdownWidth;
  final Widget? hint;
  final String? label;
  final String? iconPath;
  final double? iconPaddingRight;
  final double? iconPaddingLeft;
  final double? borderRadius;

  const CustomDropdownFormFieldInv({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.widthIcon,
    required this.heightIcon,
    this.validator,
    this.width,
    this.height,
    this.spaceHeight,
    this.dropdownWidth,
    this.hint,
    this.dropdownColor,
    this.label,
    this.iconPath,
    this.iconPaddingRight,
    this.iconPaddingLeft,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<CustomDropdownFormFieldInv> createState() =>
      _CustomDropdownFormFieldInvState();
}

class _CustomDropdownFormFieldInvState
    extends State<CustomDropdownFormFieldInv> {
  String? internalSelectedValue;
  final GlobalKey _dropdownKey = GlobalKey();
  double? _popupWidth;

  @override
  void initState() {
    super.initState();

    print("🎨 CustomDropdown initState");
    print("🎨 widget.selectedValue: ${widget.selectedValue}");
    print("🎨 widget.items.length: ${widget.items.length}");
    print("🎨 widget.items: ${widget.items}");

    internalSelectedValue = widget.selectedValue;

    if (internalSelectedValue != null) {
      bool exists =
      widget.items.any((item) => item['key'] == internalSelectedValue);
      print("🎨 Does '$internalSelectedValue' exist in items? $exists");

      if (!exists) {
        print("⚠️ CustomDropdown: Invalid selectedValue, resetting to null");
        internalSelectedValue = null;
      }
    }

    print("🎨 Final internalSelectedValue: $internalSelectedValue");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _dropdownKey.currentContext;
      if (context != null && mounted) {
        final box = context.findRenderObject() as RenderBox;
        setState(() {
          _popupWidth = box.size.width;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final double fieldHeight = (widget.height ?? 36).h;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final radius = BorderRadius.circular(widget.borderRadius?.r ?? 8.r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.font14BlackCairoRegular.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
          SizedBox(height: (widget.spaceHeight ?? 8.sp)),
        ],
        Container(
          key: _dropdownKey,
          width: widget.width,
          height: fieldHeight,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: radius,
          ),
          child: FormField<String>(
            initialValue: internalSelectedValue,
            builder: (FormFieldState<String> field) {
              return DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: widget.hint,
                  value: internalSelectedValue,
                  onChanged: (value) {
                    setState(() {
                      internalSelectedValue = value;
                      field.didChange(value);
                    });
                    widget.onChanged(value);
                  },
                  buttonStyleData: ButtonStyleData(
                    height: fieldHeight,
                    width: widget.width,
                    padding: EdgeInsetsGeometry.fromSTEB(8.w, 0, 0, 0),
                    decoration: BoxDecoration(
                      color: widget.dropdownColor ??
                          (lightMode
                              ? AppColors.background
                              : AppColors.background),
                      borderRadius: radius,
                      border: Border.all(color: Colors.transparent),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width: widget.dropdownWidth ?? _popupWidth ?? 100.sp,
                    maxHeight: 230.sp,
                    offset: const Offset(0, 0),
                    decoration: BoxDecoration(
                      color: lightMode
                          ? AppColors.white
                          : AppColors.background,
                      border: Border.all(color: Colors.transparent),
                      borderRadius: radius,
                    ),
                    scrollbarTheme: ScrollbarThemeData(
                      thumbVisibility: MaterialStateProperty.all(false),
                      trackVisibility: MaterialStateProperty.all(false),
                      thickness: MaterialStateProperty.all(0),
                      radius: Radius.zero,
                    ),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    height: fieldHeight,
                    padding: EdgeInsets.symmetric(horizontal: 8.sp),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return AppColors.primary;
                        }
                        return Colors.white;
                      },
                    ),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Builder(
                      builder: (context) {
                        final isArabic =
                            Localizations.localeOf(context).languageCode ==
                                'ar';
                        return Padding(
                          padding: EdgeInsets.only(
                            right: widget.iconPaddingRight ??
                                (isArabic ? 8.sp : 4.sp),
                            left: widget.iconPaddingLeft ??
                                (isArabic ? 4.sp : 8.sp),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons_assets/main_icons_assets/arrowdown.svg',
                            width: 16.sp,
                            height: 16.sp,
                            fit: BoxFit.scaleDown,
                            color: AppColors.secondaryText,
                          ),
                        );
                      },
                    ),
                  ),
                  style: AppTextStyles.font12BlackCairoRegular.copyWith(
                    color: AppColors.text,
                  ),
                  items: widget.items.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit["key"],
                      child: Text(
                        FormatHelper.capitalize(unit["value"] ?? ''),
                        style: AppTextStyles.font14BlackCairoRegular.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
