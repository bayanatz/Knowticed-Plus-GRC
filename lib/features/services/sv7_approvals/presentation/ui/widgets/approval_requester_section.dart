/// Module: services / sv7_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approval_requester_section.dart
/// Purpose: The requester block of the approval details page (name,
///          department, job title) in its phone, tablet and desktop layouts.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/responsive_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ApprovalRequesterSection extends StatelessWidget {
  const ApprovalRequesterSection({
    required this.name,
    required this.department,
    required this.jobTitle,
    super.key,
  });

  /// Values already in the reader's language ('-' when unknown).
  final String name;
  final String department;
  final String jobTitle;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final nameRow = CustomRowDetailsMaster(
      data: FormatHelper.capitalize(name),
      image: 'assets/icons_assets/main_icons_assets/ic_user_profile.svg',
      title: '${s.Requestedby}: ',
    );
    final departmentRow = CustomRowDetailsMaster(
      data: department,
      image: 'assets/icons_assets/main_icons_assets/ic_org_hierarchy.svg',
      title: '${s.Department}: ',
    );
    final jobTitleRow = CustomRowDetailsMaster(
      data: FormatHelper.capitalize(jobTitle),
      image: 'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
      title: '${s.jobTitle}: ',
    );

    if (ContextExtension(context).isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          nameRow,
          SizedBox(height: 5.sp),
          departmentRow,
          SizedBox(height: 10.sp),
          jobTitleRow,
        ],
      );
    }

    final isTablet =
        !kpIsPhoneLayout(context) && MediaQuery.sizeOf(context).width < 900;
    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameRow,
              SizedBox(height: 5.sp),
              departmentRow,
            ],
          ),
          SizedBox(width: MediaQuery.sizeOf(context).width * .15),
          jobTitleRow,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: nameRow),
        Expanded(child: departmentRow),
        Expanded(child: jobTitleRow),
      ],
    );
  }
}
