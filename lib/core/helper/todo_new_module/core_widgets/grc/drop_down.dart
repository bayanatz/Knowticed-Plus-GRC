import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lottie/lottie.dart';

import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/features/home/presentation/ui/pages/dashboard_view_data/chart_settings_dialog.dart';
import 'package:demo_app/core/custom/32-custom_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/grc/custom_button_with_icon.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/grc/grc_text_field.dart';

class CustomDropdownFormField extends StatefulWidget {
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
  final bool isEditable; // New parameter to enable/disable editing
  final String?
  firestoreCategory; // Category for Firestore collection (e.g., "units", "categories")

  /// ✅ NEW: Color support parameters
  final Map<String, Color>? itemColors; // Map of item keys/values to colors
  final bool showColorDots; // Whether to show colored dots next to text

  const CustomDropdownFormField({
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
    this.isEditable = false,
    this.firestoreCategory,
    this.itemColors, // ✅ NEW
    this.showColorDots = false, // ✅ NEW
  }) : super(key: key);

  @override
  State<CustomDropdownFormField> createState() =>
      _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  String? internalSelectedValue;
  final GlobalKey _dropdownKey = GlobalKey();
  double? _popupWidth;
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, String>> _dynamicItems = [];

  @override
  void initState() {
    super.initState();
    internalSelectedValue = widget.selectedValue;
    _dynamicItems = List.from(widget.items);

    if (widget.selectedValue != null) {
      _textController.text =
          widget.items.firstWhere(
            (item) => item['key'] == widget.selectedValue,
            orElse: () => {'value': widget.selectedValue ?? ''},
          )['value'] ??
          '';
    }

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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// ✅ NEW: Helper method to get color for an item
  Color? _getItemColor(Map<String, String> item) {
    if (widget.itemColors == null) return null;

    // Try to get color by key first, then by value
    String key = item['key'] ?? '';
    String value = item['value'] ?? '';

    return widget.itemColors![key] ?? widget.itemColors![value];
  }

  /// ✅ NEW: Build dropdown item with optional color support
  Widget _buildDropdownItem(Map<String, String> item, bool lightMode) {
    Color? itemColor = _getItemColor(item);

    if (widget.showColorDots && itemColor != null) {
      return Row(
        children: [
          Container(
            width: 8.sp,
            height: 8.sp,
            decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              item["value"] ?? '',
              style: AppTextStyles.font12BlackCairoRegular.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        item["value"] ?? '',
        style: AppTextStyles.font12BlackCairoRegular.copyWith(
          color:
              itemColor ??
              (lightMode ? AppColors.secondaryText : AppColors.grey),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }

  Future<void> _saveNewItemToFirestore(String newItem) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if item already exists locally
      final existingItem = _dynamicItems.firstWhere(
        (item) => item['value']?.toLowerCase() == newItem.toLowerCase(),
        orElse: () => {},
      );

      if (existingItem.isNotEmpty) {
        // Item already exists
        final String existingKey = existingItem['key'] ?? '';

        setState(() {
          internalSelectedValue = existingKey;
          _textController.text = newItem;
        });

        widget.onChanged(existingKey);

        _showSuccessDialog(
          context,
          "assets/lottie/warning.json",
          S.of(context).alreadyExistsAndSelected,
        );

        setState(() {
          _isLoading = false;
        });

        return;
      }

      // Generate a unique key for the new item
      final String newKey = DateTime.now().millisecondsSinceEpoch.toString();

      // Add to local items list
      setState(() {
        _dynamicItems.add({'key': newKey, 'value': newItem});
        internalSelectedValue = newKey;
        _textController.text = newItem;
      });

      // Notify parent widget
      widget.onChanged(newKey);

      _showSuccessDialog(
        context,
        "assets/lottie/approved.json",
        S.of(context).itemAddSuccessful,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddNewItemDialog() {
    final TextEditingController dialogController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        var isMobile = MediaQuery.of(context).size.width < 600;
        var isTablet =
            MediaQuery.of(context).size.width >= 600 &&
            MediaQuery.of(context).size.width < 900;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final lightMode = Theme.of(context).brightness == Brightness.light;
            return SizedBox(
              width: isMobile ? 250.w : 411.w,
              height: isMobile ? 172.h : 200.h,
              child: AlertDialog(
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                content: SizedBox(
                  width: isMobile ? 250.w : 411.w,
                  height: isMobile ? 172.h : 155.h,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Center(
                              child: CustomSvg(
                                assetPath: "assets/images/plus.svg",
                                width: 15.w,
                                height: 15.h,
                                color: AppColors.textButton,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            S.of(context).addNewItem,
                            style: AppTextStyles.font16BlackSemiBoldCairo,
                          ),
                        ],
                      ),
                      SizedBox(height: 0.h),
                      GRCCustomValidatedTextField(
                        height: 36,
                        label: "",
                        hint: S.of(context).textHere,
                        controller: dialogController,
                        fillColor: lightMode
                            ? AppColors.chatBackground
                            : AppColors.background,
                      ),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          S.of(context).savedToHistory,
                          style: AppTextStyles.font12BlackCairoRegular.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customButton(
                            title: S.of(context).cancel,
                            function: () => Navigator.pop(context),
                            width: 100.w,
                            radius: 4.r,
                            height: 30.h,
                            color: Colors.grey[300],
                            textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          customButton(
                            title: S.of(context).submit,
                            function: () {
                              final String newItem = dialogController.text
                                  .trim();
                              if (newItem.isNotEmpty) {
                                Navigator.of(context).pop();
                                _saveNewItemToFirestore(newItem);
                              }
                            },
                            width: 100.w,
                            radius: 4.r,
                            height: 30.h,
                            color: AppColors.primary,
                            textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                              color: AppColors.textButton,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // COMPLETE FIXED _buildOriginalDropdown METHOD
  // Replace the entire _buildOriginalDropdown method with this:

  Widget _buildOriginalDropdown(BuildContext context, bool lightMode) {
    var isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.font14BlackCairoRegular.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
          SizedBox(height: (widget.spaceHeight ?? 6.h)),
        ],

        // Dropdown Container
        Container(
          key: _dropdownKey,
          width: widget.width,
          height: widget.height?.h,
          decoration: BoxDecoration(
            color: lightMode
                ? AppColors.chatBackground
                : AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FormField<String>(
            initialValue: internalSelectedValue,
            validator: widget.validator,
            builder: (FormFieldState<String> field) {
              return DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: widget.hint,
                  value:
                      widget.items.any((e) => e['key'] == internalSelectedValue)
                      ? internalSelectedValue
                      : null,
                  onChanged: (value) {
                    setState(() {
                      internalSelectedValue = value;
                      field.didChange(value);
                    });
                    widget.onChanged(value);
                  },
                  buttonStyleData: ButtonStyleData(
                    height: widget.height?.h,
                    width: widget.width?.w,
                    padding: EdgeInsets.only(
                      left: isArabic ? 0.w : 8.w,
                      right: isArabic ? 8.w : 8.w,
                    ),
                    decoration: BoxDecoration(
                      color:
                          widget.dropdownColor ??
                          (lightMode
                              ? AppColors.chatBackground
                              : AppColors.background),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width:
                        widget.dropdownWidth ??
                        _popupWidth ??
                        widget.width ??
                        100.w,
                    maxHeight: 225.h,
                    offset: const Offset(0, 0),
                    decoration: BoxDecoration(
                      color: lightMode
                          ? AppColors.background
                          : AppColors.white,
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
                    height: widget.height!.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.hovered)) {
                        return AppColors.primary;
                      }
                      return Colors.white;
                    }),
                  ),
                  iconStyleData: IconStyleData(
                    icon: SvgPicture.asset(
                      'assets/icons/arrow_down.svg',
                      width: widget.widthIcon?.w,
                      height: widget.heightIcon?.h,
                      fit: BoxFit.scaleDown,
                      color: lightMode
                          ? AppColors.secondaryText
                          : AppColors.whiteShadow,
                    ),
                  ),
                  style: AppTextStyles.font12BlackCairoRegular.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                  items: widget.items.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit["key"],
                      child: _buildDropdownItem(unit, lightMode),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),

        // ✅ CRITICAL FIX: Add 18.h reserved space to match CustomValidatedTextFieldMaster
        // SizedBox(height: 18.h),
      ],
    );
  }

  // ===================================================================
  // COMPLETE FIXED build METHOD (for editable version)
  // Replace the entire build method with this:
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    if (!widget.isEditable) {
      return _buildOriginalDropdown(context, lightMode);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTextStyles.font14BlackCairoRegular.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: (widget.spaceHeight ?? 6.h)),
        ],

        // Dropdown Container with Add Button
        Container(
          key: _dropdownKey,
          width: widget.width,
          decoration: BoxDecoration(
            color: lightMode
                ? AppColors.chatBackground
                : AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FormField<String>(
            initialValue: internalSelectedValue,
            validator: widget.validator,
            builder: (FormFieldState<String> field) {
              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: widget.hint,
                        value:
                            _dynamicItems.any(
                              (e) => e['key'] == internalSelectedValue,
                            )
                            ? internalSelectedValue
                            : null,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              internalSelectedValue = value;
                              field.didChange(value);
                              _textController.text =
                                  _dynamicItems.firstWhere(
                                    (item) => item['key'] == value,
                                  )['value'] ??
                                  '';
                            });
                            widget.onChanged(value);
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          height: widget.height?.h ?? 36.h,
                          width: widget.width != null
                              ? widget.width! - 40.w
                              : null,
                          padding: EdgeInsets.only(
                            left: 0.w,
                            right: 0.w,
                            top: 0.h,
                            bottom: 0.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                widget.dropdownColor ??
                                (lightMode
                                    ? AppColors.chatBackground
                                    : AppColors.background),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.r),
                              bottomLeft: Radius.circular(8.r),
                            ),
                            border: Border.all(color: Colors.transparent),
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          width:
                              widget.dropdownWidth ??
                              _popupWidth ??
                              widget.width ??
                              100.w,
                          maxHeight: 230.h,
                          offset: const Offset(0, 0),
                          decoration: BoxDecoration(
                            color: lightMode
                                ? AppColors.background
                                : AppColors.white,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          scrollbarTheme: ScrollbarThemeData(
                            thumbVisibility: MaterialStateProperty.all(true),
                            trackVisibility: MaterialStateProperty.all(false),
                            thickness: MaterialStateProperty.all(4),
                            radius: Radius.circular(2.r),
                            thumbColor: MaterialStateProperty.all(
                              AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: widget.height!.h,
                          padding: EdgeInsets.symmetric(horizontal: 8.sp),
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>((
                                Set<MaterialState> states,
                              ) {
                                if (states.contains(MaterialState.hovered)) {
                                  return AppColors.primary.withOpacity(0.1);
                                }
                                return null;
                              }),
                        ),
                        iconStyleData: IconStyleData(
                          icon: SvgPicture.asset(
                            'assets/images/arrow_down.svg',
                            width: widget.widthIcon?.w,
                            height: widget.heightIcon?.h,
                            fit: BoxFit.scaleDown,
                            color: lightMode
                                ? AppColors.secondaryText
                                : AppColors.whiteShadow,
                          ),
                        ),
                        style: AppTextStyles.font12BlackCairoRegular.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                        items: _dynamicItems.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit["key"],
                            child: _buildDropdownItem(unit, lightMode),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // Add new item button
                  Container(
                    width: 32.w,
                    height: widget.height?.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                      ),
                    ),
                    child: _isLoading
                        ? Center(
                            child: SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.isEditable
                                  ? _showAddNewItemDialog
                                  : null,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4.r),
                                bottomRight: Radius.circular(4.r),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 18.sp,
                                color: AppColors.textButton,
                              ),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),

        // ✅ CRITICAL FIX: Add 18.h reserved space to match CustomValidatedTextFieldMaster
        SizedBox(height: 18.h),
      ],
    );
  }

  Future<void> _showSuccessDialog(
    BuildContext context,
    String? lottie, [
    String? message,
  ]) async {
    final rootContext = context;
    await showDialog(
      context: rootContext,
      barrierDismissible: true,
      builder: (dialogContext) {
        var isMobile = MediaQuery.of(dialogContext).size.width < 600;
        // Get screen dimensions
        final screenSize = MediaQuery.of(dialogContext).size;
        final isPhone = screenSize.width < 600;
        final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
        final isDesktop = screenSize.width >= 1024;
        final isLandscape = screenSize.width > screenSize.height;

        // Calculate responsive dimensions
        double dialogWidth;
        double lottieSize;
        double horizontalPadding;
        double verticalPadding;
        double textSize;
        double spacing;

        if (isPhone) {
          // Mobile - responsive to orientation
          if (isLandscape) {
            dialogWidth = screenSize.width * 0.7; // 70% of screen width
            lottieSize = 80;
            horizontalPadding = 16;
            verticalPadding = 12;
            textSize = 16;
            spacing = 12;
          } else {
            dialogWidth = screenSize.width * 0.85; // 85% of screen width
            lottieSize = 100;
            horizontalPadding = 20;
            verticalPadding = 20;
            textSize = 18;
            spacing = 16;
          }
        } else if (isTablet) {
          // Tablet - responsive to orientation
          if (isLandscape) {
            dialogWidth = screenSize.width * 0.5; // 50% of screen width
            lottieSize = 120;
            horizontalPadding = 24;
            verticalPadding = 20;
            textSize = 20;
            spacing = 20;
          } else {
            dialogWidth = screenSize.width * 0.7; // 70% of screen width
            lottieSize = 130;
            horizontalPadding = 28;
            verticalPadding = 24;
            textSize = 22;
            spacing = 24;
          }
        } else {
          // Desktop
          dialogWidth = 450; // Fixed width for desktop
          lottieSize = 140;
          horizontalPadding = 32;
          verticalPadding = 28;
          textSize = 24;
          spacing = 28;
        }

        // Ensure minimum and maximum constraints
        dialogWidth = dialogWidth.clamp(280.0, 600.0);

        return Dialog(
          backgroundColor:
              Theme.of(dialogContext).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isPhone ? 12.r : 16.r),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isPhone ? 16.w : 40.w,
            vertical: isPhone ? 24.h : 40.h,
          ),
          child: Container(
            width: isMobile ? 250.w : 411.w,
            height: isMobile ? 150.h : 155.h,
            child: Padding(
              padding: EdgeInsets.all(15.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie Animation
                  Lottie.asset(
                    lottie ?? 'assets/lottie/approved.json',
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.scaleDown,
                    repeat: true,
                    animate: true,
                  ),

                  SizedBox(height: 10.h),
                  // Message Text
                  Flexible(
                    child: Text(
                      message ?? S.of(dialogContext).changingStatus,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font20BlackCairoMedium.copyWith(
                        fontSize: textSize,
                        color:
                            Theme.of(dialogContext).brightness ==
                                Brightness.light
                            ? AppColors.blackButton
                            : AppColors.white,
                        height: 1.3, // Better line spacing for readability
                      ),
                    ),
                  ),

                  // Add some bottom padding for mobile landscape mode
                  if (isPhone && isLandscape) SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomDropdownFormFieldCalender extends StatefulWidget {
  final String? selectedValue;
  final double? widthIcon;
  final Color? dropdownColor;
  final double? heightIcon;
  final Function(String?) onChanged;
  final String Function(String?)? validator;
  final double? width;
  final double? height;
  final double? spaceHeight;
  final Widget? hint;
  final String? label;
  final String? iconPath;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDropdownFormFieldCalender({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    required this.widthIcon,
    required this.heightIcon,
    this.validator,
    this.width,
    this.height,
    this.spaceHeight,
    this.hint,
    this.dropdownColor,
    this.label,
    this.iconPath,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  _CustomDropdownFormFieldCalenderState createState() =>
      _CustomDropdownFormFieldCalenderState();
}

class _CustomDropdownFormFieldCalenderState
    extends State<CustomDropdownFormFieldCalender> {
  String? internalSelectedValue;
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    internalSelectedValue = widget.selectedValue;
  }

  Future<void> _openDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        final bool lightMode = Theme.of(context).brightness == Brightness.light;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: lightMode
                ? ColorScheme.light(primary: AppColors.primary)
                : ColorScheme.dark(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format the date as needed (you can customize this format)
      final formattedDate = "${picked.day}/${picked.month}/${picked.year}";

      setState(() {
        internalSelectedValue = formattedDate;
      });

      widget.onChanged(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final double fieldHeight = widget.height ?? 36.sp;

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
        GestureDetector(
          onTap: _openDatePicker,
          child: Container(
            key: _dropdownKey,
            width: widget.width,
            height: fieldHeight.h,
            padding: EdgeInsets.symmetric(horizontal: 8.sp),
            decoration: BoxDecoration(
              color:
                  widget.dropdownColor ??
                  (lightMode ? AppColors.background : AppColors.background),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    internalSelectedValue ??
                        (widget.hint is Text
                            ? (widget.hint as Text).data ?? 'Select Date'
                            : 'Select Date'),
                    style: AppTextStyles.font12BlackCairoRegular.copyWith(
                      color: internalSelectedValue != null
                          ? (lightMode
                                ? AppColors.blackButton
                                : AppColors.white)
                          : (lightMode
                                ? AppColors.secondaryText
                                : AppColors.whiteShadow),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/calender.svg',
                  width: widget.widthIcon,
                  height: widget.heightIcon,
                  fit: BoxFit.scaleDown,
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.whiteShadow,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDropdownFormFieldDateRange extends StatefulWidget {
  final DateTimeRange? selectedRange;
  final double? widthIcon;
  final Color? dropdownColor;
  final double? heightIcon;
  final Function(DateTimeRange?) onChanged;
  final String Function(DateTimeRange?)? validator;
  final double? width;
  final double? height;
  final double? spaceHeight;
  final Widget? hint;
  final String? label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showClearButton;

  const CustomDropdownFormFieldDateRange({
    Key? key,
    required this.selectedRange,
    required this.onChanged,
    required this.widthIcon,
    required this.heightIcon,
    this.validator,
    this.width,
    this.height,
    this.spaceHeight,
    this.hint,
    this.dropdownColor,
    this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  _CustomDropdownFormFieldDateRangeState createState() =>
      _CustomDropdownFormFieldDateRangeState();
}

class _CustomDropdownFormFieldDateRangeState
    extends State<CustomDropdownFormFieldDateRange> {
  DateTimeRange? internalSelectedRange;
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    internalSelectedRange = widget.selectedRange;
  }

  Future<void> _openDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: internalSelectedRange,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        final bool lightMode = Theme.of(context).brightness == Brightness.light;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: lightMode
                ? ColorScheme.light(
                    primary: AppColors.primary, // Header and buttons
                    onPrimary: Colors.white, // Text on primary color
                    secondary: AppColors.primary, // Range selection
                    onSecondary: Colors.white, // Text on secondary color
                  )
                : ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    secondary: AppColors.primary,
                    onSecondary: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        internalSelectedRange = picked;
      });
      widget.onChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getDisplayText() {
    if (internalSelectedRange == null) {
      if (widget.hint is Text) {
        return (widget.hint as Text).data ?? 'Select date range';
      }
      return 'Select date range';
    }

    return '${_formatDate(internalSelectedRange!.start)} - ${_formatDate(internalSelectedRange!.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final double fieldHeight = widget.height ?? 40.0;

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
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _openDateRangePicker,
                child: Container(
                  key: _dropdownKey,
                  width: widget.width,
                  height: fieldHeight,
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  decoration: BoxDecoration(
                    color:
                        widget.dropdownColor ??
                        (lightMode
                            ? AppColors.background
                            : AppColors.background),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getDisplayText(),
                          style: AppTextStyles.font12BlackCairoRegular.copyWith(
                            color: internalSelectedRange != null
                                ? (lightMode
                                      ? AppColors.blackButton
                                      : AppColors.white)
                                : (lightMode
                                      ? AppColors.secondaryText
                                      : AppColors.whiteShadow),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CustomSvg(
                        assetPath: "assets/images/calender.svg",
                        width: 14.w,
                        height: 14.h,
                        fit: BoxFit.scaleDown,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.showClearButton && internalSelectedRange != null) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  setState(() {
                    internalSelectedRange = null;
                  });
                  widget.onChanged(null);
                },
                child: Container(
                  width: 32.w,
                  height: fieldHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Icon(
                    Icons.clear,
                    color: lightMode ? Colors.grey[600] : Colors.grey[400],
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// Extension to capitalize string
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
