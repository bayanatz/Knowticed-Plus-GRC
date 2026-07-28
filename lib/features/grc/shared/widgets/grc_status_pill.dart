import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';

/// Bordered, colored pill showing a status icon + label — the small badge
/// used on both the Assignment Controls and Approvals cards/details pages
/// (e.g. "Approved", "Rejected", "In Review"). Extracted because both
/// features built the exact same pill markup independently.
class GrcStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const GrcStatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(label, style: CardStyles.value(12).copyWith(color: color)),
        ],
      ),
    );
  }
}
