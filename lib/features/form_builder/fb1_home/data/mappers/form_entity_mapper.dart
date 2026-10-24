/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: form_entity_mapper.dart
/// Description: Maps `FormEntity`, `PageEntity` and `RowEntity` to and from
///              the Firestore models (moved out of the domain entities).
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_directory.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/data/mappers/field_model_mapper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/open_access_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/restricted_access_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/row_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/mappers/person_entity_factory.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/column_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/form_model.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/page_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/row_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/watermark_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/department_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';

/// Maps a [FormEntity] to and from the Firestore [FormModel].
extension FormEntityMapper on FormEntity {
  /// Method Name: [toModel]
  ///
  /// Purpose: builds the Firestore form document. The creator is the
  /// signed-in employee, as before.
  ///
  /// Returns: [FormModel].
  FormModel toModel() {
    return FormModel(
      id: id,
      timestamps: [Timestamp.fromDate(createDate)],
      createdByEmail: FormBuilderDirectory.currentUserEmail,
      arabicDescription: [formHeadModel.arDescription ?? ""],
      arabicTitle: [formHeadModel.arTitle ?? ""],
      description: [formHeadModel.description],
      title: [formHeadModel.title],
      image: formHeadModel.cover == null ? [] : [formHeadModel.cover ?? ''],
      accessMangement: [formHeadModel.accessManagement.toLowerCase()],
      orientation: [formHeadModel.orientation],
      horizontalPadding: [formHeadModel.horizontalPadding.toString()],
      verticalPadding: [formHeadModel.verticalPadding.toString()],
      formStatus: [status.name.toLowerCase()],
      watermark: WatermarkModel(
        imageUrl:
            formHeadModel.watermark == null ? [] : [formHeadModel.watermark!],
        imageName: formHeadModel.watermark == null
            ? []
            : [formHeadModel.watermark!.split('/').last.split('.').first],
        opacity: [formHeadModel.watermarkOpacity.toString()],
        size: [formHeadModel.watermarkSize.toString()],
      ),
      pages: pages.map((e) => e.toModel()).toList(),
    );
  }

  /// Method Name: [fromModel]
  ///
  /// Purpose: builds a [FormEntity] from the form document and its privacy
  /// record. FB-HOME-08: a creator or an access-list email that is no longer
  /// in the employee list does not throw; it shows as a former employee.
  ///
  /// Parameters:
  /// - [formModel]: the form document.
  /// - [formPrivacyModel]: the form's access record.
  /// - [usedBy]: how many people used the form.
  /// - [isEdit]: whether the viewer may edit their answer.
  /// - [isHasAccess]: whether the viewer still has access.
  ///
  /// Returns: [FormEntity].
  static FormEntity fromModel(
    FormModel formModel,
    FormPrivacyModel formPrivacyModel, {
    int usedBy = 0,
    bool isEdit = false,
    bool isHasAccess = false,
  }) {
    final AccessManagement? access = AccessManagementExtension.fromStored(
      formModel.accessMangement.last,
    );
    final usersModel = formPrivacyModel.usersModel;
    final DateTime? timeBegin =
        (usersModel?.accessBegin != null && usersModel!.accessBegin!.isNotEmpty)
            ? usersModel.accessBegin!.last?.toDate()
            : null;
    final DateTime? timeEnd =
        (usersModel?.accessEnd != null && usersModel!.accessEnd!.isNotEmpty)
            ? usersModel.accessEnd!.last?.toDate()
            : null;

    return FormEntity(
      isEdit: isEdit,
      isHasAccess: isHasAccess,
      personEntity: PersonEntityFactory.fromEmail(formModel.createdByEmail),
      id: formModel.id,
      status: FormStatus.values.firstWhere(
        (element) =>
            element.name.toLowerCase() ==
            formModel.formStatus.last.toLowerCase(),
      ),
      formHeadModel: FormHeadData(
        title: formModel.title.last,
        arTitle: formModel.arabicTitle.last,
        description: formModel.description.last,
        arDescription: formModel.arabicDescription.last,
        cover: formModel.image!.lastOrNull,
        // Stored as AccessManagement.name so every comparison matches.
        accessManagement: access?.name ?? formModel.accessMangement.last,
        orientation: formModel.orientation.last,
        horizontalPadding: double.parse(formModel.horizontalPadding.last),
        verticalPadding: double.parse(formModel.verticalPadding.last),
        watermark: formModel.watermark.imageUrl.lastOrNull,
        watermarkOpacity: int.parse(formModel.watermark.opacity.last),
        watermarkSize: int.parse(formModel.watermark.size.last),
      ),
      pages: formModel.pages.map((e) => PageEntityMapper.fromModel(e)).toList(),
      createDate: formModel.timestamps.first.toDate(),
      requestedBy: formModel.createdByEmail,
      numberUsed: usedBy,
      deleteDate: formModel.formStatus.last.toLowerCase() ==
              FormStatus.deleted.name.toLowerCase()
          ? formModel.timestamps.last.toDate()
          : null,
      openAccessModel: access == AccessManagement.openAccess
          ? OpenAccessModel(
              selectedDepartments:
                  (usersModel?.emails != null && usersModel!.emails!.isNotEmpty)
                      // FB-HOME-08: emails that are no longer in the employee
                      // list (or have no department) are skipped.
                      ? usersModel.emails!
                          .map(
                            (e) => FormBuilderDirectory.employeeByEmail(e)
                                ?.departmentId,
                          )
                          .whereType<String>()
                          .map(
                            (departmentId) => DepartmentEntity(
                              nameAr: FormBuilderDirectory.departmentName(
                                departmentId,
                                english: false,
                              ),
                              name: FormBuilderDirectory.departmentName(
                                departmentId,
                                english: true,
                              ),
                              id: departmentId,
                            ),
                          )
                          .toList()
                      : [],
              isEdit: isEdit,
              timeBegin: timeBegin,
              timeEnd: timeEnd,
            )
          : null,
      restrictedAccessModel: access != AccessManagement.personalAccess
          ? RestrictedAccessModel(
              isEdit: (usersModel?.editPermission != null &&
                      usersModel!.editPermission!.isNotEmpty)
                  ? usersModel.editPermission!.last
                  : false,
              timeBegin: timeBegin,
              timeEnd: timeEnd,
              selectedPersons: usersModel != null
                  ? PersonEntityFactory.fromUsersModel(usersModel)
                  : null,
            )
          : null,
    );
  }
}

/// Maps a [PageEntity] to and from the Firestore [PageModel].
extension PageEntityMapper on PageEntity {
  /// Method Name: [toModel]
  ///
  /// Purpose: builds the Firestore page.
  ///
  /// Returns: [PageModel].
  PageModel toModel() {
    return PageModel(rows: rows.map((row) => row.toModel()).toList());
  }

  /// Method Name: [fromModel]
  ///
  /// Purpose: builds a page from the Firestore page.
  ///
  /// Parameters:
  /// - [model]: the Firestore page.
  ///
  /// Returns: [PageEntity].
  static PageEntity fromModel(PageModel model) {
    return PageEntity(
      rows: model.rows.map((row) => RowEntityMapper.fromModel(row)).toList(),
    );
  }
}

/// Maps a [RowEntity] to and from the Firestore [RowModel].
extension RowEntityMapper on RowEntity {
  /// Method Name: [toModel]
  ///
  /// Purpose: builds the Firestore row.
  ///
  /// Returns: [RowModel].
  RowModel toModel() {
    final List<ColumnModel> columns = [];
    for (final FieldModel field in fields) {
      columns.add(field.toModel());
    }
    return RowModel(columns: columns);
  }

  /// Method Name: [fromModel]
  ///
  /// Purpose: builds a row from the Firestore row.
  ///
  /// Parameters:
  /// - [model]: the Firestore row.
  ///
  /// Returns: [RowEntity].
  static RowEntity fromModel(RowModel model) {
    final List<FieldModel> fields = [];
    for (final ColumnModel column in model.columns) {
      fields.add(FieldModelColumnMapper.fromModel(column)!);
    }
    return RowEntity(fields: fields);
  }
}
