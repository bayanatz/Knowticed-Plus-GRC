/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: master_action_bar.dart
/// Purpose: Search + Filter + Export bar for DashBoard Master
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_cubit.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_state.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/export_widget.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/filter_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/services/presentation/widgets/dashboard/dashboard_requests_csv.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MasterActionBar extends StatelessWidget {
  final DashboardMasterState state;
  final DashboardMasterCubit cubit;
  final TextEditingController searchController;
  final String locale;
  final bool showExport;

  const MasterActionBar({
    super.key,
    required this.state,
    required this.cubit,
    required this.searchController,
    required this.locale,
    required this.showExport,
  });

  bool get _hasActiveFilter =>
      (state.activeDepartment?.isNotEmpty == true) ||
      (state.activeStatus?.isNotEmpty == true) ||
      state.activeDate != null;

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    return Row(
      children: [
        // ── Search ──
        // ✅ FIX: AppSearchTextField already returns an Expanded internally, so
        // wrapping it in another one throws "Competing ParentDataWidgets".
        AppSearchTextField(
          controller: searchController,
          onChanged: cubit.onSearchChanged,
        ),

        // ── Filter + Export: only on Requested Services tab ──
        if (showExport) ...[
          SizedBox(width: ButtonSizing.toolbarGap(context)),

          // ── Filter ──
          CustomFilterIcon(
            color: _hasActiveFilter ? AppColors.primary : AppColors.card,
            borderColor: AppColors.transparent,
            svgColor: _hasActiveFilter
                ? AppColors.textButton
                : AppColors.secondaryText,
            title: isMobile ? '' : S.of(context).filter,
            onTap: () async {
              final result = await FilterDialogDashBoard.show(
                context: context,
                currentDepartment: state.activeDepartment,
                currentStatus: state.activeStatus,
                currentDate: state.activeDate,
                departmentEnToAr: state.enToArDepartments,
                filterText: S.of(context).Filter,
                departmentText: S.of(context).department,
                requestDateText: S.of(context).requestDate,
                statusText: S.of(context).status,
                resetText: S.of(context).Reset,
                applyText: S.of(context).Apply,
                primaryColor: AppColors.primary,
              );
              if (result != null) {
                cubit.applyFilters(
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

          // ── Export ──
          if (ServicesModuleAccess.canExportRequestedServices) ...[
            SizedBox(width: ButtonSizing.toolbarGap(context)),
            customButtonWithSvg(
              color: AppColors.primary,
              width: !isMobile ? 100.w : 38.w,
              height: ButtonSizing.height,
              svgColor: AppColors.textButton,
              space: isMobile ? 0.sp : 8.sp,
              title: isMobile ? '' : S.of(context).export,
              function: () async {
                final fileName = await FileNameDialog.show(
                  context,
                  exportText: S.of(context).export,
                  fileNameText: S.of(context).fileName,
                  textHereHint: S.of(context).Texthere,
                  discardText: S.of(context).discard,
                  downloadText: S.of(context).download,
                  primaryColor: AppColors.primary,
                  buttonTextColor: AppColors.textButton,
                );
                if (fileName == null || fileName.isEmpty) return;
                if (!context.mounted) return;
                // SVC-DASH-10: export what the table shows (after search
                // and filters), not the unfiltered list.
                await DashboardRequestsCsv.export(
                  context,
                  items: state.displayedItems,
                  fileName: fileName,
                  enToArDepartments: state.enToArDepartments,
                );
              },
              textStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.textButton,
              ),
              image: AppAssets.export,
              widthImage: 20.w,
              heightImage: 20.h,
              radius: 8.r,
              colorBorder: AppColors.transparent,
            ),
          ],
        ],
      ],
    );
  }
}
