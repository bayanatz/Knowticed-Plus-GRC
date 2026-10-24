/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_form_actions.dart
/// Description: `HomeFormActions`, the dialogs and navigation of the home
///              cards (open, duplicate, edit, PDF, delete, restore, draft).
///              Moved out of `HomeCubit`, which now only saves and emits.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/constants/app_routes.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/menu.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The dialogs and navigation of the home cards. The [HomeCubit] read from
/// [BuildContext] does the saving; these methods only talk to the user.
class HomeFormActions {
  const HomeFormActions._();

  /// How long a success message stays before the screen closes.
  static const Duration successDelay = Duration(seconds: 2);

  /// Method Name: [onMenuSelect]
  ///
  /// Purpose: runs a card-menu action. Every action is re-checked at tap
  /// time through [FormBuilderAccess], not only hidden in the menu.
  ///
  /// Parameters:
  /// - [context]: a context under the [HomeCubit] provider.
  /// - [value]: the picked action.
  /// - [formModel]: the form of the card.
  static void onMenuSelect(
    BuildContext context,
    MenuEnum? value, {
    required FormEntity formModel,
  }) {
    switch (value) {
      case MenuEnum.duplicate:
        if (FormBuilderAccess.canDuplicateForm) duplicate(context, formModel);
        return;
      case MenuEnum.edit:
        if (FormBuilderAccess.canEditForm) edit(context, formModel);
        return;
      case MenuEnum.convertToPDF:
        if (FormBuilderAccess.canConvertToPdf) convertPdf(context, formModel);
        return;
      case MenuEnum.delete:
        if (FormBuilderAccess.canDeleteForm) delete(context, formModel);
        return;
      // Only offered on the Deleted tab.
      case MenuEnum.restore:
        if (FormBuilderAccess.canRestoreForm) restore(context, formModel);
        return;
      case null:
        return;
    }
  }

  /// Method Name: [openForm]
  ///
  /// Purpose: opens a card: details (Publish), the editor (Drafts,
  /// Deleted) or the answers (Requested, Submissions).
  ///
  /// Parameters:
  /// - [context]: a context under the [HomeCubit] provider.
  /// - [model]: the form of the card.
  static void openForm(BuildContext context, FormEntity model) {
    switch (context.read<HomeCubit>().selectedTab) {
      case FormStatus.publish:
        context.FormNavigateTo(Routes.formDetailsScreen, arguments: model);
        return;
      case FormStatus.drafts:
      case FormStatus.deleted:
        edit(context, model);
        return;
      case FormStatus.requestedForms:
      case FormStatus.submissions:
        context.FormNavigateTo(Routes.submissionsScreen, arguments: model);
        return;
    }
  }

  /// Method Name: [edit]
  ///
  /// Purpose: opens the editor for [formModel] (it picks the phone or tablet
  /// layout itself).
  ///
  /// Parameters:
  /// - [context]: the caller's context.
  /// - [formModel]: the form.
  static void edit(BuildContext context, FormEntity formModel) {
    context.FormNavigateTo(Routes.create, arguments: formModel);
  }

  /// Method Name: [convertPdf]
  ///
  /// Purpose: opens the PDF screen for [formModel] (its route provides the
  /// PdfCubit).
  ///
  /// Parameters:
  /// - [context]: the caller's context.
  /// - [formModel]: the form.
  static void convertPdf(BuildContext context, FormEntity formModel) {
    context.FormNavigateTo(Routes.convertPdf, arguments: formModel);
  }

  /// Method Name: [delete]
  ///
  /// Purpose: confirm → delete → success. The success step is shown only
  /// when the delete worked.
  ///
  /// Parameters:
  /// - [context]: a context under the [HomeCubit] provider.
  /// - [formModel]: the form.
  static void delete(BuildContext context, FormEntity formModel) {
    final HomeCubit cubit = context.read<HomeCubit>();
    AppDialogs.deleteForm(context, () => cubit.deleteFormModel(formModel));
  }

  /// Method Name: [duplicate]
  ///
  /// Purpose: asks for the copy's names, then saves the copy. FB-HOME-04: a
  /// failed copy is reported.
  ///
  /// Parameters:
  /// - [context]: a context under the [HomeCubit] provider.
  /// - [formModel]: the form to copy.
  static void duplicate(BuildContext context, FormEntity formModel) {
    final HomeCubit cubit = context.read<HomeCubit>();
    AppDialogs.duplicateFormDialog(
      context,
      formModel.formHeadModel.title,
      formModel.formHeadModel.arTitle ?? formModel.formHeadModel.title,
      cubit.duplicateVersionFor(formModel.formHeadModel.title),
      (newEnglishName, newArabicName) async {
        final Failure? failure = await cubit.duplicateFormModel(
          formModel,
          newEnglishName,
          newArabicName,
        );
        if (failure != null && context.mounted) {
          await AppDialogs.showError(context, S.current.formSaveFailed);
        }
      },
    );
  }

  /// Method Name: [restore]
  ///
  /// Purpose: confirm → restore → success → back to the Form Builder home.
  ///
  /// Parameters:
  /// - [context]: a context under the [HomeCubit] provider.
  /// - [model]: the deleted form.
  static void restore(BuildContext context, FormEntity model) {
    final HomeCubit cubit = context.read<HomeCubit>();
    AppDialogs.restoreForm(
      context,
      () => cubit.restoreForm(model),
      onSuccessComplete: () {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
    );
  }

  /// Method Name: [draftNewForm]
  ///
  /// Purpose: confirm → save as draft → success → back to the home screen.
  /// FB-HOME-04: a failed save is reported.
  ///
  /// Parameters:
  /// - [context]: a context under the [HomeCubit] provider.
  /// - [model]: the new form.
  static void draftNewForm(BuildContext context, FormEntity model) {
    final HomeCubit cubit = context.read<HomeCubit>();
    AppDialogs.draftForm(context, () async {
      Navigator.of(context).pop();
      final Failure? failure = await cubit.saveDraft(model);
      if (!context.mounted) return;
      if (failure != null) {
        await AppDialogs.showError(context, S.current.formSaveFailed);
        return;
      }
      final NavigatorState navigator = Navigator.of(context);
      AppDialogs.draftingFormSuccessfully(context);
      await Future<void>.delayed(successDelay);
      if (!navigator.mounted) return;
      navigator.pop();
      navigator.popUntil((route) => route.isFirst);
    });
  }
}
