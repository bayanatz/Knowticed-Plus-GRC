/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: schedule_message.dart
/// Description: Declares `ScheduleMessage`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 21/10/2026 - Owner: the reference home-card style (the Tracker
///          quick card) — `HomeWidgetCard` header (title + Messages icon),
///          narrow width, two stacked `HomeCardButton`s. The centred bold
///          title and the "For Group" / "For Direct Message" captions over
///          each button overflowed the card by 14 px; the buttons now carry
///          those words themselves. Both open the Messages module — a
///          message is scheduled from inside the chosen chat.
library;

import 'package:knowticed_plus/features/home/h1_home_page/data/helpers/home_button_access.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_extra_widgets.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ScheduleMessage extends StatelessWidget {
  const ScheduleMessage({required this.model, super.key});
  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final List<String> shown = HomeButtonAccess.shown(model, <String>[
      HomeButtonKey.forGroup,
      HomeButtonKey.forDirectMessage,
    ]);
    return HomeWidgetCard(
      title: l.scheduleMessage,
      icon: Modules.messages.iconPath,
      width: kHomeWidgetNarrowWidth,
      // Equal gaps title → buttons → card edge (Owner 21/10/2026).
      child: HomeCardButtonStack(
        buttons: <Widget>[
          if (shown.contains(HomeButtonKey.forGroup))
            HomeCardButton(
              label: l.forGroup,
              onTap: () => openHomeMessagesModule(context),
            ),
          if (shown.contains(HomeButtonKey.forDirectMessage))
            HomeCardButton(
              label: l.forDirectMessage,
              onTap: () => openHomeMessagesModule(context),
            ),
        ],
      ),
    );
  }
}
