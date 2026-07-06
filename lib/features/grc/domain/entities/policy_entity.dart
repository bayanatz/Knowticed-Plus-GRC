/// Module: Policy Management
/// Description: Defines the Policy Entity used by the app's UI/business
///              logic layer. Holds the latest (current) values of a Policy
///              record as plain single fields.
/// Author: Mohamed Elrashidy
/// Date: 2025-01-15
/// Dependencies: ControlEntity, PolicyStatus
/// Revision History: 2025-01-15 - Initial creation
///                   2026-07-06 - Added PolicyStatus field (Mohamed Elrashidy)

import 'control_entity.dart';
import 'policy_status.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_entity.dart
/// Purpose: Contains the PolicyEntity class, a flat (non-list)
///          representation of a Policy record derived from the latest index
///          of the PolicyModel. This is what the Presentation and Domain
///          layers consume directly.
/// Author: Mohamed Elrashidy
/// Created At: 15/1/2025

/// class name: [PolicyEntity]
///
/// purpose: holds the current (latest) values of a Policy record as plain
///          single fields. [controls] contains only the active (non-deleted)
///          controls from the latest revision snapshot.
///
/// authors: Mohamed Elrashidy
///
/// created at: 15/1/2025
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
  final PolicyStatus status;
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
    required this.status,
    required this.isDeleted,
    required this.lastModifiedDate,
    required this.lastEditorId,
  });

  /// function name: [copyWith]
  ///
  /// purpose: create a new [PolicyEntity] with selected fields replaced
  ///          by new values, keeping all other fields unchanged.
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
  ///            [PolicyStatus] status: new status, if changed
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
    PolicyStatus? status,
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
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      lastModifiedDate: lastModifiedDate,
      lastEditorId: lastEditorId,
    );
  }
}