/// Module: GRC / Approvals (Department Manager)
///
///*************************** FILE INFO ****************************///
/// File Name: approval_filter_dialog.dart
/// Purpose: The dialog behind the Approvals list's Filter button — narrows
///          the list to one Policy. Built from CustomDropdown (1) and
///          customButton (5).
/// Author: Knowticed Plus team
/// Created: 16/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

/// One choice in the policy filter: the policy id and its display name.
class ApprovalPolicyOption {
  final String id;
  final String name;
  const ApprovalPolicyOption({required this.id, required this.name});
}

/// function name: [showApprovalFilterDialog]
///
/// purpose: opens the filter dialog. Resolves to the chosen policy id,
///          `''` when the user cleared the filter, or null when dismissed
///          without a decision.
Future<String?> showApprovalFilterDialog({
  required BuildContext context,
  required List<ApprovalPolicyOption> policies,
  required String? selectedPolicyId,
}) {
  return showAppDialog<String>(
    context: context,
    barrierColor: AppColors.totalBlack.withValues(alpha: 0.4),
    builder: (_) => _ApprovalFilterDialog(
      policies: policies,
      initialPolicyId: selectedPolicyId,
    ),
  );
}

class _ApprovalFilterDialog extends StatefulWidget {
  final List<ApprovalPolicyOption> policies;
  final String? initialPolicyId;

  const _ApprovalFilterDialog({
    required this.policies,
    required this.initialPolicyId,
  });

  @override
  State<_ApprovalFilterDialog> createState() => _ApprovalFilterDialogState();
}

class _ApprovalFilterDialogState extends State<_ApprovalFilterDialog> {
  late String? _policyId = widget.initialPolicyId;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 24.sp),
      shape: RoundedRectangleBorder(borderRadius: CardStyles.radius()),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 450.sp),
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 20./20./10. row.
              CustomDialogHeader(
                  title: s.filter,
                  icon:
                      'assets/icons_assets/main_icons_assets/ic_action_filter.svg'),
              SizedBox(height: 20.h),
              CustomDropdown<String>(
                label: s.policyName,
                hint: s.all,
                value: _policyId,
                items: [
                  for (final ApprovalPolicyOption p in widget.policies)
                    DropdownItem<String>(value: p.id, label: p.name),
                ],
                onChanged: (v) => setState(() => _policyId = v),
              ),
              SizedBox(height: 25.h),
              Row(
                textDirection: TextDirection
                    .ltr, // X-73: Cancel left, action right in both languages

                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  customButton(
                    title: s.reset,
                    function: () => Navigator.of(context).pop(''),
                    width: 120.sp,
                    // GRC bug report p31: secondary-button style, same as
                    // Discard (darkGrey / white), not the field colour.
                    color: AppColors.darkGrey,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.white),
                  ),
                  SizedBox(width: 10.sp),
                  customButton(
                    title: s.apply,
                    function: () => Navigator.of(context).pop(_policyId ?? ''),
                    width: 120.sp,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
