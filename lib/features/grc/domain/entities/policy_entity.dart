/// Module: Policy Management
/// Description: Defines the Policy Entity used by the app's UI/business
///              logic layer. Holds the latest (current) values of a Policy
///              record as plain single fields, with its controls mapped to
///              a list of [ControlEntity].
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: ControlEntity
/// Revision History: 2026-07-5 - Initial creation

import 'control_entity.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_entity.dart
/// Purpose: Contains the PolicyEntity class, a flat (non-list)
///          representation of a Policy record derived from the latest index
///          of the PolicyModel. This is what the Presentation and Domain
///          layers consume directly.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyEntity]
///
/// purpose: holds the current (latest) values of a Policy record as plain
///          single fields. The [controls] field is a [List<ControlEntity>]
///          representing the controls snapshot at the latest policy revision.
///          Tracking fields expose only the last modification info.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class PolicyEntity {
  final String id;
  final String image;
  final String policyNameEn;
  final String policyNameAr;
  final String policyNumberEn;
  final String policyNumberAr;
  final String policyDescriptionEn;
  final String policyDescriptionAr;
  final DateTime startDate;
  final DateTime endDate;
  final double policyWeight;
  final String policyDocument;
  final List<ControlEntity> controls;
  final bool isDeleted;

  // Tracking fields (latest values only)
  final DateTime lastModifiedDate;
  final String lastEditorId;

  const PolicyEntity({
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
    required this.lastEditorId,
  });

  /// function name: [copyWith]
  ///
  /// purpose: create a new [PolicyEntity] instance with selected fields
  ///          replaced by new values, keeping all other fields unchanged.
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
  ///            [List<ControlEntity>] controls: new controls snapshot, if changed
  ///            [bool] isDeleted: new soft-delete flag, if changed
  ///
  /// return type: [PolicyEntity] - the updated entity instance
  PolicyEntity copyWith({
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
    List<ControlEntity>? controls,
    bool? isDeleted,
  }) {
    return PolicyEntity(
      id: id,
      image: image ?? this.image,
      policyNameEn: policyNameEn ?? this.policyNameEn,
      policyNameAr: policyNameAr ?? this.policyNameAr,
      policyNumberEn: policyNumberEn ?? this.policyNumberEn,
      policyNumberAr: policyNumberAr ?? this.policyNumberAr,
      policyDescriptionEn: policyDescriptionEn ?? this.policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr ?? this.policyDescriptionAr,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      policyWeight: policyWeight ?? this.policyWeight,
      policyDocument: policyDocument ?? this.policyDocument,
      controls: controls ?? this.controls,
      isDeleted: isDeleted ?? this.isDeleted,
      lastModifiedDate: lastModifiedDate,
      lastEditorId: lastEditorId,
    );
  }
}