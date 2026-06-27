import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

class TwoTextSection extends StatelessWidget {
  final Function(String)? firstOnChanged;
  final String? Function(String?)? firstValidator;
  final String? firstInitialValue;
  final String firstHint;
  final Function(String)? secondOnChanged;
  final String? Function(String?)? secondValidator;
  final String? secondInitialValue;
  final String secondHint;
  final bool isReadOnly;

  const TwoTextSection({
    Key? key,
    this.firstOnChanged,
    this.firstValidator,
    this.secondOnChanged,
    this.secondValidator,
    this.firstInitialValue,
    this.secondInitialValue,
    required this.firstHint,
    required this.secondHint,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return isVertical
        ? Theme(
            data: Theme.of(context).copyWith(
              hoverColor: Colors.transparent,
            ),
            child: Column(
              children: [
                textfieled(
                  context,
                  (value) {
                    firstOnChanged;
                  },
                  (value) {
                    firstValidator;
                  },
                  firstHint.tr,
                  firstInitialValue,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
                textfieled(
                  context,
                  (value) {
                    secondOnChanged;
                  },
                  (value) {
                    secondValidator;
                  },
                  secondHint.tr,
                  secondInitialValue,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ],
            ),
          )
        : Theme(
            data: Theme.of(context).copyWith(hoverColor: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Get.locale.toString().contains('en') ? 0.02.h : 0,
                      left: Get.locale.toString().contains('ar') ? 0.02.h : 0,
                    ),
                    child: textfieled(
                      context,
                      (value) {
                        firstOnChanged;
                      },
                      (value) {
                        firstValidator;
                      },
                      firstHint.tr,
                      firstInitialValue,
                      null, // prefixIcon
                      controller: null,
                      isReadOnly: true,
                    ),
                  ),
                ),
                Expanded(
                  child: textfieled(
                    context,
                    (value) {
                      secondOnChanged;
                    },
                    (value) {
                      secondValidator;
                    },
                    secondHint.tr,
                    secondInitialValue,
                    null, // prefixIcon
                    controller: null,
                    isReadOnly: true,
                  ),
                ),
              ],
            ),
          );
  }
}
