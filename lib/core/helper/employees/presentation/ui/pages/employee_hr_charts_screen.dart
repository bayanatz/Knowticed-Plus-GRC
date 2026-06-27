import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/helper/employees/attendance_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/job_location_chart.dart';

import 'package:demo_app/core/helper/employees/presentation/ui/widgets/custom_column_charts.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/chart_header.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/employees_nationality_chart.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/employees_overview_chart.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/employment_type_chart.dart';

/// Date Created :7/Dec/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :14/Dec/2023
/// Objectives: this screen is responsible for some charts for the hr to see some details of his all employees, like
/// the employees nationalities he have, employees genders, employees attendance, meeting attendance,
/// employees performances , and project achievements

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  String? employeeDetails;
  String? employeeAttendance;
  String? employeePerformance;
  EmployeeController addEmployeeController = Get.find();
  AttendanceController attendanceController = Get.find();
  String? selectedPeriod = 'Monthly'.tr;

  @override
  void initState() {
    addEmployeeController.countCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return addEmployeeController.topCountries == {}
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
                  child: isPortrait
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                EmployeesOverviewChart(),
                                EmployeesNationalityChart()
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.015.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  JobLocationChart(),
                                  EmploymentTypeChart()
                                ],
                              ),
                            )
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(child: EmployeesOverviewChart()),
                            SizedBox(width: .02.w),
                            Expanded(child: EmployeesNationalityChart()),
                            SizedBox(width: .02.w),
                            JobLocationChart()
                          ],
                        ),
                ),
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
                  child: isPortrait
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 0.82.w,
                              height: 0.48.h,
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
                                values: const ['20', '10'],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: SizedBox(
                                width: 0.62.w,
                                height: 0.44.h,
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
                                  values: const ['20', '10'],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 0.02.w,
                            ),
                            EmploymentTypeChart(),
                          ],
                        ),
                ),
              ],
            ),
          );
  }
}

