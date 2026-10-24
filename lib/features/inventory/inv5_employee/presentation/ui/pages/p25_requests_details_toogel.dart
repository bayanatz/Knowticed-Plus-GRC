import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv5_employee/presentation/ui/pages/p25_requests_details.dart';

class RequestsDetailsSection extends StatelessWidget {
  const RequestsDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return RequestsDetailsSectionDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return RequestsDetailsSectionDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return RequestsDetailsSectionDesktopScreen();
          } else {
            return RequestsDetailsSectionDesktopScreen();
          }
        },
      ),
    );
  }
}
