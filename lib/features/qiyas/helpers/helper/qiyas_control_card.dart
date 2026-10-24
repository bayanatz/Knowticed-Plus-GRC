/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_control_owner_card.dart
/// Purpose: Defines a widget that displays a card with information about a Qiyas control owner.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/qiyas_person_entity.dart';

class QiyasControlCard extends StatelessWidget {
  const QiyasControlCard({
    super.key,
    required this.index,
    required this.onTap,
    required this.person,
  });

  final QiyasPersonEntity person;
  final int index;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.background,
        border: person.isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20.sp,
              child: SizedBox(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(35.r),
                    child: CustomSvgImage(
                      assetPath:
                          "assets/icons_assets/qiyas_assets/ic_user_male.svg",
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.fill,
                    )),
              ),
            ),
            SizedBox(width: 10.sp),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: StyleText.fontSize12Weight500,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    person.departmentName,
                    style: StyleText.fontSize10Weight400
                        .copyWith(color: AppColors.secondaryBlack)
                        .copyWith(color: AppColors.secondaryText),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    person.title,
                    style: StyleText.fontSize10Weight400
                        .copyWith(color: AppColors.secondaryBlack)
                        .copyWith(color: AppColors.secondaryText),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
