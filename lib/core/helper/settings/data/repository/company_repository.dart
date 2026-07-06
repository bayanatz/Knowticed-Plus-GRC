/// Module: Settings · Data · Company Repository
/// Description: Concrete implementation of [CompanyRepositoryInterface]. Wraps
///              the company remote data source and is the only place the
///              settings feature reads/writes the company document.
/// Author: Mohamed Elrashidy
/// Date: 25/06/2026
/// Dependencies: CompanyRemoteDataSource, CompanyRepositoryInterface
/// Revision History:
///   - 25/06/2026 (Amr Mesbah): Implemented (was an empty stub); constructor
///       injection, try/catch, implements domain interface.
///
/// ************************ FILE INFO ********************************///
/// File Name: company_repository.dart
/// Purpose: Data-layer repository for company persistence.
/// Author: Mohamed Elrashidy
/// Created At: 25/06/2026
/// Dependencies: CompanyRemoteDataSource, CompanyRepositoryInterface
library;

import 'dart:io';

import 'package:demo_app/core/helper/settings/domain/base_repository/company_repository_interface.dart';
import 'package:demo_app/core/helper/settings/data/data_source/remote_data_source/company_remote_data_source.dart';

class CompanyRepository implements CompanyRepositoryInterface {
  final CompanyRemoteDataSource _remoteDataSource;

  CompanyRepository(this._remoteDataSource);

  @override
  Future<void> setCompany({
    required String companyId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _remoteDataSource.setCompany(companyId: companyId, data: data);
    } catch (e) {
      throw Exception('Failed to save company: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCompany({required String companyId}) async {
    try {
      return await _remoteDataSource.getCompany(companyId: companyId);
    } catch (e) {
      throw Exception('Failed to load company: $e');
    }
  }

  @override
  Future<String> uploadLogo({
    required File file,
    required String contentType,
    required String extension,
  }) async {
    try {
      return await _remoteDataSource.uploadCompanyLogo(
        file: file,
        contentType: contentType,
        extension: extension,
      );
    } catch (e) {
      throw Exception('Failed to upload company logo: $e');
    }
  }
}
