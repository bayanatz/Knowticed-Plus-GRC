// ignore_for_file: sdk_version_since, prefer_const_constructors, unnecessary_string_interpolations

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/cupertino_time_picker.dart';
import 'package:demo_app/core/helper/employees/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/multiselect.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/column_request_data.dart';
import 'package:demo_app/core/enums/enum.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/main_core_department_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/main_core_department_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/add_new_employee_view.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:multi_dropdown/enum/app_enums.dart';
import 'package:multi_dropdown/models/chip_config.dart';
import 'package:multi_dropdown/models/value_item.dart';

// ignore: must_be_immutable
class PositionDetailsView extends StatefulWidget {
  PositionDetailsView({
    super.key,
    required this.widthOfData,
    required this.departmentState,
    required this.role,
    required this.roleState,
    required this.type,
    required this.typeState,
    required this.currency,
    required this.currencyState,
    required this.department,
    required this.jobCombensationState,
    required this.jobCompensation,
    required this.jobLocation,
    required this.jobLocationState,
    required this.salary,
    required this.title,
    required this.titleInArabic,
    required this.salaryState,
    required this.titleState,
    required this.titleStateInArabic,
    required this.salaryfinishState,
    required this.days,
    required this.daysState,
    required this.weekEndsState,
    required this.startTime,
    required this.startTimeState,
    required this.endTime,
    required this.endTimeState,
    required this.weekends,
    this.isPreview = false,
  });
  bool isPreview;
  final double widthOfData;
  String? department;
  ValueChanged<String?> departmentState;
  String? role;
  ValueChanged<String?> roleState;
  String? type;
  ValueChanged<String?> typeState;
  String? jobLocation;
  ValueChanged<String?> jobLocationState;
  String? jobCompensation;
  ValueChanged<String?> jobCombensationState;
  String? currency;
  ValueChanged<String?> currencyState;
  TextEditingController salary;
  TextEditingController title;
  TextEditingController titleInArabic;
  ValueChanged<TextEditingController> salaryState;
  ValueChanged<TextEditingController> titleState;
  ValueChanged<TextEditingController> titleStateInArabic;
  TimeOfDay? startTime;
  ValueChanged<TimeOfDay> startTimeState;
  TimeOfDay? endTime;
  ValueChanged<TimeOfDay> endTimeState;
  ValueChanged? salaryfinishState;
  String? days;
  ValueChanged<String>? daysState;
  String? weekends;
  ValueChanged<String?> weekEndsState;

  @override
  State<PositionDetailsView> createState() => _PositionDetailsViewState();
}

class _PositionDetailsViewState extends State<PositionDetailsView> {
  bool hasSuffix1 = false;

  @override
  void initState() {
    getEmployees();
    supervisorName = null;
    super.initState();
  }

  MultiSelectController _controller = MultiSelectController();
  EmployeeController addEmployeeController = Get.find();
  Future<void> getEmployees() async {
    addEmployeeController.allEmployees =
        await addEmployeeController.getAllEmployees();

    //  setState(() {});
  }

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? supervisorName;
  double dropHeight = 0.055.h;
  @override
  Widget build(BuildContext context) {
    TextEditingController controllerTimeStart =
    TextEditingController(text: startTime?.format(context));
    TextEditingController controllerEndStart =
    TextEditingController(text: endTime?.format(context));
    return Container();
  }
}
