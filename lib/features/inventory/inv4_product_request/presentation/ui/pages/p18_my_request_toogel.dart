import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p18_my_request.dart';

class MyRequest extends StatelessWidget {
  const MyRequest({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return MyRequestDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return MyRequestDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return MyRequestDesktopScreen();
          } else {
            return MyRequestDesktopScreen();
          }
        },
      ),
    );
  }
}
