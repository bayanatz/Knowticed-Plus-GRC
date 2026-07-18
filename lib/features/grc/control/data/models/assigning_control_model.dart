/// Module: Policy Management
/// Description: Firestore (de)serialization for a single {Policy, Control}
///              pairing, shared by the Control Champion and Control Owner
///              features.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: AssigningControlEntity

import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';

/// class name: [AssigningControlModel]
///
/// purpose: Firestore-ready representation of [AssigningControlEntity].
///          Keys: Policy_ID, Control_ID.
class AssigningControlModel {
  final String policyId;
  final String controlId;

  const AssigningControlModel({
    required this.policyId,
    required this.controlId,
  });

  Map<String, dynamic> toJson() {
    return {
      'Policy_ID': policyId,
      'Control_ID': controlId,
    };
  }

  factory AssigningControlModel.fromJson(Map<String, dynamic> json) {
    return AssigningControlModel(
      policyId: json['Policy_ID'] as String,
      controlId: json['Control_ID'] as String,
    );
  }

  AssigningControlEntity toEntity() {
    return AssigningControlEntity(policyId: policyId, controlId: controlId);
  }
}
