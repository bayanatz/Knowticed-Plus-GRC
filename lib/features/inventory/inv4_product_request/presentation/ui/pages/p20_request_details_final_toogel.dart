import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p20_request_details_final.dart';

class RequestType extends StatelessWidget {
  const RequestType({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return RequestDetailsFinalDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return RequestDetailsFinalDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return RequestDetailsFinalDesktopScreen();
          } else {
            return RequestDetailsFinalDesktopScreen();
          }
        },
      ),
    );
  }
}
