/// Module: GRC Module Management
/// Description: Provides the Module Owner section for the GRC Module details
///              page. In view/restore mode shows only selected owners; in
///              create/edit mode shows all employees with a search field so
///              the user can toggle selection.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: GrcOwnerCubit, PersonChipCard, AppSearchTextField
/// Revision History: 2026-06-29 - Initial creation
///                    2026-06-30 - Added initialOwnerEmails for pre-selection (Mohamed Magdy Abdelkhalek)
library;

import 'package:demo_app/core/custom/19-Custom_Employee_Card.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_owner_section.dart
/// Purpose: Contains GrcOwnerSection, which renders the owner-selection grid
///          for a GRC Module in both view and edit modes.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [GrcOwnerSection]
///
/// purpose: displays the Module Owner picker section inside the GRC Module
///          details page. Owns a private [GrcOwnerCubit] instance and passes
///          [initialOwnerEmails] to pre-select existing owners. In view/restore
///          mode only selected owners are shown; in create/edit mode all
///          employees appear with a search bar.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 29/6/2026
class GrcOwnerSection extends StatefulWidget {
  final bool isViewMode;

  /// Emails of owners already assigned to the module.
  /// - In view/restore mode  → only these owners are displayed.
  /// - In create/edit mode   → these owners are pre-selected.
  final List<String> initialOwnerEmails;

  /// The department currently selected on the form. When set, only
  /// employees belonging to this department are shown as owner candidates.
  final String? selectedDepartmentName;

  final void Function(List<OwnerData> selected)? onOwnersChanged;

  const GrcOwnerSection({
    super.key,
    this.isViewMode = false,
    this.initialOwnerEmails = const [],
    this.selectedDepartmentName,
    this.onOwnersChanged,
  });

  @override
  State<GrcOwnerSection> createState() => _GrcOwnerSectionState();
}

class _GrcOwnerSectionState extends State<GrcOwnerSection> {
  late final GrcOwnerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GrcOwnerCubit();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cubit.loadOwners(
        context,
        initialOwnerEmails: widget.initialOwnerEmails,
        selectedDepartmentName: widget.selectedDepartmentName,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant GrcOwnerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDepartmentName != widget.selectedDepartmentName) {
      _cubit.filterByDepartment(widget.selectedDepartmentName);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  ImageProvider _buildAvatar(String photo) {
    if (photo.startsWith('http')) return NetworkImage(photo);
    return AssetImage(photo);
  }

  void _onToggle(int index) {
    _cubit.toggleOwner(index);
    widget.onOwnersChanged?.call(_cubit.selectedOwners);
  }

  Widget _buildOwnerGrid(BuildContext context, List<OwnerData> owners) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    if (isTablet) {
      // 2-column grid
      return Column(
        children: List.generate((owners.length / 2).ceil(), (i) {
          final left = owners[i * 2];
          final rightIdx = i * 2 + 1;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: PersonChipCard(
                    name: left.name,
                    subtitle1: left.department,
                    subtitle2: left.jobTitle,
                    avatar: _buildAvatar(left.photo),
                    isSelected: left.isSelected,
                    showCheckBox: !widget.isViewMode,
                    width: double.infinity,
                    backgroundColor: AppColors.background,
                    onTap: widget.isViewMode ? null : () => _onToggle(i * 2),
                  ),
                ),
                SizedBox(width: 10.w),
                if (rightIdx < owners.length)
                  Expanded(
                    child: PersonChipCard(
                      name: owners[rightIdx].name,
                      subtitle1: owners[rightIdx].department,
                      subtitle2: owners[rightIdx].jobTitle,
                      avatar: _buildAvatar(owners[rightIdx].photo),
                      isSelected: owners[rightIdx].isSelected,
                      showCheckBox: !widget.isViewMode,
                      width: double.infinity,
                      backgroundColor: AppColors.background,
                      onTap:
                          widget.isViewMode ? null : () => _onToggle(rightIdx),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
        }),
      );
    }

    // Mobile: 1-column list (full-width cards)
    return Column(
      children: List.generate(owners.length, (i) {
        final owner = owners[i];
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: PersonChipCard(
            name: owner.name,
            subtitle1: owner.department,
            subtitle2: owner.jobTitle,
            avatar: _buildAvatar(owner.photo),
            isSelected: owner.isSelected,
            showCheckBox: !widget.isViewMode,
            width: double.infinity,
            backgroundColor: AppColors.background,
            onTap: widget.isViewMode ? null : () => _onToggle(i),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<GrcOwnerCubit, GrcOwnerState>(
        builder: (context, state) {
          // In view/restore mode show only the selected (assigned) owners.
          // In create/edit mode show all employees so the user can pick.
          final owners = widget.isViewMode
              ? _cubit.filteredOwners.where((o) => o.isSelected).toList()
              : _cubit.filteredOwners;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Module Owner'.tr,
                style: AppTextStyles.font16BlackRegularCairo
                    .copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              if (!widget.isViewMode) ...[
                Row(
                  children: [
                    AppSearchTextField(
                      controller: _cubit.searchController,
                      onChanged: _cubit.search,
                      hintText: 'Search'.tr,
                      fillColor: AppColors.background,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
              if (owners.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: Text(
                      widget.isViewMode
                          ? 'No owners assigned'.tr
                          : 'No people found'.tr,
                      style: AppTextStyles.font16BlackRegularCairo.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                )
              else
                _buildOwnerGrid(context, owners),
            ],
          );
        },
      ),
    );
  }
}
