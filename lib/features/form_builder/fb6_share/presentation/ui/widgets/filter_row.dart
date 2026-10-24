/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: filter_row.dart
/// Description: `FilterRow` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Keep for .tr translations
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_state.dart';

import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/dropdown/small_drop_down.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_app_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/synced_search_field.dart';

class FilterRow extends StatelessWidget {
  const FilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormsGroupCubit, FormsGroupState>(
      builder: (context, state) {
        if (state is! FormsGroupLoaded) {
          return const SizedBox.shrink();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SyncedSearchField(
              fillColor: AppColors.background,
              text: state.searchText,
              onChanged: (value) =>
                  context.read<FormsGroupCubit>().search(value),
            ),
            horizontalSpace(15),
            _buildDepartment(context, state),
          ],
        );
      },
    );
  }

  Widget _buildDepartment(BuildContext context, FormsGroupLoaded state) {
    final cubit = context.read<FormsGroupCubit>();
    final departments = cubit.getDepartments();

    if (ContextExtension(context).isTablett) {
      return SizedBox(
        width: 155,
        // Bug report p.49: same 38.sp height as the search bar (was 36).
        height: 38.sp,
        child: AppDropdown(
          borderRadius: 8.r, // form bug report #8/#35: 8.r dropdowns
          value: null,
          width: double.infinity,
          height: 38.sp,
          // Bug report p.50: the open list was only as wide as the 155
          // button, so "Information Technology" was cut off.
          menuWidth: 230,
          fillColor: AppColors.background,
          textButton: S.of(context).department,
          items: departments.map((String department) {
            return DropdownMenuItem<String>(
              value: department,
              child: Text(
                FormatHelper.capitalize(department),
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryBlack,
                ),
              ),
            );
          }).toList(),
          onChanged: (p0) {
            if (p0 != null) {
              cubit.updateDepartment(p0.toLowerCase());
              cubit.search();
            }
          },
        ),
      );
    }

    return SizedBox(
      width: 38.sp,
      height: 38.sp,
      child: SmallDropdown(
        value: null,
        menuWidth: 300.w,
        fillColor: AppColors.background,
        textButton: S.of(context).department,
        items: departments.map((String department) {
          return DropdownMenuItem<String>(
            value: department,
            child: Text(
              FormatHelper.capitalize(department),
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryBlack,
              ),
            ),
          );
        }).toList(),
        onChanged: (p0) {
          if (p0 != null) {
            cubit.updateDepartment(p0.toLowerCase());
            cubit.search();
          }
        },
      ),
    );
  }
}
