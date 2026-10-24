/// Module: knowledge_hub/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: departments_list_view.dart
/// Description: Horizontal department chips with document counts on the hub.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_state.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// The first chip is "All" (filter value null); the others are the
/// departments, most documents first. Documents store the English name.
Widget departmentsListView(
  BuildContext context, {
  required int selectedIndex,
  required CreateKnowledgeCubit cubit,
  required List<DepartmentModelPro> departmentNames,
}) {
  final List<DepartmentModelPro> sorted = [...departmentNames]
    ..sort(
      (a, b) => cubit
          .getKnowledgeCountByDepartment(b.departmentName ?? '')
          .compareTo(
            cubit.getKnowledgeCountByDepartment(a.departmentName ?? ''),
          ),
    );
  final bool isMobile = ContextExtension(context).isPhone;

  return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
    buildWhen: (previous, current) =>
        current is FetchingKnowledgeSuccessState ||
        current is FetchingKnowledgeEmptyState,
    builder: (context, state) {
      return SizedBox(
        height: isMobile ? 35.h : 45.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: sorted.length + 1,
          itemBuilder: (context, index) {
            final DepartmentModelPro? dept = index == 0
                ? null
                : sorted[index - 1];
            final String? filterValue = dept?.departmentName;
            final String label = dept == null
                ? S.of(context).all
                : KhLocale.pick(
                    context,
                    en: FormatHelper.capitalize(dept.departmentName ?? ''),
                    ar: dept.departmentNameInArabic ?? '',
                  );
            final bool selected = selectedIndex == index;
            final int count = cubit.getKnowledgeCountByDepartment(filterValue);

            return GestureDetector(
              onTap: withHaptic(
                () => cubit.filterByDepartment(filterValue, index),
                HapticLevel.low,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 30),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 35.h : 45.h,
                      height: isMobile ? 35.w : 45.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: selected ? AppColors.primary : AppColors.card,
                      ),
                      child: Center(
                        child: Text(
                          KhLocale.digits(context, count),
                          style:
                              (isMobile
                                      // 22/10/2026 — Owner (phone): count chips match Notifications — box 35, number 14/400, label 14/600.
                                      ? StyleText.fontSize14Weight400
                                      : StyleText.fontSize20Weight500)
                                  .copyWith(
                                    color: selected
                                        ? AppColors.textButton
                                        : AppColors.secondaryText,
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Text(
                      label,
                      style:
                          (isMobile
                                  ? StyleText.fontSize14Weight600
                                  : StyleText.fontSize18Weight500)
                              .copyWith(
                                color: selected
                                    ? AppColors.text
                                    : AppColors.secondaryText,
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
