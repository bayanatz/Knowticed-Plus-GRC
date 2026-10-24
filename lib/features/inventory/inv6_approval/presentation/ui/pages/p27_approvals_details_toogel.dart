import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv6_approval/presentation/ui/pages/p27_approvals_details.dart';

class ApprovalsDetailsSection extends StatelessWidget {
  const ApprovalsDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return ApprovalDetailsDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return ApprovalDetailsDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return ApprovalDetailsDesktopScreen();
          } else {
            return ApprovalDetailsDesktopScreen();
          }
        },
      ),
    );
  }
}
