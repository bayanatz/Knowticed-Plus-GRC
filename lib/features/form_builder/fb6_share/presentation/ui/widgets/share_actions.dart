/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: share_actions.dart
/// Description: `ShareActions`, the dialogs of sharing a form and of
///              creating, editing and deleting a group. Moved out of
///              `ShareCubit` / `FormsGroupCubit`, which now only save and
///              return the result.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The dialogs of sharing a form and of the group screens.
class ShareActions {
  const ShareActions._();

  /// Method Name: [grantAccess]
  ///
  /// Purpose: shares the form with the picked people. On success the
  /// review dialog closes and the success message shows; otherwise the
  /// reason is shown (FB-SHARE-04).
  ///
  /// Parameters:
  /// - [context]: the share page's context.
  /// - [shareCubit]: the page's ShareCubit.
  static Future<void> grantAccess(
    BuildContext context,
    ShareCubit shareCubit,
  ) async {
    final NavigatorState rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    final String? error = await shareCubit.grantAccess();
    if (!context.mounted) return;
    if (error != null) {
      await AppDialogs.showError(context, error);
      return;
    }
    // Close the review dialog.
    if (rootNavigator.canPop()) rootNavigator.pop();
    await AppDialogs.grantFormAccessSuccessfully(context);
  }

  /// Method Name: [createGroup]
  ///
  /// Purpose: saves the new group behind the loading indicator, then shows
  /// the result.
  ///
  /// Parameters:
  /// - [context]: the create-group page's context.
  ///
  /// Returns: true when the group was saved.
  static Future<bool> createGroup(
    BuildContext context,
    FormsGroupCubit cubit,
  ) async {
    final GroupSaveResult result =
        await CustomDialogManager.runWithLoading<GroupSaveResult>(
          context,
          cubit.createGroup,
        );
    if (!context.mounted) return result == GroupSaveResult.saved;
    await _showResult(
      context,
      result,
      onSaved: () => AppDialogs.groupCreatedSuccessfully(context),
    );
    return result == GroupSaveResult.saved;
  }

  /// Method Name: [editGroup]
  ///
  /// Purpose: saves the open group behind the loading indicator (bug report
  /// p.59), then shows the result.
  ///
  /// Parameters:
  /// - [context]: the edit-group page's context.
  ///
  /// Returns: true when the group was saved.
  static Future<bool> editGroup(
    BuildContext context,
    FormsGroupCubit cubit,
  ) async {
    final GroupSaveResult result =
        await CustomDialogManager.runWithLoading<GroupSaveResult>(
          context,
          cubit.editGroup,
        );
    if (!context.mounted) return result == GroupSaveResult.saved;
    await _showResult(
      context,
      result,
      onSaved: () => AppDialogs.editingGroupSuccessfully(context),
    );
    return result == GroupSaveResult.saved;
  }

  /// Method Name: [deleteGroup]
  ///
  /// Purpose: deletes the open group; a failure is reported (FB-SHARE-04).
  ///
  /// Parameters:
  /// - [context]: the group page's context.
  ///
  /// Returns: true when the group was deleted.
  static Future<bool> deleteGroup(
    BuildContext context,
    FormsGroupCubit cubit,
  ) async {
    final bool deleted = await cubit.deleteGroup();
    if (!deleted && context.mounted) {
      await AppDialogs.showError(context, S.current.groupActionFailed);
    }
    return deleted;
  }

  static Future<void> _showResult(
    BuildContext context,
    GroupSaveResult result, {
    required dynamic Function() onSaved,
  }) async {
    switch (result) {
      case GroupSaveResult.saved:
        await onSaved();
        return;
      case GroupSaveResult.needsMembers:
        await AppDialogs.showError(context, S.current.groupNeedsMembers);
        return;
      case GroupSaveResult.failed:
        await AppDialogs.showError(context, S.current.groupActionFailed);
        return;
    }
  }
}
