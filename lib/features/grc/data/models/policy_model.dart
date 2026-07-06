/// Module: Policy Management
/// Description: Defines the Policy Model used for data persistence with
///              full revision history per field, including status lifecycle.
/// Author: Mohamed Elrashidy
/// Date: 2025-01-15
/// Dependencies: ControlModel, PolicyEntity, PolicyStatus
/// Revision History: 2025-01-15 - Initial creation
///                   2026-07-06 - Added status history list (Mohamed Elrashidy)
library;

import '../../domain/entities/policy_entity.dart';
import '../../domain/entities/policy_status.dart';
import 'control_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_model.dart
/// Purpose: Contains the PolicyModel class used for Firestore
///          (de)serialization with full revision history per field.
/// Author: Mohamed Elrashidy
/// Created At: 15/1/2025

/// class name: [PolicyModel]
///
/// purpose: represents a Policy record where every field is kept as a
///          List<...>. Each index across all Lists represents one historical
///          version at the same point in time. The [status] List tracks the
///          policy lifecycle (Draft → Active → Inactive / Expired).
///          [controls] is List<List<ControlModel>>:
///            outer index → policy revision | inner list → controls snapshot
///
/// authors: Mohamed Elrashidy
///
/// created at: 15/1/2025
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
  final List<List<ControlModel>> controls;
  final List<String> status; // PolicyStatus.value strings
  final List<bool> isDeleted;

  // Tracking
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
    required this.status,
    required this.isDeleted,
    required this.lastModifiedDate,
    required this.editors,
  }) {
    assert(_allSameLength(),
        'All PolicyModel Lists must have the same number of elements');
  }

  /// function name: [_allSameLength]
  ///
  /// purpose: validate that all history Lists share the same length.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if all lengths match
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
      status.length,
      isDeleted.length,
      lastModifiedDate.length,
      editors.length,
    };
    return lengths.length == 1;
  }

  /// function name: [PolicyModel.create]
  ///
  /// purpose: build the first revision of a PolicyModel where every List
  ///          starts with exactly one element.
  ///
  /// parameters:
  ///            [String] id: unique identifier
  ///            [String] image: initial image url/path
  ///            [String] policyNameEn: initial English name
  ///            [String] policyNameAr: initial Arabic name
  ///            [String] policyNumberEn: initial English number
  ///            [String] policyNumberAr: initial Arabic number
  ///            [String] policyDescriptionEn: initial English description
  ///            [String] policyDescriptionAr: initial Arabic description
  ///            [DateTime] startDate: initial start date
  ///            [DateTime] endDate: initial end date
  ///            [double] policyWeight: initial weight
  ///            [String] policyDocument: initial document url/path
  ///            [List<ControlModel>] controls: initial controls snapshot
  ///            [PolicyStatus] status: initial lifecycle status
  ///            [String] editorId: id of the creating user
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
    required PolicyStatus status,
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
      controls: [controls],
      status: [status.value],
      isDeleted: [false],
      lastModifiedDate: [now],
      editors: [editorId],
    );
  }

  /// function name: [copyWithUpdate]
  ///
  /// purpose: append a new revision to every List. Fields left null reuse
  ///          their last value so all Lists stay the same length.
  ///
  /// parameters:
  ///            [String] image: new image url/path, if changed
  ///            [String] policyNameEn: new English name, if changed
  ///            [String] policyNameAr: new Arabic name, if changed
  ///            [String] policyNumberEn: new English number, if changed
  ///            [String] policyNumberAr: new Arabic number, if changed
  ///            [String] policyDescriptionEn: new English description, if changed
  ///            [String] policyDescriptionAr: new Arabic description, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [double] policyWeight: new weight, if changed
  ///            [String] policyDocument: new document url/path, if changed
  ///            [List<ControlModel>] controls: new controls snapshot, if changed
  ///            [PolicyStatus] status: new lifecycle status, if changed
  ///            [bool] isDeleted: soft-delete flag (true=delete, false=restore)
  ///            [String] editorId: id of the user performing the update (required)
  ///
  /// return type: [PolicyModel] - a new model with the appended revision
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
    PolicyStatus? status,
    bool? isDeleted,
    required String editorId,
  }) {
    final now = DateTime.now();
    return PolicyModel(
      id: id,
      image: [...this.image, image ?? this.image.last],
      policyNameEn: [
        ...this.policyNameEn,
        policyNameEn ?? this.policyNameEn.last
      ],
      policyNameAr: [
        ...this.policyNameAr,
        policyNameAr ?? this.policyNameAr.last
      ],
      policyNumberEn: [
        ...this.policyNumberEn,
        policyNumberEn ?? this.policyNumberEn.last
      ],
      policyNumberAr: [
        ...this.policyNumberAr,
        policyNumberAr ?? this.policyNumberAr.last
      ],
      policyDescriptionEn: [
        ...this.policyDescriptionEn,
        policyDescriptionEn ?? this.policyDescriptionEn.last
      ],
      policyDescriptionAr: [
        ...this.policyDescriptionAr,
        policyDescriptionAr ?? this.policyDescriptionAr.last
      ],
      startDate: [...this.startDate, startDate ?? this.startDate.last],
      endDate: [...this.endDate, endDate ?? this.endDate.last],
      policyWeight: [
        ...this.policyWeight,
        policyWeight ?? this.policyWeight.last
      ],
      policyDocument: [
        ...this.policyDocument,
        policyDocument ?? this.policyDocument.last
      ],
      controls: [...this.controls, controls ?? this.controls.last],
      status: [...this.status, status?.value ?? this.status.last],
      isDeleted: [...this.isDeleted, isDeleted ?? this.isDeleted.last],
      lastModifiedDate: [...lastModifiedDate, now],
      editors: [...editors, editorId],
    );
  }

  /// function name: [toJson]
  ///
  /// purpose: serialize to a Firestore-ready Map using Capital_Underscore
  ///          keys. ID is stored as "ID".
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, dynamic>] - the Firestore representation
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
      // Firestore rejects arrays that directly contain other arrays, so each
      // revision's control list is wrapped in a map (List<List<...>> would
      // otherwise serialize as a nested array and the write would throw).
      'Controls': controls
          .map((rev) => {'Items': rev.map((c) => c.toJson()).toList()})
          .toList(),
      'Status': status,
      'Is_Deleted': isDeleted,
      'Last_Modified_Date':
          lastModifiedDate.map((d) => d.toIso8601String()).toList(),
      'Editors': editors,
    };
  }

  /// function name: [PolicyModel.fromJson]
  ///
  /// purpose: rebuild a [PolicyModel] from raw Firestore document data.
  ///
  /// parameters:
  ///            [Map<String, dynamic>] json: the raw Firestore document data
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
          .map((rev) => ((rev as Map<String, dynamic>)['Items'] as List? ?? [])
              .map((c) => ControlModel.fromJson(c as Map<String, dynamic>))
              .toList())
          .toList(),
      status: json['Status'] != null
          ? List<String>.from(json['Status'])
          : List<String>.filled(editorsRaw.length, PolicyStatus.draft.value),
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
  /// purpose: convert the full history model to a [PolicyEntity] holding
  ///          only the latest value of every field. Soft-deleted controls
  ///          are automatically filtered out.
  ///
  /// parameters: none
  ///
  /// return type: [PolicyEntity] - the entity built from the last index of every List
  PolicyEntity toEntity() {
    final latestControls = controls.last
        .where((c) => !c.isDeleted.last)
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
      status: PolicyStatus.fromString(status.last),
      isDeleted: isDeleted.last,
      lastModifiedDate: lastModifiedDate.last,
      lastEditorId: editors.last,
    );
  }
}
