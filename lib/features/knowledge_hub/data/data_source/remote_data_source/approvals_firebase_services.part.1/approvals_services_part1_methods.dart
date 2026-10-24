/// Module: knowledge_hub/data/data_source/remote_data_source/approvals_firebase_services.part.1
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_services_part1_methods.dart
/// Description: Methods of `ApprovalsFirebaseServices` — split out of `approvals_firebase_services.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../approvals_firebase_services.dart';

// Split from approvals_firebase_services.part.1.dart to keep every file under 700 lines.

mixin ApprovalsServicesPart1Methods2
    on ApprovalsFirebaseServicesBase, ApprovalsServicesPart1 {
  /// 3. Batch fetch department names for multiple department IDs
  Future<Map<String, String>> fetchMultipleDepartmentNames(
    List<String> departmentIds,
  ) async {
    try {
      _debugPaths('fetchMultipleDepartmentNames');

      if (departmentIds.isEmpty) {
        khLog(
          '⚠️ [Firebase] fetchMultipleDepartmentNames called with empty list',
        );
        return {};
      }

      khLog(
        '🏢 [Firebase] Fetching ${departmentIds.length} departments: $departmentIds',
      );

      // ✅ Use dynamic path
      String departmentsPath = getBaseUrl(
        FirebaseCollections.departmentDirectory,
      );
      khLog('📂 Using path: $departmentsPath');

      // Remove duplicates
      final uniqueIds = departmentIds.toSet().toList();
      khLog('🏢 [Firebase] Unique department IDs: ${uniqueIds.length}');

      Map<String, String> departmentMap = {};

      // Firestore 'in' queries are limited to 10 items
      for (int i = 0; i < uniqueIds.length; i += 10) {
        final batch = uniqueIds.skip(i).take(10).toList();
        khLog(
          '📦 [Firebase] Fetching department batch ${(i ~/ 10) + 1}: $batch',
        );

        QuerySnapshot querySnapshot = await _firestore
            .collection(departmentsPath)
            .where(KhDepartmentKeys.departmentId, whereIn: batch)
            .get();

        khLog(
          '📥 [Firebase] Department batch query returned ${querySnapshot.docs.length} documents',
        );

        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            String? deptId = data[KhDepartmentKeys.departmentId] as String?;
            String? deptName = data[KhDepartmentKeys.departmentName] as String?;

            if (deptId != null && deptId.isNotEmpty && deptName != null) {
              departmentMap[deptId] = deptName;
              khLog(
                '✅ [Firebase] Mapped department: ID="$deptId" → Name="$deptName"',
              );
            }
          } catch (e) {
            khLog('❌ [Firebase] Error parsing department doc ${doc.id}: $e');
          }
        }
      }

      khLog(
        '✅ [Firebase] Successfully fetched ${departmentMap.length} department names',
      );
      khLog(
        '🗂️ [Firebase] Department IDs in result: ${departmentMap.keys.toList()}',
      );

      return departmentMap;
    } catch (e) {
      khLog('❌ [Firebase] Error fetching multiple department names: $e');
      rethrow;
    }
  }

  /// Batch fetch user data for multiple user IDs
  Future<Map<String, EmployeeData>> fetchMultipleUserData(
    List<String> userIds,
  ) async {
    try {
      _debugPaths('fetchMultipleUserData');

      if (userIds.isEmpty) {
        khLog(
          '⚠️ [Firebase] fetchMultipleUserData called with empty userIds list',
        );
        return {};
      }

      khLog(
        '👥 [Firebase] Fetching data for ${userIds.length} users: $userIds',
      );

      // ✅ Use dynamic path
      String employeesPath = getBaseUrl(FirebaseCollections.employeesInfo);
      khLog('📂 Using path: $employeesPath');

      // Remove duplicates
      final uniqueUserIds = userIds.toSet().toList();
      khLog('👥 [Firebase] Unique user IDs: ${uniqueUserIds.length}');

      Map<String, EmployeeData> usersMap = {};

      // Firestore 'in' queries are limited to 10 items
      for (int i = 0; i < uniqueUserIds.length; i += 10) {
        final batch = uniqueUserIds.skip(i).take(10).toList();
        khLog('📦 [Firebase] Fetching batch ${(i ~/ 10) + 1}: $batch');

        QuerySnapshot querySnapshot = await _firestore
            .collection(employeesPath)
            .where(EmployeeKeys.id, whereIn: batch)
            .get();

        khLog(
          '📥 [Firebase] Batch query returned ${querySnapshot.docs.length} documents',
        );

        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            EmployeeData employee = EmployeeData.fromJson(data);
            usersMap[employee.currentemployeeId] = employee;

            khLog(
              '✅ [Firebase] Parsed employee: id="${employee.currentemployeeId}", name="${employee.currentemployeeName}"',
            );
          } catch (e) {
            khLog(
              '❌ [Firebase] Error parsing employee data from doc ${doc.id}: $e',
            );
          }
        }
      }

      khLog(
        '✅ [Firebase] Successfully fetched ${usersMap.length} user records',
      );
      return usersMap;
    } catch (e) {
      khLog('❌ [Firebase] Error fetching multiple user data: $e');
      rethrow;
    }
  }

  /// Enhanced version to handle different email field structures using dynamic path
  Future<EmployeeData?> fetchUserDataByEmail(String email) async {
    try {
      String companyId = _getCompanyId();
      String employeesPath = getBaseUrl(FirebaseCollections.employeesInfo);

      khLog('🔍 [Firebase] Fetching user for email: $email');
      khLog('📂 Using path: $employeesPath');
      khLog('🏢 Company ID: $companyId');

      // Try multiple query approaches since email field structure varies
      final snapshot = await _firestore
          .collection(employeesPath)
          .where(KhEmployeeFallbackKeys.currentEmployeeEmail, isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        khLog('✅ Found user with direct email query');
        return EmployeeData.fromJson(snapshot.docs.first.data());
      }

      // If not found, try array contains query
      final snapshot2 = await _firestore
          .collection(employeesPath)
          .where(
            KhEmployeeFallbackKeys.currentEmployeeEmail,
            arrayContains: email,
          )
          .get();

      if (snapshot2.docs.isNotEmpty) {
        khLog('✅ Found user with array contains query');
        return EmployeeData.fromJson(snapshot2.docs.first.data());
      }

      // If still not found, try the nested Email field structure
      final snapshot3 = await _firestore
          .collection(employeesPath)
          .where(EmployeeKeys.email, arrayContains: email)
          .get();

      if (snapshot3.docs.isNotEmpty) {
        khLog('✅ Found user with nested Email field query');
        return EmployeeData.fromJson(snapshot3.docs.first.data());
      }

      khLog('📥 Query returned 0 documents for email: $email');

      // Log sample data for debugging
      final sampleSnapshot = await _firestore
          .collection(employeesPath)
          .limit(5)
          .get();

      khLog('📊 Sample employees in collection:');
      for (var doc in sampleSnapshot.docs) {
        final data = doc.data();
        final emailField =
            data[KhEmployeeFallbackKeys.currentEmployeeEmail] ??
            data[EmployeeKeys.email] ??
            'No email field';
        khLog('  - Doc ID: ${doc.id}');
        khLog('    Email field: $emailField');
      }

      return null;
    } catch (e) {
      khLog('❌ Error in fetchUserDataByEmail: $e');
      rethrow;
    }
  }
}
