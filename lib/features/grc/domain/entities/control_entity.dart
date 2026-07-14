/// Module: Policy Management
/// Description: Defines the Control Entity used by the app's UI/business
///              logic layer. Holds the latest (current) values of a single
///              Control record as plain single fields. Controls now live in
///              their own Firestore subcollection under a Policy document.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: ControlStatus
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Migrated to the Controls subcollection
///                                schema: added policyId, number fields,
///                                split documents (En/Ar), start/end dates,
///                                departments, equalWeights, score, and
///                                ControlStatus. Removed isDeleted in favor
///                                of ControlStatus.unassigned/expired
///                                (Mohamed Magdy Abdelkhalek)

import 'control_status.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_entity.dart
/// Purpose: Contains the ControlEntity class, a flat (non-list)
///          representation of a Control record, derived from the latest
///          index of the ControlModel. This is what the Presentation and
///          Domain layers consume directly.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [ControlEntity]
///
/// purpose: holds the current (latest) values of a Control record as plain
///          single fields. Controls are stored as a subcollection under a
///          Policy document (GRC_Modules/{Module_ID}/Policies/{Policy_ID}/
///          Controls/{Control_ID}) and each Control carries its own
///          tracking fields (lastModifiedDate, lastEditorId) derived from
///          its own revision history in [ControlModel].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class ControlEntity {
  final String id;
  final String policyId;
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsNumberEn;
  final String controlsNumberAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final String? controlsDocumentEn;
  final String? controlsDocumentAr;
  final double controlsWeight;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> departments;
  final bool equalWeights;
  final int score;
  final ControlStatus status;

  // Tracking fields (latest values only)
  final DateTime lastModifiedDate;
  final String lastEditor;

  const ControlEntity({
    required this.id,
    required this.policyId,
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsNumberEn,
    required this.controlsNumberAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.controlsDocumentEn,
    required this.controlsDocumentAr,
    required this.controlsWeight,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.departments,
    required this.equalWeights,
    required this.score,
    required this.status,
    required this.lastModifiedDate,
    required this.lastEditor,
  });

  /// function name: [copyWith]
  ///
  /// purpose: create a new [ControlEntity] instance with selected fields
  ///          replaced by new values, keeping all other fields unchanged.
  ///
  /// parameters:
  ///            [String] controlsNameEn: new English control name, if changed
  ///            [String] controlsNameAr: new Arabic control name, if changed
  ///            [String] controlsNumberEn: new English control number, if changed
  ///            [String] controlsNumberAr: new Arabic control number, if changed
  ///            [String] controlsDescriptionEn: new English description, if changed
  ///            [String] controlsDescriptionAr: new Arabic description, if changed
  ///            [String] controlsDocumentEn: new English document url/path, if changed
  ///            [String] controlsDocumentAr: new Arabic document url/path, if changed
  ///            [double] controlsWeight: new weight value, if changed
  ///            [String] frequency: new frequency value, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [List<String>] departments: new departments list, if changed
  ///            [bool] equalWeights: new equal-weights flag, if changed
  ///            [int] score: new score value, if changed
  ///            [ControlStatus] status: new status, if changed
  ///
  /// return type: [ControlEntity] - the updated entity instance
  ControlEntity copyWith({
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsNumberEn,
    String? controlsNumberAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    String? controlsDocumentEn,
    String? controlsDocumentAr,
    double? controlsWeight,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? departments,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
  }) {
    return ControlEntity(
      id: id,
      policyId: policyId,
      controlsNameEn: controlsNameEn ?? this.controlsNameEn,
      controlsNameAr: controlsNameAr ?? this.controlsNameAr,
      controlsNumberEn: controlsNumberEn ?? this.controlsNumberEn,
      controlsNumberAr: controlsNumberAr ?? this.controlsNumberAr,
      controlsDescriptionEn:
          controlsDescriptionEn ?? this.controlsDescriptionEn,
      controlsDescriptionAr:
          controlsDescriptionAr ?? this.controlsDescriptionAr,
      controlsDocumentEn: controlsDocumentEn ?? this.controlsDocumentEn,
      controlsDocumentAr: controlsDocumentAr ?? this.controlsDocumentAr,
      controlsWeight: controlsWeight ?? this.controlsWeight,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      departments: departments ?? this.departments,
      equalWeights: equalWeights ?? this.equalWeights,
      score: score ?? this.score,
      status: status ?? this.status,
      lastModifiedDate: lastModifiedDate,
      lastEditor: lastEditor,
    );
  }
}