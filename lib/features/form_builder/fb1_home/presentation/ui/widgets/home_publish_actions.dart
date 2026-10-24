/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_publish_actions.dart
/// Description: `HomePublishActions`, the dialogs and navigation of
///              publishing and editing a form. Moved out of `HomeCubit`,
///              which now only saves and returns the result.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder/helpers/create_form_flow_dialog.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/home_form_actions.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/pages/publish_screen.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The dialogs and navigation of publishing and editing a form. The
/// [HomeCubit] read from [BuildContext] does the saving.
class HomePublishActions {
  const HomePublishActions._();

  /// Method Name: [publishNewForm]
  ///
  /// Purpose: publishes a new form. Phones open the Publish screen for Open
  /// and Restricted Access; tablets show the summary dialog. Every path ends
  /// in the one create-form dialog (confirm → saving → success → home).
  ///
  /// Parameters:
  /// - [context]: a context under the Form Builder providers.
  /// - [model]: the new form.
  /// - [createFormDataCubit]: the editor's cubit (holds the picked access).
  /// - [skipDialog]: go straight to the create-form dialog.
  static void publishNewForm({
    required BuildContext context,
    required FormEntity model,
    required CreateFormDataCubit createFormDataCubit,
    bool skipDialog = false,
  }) {
    // FB-HOME-02: checked again at tap time, not only on the button.
    if (!FormBuilderAccess.canCreateForm) {
      AppDialogs.showError(context, S.current.noPermissionCreateForm);
      return;
    }

    final AccessManagement? access = AccessManagementExtension.fromStored(
      model.formHeadModel.accessManagement,
    );

    switch (access) {
      case null:
        AppDialogs.showError(context, S.current.chooseAccessManagement);
        return;
      case AccessManagement.personalAccess:
        _runCreateFlow(context, model, createFormDataCubit, access!);
        return;
      case AccessManagement.openAccess:
      case AccessManagement.restrictedAccess:
        if (skipDialog) {
          _runCreateFlow(context, model, createFormDataCubit, access!);
          return;
        }
        if (!context.isTablett) {
          _openPublishScreen(context, model, createFormDataCubit);
          return;
        }
        void onPublish() =>
            _runCreateFlow(context, model, createFormDataCubit, access!);
        // The dialog opens on the root navigator, so it is handed the
        // editor's cubits.
        final CreateFormHeadCubit headCubit =
            context.read<CreateFormHeadCubit>();
        if (access == AccessManagement.openAccess) {
          AppDialogs.summaryOpenAccessDialog(
            context,
            onPublish,
            headCubit: headCubit,
            dataCubit: createFormDataCubit,
          );
        } else {
          AppDialogs.summaryRestrictedAccessDialog(
            context,
            onPublish,
            headCubit: headCubit,
            dataCubit: createFormDataCubit,
          );
        }
        return;
    }
  }

  static void _openPublishScreen(
    BuildContext context,
    FormEntity model,
    CreateFormDataCubit createFormDataCubit,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (newContext) => MultiBlocProvider(
          providers: [
            BlocProvider<CreateFormDataCubit>.value(value: createFormDataCubit),
            BlocProvider<CreateFormHeadCubit>.value(
              value: context.read<CreateFormHeadCubit>(),
            ),
            BlocProvider<HomeCubit>.value(value: context.read<HomeCubit>()),
          ],
          child: PublishScreen(model: model),
        ),
      ),
    );
  }

  /// One dialog for the whole publish: confirm → loading circle in place of
  /// Yes / No → success → home.
  static Future<void> _runCreateFlow(
    BuildContext context,
    FormEntity model,
    CreateFormDataCubit createFormDataCubit,
    AccessManagement access,
  ) async {
    final HomeCubit homeCubit = context.read<HomeCubit>();
    final NavigatorState navigator = Navigator.of(context);
    await CreateFormFlowDialog.show(
      context,
      save: () async {
        FormEntity toSave = model;
        if (access != AccessManagement.personalAccess) {
          if (createFormDataCubit.state is! CreateFormDataLoaded) {
            return S.current.formSaveFailed;
          }
          // The latest departments / people picked in the dialog.
          toSave = access == AccessManagement.openAccess
              ? createFormDataCubit.addOpenAccessData(model)
              : createFormDataCubit.addRestrictedAccessData(model);
        }
        return homeCubit.publishForm(toSave);
      },
      onFinished: () {
        if (navigator.mounted) {
          navigator.popUntil((route) => route.isFirst);
        }
        homeCubit.getForms(showLoading: false);
      },
    );
  }

  /// Method Name: [publishEdit]
  ///
  /// Purpose: saves an edited form. Bug report #13: switching an existing
  /// form to Open or Restricted Access (tablet) first shows the summary
  /// dialog, so the departments / people can be picked.
  ///
  /// Parameters:
  /// - [context]: a context under the Form Builder providers.
  /// - [oldFormModel]: the form before the edit.
  /// - [newFormModel]: the edited form.
  static void publishEdit({
    required BuildContext context,
    required FormEntity oldFormModel,
    required FormEntity newFormModel,
  }) {
    final HomeCubit cubit = context.read<HomeCubit>();
    final AccessManagement? oldAccess = AccessManagementExtension.fromStored(
      oldFormModel.formHeadModel.accessManagement,
    );
    final AccessManagement? newAccess = AccessManagementExtension.fromStored(
      newFormModel.formHeadModel.accessManagement,
    );
    final bool accessChanged = oldAccess != newAccess &&
        (newAccess == AccessManagement.openAccess ||
            newAccess == AccessManagement.restrictedAccess);
    final bool allowed = cubit.allowEditing(
      old: oldFormModel,
      edited: newFormModel,
    );

    if (accessChanged && context.isTablett && allowed) {
      final CreateFormDataCubit dataCubit = context.read<CreateFormDataCubit>();
      Future<void> saveWithAccess() async {
        final FormEntity model = newAccess == AccessManagement.openAccess
            ? dataCubit.addOpenAccessData(newFormModel)
            : dataCubit.addRestrictedAccessData(newFormModel);
        final Failure? failure = await _withLoading(
          context,
          () => cubit.editFormWithAccess(oldFormModel, model),
        );
        if (!context.mounted) return;
        if (failure != null) {
          await AppDialogs.showError(context, S.current.formSaveFailed);
          return;
        }
        await _showEditSuccess(context, cubit, popTwice: false);
      }

      if (newAccess == AccessManagement.openAccess) {
        AppDialogs.summaryOpenAccessDialog(context, saveWithAccess);
      } else {
        AppDialogs.summaryRestrictedAccessDialog(context, saveWithAccess);
      }
      return;
    }

    if (!allowed) {
      AppDialogs.editingFormNotAllowed(context);
      return;
    }
    AppDialogs.editForm(context, () async {
      Navigator.of(context).pop();
      // FB-HOME-04: success only when the save worked.
      final Failure? failure = await _withLoading(
        context,
        () => cubit.editFormModel(oldFormModel, newFormModel),
      );
      if (!context.mounted) return;
      if (failure != null) {
        await AppDialogs.showError(context, S.current.formSaveFailed);
        return;
      }
      await _showEditSuccess(context, cubit, popTwice: context.isPhone);
    });
  }

  /// Shows "edited successfully", then closes it (and the editor when
  /// [popTwice]) after [HomeFormActions.successDelay].
  static Future<void> _showEditSuccess(
    BuildContext context,
    HomeCubit cubit, {
    required bool popTwice,
  }) async {
    final NavigatorState navigator = Navigator.of(context);
    AppDialogs.editingFormSuccessfully(context);
    cubit.refreshShownList();
    await Future<void>.delayed(HomeFormActions.successDelay);
    if (!navigator.mounted) return;
    if (popTwice) navigator.pop();
    navigator.pop();
  }

  /// Runs [task] behind a non-dismissible loading indicator (bug report
  /// #12: "apply the loading indicator then show success message").
  ///
  /// Returns: what [task] returned (a failure, or null on success).
  static Future<Failure?> _withLoading(
    BuildContext context,
    Future<Failure?> Function() task,
  ) async {
    final NavigatorState rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      // Bug report p.34: the app's default loading indicator.
      barrierColor: AppColors.totalBlack.withOpacity(0.5),
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: SizedBox(
            width: 70,
            height: 70,
            child: CircleProgressMaster.inline(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightPrimary),
              backgroundColor: AppColors.white.withOpacity(0.6),
              strokeWidth: 2.0,
            ),
          ),
        ),
      ),
    );
    // The loader closes whether the task worked or not.
    return task().whenComplete(() {
      if (rootNavigator.mounted) rootNavigator.pop();
    });
  }
}
