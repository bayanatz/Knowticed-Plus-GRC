// ***************************** FILE INFO ***************************** //
// File Name: department_action_rows.dart
// Purpose: Renders the visual search and action rows for Departments.
// Author: Mohamed Elrashidy
// Created At: 2026-08-26
// ********************************************************************* //

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/hr_employee_view_buttons.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/enums/ui_controllers/hr_employee_view_mode.dart';
import 'package:knowticed_plus/features/hr/hr10_departments/presentation/controller/department_locations_cubit.dart';
import 'package:knowticed_plus/features/hr/hr10_departments/presentation/ui/widgets/add_location_dialog.dart';

/// Displays the search and action controls from the Departments reference.
class DepartmentActionRows extends StatefulWidget {
  const DepartmentActionRows({super.key});

  @override
  State<DepartmentActionRows> createState() => _DepartmentActionRowsState();
}

class _DepartmentActionRowsState extends State<DepartmentActionRows> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final actions = _buildActions(localization);
        final isCompact = constraints.maxWidth < 760.w;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isCompact) ...[
              Row(children: [_buildSearchField()]),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: actions.sublist(0, 3),
              ),
            ] else
              Row(
                children: [
                  _buildSearchField(),
                  SizedBox(width: 16.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12.w,
                    children: actions.sublist(0, 3),
                  ),
                ],
              ),
            SizedBox(height: 12.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8.w,
                children: [
                  actions[3],
                  Spacer(),
                  HrEmployeeViewButtons(
                    selectedMode: HrEmployeeViewMode.grid,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Method Name: [_buildSearchField]
  ///
  /// Purpose: Builds the shared search field used by the reference layout.
  ///
  /// Returns: A search field with no filtering side effect in this phase.
  Widget _buildSearchField() {
    return AppSearchTextField(
      controller: _searchController,
      onChanged: context.read<DepartmentLocationsCubit>().updateSearchQuery,
    );
  }

  /// Method Name: [_buildActions]
  ///
  /// Purpose: Creates the visual action controls in reference order.
  ///
  /// Parameters:
  /// - [localization]: Localized action labels.
  ///
  /// Returns: Filter, import, location, and export controls.
  List<Widget> _buildActions(S localization) {
    return [
      CustomFilterIcon(
        title: localization.filter,
        onTap: () {},
        color: AppColors.card,
        svgColor: AppColors.secondaryBlack,
        // 22/10/2026 — Owner: dead textStyle removed — CustomFilterIcon draws its
        // label from ToolbarStyle (14 medium) since 18/10.
      ),
      _buildActionButton(
        title: localization.import,
        image: AppAssets.upload,
      ),
      _buildActionButton(
        title: localization.location,
        image: AppAssets.locationIcon,
        onPressed: _showAddLocationDialog,
      ),
      _buildActionButton(
        title: localization.export,
        image: AppAssets.export,
      ),
    ];
  }

  /// Method Name: [_buildActionButton]
  ///
  /// Purpose: Builds one static yellow action button.
  ///
  /// Parameters:
  /// - [title]: Localized action title.
  /// - [image]: Centralized SVG asset path.
  ///
  /// Returns: A shared action button with the supplied callback.
  Widget _buildActionButton({
    required String title,
    required String image,
    VoidCallback? onPressed,
  }) {
    return customButtonWithSvg(
      title: title,
      function: onPressed ?? () {},
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      color: AppColors.primary,
      image: image,
      widthImage: 20.sp,
      heightImage: 20.sp,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
      fixedWidth: 100.sp,
    );
  }

  /// Method Name: [_showAddLocationDialog]
  ///
  /// Purpose: Opens the location form with the existing page Cubit instance.
  ///
  /// Returns: Completes after the location dialog is dismissed.
  Future<void> _showAddLocationDialog() async {
    final cubit = context.read<DepartmentLocationsCubit>();
    final created = await showAppDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const AddLocationDialog(),
      ),
    );
    if (created == true && mounted) await cubit.loadLocations();
  }
}
