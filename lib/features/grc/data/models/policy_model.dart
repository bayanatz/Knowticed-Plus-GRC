/// Module: Policy Management
/// Description: Defines the Policy Model used for data persistence. Every
///              field is stored as a history List so that previous values
///              are never lost and each edit is fully traceable. The controls
///              field is a nested List<List<ControlModel>> where the outer
///              index corresponds to the policy revision and the inner list
///              contains the controls snapshot at that revision.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: ControlModel, PolicyEntity
/// Revision History: 2026-07-5 - Initial creation

import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';


import 'control_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_model.dart
/// Purpose: Contains the PolicyModel class used for create/update/read
///          operations and Firestore (de)serialization.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyModel]
///
/// purpose: represents a Policy record where every field is kept as a
///          List<...>. Each index across all Lists (including [editors] and
///          [lastModifiedDate]) represents one historical version of the
///          record at the same point in time.
///
///          [controls] follows the same pattern as all other fields but
///          its type is List<List<ControlModel>>:
///            - outer index → policy revision number
///            - inner list  → snapshot of all controls at that revision
///
///          Every update must append one new element to every List (reusing
///          the last value for unchanged fields) so all Lists always stay
///          the same length.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class PolicyModel {
  final String id;
  final List<String> image;
  final List<String> policyNameEn;
  final List<String> policyNameAr;
  final List<String> policyNumberEn;
  final List<String> policyNumberAr;
  final List<String> policyDescriptionEn;
  final List<String> policyDescriptionAr;
  final List<DateTime> startDate;
  final List<DateTime> endDate;
  final List<double> policyWeight;
  final List<String> policyDocument;

  // outer index = policy revision | inner list = controls at that revision
  final List<List<ControlModel>> controls;

  final List<bool> isDeleted;

  // Tracking fields
  final List<DateTime> lastModifiedDate;
  final List<String> editors;

  PolicyModel({
    required this.id,
    required this.image,
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.policyWeight,
    required this.policyDocument,
    required this.controls,
    required this.isDeleted,
    required this.lastModifiedDate,
    required this.editors,
  }) {
    assert(
      _allSameLength(),
      'All PolicyModel Lists must have the same number of elements (same index count)',
    );
  }

  /// function name: [_allSameLength]
  ///
  /// purpose: validate that every history List in the model has the exact
  ///          same length, guaranteeing that the indexes stay synchronized
  ///          across all fields and tracking lists.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if all Lists share the same length
  bool _allSameLength() {
    final lengths = <int>{
      image.length,
      policyNameEn.length,
      policyNameAr.length,
      policyNumberEn.length,
      policyNumberAr.length,
      policyDescriptionEn.length,
      policyDescriptionAr.length,
      startDate.length,
      endDate.length,
      policyWeight.length,
      policyDocument.length,
      controls.length,
      isDeleted.length,
      lastModifiedDate.length,
      editors.length,
    };
    return lengths.length == 1;
  }

  /// function name: [PolicyModel.create]
  ///
  /// purpose: build a brand new [PolicyModel] where every history List
  ///          is initialized with a single element representing the first
  ///          (creation) revision of this Policy.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the new policy
  ///            [String] image: initial image url/path
  ///            [String] policyNameEn: initial English policy name
  ///            [String] policyNameAr: initial Arabic policy name
  ///            [String] policyNumberEn: initial English policy number
  ///            [String] policyNumberAr: initial Arabic policy number
  ///            [String] policyDescriptionEn: initial English description
  ///            [String] policyDescriptionAr: initial Arabic description
  ///            [DateTime] startDate: initial start date
  ///            [DateTime] endDate: initial end date
  ///            [double] policyWeight: initial weight value
  ///            [String] policyDocument: initial document url/path
  ///            [List<ControlModel>] controls: initial list of controls (first revision snapshot)
  ///            [String] editorId: id of the user creating this policy
  ///
  /// return type: [PolicyModel] - the newly created model instance
  factory PolicyModel.create({
    required String id,
    required String image,
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String policyDocument,
    required List<ControlModel> controls,
    required String editorId,
  }) {
    final now = DateTime.now();
    return PolicyModel(
      id: id,
      image: [image],
      policyNameEn: [policyNameEn],
      policyNameAr: [policyNameAr],
      policyNumberEn: [policyNumberEn],
      policyNumberAr: [policyNumberAr],
      policyDescriptionEn: [policyDescriptionEn],
      policyDescriptionAr: [policyDescriptionAr],
      startDate: [startDate],
      endDate: [endDate],
      policyWeight: [policyWeight],
      policyDocument: [policyDocument],
      controls: [controls], // first revision: one controls snapshot
      isDeleted: [false],
      lastModifiedDate: [now],
      editors: [editorId],
    );
  }

  /// function name: [copyWithUpdate]
  ///
  /// purpose: append a new revision (new index) to every history List in
  ///          the policy. Any field not explicitly passed reuses its last
  ///          known value, ensuring all Lists remain the same length.
  ///          When [controls] is provided, the new controls snapshot
  ///          replaces the old one for this revision; otherwise the last
  ///          controls snapshot is carried forward unchanged.
  ///
  /// parameters:
  ///            [String] image: new image url/path, if changed
  ///            [String] policyNameEn: new English policy name, if changed
  ///            [String] policyNameAr: new Arabic policy name, if changed
  ///            [String] policyNumberEn: new English policy number, if changed
  ///            [String] policyNumberAr: new Arabic policy number, if changed
  ///            [String] policyDescriptionEn: new English description, if changed
  ///            [String] policyDescriptionAr: new Arabic description, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [double] policyWeight: new weight value, if changed
  ///            [String] policyDocument: new document url/path, if changed
  ///            [List<ControlModel>] controls: new controls snapshot, if changed
  ///            [bool] isDeleted: new soft-delete flag (true = delete, false = restore)
  ///            [String] editorId: id of the user performing the update (required)
  ///
  /// return type: [PolicyModel] - a new model instance with the appended revision
  PolicyModel copyWithUpdate({
    String? image,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    String? policyDocument,
    List<ControlModel>? controls,
    bool? isDeleted,
    required String editorId,
  }) {
    final now = DateTime.now();
    return PolicyModel(
      id: id,
      image: [...this.image, image ?? this.image.last],
      policyNameEn: [...this.policyNameEn, policyNameEn ?? this.policyNameEn.last],
      policyNameAr: [...this.policyNameAr, policyNameAr ?? this.policyNameAr.last],
      policyNumberEn: [
        ...this.policyNumberEn,
        policyNumberEn ?? this.policyNumberEn.last,
      ],
      policyNumberAr: [
        ...this.policyNumberAr,
        policyNumberAr ?? this.policyNumberAr.last,
      ],
      policyDescriptionEn: [
        ...this.policyDescriptionEn,
        policyDescriptionEn ?? this.policyDescriptionEn.last,
      ],
      policyDescriptionAr: [
        ...this.policyDescriptionAr,
        policyDescriptionAr ?? this.policyDescriptionAr.last,
      ],
      startDate: [...this.startDate, startDate ?? this.startDate.last],
      endDate: [...this.endDate, endDate ?? this.endDate.last],
      policyWeight: [...this.policyWeight, policyWeight ?? this.policyWeight.last],
      policyDocument: [
        ...this.policyDocument,
        policyDocument ?? this.policyDocument.last,
      ],
      // append the new controls snapshot (or carry the last one forward)
      controls: [...this.controls, controls ?? this.controls.last],
      isDeleted: [...this.isDeleted, isDeleted ?? this.isDeleted.last],
      lastModifiedDate: [...lastModifiedDate, now],
      editors: [...editors, editorId],
    );
  }

  /// function name: [toJson]
  ///
  /// purpose: serialize the policy model into a Map ready to be persisted
  ///          in Firestore. Keys follow the convention: each word
  ///          capitalized, separated by underscores. ID is stored as "ID".
  ///          Controls are serialized as a nested list of lists of Maps.
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, dynamic>] - the Firestore-ready representation of this policy
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Image': image,
      'Policy_Name_En': policyNameEn,
      'Policy_Name_Ar': policyNameAr,
      'Policy_Number_En': policyNumberEn,
      'Policy_Number_Ar': policyNumberAr,
      'Policy_Description_En': policyDescriptionEn,
      'Policy_Description_Ar': policyDescriptionAr,
      'Start_Date': startDate.map((d) => d.toIso8601String()).toList(),
      'End_Date': endDate.map((d) => d.toIso8601String()).toList(),
      'Policy_Weight': policyWeight,
      'Policy_Document': policyDocument,
      // List< List<Map> > — outer = policy revision, inner = controls at that revision
      'Controls': controls
          .map((revisionControls) =>
              revisionControls.map((c) => c.toJson()).toList())
          .toList(),
      'Is_Deleted': isDeleted,
      'Last_Modified_Date':
          lastModifiedDate.map((d) => d.toIso8601String()).toList(),
      'Editors': editors,
    };
  }

  /// function name: [PolicyModel.fromJson]
  ///
  /// purpose: rebuild a [PolicyModel] instance from the raw Map retrieved
  ///          from Firestore.
  ///
  /// parameters:
  ///            [Map<String, dynamic>] json: the raw document data from Firestore
  ///
  /// return type: [PolicyModel] - the reconstructed model instance
  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    final editorsRaw = List<String>.from(json['Editors'] ?? []);
    return PolicyModel(
      id: json['ID'] as String,
      image: List<String>.from(json['Image'] ?? []),
      policyNameEn: List<String>.from(json['Policy_Name_En'] ?? []),
      policyNameAr: List<String>.from(json['Policy_Name_Ar'] ?? []),
      policyNumberEn: List<String>.from(json['Policy_Number_En'] ?? []),
      policyNumberAr: List<String>.from(json['Policy_Number_Ar'] ?? []),
      policyDescriptionEn:
          List<String>.from(json['Policy_Description_En'] ?? []),
      policyDescriptionAr:
          List<String>.from(json['Policy_Description_Ar'] ?? []),
      startDate: (json['Start_Date'] as List? ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList(),
      endDate: (json['End_Date'] as List? ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList(),
      policyWeight: List<double>.from(json['Policy_Weight'] ?? []),
      policyDocument: List<String>.from(json['Policy_Document'] ?? []),
      controls: (json['Controls'] as List? ?? [])
          .map((revisionRaw) => (revisionRaw as List)
              .map((c) =>
                  ControlModel.fromJson(c as Map<String, dynamic>))
              .toList())
          .toList(),
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
  ///          [PolicyEntity] that holds only the latest (current) value of
  ///          every field. Controls are derived by calling [toEntity] on
  ///          each [ControlModel] in the last controls snapshot.
  ///
  /// parameters: none
  ///
  /// return type: [PolicyEntity] - the flattened entity built from the last index of every List
  PolicyEntity toEntity() {
    final latestControls = controls.last
        .where((c) => !c.isDeleted.last) // exclude soft-deleted controls
        .map((c) => c.toEntity())
        .toList();

    return PolicyEntity(
      id: id,
      image: image.last,
      policyNameEn: policyNameEn.last,
      policyNameAr: policyNameAr.last,
      policyNumberEn: policyNumberEn.last,
      policyNumberAr: policyNumberAr.last,
      policyDescriptionEn: policyDescriptionEn.last,
      policyDescriptionAr: policyDescriptionAr.last,
      startDate: startDate.last,
      endDate: endDate.last,
      policyWeight: policyWeight.last,
      policyDocument: policyDocument.last,
      controls: latestControls,
      isDeleted: isDeleted.last,
      lastModifiedDate: lastModifiedDate.last,
      lastEditorId: editors.last,
    );
  }
}