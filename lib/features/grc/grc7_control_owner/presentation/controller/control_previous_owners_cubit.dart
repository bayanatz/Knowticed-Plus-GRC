/// Module: Control Owner Management
/// Description: BLoC Cubit that manages the Previous Control Owners page's
///              state. Delegates to GetControlOwnerHistoryUseCase and emits
///              typed ControlPreviousOwnersState subclasses.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter_bloc, GetControlOwnerHistoryUseCase, ControlOwnerHistoryEntry
/// Revision History: 2026-07-21 - Initial creation
library;

import 'package:knowticed_plus/features/grc/grc7_control_owner/domain/entities/control_owner_history_entry.dart';
import 'package:knowticed_plus/features/grc/grc7_control_owner/domain/use_cases/get_control_owner_history_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/features/grc/helpers/constants/grc_firebase_paths.dart';

part 'control_previous_owners_state.dart';

/// class name: [ControlPreviousOwnersCubit]
///
/// purpose: load and expose the completed Owner-assignment history for one
///          Control.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class ControlPreviousOwnersCubit extends Cubit<ControlPreviousOwnersState> {
  ControlPreviousOwnersCubit({
    required GetControlOwnerHistoryUseCase getOwnerHistoryUseCase,
  })  : _getOwnerHistoryUseCase = getOwnerHistoryUseCase,
        super(ControlPreviousOwnersInitial());

  final GetControlOwnerHistoryUseCase _getOwnerHistoryUseCase;

  Future<void> loadHistory({
    required String moduleId,
    required String policyId,
    required String controlId,
    bool silent = false,
  }) async {
    if (!silent) emit(ControlPreviousOwnersLoading());
    final result = await _getOwnerHistoryUseCase.execute(
      moduleId: moduleId,
      policyId: policyId,
      controlId: controlId,
    );
    if (isClosed) return;
    result.fold(
      (failure) {
        if (!silent) emit(ControlPreviousOwnersFailure(failure.message));
      },
      (entries) {
        emit(ControlPreviousOwnersLoaded(entries));
        _live.watchPaths(
          [GrcFirebasePaths.moduleSub(moduleId, 'Control Owners')],
          () => loadHistory(
            moduleId: moduleId,
            policyId: policyId,
            controlId: controlId,
            silent: true,
          ),
        );
      },
    );
  }

  final LiveRefresh _live = LiveRefresh();

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
