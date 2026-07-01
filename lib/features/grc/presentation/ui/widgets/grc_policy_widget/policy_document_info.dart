/// Module: GRC Policy Management
/// Description: Data model for uploaded policy document metadata.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: None
/// Revision History: 2026-07-01 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_document_info.dart
/// Purpose: Contains PolicyDocumentInfo, a simple immutable model for
///          storing a document's name, size, and date labels.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

/// class name: [PolicyDocumentInfo]
///
/// purpose: immutable value object that carries display metadata for an
///          uploaded document (name, formatted size, formatted date).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyDocumentInfo {
  final String name;
  final String sizeLabel;
  final String dateLabel;

  const PolicyDocumentInfo({
    required this.name,
    required this.sizeLabel,
    required this.dateLabel,
  });
}
