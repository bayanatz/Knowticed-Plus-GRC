/// Module: GRC — Action Center
///
///*************************** FILE INFO ****************************///
/// File Name: grc_action_center_cubit.dart
/// Purpose: Declares `GrcActionCenterCubit` — loads every module's policies
///          and controls (through the existing GetGrcDashboardUseCase), turns
///          them into Action Center issues, and holds the tab / search /
///          department / module filters. Filters run in memory.
/// Author: Amr Mesbah
/// Created: 17/9/2026
library;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/features/grc/grc1_action_center/domain/entities/grc_action_issue.dart';
import 'package:knowticed_plus/features/grc/grc8_dashboard/domain/use_cases/get_grc_dashboard_use_case.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/features/grc/helpers/constants/grc_firebase_paths.dart';

part 'grc_action_center_state.dart';

class GrcActionCenterCubit extends Cubit<GrcActionCenterState> {
  GrcActionCenterCubit({required GetGrcDashboardUseCase useCase})
      : _useCase = useCase,
        super(const GrcActionCenterState());

  /// Built from the use case already registered in GetIt, so the feature
  /// needs no DI registration of its own.
  factory GrcActionCenterCubit.create() => GrcActionCenterCubit(
        useCase: GetIt.instance<GetGrcDashboardUseCase>(),
      );

  final GetGrcDashboardUseCase _useCase;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: GrcActionCenterStatus.loading));
    try {
      final result = await _useCase.forAllModules();
      if (isClosed) return;
      result.fold(
        (f) {
          if (silent) return;
          emit(state.copyWith(
            status: GrcActionCenterStatus.failure,
            message: f.message,
          ));
        },
        (data) {
          emit(state.copyWith(
            status: GrcActionCenterStatus.loaded,
            issues: buildGrcActionIssues(data),
          ));
          _live.watchPaths([
            GrcFirebasePaths.modulesCollection,
            for (final snap in data.snapshots) ...[
              GrcFirebasePaths.moduleSub(snap.module.moduleId, 'Policies'),
              for (final p in snap.policies)
                GrcFirebasePaths.controlsOf(snap.module.moduleId, p.id),
            ],
          ], () => load(silent: true));
        },
      );
    } catch (error, stackTrace) {
      debugPrint('[grc-action-center] load failed: $error\n$stackTrace');
      if (!isClosed && !silent) {
        emit(state.copyWith(
          status: GrcActionCenterStatus.failure,
          message: error.toString(),
        ));
      }
    }
  }

  final LiveRefresh _live = LiveRefresh();

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  void setTab(GrcActionCenterTab tab) => emit(state.copyWith(tab: tab));

  void setAllIssuesKind(GrcIssueKind kind) =>
      emit(state.copyWith(allIssuesKind: kind));

  void setSearch(String query) => emit(state.copyWith(search: query));

  void setDepartment(String? department) =>
      emit(state.copyWith(department: () => department));

  void setModule(String? moduleId) =>
      emit(state.copyWith(moduleId: () => moduleId));
}
