/// Module: services / sv1_home_page_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: home_page_services_toggle.dart
/// Purpose: toggle in All Platform of this screen Created by: Amr Mesbah Last
///          Update: 30/8/2025
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services.dart';

class LayoutScreenServices extends StatelessWidget {
  const LayoutScreenServices({super.key});

  @override
  Widget build(BuildContext context) {
    // N08/T01: every responsive branch resolved to the same widget, so the
    // variant router was dead code. All layouts share one implementation.
    return const Scaffold(body: ServicesScreenTablet());
  }
}
