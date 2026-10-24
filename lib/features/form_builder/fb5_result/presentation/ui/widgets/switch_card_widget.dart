/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: switch_card_widget.dart
/// Description: `SwitchCardWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_tab_with_container.dart';

import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';


/// The Users / Analytics switch of the Results page.
class SwitchCardWidget extends StatelessWidget {
  const SwitchCardWidget({super.key});

  // Large-screen bug report p.4: the Users chip needs a tab to show.
  bool _hasUsersPermission() => FormBuilderAccess.canSeeUsersView;

  bool _hasAnalyticsPermission() => FormBuilderAccess.canSeeAnalytics;

  @override
  Widget build(BuildContext context) {
    final hasUsersPermission = _hasUsersPermission();
    final hasAnalyticsPermission = _hasAnalyticsPermission();

    // If neither permission is available, don't show the widget
    if (!hasUsersPermission && !hasAnalyticsPermission) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ResultCubit>();

        // Determine the current view based on permissions
        bool shouldShowUsers = state.isUser;

        // If user doesn't have permission for current view, switch to the allowed one
        if (state.isUser && !hasUsersPermission && hasAnalyticsPermission) {
          // If trying to show users but no permission, force analytics
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cubit.onChangeSwitch(false);
          });
          shouldShowUsers = false;
        } else if (!state.isUser &&
            !hasAnalyticsPermission &&
            hasUsersPermission) {
          // If trying to show analytics but no permission, force users
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cubit.onChangeSwitch(true);
          });
          shouldShowUsers = true;
        }

        // If only one permission is available, don't show the switch widget
        if (hasUsersPermission && !hasAnalyticsPermission) {
          return const SizedBox.shrink();
        }
        if (!hasUsersPermission && hasAnalyticsPermission) {
          return const SizedBox.shrink();
        }

        // Both permissions available, show the switch — the app's standard
        // segmented switch (owner, 22/10/2026), so its height and styling are
        // the same here as on every other page.
        return CustomSegmentedTabs(
          tabs: [S.current.fbUsers, S.current.analytics],
          selectedIndex: shouldShowUsers ? 0 : 1,
          onTabSelected: (int i) => cubit.onChangeSwitch(i == 0),
        );
      },
    );
  }
}
