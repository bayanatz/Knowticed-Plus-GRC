/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: person_state_view.dart
/// Description: `FormPersonStateView` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class FormPersonStateView extends StatelessWidget {
  const FormPersonStateView(
      {required this.person,
      required this.onTap,
      this.isEdit = false,
      this.isSent = false,
      super.key,
      this.color});
  final PersonEntity person;

  /// The form was already shared with this person: show a
  /// primary "Sent" tag instead of a (ticked, untappable) checkbox.
  final bool isSent;
  final void Function()? onTap;
  final Color? color;
  final bool isEdit;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: GestureDetector(
        onTap: withHaptic(onTap ?? () {}, HapticLevel.high),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsetsDirectional.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: 20.sp,
                  backgroundColor: AppColors.primary,
                  backgroundImage: appImageProvider(
                      "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png")),
              horizontalSpace(10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        FormatHelper.capitalize(person.name),
                        style: StyleText.fontSize14Weight500,
                      ),
                    ),
                    Expanded(
                        child: Text(
                      FormatHelper.capitalize(person.departmentName),
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.spanText),
                    )),
                    Expanded(
                        child: Text(
                      FormatHelper.capitalize(person.title),
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.spanText),
                    )),
                  ],
                ),
              ),
              if (isSent)
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.sp, vertical: 3.sp),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      S.of(context).fbSent,
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
                  ),
                )
              else if (onTap != null)
                Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: (isEdit)
                        ? CustomSvgImage.natural(
                            assetPath: AppAssets.minusCircle)
                        : CustomCheckBox(isSelected: person.isSelected))
            ],
          ),
        ),
      ),
    );
  }
}
