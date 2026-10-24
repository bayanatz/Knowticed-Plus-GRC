// ****************** FILE INFO ******************
// File Name: crm_requests_page.dart
// Purpose: Client-deal scoped live quote approval requests page.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_requests_tab.dart';

class CrmRequestsPage extends StatelessWidget {
  final String clientId;
  final String dealId;
  final String dealTitle;

  const CrmRequestsPage({
    super.key,
    required this.clientId,
    required this.dealId,
    required this.dealTitle,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: 'Deals',
          secondTitle: dealTitle,
          thirdTitle: 'Requests',
          onFirstTap: () => Navigator.pop(context),
          onSecondTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.only(bottom: 32.sp),
            child: CrmDealRequestsTab(
              clientId: clientId,
              dealId: dealId,
              dealTitle: dealTitle,
            ),
          ),
        ),
      );
}
