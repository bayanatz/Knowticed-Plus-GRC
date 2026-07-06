/// Module: Settings · Domain · Company Repository Interface
/// Description: Abstract contract for company persistence. Decouples the company
///              controller from Firestore by exposing only domain operations.
/// Author: Amr Mesbah
/// Date: 25/06/2026
/// Dependencies: none
/// Revision History:
///   - 25/06/2026 (Amr Mesbah): Initial creation (introduces domain layer).
library;

import 'dart:io';

///*************************** FILE INFO ****************************///
/// File Name: company_repository_interface.dart
/// Purpose: Abstract contract for company document persistence.

/// Contract for reading and writing the company document.
abstract class CompanyRepositoryInterface {
  /// Create or merge the company document identified by [companyId].
  Future<void> setCompany({
    required String companyId,
    required Map<String, dynamic> data,
  });

  /// Fetch the raw company document map, or `null` when it does not exist.
  Future<Map<String, dynamic>?> getCompany({required String companyId});

  /// Uploads a company logo file and returns its public download URL.
  Future<String> uploadLogo({
    required File file,
    required String contentType,
    required String extension,
  });
}
