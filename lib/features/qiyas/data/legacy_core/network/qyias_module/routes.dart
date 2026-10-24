import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/helper/adaptive_ui_handler.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/ui/pages/champigan_tasks_page.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/home/presentation/ui/pages/champigan_home_page.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/pages/mobile/qiyas_create_control_champion_mobile.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/pages/tablet/qiyas_create_control_champion.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/ui/pages/champigan_task_details_page.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/helper/service_locator.dart';

class Routes {
  static const String createControlChampion = 'qiyascreateControlChampion';
  static const String champiganHome = 'champiganHome';
  static const String champiganTasksPage = 'champiganTasksPage';
  static const String champiganTaskDetailsPage = 'champiganTaskDetailsPage';
}

class GRCRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.createControlChampion:
        {
          return MaterialPageRoute(
              builder: (_) => BlocProvider<ControlCoreCubit>.value(
                    value: sl<QiyasCreateChampionControllerCubit>(),
                    child: const AdaptiveUiHandler(
                        mobileWidget: QiyasCreateControlChampionMobile(),
                        tabletWidget: QiyasCreateControlChampion()),
                  ));
        }
      case Routes.champiganHome:
        return MaterialPageRoute(builder: (_) => ChampiganHomePage());

      case Routes.champiganTasksPage:
        return MaterialPageRoute(builder: (_) => ChampiganTasksPage());
      case Routes.champiganTaskDetailsPage:
        return MaterialPageRoute(builder: (_) => ChampiganTaskDetailsPage());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                    body: Center(
                  child: Text('No route defined for ${settings.name}'),
                )));
    }
  }
}
