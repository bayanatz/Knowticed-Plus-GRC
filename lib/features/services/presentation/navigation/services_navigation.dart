/// Module: services / presentation / navigation
///
///*************************** FILE INFO ****************************///
/// File Name: services_navigation.dart
/// Purpose: Moves between the module's screens by route name, so a
///          sub-module does not import another sub-module's page (Provider
///          rule 3). The routes are built by the module's Navigator
///          (responsive_services.dart).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_routes.dart';

/// Navigation helpers inside the services module.
extension ServicesNavigation on BuildContext {
  /// Function Name: [svcGoHome]
  ///
  /// Purpose: Back to the services home page (the module's first route).
  void svcGoHome() => Navigator.of(this).popUntil((route) => route.isFirst);

  /// Function Name: [svcOpenProviderPicker]
  ///
  /// Purpose: Opens the provider picker for [request].
  Future<void> svcOpenProviderPicker(ServicesHistoryModel request) =>
      Navigator.of(this)
          .pushNamed<void>(ServicesRoutes.editProvider, arguments: request);
}
