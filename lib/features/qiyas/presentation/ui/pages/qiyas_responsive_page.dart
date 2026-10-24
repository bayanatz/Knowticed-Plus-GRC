import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/qyias_module/routes.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/mobile/qiyas_home_screen_mobile.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/tablet/qiyas_home_screen_tablet.dart';

class QiyasResponsivePage extends StatelessWidget {
  const QiyasResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    //sl<QiyasHomeCubit>();

    //  configureGRCDependencies();
    return ResponsiveHelper(
      mobileWidget: mobileSelector(),
      tabletWidget: Navigator(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (_) => tabletSelector());
          }

          return GRCRouteGenerator.generateRoute(settings);
        },
      ),
    );
  }

  Widget mobileSelector() {
    return QiyasHomeScreenMobile();
  }

  Widget tabletSelector() {
    final employee = Get.find<MainCoreEmployeeController>().employeeEntity!;
    debugPrint("is employee is admin: ${employee.isManager()}");
    return QiyasHomeScreenTablet();
  }
}
