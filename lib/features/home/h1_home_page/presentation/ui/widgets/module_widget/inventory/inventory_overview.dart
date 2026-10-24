/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: inventory_overview.dart
/// Purpose: Declares `InventoryOverview`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class InventoryOverview extends StatelessWidget {
  const InventoryOverview({required this.model, super.key});
  final HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width = content (18/10/2026)
      child: StandardContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .start, // owner item 200 (21/10/2026): content under the title
          spacing: 8.sp,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8.w,
              children: [
                Text(
                  S.of(context).inventory,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  // Same line height as the other cards' titles (Arabic
                  // lines are taller — 22/10/2026 overflow by 12).
                  strutStyle: HomeStatTile.englishLineStrut(context, 14),
                ),
                CustomSvgImage.natural(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_module_inventory.svg',
                  // 22/10/2026 — Owner: home card title glyph 20 (was 16).
                  width: HomeWidgetCard.iconSize,
                  height: HomeWidgetCard.iconSize,
                  color: AppColors.primary,
                ),
              ],
            ),
            // 22/10/2026 — Owner: a card never spills past the screen. The
            // four tiles need ~422 and a 375 phone gives the card 355, so
            // the row scales DOWN when short of room (never up).
            // …and in height too: Flexible lets the row shrink to the room the
            // fixed-height card has left (22/10/2026).
            Flexible(
              child: HomeStatTileRow(
                tiles: <HomeStatTile>[
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
                      // Owner 21/10/2026 13:31: his exported Figma icon — Total
                      // Salon no longer shares Total Missing's icon.
                      icon:
                          'assets/icons_assets/home_assets/ic_inventory_total_salon.svg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 18/10/2026: the shared stat tile (same scale and gap as every card).
  HomeStatTile staticItem(
      {required String title, required int number, required String icon}) {
    return HomeStatTile(icon: icon, label: title, value: number.toString());
  }
}
