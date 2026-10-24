import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_time_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/org_chart/presentation/controller/main_core_department_controller.dart';
import 'package:knowticed_plus/features/org_chart/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';

import 'package:knowticed_plus/features/org_chart/presentation/employees_views/employee_views_mobile/employee_personal_info.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

// ✅ NEW: Single import for the updated model

class PostionDetailsMobileFields extends StatefulWidget {
  const PostionDetailsMobileFields({
    super.key,
    this.compensation,
    this.compensationState,
    this.currency,
    this.currencyState,
    this.department,
    this.departmentState,
    this.jobLocation,
    this.jobLocationState,
    this.jobType,
    this.jobTypeState,
    this.role,
    this.roleState,
    this.value = 0,
    this.valueState,
    this.salary,
    this.supervisor,
    this.title,
    this.titleInArabic,
    this.endTime,
    this.startTime,
    this.worksDays,
    this.workDaysState,
  });

  final String? department;
  final TextEditingController? title;
  final TextEditingController? titleInArabic;
  final ValueChanged<String?>? departmentState;
  final String? role;
  final ValueChanged<String?>? roleState;
  final String? jobLocation;
  final ValueChanged<String?>? jobLocationState;
  final String? jobType;
  final ValueChanged<String?>? jobTypeState;
  final String? compensation;
  final ValueChanged<String?>? compensationState;
  final String? currency;
  final String? worksDays;
  final ValueChanged<String?>? currencyState;
  final ValueChanged<String?>? workDaysState;
  final double value;
  final ValueChanged<double>? valueState;
  final TextEditingController? salary;
  final TextEditingController? supervisor;
  final TextEditingController? startTime;
  final TextEditingController? endTime;

  @override
  State<PostionDetailsMobileFields> createState() =>
      _PostionDetailsMobileFieldsState();
}

class _PostionDetailsMobileFieldsState
    extends State<PostionDetailsMobileFields> {
  // Working copies of the widget's values. They change while the user
  // fills the form and are re-read from the widget when the parent rebuilds it.
  late double _value = widget.value;
  late String? _department = widget.department;
  late String? _role = widget.role;
  late String? _jobLocation = widget.jobLocation;
  late String? _jobType = widget.jobType;
  late String? _compensation = widget.compensation;
  late String? _currency = widget.currency;

  @override
  void didUpdateWidget(covariant PostionDetailsMobileFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
    _department = widget.department;
    _role = widget.role;
    _jobLocation = widget.jobLocation;
    _jobType = widget.jobType;
    _compensation = widget.compensation;
    _currency = widget.currency;
  }

  /// Guarded lookup — the controller may not be registered yet when this
  /// widget builds, which used to throw `"AddDepartmentController" not found`.
  AddDepartmentController get _departments =>
      Get.isRegistered<AddDepartmentController>()
          ? Get.find<AddDepartmentController>()
          : Get.put(AddDepartmentController());

  String? supervisor;

  @override
  void initState() {
    supervisor = null;
    super.initState();
  }

  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());

  List<MultiSelectDropdownItem<dynamic>> get _dayItems =>
      <MultiSelectDropdownItem<dynamic>>[
        MultiSelectDropdownItem(value: '1', label: S.current.saturday),
        MultiSelectDropdownItem(value: '2', label: S.current.sunday),
        MultiSelectDropdownItem(value: '3', label: S.current.monday),
        MultiSelectDropdownItem(value: '4', label: S.current.tuesday),
        MultiSelectDropdownItem(value: '5', label: S.current.wednesday),
        MultiSelectDropdownItem(value: '6', label: S.current.thursday),
        MultiSelectDropdownItem(value: '7', label: S.current.friday),
      ];

  /// Update supervisor based on role and department
  void _updateSupervisor() {
    if (_role == null || _department == null) {
      supervisor = null;
      widget.supervisor!.clear();

      addEmployeeController.employeePhone =
          addEmployeeController.employeePhone.copyWithUpdateSynchronized(
        supervisor: null,
        addTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
      return;
    }

    final department = _department!.toLowerCase();
    final role = _role!.toLowerCase();

    try {
      NewEmployeeModelHistory? supervisorEmployee;

      // Find supervisor based on role hierarchy
      if (role == 'employee') {
        // Employee reports to Team Lead in same department
        supervisorEmployee = addEmployeeController.allEmployees!.firstWhere(
          (employee) =>
              employee.departmentId.isNotEmpty &&
              employee.departmentId.last == department &&
              employee.role.isNotEmpty &&
              employee.role.last == 'team lead',
        );
      } else if (role == 'team lead') {
        // Team Lead reports to Admin in same department
        supervisorEmployee = addEmployeeController.allEmployees!.firstWhere(
          (employee) =>
              employee.departmentId.isNotEmpty &&
              employee.departmentId.last == department &&
              employee.role.isNotEmpty &&
              employee.role.last == 'admin',
        );
      } else if (role == 'admin') {
        // Admin reports to General Admin in same department
        supervisorEmployee = addEmployeeController.allEmployees!.firstWhere(
          (employee) =>
              employee.departmentId.isNotEmpty &&
              employee.departmentId.last == department &&
              employee.role.isNotEmpty &&
              employee.role.last == 'general admin',
        );
      } else if (role == 'general admin') {
        // General Admin reports to CEO
        supervisorEmployee = addEmployeeController.allEmployees!.firstWhere(
          (employee) => employee.role.isNotEmpty && employee.role.last == 'ceo',
        );
      }

      if (supervisorEmployee != null) {
        // Set supervisor name in text field
        final firstName = supervisorEmployee.firstName.isNotEmpty
            ? supervisorEmployee.firstName.last
            : '';
        final lastName = supervisorEmployee.lastName.isNotEmpty
            ? supervisorEmployee.lastName.last
            : '';
        widget.supervisor!.text = capitalize('$firstName $lastName');

        // Store supervisor email
        supervisor = supervisorEmployee.email.isNotEmpty
            ? supervisorEmployee.email.last
            : null;

        // Update employee model
        if (supervisor != null) {
          addEmployeeController.employeePhone =
              addEmployeeController.employeePhone.copyWithUpdateSynchronized(
            supervisor: supervisor!,
            addTimestamp: DateTime.now().millisecondsSinceEpoch,
          );
        }
      }
    } catch (e) {
      supervisor = null;
      widget.supervisor!.clear();

      addEmployeeController.employeePhone =
          addEmployeeController.employeePhone.copyWithUpdateSynchronized(
        supervisor: null,
        addTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    final orientation = MediaQuery.of(context).orientation;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double heightSpacer = isPortrait ? 0.007.h : 0.013.h;
    double heightSpacerTextField = 0.003.h;

    !AppTheme.isDark ? const Color(0xFFF6F6F6) : AppColors.colorBlack;

    !AppTheme.isDark ? const Color(0xFFF6F6F6) : AppColors.colorBlack;

    EdgeInsets.symmetric(
      horizontal: orientation == Orientation.portrait ? 0.04.w : 0.01.w,
    );

    TextStyle dropDownTextStyle = StyleText.fontSize16Weight400.copyWith(
      fontSize: isTablet ? (isPortrait ? 12.sp : 14.sp) : 14.sp,
      color: AppColors.colorGrey,
      fontWeight: FontWeight.w400,
      height: orientation == Orientation.portrait ? 0.0014.h : 0.002.h,
    );

    !kpIsPhoneLayout(context)
        ? (orientation == Orientation.portrait ? 0.620.w : 0.850.h)
        : 0.42.w;

    double buttonHeight = !kpIsPhoneLayout(context)
        ? (orientation == Orientation.portrait ? 0.04.h : 0.04.w)
        : 0.05.h;

    double? dropdownHeight = !kpIsPhoneLayout(context) ? null : 0.2.h;

    !kpIsPhoneLayout(context) ? null : EdgeInsets.symmetric(vertical: 0.003.h);

    EdgeInsets buttonPadding = EdgeInsets.symmetric(
      horizontal: orientation == Orientation.landscape
          ? 0.022.h
          : isTablet
              ? 0.02.w
              : (0.025.w),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.01.h),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Department and Role section
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Department dropdown
                CustomDropdown<String>(
                  valueStyle: dropDownTextStyle,
                  maxOverlayHeight: dropdownHeight,
                  hint: S.of(context).department,
                  items: (_departments.departmentsEnglishName)
                      .map((e) => DropdownItem<String>(value: e, label: e))
                      .toList(),
                  triggerPadding: buttonPadding,
                  value: _department,
                  onChanged: (value) {
                    setState(() {
                      _department = value;

                      // Get department ID
                      final addDepartmentController = _departments;
                      String? deptId = addDepartmentController
                          .getDepartmentIdFromDepartmentName(
                        departmentName: value,
                      );

                      // Update employee model
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                        departmentId: deptId,
                        addTimestamp: DateTime.now().millisecondsSinceEpoch,
                      );

                      // Update supervisor based on role and department
                      _updateSupervisor();

                      widget.departmentState!(_department);
                      _value += (1 / 9);
                      widget.valueState!(_value);
                    });
                  },
                ),
                SizedBox(height: heightSpacer),

                // Role dropdown
                CustomDropdown<String>(
                  valueStyle: dropDownTextStyle,
                  maxOverlayHeight: dropdownHeight,
                  hint: S.of(context).role,
                  items: ([
                    S.of(context).cEO,
                    S.of(context).generalManager,
                    S.of(context).manager,
                    S.of(context).teamLead,
                    S.of(context).employee,
                  ])
                      .map((e) => DropdownItem<String>(value: e, label: e))
                      .toList(),
                  triggerPadding: buttonPadding,
                  value: _role,
                  onChanged: (value) {
                    setState(() {
                      _role = value;

                      // Update employee model
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                        role: value.toLowerCase(),
                        addTimestamp: DateTime.now().millisecondsSinceEpoch,
                      );

                      // Update supervisor based on role and department
                      _updateSupervisor();

                      widget.roleState!(_role);
                      _value += (1 / 9);
                      widget.valueState!(_value);
                    });
                  },
                ),
                SizedBox(height: heightSpacerTextField),

                // Title field
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    onChanged: (value) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                        title: value.toLowerCase(),
                        addTimestamp: DateTime.now().millisecondsSinceEpoch,
                      );
                    },
                    hint: S.of(context).title,
                    readOnly: false,
                    onSubmitted: (value) {
                      setState(() {
                        _value += (1 / 13);
                        widget.valueState!(_value);
                      });
                    },
                  ),
                ),

                // Title in Arabic field
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    onChanged: (value) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                        titleInArabic: value.toLowerCase(),
                        addTimestamp: DateTime.now().millisecondsSinceEpoch,
                      );
                    },
                    hint: S.of(context).titleInArabic,
                    readOnly: false,
                    onSubmitted: (value) {
                      setState(() {
                        _value += (1 / 13);
                        widget.valueState!(_value);
                      });
                    },
                  ),
                ),
              ],
            ),

            // Supervisor and Job Location section
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Supervisor field (read-only)
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    onChanged: (value) {},
                    hint: S.of(context).superVisor,
                    initialValue: capitalize(widget.supervisor!.text),
                    readOnly: true,
                    onSubmitted: (value) {
                      setState(() {
                        widget.supervisor!.text = value;
                        _value += (1 / 9);
                        widget.valueState!(_value);
                      });
                    },
                  ),
                ),
                SizedBox(height: heightSpacerTextField),

                // Job Location dropdown
                CustomDropdown<String>(
                  valueStyle: dropDownTextStyle,
                  maxOverlayHeight: dropdownHeight,
                  hint: S.of(context).jobLocation,
                  items: ([
                    S.of(context).onSite,
                    S.of(context).remote,
                    S.of(context).hybrid
                  ])
                      .map((e) => DropdownItem<String>(value: e, label: e))
                      .toList(),
                  triggerPadding: buttonPadding,
                  value: _jobLocation,
                  onChanged: (value) {
                    setState(() {
                      _jobLocation = value;

                      // Update employee model
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                        workLocation: value.toLowerCase(),
                        addTimestamp: DateTime.now().millisecondsSinceEpoch,
                      );

                      widget.jobLocationState!(_jobLocation);
                      _value += (1 / 9);
                      widget.valueState!(_value);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: heightSpacer),

            // Job Type and Compensation section
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Job Type dropdown
                CustomDropdown<String>(
                  valueStyle: dropDownTextStyle,
                  maxOverlayHeight: dropdownHeight,
                  hint: S.of(context).jobType,
                  items: ([
                    S.of(context).fixed,
                    S.of(context).hourly,
                    S.of(context).fixedBonus,
                  ])
                      .map((e) => DropdownItem<String>(value: e, label: e))
                      .toList(),
                  triggerPadding: buttonPadding,
                  value: _jobType,
                  onChanged: (value) {
                    setState(() {
                      _jobType = value;
                      // Note: jobType not in NewEmployeeModelHistory
                      // Store in local state only or add to model if needed
                      widget.jobTypeState!(_jobType);
                      _value += (1 / 9);
                      widget.valueState!(_value);
                    });
                  },
                ),
                SizedBox(height: heightSpacer),

                // Compensation dropdown
                CustomDropdown<String>(
                  valueStyle: dropDownTextStyle,
                  maxOverlayHeight: dropdownHeight,
                  hint: S.of(context).compensation,
                  items: ([
                    S.of(context).fullTime,
                    S.of(context).partTime,
                    S.of(context).contract,
                  ])
                      .map((e) => DropdownItem<String>(value: e, label: e))
                      .toList(),
                  triggerPadding: buttonPadding,
                  value: _compensation,
                  onChanged: (value) {
                    setState(() {
                      _compensation = value;
                      // Note: jobCompensation not in NewEmployeeModelHistory
                      // Store in local state only or add to model if needed
                      widget.compensationState!(_compensation);
                      _value += (1 / 9);
                      widget.valueState!(_value);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: heightSpacerTextField),

            // Salary and Currency section
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Salary field
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    onChanged: (value) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                        // salary: value,
                        addTimestamp: DateTime.now().millisecondsSinceEpoch,
                      );
                    },
                    hint: S.of(context).salary,
                    readOnly: false,
                    onSubmitted: (value) {
                      setState(() {
                        widget.salary!.text = value;
                        _value += (1 / 13);
                        widget.valueState!(_value);
                      });
                    },
                  ),
                ),
                SizedBox(height: heightSpacerTextField),

                // Currency dropdown
                CustomDropdown<String>(
                  valueStyle: dropDownTextStyle,
                  maxOverlayHeight: dropdownHeight,
                  hint: S.of(context).currency,
                  items: ([
                    S.of(context).uSD,
                    S.of(context).eGP,
                    S.of(context).eUR
                  ])
                      .map((e) => DropdownItem<String>(value: e, label: e))
                      .toList(),
                  triggerPadding: buttonPadding,
                  value: _currency,
                  onChanged: (value) {
                    setState(() {
                      _currency = value;
                      // Note: currency not in NewEmployeeModelHistory
                      // Store in local state only or add to model if needed
                      widget.currencyState!(_currency);
                      _value += (1 / 9);
                      widget.valueState!(_value);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: heightSpacer),

            // Work Days multi-select
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: CustomMultiSelectFilter<dynamic>(
                hint: S.of(context).enterTheWorkDays,
                items: _dayItems,
                values: addEmployeeController.selectedDaysOptions
                    .map((e) => e.value)
                    .toList(),
                onChanged: (values) {
                  final selected = _dayItems
                      .where((it) => values.contains(it.value))
                      .toList();
                  addEmployeeController.selecteItem(selected);
                  setState(() {});
                },
              ),
            ),
            SizedBox(height: heightSpacerTextField),

            // Start Time field
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                onChanged: (value) {},
                hint: // validator
                    S.of(context).startTime,
                readOnly: true,
                suffixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (isTablet ? 0.022.w : 0.038.w),
                  ),
                  child: GestureDetector(
                    onTapDown: (_) => HapticController.medium(),
                    // 22/10/2026 — Owner: the app's one time picker
                    // (scroll wheel + standard header); this wheel's OK did
                    // not keep the picked time.
                    onTap: () async {
                      final TimeOfDay? t = await showKpTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t == null || !mounted) return;
                      setState(() {
                        widget.startTime!.text = DateFormat('hh:mm a')
                            .format(DateTime(2000, 1, 1, t.hour, t.minute));
                      });
                    },
                    child: CustomSvgImage.natural(
                      assetPath:
                          "assets/icons_assets/org_chart_assets/ic_time_new.svg",
                      height: orientation == Orientation.portrait
                          ? isTablet
                              ? 0.02.h
                              : 0.02.h
                          : 0.02.h,
                      color: AppColors.colorGrey,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _value += (1 / 13);
                    widget.valueState!(_value);
                  });
                },
              ),
            ),

            // End Time field
            CustomTextField(
              onChanged: (value) {},
              hint: // validator
                  S.of(context).endTime,
              readOnly: true,
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (isTablet ? 0.022.w : 0.038.w),
                ),
                child: GestureDetector(
                  onTapDown: (_) => HapticController.medium(),
                  // 22/10/2026 — Owner: the app's one time picker.
                  onTap: () async {
                    final TimeOfDay? t = await showKpTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t == null || !mounted) return;
                    setState(() {
                      widget.endTime!.text = DateFormat('hh:mm a')
                          .format(DateTime(2000, 1, 1, t.hour, t.minute));
                    });
                  },
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/org_chart_assets/ic_time_new.svg",
                    height: orientation == Orientation.portrait
                        ? isTablet
                            ? 0.02.h
                            : 0.02.h
                        : 0.02.h,
                    color: AppColors.colorGrey,
                  ),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  _value += (1 / 13);
                  widget.valueState!(_value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
