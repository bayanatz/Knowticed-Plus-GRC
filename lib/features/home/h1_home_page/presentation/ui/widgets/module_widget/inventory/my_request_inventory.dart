/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_inventory.dart
/// Purpose: Declares `MyRequestInventory`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MyRequestInventory extends StatelessWidget {
  const MyRequestInventory({required this.model, super.key});
  final HomeComponentModel model;

  /// Placeholder figure — this card has no inventory data source yet (it
  /// showed "Total: 100" and three 10s before the restyle).
  static const String _placeholder = '10';

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    // Owner 21/10/2026: reference home-card style — the Services "My
    // Request" card (MyRequestServices): narrow, Approved · Pending ·
    // Rejected counter tiles with the same three icons.
    return HomeWidgetCard(
      hugContent: true,
      title: l.myRequest,
      icon: Modules.inventory.iconPath,
      width: kHomeWidgetNarrowWidth,
      child: HomeStatTileRow(
        tiles: <HomeStatTile>[
          HomeStatTile(
            icon: HomeWidgetSvg.approved,
            label: l.approved,
            value: _placeholder,
          ),
          HomeStatTile(
            icon: HomeWidgetSvg.pending,
            label: l.pending,
            value: _placeholder,
          ),
          HomeStatTile(
            icon: HomeWidgetSvg.rejected,
            label: l.rejected,
            value: _placeholder,
          ),
        ],
      ),
    );
  }
}
