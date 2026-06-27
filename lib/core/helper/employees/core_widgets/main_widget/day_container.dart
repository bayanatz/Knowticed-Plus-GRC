// Date Created :22/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :22/November/2023
// Objectives: this is a widget to customize day container in the meetings screen
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/title_time_meeting.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:get/get.dart';


import 'package:demo_app/core/theme/app_font_size.dart';

class DayContainer extends StatefulWidget {
  const DayContainer({
    super.key,
    required this.isToday,
    required this.dayNumber,
    required this.meetings,
    required this.dayLetter,
  });
  final bool isToday;
  final int dayNumber;
  final List<Meeting> meetings;
  final String dayLetter;

  @override
  State<DayContainer> createState() => _DayContainerState();
}

class _DayContainerState extends State<DayContainer> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 0.015.h, horizontal: isPortrait ? 0.0.w : 0.015.w),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                widget.isToday
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.012.h, horizontal: 0.01.w),
                          child: Text(
                            "Today".tr,
                            style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: isTablet
                                    ? isPortrait
                                        ? FontConstants.fontSize014.h
                                        : FontConstants.fontSize011.w
                                    : FontConstants.fontSize016.h,
                                fontWeight: FontWeight.w500,
                                color: AppColors.colorWhite),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                Text(
                  widget.dayLetter.tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? isPortrait
                            ? FontConstants.fontSize045.h
                            : FontConstants.fontSize043.w
                        : FontConstants.fontSize050.h,
                    fontWeight: FontWeight.w600,
                    color: widget.isToday
                        ? AppColors.signOut
                        : Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
                Text(
                  "${widget.dayNumber} ${widget.dayNumber > 3 ? 'th' : widget.dayNumber == 3 ? 'rd' : widget.dayNumber == 2 ? 'nd' : 'st'}",
                  textDirection: Get.locale.toString().contains('en')
                      ? null
                      : TextDirection.ltr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? isPortrait
                            ? FontConstants.fontSize016.h
                            : FontConstants.fontSize014.w
                        : FontConstants.fontSize016.h,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.scrim,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitleTimeColumn(
                    title: widget.meetings[0].meetingName,
                    startTime: widget.meetings[0].startTime,
                    endTime: widget.meetings[0].endTime),
                TitleTimeColumn(
                    title: widget.meetings[1].meetingName,
                    startTime: widget.meetings[1].startTime,
                    endTime: widget.meetings[1].endTime),
                widget.isToday
                    ? TitleTimeColumn(
                        title: widget.meetings[2].meetingName,
                        startTime: widget.meetings[2].startTime,
                        endTime: widget.meetings[2].endTime,
                        soon: true,
                      )
                    : const SizedBox.shrink()
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Meeting {
  final String meetingName;
  final String startTime;
  final String endTime;
  final bool isSoon;
  Meeting(
      {required this.meetingName,
      required this.startTime,
      required this.endTime,
      required this.isSoon});
}

class DayData {
  final bool isToday;
  final int dayNumber;
  final String dayLetter;
  final List<Meeting> meetingsData;

  DayData(
      {required this.isToday,
      required this.dayNumber,
      required this.dayLetter,
      required this.meetingsData});
}
