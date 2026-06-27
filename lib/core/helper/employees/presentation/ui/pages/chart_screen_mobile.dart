import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/custom_column_charts.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/custom_employee_chart.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/custom_vertical_chart.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/helper/employees/attendance_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/employee_hr_charts_screen.dart';

import 'package:demo_app/core/helper/employees/presentation/ui/widgets/chart_header.dart';
// ToDo: refactor
class ChartScreenMobile extends StatefulWidget {
  const ChartScreenMobile({super.key});

  @override
  State<ChartScreenMobile> createState() => _ChartScreenMobileState();
}

class _ChartScreenMobileState extends State<ChartScreenMobile> {
  String? employeeDetails;
  String? employeeAttendance;
  String? employeePerformance;
  EmployeeController addEmployeeController = Get.find();
  AttendanceController attendanceController = Get.find();
  String? selectedPeriod = 'Monthly'.tr;
  Map<String, int> topCountries = {};
  Map<String, int> countCountries() {
    Map<String, int> countryCount = {};

    for (var employee in addEmployeeController.allEmployees!) {
      if (countryCount.containsKey(employee.nationality!.last!)) {
        countryCount[employee.nationality!.last!] =
            countryCount[employee.nationality!.last]! + 1;
      } else {
        countryCount[employee.nationality!.last!] = 1;
      }
    }
    var sortedEntries = countryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topCountries = Map<String, int>.fromEntries(sortedEntries.take(3));
    return topCountries;
  }

  @override
  void initState() {
    countCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return topCountries == {}
        ? const CircleProgressMaster()
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ChartHeader(
                  chartText: 'Employees Details',
                  dropDownValue: employeeDetails,
                  dropDropeState: (value) {
                    setState(() {
                      employeeDetails = value;
                    });
                  },
                ),
                Padding(
                    padding: EdgeInsets.only(top: 0.02.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 0.29.h,
                          child: CustomEmployeeChartContainer(
                            imagePath: "assets/images/case_vertical.svg",
                            isEmployeeChart: true,
                            isTransparent: true,
                            width: double.infinity,
                            height: 0.248,
                            textSizeTexts: 0.023,
                            textSizeValues: 0.021,
                            title: 'Employees Overview',
                            texts: [
                              'Male'.tr,
                              'Female'.tr,
                            ],
                            values: [
                              addEmployeeController.allEmployees!
                                  .where((element) =>
                                      element.gender!.last! == 'male')
                                  .toList()
                                  .length
                                  .toString(),
                              addEmployeeController.allEmployees!
                                  .where((element) =>
                                      element.gender!.last! == 'female')
                                  .toList()
                                  .length
                                  .toString()
                            ],
                          ),
                        ),
                        Padding(
                          padding:  EdgeInsets.symmetric(vertical: 0.02.h),
                          child: SizedBox(
                          width: double.infinity,
                            height: 0.29.h,
                            child: CustomEmployeeChartContainer(
                              imagePath: "assets/images/case_vertical.svg",
                              isEmployeeChart: true,
                              isExpandedChart: true,
                              isTransparent: true,
                              width: double.infinity,
                              height: 0.248,
                              textSizeTexts: 0.023,
                              textSizeValues: 0.021,
                              title: 'Employees Nationality',
                              texts: [
                                    topCountries.keys.toList()[0].toString(),
                                    if (topCountries.keys.toList().length > 1)
                                      topCountries.keys.toList()[1].toString(),
                                    if (topCountries.keys.toList().length > 2)
                                      topCountries.keys.toList()[2].toString(),
                                    "Other"
                                  ],
                                  mins: const [
                                    '95',
                                    '10',
                                    '10',
                                    '10',
                                    '10',
                                  ],
                                  values: [
                                    topCountries.values.toList()[0].toString(),
                                    if (topCountries.keys.toList().length > 1)
                                      topCountries.values
                                          .toList()[1]
                                          .toString(),
                                    if (topCountries.keys.toList().length > 2)
                                      topCountries.values
                                          .toList()[2]
                                          .toString(),
                                    addEmployeeController.allEmployees!
                                        .where((element) =>
                                            element.nationality!
                                                    .last !=
                                                topCountries.keys
                                                    .toList()[0]
                                                    .toString() &&
                                            element.nationality!
                                                    .last !=
                                                topCountries.keys
                                                    .toList()[1]
                                                    .toString() &&
                                            element.nationality!
                                                    .last !=
                                                topCountries.keys
                                                    .toList()[2]
                                                    .toString())
                                        .toList()
                                        .length
                                        .toString(),
                                  ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 0.4.h,
                          child: CustomVerticalChart(
                            innerTitle: "Employees",
                            imagePath: "assets/images/case_vertical.svg",
                            isTransparent: true,
                            width: double.infinity,
                            height: 0.248,
                            textSizeTexts: 0.023,
                            textSizeValues: 0.021,
                            title: 'Job Location',
                            texts: ["On Site".tr, "Remote".tr, "Hybrid".tr],
                            values: [
                              addEmployeeController.allEmployees!
                                  .where((element) =>
                                      element.workLocation!.last ==
                                      'on site')
                                  .toList()
                                  .length
                                  .toString(),
                              addEmployeeController.allEmployees!
                                  .where((element) =>
                                      element.workLocation!.last ==
                                      'remote')
                                  .toList()
                                  .length
                                  .toString(),
                              addEmployeeController.allEmployees!
                                  .where((element) =>
                                      element.workLocation!.last ==
                                      'hybrid')
                                  .toList()
                                  .length
                                  .toString(),
                            ],
                          ),
                        ),
                        Padding(
                          padding:  EdgeInsets.symmetric(vertical: 0.02.h),
                          child: SizedBox(
                            width: double.infinity,
                            height: 0.4.h,
                            child: CustomVerticalChart(
                              innerTitle: "Employees",
                              imagePath: "assets/images/case_vertical.svg",
                              isTransparent: true,
                              width: double.infinity,
                              height: 0.248,
                              textSizeTexts: 0.023,
                              textSizeValues: 0.021,
                              title: 'Employment Type',
                              texts: [
                                "Full-time".tr,
                                "Part-time".tr,
                                "Contract".tr
                              ],
                              values: [
                               /* addEmployeeController.allEmployees!
                                    .where((element) =>
                                        element.jobCompensation!.jobCompensation!
                                            .last ==
                                        'full-time')
                                    .toList()
                                    .length
                                    .toString(),
                                addEmployeeController.allEmployees!
                                    .where((element) =>
                                        element.jobCompensation!.jobCompensation!
                                            .last ==
                                        'part-time')
                                    .toList()
                                    .length
                                    .toString(),
                                addEmployeeController.allEmployees!
                                    .where((element) =>
                                        element.jobCompensation!.jobCompensation!
                                            .last ==
                                        'contract')
                                    .toList()
                                    .length
                                    .toString(),*/
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
                // ChartHeader(
                //   chartText: 'Employee Attendance',
                //   dropDownValue: employeeAttendance,
                //   dropDropeState: (value) {
                //     setState(() {
                //       employeeAttendance = value;
                //     });
                //   },
                // ),
                // Padding(
                //   padding: EdgeInsets.only(top: 0.02.h),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: <Widget>[
                //       SizedBox(
                //         width: 0.62.w,
                //         height: 0.41.h,
                //         child: CustomColumnChartContainer(
                //           imagePath: 'assets/icons/attendance.svg',
                //           isTransparent: true,
                //           width: double.infinity,
                //           height: 0.248,
                //           textSizeTexts: 0.023,
                //           textSizeValues: 0.021,
                //           isSmallContainer: true,
                //           title: 'Employees Attendance',
                //           texts: [
                //             'On Time'.tr,
                //             'Late'.tr,
                //             'Absent'.tr,
                //           ],
                //           values: [
                //             attendanceController.allAttendances
                //                 .where((element) => element.status == 'attendance')
                //                 .toList()
                //                 .length
                //                 .toString(),
                //             attendanceController.allAttendances
                //                 .where((element) => element.status == 'late')
                //                 .toList()
                //                 .length
                //                 .toString(),
                //             attendanceController.allAttendances
                //                 .where((element) => element.status == 'absent')
                //                 .toList()
                //                 .length
                //                 .toString(),
                //           ],
                //         ),
                //       ),
                //       SizedBox(
                //         width: 0.02.w,
                //       ),
                //       SizedBox(
                //         width: 0.35.h,
                //         height: 0.41.h,
                //         child: CustomVerticalChart(
                //           innerTitle: "Employees",
                //           imagePath: 'assets/icons/attendance.svg',
                //           isTransparent: true,
                //           width: double.infinity,
                //           height: 0.248,
                //           textSizeTexts: 0.023,
                //           textSizeValues: 0.021,
                //           title: 'Job Location',
                //           texts: ["On Site".tr, "Remote".tr, "Hybrid".tr],
                //           values: [
                //             addEmployeeController.allEmployees!
                //                 .where((element) =>
                //                     element.jobLocation!.jobLocation!.last ==
                //                     'on site')
                //                 .toList()
                //                 .length
                //                 .toString(),
                //             addEmployeeController.allEmployees!
                //                 .where((element) =>
                //                     element.jobLocation!.jobLocation!.last ==
                //                     'remote')
                //                 .toList()
                //                 .length
                //                 .toString(),
                //             addEmployeeController.allEmployees!
                //                 .where((element) =>
                //                     element.jobLocation!.jobLocation!.last ==
                //                     'hybrid')
                //                 .toList()
                //                 .length
                //                 .toString(),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                ChartHeader(
                  chartText: 'Employee Statistics',
                  dropDownValue: employeePerformance,
                  dropDropeState: (value) {
                    setState(() {
                      employeePerformance = value;
                    });
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.02.h, bottom: 0.02.h),
                  child:  SizedBox(
                    width: double.infinity,
                    height: 0.47.h,
                    child: CustomColumnChartContainer(
                      line: true,
                      imagePath: "assets/images/case_vertical.svg",
                      isTransparent: true,
                      width: double.infinity,
                      height: 0.248,
                      textSizeTexts: 0.023,
                      textSizeValues: 0.021,
                      isSmallContainer: true,
                      title: 'Employees Status',
                      texts: [
                        'Employees Added'.tr,
                        'Employees Terminated'.tr,
                      ],
                      values: const [
                        '20',
                        '10',
                      ],
                    ),
                  )
                     
                ),
              ],
            ),
          );
  }
}
