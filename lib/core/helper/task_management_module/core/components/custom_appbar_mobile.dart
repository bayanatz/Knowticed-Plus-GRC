// ignore_for_file: unrelated_type_equality_checks
import 'package:demo_app/core/haptic/haptic_controller.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/image_paths.dart';
import 'package:demo_app/features/notification/presentation/controller/notification_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';

//Date:April/3/2023
//by: Bassem Mohamed
//lastUpdate:April/17/2023

// This is a custom app bar widget in Flutter. It is a StatefulWidget widget that
// takes optional parameters: a title (required), an icon and an onPressed function.
// The build method returns a Column widget wrapped in a Padding widget.
// The column contains a logo (loaded from an SVG file), the title, and the optional icon.
// If the icon is not provided, the widget returns an empty SizedBox.
// The logo and text are styled using the theme data provided by the parent widget.
// The .h and .w suffixes used in the SizedBox widgets are likely custom extensions
// to make the widget responsive to the screen size.

class CustomAppBarMobile extends StatefulWidget {
  const CustomAppBarMobile({
    super.key,
    this.title,
    this.isEdit = false,
    this.isHome = false,
    this.isMessage = false,
    this.isYellowContainer = false,
    this.onPressed,
    this.onIconPressed,
    this.imagePath,
    this.showMoreIcon = false,
    this.onTapUp,
    required this.showIcon,
    this.isEmployees = false,
    this.isProject = false,
    this.isStack = false,
    this.stackPhoto,
    this.upPhoto,
  });

  final String? title;
  final String? imagePath;
  final bool showIcon;
  final bool? isEdit;
  final bool? isMessage;
  final bool? isHome;
  final bool? isYellowContainer;
  final bool? showMoreIcon;
  final void Function()? onPressed;
  final void Function()? onIconPressed;
  final Function(TapUpDetails)? onTapUp;
  final bool isEmployees;
  final bool isProject;
  final bool isStack;
  final String? stackPhoto;
  final String? upPhoto;

  @override
  State<CustomAppBarMobile> createState() => _CustomAppBarMobileState();
}

class _CustomAppBarMobileState extends State<CustomAppBarMobile> {
  late String currentImagePath;

  @override
  void initState() {
    super.initState();
    currentImagePath = widget.imagePath ?? 'assets/images/edit.png';
  }

  void _changeImage() {
    setState(() {
      currentImagePath = 'assets/images/other_image.png';
    });
  }

  MainCoreNotificationController appNotificationController =
      Get.put(MainCoreNotificationController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isHome != true)
            SizedBox(
              height: .01.h,
            ),
          if (widget.isHome == true)
            SizedBox(
              height: .014.h,
            ),
          if (widget.isHome == true)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      Get.locale.toString().contains('en') ? 0.04.w : 0.04.w),
              child: Row(
                children: [
                  SizedBox(
                    width: .08.h,
                    height: storage.read('logo') == null ? .06.h : 0.08.h,
                    child: storage.read('logo') == null
                        ? SvgPicture.asset(
                            ImagePaths.getImagePath(context, 'logo'),
                            fit: BoxFit.fill,
                          )
                        : SvgPicture.network(
                            storage.read('logo'),
                            fit: BoxFit.fill,
                          ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // PersistentNavBarNavigator.pushNewScreen(
                      //   context,
                      //   screen: SettingsScreen(),
                      //   withNavBar: false,
                      // );
                    },
                    child: SvgPicture.asset(
                      "assets/icons_assets/main_icons_assets/SettingHome.svg",
                      color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? null
                              : AppColors.colorGreydark,
                    ),
                  ),
                  SizedBox(
                    width: 0.03.w,
                  ),
                  SizedBox(
                    width: 0.03.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      // PersistentNavBarNavigator.pushNewScreen(
                      //   context,
                      //   screen: const NotificationScreenMobile(),
                      //   withNavBar: false,
                      // );
                    },
                    child: StreamBuilder<QuerySnapshot>(
                      stream: appNotificationController
                          .getUnseenNotificationsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SvgPicture.asset(
                            "assets/icons_assets/main_icons_assets/bellIcon.svg",
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? null
                                : AppColors.colorGreydark,
                            fit: BoxFit.fill,
                          );
                        } else if (snapshot.hasError ||
                            snapshot.data?.docs.isEmpty == true) {
                          return SvgPicture.asset(
                            "assets/icons_assets/main_icons_assets/bellIcon.svg",
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? null
                                : AppColors.colorGreydark,
                            fit: BoxFit.fill,
                          );
                        } else {
                          final unseenCount = snapshot.data?.docs.length ?? 0;
                          return Badge(
                            textColor: Colors.white,
                            label: Text(
                              Get.locale.toString().contains('en')
                                  ? '$unseenCount'
                                  : convertNumberToArabic('$unseenCount'),
                            ),
                            largeSize: 16,
                            textStyle: AppFontStyle.cairoRegularStyle.copyWith(
                              height: 1.3,
                              fontSize: FontConstants.fontSize010.h,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                            ),
                            child: SvgPicture.asset(
                              "assets/icons_assets/main_icons_assets/bellIcon.svg",
                              color: themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? null
                                  : AppColors.colorGreydark,
                              fit: BoxFit.fill,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (widget.isMessage == true)
            SizedBox(
              height: .015.h,
            ),
          if (widget.title != null && widget.isMessage == false)
            SizedBox(
              height: .024.h,
            ),
          Padding(
            padding: EdgeInsets.only(
              left: widget.showIcon && Get.locale.toString().contains('en')
                  ? 0.0.w
                  : 0.04.w,
              right: widget.showIcon && Get.locale.toString().contains('ar')
                  ? 0.0.w
                  : 0.04.w,
            ),
            child: Container(
              //     color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: widget.showIcon,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Transform.translate(
                        offset: Offset(-0.005.w, -0.005.h),
                        child: Transform.rotate(
                          angle:
                              Get.locale.toString().contains('ar') ? 3.13 : 0,
                          child: Transform.scale(
                            scale: 0.0013.h,
                            child: SvgPicture.asset(
                              'assets/icons_assets/main_icons_assets/arrowright2.svg',
                              fit: BoxFit.fitWidth,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                  BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.title != null)
                    Expanded(
                      // Use Expanded to occupy available space
                      child: AutoSizeText(
                        widget.title!.tr,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: FontConstants.fontSize029.h,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (widget.title != null && widget.showMoreIcon == true)
                    Container(
                        decoration: BoxDecoration(
                          color: AppColors.signOut,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(0.01.h),
                        child: SvgPicture.asset(
                          "assets/icons_assets/main_icons_assets/blackAddIcon.svg",
                        )),

                  //   if (widget.imagePath != null)
                  // widget.isEmployees
                  //     ? addRoleController.accessTypeByName?.employeeModule
                  //                 ?.granted ==
                  //             true
                  //         ? GestureDetector(
                  //             onTapUp: widget.onTapUp,
                  //             child: Container(
                  //                 decoration: BoxDecoration(
                  //                   color: AppColors.signOut,
                  //                   borderRadius: BorderRadius.circular(8),
                  //                 ),
                  //                 padding: EdgeInsets.all(0.01.h),
                  //                 child: SvgPicture.asset(
                  //                   "assets/icons_assets/main_icons_assets/blackAddIcon.svg",
                  //                   color: AppColors.textButton,
                  //                 )),
                  //           )
                  //         : const SizedBox()
                  //    :
                  widget.isProject
                      ? GestureDetector(
                          onTap: widget.onIconPressed,
                          child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.signOut,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(0.01.h),
                              child: SvgPicture.asset(
                                "assets/icons_assets/main_icons_assets/shareIcon.svg",
                                color: AppColors.textButton,
                              )),
                        )
                      : const SizedBox.shrink()
                  // widget.isStack
                  //     ? GestureDetector(
                  //         onTap: widget.onIconPressed,
                  //         child: Stack(
                  //           children: <Widget>[
                  //             Transform.scale(
                  //               scale: 1,
                  //               child: SvgPicture.asset(
                  //                 widget.stackPhoto!,
                  //                 color: Theme.of(context)
                  //                     .colorScheme
                  //                     .inverseSurface,
                  //               ),
                  //             ),
                  //             Positioned.fill(
                  //               child: Align(
                  //                 alignment: Alignment.topRight,
                  //                 child: Transform.scale(
                  //                   scale: 1,
                  //                   child: CircleAvatar(
                  //                       backgroundColor:
                  //                           AppColors.signOut,
                  //                       radius: 0.01.h,
                  //                       child: SvgPicture.asset(
                  //                         widget.upPhoto!,
                  //                         color: MyThemeData()
                  //                             .contrastColor(),
                  //                         height: 0.012.h,
                  //                       )),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       )
                  //     : GestureDetector(
                  //         onTap: widget.onIconPressed,
                  //         child: SvgPicture.asset(
                  //           widget.imagePath!,
                  //         ),
                  //       ),
                ],
              ),
            ),
          ),
          // if (widget.title != null && widget.isMessage == false && widget.isEdit == false)
          //   SizedBox(
          //     height: .014.h,
          //   ),
        ],
      ),
    );
  }
}
