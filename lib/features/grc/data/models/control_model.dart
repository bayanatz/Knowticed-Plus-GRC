/// Module: Policy Management
/// Description: Defines the Control Model used for data persistence. Every
///              field is stored as a history List so that previous values
///              are never lost and each edit is fully traceable.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: ControlEntity
/// Revision History: 2026-07-5 - Initial creation

import 'package:demo_app/features/grc/domain/entities/control_entity.dart';


/// ************************* FILE INFO *************************** ///
/// File Name: control_model.dart
/// Purpose: Contains the ControlModel class used for Firestore
///          (de)serialization. Controls are nested within PolicyModel but
///          carry their own revision history and tracking.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [ControlModel]
///
/// purpose: represents a single Control record where every field is kept as
///          a List<...>. Each index across all the Lists (including
///          [editors] and [lastModifiedDate]) represents one historical
///          version of the Control at the same point in time.
///
///          Controls are stored as a nested list inside [PolicyModel]:
///          PolicyModel.controls = List<List<ControlModel>>
///          where the outer index = policy revision, inner list = controls
///          at that revision.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class ControlModel {
  final String id;
  final List<String> controlsNameEn;
  final List<String> controlsNameAr;
  final List<String> controlsDescriptionEn;
  final List<String> controlsDescriptionAr;
  final List<String> controlsDocument;
  final List<double> controlsWeight;
  final List<String> frequency;
  final List<bool> isDeleted;

  // Tracking fields
  final List<DateTime> lastModifiedDate;
  final List<String> editors;

  ControlModel({
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
    required this.editors,
  }) {
    assert(
      _allSameLength(),
      'All ControlModel Lists must have the same number of elements (same index count)',
    );
  }

  /// function name: [_allSameLength]
  ///
  /// purpose: validate that every history List inside the model has the
  ///          same length, guaranteeing index synchronization across all
  ///          fields and tracking lists.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if all Lists share the same length
  bool _allSameLength() {
    final lengths = <int>{
      controlsNameEn.length,
      controlsNameAr.length,
      controlsDescriptionEn.length,
      controlsDescriptionAr.length,
      controlsDocument.length,
      controlsWeight.length,
      frequency.length,
      isDeleted.length,
      lastModifiedDate.length,
      editors.length,
    };
    return lengths.length == 1;
  }

  /// function name: [ControlModel.create]
  ///
  /// purpose: build a brand new [ControlModel] record where every history
  ///          List is initialized with a single element representing the
  ///          first (creation) revision of this Control.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the new control
  ///            [String] controlsNameEn: initial English control name
  ///            [String] controlsNameAr: initial Arabic control name
  ///            [String] controlsDescriptionEn: initial English description
  ///            [String] controlsDescriptionAr: initial Arabic description
  ///            [String] controlsDocument: initial document url/path
  ///            [double] controlsWeight: initial weight value
  ///            [String] frequency: initial frequency value
  ///            [String] editorId: id of the user creating this control
  ///
  /// return type: [ControlModel] - the newly created model instance
  factory ControlModel.create({
    required String id,
    required String controlsNameEn,
    required String controlsNameAr,
    required String controlsDescriptionEn,
    required String controlsDescriptionAr,
    required String controlsDocument,
    required double controlsWeight,
    required String frequency,
    required String editorId,
  }) {
    final now = DateTime.now();
    return ControlModel(
      id: id,
      controlsNameEn: [controlsNameEn],
      controlsNameAr: [controlsNameAr],
      controlsDescriptionEn: [controlsDescriptionEn],
      controlsDescriptionAr: [controlsDescriptionAr],
      controlsDocument: [controlsDocument],
      controlsWeight: [controlsWeight],
      frequency: [frequency],
      isDeleted: [false],
      lastModifiedDate: [now],
      editors: [editorId],
    );
  }

  /// function name: [copyWithUpdate]
  ///
  /// purpose: append a new revision (new index) to every history List in
  ///          the control. Any field not explicitly passed reuses its last
  ///          known value, ensuring all Lists remain the same length.
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
  ///            [String] editorId: id of the user performing the update (required)
  ///
  /// return type: [ControlModel] - a new model instance with the appended revision
  ControlModel copyWithUpdate({
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    String? controlsDocument,
    double? controlsWeight,
    String? frequency,
    bool? isDeleted,
    required String editorId,
  }) {
    final now = DateTime.now();
    return ControlModel(
      id: id,
      controlsNameEn: [
        ...this.controlsNameEn,
        controlsNameEn ?? this.controlsNameEn.last,
      ],
      controlsNameAr: [
        ...this.controlsNameAr,
        controlsNameAr ?? this.controlsNameAr.last,
      ],
      controlsDescriptionEn: [
        ...this.controlsDescriptionEn,
        controlsDescriptionEn ?? this.controlsDescriptionEn.last,
      ],
      controlsDescriptionAr: [
        ...this.controlsDescriptionAr,
        controlsDescriptionAr ?? this.controlsDescriptionAr.last,
      ],
      controlsDocument: [
        ...this.controlsDocument,
        controlsDocument ?? this.controlsDocument.last,
      ],
      controlsWeight: [
        ...this.controlsWeight,
        controlsWeight ?? this.controlsWeight.last,
      ],
      frequency: [...this.frequency, frequency ?? this.frequency.last],
      isDeleted: [...this.isDeleted, isDeleted ?? this.isDeleted.last],
      lastModifiedDate: [...lastModifiedDate, now],
      editors: [...editors, editorId],
    );
  }

  /// function name: [toJson]
  ///
  /// purpose: serialize the control model into a Map ready to be stored
  ///          as a nested object inside a Firestore Policy document.
  ///          Keys follow the convention: each word capitalized, separated
  ///          by underscores (e.g. "Controls_Name_En"). ID is stored as "ID".
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, dynamic>] - the Firestore-ready representation of this control
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Controls_Name_En': controlsNameEn,
      'Controls_Name_Ar': controlsNameAr,
      'Controls_Description_En': controlsDescriptionEn,
      'Controls_Description_Ar': controlsDescriptionAr,
      'Controls_Document': controlsDocument,
      'Controls_Weight': controlsWeight,
      'Frequency': frequency,
      'Is_Deleted': isDeleted,
      'Last_Modified_Date':
          lastModifiedDate.map((d) => d.toIso8601String()).toList(),
      'Editors': editors,
    };
  }

  /// function name: [ControlModel.fromJson]
  ///
  /// purpose: rebuild a [ControlModel] instance from the raw nested Map
  ///          retrieved from Firestore.
  ///
  /// parameters:
  ///            [Map<String, dynamic>] json: the raw nested control data from Firestore
  ///
  /// return type: [ControlModel] - the reconstructed model instance
  factory ControlModel.fromJson(Map<String, dynamic> json) {
    final editorsRaw = List<String>.from(json['Editors'] ?? []);
    return ControlModel(
      id: json['ID'] as String,
      controlsNameEn: List<String>.from(json['Controls_Name_En'] ?? []),
      controlsNameAr: List<String>.from(json['Controls_Name_Ar'] ?? []),
      controlsDescriptionEn:
          List<String>.from(json['Controls_Description_En'] ?? []),
      controlsDescriptionAr:
          List<String>.from(json['Controls_Description_Ar'] ?? []),
      controlsDocument: List<String>.from(json['Controls_Document'] ?? []),
      controlsWeight: List<double>.from(json['Controls_Weight'] ?? []),
      frequency: List<String>.from(json['Frequency'] ?? []),
      isDeleted: json['Is_Deleted'] != null
          ? List<bool>.from(json['Is_Deleted'])
          : List<bool>.filled(editorsRaw.length, false),
      lastModifiedDate: (json['Last_Modified_Date'] as List? ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList(),
      editors: editorsRaw,
    );
  }

  /// function name: [toEntity]
  ///
  /// purpose: convert this model (full revision history) into a
  ///          [ControlEntity] that holds only the latest (current) value
  ///          of every field, derived from the last index of each List.
  ///
  /// parameters: none
  ///
  /// return type: [ControlEntity] - the flattened entity built from the last index of every List
  ControlEntity toEntity() {
    return ControlEntity(
      id: id,
      controlsNameEn: controlsNameEn.last,
      controlsNameAr: controlsNameAr.last,
      controlsDescriptionEn: controlsDescriptionEn.last,
      controlsDescriptionAr: controlsDescriptionAr.last,
      controlsDocument: controlsDocument.last,
      controlsWeight: controlsWeight.last,
      frequency: frequency.last,
      isDeleted: isDeleted.last,
      lastModifiedDate: lastModifiedDate.last,
      lastEditorId: editors.last,
    );
  }
}