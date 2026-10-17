import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/settings/helpers/mode_changer.dart';
import 'package:grc_module/core/extensions/screen_fraction_extension.dart';
import 'package:grc_module/features/org_chart/presentation/controller/employee_controller.dart';

import 'package:grc_module/features/org_chart/presentation/ui/widgets/employees_components/employees_hr_components/buttons_beside_title_row.dart';
import 'package:grc_module/generated/l10n.dart';

class EmployeesHeader extends StatelessWidget {
  EmployeesHeader({super.key});
  final OrgChartEmployeeController employeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: isTablet
              ? isPortrait
                  ? 0.0.h
                  : 0.015.h
              : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).orgChart,
            style: StyleText.fontSize16Weight400.copyWith(
                fontSize: isTablet
                    ? isPortrait
                        ? 24.sp
                        : 32.sp
                    : 20.sp,
                fontWeight: FontWeight.w600,
                letterSpacing:
                    Get.locale.toString().contains('en') ? 1.1 : null,
                color: Theme.of(context).colorScheme.inverseSurface),
          ),
          Mode.hr || Mode.owner
              ? ButtonsBesideTitle(
                  chartSelected: employeeController.chartSelected,
                  chartSelectedState: (value) {
                    employeeController.chartSelected = value;
                    employeeController.update();
                  },
                  orgSelected: employeeController.orgSelected,
                  orgSelectedState: (value) {
                    employeeController.orgSelected = value;
                    employeeController.update();
                  },
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
