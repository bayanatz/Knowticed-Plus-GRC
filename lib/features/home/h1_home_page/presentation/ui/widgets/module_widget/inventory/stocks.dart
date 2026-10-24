/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: stocks.dart
/// Purpose: Declares `Stocks`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class Stocks extends StatelessWidget {
  const Stocks({required this.model, super.key});
  final HomeComponentModel model;

  /// Placeholder figure — this card has no inventory data source yet (it
  /// showed three unlabelled 10s before the restyle).
  static const String _placeholder = '10';

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    // Owner 21/10/2026: reference home-card style — labelled counter tiles.
    // The three unlabelled lines were green / yellow / red; read here as
    // Available · Low Stock · Out of Stock, keeping those icons and colours.
    return HomeWidgetCard(
      hugContent: true,
      title: l.stocks,
      icon: Modules.inventory.iconPath,
      width: kHomeWidgetCompactWidth,
      child: HomeStatTileRow(
        tiles: <HomeStatTile>[
          HomeStatTile(
            icon:
                'assets/icons_assets/home_assets/ic_status_approved_stamp.svg',
            iconColor: AppColors.green,
            label: l.available,
            value: _placeholder,
          ),
          HomeStatTile(
            icon:
                'assets/icons_assets/home_assets/ic_status_pending_hourglass.svg',
            iconColor: AppColors.secondaryPrimary,
            label: l.lowStock,
            value: _placeholder,
          ),
          HomeStatTile(
            icon:
                'assets/icons_assets/home_assets/ic_status_rejected_ribbon.svg',
            iconColor: AppColors.red,
            label: l.outOfStock,
            value: _placeholder,
          ),
        ],
      ),
    );
  }
}
