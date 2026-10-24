/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_button.dart
/// Description: `dashboardButton()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/ui/pages/dashboard_screen.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget dashboardButton(BuildContext context) {
  final isMobile = ContextExtension(context).isPhone;
  return SizedBox(
    child: customButton(
      title: S.of(context).dashboard,
      function: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => KnowledgeHubDI.dashboardCubit(),
              child: DashboardScreenKnow(),
            ),
          ),
        );
      },
      width: isMobile ? 100.w : 135.w,
      height: 38.h,
      textStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.textButton,
      ),
    ),
  );
}
