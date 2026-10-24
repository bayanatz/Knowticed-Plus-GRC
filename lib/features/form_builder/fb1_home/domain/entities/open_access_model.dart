/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: open_access_model.dart
/// Description: `OpenAccessModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/department_entity.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';

class OpenAccessModel {
  bool isEdit;
  DateTime? timeBegin, timeEnd;
  List<DepartmentEntity>? selectedDepartments;
  List<PersonEntity>? selectedPersons;
  OpenAccessModel(
      {required this.isEdit,
      this.timeBegin,
      this.selectedPersons,
      this.timeEnd,
      this.selectedDepartments});
}
