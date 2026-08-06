import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/generated/l10n.dart';

class InventoryOverview extends StatelessWidget {
  InventoryOverview({required this.model, super.key});
  HomeComponentModel model;
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
                  style: AppTextStyles.font14BlackCairoMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SvgPicture.asset(
                  'assets/icons_assets/roles_assets/inventory_warehouse.svg',
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
                        'assets/icons_assets/home_assets/inventory_products_box.svg'),
                staticItem(
                    title: S.of(context).totalDamaged,
                    number: 10,
                    icon:
                        'assets/icons_assets/home_assets/inventory_damaged_box.svg'),
                staticItem(
                    title: S.of(context).totalMissing,
                    number: 10,
                    icon:
                        'assets/icons_assets/home_assets/inventory_stolen_laptop.svg'),
                staticItem(
                    title: S.of(context).totalSalon,
                    number: 10,
                    icon:
                        'assets/icons_assets/home_assets/inventory_stolen_laptop.svg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  staticItem(
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
            SvgPicture.asset(icon),
            FittedBox(
              child: Text(
                title,
                style: AppTextStyles.font14BlackCairoRegular,
              ),
            ),
            Container(),
            Text(
              number.toString(),
              style: AppTextStyles.font14BlackSemiBoldCairo,
            ),
          ],
        ),
      ),
    );
  }
}
