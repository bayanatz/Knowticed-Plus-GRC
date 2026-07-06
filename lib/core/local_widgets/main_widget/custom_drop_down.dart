import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/core/helper/tracking_module/core/constants/enums.dart'
as FormatHelper;

class CustomDropdownFormFieldAmr extends StatefulWidget {
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
  final double? maxHeight;

  const CustomDropdownFormFieldAmr({
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
    this.maxHeight,
  }) : super(key: key);

  @override
  State<CustomDropdownFormFieldAmr> createState() =>
      _CustomDropdownFormFieldAmrState();
}

class _CustomDropdownFormFieldAmrState extends State<CustomDropdownFormFieldAmr> {
  String? internalSelectedValue;
  final GlobalKey _dropdownKey = GlobalKey();
  double? _popupWidth;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Validate that selectedValue exists in items before using it
    internalSelectedValue = _getValidatedSelectedValue(widget.selectedValue);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final context = _dropdownKey.currentContext;
        if (context != null) {
          try {
            final box = context.findRenderObject() as RenderBox?;
            if (box != null && box.hasSize) {
              setState(() {
                _popupWidth = box.size.width;
              });
            }
          } catch (e) {
            print('⚠️ Error getting dropdown width: $e');
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(CustomDropdownFormFieldAmr oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ FIX: Also validate when widget updates
    if (oldWidget.selectedValue != widget.selectedValue) {
      setState(() {
        internalSelectedValue = _getValidatedSelectedValue(widget.selectedValue);
      });
    }
  }

  // ✅ NEW METHOD: Validate that the selected value exists in items
  String? _getValidatedSelectedValue(String? value) {
    if (value == null) return null;

    // Check if the value exists in the items list
    final exists = widget.items.any((item) => item["key"] == value);

    if (exists) {
      return value;
    } else {
      // If value doesn't exist in items, return null to show hint
      print('⚠️ Selected value "$value" not found in dropdown items, using null');
      return null;
    }
  }

  // ✅ UPDATED METHOD: Use stateful widget for hover detection
  List<DropdownMenuItem<String>> _buildDropdownItems() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return widget.items.map((unit) {
      return DropdownMenuItem<String>(
        value: unit["key"],
        child: _DropdownItemWidget(
          text: FormatHelper.capitalize(unit["value"] ?? ''),
          isArabic: isArabic,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final double fieldHeight = (widget.height ?? 36);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Match text field label spacing
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.font14BlackCairoRegular.copyWith(
                color: AppColors.text),
          ),
          SizedBox(height: 6.h),
        ],
        Container(
          key: _dropdownKey,
          width: widget.width,
          height: widget.height?.h,
          decoration: BoxDecoration(
            color: lightMode
                ? AppColors.white
                : AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FormField<String>(
            initialValue: internalSelectedValue,
            builder: (FormFieldState<String> field) {
              return DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: widget.hint,
                  value: internalSelectedValue, // ✅ Now guaranteed to be valid or null
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
                    padding: EdgeInsets.symmetric(horizontal: 8.sp),
                    decoration: BoxDecoration(
                      color: widget.dropdownColor ?? (AppColors.background),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.transparent),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width: widget.dropdownWidth ?? _popupWidth ?? 100.sp,
                    maxHeight: widget.maxHeight ?? 230.sp,
                    offset: const Offset(0, 0),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(4.r),
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
                    padding: EdgeInsets.symmetric(horizontal: 12.sp),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return AppColors.primary;
                        }
                        return Colors.transparent;
                      },
                    ),
                    customHeights: null,
                  ),
                  iconStyleData: IconStyleData(
                    icon: Builder(
                      builder: (context) {
                        final isArabic =
                            Localizations.localeOf(context).languageCode ==
                                'ar';
                        return Padding(
                          padding: EdgeInsets.only(
                            right: isArabic ? 0 : 4.sp,
                            left: isArabic ? 4.sp : 0,
                          ),
                          child: Center(
                            child: SvgPicture.asset('assets/icons_assets/main_icons_assets/arrowdown.svg',
                                width: 16.sp,
                                height: 16.sp,
                                fit: BoxFit.scaleDown,
                                color: Colors.grey[400]),
                          ),
                        );
                      },
                    ),
                  ),
                  style: AppTextStyles.font12BlackCairoRegular.copyWith(
                      color: AppColors.text),
                  items: _buildDropdownItems(),
                ),
              );
            },
          ),
        ),

        // Add fixed-height spacing to match text field's error/counter area
        SizedBox(height: 18.h),
      ],
    );
  }
}

// ✅ FIXED WIDGET: Dropdown item with full container hover state
class _DropdownItemWidget extends StatefulWidget {
  final String text;
  final bool isArabic;

  const _DropdownItemWidget({
    required this.text,
    required this.isArabic,
  });

  @override
  State<_DropdownItemWidget> createState() => _DropdownItemWidgetState();
}

class _DropdownItemWidgetState extends State<_DropdownItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: double.infinity,
        alignment: widget.isArabic ? Alignment.centerRight : Alignment.centerLeft,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth - 8.sp,
              child: Text(
                widget.text,
                style: AppTextStyles.font12BlackCairoRegular.copyWith(
                  color: _isHovered ? AppColors.textButton : AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ),
    );
  }
}