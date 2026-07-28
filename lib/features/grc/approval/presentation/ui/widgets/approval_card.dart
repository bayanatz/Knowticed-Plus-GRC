import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_item.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_resolver.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_status.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_score_badge.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_status_pill.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');

class ApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  final bool isArabic;
  final VoidCallback onTap;

  const ApprovalCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final control = item.control;
    final policy = item.policy;
    final championEmail = item.assignmentControl.controlChampionEmail;
    final championName = employeeDisplayName(context, championEmail);
    final championPhoto = findEmployeeByEmail(championEmail).displayPhoto;
    final score = item.assignmentControl.controlScore;
    final style = ApprovalStatusStyle.of(item.approval.status);

    return InkWell(
      onTap: onTap,
      borderRadius: CardStyles.radius(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(),
          boxShadow: CardStyles.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isArabic ? control.controlsNameAr : control.controlsNameEn,
                    style: CardStyles.value(14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${'Request Date'.tr}: ${_cardDateFormat.format(item.assignmentControl.lastModificationDate)}',
                  style: CardStyles.label(11),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              '${'Policy Name'.tr}: ${isArabic ? policy.policyNameAr : policy.policyNameEn}',
              style: CardStyles.label(12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text('${'Control Champion'.tr}: ', style: CardStyles.label(12)),
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: AppColors.barrierColor,
                  backgroundImage:
                      championPhoto.startsWith('http') ? NetworkImage(championPhoto) : null,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    championName,
                    style: CardStyles.value(12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (score != null) ...[
                  GrcScoreBadge(score: score),
                  SizedBox(width: 8.w),
                ],
                if (item.approval.status != ApprovalStatus.pending)
                  GrcStatusPill(
                    label: item.approval.status.value.tr,
                    color: style.color,
                    icon: style.icon,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
