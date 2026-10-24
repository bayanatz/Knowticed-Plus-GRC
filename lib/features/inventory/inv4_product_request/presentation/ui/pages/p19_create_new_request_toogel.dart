import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p19_create_new_request.dart';

class CreateNewRequest extends StatelessWidget {
  const CreateNewRequest({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return CreateNewRequestDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return CreateNewRequestDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return CreateNewRequestDesktopScreen();
          } else {
            return CreateNewRequestDesktopScreen();
          }
        },
      ),
    );
  }
}
