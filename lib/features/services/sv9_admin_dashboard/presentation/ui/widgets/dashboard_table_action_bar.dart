/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_table_action_bar.dart
/// Purpose: Search, Filter, and Export action bar for the dashboard table
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/request_rows_filter.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/admin_dashboard_export.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_admin_export_widget.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/filter_table.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_table_section.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Signature for [DashboardTableActionBar.onChanged].
typedef DashboardTableFiltersChanged = void Function(
  String searchQuery,
  List<String> departments,
  List<String> statuses,
  DateTime? date,
);

class DashboardTableActionBar extends StatefulWidget {
  final DashboardAdminState state;

  /// SVC-DASH-10: the rows Export saves — the same filtered list the table
  /// shows. Falls back to the unfiltered rows when not given.
  final List<Map<String, dynamic>>? exportItems;

  /// FIX 25/9/2026 (bug report p7/p25 "Filter not work"): the search text and
  /// the filter dialog result only lived in this widget's State — the table
  /// under it was always built with empty filters. Every change is now
  /// reported here so the parent can pass it to the table.
  final DashboardTableFiltersChanged? onChanged;

  const DashboardTableActionBar({
    super.key,
    required this.state,
    this.onChanged,
    this.exportItems,
  });

  @override
  State<DashboardTableActionBar> createState() =>
      _DashboardTableActionBarState();
}

class _DashboardTableActionBarState extends State<DashboardTableActionBar> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _activeDepartments = [];
  List<String> _activeStatuses = [];
  DateTime? _activeDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged?.call(
        _searchController.text.trim(),
        _activeDepartments,
        _activeStatuses,
        _activeDate,
      );

  bool get _hasActiveFilters =>
      _activeDepartments.isNotEmpty ||
      _activeStatuses.isNotEmpty ||
      _activeDate != null;

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    return Container(
      margin: EdgeInsets.only(bottom: 15.sp),
      child: Row(
        children: [
          // ── Search ──────────────────────────────────────────────────────
          AppSearchTextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {});
              _notify();
            },
          ),
          SizedBox(width: ButtonSizing.toolbarGap(context)),

          // ── Filter ──────────────────────────────────────────────────────
          CustomFilterIcon(
            color: _hasActiveFilters ? AppColors.primary : AppColors.card,
            borderColor: AppColors.transparent,
            svgColor: _hasActiveFilters
                ? AppColors.textButton
                : AppColors.secondaryText,
            title: S.of(context).Filter,
            onTap: () async {
              final result = await TableFilterDialog.show(
                context,
                activeDepartments: _activeDepartments,
                activeStatuses: _activeStatuses,
                activeDate: _activeDate,
              );
              if (result != null) {
                setState(() {
                  _activeDepartments = List<String>.from(
                    result['departments'] ?? [],
                  );
                  _activeStatuses = List<String>.from(result['statuses'] ?? []);
                  _activeDate = result['date'];
                });
                _notify();
              }
            },
          ),
          // ── Export ──────────────────────────────────────────────────────
          if (ServicesModuleAccess.canExportRequestedServices) ...[
            SizedBox(width: ButtonSizing.toolbarGap(context)),
            GestureDetector(
              onTapDown: (_) => HapticController.low(),
              onTap: () async {
                final fileName = await ExportFileDialog.show(context);
                if (fileName != null && fileName.isNotEmpty) {
                  if (!context.mounted) return;
                  await AdminExportService.exportRequestsToCSV(
                    context: context,
                    fileName: fileName,
                    displayedItems:
                        widget.exportItems ?? widget.state.displayedItems,
                    selectedDepartment: widget.state.selectStatus,
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
                child: !isMobile
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomSvgImage.natural(
                            assetPath:
                                "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                            width: 20.sp,
                            height: 20.sp,
                            color: AppColors.textButton,
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
                      )
                    : Center(
                        child: CustomSvgImage.natural(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                          width: 20.sp,
                          height: 20.sp,
                          color: AppColors.textButton,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Action bar + requests table wired together, so search and the Filter
/// dialog actually filter the table (bug report p7/p25).
class DashboardFilterableRequestsTable extends StatefulWidget {
  final DashboardAdminState state;
  final bool isMobile;

  /// When false only the action bar is drawn (the Statistics tab keeps the
  /// bar but shows its own content below it).
  final bool showTable;

  const DashboardFilterableRequestsTable({
    super.key,
    required this.state,
    required this.isMobile,
    this.showTable = true,
  });

  @override
  State<DashboardFilterableRequestsTable> createState() =>
      _DashboardFilterableRequestsTableState();
}

class _DashboardFilterableRequestsTableState
    extends State<DashboardFilterableRequestsTable> {
  String _search = '';
  List<String> _departments = const [];
  List<String> _statuses = const [];
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final departmentCubit = context.read<MainCoreDepartmentCubit>();
    final filtered = RequestRowsFilter.apply(
      widget.state.displayedItems,
      search: _search,
      departments: _departments,
      statuses: _statuses,
      date: _date,
      departmentNameToId: (name) => departmentCubit
          .getDepartmentIdFromDepartmentName(departmentName: name),
    );
    return Column(
      children: [
        DashboardTableActionBar(
          state: widget.state,
          exportItems: filtered,
          onChanged: (search, departments, statuses, date) => setState(() {
            _search = search;
            _departments = List<String>.from(departments);
            _statuses = List<String>.from(statuses);
            _date = date;
          }),
        ),
        if (widget.showTable)
          DashboardTableSection(
            selectStatus: widget.state.selectStatus,
            searchQuery: _search,
            activeDepartments: _departments,
            activeStatuses: _statuses,
            activeDate: _date,
            isMobile: widget.isMobile,
            displayedItems: filtered,
            isLoadingRequests: widget.state.isLoadingRequests,
          ),
      ],
    );
  }
}
