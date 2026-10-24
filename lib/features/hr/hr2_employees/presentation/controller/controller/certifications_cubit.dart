// ***************************** FILE INFO ***************************** //
// File Name: certifications_cubit.dart
// Purpose: Joins and publishes employee certification rows.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/constants/hr_api_constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/hr_fields/hr_employee_entity.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/data/models/employee_certification_details_model.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/data/repository/certifications_repository.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/domain/entities/certification_employee_row.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/ui_controllers_models/employee_filter_model.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/controller/controller/employee_details_table_cubit.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/controller/controller/employee_details_table_state.dart';

part 'certifications_state.dart';

/// Publishes table-ready certification records using shared employee controls.
class CertificationsCubit extends EmployeeDetailsTableCubit<
    CertificationEmployeeRow, CertificationsState> {
  CertificationsCubit({
    required super.dataCubit,
    CertificationsRepository? repository,
  })  : _repository = repository ?? CertificationsRepository(),
        super(initialState: const CertificationsInitial()) {
    initializeEmployeeDetailsTable();
    _loadSupplementalData();
  }

  final CertificationsRepository _repository;
  final LiveRefresh _live = LiveRefresh();
  Map<String, EmployeeCertificationDetailsModel> _certifications = const {};

  /// Method Name: [_loadSupplementalData]
  ///
  /// Purpose: Loads complete certification histories for employee row joins.
  Future<void> _loadSupplementalData({bool silent = false}) async {
    final result = await _repository.getCertifications();
    if (silent && result.isLeft()) return;
    result.fold(
      (failure) => publishError(failure.message),
      (data) {
        _certifications = data;
        rebuildRows();
        publishLoaded();
      },
    );
    _live.watchPaths(
      <String>[HrApiConstants.certificationsPath],
      () => _loadSupplementalData(silent: true),
    );
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// Method Name: [refreshCertifications]
  ///
  /// Purpose: Reloads certification histories after a bulk upload completes.
  Future<void> refreshCertifications() => _loadSupplementalData();

  /// Creates a certification row by joining the employee with its history.
  @override
  CertificationEmployeeRow buildRow(HrEmployeeEntity employee) =>
      CertificationEmployeeRow(
        employee: employee,
        certification: _certifications[employee.id],
      );

  /// Creates the feature's initial table state.
  @override
  CertificationsState createInitialState() => const CertificationsInitial();

  /// Creates the feature's loading table state.
  @override
  CertificationsState createLoadingState({
    required List<CertificationEmployeeRow> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  }) =>
      CertificationsLoading(
        rows: rows,
        searchQuery: searchQuery,
        filters: filters,
      );

  /// Creates the feature's loaded table state.
  @override
  CertificationsState createLoadedState({
    required List<CertificationEmployeeRow> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  }) =>
      CertificationsLoaded(
        rows: rows,
        searchQuery: searchQuery,
        filters: filters,
      );

  /// Creates the feature's error table state.
  @override
  CertificationsState createErrorState({
    required String message,
    required List<CertificationEmployeeRow> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  }) =>
      CertificationsError(
        message: message,
        rows: rows,
        searchQuery: searchQuery,
        filters: filters,
      );
}
