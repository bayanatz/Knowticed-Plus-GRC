/// Module: form_builder_module/f3_form_details
///
///*************************** FILE INFO ****************************///
/// File Name: form_details_cubit.dart
/// Description: `FormDetailsCubit`, the controller of the form details
///              screen. Holds the form shown and swaps in the newest copy
///              after the home lists reload (vertical bug report p.20: an
///              edit shows as soon as the save lands).
/// Author: Amr Mesbah
/// Created at: 19/10/2026
/// Updated: 23/10/2026 - Listens to the home lists and deletes the form
///                       itself, so the screen no longer drives HomeCubit
///                       (Details rule 1).
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_state.dart';
import 'package:knowticed_plus/features/form_builder/fb3_form_details/presentation/controller/form_details_state.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';

/// The controller of the form details screen.
class FormDetailsCubit extends Cubit<FormDetailsState> {
  /// The home lists (the form is saved and deleted there).
  final HomeCubit homeCubit;

  late final StreamSubscription<HomeState> _homeSubscription;

  FormDetailsCubit({required FormEntity form, required this.homeCubit})
    : super(FormDetailsState(form: form)) {
    _homeSubscription = homeCubit.stream.listen(_onHomeChanged);
  }

  void _onHomeChanged(HomeState homeState) {
    if (homeState is! HomeLoaded) return;
    formsReloaded([
      ...homeState.publishForms,
      ...homeState.draftForms,
      ...homeState.deletedForms,
    ]);
  }

  /// Method Name: [formsReloaded]
  ///
  /// Purpose: the home lists were rebuilt (new FormEntity objects); shows
  /// the newest copy of this form.
  ///
  /// Parameters:
  /// - [forms]: every form in the reloaded lists.
  void formsReloaded(Iterable<FormEntity> forms) {
    for (final FormEntity form in forms) {
      if (form.id != state.form.id) continue;
      if (!identical(form, state.form) && !isClosed) {
        emit(FormDetailsState(form: form));
      }
      return;
    }
  }

  /// Method Name: [deleteForm]
  ///
  /// Purpose: deletes the form shown, re-checking the Delete permission.
  ///
  /// Returns: true when the form was deleted.
  Future<bool> deleteForm() async {
    if (!FormBuilderAccess.canDeleteForm) return false;
    return homeCubit.deleteFormModel(state.form);
  }

  @override
  Future<void> close() async {
    await _homeSubscription.cancel();
    return super.close();
  }
}
