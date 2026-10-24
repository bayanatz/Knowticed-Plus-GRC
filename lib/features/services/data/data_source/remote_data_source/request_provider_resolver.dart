/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: request_provider_resolver.dart
/// Purpose: Finds the provider of one request and, when none was assigned
///          yet, assigns the least busy one. Moved out of the presentation
///          controller folder; screens reach it through
///          CreateServicesRepository.resolveRequestProvider.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/history_append.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/service_provider_selector.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Resolves the provider of one request.
class RequestProviderResolver {
  /// Rule "Reuse shared widgets — no copies": the provider is picked by the
  /// ONE algorithm in [ServiceProviderSelector] (this class had its own copy).
  RequestProviderResolver(this._firestore, {ServiceProviderSelector? selector})
      : _selector = selector ?? ServiceProviderSelector(firestore: _firestore);

  final FirebaseFirestore _firestore;
  final ServiceProviderSelector _selector;

  /// Function Name: [resolve]
  ///
  /// Purpose: The provider of [model]: the assigned provider when there is
  /// one, else the provider stored on the request; when neither exists, the
  /// least busy provider of the last 7 days is assigned and saved (with
  /// history) and returned.
  ///
  /// Parameters:
  /// - [model]: the request.
  ///
  /// Returns: the provider, or null when the request has none or cannot be
  /// read.
  Future<ServiceEmployeeModel?> resolve(ServicesHistoryModel model) async {
    final map = await _resolveMap(model);
    return map == null ? null : convertMapToEmployeeEntityModel(map);
  }

  Future<Map<String, dynamic>?> _resolveMap(ServicesHistoryModel model) async {
    try {
      final docId = model.currentId;
      if (docId.isEmpty) {
        return null;
      }

      // read the one request by id.
      final requestDoc = await _firestore
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .doc(docId)
          .get();
      if (!requestDoc.exists) {
        throw StateError('Request not found: $docId');
      }

      final data = requestDoc.data() ?? <String, dynamic>{};

      final assignedEmail = model.currentAssignedProviderEmail;

      if (assignedEmail.isNotEmpty) {
        final providerServices = model.currentProviderServices;

        if (providerServices.isNotEmpty) {
          try {
            final assignedProvider = providerServices.firstWhere(
              (p) =>
                  (p.email ?? '').toLowerCase() == assignedEmail.toLowerCase(),
            );

            return convertEmployeeToMap(assignedProvider);
          } on StateError {
            // The assigned e-mail is not in the provider list; fall through.
          }
        }
      }

      if (data.containsKey('Provider_Services') &&
          data['Provider_Services'] is Map) {
        final providerData = data['Provider_Services'] as Map<String, dynamic>;
        return providerData;
      }

      final providerServicesForSelection = model.currentProviderServices;

      if (providerServicesForSelection.isNotEmpty) {
        final selectedProvider = await _selectProvider(
          providers: providerServicesForSelection,
          parentServiceId: model.currentParentServiceId,
        );

        if (selectedProvider != null) {
          final assignedEmail =
              selectedProvider['email'].toString().toLowerCase();

          await updateWithHistory(_firestore, requestDoc.reference, {
            'Provider_Services': selectedProvider,
            'Assigned_Provider_Email': HistoryAppend(assignedEmail),
            'timestamps': HistoryAppend(DateTime.now().millisecondsSinceEpoch),
          });

          return selectedProvider;
        }
      }

      final providerServicesFromModel = model.currentProviderServices;

      if (providerServicesFromModel.isNotEmpty) {
        final firstProvider = providerServicesFromModel.first;

        final providerMap = convertEmployeeToMap(firstProvider);
        final assignedEmail = (firstProvider.email ?? '').toLowerCase();

        await updateWithHistory(_firestore, requestDoc.reference, {
          'Provider_Services': providerMap,
          'Assigned_Provider_Email': HistoryAppend(assignedEmail),
          'timestamps': HistoryAppend(DateTime.now().millisecondsSinceEpoch),
        });

        return providerMap;
      }

      return null;
    } catch (e) {
      if (kDebugMode) svcLog('Resolving the request provider failed: $e');
      return null;
    }
  }

  /// The provider ServiceProviderSelector picks, with all its saved fields.
  Future<Map<String, dynamic>?> _selectProvider({
    required List<ServiceEmployeeModel> providers,
    required String parentServiceId,
  }) async {
    if (providers.isEmpty) return null;
    final picked = await _selector.selectProviderForNewRequest(
      providers: providers,
      parentServiceId: parentServiceId,
    );
    final email = (picked?['email'] ?? '').toString().toLowerCase();
    final match = providers.firstWhere(
      (p) => (p.email ?? '').toLowerCase() == email,
      orElse: () => providers.first,
    );
    return convertEmployeeToMap(match);
  }

  /// The provider fields saved on a request.
  Map<String, dynamic> convertEmployeeToMap(ServiceEmployeeModel employee) {
    return {
      'id': employee.id ?? '',
      'email': employee.email ?? '',
      'firstName': employee.firstName ?? '',
      'lastName': employee.lastName ?? '',
      'firstNameInArabic': employee.firstNameInArabic ?? '',
      'lastNameInArabic': employee.lastNameInArabic ?? '',
      'middleName': employee.middleName ?? '',
      'middleNameInArabic': employee.middleNameInArabic ?? '',
      'departmentId': employee.departmentId ?? '',
      'title': employee.title ?? '',
      'titleInArabic': employee.titleInArabic ?? '',
      'role': employee.role ?? '',
      'gender': employee.gender ?? '',
      'workLocation': employee.workLocation ?? '',
      'status': employee.status ?? 'active',
      'nationalId': employee.nationalId ?? '',
      'nationality': employee.nationality ?? '',
      'birthDay': employee.birthDay ?? '',
      'country': employee.country ?? '',
      'province': employee.province ?? '',
      'city': employee.city ?? '',
      'maritalStatus': employee.maritalStatus ?? '',
      'language': employee.language ?? '',
      'supervisor': employee.supervisor ?? '',
      'mobilePhone': employee.mobilePhone?.toJson(),
      'officePhone': employee.officePhone ?? '',
      'homePhone': employee.homePhone ?? '',
      'extension': employee.extension ?? '',
    };
  }

  /// Reads a provider saved on a request.
  ServiceEmployeeModel convertMapToEmployeeEntityModel(
    Map<String, dynamic> data,
  ) {
    List<String?>? convertToStringList(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e?.toString()).toList();
      }
      if (value is String) {
        return value.isEmpty ? null : [value];
      }
      return null;
    }

    return ServiceEmployeeModel(
      id: data['id']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      firstNameInArabic: data['firstNameInArabic']?.toString() ?? '',
      lastNameInArabic: data['lastNameInArabic']?.toString() ?? '',
      middleName: data['middleName']?.toString() ?? '',
      middleNameInArabic: data['middleNameInArabic']?.toString() ?? '',
      nationalId: data['nationalId']?.toString() ?? '',
      nationalIdExpirationDate:
          data['nationalIdExpirationDate']?.toString() ?? '',
      nationality: data['nationality']?.toString() ?? '',
      passport: data['passport']?.toString() ?? '',
      passportExpirationDate: data['passportExpirationDate']?.toString() ?? '',
      mobilePhone: data['mobilePhone'] != null && data['mobilePhone'] is Map
          ? ServicesMobilePhoneEntity.fromJson(data['mobilePhone'])
          : null,
      officePhone: data['officePhone']?.toString() ?? '',
      homePhone: data['homePhone']?.toString() ?? '',
      extension: data['extension']?.toString() ?? '',
      birthDay: data['birthDay']?.toString() ?? '',
      gender: data['gender']?.toString() ?? '',
      country: data['country']?.toString() ?? '',
      province: data['province']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      postalCode: data['postalCode']?.toString() ?? '',
      street: data['street']?.toString() ?? '',
      maritalStatus: data['maritalStatus']?.toString() ?? '',
      language: data['language']?.toString() ?? '',
      departmentId: data['departmentId']?.toString() ?? '',
      supervisor: data['supervisor']?.toString() ?? '',
      role: data['role']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      titleInArabic: data['titleInArabic']?.toString() ?? '',
      workLocation: data['workLocation']?.toString() ?? '',
      drivingLicenseId: data['drivingLicenseId']?.toString() ?? '',
      carPlates: convertToStringList(data['carPlates']),
      academicHistory:
          data['academicHistory'] != null && data['academicHistory'] is Map
              ? AcademicHistoryEntity.fromJson(data['academicHistory'])
              : null,
      bio: data['bio']?.toString() ?? '',
      photo: data['photo']?.toString() ?? '',
      skills: convertToStringList(data['skills']),
      hobbies: convertToStringList(data['hobbies']),
      status: data['status']?.toString() ?? '',
      firstLogin: data['firstLogin'],
      lastLogin: data['lastLogin']?.toString() ?? '',
      deactivationDate: data['deactivationDate']?.toString() ?? '',
      activationDate: data['activationDate']?.toString() ?? '',
      state: data['state']?.toString() ?? '',
    );
  }
}
