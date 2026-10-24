/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: form_entity.dart
/// Description: `FormEntity`, one form with its head data, pages, status and
///              access. Plain data: the Firestore mapping lives in
///              data/mappers/form_entity_mapper.dart and the editor
///              controllers in presentation/controller/fields/.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:intl/intl.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/open_access_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/restricted_access_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/submissions.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';

/// One form with its head data, pages, status and access.
class FormEntity {
  /// Unique identifier for the form
  late String id;

  /// Number of times the form has been used
  late int numberUsed;

  /// Date of the form creation
  late DateTime createDate;
  DateTime? deleteDate;

  late DateTime? submissionDate, receivedDate;
  late String? requestedBy;

  /// Head data for form creation
  late FormHeadData formHeadModel;

  /// The pages of the form
  late List<PageEntity> pages;

  /// enum representing the status of the form
  late FormStatus status;
  bool isEdit;
  List<SubmissionsModel>? submissions = [];
  List<RequestedModel>? requests = [];
  OpenAccessModel? openAccessModel;
  RestrictedAccessModel? restrictedAccessModel;
  PersonEntity personEntity;
  bool isHasAccess;
  FormEntity(
      {required this.id,
      required this.status,
      required this.formHeadModel,
      required this.pages,
      required this.createDate,
      this.requestedBy,
      this.deleteDate,
      this.isEdit = false,
      this.isHasAccess = false,
      this.receivedDate,
      this.submissionDate,
      this.openAccessModel,
      this.restrictedAccessModel,
      this.numberUsed = 0,
      this.submissions,
      required this.personEntity});

  /// Method Name: [duplicate]
  ///
  /// Purpose: copies the form (head data and pages, without answers).
  ///
  /// Parameters:
  /// - [newId]: the id of the copy (the caller builds it, so this entity
  ///   does not read the signed-in user).
  ///
  /// Returns: the copy.
  FormEntity duplicate({required String newId}) {
    FormHeadData newFormHeadModel = formHeadModel.duplicate();
    List<PageEntity> newPages = [];
    for (var element in pages) {
      newPages.add(element.duplicate());
    }
    return FormEntity(
      id: newId,
      status: status,
      formHeadModel: newFormHeadModel,
      pages: newPages,
      createDate: createDate,
      submissionDate: submissionDate,
      receivedDate: receivedDate,
      requestedBy: requestedBy,
      numberUsed: numberUsed,
      openAccessModel: openAccessModel,
      restrictedAccessModel: restrictedAccessModel,
      personEntity: personEntity,
    );
  }

  /// The title in the app's language: the Arabic title in an Arabic UI when
  /// the form has one, otherwise the English title.
  String get getTitle =>
      formHeadModel.titleFor(arabic: Intl.getCurrentLocale().startsWith('ar'));
}
