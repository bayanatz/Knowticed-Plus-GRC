/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: open_home_module.dart
/// Purpose: Declares `openHomeModule` — opens a module from a Home card the
///          same way the Forms Submission card does: in the side menu on
///          tablet, as a pushed page on a phone. Used by a Chart & Graph
///          card's "View details".
/// Author: Knowticed Plus team
/// Created: 23/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

/// Function Name: [openHomeModule]
///
/// Purpose: Show [module] (selected in the side menu on tablet, pushed on a
///          phone). Does nothing when the employee's role does not include it.
void openHomeModule(BuildContext context, Modules module) {
  if (!kpIsPhoneLayout(context)) {
    final drawer = NotificationRouting.drawerCubit();
    final int index = drawer.allowedDrawerModules.indexOf(module);
    if (index == -1) return;
    drawer.updateSelectedIndex(index);
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => module.widget),
  );
}
