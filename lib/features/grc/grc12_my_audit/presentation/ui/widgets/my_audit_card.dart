import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/custom/cards/custom_card_styles.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/grc/grc12_my_audit/domain/entities/my_audit_item.dart';
import 'package:grc_module/features/grc/grc12_my_audit/domain/entities/my_audit_tab.dart';
import 'package:grc_module/features/grc/helpers/grc_assignment_lookup.dart';
import 'package:grc_module/features/grc/presentation/ui/widgets/grc_score_badge.dart';
import 'package:grc_module/features/grc/presentation/ui/widgets/grc_status_pill.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/grc/helpers/grc_l10n.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

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
      onTap: withHaptic(onTap, HapticLevel.low),
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
                if (ac?.controlScore != null)
                  GrcScoreBadge(score: ac!.controlScore!),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              '${S.of(context).policyName}: ${isArabic ? policy.policyNameAr : policy.policyNameEn}',
              style: CardStyles.label(12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (ac != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text('${S.of(context).controlChampion}: ',
                      style: CardStyles.label(12)),
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
                  '${S.of(context).dueDate}: ${_cardDateFormat.format(control.endDate)}',
                  style: CardStyles.label(12).copyWith(
                    color: item.tab == MyAuditTab.overdue ? Colors.red : null,
                  ),
                ),
                GrcStatusPill(
                  label: grcTr(context, item.tab.label),
                  color: style.pillColor,
                  icon: style.icon,
                  svgAsset: style.svgAsset,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
