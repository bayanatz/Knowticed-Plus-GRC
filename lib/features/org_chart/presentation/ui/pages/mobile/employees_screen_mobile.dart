import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/custom/feedback/circle_progress.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/settings/helpers/mode_changer.dart';
import 'package:grc_module/features/org_chart/presentation/ui/widgets/employees_components/employees_hr_components/buttons_beside_title_row.dart';

import 'package:grc_module/core/extensions/screen_fraction_extension.dart';
import 'package:grc_module/features/org_chart/presentation/controller/main_core_department_controller.dart';
import 'package:grc_module/features/org_chart/presentation/controller/employee_controller.dart';


import 'package:grc_module/features/org_chart/presentation/ui/pages/tablet/employees_hierarchy.dart';

class EmployeesScreenMobile extends StatefulWidget {
  const EmployeesScreenMobile({super.key});

  @override
  State<EmployeesScreenMobile> createState() => _EmployeesScreenMobileState();
}

class _EmployeesScreenMobileState extends State<EmployeesScreenMobile> {
  Future<void> getDepartments() async {
    await addDepartmentController.getDepartments();

    setState(() {});
  }

  int selectedIndex = 0;
  String? orgDropDwon;
  AddDepartmentController addDepartmentController =
      Get.isRegistered<AddDepartmentController>()
          ? Get.find<AddDepartmentController>()
          : Get.put(AddDepartmentController());
  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());

  @override
  void initState() {
    getDepartments();

    addEmployeeController.getAllEmployees();
    super.initState();
  }

  bool chartSelected = false;
  bool orgSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Mode.hr || Mode.owner
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.04.w),
                  child: ButtonsBesideTitle(
                    chartSelected: chartSelected,
                    chartSelectedState: (value) {
                      setState(() {
                        chartSelected = value;
                      });
                    },
                    orgSelected: orgSelected,
                    orgSelectedState: (value) {
                      setState(() {
                        orgSelected = value;
                      });
                    },
                  ),
                )
              : const SizedBox.shrink(),
          Mode.hr || Mode.owner
              ? SizedBox(height: .014.h)
              : const SizedBox.shrink(),
          Expanded(
              child: Container(
            color: AppColors.background,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.04.w),
              child: GetBuilder<OrgChartEmployeeController>(
                builder: (_) {
                  if (addEmployeeController.allEmployees == null) {
                    return CircleProgressMaster();
                  } else {
                    // The chart view (ChartScreenMobile) was removed, so the
                    // hierarchy is the only body this page renders. The old
                    // `chartSelected == false` branch below it was unreachable
                    // anyway — it only ran inside the `chartSelected == true`
                    // path — so it went with it.
                    return TabletEmployeesHierarchy();
                  }
                },
              ),
            ),
          )),
        ],
      )),
    );
  }
}

enum StatusWant {
  // ignore: constant_identifier_names
  Employee,
  // ignore: constant_identifier_names
  department,
  // ignore: constant_identifier_names
}


StatusWant? selectedOption;

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final Color color;
  final bool first;
  final bool last;

  const CustomPopupMenuItem({
    super.key,
    required T super.value,
    super.enabled,
    required Widget super.child,
    required this.color,
    this.first = false,
    this.last = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomPopupMenuItemState<T> createState() => _CustomPopupMenuItemState<T>();
}

class _CustomPopupMenuItemState<T>
    extends PopupMenuItemState<T, CustomPopupMenuItem<T>> {
  late BorderRadius borderRadius;
  double radius = 10;
  @override
  Widget build(BuildContext context) {
    if (widget.first) {
      borderRadius = BorderRadius.only(
          topLeft: Radius.circular(radius), topRight: Radius.circular(radius));
    } else if (widget.last) {
      borderRadius = BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius));
    } else {
      borderRadius = BorderRadius.zero;
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        color: widget.color,
        child: super.build(context),
      ),
    );
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd MMMM yyyy').format(now);
  return formattedDate;
}
