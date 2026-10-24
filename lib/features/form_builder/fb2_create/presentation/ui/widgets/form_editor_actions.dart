/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_editor_actions.dart
/// Description: `FormEditorActions`, the Publish / Save / Save For Later
///              logic shared by the phone and tablet editors, so the two
///              layouts run the same checks and the same save flow.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/home_form_actions.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/home_publish_actions.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/form_editor_keys.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Publish / Save / Save For Later for both editor layouts.
class FormEditorActions {
  const FormEditorActions._();

  /// Method Name: [publish]
  ///
  /// Purpose: validates the header and the pages, builds the form and
  /// publishes it, or saves the edit of [editing]. FB-HOME-18: the header
  /// is validated too, not only the pages. A second tap while a publish is
  /// starting is ignored.
  ///
  /// Parameters:
  /// - [context]: a context under the editor's providers.
  /// - [editing]: the form being edited, or null for a new form.
  static void publish(BuildContext context, {FormEntity? editing}) {
    final CreateFormDataCubit dataCubit = context.read<CreateFormDataCubit>();
    final FormEntity? model = _validatedForm(context);
    if (model == null) return;
    if (!dataCubit.tryStartPublish()) return;
    if (editing != null) {
      HomePublishActions.publishEdit(
        context: context,
        oldFormModel: editing,
        newFormModel: model,
      );
    } else {
      HomePublishActions.publishNewForm(
        context: context,
        model: model,
        createFormDataCubit: dataCubit,
      );
    }
    dataCubit.endPublish();
  }

  /// Method Name: [saveForLater]
  ///
  /// Purpose: validates the header and saves the new form as a draft.
  ///
  /// Parameters:
  /// - [context]: a context under the editor's providers.
  static void saveForLater(BuildContext context) {
    final FormEntity? model = _validatedForm(context, validatePages: false);
    if (model == null) return;
    HomeFormActions.draftNewForm(context, model);
  }

  /// Checks that both editor cubits are loaded and the mounted forms are
  /// valid, then builds the form. Shows the reason and returns null when
  /// it cannot be built.
  static FormEntity? _validatedForm(
    BuildContext context, {
    bool validatePages = true,
  }) {
    final CreateFormHeadCubit headCubit = context.read<CreateFormHeadCubit>();
    final CreateFormDataCubit dataCubit = context.read<CreateFormDataCubit>();
    if (headCubit.state is! CreateFormHeadLoaded ||
        dataCubit.state is! CreateFormDataLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).fbFormDataNotReady),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }

    final FormEditorKeys keys = context.read<FormEditorKeys>();
    final bool headValid = keys.headFormKey.currentState?.validate() ?? true;
    final bool pagesValid =
        !validatePages || (keys.dataFormKey.currentState?.validate() ?? true);
    if (!headValid || !pagesValid) return null;

    // Building the form can fail; the cubit catches that (Home rule 14).
    final FormEntity? model = dataCubit.buildFormForPublish();
    if (model == null) {
      AppDialogs.showError(context, S.of(context).formSaveFailed);
    }
    return model;
  }
}
