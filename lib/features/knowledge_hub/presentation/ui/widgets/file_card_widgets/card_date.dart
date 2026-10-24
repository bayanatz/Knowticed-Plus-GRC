/// Module: knowledge_hub/presentation/ui/widgets/file_card_widgets
///
///*************************** FILE INFO ****************************///
/// File Name: card_date.dart
/// Description: `buildDateInfo()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildDateInfo(
  BuildContext context,
  String label,
  String date,
  bool lightMode,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: StyleText.fontSize8Weight400
            .copyWith(color: AppColors.secondaryBlack)
            .copyWith(color: AppColors.secondaryText),
      ),
      Text(
        date,
        style: StyleText.fontSize8Weight400
            .copyWith(color: AppColors.secondaryBlack)
            .copyWith(color: AppColors.blackButton),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
