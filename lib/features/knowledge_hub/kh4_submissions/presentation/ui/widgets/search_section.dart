/// Module: knowledge_hub/kh4_submissions/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: search_section.dart
/// Description: Search section — Submissions (S4) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/ui/widgets/status_filter_dialog.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

Widget searchWithStatusFilters(
  BuildContext context, {
  required TextEditingController searchCategoryController,
}) {
  // Icon only on phones and on a tablet held upright (KH vertical report
  // p.13: the label crowded the search box in portrait).
  final isMobile =
      ContextExtension(context).isPhone ||
      MediaQuery.orientationOf(context) == Orientation.portrait;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      AppSearchTextField(
        controller: searchCategoryController,
        fillColor: AppColors.card,
        onChanged: (query) {
          context.read<SubmissionsCubit>().searchKnowledge(query);
        },
      ),
      SizedBox(width: ButtonSizing.toolbarGap(context)),

      // CHANGED 18/10/2026 (Moataz: Filter looks the same in every module):
      // the shared CustomFilterIcon, not a hand-built 14/500 button. Same
      // icon-only-when-upright rule as before; the shared button fires the
      // low haptic itself.
      CustomFilterIcon(
        iconOnly: isMobile,
        onTap: () {
          showAppDialog(
            context: context,
            builder: (ctx) => Center(
              child: BlocProvider.value(
                value: context.read<SubmissionsCubit>(),
                child: StatusFilterDialog(),
              ),
            ),
          );
        },
      ),
    ],
  );
}
