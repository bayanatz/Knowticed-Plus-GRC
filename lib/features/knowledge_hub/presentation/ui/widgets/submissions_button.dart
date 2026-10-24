/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_button.dart
/// Description: `submissionsButton()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/ui/pages/submissions_screen.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

Widget submissionsButton(BuildContext context) {
  final isMobile = ContextExtension(context).isPhone;
  return Align(
    alignment: AlignmentDirectional.topEnd,
    child: SizedBox(
      child: customButton(
        title: S.of(context).submissions,
        function: () {
          khLog('Submissions Button Pressed');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => KnowledgeHubDI.submissionsCubit(),
                child: SubmissionsScreen(),
              ),
            ),
          );
        },
        width: isMobile ? 100.w : 135.w,
        height: 38.h,
        textStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.textButton,
          letterSpacing: .1,
        ),
      ),
    ),
  );
}
