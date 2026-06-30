/// Module: GRC Module Management
/// Description: Defines the Entity used by the app's UI/business logic layer.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: None
/// Revision History: 2026-06-30 - Initial creation
///                    2026-06-30 - Added isDeleted flag for soft-delete/restore support (Mohamed Magdy Abdelkhalek)

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_entity.dart
/// Purpose: Contains the GRCModuleEntity class, a flat (non-list) representation
///          of a GRC Module record, derived from the latest index of the Model.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GRCModuleEntity]
///
/// purpose: holds the current (latest) values of a GRC Module record as plain
///          single fields, ready to be consumed directly by the UI and the
///          business logic, instead of working with the history Lists kept
///          in [GRCModuleModel].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GRCModuleEntity {
  final String id;
  final String image;
  final String grcModuleNameEnglish;
  final String grcModuleNameArabic;
  final String descriptionEnglish;
  final String descriptionArabic;
  final String owningDepartment;
  final DateTime activationDate;
  final List<String> owners;
  final String status;

  // Tracking fields (latest values only)
  final DateTime lastModifiedDate;
  final String lastEditorId;

  // Soft-delete flag (latest value only)
  final bool isDeleted;

  const GRCModuleEntity({
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
    required this.lastEditorId,
    required this.isDeleted,
  });

  /// function name: [copyWith]
  ///
  /// purpose: create a new [GRCModuleEntity] instance with selected fields
  ///          replaced by new values, keeping all other fields unchanged.
  ///
  /// parameters:
  ///            [String] image: new image url/path, if provided
  ///            [String] grcModuleNameEnglish: new English module name, if provided
  ///            [String] grcModuleNameArabic: new Arabic module name, if provided
  ///            [String] descriptionEnglish: new English description, if provided
  ///            [String] descriptionArabic: new Arabic description, if provided
  ///            [String] owningDepartment: new owning department, if provided
  ///            [DateTime] activationDate: new activation date, if provided
  ///            [List<String>] owners: new owners list, if provided
  ///            [String] status: new status, if provided
  ///
  /// return type: [GRCModuleEntity] - the updated entity instance
  GRCModuleEntity copyWith({
    String? image,
    String? grcModuleNameEnglish,
    String? grcModuleNameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    String? owningDepartment,
    DateTime? activationDate,
    List<String>? owners,
    String? status,
  }) {
    return GRCModuleEntity(
      id: id,
      image: image ?? this.image,
      grcModuleNameEnglish: grcModuleNameEnglish ?? this.grcModuleNameEnglish,
      grcModuleNameArabic: grcModuleNameArabic ?? this.grcModuleNameArabic,
      descriptionEnglish: descriptionEnglish ?? this.descriptionEnglish,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      owningDepartment: owningDepartment ?? this.owningDepartment,
      activationDate: activationDate ?? this.activationDate,
      owners: owners ?? this.owners,
      status: status ?? this.status,
      lastModifiedDate: lastModifiedDate,
      lastEditorId: lastEditorId,
      isDeleted: isDeleted,
    );
  }
}