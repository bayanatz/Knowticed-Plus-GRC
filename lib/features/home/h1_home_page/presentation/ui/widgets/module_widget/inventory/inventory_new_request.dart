/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: inventory_new_request.dart
/// Purpose: Declares `InventoryNewRequests`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/features/home/h1_home_page/data/helpers/home_button_access.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/inventory_actions.dart';

class InventoryNewRequests extends StatelessWidget {
  const InventoryNewRequests({super.key, required this.model});
  final HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final List<String> shown = HomeButtonAccess.shown(model, <String>[
      HomeButtonKey.asset,
      HomeButtonKey.consumable,
      HomeButtonKey.myRequest,
    ]);
    // Owner 21/10/2026: reference home-card style — as Forms: HomeWidgetCard
    // header (title + Inventory icon), narrow width, stacked HomeCardButtons.
    return HomeWidgetCard(
      title: l.newRequest,
      icon: Modules.inventory.iconPath,
      width: kHomeWidgetNarrowWidth,
      // Equal gaps title → buttons → card edge (Owner 21/10/2026).
      child: HomeCardButtonStack(
        buttons: <Widget>[
          if (shown.contains(HomeButtonKey.asset))
            HomeCardButton(
              label: l.asset,
              onTap: () => openInventoryFromHome(context),
            ),
          if (shown.contains(HomeButtonKey.consumable))
            HomeCardButton(
              label: l.consumable,
              onTap: () => openInventoryFromHome(context),
            ),
          if (shown.contains(HomeButtonKey.myRequest))
            HomeCardButton(
              label: l.myRequest,
              onTap: () => openInventoryFromHome(context),
            ),
        ],
      ),
    );
  }
}
