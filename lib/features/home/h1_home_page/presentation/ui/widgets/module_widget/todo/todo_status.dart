/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: todo_status.dart
/// Purpose: Declares `MyTodoStatus` — home To-Do card 3: High / Medium / Low
///          counts and the yellow View button.
/// Author: Knowticed Plus team
/// Updated: 7/10/2026 - Reads the new To-Do module through `TodoHomeCubit`;
///          View opens `TodoModuleEntry` (was a removed-module placeholder).
/// Updated: 7/10/2026 - Owner round 3: label + count per priority, grid
///          narrow width, shared card height.
///
/// Figma: To-Do widget node 130:8096, third card. Counts equal the list's
/// All tab with that priority chip selected (deleted to-dos excluded).
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/todo_home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/todo_home_card_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';

class MyTodoStatus extends StatelessWidget {
  const MyTodoStatus({required this.model, super.key});

  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    final HomeWidgetSettings settings = model.widgetSettings;
    // D-242: "Priorities shown" (default all three), "Count", "Due".
    final List<String> shown = settings.list(
        HomeSettingKey.priorities, const <String>['high', 'medium', 'low']);
    // Owner 21/10/2026: reference home-card style — one stat tile per
    // priority (its icon in the priority colour, label, count), like the
    // Services cards.
    return TodoHomeStatCardScope(
      width: kHomeWidgetCompactWidth,
      builder: (BuildContext context, TodoHomeState state) => HomeStatTileRow(
        tiles: <HomeStatTile>[
          for (final TodoPriority priority in TodoPriority.values)
            if (shown.contains(priority.name))
              HomeStatTile(
                icon: priority.iconPath,
                iconColor: _colorOf(priority),
                label: priority.label(context),
                value: LocalizedNumber.of(
                    context, state.countPriorityFor(priority, settings)),
                labelMaxLines: 1,
              ),
        ],
      ),
      // D-227 (Moataz 20/10/2026): no "View" button on this widget.
    );
  }

  /// Same colours as before: High red, Medium yellow, Low blue.
  static Color _colorOf(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return AppColors.red;
      case TodoPriority.medium:
        return AppColors.secondaryPrimary;
      case TodoPriority.low:
        return AppColors.blue;
    }
  }
}
