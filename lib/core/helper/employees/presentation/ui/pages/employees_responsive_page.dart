import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/mobile/employees_screen_mobile.dart';
import 'package:demo_app/features/settings/presentation/controller/settings_controller.dart';

import 'package:demo_app/core/helper/employees/core_widgets/main_widget/responsive_helper.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/tablet/employees_screen.dart';
GlobalKey employeesNavKey = GlobalKey();

class EmployeesResponsivePage extends StatelessWidget {
   EmployeesResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    return ResponsiveHelper(
        mobileWidget: EmployeesScreenMobile(), tabletWidget:
     Navigator(
       key: employeesNavKey,
      onGenerateRoute: (settings) {

        return MaterialPageRoute(
          builder: (context) => EmployeesScreen(),
        );
      },
     )
    );
  }
}
