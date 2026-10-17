// Date Created :14/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :3/December/2023
// Objectives: this is a screen that contains the org chart of the employees and where you can show all the
// the employees
// ignore_for_file: sdk_version_since

import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/navigation/custom_side_frame_master.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/feedback/circle_progress.dart';
import 'package:grc_module/features/org_chart/presentation/ui/pages/tablet/employees_hierarchy.dart';
import 'package:grc_module/core/theme/app_colors.dart';

import 'package:grc_module/features/org_chart/presentation/controller/employee_controller.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());

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
    // CHANGED 18/10/2026 (owner): the "Organization Chart" title is the
    // shared module title (SideFrameMasterServices) — same style, start
    // padding and top position as Form Builder / Knowledge Hub.
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: SideFrameMasterServices(
          titleText: S.of(context).organizationChart,
          child: GetBuilder<OrgChartEmployeeController>(
            init: Get.find<OrgChartEmployeeController>(),
            builder: (addEmployeeController) {
              if (addEmployeeController.allEmployees == null) {
                return Center(child: CircleProgressMaster());
              }
              return ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: false),
                child: const TabletEmployeesHierarchy(showTitle: false),
              );
            },
          ),
        ),
      ),
    );
  }
}
