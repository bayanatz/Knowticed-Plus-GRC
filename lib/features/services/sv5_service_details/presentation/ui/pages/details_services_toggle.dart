/// Module: services / sv5_service_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: details_services_toggle.dart
/// Purpose: toggle in All Platform of this screen Created by: Amr Mesbah Last
///          Update: 30/8/2025
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/pages/details_services.dart';

class ToggleDetailsServicesLayout extends StatelessWidget {
  const ToggleDetailsServicesLayout({
    required this.createServicesModel,
    super.key,
  });

  final ServicesHistoryModel createServicesModel;

  @override
  Widget build(BuildContext context) {
    // S5-N07: every responsive branch resolved to the same widget — the variant
    // router was dead code (§17).
    return Scaffold(
      body: DetailsServicesPage(createServicesModel: createServicesModel),
    );
  }
}
