/// Module: Policy Management
/// Description: Defines the Control Entity used by the app's UI/business
///              logic layer. Holds the latest (current) values of a single
///              Control record as plain single fields.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: None
/// Revision History: 2026-07-5 - Initial creation

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
///          single fields. Controls are nested children of a [PolicyEntity]
///          and each Control carries its own tracking fields (lastModifiedDate,
///          lastEditorId) derived from the innermost versioning of
///          [ControlModel].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class ControlEntity {
  final String id;
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final String controlsDocument;
  final double controlsWeight;
  final String frequency;
  final bool isDeleted;

  // Tracking fields (latest values only)
  final DateTime lastModifiedDate;
  final String lastEditorId;

  const ControlEntity({
    required this.id,
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.controlsDocument,
    required this.controlsWeight,
    required this.frequency,
    required this.isDeleted,
    required this.lastModifiedDate,
    required this.lastEditorId,
  });

  /// function name: [copyWith]
  ///
  /// purpose: create a new [ControlEntity] instance with selected fields
  ///          replaced by new values, keeping all other fields unchanged.
  ///
  /// parameters:
  ///            [String] controlsNameEn: new English control name, if changed
  ///            [String] controlsNameAr: new Arabic control name, if changed
  ///            [String] controlsDescriptionEn: new English description, if changed
  ///            [String] controlsDescriptionAr: new Arabic description, if changed
  ///            [String] controlsDocument: new document url/path, if changed
  ///            [double] controlsWeight: new weight value, if changed
  ///            [String] frequency: new frequency value, if changed
  ///            [bool] isDeleted: new soft-delete flag, if changed
  ///
  /// return type: [ControlEntity] - the updated entity instance
  ControlEntity copyWith({
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    String? controlsDocument,
    double? controlsWeight,
    String? frequency,
    bool? isDeleted,
  }) {
    return ControlEntity(
      id: id,
      controlsNameEn: controlsNameEn ?? this.controlsNameEn,
      controlsNameAr: controlsNameAr ?? this.controlsNameAr,
      controlsDescriptionEn:
          controlsDescriptionEn ?? this.controlsDescriptionEn,
      controlsDescriptionAr:
          controlsDescriptionAr ?? this.controlsDescriptionAr,
      controlsDocument: controlsDocument ?? this.controlsDocument,
      controlsWeight: controlsWeight ?? this.controlsWeight,
      frequency: frequency ?? this.frequency,
      isDeleted: isDeleted ?? this.isDeleted,
      lastModifiedDate: lastModifiedDate,
      lastEditorId: lastEditorId,
    );
  }
}