import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';

// REMOVED_MODULE: import 'package:demo_app/features/skeleton/settings/settings_screen/views/profile_screen.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/features/settings/presentation/ui/pages/profile_screen.dart';

import 'package:demo_app/features/settings/presentation/ui/pages/personal_info_screen.dart';

class CustomDescriptionTextField extends StatefulWidget {
  final int? maxLength;
  final TextEditingController controller;
  bool enabled;
  final Color? fillColor;
  String? Function(String?)? validator;
  final TextDirection? textDirection;
  final String? hint;

  CustomDescriptionTextField(
      {Key? key,
      this.maxLength,
      this.hint,
      this.fillColor,
      required this.controller,
      this.enabled = true,
      this.textDirection,
      this.validator})
      : super(key: key);

  @override
  State<CustomDescriptionTextField> createState() =>
      _CustomDescriptionTextFieldState();
}

class _CustomDescriptionTextFieldState
    extends State<CustomDescriptionTextField> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return TextFormField(
      maxLength: widget.maxLength ?? 200,
      controller: widget.controller,
      textDirection: widget.textDirection,
      onChanged: (value) {
        setState(() {
          whatChanged = value;
          print('whatChanged:$whatChanged');
        });
      },
      buildCounter: (context,
          {required currentLength, required isFocused, maxLength}) {
        return Container(
          child: Row(
            mainAxisAlignment: widget.textDirection == TextDirection.ltr
                ? Get.locale.toString().contains('en')
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start
                : widget.textDirection == TextDirection.rtl
                    ? Get.locale.toString().contains('ar')
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start
                    : Get.locale.toString().contains('en')
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
            children: [
              Text(
                Get.locale.toString().contains('en')
                    ? "$currentLength/$maxLength"
                    : "${convertNumberToArabic(currentLength.toString())}/${convertNumberToArabic(maxLength.toString())}",
                style:    (isPortrait ? AppTextStyles.font12BlackCairoRegular:AppTextStyles.font14BlackCairoRegular).copyWith(
                        color: AppColors.lightGrey
                      )
              ),
            ],
          ),
        );
      },
      decoration: InputDecoration(
        filled: widget.fillColor != null ? true : false,
        fillColor: AppColors.field,
        hoverColor: Colors.transparent,
        enabled: widget.enabled,
        hintText: widget.hint?.tr ?? "Text Here".tr,
        hintTextDirection: widget.textDirection,
        hintStyle: (isTablet?AppTextStyles.font16SecondaryBlackCairoMedium:AppTextStyles.font14SecondaryBlackCairoMedium)
                .copyWith(color: AppColors.greyIcon),   enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: AppColors.lightPrimary,
          ),
        ),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: Colors.transparent //Theme.of(context).colorScheme.scrim,
                )),
        isDense: true,
        counterStyle:isPortrait
                ? AppTextStyles.font12SecondaryBlackCairoRegular
                : AppTextStyles.font18SecondaryBlackCairoMedium,
    
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
      ),
      maxLines: 6,
      style: isTablet? AppTextStyles.font16BlackRegularCairo:AppTextStyles.font14BlackRegularCairo
    ,
      textAlignVertical: TextAlignVertical.center,
      cursorHeight: 0,
      cursorWidth:0,
      keyboardType: TextInputType.multiline,
      validator: widget.validator,
    );
  }
}
