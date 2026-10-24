/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: restricted_access_model.dart
/// Description: `RestrictedAccessModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';

class RestrictedAccessModel {
  bool isEdit;
  DateTime? timeBegin, timeEnd;
  List<PersonEntity>? selectedPersons;

  RestrictedAccessModel(
      {required this.isEdit,
      this.timeBegin,
      this.timeEnd,
      this.selectedPersons});
}
