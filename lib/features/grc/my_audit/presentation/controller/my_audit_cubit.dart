// lib/features/grc/my_audit/presentation/controller/my_audit_cubit.dart
/// Module: My Audits (Control Owner)
/// Description: BLoC Cubit that manages the Owner's My Audits list and
///              Approve/Reject/Score actions, mirroring ApprovalCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/apply_owner_score_usecase.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_entity.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_item.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_resolver.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_status.dart';
import 'package:demo_app/features/grc/my_audit/domain/use_cases/apply_my_audit_score_usecase.dart';
import 'package:demo_app/features/grc/my_audit/domain/use_cases/decide_my_audit_usecase.dart';
import 'package:demo_app/features/grc/my_audit/domain/use_cases/get_all_my_audits_usecase.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';

part 'my_audit_state.dart';

class MyAuditCubit extends Cubit<MyAuditState> {
  MyAuditCubit({
    required GetAllMyAuditsUseCase getAllMyAuditsUseCase,
    required GetAssignmentControlByIdUseCase getAssignmentControlByIdUseCase,
    required GetOwnerUseCase getOwnerUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required DecideMyAuditUseCase decideMyAuditUseCase,
    required ApplyMyAuditScoreUseCase applyMyAuditScoreUseCase,
    required ApplyManagerDecisionUseCase applyManagerDecisionUseCase,
    required ApplyOwnerScoreUseCase applyOwnerScoreUseCase,
  })  : _getAllMyAuditsUseCase = getAllMyAuditsUseCase,
        _getAssignmentControlByIdUseCase = getAssignmentControlByIdUseCase,
        _getOwnerUseCase = getOwnerUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _decideMyAuditUseCase = decideMyAuditUseCase,
        _applyMyAuditScoreUseCase = applyMyAuditScoreUseCase,
        _applyManagerDecisionUseCase = applyManagerDecisionUseCase,
        _applyOwnerScoreUseCase = applyOwnerScoreUseCase,
        super(MyAuditInitial());

  final GetAllMyAuditsUseCase _getAllMyAuditsUseCase;
  final GetAssignmentControlByIdUseCase _getAssignmentControlByIdUseCase;
  final GetOwnerUseCase _getOwnerUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final DecideMyAuditUseCase _decideMyAuditUseCase;
  final ApplyMyAuditScoreUseCase _applyMyAuditScoreUseCase;
  final ApplyManagerDecisionUseCase _applyManagerDecisionUseCase;
  final ApplyOwnerScoreUseCase _applyOwnerScoreUseCase;

  /// Loads every My_Audit whose linked Assignment Control's `controlOwner`
  /// is [ownerEmail], plus a derived Overdue row for each of this Owner's
  /// assigned controls (via OwnerModel) that has no submission at all past
  /// its deadline. Resolves each surviving row's Control/Policy for display.
  Future<void> getMyAudits({
    required String moduleId,
    required String ownerEmail,
  }) async {
    emit(MyAuditLoading());
    final auditsResult = await _getAllMyAuditsUseCase.call(moduleId: moduleId);

    await auditsResult.fold(
      (failure) async => emit(MyAuditFailure(failure.message)),
      (audits) async {
        final assignmentControls = <String, AssignmentControlEntity>{};
        for (final audit in audits) {
          final result = await _getAssignmentControlByIdUseCase.call(
            moduleId: moduleId,
            id: audit.submissionId,
          );
          result.fold(
            (_) {},
            (assignmentControl) {
              if (assignmentControl != null) {
                assignmentControls[audit.submissionId] = assignmentControl;
              }
            },
          );
        }

        final ownerResult = await _getOwnerUseCase.call(ownerEmail, moduleId: moduleId);
        final ownerAssigningControls = ownerResult.fold(
          (_) => const <AssigningControlEntity>[],
          (owner) => owner.assigningControls,
        );

        final policyIds = <String>{
          for (final ac in assignmentControls.values)
            if (ac.controlOwner == ownerEmail) ac.policyId,
          for (final ac in ownerAssigningControls) ac.policyId,
        };

        final policyControls = <String, List<ControlEntity>>{};
        for (final policyId in policyIds) {
          final controlsResult = await _getAllControlsUseCase.call(
            moduleId: moduleId,
            policyId: policyId,
          );
          controlsResult.fold(
            (_) {},
            (controls) => policyControls[policyId] = controls,
          );
        }

        final policiesResult = await _getAllPoliciesUseCase.call(moduleId: moduleId);
        final policies = <String, PolicyEntity>{
          for (final p in policiesResult.fold((_) => <PolicyEntity>[], (p) => p))
            p.id: p,
        };

        emit(MyAuditListLoaded(
          buildMyAuditItems(
            audits: audits,
            assignmentControls: assignmentControls,
            ownerAssigningControls: ownerAssigningControls,
            policyControls: policyControls,
            policies: policies,
            ownerEmail: ownerEmail,
          ),
        ));
      },
    );
  }

  /// Pending -> Outstanding. Assignment Controls stays In review (no score yet).
  Future<void> approve({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String ownerEmail,
  }) async {
    emit(MyAuditLoading());
    final result = await _decideMyAuditUseCase.call(
      DecideMyAuditParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        status: MyAuditStatus.outstanding.value,
        editorEmail: ownerEmail,
      ),
    );
    result.fold(
      (failure) => emit(MyAuditFailure(failure.message)),
      (audit) => emit(MyAuditActionSuccess(audit)),
    );
  }

  /// Pending -> Rejected, and Assignment Controls -> Rejected (back to Champion).
  Future<void> reject({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String ownerEmail,
    required String reason,
  }) async {
    emit(MyAuditLoading());
    final result = await _decideMyAuditUseCase.call(
      DecideMyAuditParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        status: MyAuditStatus.rejected.value,
        reasonOfRejection: reason,
        editorEmail: ownerEmail,
      ),
    );

    await result.fold(
      (failure) async => emit(MyAuditFailure(failure.message)),
      (audit) async {
        final acResult = await _applyManagerDecisionUseCase.call(
          ApplyManagerDecisionParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            newStatus: AssignmentControlStatus.rejected,
            rejectionReason: reason,
            editorEmail: ownerEmail,
          ),
        );
        acResult.fold(
          (failure) => emit(MyAuditFailure(failure.message)),
          (_) => emit(MyAuditActionSuccess(audit)),
        );
      },
    );
  }

  /// (Outstanding or Scored) -> Scored, and Assignment Controls -> Approved
  /// (the terminal state of the whole workflow).
  Future<void> submitScore({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String ownerEmail,
    required double score,
    String? justification,
  }) async {
    emit(MyAuditLoading());
    final result = await _applyMyAuditScoreUseCase.call(
      ApplyMyAuditScoreParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        score: score,
        justification: justification,
        editorEmail: ownerEmail,
      ),
    );

    await result.fold(
      (failure) async => emit(MyAuditFailure(failure.message)),
      (audit) async {
        final acResult = await _applyOwnerScoreUseCase.call(
          ApplyOwnerScoreParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            score: score,
            justification: justification,
            editorEmail: ownerEmail,
          ),
        );
        acResult.fold(
          (failure) => emit(MyAuditFailure(failure.message)),
          (_) => emit(MyAuditActionSuccess(audit)),
        );
      },
    );
  }
}
