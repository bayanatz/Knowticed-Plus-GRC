import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/timeline_widget.dart';
import 'package:demo_app/core/enums/enum.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';
import 'package:demo_app/features/onboarding/authentication/welcome_screen/views/mobile_view/nav_bar.dart';


class ColorPickerContainer extends StatefulWidget {
  final Color initialColor;
  final String initialColorString;
  final String fieldName;

  final Function(Color) onColorSelected;
  final ValueChanged<Color> onChanged;

  ColorPickerContainer({
    required this.initialColor,
    required this.onColorSelected,
    required this.initialColorString,
    required this.onChanged,
    required this.fieldName,
  });

  @override
  _ColorPickerContainerState createState() => _ColorPickerContainerState();
}

class _ColorPickerContainerState extends State<ColorPickerContainer> {
  Color? _selectedColor;
  final List<Color> _colorHistory = [];
  final TextEditingController _hexController = TextEditingController();

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _showColorPickerDialog(BuildContext context) {
    // Seed the controller with the current color value
    _hexController.text = _selectedColor != null
        ? '#${_selectedColor!.value.toRadixString(16).toUpperCase()}'
        : widget.initialColorString;

    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;

    TextStyle titleTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isTablet
          ? (orientation
          ? FontConstants.fontSize015.h
          : FontConstants.fontSize018.h)
          : FontConstants.fontSize015.h,
      color: Theme.of(context).colorScheme.secondaryContainer,
      height: isTablet ? (orientation ? 2 : 1.7) : 0.002.h,
      fontWeight: FontWeight.w400,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Color Picker Wheel ─────────────────────────────────
                    // SingleChildScrollView(
                    //   child: ColorPicker(
                    //     pickerColor: _selectedColor ??
                    //         Color(int.parse(widget.initialColorString)),
                    //     onColorChanged: (Color color) {
                    //       setState(() {
                    //         _selectedColor = color;
                    //         // Keep the hex field in sync when wheel changes
                    //         _hexController.text =
                    //         '#${color.value.toRadixString(16).toUpperCase()}';
                    //       });
                    //     },
                    //     showLabel: true,
                    //     pickerAreaHeightPercent: isTablet
                    //         ? (orientation ? 0.0007.h : 0.001.h)
                    //         : 0.001.h,
                    //     colorPickerWidth:
                    //     isTablet ? (orientation ? 0.4.w : 0.3.w) : 0.6.w,
                    //     labelTextStyle: titleTextStyle,
                    //     pickerAreaBorderRadius:
                    //     BorderRadius.all(Radius.circular(8)),
                    //     labelTypes: const [],
                    //     displayThumbColor: true,
                    //     portraitOnly: true,
                    //   ),
                    // ),

                    // ── Hex Input ──────────────────────────────────────────
                    Text(
                      S.of(context).enterhexacolor,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SizedBox(
                      width: isTablet
                          ? (orientation ? 0.4.w : 0.3.w)
                          : 0.6.w,
                      child: CustomTextField(
                        hint: 'Enter Hex Code'.tr,
                        controller: _hexController,
                        enabled: false,
                        fillColor: AppColors.card,
                        textDirection: TextDirection.ltr,
                        onChanged: (value) {
                          final clean = value.startsWith('#')
                              ? value.substring(1)
                              : value;
                          if (clean.length == 6) {
                            final parsed = int.tryParse(clean, radix: 16);
                            if (parsed != null) {
                              setState(() {
                                _selectedColor = Color(parsed + 0xFF000000);
                              });
                            }
                          }
                        },
                      ),
                    ),
                    // SizedBox(height: 10.h),

                    // // ── Color History ──────────────────────────────────────
                    // Text(
                    //   'Colors History:'.tr,
                    //   style: StyleText.fontSize16Weight500.copyWith(
                    //     color: AppColors.text,
                    //   ),
                    // ),
                    // // SizedBox(height: 5.h),
                    // Container(
                    //   width: isTablet
                    //       ? (orientation ? 0.4.w : 0.3.w)
                    //       : 0.6.w,
                    //   height: 0.04.h,
                    //   child: ListView.builder(
                    //     padding: EdgeInsets.zero,
                    //     scrollDirection: Axis.horizontal,
                    //     itemCount: _colorHistory.length,
                    //     itemBuilder: (context, index) {
                    //       return GestureDetector(
                    //         onTap: () {
                    //           setState(() {
                    //             _selectedColor = _colorHistory[index];
                    //             _hexController.text =
                    //             '#${_colorHistory[index].value.toRadixString(16).toUpperCase()}';
                    //           });
                    //         },
                    //         child: Container(
                    //           width: 0.04.h,
                    //           height: 0.04.h,
                    //           color: _colorHistory[index],
                    //           margin: EdgeInsets.only(right: 5),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),

              // ── Actions ────────────────────────────────────────────────
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 0.01.h,
                    right: isTablet
                        ? (orientation ? 0.02.w : 0.015.w)
                        : 0.03.w,
                    left: isTablet
                        ? (orientation ? 0.02.w : 0.015.w)
                        : 0.03.w,
                  ),
                  child: MainCustomIconButton(
                    onPressed: () {
                      hapticController.triggerHapticFeedback(
                        vibration: VibrateType.heavyImpact,
                        hapticFeedback: HapticFeedback.heavyImpact,
                      );

                      if (_selectedColor != null) {
                        widget.onColorSelected(_selectedColor!);
                        widget.onChanged(_selectedColor!);

                        // Sync controller text with the final selected color
                        _hexController.text =
                        '#${_selectedColor!.value.toRadixString(16).toUpperCase()}';

                        setState(() {
                          _colorHistory.add(_selectedColor!);
                        });
                      }

                      Navigator.of(context).pop();
                    },
                    buttonText: "Apply".tr,
                    buttonStyle: ElevatedButton.styleFrom(
                      minimumSize: isTablet
                          ? orientation
                          ? Size(0.15.w, 0.045.h)
                          : Size(0.07.w, 0.05.h)
                          : Size(0.2.w, 0.05.h),
                      backgroundColor: AppColors.signOut,
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  CompanyController addCompanyController = Get.find();

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return GestureDetector(
      onTap: () {
        _showColorPickerDialog(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Container(
          width: double.infinity,
          height: 36.h,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              Text(
                "${widget.fieldName.tr}: ",
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
              Text(
                _selectedColor == null
                    ? widget.initialColorString
                    : _selectedColor!.value
                    .toRadixString(16)
                    .toUpperCase(),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 15.h,
                  width: 15.w,
                  color: _selectedColor ??
                      Color(int.parse(widget.initialColorString)),
                ),
              ),
              if (!isTablet) SizedBox(width: 0.025.w),
            ],
          ),
        ),
      ),
    );
  }
}