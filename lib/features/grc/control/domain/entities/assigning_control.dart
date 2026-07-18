/// Module: Policy Management
/// Description: A single {Policy, Control} pairing used by both the Control
///              Champion and Control Owner features to record which
///              Policy/Control combination a person is responsible for.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: None

/// class name: [AssigningControlEntity]
///
/// purpose: pairs a Policy id with a Control id — one row of the
///          "Assigning Control" section on the Add Champion/Add Owner pages.
class AssigningControlEntity {
  final String policyId;
  final String controlId;

  const AssigningControlEntity({
    required this.policyId,
    required this.controlId,
  });
}
