/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_champion_entity.dart
/// Purpose: Defines the entity class for Qiyas Champion, converting Firestore model data to domain entities.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `QiyasChampionEntity` class, which is a domain model representing the data for Qiyas Champion.
///              The entity is used to abstract the data that is transferred between the Firestore data model and the business logic layers.
///              The class includes a static method `qiyasChampionFireBasetoEntity` that maps a `QiyasChampionFirestore` object to a
///              `QiyasChampionEntity`. The entity contains various properties such as `timeStamp`, `controlChampion`, `visions`,
///              `topics`, `criteria`, `documentSubmissionDate`, and `additionalNote`. It ensures that Firestore data is properly formatted
///              and transformed into a usable domain model for further processing.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/helper/localized_date.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';

import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/late_unit_enum.dart';

class QiyasChampionEntity {
  String timeStamp;
  String controlChampion;
  String criteriaId;
  String documentNumber;
  DateTime documentSubmissionDate;
  String additionalNote;
  String id;
  int lateUnitMultiplier;
  LateUnitEnum lateUnit;
  QiyasChampionEntity({
    required this.timeStamp,
    required this.controlChampion,
    required this.documentNumber,
    required this.criteriaId,
    required this.documentSubmissionDate,
    required this.additionalNote,
    required this.id,
    required this.lateUnitMultiplier,
    required this.lateUnit,
  });

  static QiyasChampionEntity qiyasChampionFireBasetoEntity(
      QiyasChampionModel qiyasChampionFirestore) {
    return QiyasChampionEntity(
      id: qiyasChampionFirestore.id.isNotEmpty ? qiyasChampionFirestore.id : '',
      timeStamp: qiyasChampionFirestore.timeStamp.isNotEmpty
          ? capitalize(LocalizedDate.forLocale(
              qiyasChampionFirestore.timeStamp.last.toDate(), 'en'))
          : '',
      controlChampion: qiyasChampionFirestore.controlChampion.isNotEmpty
          ? capitalize(qiyasChampionFirestore.controlChampion)
          : '',
      documentNumber: qiyasChampionFirestore.document.isNotEmpty
          ? qiyasChampionFirestore.document
          : '',
      criteriaId: qiyasChampionFirestore.criteriaId.isNotEmpty
          ? qiyasChampionFirestore.criteriaId
          : '',
      documentSubmissionDate:
          qiyasChampionFirestore.documentSubmissionDate.last.toDate(),
      additionalNote: qiyasChampionFirestore.additionalNote.isNotEmpty
          ? capitalize(qiyasChampionFirestore.additionalNote.last)
          : '',
      lateUnitMultiplier: qiyasChampionFirestore.lateUnitMultiplier,
      lateUnit: qiyasChampionFirestore.lateUnit,
    );
  }
}
