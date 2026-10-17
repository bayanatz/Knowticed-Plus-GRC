/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_inventory.dart
/// Purpose: Declares `MyRequestInventory`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:grc_module/generated/l10n.dart';

class MyRequestInventory extends StatelessWidget {
  const MyRequestInventory({required this.model, super.key});
  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 130.sp,
        child: StandardContainer(
            child: Column(
          spacing: 8.sp,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).myRequest,
                  style: StyleText.fontSize14Weight500
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                CustomSvgImage.natural(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_module_inventory.svg',
                  width: 20,
                  height: 20,
                  color: AppColors.primary,
                )
              ],
            ),
            Container(),
            Text(
              S.of(context).total + 100.toString(),
              style: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.secondaryText),
            ),
            Column(
              spacing: 10.sp,
              children: [
                item(
                    color: AppColors.green,
                    number: '10',
                    icon:
                        'assets/icons_assets/home_assets/ic_status_approved_stamp.svg'),
                item(
                    color: AppColors.secondaryPrimary,
                    number: '10',
                    icon:
                        'assets/icons_assets/home_assets/ic_status_pending_hourglass.svg'),
                item(
                    color: AppColors.red,
                    number: '10',
                    icon:
                        'assets/icons_assets/home_assets/ic_status_rejected_ribbon.svg'),
              ],
            )
          ],
        )));
  }

  Widget item(
      {required Color color, required String number, required String icon}) {
    return Row(
      spacing: 4.sp,
      children: [
        CustomSvgImage.natural(
          assetPath: icon,
          width: 15,
          height: 15,
          color: color,
        ),
        Text(
          number,
          style: StyleText.fontSize12Weight400
              .copyWith(fontWeight: FontWeight.bold, color: color),
        )
      ],
    );
  }
}
