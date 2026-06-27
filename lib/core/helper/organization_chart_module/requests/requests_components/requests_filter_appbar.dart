import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/organization_chart_module/core_widgets/main_widget/custom_drop_down_menu.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/organization_chart_module/core_widgets/form_fields/custom_search.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';

// ignore: must_be_immutable
class RequestsFilterAppBar extends StatefulWidget {
  RequestsFilterAppBar(
      {super.key,
      required this.day,
      required this.dayState,
      required this.depState,
      required this.department,
      required this.status,
      required this.onChanged,
      required this.sortWidget,
      required this.statusState});
  String? department;
  ValueChanged<String?> depState;
  String? status;
  ValueChanged<String?> statusState;
  String? day;
  ValueChanged<String?> dayState;
  dynamic Function(String)? onChanged;
  Widget sortWidget;
  @override
  State<RequestsFilterAppBar> createState() => _RequestsFilterAppBarState();
}

AddDepartmentController addDepartmentController = Get.find();

class _RequestsFilterAppBarState extends State<RequestsFilterAppBar> {
  bool isSort = false;
  List<String> status = ["Pending", "Approved", "Rejected"];
  List<String> statusInArabic = ["Pending".tr, "Approved".tr, "Rejected".tr];
  List<String> days = ["Today", "Yesterday", "Last Week"];
  List<String> daysInArabic = ["Today".tr, "Yesterday".tr, "Last Week".tr];

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: isPortrait
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: SizedBox(
                height: (isPortrait ? 0.035.h : 0.06.h),
                child: CustomSearchFiled2(
                    onChanged: widget.onChanged,
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    padding: EdgeInsets.zero,
                    hint: "Search".tr,
                    hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: isPortrait
                            ? FontConstants.fontSize016.h
                            : FontConstants.fontSize022.h,
                        fontWeight: FontWeight.w500,
                        // height: (isPortrait? 2.8 : 3.2)  ,
                        color: Theme.of(context).colorScheme.inverseSurface),
                    keyBoardType: TextInputType.text),
              )),

              widget.sortWidget,
              isPortrait
                  ? const SizedBox.shrink()
                  : CustomDropdownButton2(
                      hint: "Department",
                      value: widget.department,
                      backgroundColor:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorWhite
                              : Theme.of(context).colorScheme.inversePrimary,
                      buttonPadding: EdgeInsets.symmetric(horizontal: 0.01.w),
                     
                      buttonWidth: 0.17.w,
                      dropdownWidth: 0.17.w,
                      buttonHeight: 0.06.h,
                      dropdownItems: Get.locale.toString().contains('en')
                          ? Get.find<AddDepartmentController>()
                              .departmentsEnglishName
                          : Get.find<AddDepartmentController>()
                              .departmentsArabicName,
                      onChanged: (value) {
                        setState(() {
                          print('value dep is $value');
                          widget.department = value;
                          widget.depState(widget.department);
                        });
                      }),
              isPortrait
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.01.w),
                      child: CustomDropdownButton2(
                          hint: "Status",
                          value: widget.status,
                          backgroundColor: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorWhite
                              : Theme.of(context).colorScheme.inversePrimary,
                          buttonPadding:
                              EdgeInsets.symmetric(horizontal: 0.01.w),
                       
                          buttonWidth: 0.11.w,
                          dropdownWidth: 0.11.w,
                          buttonHeight: 0.06.h,
                          dropdownItems: Get.locale.toString().contains('en')
                              ? status
                              : statusInArabic,
                          onChanged: (value) {
                            setState(() {
                              widget.status = value;
                              widget.statusState(
                                  Get.locale.toString().contains('en')
                                      ? widget.status
                                      : status[statusInArabic.indexOf(value!)]);
                            });
                          }),
                    ),
              isPortrait
                  ? const SizedBox.shrink()
                  : CustomDropdownButton2(
                      hint: "Day",
                      value: widget.day,
                      backgroundColor:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorWhite
                              : Theme.of(context).colorScheme.inversePrimary,
                      buttonPadding: EdgeInsets.symmetric(horizontal: 0.01.w),
                     
                      buttonWidth: 0.11.w,
                      dropdownWidth: 0.11.w,
                      buttonHeight: 0.06.h,
                      dropdownItems: Get.locale.toString().contains('en')
                          ? days
                          : daysInArabic,
                      onChanged: (value) {
                        setState(() {
                          widget.day = value;
                          widget.dayState(Get.locale.toString().contains('en')
                              ? widget.day
                              : days[daysInArabic.indexOf(value!)]);
                        });
                      })
              // Container(
              //   height: isPortrait ? 0.04.h : 0.055.h,
              //   width: isPortrait ? 0.15.w : 0.1.w,
              //   decoration: BoxDecoration(
              //       color: Theme.of(context).colorScheme.inversePrimary,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(
              //         color: Theme.of(context).colorScheme.scrim,
              //       )),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       SvgPicture.asset("assets/images/filter_table.svg",
              //           // ignore: deprecated_member_use
              //           color: Theme.of(context).colorScheme.scrim),
              //       Text(
              //         "Filter".tr,
              //         style: AppFontStyle.cairoRegularStyle.copyWith(
              //             fontSize: isPortrait
              //                 ? FontConstants.fontSize018.h
              //                 : FontConstants.fontSize024.h,
              //             fontWeight: FontWeight.w500,
              //             height: isPortrait ? 1.6 : 0.0018.h,
              //             color: Theme.of(context).colorScheme.scrim),
              //       )
              //     ],
              //   ),
              // )
            ],
          ),
        ),
        isPortrait
            ? Padding(
                padding: EdgeInsets.only(top: 0.02.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomDropdownButton2(
                          hint: "Department",
                          value: widget.department,
                          buttonPadding:
                              EdgeInsets.symmetric(horizontal: 0.01.w),
                         
                          backgroundColor: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorWhite
                              : Theme.of(context).colorScheme.inversePrimary,
                          buttonWidth: 0.22.w,
                          dropdownWidth: 0.27.w,
                          buttonHeight: 0.04.h,
                          dropdownItems:
                              Get.locale.toString().contains('en')
                                  ? Get.find<AddDepartmentController>()
                                      .departmentsEnglishName
                                  : Get.find<AddDepartmentController>()
                                      .departmentsArabicName,
                          onChanged: (value) {
                            setState(() {
                              widget.department = value;
                              widget.depState( widget.department
                          );
                            });
                          }),
                    ),
                    SizedBox(width: 0.02.w),
                    Expanded(
                      child: CustomDropdownButton2(
                          hint: "Status",
                          value: widget.status,
                          buttonPadding:
                              EdgeInsets.symmetric(horizontal: 0.01.w),
                          backgroundColor: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorWhite
                              : Theme.of(context).colorScheme.inversePrimary,
                          buttonWidth: 0.22.w,
                          dropdownWidth: 0.27.w,
                          buttonHeight: 0.04.h,
                          dropdownItems: Get.locale.toString().contains('en')
                              ? status
                              : statusInArabic,
                          onChanged: (value) {
                            setState(() {
                              widget.status = value;
                              widget.statusState(
                                  Get.locale.toString().contains('en')
                                      ? widget.status
                                      : status[statusInArabic.indexOf(value!)]);
                            });
                          }),
                    ),
                    SizedBox(width: 0.02.w),
                    Expanded(
                      child: CustomDropdownButton2(
                          hint: "Day",
                          value: widget.day,
                          buttonPadding:
                              EdgeInsets.symmetric(horizontal: 0.01.w),
                          backgroundColor: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorWhite
                              : Theme.of(context).colorScheme.inversePrimary,
                          buttonWidth: 0.22.w,
                          dropdownWidth: 0.27.w,
                          buttonHeight: 0.04.h,
                          dropdownItems: Get.locale.toString().contains('en')
                              ? days
                              : daysInArabic,
                          onChanged: (value) {
                            setState(() {
                              widget.day = value;
                              widget.dayState(
                                  Get.locale.toString().contains('en')
                                      ? widget.day
                                      : days[daysInArabic.indexOf(value!)]);
                            });
                          }),
                    )
                  ],
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }
}
