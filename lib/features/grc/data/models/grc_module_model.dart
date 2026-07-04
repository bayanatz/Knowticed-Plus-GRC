/// Module: GRC Module Management
/// Description: Defines the Model used to persist GRC Module records, where
///              every field is stored as a history List so that previous
///              values are never lost and each edit is fully traceable.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: GRCModuleEntity
/// Revision History: 2026-06-30 - Initial creation
///                    2026-06-30 - Added isDeleted history list for soft-delete/restore support (Mohamed Magdy Abdelkhalek)

import 'dart:convert';

import 'package:demo_app/features/grc/domain/entities/grc_module_entity.dart';


/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_model.dart
/// Purpose: Contains the GRCModuleModel class used for create/update/read
///          operations and Firebase (de)serialization.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GRCModuleModel]
///
/// purpose: represents a GRC Module record where every field is kept as a
///          List<...>. Each index across all the Lists (including
///          [editors] and [lastModifiedDate]) represents one historical
///          version of the record made at the same point in time. Updating
///          any single field requires appending a new element to every List
///          (re-using the previous value for fields that did not change) so
///          that all Lists always stay the same length.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GRCModuleModel {
  final String id;

  final List<String> image;
  final List<String> grcModuleNameEnglish;
  final List<String> grcModuleNameArabic;
  final List<String> descriptionEnglish;
  final List<String> descriptionArabic;
  final List<String> owningDepartment;
  final List<DateTime> activationDate;
  final List<List<String>> owners; // each element is the owners list at that revision
  final List<String> status;

  // --- Tracking fields ---
  final List<DateTime> lastModifiedDate; // last modification date per index
  final List<String> editors; // id of the editor responsible for each index

  // --- Soft-delete flag ---
  // Kept as a history List, just like every other field, so deleting and
  // restoring a record is simply appending a new revision (true/false)
  // instead of physically removing the document from the database.
  final List<bool> isDeleted;

  GRCModuleModel({
    required this.id,
    required this.image,
    required this.grcModuleNameEnglish,
    required this.grcModuleNameArabic,
    required this.descriptionEnglish,
    required this.descriptionArabic,
    required this.owningDepartment,
    required this.activationDate,
    required this.owners,
    required this.status,
    required this.lastModifiedDate,
    required this.editors,
    required this.isDeleted,
  }) {
    assert(
      _allSameLength(),
      'All Lists must have the same number of elements (same index count)',
    );
  }

  /// function name: [_allSameLength]
  ///
  /// purpose: validate that every history List in the model has the exact
  ///          same length, guaranteeing that the indexes stay synchronized
  ///          across all fields.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if all Lists share the same length, false otherwise
  bool _allSameLength() {
    final lengths = <int>{
      image.length,
      grcModuleNameEnglish.length,
      grcModuleNameArabic.length,
      descriptionEnglish.length,
      descriptionArabic.length,
      owningDepartment.length,
      activationDate.length,
      owners.length,
      status.length,
      lastModifiedDate.length,
      editors.length,
      isDeleted.length,
    };
    return lengths.length == 1;
  }

  /// function name: [GRCModuleModel.create]
  ///
  /// purpose: build a brand new [GRCModuleModel] record. Every history List
  ///          is initialized with a single element representing the first
  ///          (creation) revision.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the new record
  ///            [String] image: initial image url/path
  ///            [String] grcModuleNameEnglish: initial English module name
  ///            [String] grcModuleNameArabic: initial Arabic module name
  ///            [String] descriptionEnglish: initial English description
  ///            [String] descriptionArabic: initial Arabic description
  ///            [String] owningDepartment: initial owning department
  ///            [DateTime] activationDate: initial activation date
  ///            [List<String>] owners: initial owners list
  ///            [String] status: initial status
  ///            [String] editorId: id of the user creating the record
  ///
  /// return type: [GRCModuleModel] - the newly created model instance
  factory GRCModuleModel.create({
    required String id,
    required String image,
    required String grcModuleNameEnglish,
    required String grcModuleNameArabic,
    required String descriptionEnglish,
    required String descriptionArabic,
    required String owningDepartment,
    required DateTime activationDate,
    required List<String> owners,
    required String status,
    required String editorId,
  }) {
    final now = DateTime.now();
    return GRCModuleModel(
      id: id,
      image: [image],
      grcModuleNameEnglish: [grcModuleNameEnglish],
      grcModuleNameArabic: [grcModuleNameArabic],
      descriptionEnglish: [descriptionEnglish],
      descriptionArabic: [descriptionArabic],
      owningDepartment: [owningDepartment],
      activationDate: [activationDate],
      owners: [owners],
      status: [status],
      lastModifiedDate: [now],
      editors: [editorId],
      isDeleted: [false],
    );
  }

  /// function name: [copyWithUpdate]
  ///
  /// purpose: append a new revision (new index) to every history List in the
  ///          model. Any field not explicitly passed reuses its last known
  ///          value, ensuring all Lists remain the same length after the
  ///          update.
  ///
  /// parameters:
  ///            [String] image: new image url/path, if changed
  ///            [String] grcModuleNameEnglish: new English module name, if changed
  ///            [String] grcModuleNameArabic: new Arabic module name, if changed
  ///            [String] descriptionEnglish: new English description, if changed
  ///            [String] descriptionArabic: new Arabic description, if changed
  ///            [String] owningDepartment: new owning department, if changed
  ///            [DateTime] activationDate: new activation date, if changed
  ///            [List<String>] owners: new owners list, if changed
  ///            [String] status: new status, if changed
  ///            [bool] isDeleted: new soft-delete flag, if changed (true = delete, false = restore)
  ///            [String] editorId: id of the user performing the update (required)
  ///
  /// return type: [GRCModuleModel] - a new model instance with the appended revision
  GRCModuleModel copyWithUpdate({
    String? image,
    String? grcModuleNameEnglish,
    String? grcModuleNameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    String? owningDepartment,
    DateTime? activationDate,
    List<String>? owners,
    String? status,
    bool? isDeleted,
    required String editorId,
  }) {
    final now = DateTime.now();
    return GRCModuleModel(
      id: id,
      image: [...this.image, image ?? this.image.last],
      grcModuleNameEnglish: [
        ...this.grcModuleNameEnglish,
        grcModuleNameEnglish ?? this.grcModuleNameEnglish.last,
      ],
      grcModuleNameArabic: [
        ...this.grcModuleNameArabic,
        grcModuleNameArabic ?? this.grcModuleNameArabic.last,
      ],
      descriptionEnglish: [
        ...this.descriptionEnglish,
        descriptionEnglish ?? this.descriptionEnglish.last,
      ],
      descriptionArabic: [
        ...this.descriptionArabic,
        descriptionArabic ?? this.descriptionArabic.last,
      ],
      owningDepartment: [
        ...this.owningDepartment,
        owningDepartment ?? this.owningDepartment.last,
      ],
      activationDate: [
        ...this.activationDate,
        activationDate ?? this.activationDate.last,
      ],
      owners: [...this.owners, owners ?? this.owners.last],
      status: [...this.status, status ?? this.status.last],
      lastModifiedDate: [...lastModifiedDate, now],
      editors: [...editors, editorId],
      isDeleted: [...this.isDeleted, isDeleted ?? this.isDeleted.last],
    );
  }

  /// function name: [toJson]
  ///
  /// purpose: serialize the model into a Map ready to be persisted in
  ///          Firebase. Keys follow the convention: first letter of each
  ///          word capitalized, words separated by underscores (e.g.
  ///          "GRC_Module_Name_English"). The primary key is stored as "ID".
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, dynamic>] - the Firebase-ready representation of the model
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Image': image,
      'GRC_Module_Name_English': grcModuleNameEnglish,
      'GRC_Module_Name_Arabic': grcModuleNameArabic,
      'Description_English': descriptionEnglish,
      'Description_Arabic': descriptionArabic,
      'Owning_Department': owningDepartment,
      'Activation_Date':
          activationDate.map((d) => d.toIso8601String()).toList(),
      // Each revision's owners list is JSON-encoded as a String because
      // Firestore does not support nested arrays.
      'Owners': owners.map((list) => jsonEncode(list)).toList(),
      'Status': status,
      'Last_Modified_Date':
          lastModifiedDate.map((d) => d.toIso8601String()).toList(),
      'Editors': editors,
      'Is_Deleted': isDeleted,
    };
  }

  /// function name: [GRCModuleModel.fromJson]
  ///
  /// purpose: rebuild a [GRCModuleModel] instance from the raw Map retrieved
  ///          from Firebase.
  ///
  /// parameters:
  ///            [Map<String, dynamic>] json: the raw document data coming from Firebase
  ///
  /// return type: [GRCModuleModel] - the reconstructed model instance
  factory GRCModuleModel.fromJson(Map<String, dynamic> json) {
    return GRCModuleModel(
      id: json['ID'] as String,
      image: List<String>.from(json['Image'] ?? []),
      grcModuleNameEnglish:
          List<String>.from(json['GRC_Module_Name_English'] ?? []),
      grcModuleNameArabic:
          List<String>.from(json['GRC_Module_Name_Arabic'] ?? []),
      descriptionEnglish:
          List<String>.from(json['Description_English'] ?? []),
      descriptionArabic: List<String>.from(json['Description_Arabic'] ?? []),
      owningDepartment: List<String>.from(json['Owning_Department'] ?? []),
      activationDate: (json['Activation_Date'] as List? ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList(),
      owners: (json['Owners'] as List? ?? [])
          .map((o) => List<String>.from(jsonDecode(o as String) as List))
          .toList(),
      status: List<String>.from(json['Status'] ?? []),
      lastModifiedDate: (json['Last_Modified_Date'] as List? ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList(),
      editors: List<String>.from(json['Editors'] ?? []),
      // Falls back to a list of `false` matching the editors length, so
      // documents created before this field existed still load correctly.
      isDeleted: json['Is_Deleted'] != null
          ? List<bool>.from(json['Is_Deleted'])
          : List<bool>.filled(
              List<String>.from(json['Editors'] ?? []).length,
              false,
            ),
    );
  }

  /// function name: [toEntity]
  ///
  /// purpose: convert the model (full history) into a [GRCModuleEntity]
  ///          holding only the latest (current) value of every field, which
  ///          is what the rest of the app actually consumes.
  ///
  /// parameters: none
  ///
  /// return type: [GRCModuleEntity] - the flattened entity built from the last index of every List
  GRCModuleEntity toEntity() {
    return GRCModuleEntity(
      id: id,
      image: image.last,
      grcModuleNameEnglish: grcModuleNameEnglish.last,
      grcModuleNameArabic: grcModuleNameArabic.last,
      descriptionEnglish: descriptionEnglish.last,
      descriptionArabic: descriptionArabic.last,
      owningDepartment: owningDepartment.last,
      activationDate: activationDate.last,
      owners: owners.last,
      status: status.last,
      createdAt: lastModifiedDate.first,
      lastModifiedDate: lastModifiedDate.last,
      lastEditorId: editors.last,
      isDeleted: isDeleted.last,
    );
  }
}