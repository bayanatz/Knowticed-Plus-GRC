import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv6_approval/presentation/ui/pages/p26_approvals.dart';

class ApprovalsSection extends StatelessWidget {
  const ApprovalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return ApprovalDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return ApprovalDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return ApprovalDesktopScreen();
          } else {
            return ApprovalDesktopScreen();
          }
        },
      ),
    );
  }
}
