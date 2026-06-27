import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

class ProvinceStreetAddSection extends StatefulWidget {
  final Function(String)? streetOnChanged;
  final String? Function(String?)? streetValidator;
  final String? streetInitialValue;
  final String streetHint;

  final Function(String)? provinceOnChanged;
  final String? Function(String?)? provinceValidator;
  final String? provinceInitialValue;
  final String provinceHint;

  const ProvinceStreetAddSection({
    Key? key,
    this.streetOnChanged,
    this.streetValidator,
    this.streetInitialValue,
    required this.streetHint,
    this.provinceOnChanged,
    this.provinceValidator,
    this.provinceInitialValue,
    required this.provinceHint,
  }) : super(key: key);

  @override
  State<ProvinceStreetAddSection> createState() =>
      _ProvinceStreetAddSectionState();
}

class _ProvinceStreetAddSectionState extends State<ProvinceStreetAddSection> {
  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return isVertical
        ? Column(
            children: [
              Stack(
                children: [
                  textfieled(
                    context,
                    (value) async {
                      widget.provinceHint;
                    },
                    (value) {
                      widget.provinceValidator;
                    },
                    widget.provinceHint.tr,
                    widget.provinceInitialValue,
                    null,
                    controller: null,
                    isReadOnly: true,
                  ),
                  InkWell(
                      onTap: (() async {
                        setState(() {
                          //     showLoadingIndicator();
                        });
                        //    address = await getUserLocation();
                        setState(() {
                          //      hideLoadingIndicator();
                        });

                        //     state = address!.administrativeArea;
                      }),
                      child: Container(
                        width: double.infinity,
                        height: 46,
                        color: Colors.transparent,
                      )),
                ],
              ),
              textfieled(
                context,
                (value) {
                  widget.streetOnChanged;
                },
                (value) {
                  widget.streetValidator;
                },
                widget.streetHint.tr, // hintText
                widget.streetInitialValue,
                null, // prefixIcon
                controller: null,
                isReadOnly: true,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: Get.locale.toString().contains('en') ? 0.02.h : 0,
                      left: Get.locale.toString().contains('ar') ? 0.02.h : 0),
                  child: Stack(
                    children: [
                      textfieled(
                        context,
                        (value) async {
                          widget.provinceHint;
                        },
                        (value) {
                          widget.provinceValidator;
                        },
                        widget.provinceHint.tr,
                        widget.provinceInitialValue,
                        null,
                        controller: null,
                        isReadOnly: true,
                      ),
                      InkWell(
                          onTap: (() async {
                            setState(() {
                              //     showLoadingIndicator();
                            });
                            //    address = await getUserLocation();
                            setState(() {
                              //      hideLoadingIndicator();
                            });

                            //     state = address!.administrativeArea;
                          }),
                          child: Container(
                            width: double.infinity,
                            height: 46,
                            color: Colors.transparent,
                          )),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: textfieled(
                  context,
                  (value) {
                    widget.streetOnChanged;
                  },
                  (value) {
                    widget.streetValidator;
                  },
                  widget.streetHint.tr, // hintText
                  widget.streetInitialValue,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ],
          );
  }
}
