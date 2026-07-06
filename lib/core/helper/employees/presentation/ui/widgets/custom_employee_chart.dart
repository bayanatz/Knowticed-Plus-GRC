// ignore_for_file: unrelated_type_equality_checks, sized_box_for_whitespace, unused_local_variable
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/widgets/custom_chart_data.dart';
import 'package:demo_app/core/helper/employees/widgets/custom_chart_values.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

//Date Created :5/September/2023
// Developer Name : Mazen shabaan
//App Version : Version Mobile
// Date of Last Edit :28/Novmember/2023 by Bassem
// Objectives: this class created to Customize the chart widget in the employee screen

class CustomEmployeeChartContainer extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<String> texts;
  final List<String> values;
  final List<String>? mins;
  final double width;
  final double height;
  final double textSizeTexts;
  final double textSizeValues;
  final double widthDiff;
  final bool show;
  final bool isTransparent;
  final double textwidth;
  final bool detailsProgress;
  final bool isSmall;
  final bool isHorizontal;
  final bool isExpandedChart;
  final bool isEmployeeChart;

  const CustomEmployeeChartContainer({
    required this.title,
    required this.imagePath,
    required this.texts,
    required this.values,
    this.mins,
    required this.width,
    this.height = 0.300,
    this.textSizeTexts = 0.023,
    this.textSizeValues = 0.021,
    this.widthDiff = 0.008,
    this.textwidth = 0.16,
    this.show = true,
    this.isExpandedChart = false,
    this.isEmployeeChart = false,
    this.isSmall = false,
    this.detailsProgress = false,
    this.isTransparent = false,
    this.isHorizontal = false,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomEmployeeChartContainer> createState() =>
      _CustomEmployeeChartContainerState();
}

class _CustomEmployeeChartContainerState
    extends State<CustomEmployeeChartContainer> {
  int calculateSum(List<String>? values) {
    int sum = 0;
    if (values != null) {
      for (int i = 0; i < values.length; i++) {
        sum += int.parse(values[i]);
      }
    }
    return sum;
  }

  List<int> calculateHoursAndMinutes(List<String>? values, List<String>? mins) {
    int totalMinutes = 0;

    if (mins != null) {
      for (int i = 0; i < mins.length; i++) {
        totalMinutes += int.parse(mins[i]);
      }
    }

    int additionalHours = totalMinutes ~/ 60; // Calculate the additional hours
    int remainingMinutes = totalMinutes % 60; // Calculate the remaining minutes

    int totalHours = 0;
    if (values != null) {
      for (int i = 0; i < values.length; i++) {
        totalHours += int.parse(values[i]);
      }
    }

    // Add the additional hours to the existing total hours
    totalHours += additionalHours;

    return [totalHours, remainingMinutes];
  }

  final List<Color> customColors = [
    AppColors.signOut,
    AppColors.colorGrey,
    AppColors.lightPrimary,
    AppColors.colorGreydark,
    AppColors.colorLightGrey,
    AppColors.colorWhiteDark,
    AppColors.greyDark,
    AppColors.colorDarkGrey,
  ];
  //AppColors.colorGreydark,


  @override
  Widget build(BuildContext context) {
    int totalSum = calculateSum(widget.values);
    // String simplifiedSum = simplifyNumber(totalSum);

    List<int> hoursAndMinutes =
        calculateHoursAndMinutes(widget.values, widget.mins);
    int totalHours = hoursAndMinutes[0];
    int totalMinutes = hoursAndMinutes[1];

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final ThemeController themeController = Get.put(ThemeController());
    List<ChartData> data = [];
    for (int i = 0; i < widget.texts.length; i++) {
      data.add(ChartData(widget.texts[i], double.parse(widget.values[i])));
    }
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Container(
      width: widget.width,
      height: widget.height.h,
      decoration: BoxDecoration(
        color: widget.isTransparent && isTablet == false
            ? Theme.of(context).colorScheme.inversePrimary
            : Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(9),
        boxShadow: themeController.currentTheme == AppColors.lightTheme
            ? [
                if (widget.isTransparent == false)
                  BoxShadow(
                    color: AppColors.colorGrey.withOpacity(0.2),
                    blurRadius: 18,
                  ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                bottom: 0.02.h,
                top: 0.01.h,
                right: isPortrait ? 0.015.h : 0.02.h,
                left: isPortrait ? 0.015.h : 0.02.h),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.bubbleColor,
                  radius: isTablet
                      ? isPortrait
                          ? 0.015.h
                          : 0.02.h
                      : 0.015.h,
                  child: SvgPicture.asset(
                    widget.imagePath,
                    height: isTablet ? (isPortrait ? 0.02.h : 0.025.h) : 0.02.h,
                    color: AppColors.textButton,
                  ),
                ),
                SizedBox(width: 0.01.h),
                Text(
                  widget.title.tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isPortrait
                          ? FontConstants.fontSize018.h
                          : FontConstants.fontSize022.h,
                      color:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorBlack
                              : AppColors.colorWhiteDark,
                      fontWeight: FontWeight.w600,
                      height: isPortrait ? 2 : 0.002.h),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  //        color: Colors.amber,
                  height: isPortrait ? 0.19.h : 0.24.h,
                  width: isTablet
                      ? isPortrait
                          ? 0.15.w
                          : 0.11.w
                      : 0.45.w,
                  child: SfCircularChart(
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(widget: SizedBox())
                    ],
                    series: <CircularSeries>[
                      PieSeries<ChartData, String>(
                        dataSource: data,
                        xValueMapper: (ChartData info, _) => info.text,
                        yValueMapper: (ChartData info, _) => info.values,
                        pointColorMapper: (ChartData info, int index) {
                          if (index >= 0 && index < customColors.length) {
                            return customColors[index];
                          }
                          return Colors.grey;
                        },
                        dataLabelSettings: DataLabelSettings(
                          isVisible: false,
                          labelPosition: ChartDataLabelPosition.inside,
                          textStyle: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize016.h,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        radius: isTablet ? '94%' : '80%',
                        explodeOffset: isTablet ? '0%' : '3%',
                        explode: false,
                        explodeAll: false,
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                    ),
                  )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0;
                              i < widget.values.length && i < 4;
                              i++)
                            Padding(
                              padding: EdgeInsets.only(bottom: 0.015.h),
                              child: Row(
                                children: [
                                  CustomChartDataRow(
                                      isSmall: widget.isSmall,
                                      dataColor: customColors[i],
                                      textData: widget.texts[i],
                                      isHorizontal: widget.isHorizontal),
                                  CustomChartDataValues(
                                    valueText: widget.values[i],
                                    detailsProgress: widget.detailsProgress,
                                    isHorizontal: widget.isHorizontal,
                                    isSmall: widget.isSmall,
                                  )
                                ],
                              ),
                            ),
                          if (widget.isExpandedChart == false)
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 0.005.h),
                                  child: Icon(Icons.square,
                                      size: isTablet
                                          ? (isPortrait ? 0.013.h : 0.018.h)
                                          : 0.018.h,
                                      color:
                                          Colors.transparent //customColors[i],
                                      ),
                                ),
                                isTablet
                                    ? SizedBox(width: 0.01.w)
                                    : SizedBox(width: 0.0.w),
                                Container(
                                  //   color: Colors.amber,
                                  width: isTablet
                                      ? (isPortrait ? 0.12.w : 0.1.w)
                                      : 0.25.w, //widget.textwidth.w,
                                  child: Text(
                                    "Total".tr, // widget.texts[i].tr,
                                    style: AppFontStyle.cairoRegularStyle
                                        .copyWith(
                                            fontSize: isPortrait
                                                ? FontConstants.fontSize016.h
                                                : FontConstants.fontSize020.h,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                            fontWeight: FontWeight.w600,
                                            height: 0.001.h),
                                  ),
                                ),
                                isTablet
                                    ? SizedBox(width: 0.025.h)
                                    : Icon(
                                        Icons.circle,
                                        size: 0.012.h,
                                        color: Colors.transparent,
                                      ),
                                isTablet
                                    ? const SizedBox.shrink()
                                    : SizedBox(width: 0.01.w),
                                Text(
                                  Get.locale.toString().contains("en")
                                      ? "$totalSum"
                                      : convertNumberToArabic(
                                          "$totalSum"), //widget.values[i] + ' Projects'.tr,
                                  style:
                                      AppFontStyle.cairoRegularStyle.copyWith(
                                    fontSize: isPortrait
                                        ? FontConstants.fontSize016.h
                                        : FontConstants.fontSize020.h,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                    //height: 0.0015.h
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (widget.isExpandedChart == true)
                        Column(
                          children: [
                            for (int i = 4; i < widget.values.length; i++)
                              Padding(
                                padding: EdgeInsets.only(bottom: 0.015.h),
                                child: Row(
                                  children: [
                                    CustomChartDataRow(
                                        isSmall: widget.isSmall,
                                        dataColor: customColors[i],
                                        textData: widget.texts[i],
                                        isHorizontal: widget.isHorizontal),
                                    CustomChartDataValues(
                                      valueText: widget.values[i],
                                      detailsProgress: widget.detailsProgress,
                                      isHorizontal: widget.isHorizontal,
                                      isSmall: widget.isSmall,
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                  if (widget.isExpandedChart == true)
                    Padding(
                      padding: EdgeInsets.only(top: 0.015.h),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 0.01.h),
                            child: Icon(Icons.square,
                                size: isTablet
                                    ? (isPortrait ? 0.013.h : 0.018.h)
                                    : 0.018.h,
                                color: Colors.transparent //customColors[i],
                                ),
                          ),
                          isTablet
                              ? SizedBox(width: 0.01.w)
                              : SizedBox.shrink(),
                          Container(
                            //        color: Colors.amber,
                            width: isTablet
                                ? (isPortrait ? 0.12.w : 0.1.w)
                                : 0.25.w,
                            child: Text(
                              "Total".tr, // widget.texts[i].tr,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isPortrait
                                      ? FontConstants.fontSize016.h
                                      : FontConstants.fontSize020.h,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                  fontWeight: FontWeight.w600,
                                  height: 0.001.h),
                            ),
                          ),
                          isTablet
                              ? SizedBox(width: 0.025.h)
                              : Icon(
                                  Icons.circle,
                                  size: 0.012.h,
                                  color: Colors.transparent,
                                ),
                          isTablet
                              ? const SizedBox.shrink()
                              : SizedBox(width: 0.01.w),
                          Text(
                            Get.locale.toString().contains("en")
                                ? "$totalSum"
                                : convertNumberToArabic(
                                    "$totalSum"), //widget.values[i] + ' Projects'.tr,
                            style: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: isPortrait
                                  ? FontConstants.fontSize016.h
                                  : FontConstants.fontSize020.h,
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              fontWeight: FontWeight.w600,
                              //height: 0.0015.h
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.text, this.values);

  final String text;
  final double values;
}
