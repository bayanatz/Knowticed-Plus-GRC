import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/widgets/filter_dialog.dart';
import 'package:demo_app/core/helper/employees/chats_lists.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/employees/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/employees/core_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/core/helper/employees/core_widgets/form_fields/custom_search.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/add_new_employee_view.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/add_depratment_dialog.dart';
import 'package:demo_app/features/roles/role_management/controller/role_controller.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_responsive_page.dart';

// ignore: must_be_immutable
class EmployeeHrAppBar extends StatefulWidget {
  EmployeeHrAppBar({
    super.key,
    required this.orgView,
    required this.chartView,
    required this.isFilterDataShow,
    required this.isFilterDataState,
    required this.isSort,
    required this.isSortState,
    this.dropDownValue,
    this.orgDropValue,
    this.dropDropeState,
    this.orgDropeState,
    this.onChangedSearch,
    this.delayState,
    this.statusState,
    this.dateValueState,
    required this.depName,
    required this.depNameState,
    required this.depNameInArabic,
    required this.depNameStateInArabic,
    required this.statusValue,
    required this.delayValue,
    required this.dateValue,
  });
  bool chartView;
  bool orgView;
  bool isFilterDataShow;
  bool isSort;
  ValueChanged<bool> isSortState;
  ValueChanged<bool> isFilterDataState;
  String? dropDownValue;
  String? orgDropValue;
  ValueChanged<String?>? orgDropeState;
  ValueChanged<String?>? dropDropeState;
  TextEditingController depName;
  ValueChanged<TextEditingController> depNameState;
  TextEditingController depNameInArabic;
  ValueChanged<TextEditingController> depNameStateInArabic;
  Function(String)? onChangedSearch;
  Function(String?)? delayState;
  Function(String?)? statusState;
  String? dateValue;
  String? delayValue;
  String? statusValue;

  void Function(String?)? dateValueState;
  @override
  State<EmployeeHrAppBar> createState() => _EmployeeHrAppBarState();
}

RoleCubit addRoleController =roleCubit;

class _EmployeeHrAppBarState extends State<EmployeeHrAppBar> {
  final HapticController hapticController = Get.put(HapticController());
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: widget.chartView
              ? 0
              : isPortrait
                  ? 0.01.h
                  : 0.02.h),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: widget.chartView || widget.orgView
              ? MainAxisAlignment.end
              : MainAxisAlignment.spaceBetween,
          children: widget.orgView
              ? <Widget>[
                  CustomDropdownButton2(
                    hint: "Organization Chart",
                    buttonWidth: 0.17.w,
                    dropdownWidth: 0.17.w,
                    buttonHeight: 0.059.h,
                    borded: true,
                    buttonPadding: EdgeInsets.symmetric(horizontal: 0.01.w),
                    value: widget.orgDropValue,
                    dropdownItems: [
                      "Organization Chart".tr,
                      "Team Departments".tr
                    ],
                    onChanged: ((value) {
                      setState(() {
                        widget.orgDropValue = value;
                        widget.orgDropeState!(widget.orgDropValue);
                      });
                    }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left:
                            Get.locale.toString().contains('en') ? 0.015.w : 0,
                        right:
                            Get.locale.toString().contains('en') ? 0 : 0.015.w),
                    child: MainCustomIconButton(
                      onPressed: () {
                        // showDialog(
                        //     context: context,
                        //     builder: (context) {
                        //       return AddDepartmentDialogNew(
                        //           employeesState: (value) {
                        //             setState(() {
                        //               teams = value;
                        //               print('12121212=$value');
                        //             });
                        //           },
                        //           depName: widget.depName,
                        //           depNameInArabic: widget.depNameInArabic,
                        //           depNameState: (value) {
                        //             setState(() {
                        //               widget.depName = value;
                        //             });
                        //           },
                        //           depNameStateInArabic: (value) {
                        //             setState(() {
                        //               widget.depNameInArabic = value;
                        //             });
                        //           });
                        //     });
                      },
                      buttonText: "Add Department".tr,
                      widgetIcon: "assets/images/case.svg",
                      buttonStyle: ElevatedButton.styleFrom(
                        minimumSize: Size(0.018.w, 0.055.h),
                        backgroundColor: AppColors.signOut,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        )),
                      ),
                    ),
                  )
                ]
              : widget.chartView
                  ? <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 0.02.h, bottom: 0.02.h),
                        child: CustomDropdownButton2(
                            hint: "Monthly",
                            buttonWidth: 0.1.w,
                            dropdownWidth: 0.1.w,
                            buttonHeight: 0.048.h,
                            borded: true,
                            buttonPadding:
                                EdgeInsets.symmetric(horizontal: 0.01.w),
                            value: widget.dropDownValue,
                            dropdownItems: [
                              "Monthly".tr,
                              "Weekly".tr,
                              "Annually".tr
                            ],
                            onChanged: ((value) {
                              setState(() {
                                widget.dropDownValue = value;
                                widget.dropDropeState!(widget.dropDownValue);
                              });
                            })),
                      )
                    ]
                  : <Widget>[
                      SizedBox(
                        width: isPortrait ? 0.43.w : 0.61.w,
                        height: isPortrait ? 0.045.h : null,
                        child: CustomSearchFiled2(
                            onChanged: widget.onChangedSearch,
                            fillColor:
                                Theme.of(context).colorScheme.inversePrimary,
                            hint: "Search".tr,
                            hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                              color: Theme.of(context).colorScheme.scrim,
                              fontSize: isPortrait
                                  ? FontConstants.fontSize015.h
                                  : FontConstants.fontSize014.w,
                              fontWeight: FontWeight.w400,
                            ),
                            keyBoardType: TextInputType.text),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     hapticController.triggerHapticFeedback(
                      //         vibration: VibrateType.lightImpact,
                      //         hapticFeedback: HapticFeedback.lightImpact);
                      //     setState(() {
                      //       widget.isSort = !widget.isSort;
                      //       widget.isSortState(widget.isSort);
                      //     });
                      //   },
                      //   child: CustomPhotoContainer(
                      //       imageUrl: "assets/images/list.svg",
                      //       borderColor: widget.isSort
                      //           ? Colors.transparent
                      //           : Theme.of(context).colorScheme.scrim,
                      //       backColor: widget.isSort
                      //           ? AppColors.signOut
                      //           : Theme.of(context).colorScheme.inversePrimary,
                      //       photoColor: widget.isSort
                      //           ? AppColors.colorBlack
                      //           : Theme.of(context).colorScheme.scrim),
                      // ),
                      GestureDetector(
                        onTap: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.lightImpact,
                              hapticFeedback: HapticFeedback.lightImpact);
                          setState(() {
                            widget.isFilterDataShow = !widget.isFilterDataShow;
                            widget.isFilterDataState(widget.isFilterDataShow);
                          });
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FilterDialog(
                                employessScreen: true,
                                statusValue: widget.statusValue,
                                delayValue: widget.delayValue,
                                dropDownItems: [
                                  'On Time'.tr,
                                  'Late'.tr,
                                  'Absent'.tr,
                                ],
                                delayState: widget.delayState,
                                statusState: widget.statusState,
                                dateValue: widget.dateValue ?? "Date",
                                dateValueState: widget.dateValueState,
                              );
                            },
                          );
                        },
                        child: Container(
                          height: isPortrait ? 0.04.h : 0.055.h,
                          width: isPortrait ? 0.15.w : 0.1.w,
                          decoration: BoxDecoration(
                              color: widget.isFilterDataShow
                                  ? AppColors.signOut
                                  : Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: widget.isFilterDataShow
                                    ? Colors.transparent
                                    : Theme.of(context).colorScheme.scrim,
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SvgPicture.asset("assets/images/filter_table.svg",
                                  // ignore: deprecated_member_use
                                  color: widget.isFilterDataShow
                                      ? AppColors.colorBlack
                                      : Theme.of(context).colorScheme.scrim),
                              Text(
                                "Filter".tr,
                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                    fontSize: isPortrait
                                        ? FontConstants.fontSize018.h
                                        : FontConstants.fontSize024.h,
                                    fontWeight: FontWeight.w500,
                                    height: isPortrait ? 1.6 : 0.0018.h,
                                    color: widget.isFilterDataShow
                                        ? AppColors.colorBlack
                                        : Theme.of(context).colorScheme.scrim),
                              )
                            ],
                          ),
                        ),
                      ),
                      MainCustomIconButton(
                        onPressed: () {
                          false
                              ? Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    child: const AddNewEmployeeScreen(),
                                  ),
                                )
                              : showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const ResponseDialog(
                                      title: "Unsuccessful",
                                      subtitle:
                                          "You Don't Have Permission To Add New Employees",
                                      lottieAsset: "assets/images/error.json",
                                    );
                                  });
                        },
                        buttonText: "Add Employee".tr,
                        widgetIcon: "assets/images/case.svg",
                        buttonStyle: ElevatedButton.styleFrom(
                          minimumSize: isPortrait
                              ? Size(0.04.w, 0.035.h)
                              : Size(0.018.w, 0.055.h),
                          backgroundColor: AppColors.signOut,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          )),
                        ),
                      )
                    ],
        ),
      ),
    );
  }
}
