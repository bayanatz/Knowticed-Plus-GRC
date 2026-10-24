/// Module: form_builder_module/f3_form_details
///
///*************************** FILE INFO ****************************///
/// File Name: form_details_state.dart
/// Description: `FormDetailsState`, the form shown on the details screen.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:equatable/equatable.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';

/// The form shown on the details screen.
class FormDetailsState extends Equatable {
  /// The newest copy of the form.
  final FormEntity form;

  const FormDetailsState({required this.form});

  @override
  List<Object?> get props => [identityHashCode(form)];
}
