/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: selected_person_avatar.dart
/// Description: Small avatar of a selected person.
/// Author: Amr Mesbah
/// Created at: 7/5/2025
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// A picked person's avatar; tapping it unpicks them.
class SelectedPersonAvatar extends StatelessWidget {
  const SelectedPersonAvatar(
      {required this.personEntity, required this.onTap, super.key});
  final PersonEntity personEntity;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 8),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: personEntity.image.contains('http')
                ? NetworkImage(personEntity.image)
                : appImageProvider(personEntity.image),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                splashColor: AppColors.transparent,
                onTapDown: (_) => HapticController.high(),
                onTap: () {
                  onTap();
                },
                child: ClipOval(
                  child: SizedBox(
                      height: 14.sp,
                      width: 14.sp,
                      child: CustomSvgImage.natural(
                        assetPath: AppAssets.close,
                        width: 12.sp,
                        height: 12.sp,
                      )),
                ),
              )),
        ],
      ),
    );
  }
}
