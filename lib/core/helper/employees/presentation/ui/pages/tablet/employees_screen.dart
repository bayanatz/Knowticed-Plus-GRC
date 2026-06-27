// Date Created :14/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :3/December/2023
// Objectives: this is a screen that contains the org chart of the employees and where you can show all the
// the employees
// ignore_for_file: sdk_version_since

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/tablet/employees_hierarchy.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/main_core_department_controller.dart';

import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/employees_header.dart';

class EmployeesScreen extends StatefulWidget {
   EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  AddDepartmentController addDepartmentController = Get.find();
  EmployeeController addEmployeeController = Get.find();

  @override
  void initState() {
    addEmployeeController.getAllEmployees();
    addEmployeeController.chartSelected = false;
    addEmployeeController.orgSelected = true;

    super.initState();
  }

  bool isFilterDataShow = false;
  bool isSort = false;
  String? chartDropDown;
  String? orgDropDwon;
  TextEditingController departmentNew = TextEditingController();

  List<int>? managerIndexs;
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color:AppColors.background,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 0.h : 0,
                          horizontal: 0.w
                      ),
                      child: GetBuilder<EmployeeController>(
                          init: Get.find<EmployeeController>(),
                          builder: (addEmployeeController) {
                            if (addEmployeeController.allEmployees == null) {
                              return CircleProgressMaster();
                            } else {
                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    //    EmployeesHeader(),
                                    //   SizedBox(width: 20.w),
                                    selectedIndex == 1
                                        ? const SizedBox.shrink()
                                        : Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 0.h),
                                      child:  TabletEmployeesHierarchy(),)
                                  ],
                                ),
                              );
                            }
                          }),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
