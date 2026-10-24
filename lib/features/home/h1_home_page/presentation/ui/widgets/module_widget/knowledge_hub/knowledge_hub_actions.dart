// [module-file:knowledge_hub] — deleted when the knowledge_hub module is split out
/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_actions.dart
/// Description: Declares `KnowledgeHubActions`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// 15/10/2026 — KH report p.29/p.25 "enhance their width": every KH card is
// the dashboard tile width (kHomeWidgetWidth), not its own 400/140.
import 'package:knowticed_plus/features/home/h1_home_page/data/helpers/home_button_access.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/ui/pages/creating_knowledge_hub.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/ui/pages/dashboard_screen.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';

class KnowledgeHubActions extends StatelessWidget {
  const KnowledgeHubActions({super.key, required this.model});
  final HomeComponentModel model;
  @override
  Widget build(BuildContext context) {
    // 24/10/2026: the gear's choice AND the role's permission (same two
    // permissions as before, now read in HomeButtonAccess).
    final List<String> shown = HomeButtonAccess.shown(model, <String>[
      HomeButtonKey.createHub,
      HomeButtonKey.viewDashboard,
    ]);
    // Owner 21/10/2026: reference home-card style — as Forms: HomeWidgetCard
    // header (title + Knowledge Hub icon), narrow width, stacked
    // HomeCardButtons.
    // FIXED 15/10/2026 — KH large-screen report p.29 / vertical p.25
    // "widgets not work": both buttons opened the "module removed"
    // placeholder left over from the demo copy of the app. They now open
    // the real Create screen and Dashboard, behind the same permissions
    // the Knowledge Hub page uses for them.
    return HomeWidgetCard(
      title: S.of(context).knowledge_hub,
      icon: Modules.knowledgeHub.iconPath,
      width: kHomeWidgetNarrowWidth,
      // Equal gaps title → buttons → card edge (Owner 21/10/2026).
      child: HomeCardButtonStack(
        buttons: <Widget>[
          if (shown.contains(HomeButtonKey.createHub))
            HomeCardButton(
              label: S.of(context).createHub,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => KnowledgeHubDI.createKnowledgeCubit(),
                      child: const CreatingKnowledgeHub(),
                    ),
                  ),
                );
              },
            ),
          if (shown.contains(HomeButtonKey.viewDashboard))
            HomeCardButton(
              label: S.of(context).viewDashboard,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => KnowledgeHubDI.dashboardCubit(),
                      child: DashboardScreenKnow(),
                    ),
                  ),
                );
              },
            ),
          // customButton(
          //     textStyle: StyleText.fontSize12Weight400.copyWith(
          //         fontWeight: FontWeight.w500, color: AppColors.textButton),
          //     buttonText: 'View Approval'.tr,
          //     onTap: () {
          //
          //       navigateTo(context, ApprovalsScreen());
          //     }),
        ],
      ),
    );
  }
}
