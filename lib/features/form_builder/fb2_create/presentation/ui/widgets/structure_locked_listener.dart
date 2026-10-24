/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: structure_locked_listener.dart
/// Description: `StructureLockedListener`, shows "this form already has
///              answers" when the editor refuses a structure change. The
///              message used to be shown by the cubit itself.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_assets.dart';

/// Wraps an editor page and tells the user when a structure change was
/// refused (FB-HOME-03: the form already has answers).
class StructureLockedListener extends StatelessWidget {
  const StructureLockedListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateFormDataCubit, CreateFormDataState>(
      listenWhen: (previous, current) =>
          previous is CreateFormDataLoaded &&
          current is CreateFormDataLoaded &&
          current.structureLockedNotice != previous.structureLockedNotice,
      listener: (context, state) {
        CustomDialogManager.showMessage(
          context: context,
          lottiePath: FormBuilderAssets.warningRedLottie,
          title: S.of(context).editingForm,
          subtitle: S.of(context).cantEditFormBecauseSubmitted,
        );
      },
      child: child,
    );
  }
}
