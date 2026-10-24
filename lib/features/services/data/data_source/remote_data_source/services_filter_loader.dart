/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: services_filter_loader.dart
/// Purpose: Builds the filtered request list + per-employee/aggregate stats for
///          a parent service. Extracted from ServicesManagerCubit.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/parent_service_details_fetcher.dart';
import 'package:knowticed_plus/features/services/domain/entities/requester_info.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Loads request documents for a parent service, enriches them with creator
/// details from CreateServices, computes status counts and per-employee stats.
class ServicesFilterLoader {
  ServicesFilterLoader({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>> loadFilteredItems({
    required String? parentServiceId,
    required ServicesHistoryModel parentService,
    required RequesterInfo Function(String email) requesterOf,
  }) async {
    final firestore = _firestore;
    final String? parentId = parentServiceId?.trim();

    final emptyResult = {
      'filteredItems': <Map<String, dynamic>>[],
      'allEmployees': <ServiceEmployeeModel>[],
      'localStats': {
        'done': 0,
        'approved': 0,
        'inprogress': 0,
        'pending': 0,
        'rejected': 0,
        'cancel': 0,
        'branchsla': 0,
      },
    };

    if (parentId == null || parentId.isEmpty) {
      return emptyResult;
    }

    try {
      final String requestServicesPath = getBaseUrl(
        FirestoreCollections.requestServicesRoot,
      );

      // Path may be any odd-segment length
      // (e.g. Demo/{id}/Modules/services/RequestServices).
      // Firestore.collection() accepts a full slash-delimited path directly.
      final CollectionReference<Map<String, dynamic>> requestsCollection =
          firestore.collection(requestServicesPath);

      // SVC-HOME-03: query this service's requests instead of downloading
      // every request in the company. Parent_Service_Id is a history list on
      // most documents and a plain string on a few older ones, so both forms
      // are queried; the "last value" check below stays the source of truth.
      final snapshots = await Future.wait([
        requestsCollection
            .where('Parent_Service_Id', arrayContains: parentId)
            .get(),
        requestsCollection
            .where('Parent_Service_Id', isEqualTo: parentId)
            .get(),
      ]);
      final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> byId = {
        for (final snap in snapshots)
          for (final doc in snap.docs) doc.id: doc,
      };

      List<QueryDocumentSnapshot> matchingDocs = [];

      for (final doc in byId.values) {
        final data = doc.data();
        String docParentId = '';

        if (data['Parent_Service_Id'] is List) {
          final parentIdList = data['Parent_Service_Id'] as List;
          if (parentIdList.isNotEmpty) {
            docParentId = parentIdList.last.toString().trim();
          }
        } else if (data['Parent_Service_Id'] is String) {
          docParentId = data['Parent_Service_Id'].toString().trim();
        }

        if (docParentId == parentId) {
          matchingDocs.add(doc);
        }
      }

      // No early return when there are no requests: the Employees tab still
      // needs the service team computed below.

      // Rule "Layers depend one way": raw values in BOTH languages are
      // returned; the widgets pick the reader's version.
      final List<Map<String, dynamic>> results = [];

      int doneCount = 0;
      int approvedCount = 0;
      int inProgressCount = 0;
      int pendingCount = 0;
      int rejectedCount = 0;
      int cancelCount = 0;
      int branchSlaCount = 0;

      for (int i = 0; i < matchingDocs.length; i++) {
        final doc = matchingDocs[i];
        final data = doc.data() as Map<String, dynamic>;
        final docId = doc.id;

        ServicesHistoryModel? model;
        try {
          model = ServicesHistoryModel.fromJson(data, docId);
        } catch (e) {
          // Malformed document: skip it, but leave a trace (SVC-HOME-05).
          svcLog('ServicesFilterLoader: skipped request $docId: $e');
          continue;
        }

        // ✅ FETCH MISSING DATA FROM CreateServices
        Map<String, String> serviceDetails = {};

        // Extract email from model
        String emailRequester = model.currentEmailRequester;

        // If email is empty, try to extract from data
        if (emailRequester.isEmpty && data.containsKey('Email_Requester')) {
          final rawEmail = data['Email_Requester'];
          if (rawEmail is List && rawEmail.isNotEmpty) {
            emailRequester = rawEmail.last.toString();
          } else if (rawEmail is String) {
            emailRequester = rawEmail;
          }
        }

        if (emailRequester.isNotEmpty && parentId.isNotEmpty) {
          try {
            // The parent service's names and the requester's details.
            final parent =
                await ParentServiceDetailsFetcher(firestore).fetch(parentId);
            final requester = requesterOf(emailRequester);
            final englishName = requester.nameEnglish.split(' ');
            final arabicName = requester.nameArabic.split(' ');
            serviceDetails = {
              'department': requester.departmentEnglish,
              'jobTitle': requester.jobTitleEnglish,
              'jobTitleArabic': requester.jobTitleArabic,
            };

            model = model.copyWith(
              serviceNameEnglish:
                  parent.nameEnglish.isNotEmpty ? parent.nameEnglish : null,
              serviceNameArabic:
                  parent.nameArabic.isNotEmpty ? parent.nameArabic : null,
              firstNameRequester: englishName.first,
              lastNameRequester: englishName.skip(1).join(' '),
              firstNameRequesterArabic: arabicName.first,
              lastNameRequesterArabic: arabicName.skip(1).join(' '),
              jobTitleRequester: serviceDetails['jobTitle'],
              jobTitleRequesterArabic: serviceDetails['jobTitleArabic'],
              // ✅ FIX: display backfill, not an edit — must not append "now" to
              // the timestamps history. See ServicesHistoryModel.copyWith.
              bumpTimestamp: false,
            );
          } catch (e) {
            // Keep the row with the data it has, but log the failure.
            svcLog('ServicesFilterLoader: details for $docId failed: $e');
          }
        }

        final requestorEn =
            '${model!.currentFirstNameRequester} ${model.currentLastNameRequester}'
                .trim();
        final requestorAr =
            '${model.currentFirstNameRequesterArabic} ${model.currentLastNameRequesterArabic}'
                .trim();

        String calculatedStatus = 'pending';

        if (data.containsKey('state')) {
          final rawState = data['state'];
          if (rawState is List && rawState.isNotEmpty) {
            calculatedStatus = rawState.last.toString().toLowerCase().trim();
          } else if (rawState is String && rawState.isNotEmpty) {
            calculatedStatus = rawState.toLowerCase().trim();
          }
        }

        if ((calculatedStatus.isEmpty || calculatedStatus == 'pending') &&
            model.currentState.isNotEmpty) {
          calculatedStatus = model.currentState.toLowerCase().trim();
        }

        switch (calculatedStatus) {
          case 'done':
            doneCount++;
            break;
          case 'approved':
            approvedCount++;
            break;
          case 'inprogress':
          case 'in progress':
            inProgressCount++;
            break;
          case 'pending':
            pendingCount++;
            break;
          case 'rejected':
            rejectedCount++;
            break;
          case 'cancel':
          case 'cancelled':
          case 'canceled':
            cancelCount++;
            break;
          case 'branchsla':
          case 'breached sla':
            branchSlaCount++;
            break;
          default:
            pendingCount++;
        }

        String assignedEmail = '';
        if (data.containsKey('Assigned_Provider_Email')) {
          final rawEmail = data['Assigned_Provider_Email'];

          if (rawEmail is List && rawEmail.isNotEmpty) {
            assignedEmail = rawEmail.last.toString().trim().toLowerCase();
          } else if (rawEmail is String && rawEmail.isNotEmpty) {
            assignedEmail = rawEmail.trim().toLowerCase();
          }
        }

        if (assignedEmail.isEmpty) {
          assignedEmail =
              model.currentAssignedProviderEmail.trim().toLowerCase();
        }

        // Empty = unknown; the widgets show the translated placeholder.
        String providerName = '';
        String providerNameAr = '';

        if (assignedEmail.isNotEmpty) {
          List<ServiceEmployeeModel> availableProviders = [];
          availableProviders.addAll(parentService.currentProviderServices);

          if (data.containsKey('Provider_Services')) {
            try {
              final rawProviders = data['Provider_Services'];
              String providersJson = '';

              if (rawProviders is List && rawProviders.isNotEmpty) {
                providersJson = rawProviders.last.toString();
              } else if (rawProviders is String) {
                providersJson = rawProviders;
              }

              if (providersJson.isNotEmpty) {
                final providersList = jsonDecode(providersJson) as List;
                for (var providerData in providersList) {
                  try {
                    final provider = ServiceEmployeeModel(
                      id: providerData['id']?.toString() ?? '',
                      email: providerData['email']?.toString() ?? '',
                      firstName: providerData['firstName']?.toString() ?? '',
                      lastName: providerData['lastName']?.toString() ?? '',
                      firstNameInArabic:
                          providerData['firstNameInArabic']?.toString() ?? '',
                      lastNameInArabic:
                          providerData['lastNameInArabic']?.toString() ?? '',
                      middleName: providerData['middleName']?.toString() ?? '',
                      middleNameInArabic:
                          providerData['middleNameInArabic']?.toString() ?? '',
                      title: providerData['title']?.toString() ?? '',
                      titleInArabic:
                          providerData['titleInArabic']?.toString() ?? '',
                      departmentId:
                          providerData['departmentId']?.toString() ?? '',
                      role: providerData['role']?.toString() ?? '',
                      gender: providerData['gender']?.toString() ?? '',
                      status: providerData['status']?.toString() ?? 'active',
                    );
                    availableProviders.add(provider);
                  } catch (e) {
                    svcLog('Ignored error: $e');
                  }
                }
              }
            } catch (e) {
              svcLog('Ignored error: $e');
            }
          }

          ServiceEmployeeModel? foundProvider;

          try {
            foundProvider = availableProviders.firstWhere(
              (p) => (p.email ?? '').toLowerCase() == assignedEmail,
            );
          } catch (e) {
            try {
              foundProvider = parentService.currentApprovalCycle.firstWhere(
                (p) => (p.email ?? '').toLowerCase() == assignedEmail,
              );
            } catch (e2) {
              svcLog('Ignored error: $e2');
            }
          }

          if (foundProvider != null) {
            providerName =
                '${foundProvider.firstName ?? ''} ${foundProvider.lastName ?? ''}'
                    .trim();
            providerNameAr =
                '${foundProvider.firstNameInArabic ?? ''} ${foundProvider.lastNameInArabic ?? ''}'
                    .trim();

            if (providerName.isEmpty && providerNameAr.isEmpty) {
              providerName = assignedEmail;
            }
          } else {
            providerName = assignedEmail;
          }
        }

        // ✅ Use department from fetched data if available
        String departmentId = model.currentDepartmentRequester;
        if (departmentId.isEmpty && serviceDetails.containsKey('department')) {
          // If we have department name from helper, we need to convert it back to ID
          // For now, just use what we have
          departmentId = serviceDetails['department'] ?? '';
        }

        results.add({
          "no": i + 1,
          "department": departmentId,
          "serviceName": model.currentServiceNameEnglish.isNotEmpty
              ? model.currentServiceNameEnglish
              : model.currentServiceNameArabic,
          "gender": model.currentGenderRequester,
          "requestorEn": requestorEn,
          "requestorAr": requestorAr,
          "jobtitleEn": model.currentJobTitleRequester,
          "jobtitleAr": model.currentJobTitleRequesterArabic,
          "status": calculatedStatus,
          // Kept for the provider lookups that match on it.
          "provider": providerName,
          "providerAr": providerNameAr,
          "docId": docId,
          "model": model, // ✅ Updated model with fetched data
          "raw": data,
        });
      }

      final providerList = parentService.currentProviderServices;
      final approvalList = parentService.currentApprovalCycle;

      final Set<String> usedEmails = {};
      final List<ServiceEmployeeModel> combined = [];

      for (final member in [...providerList, ...approvalList]) {
        final email = (member.email ?? '').toLowerCase();
        if (email.isNotEmpty && !usedEmails.contains(email)) {
          combined.add(_teamMember(member));
          usedEmails.add(email);
        }
      }
      final localStats = {
        'done': doneCount,
        'approved': approvedCount,
        'inprogress': inProgressCount,
        'pending': pendingCount,
        'rejected': rejectedCount,
        'cancel': cancelCount,
        'branchsla': branchSlaCount,
      };

      return {
        'filteredItems': results,
        'allEmployees': combined,
        'localStats': localStats,
      };
    } catch (e) {
      // SVC-HOME-05: a failed load must not look like "0 requests".
      svcLog('ServicesFilterLoader.loadFilteredItems failed: $e');
      rethrow;
    }
  }

  /// Suggestion (CR-KNP-SVC-HOME-19): only the fields the Employees tab
  /// shows are copied — not national id, passport, address, phones or
  /// academic history.
  ServiceEmployeeModel _teamMember(ServiceEmployeeModel e) =>
      ServiceEmployeeModel(
        id: e.id,
        email: e.email,
        firstName: e.firstName,
        lastName: e.lastName,
        firstNameInArabic: e.firstNameInArabic,
        lastNameInArabic: e.lastNameInArabic,
        title: e.title,
        titleInArabic: e.titleInArabic,
        departmentId: e.departmentId,
        gender: e.gender,
        role: e.role,
        state: e.state,
      );
}
