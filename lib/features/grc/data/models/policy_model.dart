/// Module: Policy Management
/// Description: Defines the Policy Model used for data persistence with
///              full revision history per field, including status lifecycle.
///              Policies are stored in Firestore at:
///              GRC_Modules/{Module_ID}/Policies/{Policy_ID}
///              Controls now live in their own subcollection underneath this
///              document and are no longer embedded here.
/// Author: Mohamed Elrashidy
/// Date: 2025-01-15
/// Dependencies: PolicyEntity, PolicyStatus
/// Revision History: 2025-01-15 - Initial creation
///                   2026-07-06 - Added status history list (Mohamed Elrashidy)
///                   2026-07-14 - Migrated to the new schema: removed the
///                                nested controls List<List<ControlModel>>
///                                (Controls are now a Firestore
///                                subcollection), renamed Image to
///                                Policy_Image, split Policy_Document into
///                                En/Ar, dates now stored as ISO strings,
///                                and tracking fields renamed to
///                                Modification_Date/Modifiers. Removed
///                                Is_Deleted in favor of
///                                PolicyStatus.removed (Mohamed Elrashidy)
library;

import 'package:intl/intl.dart';
import '../../domain/entities/policy_entity.dart';
import '../../domain/entities/policy_status.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_model.dart
/// Purpose: Contains the PolicyModel class used for Firestore
///          (de)serialization with full revision history per field.
/// Author: Mohamed Elrashidy
/// Created At: 15/1/2025

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

/// class name: [PolicyModel]
///
/// purpose: represents a Policy record where every field is kept as a
///          List<...>. Each index across all Lists represents one historical
///          version at the same point in time. The [status] List tracks the
///          policy lifecycle (Draft → Active → Inactive / Scheduled /
///          Expired / Removed). Controls are intentionally NOT included
///          here - they live in their own Controls subcollection under this
///          Policy document and should be fetched/managed via ControlModel.
///
/// authors: Mohamed Elrashidy
///
/// created at: 15/1/2025
class PolicyModel {
  final String id;
  final String moduleId;
  final List<String?> policyImage;
  final List<String> policyNameEn;
  final List<String> policyNameAr;
  final List<String> policyNumberEn;
  final List<String> policyNumberAr;
  final List<String> policyDescriptionEn;
  final List<String> policyDescriptionAr;
  final List<DateTime> startDate;
  final List<DateTime> endDate;
  final List<double> policyWeight;
  final List<String?> policyDocumentEn;
  final List<String?> policyDocumentAr;
  final List<String> status; // PolicyStatus.value strings

  // Tracking
  final List<DateTime> lastModifiedDate;
  final List<String> editors;

  PolicyModel({
    required this.id,
    required this.moduleId,
    required this.policyImage,
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.policyWeight,
    required this.policyDocumentEn,
    required this.policyDocumentAr,
    required this.status,
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
      policyImage.length,
      policyNameEn.length,
      policyNameAr.length,
      policyNumberEn.length,
      policyNumberAr.length,
      policyDescriptionEn.length,
      policyDescriptionAr.length,
      startDate.length,
      endDate.length,
      policyWeight.length,
      policyDocumentEn.length,
      policyDocumentAr.length,
      status.length,
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
  ///            [String] id: unique identifier (Policy_ID)
  ///            [String] moduleId: parent module id (denormalized)
  ///            [String?] policyImage: initial image url/path
  ///            [String] policyNameEn: initial English name
  ///            [String] policyNameAr: initial Arabic name
  ///            [String] policyNumberEn: initial English number
  ///            [String] policyNumberAr: initial Arabic number
  ///            [String] policyDescriptionEn: initial English description
  ///            [String] policyDescriptionAr: initial Arabic description
  ///            [DateTime] startDate: initial start date
  ///            [DateTime] endDate: initial end date
  ///            [double] policyWeight: initial weight
  ///            [String?] policyDocumentEn: initial English document url/path
  ///            [String?] policyDocumentAr: initial Arabic document url/path
  ///            [PolicyStatus] status: initial lifecycle status
  ///            [String] editorId: id/email of the creating user
  ///
  /// return type: [PolicyModel] - the newly created model instance
  factory PolicyModel.create({
    required String id,
    required String moduleId,
    String? policyImage,
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    String? policyDocumentEn,
    String? policyDocumentAr,
    required PolicyStatus status,
    required String editorId,
  }) {
    final now = DateTime.now();
    return PolicyModel(
      id: id,
      moduleId: moduleId,
      policyImage: [policyImage],
      policyNameEn: [policyNameEn],
      policyNameAr: [policyNameAr],
      policyNumberEn: [policyNumberEn],
      policyNumberAr: [policyNumberAr],
      policyDescriptionEn: [policyDescriptionEn],
      policyDescriptionAr: [policyDescriptionAr],
      startDate: [startDate],
      endDate: [endDate],
      policyWeight: [policyWeight],
      policyDocumentEn: [policyDocumentEn],
      policyDocumentAr: [policyDocumentAr],
      status: [status.value],
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
  ///            [String?] policyImage: new image url/path, if changed
  ///            [String] policyNameEn: new English name, if changed
  ///            [String] policyNameAr: new Arabic name, if changed
  ///            [String] policyNumberEn: new English number, if changed
  ///            [String] policyNumberAr: new Arabic number, if changed
  ///            [String] policyDescriptionEn: new English description, if changed
  ///            [String] policyDescriptionAr: new Arabic description, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [double] policyWeight: new weight, if changed
  ///            [String?] policyDocumentEn: new English document url/path, if changed
  ///            [String?] policyDocumentAr: new Arabic document url/path, if changed
  ///            [PolicyStatus] status: new lifecycle status, if changed
  ///            [String] editorId: id/email of the user performing the update (required)
  ///
  /// return type: [PolicyModel] - a new model with the appended revision
  PolicyModel copyWithUpdate({
    String? policyImage,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    String? policyDocumentEn,
    String? policyDocumentAr,
    PolicyStatus? status,
    required String editorId,
  }) {
    final now = DateTime.now();
    return PolicyModel(
      id: id,
      moduleId: moduleId,
      policyImage: [...this.policyImage, policyImage ?? this.policyImage.last],
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
      startDate: [
        ...this.startDate,
        startDate ?? this.startDate.last
      ],
      endDate: [
        ...this.endDate,
        endDate ?? this.endDate.last
      ],
      policyWeight: [
        ...this.policyWeight,
        policyWeight ?? this.policyWeight.last
      ],
      policyDocumentEn: [
        ...this.policyDocumentEn,
        policyDocumentEn ?? this.policyDocumentEn.last
      ],
      policyDocumentAr: [
        ...this.policyDocumentAr,
        policyDocumentAr ?? this.policyDocumentAr.last
      ],
      status: [...this.status, status?.value ?? this.status.last],
      lastModifiedDate: [...lastModifiedDate, now],
      editors: [...editors, editorId],
    );
  }

  /// function name: [toJson]
  ///
  /// purpose: serialize to a Firestore-ready Map using Capital_Underscore
  ///          keys.
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, dynamic>] - the Firestore representation
  Map<String, dynamic> toJson() {
    return {
      'Module_ID': moduleId,
      'Policy_ID': id,
      'Policy_Image': policyImage,
      'Policy_Name_En': policyNameEn,
      'Policy_Name_Ar': policyNameAr,
      'Policy_Number_En': policyNumberEn,
      'Policy_Number_Ar': policyNumberAr,
      'Policy_Description_En': policyDescriptionEn,
      'Policy_Description_Ar': policyDescriptionAr,
      'Policy_Start_Date': startDate
          .map((d) => _storageDateFormat.format(d))
          .toList(),
      'Policy_End_Date': endDate
          .map((d) => _storageDateFormat.format(d))
          .toList(),
      'Policy_Weight': policyWeight,
      'Policy_Document_En': policyDocumentEn,
      'Policy_Document_Ar': policyDocumentAr,
      'Policy_Status': status,
      'Modification_Date': lastModifiedDate
          .map((d) => _storageDateFormat.format(d))
          .toList(),
      'Modifiers': editors,
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
    final editorsRaw = List<String>.from(json['Modifiers'] ?? []);
    return PolicyModel(
      id: json['Policy_ID'] as String,
      moduleId: json['Module_ID'] as String,
      policyImage: List<String?>.from(json['Policy_Image'] ?? []),
      policyNameEn: List<String>.from(json['Policy_Name_En'] ?? []),
      policyNameAr: List<String>.from(json['Policy_Name_Ar'] ?? []),
      policyNumberEn: List<String>.from(json['Policy_Number_En'] ?? []),
      policyNumberAr: List<String>.from(json['Policy_Number_Ar'] ?? []),
      policyDescriptionEn:
          List<String>.from(json['Policy_Description_En'] ?? []),
      policyDescriptionAr:
          List<String>.from(json['Policy_Description_Ar'] ?? []),
      startDate: (json['Policy_Start_Date'] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      endDate: (json['Policy_End_Date'] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      policyWeight: (json['Policy_Weight'] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      policyDocumentEn: List<String?>.from(json['Policy_Document_En'] ?? []),
      policyDocumentAr: List<String?>.from(json['Policy_Document_Ar'] ?? []),
      status: json['Policy_Status'] != null
          ? List<String>.from(json['Policy_Status'])
          : List<String>.filled(editorsRaw.length, PolicyStatus.draft.value),
      lastModifiedDate: (json['Modification_Date'] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      editors: editorsRaw,
    );
  }

  /// function name: [toEntity]
  ///
  /// purpose: convert the full history model to a [PolicyEntity] holding
  ///          only the latest value of every field. Controls are not part
  ///          of this conversion - fetch them separately from the Controls
  ///          subcollection via ControlModel.
  ///
  /// parameters: none
  ///
  /// return type: [PolicyEntity] - the entity built from the last index of every List
  PolicyEntity toEntity() {
    return PolicyEntity(
      id: id,
      moduleId: moduleId,
      policyImage: policyImage.last,
      policyNameEn: policyNameEn.last,
      policyNameAr: policyNameAr.last,
      policyNumberEn: policyNumberEn.last,
      policyNumberAr: policyNumberAr.last,
      policyDescriptionEn: policyDescriptionEn.last,
      policyDescriptionAr: policyDescriptionAr.last,
      startDate: startDate.last,
      endDate: endDate.last,
      policyWeight: policyWeight.last,
      policyDocumentEn: policyDocumentEn.last,
      policyDocumentAr: policyDocumentAr.last,
      status: PolicyStatus.fromString(status.last),
      lastModifiedDate: lastModifiedDate.last,
      lastEditor: editors.last,
    );
  }
}