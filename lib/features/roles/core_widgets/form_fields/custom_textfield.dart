// ignore_for_file: unnecessary_null_in_if_null_operators

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  CustomTextField(
      {super.key,
      this.maxLength,
      required this.hint,
      this.hasPrefix = false,
      this.prefixIcon,
      this.hasSuffix = false,
      this.suffixUrl,
      this.textController,
      this.fillColor,
      this.controllerState,
      this.validator,
      this.hassSuffixState,
      this.enabled = true,
      this.readOnly,
      this.suffixColor,
      this.initialValue,
      this.maxLines,
      this.keyboardType,
      this.buttonHeight,
      this.textDirection,
      this.textAlign,
      this.contextMenuBuilder,
      this.controllerfinishState});
  final String hint;
  TextEditingController? textController;
  ValueChanged<String?>? controllerState;
  ValueChanged? controllerfinishState;
  TextInputType? keyboardType;
  final bool? hasPrefix;
  final Widget? prefixIcon;
  final int? maxLength;
  bool? hasSuffix;
  double? buttonHeight;
  String? Function(String?)? validator;
  ValueChanged<bool?>? hassSuffixState;
  final String? suffixUrl;
  final String? initialValue;
  final Color? fillColor;
  final bool? readOnly;
  final int? maxLines;
  bool enabled;
  final TextDirection? textDirection;
  final Color? suffixColor;
  TextAlign? textAlign;
  Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final ValueNotifier<String> errorNotifier = ValueNotifier<String>('');
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.buttonHeight,
          child: TextFormField(
            textDirection: widget.textDirection,
            textAlignVertical: TextAlignVertical.bottom,
            buildCounter: (context,
                {required currentLength, required isFocused, maxLength}) {
              if (widget.maxLength != null) {
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
                        style: 
                        (isPortrait ? AppTextStyles.font12BlackCairoRegular:AppTextStyles.font14BlackCairoRegular).copyWith(
                          color: AppColors.lightGrey
                        )
                      ),
                    ],
                  ),
                );
              }
            },
            contextMenuBuilder: widget.contextMenuBuilder,
            initialValue: widget.initialValue,
            maxLength: widget.maxLength ?? null,
            maxLines: widget.maxLines ?? 1,
            readOnly: widget.readOnly ?? false,
            controller: widget.textController,
            textAlign: widget.textAlign ?? TextAlign.start,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: widget.keyboardType,
            scrollPadding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).viewInsets.bottom),
            decoration: InputDecoration(
              filled: true,
              enabled: widget.enabled,
              hintText: widget.hint.tr,
              counterStyle: isPortrait
                  ? AppTextStyles.font12SecondaryBlackCairoRegular
                  : AppTextStyles.font18SecondaryBlackCairoMedium,

              fillColor: widget.fillColor ?? AppColors.field,
              prefixIcon: widget.hasPrefix == true ? widget.prefixIcon : null,
              hoverColor: Colors.transparent,
              suffixIcon: widget.hasSuffix == true
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          if (widget.textController != null) {
                            widget.textController!.text = '';
                          }
                          widget.hasSuffix = false;
                          if (widget.hassSuffixState != null) {
                            widget.hassSuffixState!(widget.hasSuffix);
                          }
                        });
                      },
                      child: widget.suffixUrl == null
                          ? const SizedBox.shrink()
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:10.w ),
                                  child: SvgPicture.asset(
                                    height: isTablet?25.w:20.w,
                                    widget.suffixUrl ?? '',
                                    color: widget.suffixColor ?? AppColors.greyIcon,
                                  ),
                                ),
                            ],
                          ),
                    )
                  : null,
              hintTextDirection: widget.textDirection,
              hintStyle:(isTablet?AppTextStyles.font16SecondaryBlackCairoMedium:AppTextStyles.font14SecondaryBlackCairoMedium)
                  .copyWith(color: AppColors.greyIcon),

              errorStyle: AppTextStyles.font12SecondaryBlackCairoMedium
                  .copyWith(color: AppColors.red),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),

              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                 color: Colors.transparent
                  )),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  )),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  )),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.0),
              ),
           
              isDense: true,
            ),
            showCursor: false,
            style:isTablet? AppTextStyles.font16BlackRegularCairo:AppTextStyles.font14BlackRegularCairo,
            onChanged: (value) {
              setState(() {
                if (widget.textController != null) {
                  if (widget.textController!.text.isNotEmpty) {
                    widget.hasSuffix = true;
                  } else {
                    widget.hasSuffix = false;
                  }
                  widget.hassSuffixState?.call(widget.hasSuffix);
                }
                widget.controllerState?.call(value);
                final errorMessage = widget.validator?.call(value) ?? '';
                errorNotifier.value = errorMessage;
              });

              final errorMessage = widget.validator?.call(value) ?? '';
              errorNotifier.value = errorMessage;
            },
            onEditingComplete: () {
              setState(() {
                widget.controllerfinishState?.call(widget.textController);
              });
            },
            cursorColor: AppColors.primary,
          ),
        ),

        Builder(
          builder: (context) {
            return ValueListenableBuilder<String>(
              valueListenable: errorNotifier,
              builder: (context, errorMessage, _) {
                return errorMessage.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage,
                          style: AppTextStyles.font14BlackRegularCairo.copyWith(color: Colors.red),
                        ),
                      )
                    : SizedBox.shrink();
              },
            );
          },
        ),
      ],
    );
  }
}
