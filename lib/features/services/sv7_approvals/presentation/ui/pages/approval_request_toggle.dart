/// Module: services / sv7_approvals / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_toggle.dart
/// Purpose: Picks the phone, tablet or desktop layout of the approvals list.
/// Author: Amr Mesbah
/// Created at: 30/08/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/pages/approval_request.dart';

class ApprovalToggle extends StatelessWidget {
  const ApprovalToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // S7-024: every responsive branch resolved to the same widget — the variant
    // router was dead code (§17).
    return Scaffold(body: ApprovalServices());
  }
}

/*

return Scaffold(
body: LayoutBuilder(
builder: (context, constrain){
if (constrain.maxWidth >= 1200) {
return ApprovalMasterFullScreen(); // Desktop
} else if (constrain.maxWidth >= 900) {
return ApprovalMasterDesktop(); // Horizontal tablet
} else if (constrain.maxWidth >= 600) {
return ApprovalMasterTablet(); // // tablet
} else {
return MasterApprovalMobile(); // mobile
}

}),
);
 */
