/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/controller
///
///*************************** FILE INFO ****************************///
/// File Name: create_knowledge_tools.dart
/// Description: Debug-only data tools of the hub (sample documents and the
///              one-off data fixes), moved out of the seed buttons.
/// Author: Amr Mesbah
/// Created at: 20/10/2026

part of '../create_knowledge_cubit.dart';

/// The seed / backfill buttons call these instead of the services.
mixin CreateKnowledgeTools on CreateKnowledgeCubitBase, CreateKnowledgeLoading {
  /// Writes the sample documents under the signed-in employee, then reloads
  /// the hub.
  ///
  /// Returns how many documents were written, or null when nobody is signed
  /// in, their department is unknown (never seed under a placeholder,
  /// KH-CREATE-10) or the write failed.
  Future<int?> seedSampleDocuments() async {
    final employee = people.signedInEmployee;
    final String email = employee?.email ?? '';
    final String? department = await _englishDepartmentName(
      employee?.departmentId,
    );
    if (email.isEmpty || department == null) return null;
    try {
      final int count = await _repository.seedSampleDocuments(
        createdByEmail: email,
        owningDepartment: department,
      );
      if (!isClosed) await fetchAllKnowledge();
      return count;
    } catch (e) {
      khLog('seedSampleDocuments failed: $e', name: 'CreateKnowledgeCubit');
      return null;
    }
  }

  /// Runs the one-off data fixes, then reloads the hub:
  /// - visibility fields on older documents (KH-CREATE-06);
  /// - employee IDs on older file actions (KH-CREATE-14 / KH-SUBMIT-07).
  ///
  /// Returns how many records were updated, or null when it failed.
  Future<int?> runDataBackfill() async {
    try {
      final int documents = await _repository.backfillVisibilityFields();
      final int actions = await _repository.migrateFileActionEmployeeIds(
        _employeeIdsByEmail(),
      );
      if (!isClosed) await fetchAllKnowledge();
      return documents + actions;
    } catch (e) {
      khLog('runDataBackfill failed: $e', name: 'CreateKnowledgeCubit');
      return null;
    }
  }

  /// Lower-case e-mail → employee ID, from the employee list loaded at start.
  Map<String, String> _employeeIdsByEmail() {
    final Map<String, String> map = {};
    final employees = people.employeesOrNull?.allEmployeesEntities;
    if (employees == null) return map;
    for (final employee in employees) {
      final String email = (employee.email ?? '').toLowerCase().trim();
      final String id = employee.id ?? '';
      if (email.isNotEmpty && id.isNotEmpty) map[email] = id;
    }
    return map;
  }

  /// The English name of [departmentId] (the form the create screen saves),
  /// or null when it cannot be resolved.
  Future<String?> _englishDepartmentName(String? departmentId) async {
    if (departmentId == null || departmentId.isEmpty) return null;
    try {
      final departments = await _repository.fetchAllDepartments();
      for (final d in departments) {
        if (d.departmentID == departmentId &&
            (d.departmentName ?? '').isNotEmpty) {
          return d.departmentName;
        }
      }
    } catch (e) {
      khLog('department lookup failed: $e', name: 'CreateKnowledgeCubit');
    }
    return null;
  }
}
