/// *************************** FILE INFO ******************** ///
/// FILE NAME: system_logs_table.dart
/// PURPOSE: this file contains the system logs tab content.
/// AUTHOR: Mohamed Elrashidy
/// REFACTORED AT: 2/2/2025
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';
import 'package:demo_app/features/roles/system_logs/ui/widgets/custom_table_body.dart';
import 'package:demo_app/features/roles/system_logs/ui/widgets/system_logs_appbar.dart';
import 'package:demo_app/features/roles/system_logs/ui/widgets/system_logs_table_header.dart';

import 'package:demo_app/features/roles/system_logs/data/models/system_logs_model.dart';
import 'package:demo_app/features/roles/system_logs/utils/system_logs_constants.dart';

class SystemLogsTable extends StatefulWidget {
  const SystemLogsTable({super.key});

  @override
  State<SystemLogsTable> createState() => _SystemLogsTableState();
}

class _SystemLogsTableState extends State<SystemLogsTable> {
  SystemLogsController systemLogsController = Get.find();
  EmployeeController addEmployeeController = Get.find();
  @override
  void initState() {
    systemLogsController.getSystemLogs().then((value) {
      systemLogsController.initFiltersLists();
      systemLogsController.resetFilter();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      body: GetBuilder<SystemLogsController>(builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SystemLogsAppBar(),
            controller.systemLogsData.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: .26.h),
                      child: SizedBox(
                          height: isPortrait ? 0.055.h : 0.07.h,
                          child: const CircleProgressMaster()),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: isTablet
                          ? isPortrait
                              ? 2.55.w
                              : 2.1.w
                          : 2.3.w,
                      child: Container(
                        height: 0.55.h,
                        child: ListView(
                          children: [
                            SystemLogsTableHeader(),
                            _tableBody(controller.finalSystemLogsList)
                          ],
                        ),
                      ),
                    ),
                  )
          ],
        );
      }),
    );
  }

  Widget _tableBody(List<SystemLogsModel> systemLogs) {
    return ListView.builder(
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: systemLogs.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: index % 2 == 0
                  ? themeController.currentTheme == AppColors.lightTheme
                      ? const Color(0xFFf1f1f1)
                      : AppColors.darkBackGround
                  : themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorWhite
                      : const Color(0xFF28282B),
            ),
            child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.025.h),
                child: Row(
                  children: [
                    for (int itemIndex = 0;
                        itemIndex < SystemLogsConstants.systemLogsItems.length;
                        itemIndex++)
                      CustomTableBody(
                          text: SystemLogsConstants.systemLogsItems[itemIndex]
                              .itemValue(systemLogs[index])),
                  ],
                )),
          );
        });
  }
}
