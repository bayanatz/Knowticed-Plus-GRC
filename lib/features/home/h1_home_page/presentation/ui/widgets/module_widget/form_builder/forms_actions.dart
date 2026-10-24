// [module-file:form_builder] — deleted when the form_builder module is split out
/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: forms_actions.dart
/// Description: Declares `FormActions`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
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
import 'package:knowticed_plus/features/form_builder/presentation/navigation/form_builder_shortcut.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

/// Opens the Form Builder module, optionally landing on [shortcut].
///
/// ADDED 29/9/2026 (bug report p.2 — the Home "Forms" buttons had empty
/// onTap handlers). Tablet/desktop switches the side-rail module; phone pushes
/// the module page. Same routing as the "Forms Submission" card uses.
void openFormBuilderFromHome(
  BuildContext context, {
  FormBuilderShortcut? shortcut,
}) {
  FormBuilderShortcuts.pending = shortcut;
  if (!kpIsPhoneLayout(context)) {
    final drawer = NotificationRouting.drawerCubit();
    final index = drawer.allowedDrawerModules.indexOf(Modules.formBuilder);
    if (index == -1) {
      // The user has no Form Builder access — nothing to open.
      FormBuilderShortcuts.pending = null;
      return;
    }
    drawer.updateSelectedIndex(index);
  } else {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => Modules.formBuilder.widget),
    );
  }
}

class FormActions extends StatelessWidget {
  const FormActions({super.key, required this.model});
  final HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final List<String> shown = HomeButtonAccess.shown(model, <String>[
      HomeButtonKey.createForm,
      HomeButtonKey.viewDraftForm,
      HomeButtonKey.viewRequestedForm,
    ]);
    // Owner 21/10/2026: the reference home-card style (as Schedule Message
    // and the Tracker quick card) — HomeWidgetCard header (title + Form
    // Builder icon), narrow width, stacked 24-high HomeCardButtons.
    return HomeWidgetCard(
      title: l.forms,
      icon: Modules.formBuilder.iconPath,
      width: kHomeWidgetNarrowWidth,
      // Equal gaps title → buttons → card edge (Owner 21/10/2026).
      child: HomeCardButtonStack(
        buttons: <Widget>[
          if (shown.contains(HomeButtonKey.createForm))
            HomeCardButton(
              label: l.createForm,
              onTap: () => openFormBuilderFromHome(context,
                  shortcut: FormBuilderShortcut.createForm),
            ),
          if (shown.contains(HomeButtonKey.viewDraftForm))
            HomeCardButton(
              label: l.viewDraftForm,
              onTap: () => openFormBuilderFromHome(context,
                  shortcut: FormBuilderShortcut.drafts),
            ),
          if (shown.contains(HomeButtonKey.viewRequestedForm))
            HomeCardButton(
              label: l.viewRequestedForm,
              onTap: () => openFormBuilderFromHome(context,
                  shortcut: FormBuilderShortcut.requestedForms),
            ),
        ],
      ),
    );
  }
}
