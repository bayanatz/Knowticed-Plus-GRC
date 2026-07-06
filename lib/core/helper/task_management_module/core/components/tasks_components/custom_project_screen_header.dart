import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/invited_members_screen.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:page_transition/page_transition.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drawer.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

class ProjectHeader extends StatefulWidget {
  final String projectName;
  final VoidCallback onPressed;
  final BoardModel boardModel;
  final List<String> membersImages;
  final int allMembersNum;

  const ProjectHeader({
    super.key,
    required this.projectName,
    required this.boardModel,
    required this.onPressed,
    required this.membersImages,
    required this.allMembersNum,
  });

  @override
  State<ProjectHeader> createState() => _ProjectHeaderState();
}

final HapticController hapticController = Get.put(HapticController());

class _ProjectHeaderState extends State<ProjectHeader> {
  TaskDetailsController tController = Get.find();

  void invitedMembersPage() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: CustomDrawer(
          initialIndex: 1,
          screens: [
            Container(),
            InvitedMembersScreen(
              boardModel: widget.boardModel,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    //images=widget.membersImages;
    //images=[];
    // getAllMembersNum();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double? bottomHeight = orientation ? null : 0.007.h;
    double? topHeight = !orientation ? null : 0.06.h;
    TextStyle breadCrumbsTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: orientation
          ? FontConstants.fontSize018.h
          : FontConstants.fontSize025.h,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.ellipsis,
      color: Theme.of(context).colorScheme.inverseSurface,
      height: orientation ? 1.6 : 0.002.h,
    );

    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.lightImpact,
                            hapticFeedback: HapticFeedback.lightImpact);

                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: CustomDrawer(
                              initialIndex: 1,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Board".tr,
                        style: breadCrumbsTextStyle,
                      ),
                    ),
                    SizedBox(
                      width: orientation ? 0.005.w : 0.015.h,
                    ),
                    SvgPicture.asset(
                      matchTextDirection: Get.locale?.languageCode == 'ar',
                      'assets/icons_assets/main_icons_assets/images_arrow.svg',
                      height: orientation ? 0.025.h : 0.04.h,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                    SizedBox(
                      width: orientation ? 0.005.w : 0.015.h,
                    ),
                    Text(
                      widget.projectName.tr.capitalize as String,
                      style: breadCrumbsTextStyle,
                    ),
                    // if (orientation) const Spacer(),
                    // if (orientation)
                    //   Padding(
                    //     padding: EdgeInsets.only(
                    //         top: 0.02.h,
                    //         left: Get.locale.toString().contains('ar')
                    //             ? 0.02.h
                    //             : 0,
                    //         right: Get.locale.toString().contains('en')
                    //             ? 0.02.h
                    //             : 0),
                    //     child: GestureDetector(
                    //       onTap: widget.onPressed,
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(8),
                    //             color: AppColors.signOut),
                    //         padding: EdgeInsets.all(0.012.h),
                    //         child: SvgPicture.asset(
                    //           height: 0.02.h,
                    //           'assets/icons_assets/task_assets/shareBoardIcon.svg',
                    //           color: AppColors.textButton,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
                // orientation
                //     ? const SizedBox.shrink()
                //     : Padding(
                //         padding: EdgeInsets.only(
                //             top: 0.02.h,
                //             left: Get.locale.toString().contains('ar')
                //                 ? 0.02.h
                //                 : 0,
                //             right: Get.locale.toString().contains('en')
                //                 ? 0.02.h
                //                 : 0),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text(
                //               widget.projectName.tr.capitalize as String,
                //               style: AppFontStyle.cairoRegularStyle.copyWith(
                //                 fontSize: FontConstants.fontSize045.h,
                //                 color: themeController.currentTheme ==
                //                         AppColors.lightTheme
                //                     ? AppColors.colorBlack
                //                     : AppColors.colorWhiteDark,
                //                 fontWeight: FontWeight.w600,
                //               ),
                //             ),
                //             const Spacer(),
                //             if (widget.allMembersNum != 0)
                //               Text(
                //                 " +${widget.allMembersNum}",
                //                 style: AppFontStyle.cairoRegularStyle.copyWith(
                //                   fontSize: FontConstants.fontSize029.h,
                //                   fontWeight: FontWeight.w600,
                //                   letterSpacing: 1.1,
                //                   color: AppColors.colorDarkGrey,
                //                 ),
                //               ),
                //             SizedBox(
                //               width: 0.02.w,
                //             ),
                //             GestureDetector(
                //               onTap: widget.onPressed,
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                     borderRadius: BorderRadius.circular(8),
                //                     color: AppColors.signOut),
                //                 padding: EdgeInsets.all(0.012.h),
                //                 child: SvgPicture.asset(
                //                   height: 0.03.h,
                //                   'assets/icons_assets/task_assets/shareBoardIcon.svg',
                //                   color: AppColors.textButton,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
              ],
            ),
            //   if (controller.images.isNotEmpty && !orientation)
            //     Positioned(
            //       top: topHeight,
            //       bottom: bottomHeight,
            //       right: Get.locale.toString().contains('en') ? 0.35.h : null,
            //       left: Get.locale.toString().contains('ar') ? 0.35.h : null,
            //       child: GestureDetector(
            //         onTap: () {
            //           invitedMembersPage();
            //         },
            //         child: Container(
            //           width: 0.05.h,
            //           height: 0.05.h,
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: AppColors.lightPrimary,
            //           ),
            //           child: Center(
            //             child: controller.images[0].isURL
            //                 ? CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage:
            //                         NetworkImage(controller.images[0]),
            //                   )
            //                 : CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage: appImageProvider(controller.images[0]),
            //                   ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   if (controller.images.length > 1 && !orientation)
            //     Positioned(
            //       top: topHeight,
            //       bottom: bottomHeight,
            //       right: Get.locale.toString().contains('en') ? 0.31.h : null,
            //       left: Get.locale.toString().contains('ar') ? 0.31.h : null,
            //       child: GestureDetector(
            //         onTap: () {
            //           invitedMembersPage();
            //         },
            //         child: Container(
            //           width: 0.05.h,
            //           height: 0.05.h,
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: AppColors.lightPrimary,
            //           ),
            //           child: Center(
            //             child: controller.images[1].isURL
            //                 ? CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage:
            //                         NetworkImage(controller.images[1]),
            //                   )
            //                 : CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage: appImageProvider(controller.images[1]),
            //                   ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   if (controller.images.length > 2 && !orientation)
            //     Positioned(
            //       top: topHeight,
            //       bottom: bottomHeight,
            //       right: Get.locale.toString().contains('en') ? 0.27.h : null,
            //       left: Get.locale.toString().contains('ar') ? 0.27.h : null,
            //       child: GestureDetector(
            //         onTap: () {
            //           invitedMembersPage();
            //         },
            //         child: Container(
            //           width: 0.05.h,
            //           height: 0.05.h,
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: AppColors.lightPrimary,
            //           ),
            //           child: Center(
            //             child: controller.images[2].isURL
            //                 ? CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage:
            //                         NetworkImage(controller.images[2]),
            //                   )
            //                 : CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage: appImageProvider(controller.images[2]),
            //                   ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   if (controller.images.length > 3 && !orientation)
            //     Positioned(
            //       top: topHeight,
            //       bottom: bottomHeight,
            //       right: Get.locale.toString().contains('en') ? 0.23.h : null,
            //       left: Get.locale.toString().contains('ar') ? 0.23.h : null,
            //       child: GestureDetector(
            //         onTap: () {
            //           invitedMembersPage();
            //         },
            //         child: Container(
            //           width: 0.05.h,
            //           height: 0.05.h,
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: AppColors.lightPrimary,
            //           ),
            //           child: Center(
            //             child: controller.images[3].isURL
            //                 ? CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage:
            //                         NetworkImage(controller.images[3]),
            //                   )
            //                 : CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage: appImageProvider(controller.images[3]),
            //                   ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   if (controller.images.length > 4 && !orientation)
            //     Positioned(
            //       top: topHeight,
            //       bottom: bottomHeight,
            //       right: Get.locale.toString().contains('en') ? 0.19.h : null,
            //       left: Get.locale.toString().contains('ar') ? 0.19.h : null,
            //       child: GestureDetector(
            //         onTap: () {
            //           invitedMembersPage();
            //         },
            //         child: Container(
            //           width: 0.05.h,
            //           height: 0.05.h,
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: AppColors.lightPrimary,
            //           ),
            //           child: Center(
            //             child: controller.images[4].isURL
            //                 ? CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage:
            //                         NetworkImage(controller.images[4]),
            //                   )
            //                 : CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage: appImageProvider(controller.images[4]),
            //                   ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   if (controller.images.length > 5 && !orientation)
            //     Positioned(
            //       top: topHeight,
            //       bottom: bottomHeight,
            //       right: Get.locale.toString().contains('en') ? 0.15.h : null,
            //       left: Get.locale.toString().contains('ar') ? 0.15.h : null,
            //       child: GestureDetector(
            //         onTap: () {
            //           invitedMembersPage();
            //         },
            //         child: Container(
            //           width: 0.05.h,
            //           height: 0.05.h,
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: AppColors.lightPrimary,
            //           ),
            //           child: Center(
            //             child: controller.images[5].isURL
            //                 ? CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage:
            //                         NetworkImage(controller.images[5]),
            //                   )
            //                 : CircleAvatar(
            //                     radius: 0.03.h,
            //                     backgroundImage: appImageProvider(controller.images[5]),
            //                   ),
            //           ),
            //         ),
            //       ),
            //     ),
          ],
        );
      },
    );
  }
}
