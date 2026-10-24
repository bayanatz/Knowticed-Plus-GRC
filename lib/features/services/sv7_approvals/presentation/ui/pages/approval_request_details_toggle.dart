/// Module: services / sv7_approvals / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_details_toggle.dart
/// Purpose: Picks the phone, tablet or desktop layout of the approval details
///          page.
/// Author: Amr Mesbah
/// Created at: 30/08/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/pages/approval_request_details.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ServicesApprovalDetailsToggle extends StatelessWidget {
  const ServicesApprovalDetailsToggle({
    super.key,
    required this.approvalModel,
    required this.index,
    this.fromTable = false,
    this.createServicesModel, // Optional parameter
  });

  final ServicesHistoryModel approvalModel;
  final int index;
  final bool fromTable;
  final ServicesHistoryModel? createServicesModel;

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isLandscape = ContextExtension(context).isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return ApprovalDetailsScreen(
              createServicesModel: createServicesModel,
              approvalModel: approvalModel,
              index: index,
              fromTable: fromTable,
            );
          } else if (isTablet && !isLandscape) {
            return ApprovalDetailsScreen(
              createServicesModel: createServicesModel,
              approvalModel: approvalModel,
              index: index,
              fromTable: fromTable,
            );
          } else if (!isTablet && isLandscape) {
            return ApprovalDetailsScreen(
              approvalModel: approvalModel,
              index: index,
            );
          } else {
            return ApprovalDetailsScreen(
              approvalModel: approvalModel,
              index: index,
            );
          }
        },
      ),
    );
  }
}

/*
return Scaffold(
body: LayoutBuilder(
builder: (context, constrain) {
if (constrain.maxWidth >= 1200) {
return ApprovalDetailsScreenFullScreen(
approvalModel: approvalModel,
index: index,

);
} else if (constrain.maxWidth >= 900) {
return ApprovalDetailsScreenDesktop(
approvalModel: approvalModel,
index: index,

);
} else if (constrain.maxWidth >= 600) {
return ApprovalDetailsScreenTablet(

createServicesModel: createServicesModel,
approvalModel: approvalModel,
index: index,
fromTable: fromTable,

);
} else {
return ApprovalDetailsScreenMobile(
approvalModel: approvalModel,
index: index,

);
}
},
),
);
 */
