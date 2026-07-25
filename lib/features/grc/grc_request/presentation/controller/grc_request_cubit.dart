/// Module: GRC Request Management
/// Description: BLoC Cubit that manages GRC Request state for the
///              presentation layer, mirroring ChampionCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, use cases, GrcRequestEntity

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/approve_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/reject_grc_request_usecase.dart';
import 'package:get/get.dart';

part 'grc_request_state.dart';

class GrcRequestCubit extends Cubit<GrcRequestState> {
  GrcRequestCubit({
    required CreateGrcRequestUseCase createGrcRequestUseCase,
    required GetGrcRequestsUseCase getGrcRequestsUseCase,
    required ApproveGrcRequestUseCase approveGrcRequestUseCase,
    required RejectGrcRequestUseCase rejectGrcRequestUseCase,
  })  : _createUseCase = createGrcRequestUseCase,
        _getAllUseCase = getGrcRequestsUseCase,
        _approveUseCase = approveGrcRequestUseCase,
        _rejectUseCase = rejectGrcRequestUseCase,
        super(GrcRequestInitial());

  final CreateGrcRequestUseCase _createUseCase;
  final GetGrcRequestsUseCase _getAllUseCase;
  final ApproveGrcRequestUseCase _approveUseCase;
  final RejectGrcRequestUseCase _rejectUseCase;

  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  Future<void> getRequestsForModule(String moduleId) async {
    emit(GrcRequestLoading());
    final result = await _getAllUseCase.call(moduleId);
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (requests) => emit(GrcRequestListLoaded(requests)),
    );
  }

  Future<void> createRequest(CreateGrcRequestParams params) async {
    emit(GrcRequestLoading());
    final result = await _createUseCase.call(params);
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) => emit(GrcRequestActionSuccess(request)),
    );
  }

  Future<void> approveRequest({
    required String moduleId,
    required String requestId,
  }) async {
    emit(GrcRequestLoading());
    final result = await _approveUseCase.call(
      ApproveGrcRequestParams(
        moduleId: moduleId,
        requestId: requestId,
        decidedBy: _currentUserEmail,
      ),
    );
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) => emit(GrcRequestActionSuccess(request)),
    );
  }

  Future<void> rejectRequest({
    required String moduleId,
    required String requestId,
    required String reason,
  }) async {
    emit(GrcRequestLoading());
    final result = await _rejectUseCase.call(
      RejectGrcRequestParams(
        moduleId: moduleId,
        requestId: requestId,
        decidedBy: _currentUserEmail,
        reason: reason,
      ),
    );
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) => emit(GrcRequestActionSuccess(request)),
    );
  }
}
