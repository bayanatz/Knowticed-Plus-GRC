/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_text_field.dart
/// Description: `AnalyticsTextField` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_text_field_entity.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';

/// One person's answer in the analytics answer list.
class AnalyticsTextField extends StatelessWidget {
  const AnalyticsTextField({required this.entity, super.key});
  final AnalyticsTextFieldEntity entity;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: AppColors.background),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                backgroundImage: entity.person.image.contains("http")
                    ? NetworkImage(entity.person.image)
                    : appImageProvider(entity.person.image),
              ),
              horizontalSpace(10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(entity.person.name),
                      style: StyleText.fontSize14Weight500,
                    ),
                    Text(
                      FormatHelper.capitalize(entity.person.title),
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.spanText),
                    )
                  ],
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: S.current.date,
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.spanText),
                    ),
                    TextSpan(
                        //number
                        text:
                            ' ${FormDateTimeHelper.formatDate(entity.submissionDate)}',
                        style: StyleText.fontSize10Weight400
                            .copyWith(color: AppColors.fullBlack))
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
