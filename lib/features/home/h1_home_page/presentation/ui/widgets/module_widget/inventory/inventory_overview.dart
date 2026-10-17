/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: inventory_overview.dart
/// Purpose: Declares `InventoryOverview`.
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

class InventoryOverview extends StatelessWidget {
  const InventoryOverview({required this.model, super.key});
  final HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400.sp,
      child: StandardContainer(
        child: Column(
          spacing: 15.sp,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).inventory,
                  style: StyleText.fontSize14Weight500
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                CustomSvgImage.natural(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_module_inventory.svg',
                  width: 20,
                  height: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
            Row(
              spacing: 5.sp,
              children: [
                staticItem(
                    title: S.of(context).totalProduct,
                    number: 10,
                    icon:
                        'assets/icons_assets/main_icons_assets/ic_data_inventory_products.svg'),
                staticItem(
                    title: S.of(context).totalDamaged,
                    number: 10,
                    icon:
                        'assets/icons_assets/main_icons_assets/ic_data_inventory_damaged.svg'),
                staticItem(
                    title: S.of(context).totalMissing,
                    number: 10,
                    icon:
                        'assets/icons_assets/home_assets/ic_data_inventory_stolen.svg'),
                staticItem(
                    title: S.of(context).totalSalon,
                    number: 10,
                    icon:
                        'assets/icons_assets/home_assets/ic_data_inventory_stolen.svg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Expanded staticItem(
      {required String title, required int number, required String icon}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(5.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6.sp,
          children: [
            CustomSvgImage.natural(assetPath: icon),
            FittedBox(
              child: Text(
                title,
                style: StyleText.fontSize14Weight400,
              ),
            ),
            Container(),
            Text(
              number.toString(),
              style: StyleText.fontSize14Weight600,
            ),
          ],
        ),
      ),
    );
  }
}
