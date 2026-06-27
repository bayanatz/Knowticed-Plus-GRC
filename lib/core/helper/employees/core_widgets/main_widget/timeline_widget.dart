// Date Created :22/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :22/November/2023
// Objectives: this is a widget to customize widget that ocntain time line of the day in meetings screen
import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/create_edit_meeting_dialogue.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/day_container.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/profiles_circles.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/title_time_meeting.dart';

import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';

import 'package:demo_app/core/theme/app_font_size.dart';

class TimelineWidget extends StatefulWidget {
  final List<Meeting> data;

  const TimelineWidget({super.key, required this.data});

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

final HapticController hapticController = Get.put(HapticController());

class _TimelineWidgetState extends State<TimelineWidget> {
  @override
  Widget build(BuildContext context) {
    bool isHappening = false;
    final HapticController hapticController = Get.put(HapticController());
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.data.map((entry) {
        final start = entry.startTime;
        final end = entry.endTime;
        final hasEvent = true;
        isHappening = entry.isSoon;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 0.012.h),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0.01.h),
                    child: Text(
                      start.endsWith("AM")
                          ? start.replaceAll("AM", "")
                          : start.replaceAll("PM", ""),
                      style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize:
                            isPortrait ? FontConstants.fontSize014.h : 0.025.h,
                        color: Theme.of(context).colorScheme.scrim,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (hasEvent)
                    Padding(
                      padding: EdgeInsets.only(top: 0.152.h),
                      child: Text(
                        end.endsWith("AM")
                            ? end.replaceAll("AM", "")
                            : end.replaceAll("PM", ""),
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: isPortrait
                              ? FontConstants.fontSize014.h
                              : 0.025.h,
                          color: Theme.of(context).colorScheme.scrim,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.015.w),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isHappening
                          ? Theme.of(context).colorScheme.onTertiaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 0.01.w, vertical: 0.01.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.01.h,
                                left: Get.locale.toString().contains('en')
                                    ? 0.025.w
                                    : 0.005.w,
                                right: Get.locale.toString().contains('en')
                                    ? 0.005.w
                                    : 0.025.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: 1.25,
                                  child: TitleTimeColumn(
                                    title: entry.meetingName,
                                    startTime: start,
                                    endTime: end,
                                    soonListMeetings:
                                        isHappening ? true : false,
                                  ),
                                ),
                                isHappening
                                    ? GestureDetector(
                                        onTapUp: (details) {
                                          hapticController
                                              .triggerHapticFeedback(
                                                  vibration:
                                                      VibrateType.lightImpact,
                                                  hapticFeedback: HapticFeedback
                                                      .lightImpact);
                                          final iconPosition =
                                              details.globalPosition;
                                          _showSortMenu(context, iconPosition);
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          width: 0.03.w,
                                          height: 0.025.w,
                                          child: Transform.scale(
                                            scale: 0.65,
                                            child: SvgPicture.asset(
                                              'assets/icons/threeDots.svg',
                                              // ignore: deprecated_member_use
                                              color: AppColors.colorWhite,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.06.h,
                                right: Get.locale.toString().contains('en')
                                    ? 0.015.w
                                    : 0,
                                left: Get.locale.toString().contains('en')
                                    ? 0
                                    : 0.015.w),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 0.08.w,
                                  height: 0.05.h,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        bottom: 0.01.h,
                                        left: 0.01.h,
                                        child: const ProfilesCircles(
                                            imageUrl:
                                                "assets/images/profile3.png"),
                                      ),
                                      Positioned(
                                        bottom: 0.01.h,
                                        left: 0.03.h,
                                        child: const ProfilesCircles(
                                            imageUrl:
                                                "assets/images/profile1.png"),
                                      ),
                                      Positioned(
                                          bottom: 0.01.h,
                                          left: 0.05.h,
                                          child: const ProfilesCircles(
                                              imageUrl:
                                                  "assets/images/profile3.png")),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "1h".tr,
                                  style: AppFontStyle.cairoRegularStyle
                                      .copyWith(
                                          fontSize: FontConstants.fontSize010.w,
                                          fontWeight: FontWeight.w600,
                                          color: isHappening
                                              ? AppColors.colorWhite
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .inverseSurface),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  ProgressService? selectedOption;
  bool isSortSelected = false;

  void _showSortMenu(BuildContext context, Offset iconPosition) async {
    final List<ProgressService> sortOptions = [
      ProgressService.Edit,
      ProgressService.Reschedule,
      ProgressService.cancel
    ];
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    // Calculate the position of the menu relative to the three dots icon
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final double menuOffsetX = iconPosition.dx - (isTablet ? -9.0 : -11);
    final double menuOffsetY = iconPosition.dy - (-7.0);

    final RelativeRect position = RelativeRect.fromLTRB(
      menuOffsetX,
      menuOffsetY,
      overlay.size.width - menuOffsetX,
      overlay.size.height,
    );

    selectedOption = await showMenu(
      context: context,
      position: position,
      color: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      items: sortOptions.map((option) {
        final orientation = MediaQuery.of(context).orientation;
        return PopupMenuItem<ProgressService>(
          padding: EdgeInsets.symmetric(horizontal: 0.01.w),
          height: isTablet
              ? (orientation == Orientation.portrait ? 0.045.h : 0.06.h)
              : 0.035.h,
          value: option,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isTablet ? 0.005.w : 0.03.w),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.5,
                    child: SvgPicture.asset(
                      _getSortOptionIcon(option),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left:
                            Get.locale.toString().contains('en') ? 0.015.w : 0,
                        right:
                            Get.locale.toString().contains('en') ? 0 : 0.015.w),
                    child: Text(
                      _getSortOptionLabel(option),
                      style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: isPortrait
                            ? FontConstants.fontSize014.h
                            : FontConstants.fontSize015.w,
                        color: Theme.of(context).colorScheme.scrim,
                        height: 0.0022.h,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );

    if (selectedOption != null) {
      // Trigger haptic feedback
      hapticController.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact);
      switch (selectedOption!) {
        case ProgressService.cancel:
          // ignore: use_build_context_synchronously
          _showCancelAJobDialog(context);
          break;
        case ProgressService.Reschedule:
          // ignore: use_build_context_synchronously
          _showRenegotiateDialog(context);
          break;
        case ProgressService.Edit:
          // ignore: use_build_context_synchronously
          _showEditDialog(context);
          break;
      }
    }
  }

  String _getSortOptionLabel(ProgressService option) {
    switch (option) {
      case ProgressService.Edit:
        return "Edit".tr;
      case ProgressService.Reschedule:
        return "Reschedule".tr;
      case ProgressService.cancel:
        return "Cancel".tr;
      default:
        return "";
    }
  }

  String _getSortOptionIcon(ProgressService option) {
    switch (option) {
      case ProgressService.Edit:
        return "assets/images/edit_pen.svg";
      case ProgressService.Reschedule:
        return "assets/images/circle_res.svg";
      case ProgressService.cancel:
        return "assets/images/cancel_cir.svg";
      default:
        return "";
    }
  }
}

// Function to show the "Cancel A Job" dialog
void _showCancelAJobDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CreateEditMeetingDialouge(
        title: "Cancel Meeting",
        isCancel: true,
        iconUrl: "assets/images/cancel_meeting.svg",
      );
    },
  );
}

// Function to show the "Renegotiate" dialog
void _showRenegotiateDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CreateEditMeetingDialouge(
        title: "Reschedule Meeting",
        isReschedule: true,
        iconUrl: "assets/images/resc_meeting.svg",
      );
    },
  );
}

void _showEditDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CreateEditMeetingDialouge(
        title: "Edit Meeting",
        iconUrl: "assets/images/edit_meeting.svg",
      );
    },
  );
}

enum ProgressService {
  // ignore: constant_identifier_names
  Edit,
  // ignore: constant_identifier_names
  Reschedule,
  cancel,
}
