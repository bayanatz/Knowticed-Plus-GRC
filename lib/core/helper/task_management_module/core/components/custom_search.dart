// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/view/board_create/create_board_screen.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/copy_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_icon.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/core/nav_bar_package.dart/functions.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';

class CustomSearchFiled2 extends StatefulWidget {
  final Color fillColor;
  final String hint;
  final TextStyle hintStyle;
  final TextInputType keyBoardType;
  final Function(String)? onChanged;
  final EdgeInsets? padding;
  final String secondActionIcon;
  final Color secondActionIconColor;
  final bool onBoardDetails;
  final bool isSecondIcon;

  const CustomSearchFiled2({
    super.key,
    required this.fillColor,
    required this.hint,
    required this.hintStyle,
    required this.keyBoardType,
    this.padding,
    this.onChanged,
    required this.secondActionIcon,
    required this.secondActionIconColor,
    this.onBoardDetails = false,
    this.isSecondIcon = true,
  });

  @override
  _CustomSearchFiledState createState() => _CustomSearchFiledState();
}

class _CustomSearchFiledState extends State<CustomSearchFiled2> {
  String search_text = '';
  TextEditingController textEditingController = TextEditingController();

  void onSearchTextChanged(String searchText) {
    setState(() {
      search_text = searchText;
    });
    widget.onChanged?.call(searchText);
  }

  void clearSearchText() {
    setState(() {
      search_text = '';
      textEditingController.clear(); // Clear the text field
    });
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    Get.put(TaskDetailsController());

    // bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GetBuilder<TaskDetailsController>(builder: (taskController) {
      if (search_text == '') {
        taskController.onBoardSearch = false;
        taskController.onCardSearch = false;
        taskController.onCardMemeberSearch = false;
      }
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextFormField(
                onTapOutside: (event) {
                  taskController.onBoardSearch = false;
                  taskController.onCardSearch = false;
                  taskController.onCardMemeberSearch = false;
                },
                textAlign: TextAlign.start,
                controller: textEditingController,
                onChanged: onSearchTextChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: widget.fillColor,
                  hintText: widget.hint,
                  hintStyle: widget.hintStyle.copyWith(
                      height: 1.7,
                      color: Theme.of(context).colorScheme.onTertiary),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Set border radius here
                    borderSide: BorderSide(
                        color: AppColors.signOut), // Set border color here
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Set border radius here
                    borderSide: BorderSide.none, // Set border color here
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: InkWell(
                      child: SvgPicture.asset(
                        'assets/icons_assets/main_icons_assets/images_search.svg',
                      ),
                    ),
                  ),
                  suffixIcon: search_text.isNotEmpty
                      ? IconButton(
                          onPressed: clearSearchText,
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                ),
                keyboardType: widget.keyBoardType,
                //
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    //height: 1.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              /// open dialog for filter
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColors.colorWhite,
                    contentPadding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    content: IntrinsicHeight(
                      child: SizedBox(
                        width: 300,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: AppColors.signOut,
                                    child: SvgPicture.asset(
                                      'assets/icons_assets/task_assets/icons_Tuning 2.svg',
                                      colorFilter: ColorFilter.mode(
                                        Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                      height: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Center(
                                    child: Text(
                                      'Filter'.tr,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xff2D2D2D),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              CustomDropdownButton2(
                                buttonPadding:
                                    EdgeInsets.symmetric(horizontal: 0.02.w),
                                iconHeight: 0.022.h,
                                //borded: true,
                                buttonColor: Colors.transparent,
                                buttonWidth: double.infinity,
                                backColor: Colors.transparent,
                                dropdownWidth: 0.865.w,
                                buttonHeight: 0.047.h,
                                isBottomSheet: true,
                                hint: 'Choose Department'.tr,
                                dropdownItems: [
                                  'selectedDepartment',
                                  'ddd',
                                  'dddd',
                                  'ddse'
                                ],
                                value: 'selectedDepartment',
                                onChanged: (String? value) {},
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              CustomDropdownButton2(
                                buttonPadding:
                                    EdgeInsets.symmetric(horizontal: 0.02.w),
                                iconHeight: 0.022.h,
                                //borded: true,
                                buttonColor: Colors.transparent,
                                buttonWidth: double.infinity,
                                backColor: Colors.transparent,
                                dropdownWidth: 0.865.w,
                                buttonHeight: 0.047.h,
                                isBottomSheet: true,
                                hint: 'Owner Status'.tr,
                                dropdownItems: [
                                  'Owner Status',
                                  'ddd',
                                  'dddd',
                                  'ddse'
                                ],
                                value: 'Owner Status',
                                onChanged: (String? value) {},
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              CustomDropdownButton2(
                                buttonPadding:
                                    EdgeInsets.symmetric(horizontal: 0.02.w),
                                iconHeight: 0.022.h,
                                //borded: true,
                                buttonColor: Colors.transparent,
                                buttonWidth: double.infinity,
                                backColor: Colors.transparent,
                                dropdownWidth: 0.865.w,
                                buttonHeight: 0.047.h,
                                isBottomSheet: true,
                                hint: 'Department'.tr,
                                dropdownItems: [
                                  'Department',
                                  'ddd',
                                  'dddd',
                                  'ddse'
                                ],
                                value: 'Department',
                                onChanged: (String? value) {},
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  CustomButtonFilter(
                                      text: 'Reset'.tr,
                                      buttonColor: AppColors.dotBlack),
                                  SizedBox(width: 30),
                                  CustomButtonFilter(
                                      text: 'Apply'.tr,
                                      buttonColor: AppColors.signOut),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: widget.fillColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: SvgPicture.asset(
                  widget.onBoardDetails
                      ? 'assets/icons_assets/main_icons_assets/sort_mob.svg'
                      : 'assets/icons_assets/task_assets/icons_Tuning 2.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          widget.onBoardDetails
              ? ReusableElevatedButton(
                  buttonText: 'Card',
                  icon: 'assets/icons_assets/main_icons_assets/icons_add.svg',
                  onPressed: () {
                    hapticController.triggerHapticFeedback(
                        vibration: VibrateType.lightImpact,
                        hapticFeedback: HapticFeedback.lightImpact);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CopyCardDialouge(
                          board: 'board',
                          /*boardModel: widget
                                                                .boardModel!,*/
                          title: "Create Card",
                          onPressed: () {
                            setState(() {});
                          },
                          isCard: true,
                          isCreatingCard: true,
                          iconUrl: 'assets/icons_assets/task_assets/addCardIcon.svg',
                        );
                      },
                    );
                  },
                )
              : widget.isSecondIcon
                  ? CustomIcon(
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          withNavBar: true,
                          screen: const CreateBoardScreenMobile(),
                        );
                      },
                      svgPath: widget.secondActionIcon,
                      color: widget.secondActionIconColor,
                    )
                  : SizedBox()
        ],
      );
    });
  }
}

class CustomButtonFilter extends StatelessWidget {
  final String text;
  final Color buttonColor;
  const CustomButtonFilter(
      {super.key, required this.text, required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 38,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: buttonColor,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  color: AppColors.colorBlack,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
