/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: search_approvals.dart
/// Description: Search approvals — Approvals (S6) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/approval_filter.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class SearchApprovals extends StatefulWidget {
  final TextEditingController searchApprovalsController;
  final VoidCallback? onStatusChanged;

  const SearchApprovals({
    super.key,
    required this.searchApprovalsController,
    this.onStatusChanged,
  });

  @override
  State<SearchApprovals> createState() => _SearchApprovalsState();
}

class _SearchApprovalsState extends State<SearchApprovals> {
  String? selectedDepartmentId;
  MainCoreDepartmentCubit get departmentController =>
      context.read<ApprovalsCubit>().people.departments;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    await departmentController.getAllDepartments();
    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, String>> _getDepartmentItems() {
    List<Map<String, String>> items = [];

    // Add "All Departments" option at the beginning
    items.add({"key": "all", "value": S.of(context).all_departments});

    // Add all departments
    for (int i = 0; i < departmentController.departmentIds.length; i++) {
      String departmentId = departmentController.departmentIds[i];
      String departmentName = KhLocale.pick(
        context,
        en: departmentController.departmentsEnglishName[i],
        ar: departmentController.departmentsArabicName[i],
      );

      items.add({"key": departmentId, "value": departmentName});
    }

    return items;
  }

  void _onDepartmentChanged(String? departmentId) {
    final cubit = context.read<ApprovalsCubit>();

    // Always reflect the chosen option in the trigger — including the
    // "All Departments" option (key "all"), which previously mapped to null and
    // left the trigger showing only the hint. The cubit still filters on null
    // for the show-everything case.
    setState(() => selectedDepartmentId = departmentId);
    cubit.filterByDepartment(
      (departmentId == null || departmentId == "all") ? null : departmentId,
    );
  }

  // ✅ Public method to reset department filter
  void resetDepartmentFilter() {
    if (selectedDepartmentId != null) {
      setState(() => selectedDepartmentId = null);
      final cubit = context.read<ApprovalsCubit>();
      cubit.filterByDepartment(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSearchTextField(
          controller: widget.searchApprovalsController,
          onChanged: (query) {
            context.read<ApprovalsCubit>().searchKnowledge(query);
          },
        ),

        isMobile
            ? SizedBox()
            : SizedBox(width: ButtonSizing.toolbarGap(context)),
        isMobile
            ? SizedBox()
            : SizedBox(
                width: 135.w,
                height: 38.sp,
                child: CustomDropdown<String>(
                  triggerPadding: EdgeInsets.symmetric(
                    vertical: 15.sp,
                    horizontal: 8.sp,
                  ),
                  // Same radius as the Filter button beside it (ButtonSizing.radius = 8.r).
                  borderRadius: BorderRadius.circular(ButtonSizing.radius),
                  value: selectedDepartmentId,
                  items: _getDepartmentItems()
                      .map(
                        (e) => DropdownItem<String>(
                          value: e['key'] ?? '',
                          label: e['value'] ?? '',
                        ),
                      )
                      .toList(),
                  onChanged: (v) => _onDepartmentChanged(v),
                  hint: S.of(context).department,
                  hintStyle: StyleText.fontSize14Weight400,
                  accentColor: _toolbarIdleColor,
                  fillColor: AppColors.card,
                ),
              ),

        SizedBox(width: ButtonSizing.toolbarGap(context)),

        // Custom filter action button (core/custom/14-custom_filter_icon.dart).
        // Handles mobile (icon-only) vs tablet/desktop (icon + text) sizing
        // internally, replacing the previous hand-rolled GestureDetector.
        //
        // Wrapped in a BlocBuilder so the button reflects the ACTIVE filter
        // state: once the user applies any filter (status / document type /
        // date range) it turns primary with textButton-colored icon & text, and
        // reverts when the filters are reset. CustomFilterIcon ties its text
        // color to [svgColor], so setting svgColor also recolors the label.
        BlocBuilder<ApprovalsCubit, ApprovalsStates>(
          builder: (context, state) {
            final cubit = context.read<ApprovalsCubit>();
            final bool isFilterActive = cubit.dialogFilterActive;

            return CustomFilterIcon(
              title: S.of(context).filter,
              iconOnly:
                  isMobile ||
                  MediaQuery.orientationOf(context) == Orientation.portrait,
              color: isFilterActive ? AppColors.primary : AppColors.card,
              svgColor: isFilterActive
                  ? AppColors.textButton
                  : (isMobile ? AppColors.secondaryText : _toolbarIdleColor),
              onTap: () {
                showAppDialog(
                  context: context,
                  builder: (ctx) => Center(
                    child: BlocProvider.value(
                      value: context.read<ApprovalsCubit>(),
                      child: ApprovalsFilterDialog(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Text + icon colour of the idle Filter button AND the Department dropdown,
/// so the two controls in the Approvals toolbar always match.
Color get _toolbarIdleColor => AppColors.secondaryText;
