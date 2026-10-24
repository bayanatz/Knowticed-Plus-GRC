/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: inventory_actions.dart
/// Purpose: Declares `InventoryActions`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/features/home/h1_home_page/data/helpers/home_button_access.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

/// Function Name: [openInventoryFromHome]
///
/// Purpose: Open the Inventory module from a home card. ADDED 21/10/2026 —
/// the "Inventory" and "New Request" cards' buttons had empty onTaps. Same
/// routing as `openFormBuilderFromHome`: tablet/desktop switches the
/// side-rail module; phone pushes the module page. Inventory has no shortcut
/// hook, so every button lands on its main page.
void openInventoryFromHome(BuildContext context) {
  if (!kpIsPhoneLayout(context)) {
    final drawer = NotificationRouting.drawerCubit();
    final int index = drawer.allowedDrawerModules.indexOf(Modules.inventory);
    // The user has no Inventory access — nothing to open.
    if (index == -1) return;
    drawer.updateSelectedIndex(index);
  } else {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => Modules.inventory.widget),
    );
  }
}

class InventoryActions extends StatelessWidget {
  const InventoryActions({super.key, required this.model});
  final HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final List<String> shown = HomeButtonAccess.shown(model, <String>[
      HomeButtonKey.addProduct,
      HomeButtonKey.order,
      HomeButtonKey.approvals,
    ]);
    // Owner 21/10/2026: reference home-card style — as Forms: HomeWidgetCard
    // header (title + Inventory icon), narrow width, stacked HomeCardButtons.
    return HomeWidgetCard(
      title: l.inventory,
      icon: Modules.inventory.iconPath,
      width: kHomeWidgetNarrowWidth,
      // Equal gaps title → buttons → card edge (Owner 21/10/2026).
      child: HomeCardButtonStack(
        buttons: <Widget>[
          if (shown.contains(HomeButtonKey.addProduct))
            HomeCardButton(
              label: l.addProduct,
              onTap: () => openInventoryFromHome(context),
            ),
          if (shown.contains(HomeButtonKey.order))
            HomeCardButton(
              label: l.order,
              onTap: () => openInventoryFromHome(context),
            ),
          if (shown.contains(HomeButtonKey.approvals))
            HomeCardButton(
              label: l.approvals,
              onTap: () => openInventoryFromHome(context),
            ),
        ],
      ),
    );
  }
}
