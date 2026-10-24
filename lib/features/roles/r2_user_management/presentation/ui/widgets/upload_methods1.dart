/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_methods1.dart
/// Description: Declares `_UploadMethods1`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/upload_file_details.dart';

extension _UploadMethods1 on _UploadFileDetailsTabletRolesState {
  String? validateCell(
    String key,
    String? value, {
    Map<String, TextEditingController>? rowData,
  }) {
    // No conditional validation - Access Granted and Access Revoked are always independent

    if (value == null || value.trim().isEmpty) return 'Required';
    value = value.trim();

    if (value.toLowerCase() == 'null') return 'Warning Wrong Entry';

    // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).
    bool hasExtraSpaces(String val) => RegExp(r'\s{2,}').hasMatch(val);
    // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).
    bool isEnglish(String text) => RegExp(r'^[a-zA-Z\s]+$').hasMatch(text);
    bool hasSpecialChars(String text) =>
        RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*&^%$]').hasMatch(text);
    bool hasNumbers(String text) => RegExp(r'\d').hasMatch(text);
    bool containsArabic(String text) =>
        RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).

    // ✅ Detect duplicate for Employee ID only
    if (['Employee ID'].contains(key)) {
      final currentValue = value.toLowerCase().trim();
      int count = 0;

      for (var row in formData) {
        final otherValue = row[key]?.text.toLowerCase().trim();
        if (otherValue == currentValue) count++;
      }

      if (count > 1) return 'Duplicate value – must be unique';
    }

    switch (key.trim()) {
      case 'Employee ID':
        // Employee ID should be alphanumeric, no special chars, no spaces
        if (value.contains(' ')) return 'Warning Format Issue';
        if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%$]').hasMatch(value)) {
          return 'Warning Format Issue';
        }
        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
          return 'Warning Format Issue';
        }
        if (value.length < 2) return 'Warning Format Issue';
        break;

      case 'Current Role Type':
        // Should be English text only, no numbers, no Arabic, allow spaces
        if (containsArabic(value)) return 'Warning Language Check';
        if (hasNumbers(value)) return 'Warning Format Issue';
        if (hasSpecialChars(value)) return 'Warning Format Issue';
        if (!isEnglish(value)) return 'Warning Language Check';
        if (hasExtraSpaces(value)) return 'Warning Format Issue';
        if (value.length < 2) return 'Warning Format Issue';
        break;

      case 'Desired Role Type':
        // Should be English text only, no numbers, no Arabic, allow spaces
        if (containsArabic(value)) return 'Warning Language Check';
        if (hasNumbers(value)) return 'Warning Format Issue';
        if (hasSpecialChars(value)) return 'Warning Format Issue';
        if (!isEnglish(value)) return 'Warning Language Check';
        if (hasExtraSpaces(value)) return 'Warning Format Issue';
        if (value.length < 2) return 'Warning Format Issue';
        break;

      case 'Access Granted':
        // Always validate - independent of Status
        // Validate comma-separated permissions
        if (value.startsWith(',') || value.endsWith(',')) {
          return 'Warning Misplaced Comma';
        }

        if (value.contains(',,')) {
          return 'Warning Misplaced Comma';
        }

        // Check for spaces around commas
        if (RegExp(r'\s*,\s*').hasMatch(value) && value.contains(' ')) {
          return 'Warning Format Issue';
        }

        // Check for invalid characters (only allow letters, numbers, and commas)
        if (RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*&^%$\s]').hasMatch(value)) {
          return 'Warning Format Issue';
        }

        final permissions = value.split(',').map((e) => e.trim()).toList();

        for (final perm in permissions) {
          if (perm.isEmpty) {
            return 'Warning Misplaced Comma';
          }

          if (perm.length < 2) {
            return 'Warning Format Issue';
          }

          // Each permission should be alphanumeric
          if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(perm)) {
            return 'Warning Format Issue';
          }
        }
        break;

      case 'Access Revoked':
        // Always validate - independent of Status
        // Validate comma-separated permissions
        if (value.startsWith(',') || value.endsWith(',')) {
          return 'Warning Misplaced Comma';
        }

        if (value.contains(',,')) {
          return 'Warning Misplaced Comma';
        }

        // Check for spaces around commas
        if (RegExp(r'\s*,\s*').hasMatch(value) && value.contains(' ')) {
          return 'Warning Format Issue';
        }

        // Check for invalid characters (only allow letters, numbers, and commas)
        if (RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*&^%$\s]').hasMatch(value)) {
          return 'Warning Format Issue';
        }

        final permissions = value.split(',').map((e) => e.trim()).toList();

        for (final perm in permissions) {
          if (perm.isEmpty) {
            return 'Warning Misplaced Comma';
          }

          if (perm.length < 2) {
            return 'Warning Format Issue';
          }

          // Each permission should be alphanumeric
          if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(perm)) {
            return 'Warning Format Issue';
          }
        }
        break;

      case 'Status':
        // Status must be one of: Active, Inactive, Scheduled, Expiring Soon (case insensitive)
        final normalized = value.toLowerCase();
        const allowedStatuses = [
          'active',
          'inactive',
          'scheduled',
          'expiring soon',
        ];
        if (!allowedStatuses.contains(normalized)) {
          return 'Warning Wrong Entry';
        }
        break;
    }

    return null;
  }

  Future<void> uploadToFirebase() async {
    // ADDED 9/10/2026 — this legacy page (no longer navigated to since
    // 21/9/2026, see user_management_home.dart) wrote grants straight to
    // Firestore with no user-limit check. The whole file is now checked
    // first and refused if any Knowticed Admin limit would be exceeded or the
    // limits cannot be read. Not transactional — the writes below are
    // individual; the Import page that replaced this one is.
    final List<ProposedAssignment> seatChange = <ProposedAssignment>[
      for (final Map<String, TextEditingController> row in formData)
        if ((row[primaryKey]?.text.trim() ?? '').isNotEmpty &&
            (row['Desired Role Type']?.text.trim() ?? '').isNotEmpty)
          ProposedAssignment(
            employeeId: row[primaryKey]!.text.trim(),
            role: row['Desired Role Type']!.text.trim(),
          ),
    ];
    if (seatChange.isNotEmpty) {
      final pre = await UserManagementAccessRepository().precheckAssignments(
        seatChange,
      );
      if (pre.isLeft()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pre.fold((f) => f.errMessage, (_) => '')),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }
    }

    final firestore = FirebaseFirestore.instance;
    final accessCollection = firestore.collection(
      getBaseUrl(FirestoreCollections.accessEmployee),
    );
    final employeesCollection = firestore.collection(
      getBaseUrl(FirestoreCollections.employeeInfo),
    ); // Assuming this is the correct collection name

    int success = 0, updated = 0, failed = 0;

    for (var row in formData) {
      String employeeId = row[primaryKey]?.text.trim() ?? '';
      if (employeeId.isEmpty) {
        failed++;
        continue;
      }

      try {
        final now = DateTime.now().millisecondsSinceEpoch;

        // ✅ Step 1: Update/Create document in accessEmployee collection
        final accessDocRef = accessCollection.doc(employeeId);
        final accessDocSnapshot = await accessDocRef.get();

        if (accessDocSnapshot.exists) {
          // ✅ APPEND to existing arrays (not replace)
          Map<String, dynamic> updateData = {};

          // Add timestamp to timestamps array
          updateData['timestamps'] = FieldValue.arrayUnion([now]);

          row.forEach((key, controller) {
            String value = controller.text.trim();
            final firestoreField = columnToFirestoreField[key] ?? key;

            // Append to arrays (preserving existing data)
            updateData[firestoreField] = FieldValue.arrayUnion([value]);
          });

          await accessDocRef.update(updateData);
          updated++;
        } else {
          // ✅ CREATE new document with arrays
          Map<String, dynamic> data = {};

          data['timestamps'] = [now];

          row.forEach((key, controller) {
            String value = controller.text.trim();
            final firestoreField = columnToFirestoreField[key] ?? key;
            data[firestoreField] = [value];
          });

          await accessDocRef.set(data);
          success++;
        }

        // ✅ Step 2: Update Employee's Role in Employees_Info collection
        String desiredRole = row['Desired Role Type']?.text.trim() ?? '';

        if (desiredRole.isNotEmpty) {
          final employeeDocRef = employeesCollection.doc(employeeId);
          final employeeDocSnapshot = await employeeDocRef.get();

          if (employeeDocSnapshot.exists) {
            // Get existing employee data using NewEmployeeModelHistory
            final employeeData = NewEmployeeModelHistory.fromMap(
              employeeDocSnapshot.data(),
            );

            // Check if role already exists in the list
            bool roleExists = false;
            if (employeeData.role.isNotEmpty) {
              // Check the last role entry
              String lastRole = employeeData.role.last;
              roleExists = lastRole == desiredRole;
            }

            if (!roleExists) {
              // Add new role using the synchronized update method
              final updatedEmployee = employeeData.copyWithUpdateSynchronized(
                role: desiredRole,
                addTimestamp: now,
              );

              // Update Firestore
              await employeeDocRef.update(updatedEmployee.toMap());
            } else {}
          } else {}
        }
      } catch (e) {
        failed++;
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Upload complete: $success added, $updated updated, $failed failed.',
        ),
      ),
    );
  }

  int getTotalErrorCount() {
    int totalErrors = 0;
    for (final row in validationErrors) {
      totalErrors += row.length;
    }
    return totalErrors;
  }
}
