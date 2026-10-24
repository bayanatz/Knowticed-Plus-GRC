/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: results_department_filter.dart
/// Description: `ResultsDepartmentFilter` — the Department filter beside the
///              search bar on the Results page (Pending and Submissions tabs).
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// Was a single-choice dropdown (CustomDropdown on Pending, AppDropdown on
/// Submissions). It is now the app's multi-select
/// (core/custom/31-custom_multi_select_dropdown.dart): pick any number of
/// departments, nothing picked = everyone. Same 38 height and 8.r corners as
/// the search bar beside it.
library;

import 'package:knowticed_plus/features/form_builder/helpers/department_display_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';

/// The Results "Department" multi-select (department ids; none = everyone).
class ResultsDepartmentFilter extends StatelessWidget {
  const ResultsDepartmentFilter({super.key});

  /// Same raw height the search fields on this page use (scaled in .sp).
  static const double _kHeight = 38;

  /// The picked department ids, read from the state.
  static List<String> _selected(ResultCubit cubit) {
    final state = cubit.state;
    return state is ResultLoaded ? state.selectedDepartmentIds : const [];
  }

  @override
  Widget build(BuildContext context) {
    final ResultCubit cubit = context.read<ResultCubit>();

    // FB-RESULT-04: the value is the department ID; only the label is a name.
    final List<MultiSelectDropdownItem<String>> items =
        <MultiSelectDropdownItem<String>>[
      for (final department
          in context.read<MainCoreDepartmentCubit>().departmentModels)
        MultiSelectDropdownItem<String>(
          value: department.departmentID ?? '',
          label: department.displayName(),
        ),
    ];

    final String departmentLabel = S.of(context).department;

    // Large-screen bug report p.12: held to exactly the search bar's 38.sp
    // and centred, so the two share one top and bottom edge.
    return SizedBox(
      width: 150.sp,
      height: _kHeight.sp,
      child: Align(
        alignment: Alignment.center,
        child: CustomMultiSelectFilter<String>(
          items: items,
          values: _selected(cubit),
          hint: departmentLabel,
          height: _kHeight,
          // The whole box is 38 tall and the 8.r corners apply to it — the
          // content-sizing mode keeps the decorator's own 4.r border.
          heightSizesWholeTrigger: true,
          borderRadius: BorderRadius.circular(8.r),
          fillColor: AppColors.card,
          itemHeight: _kHeight.sp,
          itemStyle: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryBlack),
          // One pick shows its name; several show a count, so the 150-wide
          // button never turns into a truncated list.
          selectedTextBuilder: (selected) => selected.length == 1
              ? selected.first.label
              : '$departmentLabel (${selected.length})',
          onChanged: cubit.updateSelectedDepartmentFilters,
        ),
      ),
    );
  }
}
