import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';

/// White, rounded, shadowed card wrapper used for every "Details" section
/// (Policy Details, Control Details, Submissions/Approvals, ...) across the
/// Assignment Controls and Approvals pages. Extracted because both features
/// built the exact same container markup independently.
class GrcSectionCard extends StatelessWidget {
  final List<Widget> children;

  const GrcSectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
