/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approval_cycle_widget.dart
/// Purpose: The approval cycle of a service: a vertical list on a phone and
///          rows of approvers on larger screens (both from approval.dart).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/approval.dart';

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ApprovalCycleWidgetServices extends StatelessWidget {
  const ApprovalCycleWidgetServices({required this.approvalCycle, super.key});
  final List<ServiceEmployeeModel> approvalCycle;

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    if (isMobile) {
      return buildApprovalCycle(
        context,
        approvalCycle,
        "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
      );
    } else {
      return approvalCycleViewTablet(approvalCycle, context);
    }
  }
}
