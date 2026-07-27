// lib/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';

class AssignmentControlCard extends StatelessWidget {
  final AssignmentControlItem item;
  final bool isArabic;
  final VoidCallback onTap;

  const AssignmentControlCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final control = item.control;
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? control.controlsNameAr : control.controlsNameEn,
                    style: CardStyles.value(14),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isArabic ? control.controlsNumberAr : control.controlsNumberEn,
                    style: CardStyles.label(12),
                  ),
                ],
              ),
            ),
            Text(item.tab.label, style: CardStyles.label(12)),
          ],
        ),
      ),
    );
  }
}
