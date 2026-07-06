import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/borad/view/board_create/create_board_screen.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/invited_members_screen.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_icon.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/core/nav_bar_package.dart/functions.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/member/widgets/invited_members_screen_mobile.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_drawer.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

/// Date Created :19/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives:  this file represents the  custom container for showing the project detailes inside the board screen
class CustomTaskContainer extends StatefulWidget {
  final BoardModel board;
  final VoidCallback? onPressed;
  final bool onBoardDetails;

  const CustomTaskContainer({
    super.key,
    required this.board,
    this.onPressed,
    this.onBoardDetails = false,
  });

  @override
  State<CustomTaskContainer> createState() => _CustomTaskContainerState();
}

class _CustomTaskContainerState extends State<CustomTaskContainer> {
  TaskDetailsController tController = Get.find();
  BoardController bController = Get.find();
  List<String> images = [
    'https://firebasestorage.googleapis.com/v0/b/knowticed-v2-scheme.appspot.com/o/job_post_images%2F2024-05-27%2014%3A51%3A04.496780.jpeg?alt=media&token=534c23d1-71c2-467f-b189-942d56eb79da',
    'https://firebasestorage.googleapis.com/v0/b/knowticed-v2-scheme.appspot.com/o/job_post_images%2F2024-05-27%2014%3A51%3A04.496780.jpeg?alt=media&token=534c23d1-71c2-467f-b189-942d56eb79da',
    'https://firebasestorage.googleapis.com/v0/b/knowticed-v2-scheme.appspot.com/o/job_post_images%2F2024-05-27%2014%3A51%3A04.496780.jpeg?alt=media&token=534c23d1-71c2-467f-b189-942d56eb79da',
    'https://firebasestorage.googleapis.com/v0/b/knowticed-v2-scheme.appspot.com/o/job_post_images%2F2024-05-27%2014%3A51%3A04.496780.jpeg?alt=media&token=534c23d1-71c2-467f-b189-942d56eb79da',
  ];
  int allMembersNum = 0;

  String getNameOfDepartment(String index) {
    switch (index) {
      case '1':
        return "Executive".tr;
      case '2':
        return "Operations".tr;
      case '3':
        return "Finance".tr;
      case '4':
        return "Information Technology".tr;
      case '5':
        return "Human Resources".tr;
      case '6':
        return "Marketing".tr;
      case '7':
        return "Sales".tr;
      case '8':
        return "Data Management".tr;
      case '9':
        return "Compliance & Legal".tr;
      case '10':
        return "Customer Support".tr;
      default:
        return "None".tr;
    }
  }

  void inviteMembersNavigationMobile() {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      withNavBar: false,
      screen: InvitedMembersScreenMobile(
        boardModel: widget.board,
      ),
    );
  }

  void inviteMembersNavigationTablet() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: CustomDrawer(
          initialIndex: 1,
          screens: [
            Container(),
            InvitedMembersScreen(
              boardModel: widget.board,
            ),
          ],
        ),
      ),
    );
  }

  void getAllMembersNum() {
    allMembersNum = 0;
    for (int i = 0; i < widget.board.boardMember!.boardMembers!.length; i++) {
      if (widget.board.boardMember!.boardMembersStatus![i] == "invited") {
        allMembersNum++;
        images.add(bController.getSingleImage(
          widget.board.boardMember!.boardMembers![i],
        ));
      }
    }
    if (allMembersNum > 3) {
      allMembersNum = allMembersNum - 3;
    } else {
      allMembersNum = 0;
    }
  }

  @override
  void initState() {
    // images = [];
    getAllMembersNum();

    // bController.getAllEmployees().then((value) {
    //   images = [];
    //   getAllMembersNum();
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return GetBuilder<BoardController>(builder: (taskController) {
      return Stack(
        children: [
          GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              decoration: BoxDecoration(
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorWhite
                    : Theme.of(context).colorScheme.inversePrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              // width: 0.42.h,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        widget.board.boardImage?.boardImage?.lastOrNull == null
                            ? Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: AppColors.grey,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/new_student_button_2.svg',
                                    // width: 20,
                                    // height: 24,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  widget.board.boardImage!.boardImage!.last,
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        SizedBox(
                          width: 10.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.board.boardName!.boardgName!.last
                                  .capitalize as String,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: FontConstants.fontSize016.h,
                                color: themeController.currentTheme ==
                                        AppColors.lightTheme
                                    ? AppColors.colorBlack
                                    : AppColors.colorWhiteDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Department: ',
                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: FontConstants.fontSize014.h,
                                  color: themeController.currentTheme ==
                                          AppColors.lightTheme
                                      ? AppColors.dotBlack
                                      : AppColors.colorWhiteDark,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: getNameOfDepartment(widget
                                        .board
                                        .boardDeparment!
                                        .boardgDepartment!
                                        .last),
                                    style:
                                        AppFontStyle.cairoRegularStyle.copyWith(
                                      fontSize: FontConstants.fontSize012.h,
                                      color: themeController.currentTheme ==
                                              AppColors.lightTheme
                                          ? AppColors.colorBlack
                                          : AppColors.colorWhiteDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        widget.onBoardDetails
                            ? Align(
                                alignment: Alignment.topCenter,
                                child: DateWidget(
                                  board: widget.board,
                                ),
                              )
                            : widget.board.boardCreator ==
                                    Get.find<MainCoreEmployeeController>()
                                        .employeeEntity!
                                        .email!
                                ? Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: AppColors.signOut,
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 5),
                                          child: Text(
                                            'Owner'.tr,
                                            style: AppFontStyle
                                                .cairoRegularStyle
                                                .copyWith(
                                              fontSize:
                                                  FontConstants.fontSize012.h,
                                              color: themeController
                                                          .currentTheme ==
                                                      AppColors.lightTheme
                                                  ? AppColors.colorBlack
                                                  : AppColors.colorWhiteDark,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  widget.onBoardDetails
                      ? Text(
                          'Description:'.tr,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: FontConstants.fontSize016.h,
                              color: themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? AppColors.dotBlack
                                  : AppColors.colorWhiteDark,
                              fontWeight: FontWeight.w600,
                              height: 1.5),
                        )
                      : SizedBox.shrink(),
                  Text(
                    widget.board.boardDescription!.boardDescription!.last,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: FontConstants.fontSize016.h,
                      color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorDarkGrey
                              : AppColors.colorGreydark,
                      fontWeight: FontWeight.w400,
                      // height: (orientation && isTablet ? 1.8 : 0.002.h),
                    ),
                  ),
                  SizedBox(
                    height: 41,
                  ),
                  widget.onBoardDetails
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CustomIcon(
                                  onTap: () {
                                    PersistentNavBarNavigator.pushNewScreen(
                                        context,
                                        withNavBar: true,
                                        screen: CreateBoardScreenMobile(
                                          board: widget.board,
                                        ));
                                  },
                                  svgPath: 'assets/icons_assets/main_icons_assets/images_edit.svg',
                                  color: AppColors.signOut,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                CustomIcon(
                                    svgPath: 'assets/images/delete1.svg',
                                    color: AppColors.red),
                              ],
                            ),
                            ReusableElevatedButton(
                              buttonText: 'Chat',
                              icon: 'assets/icons_assets/main_icons_assets/chat_notifi_mob.svg',
                              onPressed: () {},
                            ),
                          ],
                        )
                      : DateWidget(board: widget.board)
                ],
              ),
            ),
          ),
          if (images.isNotEmpty)
            Positioned(
              bottom: 0.015.h,
              left: Get.locale.toString().contains('ar') ? 0.02.h : null,
              right: Get.locale.toString().contains('en') ? 0.02.h : null,
              child: GestureDetector(
                onTap: () {
                  // isTablet
                  //     ? inviteMembersNavigationTablet():
                  inviteMembersNavigationMobile();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: images[0].isURL
                        ? CircleAvatar(
                            radius: 0.03.h,
                            backgroundImage: NetworkImage(images[0]),
                          )
                        : CircleAvatar(
                            radius: 0.03.h,
                            backgroundImage: appImageProvider(images[0]),
                          ),
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              bottom: 0.015.h,
              left: Get.locale.toString().contains('ar') ? 0.04.h : null,
              right: Get.locale.toString().contains('en') ? 0.04.h : null,
              child: GestureDetector(
                onTap: () {
                  // isTablet
                  //     ? inviteMembersNavigationTablet() :
                  inviteMembersNavigationMobile();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: images[1].isURL
                        ? CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(images[1]),
                          )
                        : CircleAvatar(
                            radius: 30,
                            backgroundImage: appImageProvider(images[1]),
                          ),
                  ),
                ),
              ),
            ),
          if (images.length > 2)
            Positioned(
              bottom: 0.015.h,
              left: Get.locale.toString().contains('ar') ? 0.06.h : null,
              right: Get.locale.toString().contains('en') ? 0.06.h : null,
              child: GestureDetector(
                onTap: () {
                  // isTablet
                  //     ? inviteMembersNavigationTablet() :
                  inviteMembersNavigationMobile();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: images[2].isURL
                        ? CircleAvatar(
                            radius: 0.03.h,
                            backgroundImage: NetworkImage(images[2]),
                          )
                        : CircleAvatar(
                            radius: 0.03.h,
                            backgroundImage: appImageProvider(images[2]),
                          ),
                  ),
                ),
              ),
            ),
          if (allMembersNum != 0)
            Positioned(
              bottom: 0.015.h,
              left: Get.locale.toString().contains('ar') ? 0.08.h : null,
              right: Get.locale.toString().contains('en') ? 0.08.h : null,
              child: GestureDetector(
                onTap: () {
                  // isTablet
                  //     ? inviteMembersNavigationTablet() :
                  inviteMembersNavigationMobile();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightPrimary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.001.h),
                        child: Text(
                          "+${Get.locale.toString().contains('en') ? allMembersNum : convertNumberToArabic(allMembersNum.toString())}",
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize010.h,
                            height: 1.6,
                            color: AppColors.textButton,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class DateWidget extends StatelessWidget {
  final BoardModel board;
  const DateWidget({super.key, required this.board});

  String formatDate() {
    DateTime dateTime = board.boardName!.timestamp!.first.toDate();
    return DateFormat("d MMM y").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Creation Date: ',
        style: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: FontConstants.fontSize012.h,
          color: themeController.currentTheme == AppColors.lightTheme
              ? AppColors.dotBlack
              : AppColors.colorWhiteDark,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: formatDate(),
            style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize012.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}
