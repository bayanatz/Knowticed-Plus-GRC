/// Module: GRC / Dashboard Of All Departments
/// Description: State for the module's Departments tab and its Reporting
///              and Audit page — the loaded data plus every filter the
///              design exposes (department, Policies | Controls, Table |
///              Analytics, search, status filter, chart policy / control).
/// Author: Knowticed Plus team
/// Date: 2026-09-16
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/features/grc/grc5_control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/grc6_control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:knowticed_plus/features/grc/grc7_control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:knowticed_plus/features/grc/grc9_department_dashboard/domain/entities/department_dashboard_data.dart';
import 'package:knowticed_plus/features/grc/grc9_department_dashboard/domain/use_cases/get_department_dashboard_use_case.dart';
import 'package:knowticed_plus/features/grc/grc13_policy/domain/use_cases/get_policy_usecases.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/features/grc/helpers/constants/grc_firebase_paths.dart';

part 'department_dashboard_state.dart';

/// class name: [DepartmentDashboardCubit]
class DepartmentDashboardCubit extends Cubit<DepartmentDashboardState> {
  DepartmentDashboardCubit({
    required this.moduleId,
    required GetDepartmentDashboardUseCase useCase,
  })  : _useCase = useCase,
        super(const DepartmentDashboardState());

  /// Builds the cubit from the use cases already registered in GetIt, so the
  /// feature needs no extra DI registration.
  factory DepartmentDashboardCubit.create(String moduleId) {
    final sl = GetIt.instance;
    return DepartmentDashboardCubit(
      moduleId: moduleId,
      useCase: GetDepartmentDashboardUseCase(
        getAllPolicies: sl<GetAllPoliciesUseCase>(),
        getAllControls: sl<GetAllControlsUseCase>(),
        getAllOwners: sl<GetAllOwnersUseCase>(),
        getAllChampions: sl<GetAllChampionsUseCase>(),
      ),
    );
  }

  final String moduleId;
  final GetDepartmentDashboardUseCase _useCase;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: DepartmentLoadStatus.loading));
    final result = await _useCase.call(moduleId: moduleId);
    if (isClosed) return;
    result.fold(
      (failure) {
        if (silent) return;
        emit(state.copyWith(
          status: DepartmentLoadStatus.failure,
          message: failure.message,
        ));
      },
      (data) {
        emit(state.copyWith(
          status: DepartmentLoadStatus.loaded,
          data: data,
        ));
        _live.watchPaths([
          GrcFirebasePaths.moduleSub(moduleId, 'Policies'),
          GrcFirebasePaths.moduleSub(moduleId, 'Control Owners'),
          GrcFirebasePaths.moduleSub(moduleId, 'Control Champions'),
          for (final p in data.policies)
            GrcFirebasePaths.controlsOf(moduleId, p.id),
        ], () => load(silent: true));
      },
    );
  }

  final LiveRefresh _live = LiveRefresh();

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// A new department resets the chart / report pickers, which may no
  /// longer belong to it.
  void setDepartment(String? department) => emit(state.copyWith(
        department: () => department,
        chartPolicyId: () => null,
        chartControlId: () => null,
        reportPolicyId: () => null,
        reportControlId: () => null,
      ));

  void setTab(DepartmentListTab tab) =>
      emit(state.copyWith(tab: tab, statusFilter: () => null));

  void setView(DepartmentView view) => emit(state.copyWith(view: view));

  void setSearch(String query) => emit(state.copyWith(search: query));

  void setStatusFilter(String? status) =>
      emit(state.copyWith(statusFilter: () => status));

  void setChartPolicy(String? policyId) => emit(state.copyWith(
        chartPolicyId: () => policyId,
        chartControlId: () => null,
      ));

  void setChartControl(String? controlId) =>
      emit(state.copyWith(chartControlId: () => controlId));

  void setReportPolicy(String? policyId) => emit(state.copyWith(
        reportPolicyId: () => policyId,
        reportControlId: () => null,
      ));

  void setReportControl(String? controlId) =>
      emit(state.copyWith(reportControlId: () => controlId));
}
