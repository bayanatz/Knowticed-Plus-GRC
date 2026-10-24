/// Module: services / sv7_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approval_provider_section.dart
/// Purpose: The provider block of the approval details page: the assigned
///          provider's details, or a notice (with "Assign provider" when
///          opened from the table) when the request has no provider.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/presentation/ui/pages/select_services_provider_toggle.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/provider_details.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ApprovalProviderSection extends StatelessWidget {
  const ApprovalProviderSection({
    required this.model,
    required this.fromTable,
    required this.duration,
    required this.durationUnit,
    required this.state,
    required this.onProviderChanged,
    super.key,
  });

  /// The request, as last read.
  final ServicesHistoryModel model;

  /// Opened from the dashboard table (the provider can be changed there).
  final bool fromTable;
  final String duration;
  final String durationUnit;

  /// The request's saved status.
  final String state;

  /// Called after the provider page closes, so the page can re-read.
  final VoidCallback onProviderChanged;

  Future<void> _openProviderPage(BuildContext context) async {
    await navigateToAsync<void>(
      context,
      ServicesProviderLayout(
        editingModel: model,
        docId: model.currentId,
        editProvider: model,
      ),
    );
    onProviderChanged();
  }

  ServiceEmployeeModel _assigned(List<ServiceEmployeeModel> providers) {
    final assigned = model.currentAssignedProviderEmail.toLowerCase().trim();
    if (assigned.isEmpty) return providers.first;
    return providers.firstWhere(
      (p) => (p.email?.toLowerCase().trim() ?? '') == assigned,
      orElse: () => providers.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final providers = model.currentProviderServices;
    if (providers.isEmpty) return _buildEmpty(context);
    return buildProviderDetailsSectionMaster(
      onTap: () => _openProviderPage(context),
      table: fromTable,
      context: context,
      duration: duration,
      durationUnit: durationUnit,
      approvalCycle: model.currentApprovalCycle,
      model: _assigned(providers),
      state: state,
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.secondaryText.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.secondaryText,
                  size: 20.sp,
                ),
                SizedBox(width: 8.sp),
                Expanded(
                  child: Text(
                    S.of(context).svcNoProviderAssigned,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
            if (fromTable) ...[
              SizedBox(height: 12.sp),
              GestureDetector(
                onTap: () => _openProviderPage(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.sp,
                    vertical: 8.sp,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppColors.primary, size: 16.sp),
                      SizedBox(width: 4.sp),
                      Text(
                        S.of(context).svcAssignProvider,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
