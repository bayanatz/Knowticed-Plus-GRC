/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: my_todo.dart
/// Purpose: Declares `MyTodo` — home To-Do card 1: Total, then Done /
///          Overdue / Scheduled counts.
/// Author: Knowticed Plus team
/// Updated: 7/10/2026 - Reads the new To-Do module through `TodoHomeCubit`
///          (was the removed tasks_module stub, always 0).
/// Updated: 7/10/2026 - Owner round 3: each status is icon + label + count
///          (readable in dark mode); grid narrow width; shared card height.
///
/// Figma: To-Do widget node 130:8096, first card. Counts use
/// `TodoEntity.matchesTab`, so each number equals the list tab it names.
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/todo_home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/todo_home_card_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';

class MyTodo extends StatelessWidget {
  const MyTodo({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    final HomeWidgetSettings settings = model.widgetSettings;
    // D-242: "Counts shown" (default all three) and the "Due" window.
    final List<String> shown = settings.list(
        HomeSettingKey.counts, const <String>['done', 'overdue', 'scheduled']);
    // Owner 21/10/2026: reference home-card style — one stat tile per status
    // (icon, label, count), like the Services cards. The "Total" line is
    // dropped: the Services "My Request" card has none, and with it the tiles
    // did not fit the card height (the last line was cut off).
    return TodoHomeStatCardScope(
      width: kHomeWidgetCompactWidth,
      builder: (BuildContext context, TodoHomeState state) => HomeStatTileRow(
        tiles: <HomeStatTile>[
          for (final _StatusLine line in _lines)
            if (shown.contains(line.tab.key))
              HomeStatTile(
                icon: line.iconPath,
                iconColor: line.color,
                label: line.tab.label(context),
                value: LocalizedNumber.of(
                    context, state.countTabFor(line.tab, settings)),
                labelMaxLines: 1,
              ),
        ],
      ),
    );
  }

  /// Done · Overdue · Scheduled, in the Figma order.
  static List<_StatusLine> get _lines => <_StatusLine>[
        _StatusLine(
          tab: TodoStatusTab.done,
          iconPath: 'assets/icons_assets/home_assets/ic_status_todo_done.svg',
          color: AppColors.green,
        ),
        _StatusLine(
          tab: TodoStatusTab.overdue,
          iconPath:
              'assets/icons_assets/home_assets/ic_status_todo_overdue.svg',
          color: AppColors.red,
        ),
        _StatusLine(
          tab: TodoStatusTab.scheduled,
          iconPath:
              'assets/icons_assets/main_icons_assets/ic_status_todo_scheduled.svg',
          color: AppColors.orange,
        ),
      ];
}

/// One status row's tab, glyph and colour.
class _StatusLine {
  const _StatusLine({
    required this.tab,
    required this.iconPath,
    required this.color,
  });

  final TodoStatusTab tab;
  final String iconPath;
  final Color color;
}
