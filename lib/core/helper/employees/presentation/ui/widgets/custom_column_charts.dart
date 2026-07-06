// ignore_for_file: unrelated_type_equality_checks, sized_box_for_whitespace, unused_local_variable
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/employees/widgets/custom_chart_data.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:demo_app/features/employee/data/models/emplyees_model/new_employee_model.dart';

//Date Created: 5/September/2023
// Developer Name: Mazen shabaan
//App Version: Version Mobile
// Date of Last Edit: Migrated to NewEmployeeModelHistory
// Objectives: Customize the chart widget in the employee screen

class CustomColumnChartContainer extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<String> texts;
  final List<String> values;
  final double width;
  final double height;
  final double textSizeTexts;
  final double textSizeValues;
  final bool isTransparent;
  final bool detailsProgress;
  final bool isSmall;
  final bool isSmallContainer;
  final bool isHorizontal;
  final bool line;

  const CustomColumnChartContainer({
    required this.title,
    required this.imagePath,
    required this.texts,
    required this.values,
    required this.width,
    this.height = 0.300,
    this.textSizeTexts = 0.023,
    this.textSizeValues = 0.021,
    this.isSmall = false,
    this.detailsProgress = false,
    this.isSmallContainer = false,
    this.isTransparent = false,
    this.isHorizontal = false,
    this.line = false,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomColumnChartContainer> createState() =>
      _CustomColumnChartContainerState();
}

EmployeeController addEmployeeController = Get.find();

/// ✅ UPDATED: Convert int timestamp to month name
String? getMonthNameFromTimestamp(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  Map<int, String> monthNames = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };
  return monthNames[dateTime.month];
}

/// ✅ UPDATED: Convert int timestamp to year
String? getYearNameFromTimestamp(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return dateTime.year.toString();
}

List<String> sortedMonths = [];

/// Sort months from current month to the end of the year
List<String> sortMonthsFromCurrentMonth() {
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  DateTime now = DateTime.now();
  int currentMonthIndex = now.month - 1;

  List<String> sortedMonths = months.sublist(currentMonthIndex)
    ..addAll(months.sublist(0, currentMonthIndex));

  return sortedMonths;
}

List<String> sortMonths = sortMonthsFromCurrentMonth();

class _CustomColumnChartContainerState
    extends State<CustomColumnChartContainer> {
  int calculateSum(List<String>? values) {
    int sum = 0;
    if (values != null) {
      for (int i = 0; i < values.length; i++) {
        sum += int.parse(values[i]);
      }
    }
    return sum;
  }

  List<NewEmployeeModelHistory>? employeesWithoutFilter = [];

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

  final List<String> period = [
    'Weekly'.tr,
    'Monthly'.tr,
    'Annually'.tr,
  ];

  String? selectedPeriod = 'Monthly'.tr;

  /// ✅ HELPER: Get current status safely
  String _getCurrentStatus(NewEmployeeModelHistory employee) {
    return employee.status.isNotEmpty ? employee.status.last : '';
  }

  /// ✅ HELPER: Get last timestamp safely
  int _getLastTimestamp(NewEmployeeModelHistory employee) {
    return employee.timestamps.isNotEmpty ? employee.timestamps.last : 0;
  }

  /// ✅ HELPER: Check if employee is active
  bool _isActive(NewEmployeeModelHistory employee) {
    return _getCurrentStatus(employee) == 'active';
  }

  /// ✅ HELPER: Check if employee is not active
  bool _isNotActive(NewEmployeeModelHistory employee) {
    return _getCurrentStatus(employee) != 'active';
  }

  /// ✅ UPDATED: Annual additions chart data
  List<ChartData> get annualAdditions {
    return [
      ChartData(
          (DateTime.now().year - 3).toString(),
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isActive(element) &&
              getYearNameFromTimestamp(_getLastTimestamp(element)) ==
                  (DateTime.now().year - 3).toString())
              .length
              .toDouble()),
      ChartData(
          (DateTime.now().year - 2).toString(),
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isActive(element) &&
              getYearNameFromTimestamp(_getLastTimestamp(element)) ==
                  (DateTime.now().year - 2).toString())
              .length
              .toDouble()),
      ChartData(
          (DateTime.now().year - 1).toString(),
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isActive(element) &&
              getYearNameFromTimestamp(_getLastTimestamp(element)) ==
                  (DateTime.now().year - 1).toString())
              .length
              .toDouble()),
      ChartData(
          DateTime.now().year.toString(),
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isActive(element) &&
              getYearNameFromTimestamp(_getLastTimestamp(element)) ==
                  DateTime.now().year.toString())
              .length
              .toDouble()),
    ];
  }

  /// ✅ UPDATED: Monthly additions chart data
  List<ChartData> get monthlyAdditions {
    return List.generate(12, (index) {
      int monthIndex = index == 11 ? 0 : index + 1;
      return ChartData(
          sortMonths[monthIndex],
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isActive(element) &&
              getMonthNameFromTimestamp(_getLastTimestamp(element)) ==
                  sortMonths[monthIndex])
              .length
              .toDouble());
    });
  }

  /// ✅ UPDATED: Weekly additions chart data
  List<ChartData> get weeklyAdditions {
    return [
      for (int week = 1; week <= 4; week++)
        ChartData(
            '${sortMonths[11]} Week $week',
            addEmployeeController.employeesWithoutFilter!
                .where((element) {
              if (!_isActive(element)) return false;

              int timestamp = _getLastTimestamp(element);
              String month = getMonthNameFromTimestamp(timestamp) ?? '';
              if (month != sortMonths[11]) return false;

              DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
              int day = date.day;

              int startDay = (week - 1) * 7 + 1;
              int endDay = week * 7;

              return day >= startDay && day <= endDay;
            })
                .length
                .toDouble()),

      for (int week = 1; week <= 2; week++)
        ChartData(
            '${sortMonths[0]} Week $week',
            addEmployeeController.employeesWithoutFilter!
                .where((element) {
              if (!_isActive(element)) return false;

              int timestamp = _getLastTimestamp(element);
              String month = getMonthNameFromTimestamp(timestamp) ?? '';
              if (month != sortMonths[0]) return false;

              DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
              int day = date.day;

              int startDay = (week - 1) * 7 + 1;
              int endDay = week * 7;

              return day >= startDay && day <= endDay;
            })
                .length
                .toDouble()),
    ];
  }

  /// ✅ UPDATED: Annual terminations chart data
  List<ChartData> get annualTerminations {
    return [
      ChartData(
          (DateTime.now().year - 3).toString(),
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isNotActive(element) &&
              getYearNameFromTimestamp(_getLastTimestamp(element)) ==
                  (DateTime.now().year - 3).toString())
              .length
              .toDouble()),
      ChartData(
          (DateTime.now().year - 2).toString(),
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isNotActive(element) &&
              getYearNameFromTimestamp(_getLastTimestamp(element)) ==
                  (DateTime.now().year - 2).toString())
              .length
              .toDouble()),
      ChartData(
          (DateTime.now().year - 1).toString(),
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isNotActive(element) &&
              getYearNameFromTimestamp(_getLastTimestamp(element)) ==
                  (DateTime.now().year - 1).toString())
              .length
              .toDouble()),
      ChartData(
          DateTime.now().year.toString(),
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isNotActive(element) &&
              getYearNameFromTimestamp(_getLastTimestamp(element)) ==
                  DateTime.now().year.toString())
              .length
              .toDouble()),
    ];
  }

  /// ✅ UPDATED: Monthly terminations chart data
  List<ChartData> get monthlyTerminations {
    return List.generate(12, (index) {
      int monthIndex = index == 11 ? 0 : index + 1;
      return ChartData(
          sortMonths[monthIndex],
          addEmployeeController.employeesWithoutFilter!
              .where((element) =>
          _isNotActive(element) &&
              getMonthNameFromTimestamp(_getLastTimestamp(element)) ==
                  sortMonths[monthIndex])
              .length
              .toDouble());
    });
  }

  /// ✅ UPDATED: Weekly terminations chart data
  List<ChartData> get weeklyTerminations {
    return [
      for (int week = 1; week <= 4; week++)
        ChartData(
            '${sortMonths[11]} Week $week',
            addEmployeeController.employeesWithoutFilter!
                .where((element) {
              if (!_isNotActive(element)) return false;

              int timestamp = _getLastTimestamp(element);
              String month = getMonthNameFromTimestamp(timestamp) ?? '';
              if (month != sortMonths[11]) return false;

              DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
              int day = date.day;

              int startDay = (week - 1) * 7 + 1;
              int endDay = week * 7;

              return day >= startDay && day <= endDay;
            })
                .length
                .toDouble()),

      for (int week = 1; week <= 2; week++)
        ChartData(
            '${sortMonths[0]} Week $week',
            addEmployeeController.employeesWithoutFilter!
                .where((element) {
              if (!_isNotActive(element)) return false;

              int timestamp = _getLastTimestamp(element);
              String month = getMonthNameFromTimestamp(timestamp) ?? '';
              if (month != sortMonths[0]) return false;

              DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
              int day = date.day;

              int startDay = (week - 1) * 7 + 1;
              int endDay = week * 7;

              return day >= startDay && day <= endDay;
            })
                .length
                .toDouble()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print(sortMonths);
    int totalSum = calculateSum(widget.values);
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
                      height: isTablet ? 1.8 : 0.002.h),
                ),
                Spacer(),
                for (int i = 0; i < widget.values.length; i++)
                  isPortrait
                      ? const SizedBox.shrink()
                      : CustomChartDataRow(
                      isSmall: widget.isSmall,
                      dataColor: customColors[i],
                      textData: widget.texts[i],
                      isSmallContainer: widget.isSmallContainer,
                      isHorizontal: widget.isHorizontal),
                widget.line
                    ? Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: isTablet ? 18 : 0),
                  child: CustomDropdownButton2(
                    buttonPadding:
                    EdgeInsets.symmetric(horizontal: 0.01.h),
                    dropdownPadding:
                    EdgeInsets.symmetric(horizontal: 0.01.h),
                    iconHeight: 0.022.h,
                    dropdownWidth: isTablet ? 0.13.h : 0.13.h,
                    buttonHeight: 0.035.h,
                    isBottomSheet: true,
                    hint: 'Monthly'.tr,
                    dropdownItems: period,
                    value: selectedPeriod,
                    onChanged: (String? value) {
                      setState(() {
                        selectedPeriod = value;
                        print('selectedPeriod: $selectedPeriod');
                      });
                    },
                  ),
                )
                    : const SizedBox.shrink()
              ],
            ),
          ),
          isPortrait
              ? Padding(
            padding: EdgeInsets.only(
                bottom: 0.02.h,
                top: 0.01.h,
                right: isPortrait ? 0.015.h : 0.02.h,
                left: isPortrait ? 0.015.h : 0.02.h),
            child: Row(
              children: [
                for (int i = 0; i < widget.values.length; i++)
                  CustomChartDataRow(
                      isSmall: widget.isSmall,
                      dataColor: customColors[i],
                      textData: widget.texts[i],
                      isSmallContainer: widget.isSmallContainer,
                      isHorizontal: widget.isHorizontal),
              ],
            ),
          )
              : const SizedBox.shrink(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.02.w),
                child: Container(
                  height: 0.33.h,
                  width: isTablet
                      ? isPortrait
                      ? 0.75.w
                      : 0.6.w
                      : 0.82.w,
                  child: widget.line == false
                      ? SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <ColumnSeries<ChartData, String>>[
                      ColumnSeries<ChartData, String>(
                        dataSource: data,
                        xValueMapper: (ChartData info, _) => info.text,
                        yValueMapper: (ChartData info, _) => info.values,
                        pointColorMapper: (ChartData info, int index) {
                          if (index >= 0 && index < customColors.length) {
                            return customColors[index];
                          }
                          return Colors.grey;
                        },
                      )
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  )
                      : SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: isPortrait
                              ? FontConstants.fontSize016.h
                              : FontConstants.fontSize020.h,
                          color: Theme.of(context)
                              .colorScheme
                              .tertiaryContainer,
                          fontWeight: FontWeight.w600,
                          height: 0.001.h),
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: isPortrait
                              ? FontConstants.fontSize016.h
                              : FontConstants.fontSize020.h,
                          color: Theme.of(context)
                              .colorScheme
                              .tertiaryContainer,
                          fontWeight: FontWeight.w600,
                          height: 0.001.h),
                    ),
                    series: <LineSeries<ChartData, String>>[
                      LineSeries<ChartData, String>(
                          color: customColors[0],
                          dataSource: selectedPeriod == 'Weekly'
                              ? weeklyAdditions
                              : selectedPeriod == 'Monthly'
                              ? monthlyAdditions
                              : annualAdditions,
                          xValueMapper: (ChartData data, _) => data.text,
                          yValueMapper: (ChartData data, _) =>
                          data.values),
                      LineSeries<ChartData, String>(
                          color: customColors[1],
                          dataSource: selectedPeriod == 'Weekly'
                              ? weeklyTerminations
                              : selectedPeriod == 'Monthly'
                              ? monthlyTerminations
                              : annualTerminations,
                          xValueMapper: (ChartData data, _) => data.text,
                          yValueMapper: (ChartData data, _) =>
                          data.values),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.03.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (int i = 0; i < widget.values.length; i++)
                              Padding(
                                padding: EdgeInsets.only(bottom: 0.015.h),
                                child: Row(
                                  children: [],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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