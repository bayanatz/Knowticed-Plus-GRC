import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv5_employee/presentation/ui/pages/p24_requests.dart';

class RequestsSection extends StatelessWidget {
  const RequestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return RequestsDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return RequestsDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return RequestsDesktopScreen();
          } else {
            return RequestsDesktopScreen();
          }
        },
      ),
    );
  }
}
