import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:demo_app/features/home/home_page/presentation/ui/widgets/standard_container.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

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
                  'Inventory'.tr,
                  style: AppTextStyles.font14BlackCairoMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SvgPicture.asset(
                  'assets/skeleton/home/icons/inventory.svg',
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
                    title: 'Total Product'.tr,
                    number: 10,
                    icon:
                        'assets/icons_assets/home_assets/inventory_total_product.svg'),
                staticItem(
                    title: 'Total Damaged'.tr,
                    number: 10,
                    icon:
                        'assets/icons_assets/home_assets/inventory_total_damaged.svg'),
                staticItem(
                    title: 'Total Missing'.tr,
                    number: 10,
                    icon:
                        'assets/skeleton/home/icons/inventory_total_Missing.svg'),
                staticItem(
                    title: 'Total Salon'.tr,
                    number: 10,
                    icon:
                        'assets/icons_assets/home_assets/inventory_total_stolen.svg'),
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
