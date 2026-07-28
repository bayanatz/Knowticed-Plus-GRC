import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_item.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_tab.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_score_badge.dart';
import 'package:demo_app/features/grc/shared/widgets/grc_status_pill.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');

class MyAuditCard extends StatelessWidget {
  final MyAuditItem item;
  final bool isArabic;
  final VoidCallback onTap;

  const MyAuditCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final control = item.control;
    final policy = item.policy;
    final ac = item.assignmentControl;
    final style = MyAuditTabStyle.of(item.tab);

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
                if (ac?.controlScore != null) GrcScoreBadge(score: ac!.controlScore!),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              '${'Policy Name'.tr}: ${isArabic ? policy.policyNameAr : policy.policyNameEn}',
              style: CardStyles.label(12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (ac != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text('${'Control Champion'.tr}: ', style: CardStyles.label(12)),
                  Expanded(
                    child: Text(
                      employeeDisplayName(context, ac.controlChampionEmail),
                      style: CardStyles.value(12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'Due Date'.tr}: ${_cardDateFormat.format(control.endDate)}',
                  style: CardStyles.label(12).copyWith(
                    color: item.tab == MyAuditTab.overdue ? Colors.red : null,
                  ),
                ),
                GrcStatusPill(label: item.tab.label.tr, color: style.color, icon: style.icon),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
