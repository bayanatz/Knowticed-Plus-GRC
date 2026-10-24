/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: details_action_bar.dart
/// Purpose: Search + Filter + Export action bar for Dashboard Details
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/presentation/widgets/dashboard/dashboard_requests_csv.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/dashboard_details_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/filter_dialog.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_admin_details_export_widget.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class DetailsActionBar extends StatelessWidget {
  final DashboardDetailsState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterApplied;
  final Function({
    String? department,
    String? status,
    DateTime? date,
    bool clearDepartment,
    bool clearStatus,
    bool clearDate,
  }) onFilterResult;
  final String locale;
  final ServiceRequestExportHelper exportHelper;

  const DetailsActionBar({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterApplied,
    required this.onFilterResult,
    required this.locale,
    required this.exportHelper,
  });

  bool get _hasActiveFilter =>
      (state.activeDepartment?.isNotEmpty == true) ||
      (state.activeStatus?.isNotEmpty == true) ||
      state.activeDate != null;

  @override
  Widget build(BuildContext context) {
    Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    return Row(
      children: [
        // ── Search ─────────────────────────────────────────────────────────
        AppSearchTextField(
          controller: searchController,
          onChanged: onSearchChanged,
        ),

        SizedBox(width: ButtonSizing.toolbarGap(context)),

        // ── Filter ─────────────────────────────────────────────────────────
        CustomFilterIcon(
          color: _hasActiveFilter ? AppColors.primary : AppColors.card,
          borderColor: AppColors.transparent,
          svgColor:
              _hasActiveFilter ? AppColors.textButton : AppColors.secondaryText,
          title: S.of(context).Filter,
          onTap: () async {
            final result = await ServiceRequestFilterDialog.show(
              context,
              state.filteredItems.map((item) {
                return ServicesHistoryModel.fromJson(
                  item['raw'] as Map<String, dynamic>,
                  item['docId'] as String,
                );
              }).toList(),
              currentDepartment: state.activeDepartment,
              currentStatus: state.activeStatus,
              currentDate: state.activeDate,
            );

            if (result != null) {
              onFilterResult(
                department: result['department'],
                status: result['status'],
                date: result['date'],
                clearDepartment: result['department'] == null,
                clearStatus: result['status'] == null,
                clearDate: result['date'] == null,
              );
            }
          },
        ),

        // ── Export (only on Requested Services tab) ─────────────────────────
        if (state.showRequestedServices &&
            ServicesModuleAccess.canExportRequestedServices) ...[
          SizedBox(width: ButtonSizing.toolbarGap(context)),
          GestureDetector(
            onTapDown: (_) => HapticController.low(),
            onTap: () async {
              final fileName = await exportHelper.showFileNameDialog(context);
              if (fileName != null && fileName.isNotEmpty) {
                if (!context.mounted) return;
                await DashboardRequestsCsv.export(
                  context,
                  items: state.displayedItems,
                  fileName: fileName,
                  enToArDepartments: state.enToArDepartments,
                );
              }
            },
            child: Container(
              width: isMobile ? 38.w : 100.w,
              height: ButtonSizing.height,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: isMobile
                  ? Center(
                      child: SvgPicture.asset(
                        AppAssets.export,
                        width: 20.sp,
                        height: 20.sp,
                        colorFilter: ColorFilter.mode(
                          AppColors.textButton,
                          BlendMode.srcIn,
                        ),
                        fit: BoxFit.scaleDown,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.export,
                          width: 20.sp,
                          height: 20.sp,
                          colorFilter: ColorFilter.mode(
                            AppColors.textButton,
                            BlendMode.srcIn,
                          ),
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          S.of(context).export,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
