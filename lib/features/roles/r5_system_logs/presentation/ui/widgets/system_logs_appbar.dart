/// ************************ FILE INFO ******************** ///
/// FILE NAME: system_logs_appbar.dart
/// PURPOSE: this file contains the system logs appbar.
/// Author: Amr Mesbah
/// REFACTORED AT: 2/2/2025

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/custom/35-custom_search_widget_custom.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';

import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/ui/widgets/download_logs_dialog.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/ui/widgets/filter_dialog.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/helper/main_helper/icon_size.dart';
import 'package:grc_module/features/roles/r5_system_logs/data/models/system_logs_constants.dart';

import 'package:grc_module/core/custom/1-custom_dropdwon.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
class SystemLogsAppBar extends StatefulWidget {
  SystemLogsAppBar();

  bool isFilterDataShow = false;
  String? delayValue;
  String? roleValue = Get.find<SystemLogsController>().status;

  @override
  State<SystemLogsAppBar> createState() => _SystemLogsAppBarState();
}

class _SystemLogsAppBarState extends State<SystemLogsAppBar> {
  final HapticController hapticController = Get.put(HapticController());
  SystemLogsController systemLogsController = Get.find();

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return BlocBuilder<SystemLogsController, SystemLogsState>(
        bloc: Get.find<SystemLogsController>(),
        builder: (context, state) {
      final controller = Get.find<SystemLogsController>();
      return Padding(
        padding: EdgeInsets.only(bottom: isPortrait ? 0.01.h : 0.02.h),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: isPortrait
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: <Widget>[


              AppSearchTextField(controller: controller.searchController, onChanged: (value) {
        controller.searchAndFilterLogs();
        },),

              isMobile ? SizedBox(width: 10.w) : SizedBox(),

             isMobile ? GestureDetector(
               onTap: () {
                 hapticController.triggerHapticFeedback(
                     vibration: VibrateType.lightImpact,
                     hapticFeedback: HapticFeedback.lightImpact);
                 setState(() {
                   widget.isFilterDataShow = !widget.isFilterDataShow;
                 });
                 showDialog(
                   context: context,
                   builder: (BuildContext context) {
                     return FilterDialog(
                       employessScreen: true,
                       roleValue: widget.roleValue,
                       delayValue: widget.delayValue,
                       dropDownItems: [],
                     );
                   },
                 );
               },
               child: Container(
                 width: 38.sp,
                 height: 38.sp,
                 decoration: BoxDecoration(
                     color: lightMode ? AppColors.white : AppColors.chatBackground,
                     borderRadius: BorderRadius.circular(8.r)
                 ),
                 child: SizedBox(
                   child: CustomSvgImage(
                     assetPath: "assets/icons_assets/main_icons_assets/filter_sliders.svg",
                     width: 10.w,
                     height: 10.h,
                     fit: BoxFit.scaleDown,
                     color: lightMode ? AppColors.blackButton : AppColors.white,
                   ),
                 ),
               ),
             ) :



             Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isPortrait ? 0.015.w : 0.015.w),
                child: GestureDetector(
                  onTap: () {
                    hapticController.triggerHapticFeedback(
                        vibration: VibrateType.lightImpact,
                        hapticFeedback: HapticFeedback.lightImpact);
                    setState(() {
                      widget.isFilterDataShow = !widget.isFilterDataShow;
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FilterDialog(
                          employessScreen: true,
                          roleValue: widget.roleValue,
                          delayValue: widget.delayValue,
                          dropDownItems: [],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: isPortrait ? 0.04.h : 0.055.h,
                    width: isPortrait ? 0.13.w : 0.1.w,
                    decoration: BoxDecoration(
                        color: systemLogsController.isFilter
                            ? AppColors.signOut
                            : Theme.of(context).colorScheme.inversePrimary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.transparent)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Transform.scale(
                          scale: isDesktop
                              ? IconSizeHelper.getIconSize(context)
                              : 1.3,
                          child: CustomSvgImage(assetPath: 
                              "assets/icons_assets/main_icons_assets/filter_sliders.svg",
                              color: widget.isFilterDataShow
                                  ? AppColors.textButton
                                  : Theme.of(context).colorScheme.scrim),
                        ),
                        Text(
                          S.of(context).Filter,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: isPortrait
                                  ? FontConstants.fontSize024.w
                                  : FontConstants.fontSize016.w,
                              fontWeight: FontWeight.w500,
                              height: isPortrait ? 1.6 : 1.8,
                              color: widget.isFilterDataShow
                                  ? AppColors.textButton
                                  : Theme.of(context).colorScheme.scrim),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              isMobile ? SizedBox(width: 10.w) : SizedBox(),











             isMobile ? SizedBox(): CustomDropdown<String>(
                hint: S.of(context).Sort,
                value: controller.sortValue,
                fillColor: Theme.of(context).colorScheme.inversePrimary,
                itemHeight: isTablet
                    ? isPortrait
                        ? 0.04.h
                        : 0.055.h
                    : 0.04.h,
                items: SystemLogsConstants.sortListInArabic
                    .map((e) => DropdownItem<String>(
                          value: e,
                          label: e,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    controller.sortValue = value;
                    controller.sortLogs(Get.locale!.toString().contains('en')
                        ? value
                        : SystemLogsConstants.sortList[SystemLogsConstants
                            .sortListInArabic
                            .indexOf(value)]);
                  });
                },
              ),

              isMobile ? GestureDetector(
                onTap: (){},
                child: Container(
                  width: 38.sp,
                  height: 38.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r)
                  ),
                  child: SizedBox(
                    child: CustomSvgImage(
                      assetPath: "assets/icons_assets/main_icons_assets/export_arrow.svg",
                      width: 10.w,
                      height: 10.h,
                      fit: BoxFit.scaleDown,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              ) : Padding(
                padding: EdgeInsets.only(
                    left: Get.locale.toString().contains('en') ? 0.015.w : 0,
                    right: Get.locale.toString().contains('en') ? 0 : 0.015.w),
                child: SizedBox(
                  height: (isPortrait ? 0.04.h : 0.055.h),
                  child: customButton(
                    function: () async {
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return SystemLogsDownloadDialog();
                          });
                    },
                    title: S.of(context).export,
                    color: AppColors.signOut,
                  ),
                ),
              )
            ],
          ),
      );
    });
  }
}
