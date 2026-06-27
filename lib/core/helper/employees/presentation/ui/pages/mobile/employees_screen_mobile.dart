import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/custom_appbar_mobile.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/add_depratment_dialog.dart';
import 'package:demo_app/core/helper/employees/widgets/buttons_beside_title_row.dart';
import 'package:demo_app/features/settings/mode_changer.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/main_core_department_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/helper/employees/employees_views/employee_hr_mobile_add_employee.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/chart_screen_mobile.dart';
import 'package:demo_app/core/helper/employees/employees_views/requests/requests_screen_mobile.dart';

import 'package:demo_app/core/nav_bar_package.dart/functions.dart';

import 'package:demo_app/core/helper/employees/core_widgets/main_widget/sort_option_widget.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/tablet/employees_hierarchy.dart';

class EmployeesScreenMobile extends StatefulWidget {
   EmployeesScreenMobile({super.key});

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
  AddDepartmentController addDepartmentController = Get.find();
  EmployeeController addEmployeeController = Get.find();

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
          CustomAppBarMobile(
            showIcon: false,
            isHome: false,
            showMoreIcon: false,
            title: "Employees",
            isEmployees: true,
            imagePath: 'assets/icons/add_emp_dep_mob.svg',
            onTapUp: (details) {
              final iconPosition = details.globalPosition;
              _showSortMenu(context, iconPosition);
            },
            onIconPressed: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const EmployeeHrAddEmployee(),
                withNavBar: true,
              );
            },
          ),
          SizedBox(height: .014.h),
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
              child: GetBuilder<EmployeeController>(
                builder: (_) {
                  if (addEmployeeController.allEmployees == null) {
                    debugPrint(
                        'allEmployees.length in mobile page=${addEmployeeController.allEmployees?.length}');
                    return CircleProgressMaster();
                  } else {
                    if (!chartSelected ) {
                      return TabletEmployeesHierarchy();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (Mode.hr || Mode.owner) &&
                                orgSelected == false &&
                                chartSelected == false
                            ? selectedIndex == 1
                                ? const RequestsScreenMobile()
                                : Container()
                            : (Mode.hr || Mode.owner) && chartSelected
                                ? const Expanded(
                                    child: SingleChildScrollView(
                                    child: ChartScreenMobile(),
                                  ))
                                : Container()
                      ],
                    );
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

void _showSortMenu(BuildContext context, Offset iconPosition) async {
  final List<StatusWant> sortOptions = [
    StatusWant.Employee,
    StatusWant.department,
  ];

  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final double menuOffsetX = iconPosition.dx - (-9.0);
  final double menuOffsetY = iconPosition.dy - (-7.0);

  final RelativeRect position = RelativeRect.fromLTRB(
    menuOffsetX,
    menuOffsetY,
    overlay.size.width - menuOffsetX,
    overlay.size.height,
  );

  selectedOption = await showMenu(
    elevation: 0,
    shadowColor: Colors.transparent,
    color: Theme.of(context).colorScheme.onPrimary,
    context: context,
    constraints: BoxConstraints(
      maxWidth: 0.43.w,
      minHeight: 0.0.h,
    ),
    position: position,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.signOut)),
    items: sortOptions.map((option) {
      return CustomPopupMenuItem<StatusWant>(
          first: option.index == 0,
          last: option.index == sortOptions.length - 1,
          color: Theme.of(context).colorScheme.onPrimary,
          value: option,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getSortOptionLabel(option, context),
            ],
          ));
    }).toList(),
  );

  if (selectedOption != null) {
    // Call the appropriate dialog function based on the selected option
    switch (selectedOption!) {
      case StatusWant.Employee:
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const EmployeeHrAddEmployee(),
          withNavBar: true,
        );
        break;
      case StatusWant.department:
        showDialog(
            context: context,
            builder: (context) {
              return Container();
            });
        break;
    }
  }
}

StatusWant? selectedOption;
Widget _getSortOptionLabel(StatusWant option, BuildContext context) {
  switch (option) {
    case StatusWant.Employee:
      return const SortOptionWidget(
        iconAddress: 'assets/icons/employee_down.svg',
        text: "Add Employee",
      );
    case StatusWant.department:
      return const SortOptionWidget(
        iconAddress: 'assets/icons/case_down.svg',
        text: "Add Department",
      );
  }
}

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final Color color;
  final bool first;
  final bool last;

  const CustomPopupMenuItem({
    Key? key,
    required T value,
    bool enabled = true,
    required Widget child,
    required this.color,
    this.first = false,
    this.last = false,
  }) : super(key: key, value: value, enabled: enabled, child: child);

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
