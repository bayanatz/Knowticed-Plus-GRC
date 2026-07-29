/// Module: GRC — Final Score Rollup
/// Description: Recomputes and persists Control -> Policy -> Module scores
///              after a Control Owner submits or edits a score in My Audits.
///              See docs/superpowers/specs/2026-07-29-score-rollup-design.md.
///              This is the only place this calculation happens — it is a
///              plain domain-layer class, not a Cubit, and depends only on
///              already-existing repositories/use cases (no new Firestore
///              access code). Best-effort: every step's Either result is
///              unwrapped with a safe fallback rather than short-circuiting,
///              matching the existing precedent where ApprovalCubit's
///              linked-My-Audit creation isn't folded/checked either — the
///              caller's own success does not depend on this succeeding.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-29
library;

import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/update_grc_module_use_case.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/update_policy_usecase.dart';

/// Weighted sum of every non-Draft Control's score under one Policy —
/// Σ(control.score × control.controlsWeight / 100). Matches the existing
/// Draft-exclusion convention in control_entity.dart's
/// ControlListWeightX.hasControlWeightIssue.
double computePolicyScore(List<ControlEntity> controls) {
  return controls
      .where((c) => c.status != ControlStatus.draft)
      .fold<double>(0, (sum, c) => sum + c.score * c.controlsWeight / 100);
}

/// Weighted sum of every Active/Scheduled Policy's score under one Module —
/// Σ(policy.score × policy.policyWeight / 100). Matches the existing
/// weightScopedPolicies filter in grc_module_policies_tab.dart.
double computeModuleScore(List<PolicyEntity> policies) {
  return policies
      .where((p) =>
          p.status == PolicyStatus.active || p.status == PolicyStatus.scheduled)
      .fold<double>(0, (sum, p) => sum + p.score * p.policyWeight / 100);
}

class RecalculateScoreRollupUseCase {
  const RecalculateScoreRollupUseCase({
    required UpdateControlUseCase updateControlUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required UpdateGRCModuleUseCase updateGrcModuleUseCase,
  })  : _updateControlUseCase = updateControlUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _updatePolicyUseCase = updatePolicyUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _updateGrcModuleUseCase = updateGrcModuleUseCase;

  final UpdateControlUseCase _updateControlUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final UpdatePolicyUseCase _updatePolicyUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final UpdateGRCModuleUseCase _updateGrcModuleUseCase;

  Future<void> call({
    required String moduleId,
    required String policyId,
    required String controlId,
    required double controlScore,
    required String editorEmail,
  }) async {
    await _updateControlUseCase.call(
      UpdateControlParams(
        id: controlId,
        moduleId: moduleId,
        policyId: policyId,
        editorId: editorEmail,
        score: controlScore.round(),
      ),
    );

    final controlsResult = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    final controls = controlsResult.fold((_) => <ControlEntity>[], (c) => c);
    final newPolicyScore = computePolicyScore(controls);

    await _updatePolicyUseCase.call(
      UpdatePolicyParams(
        id: policyId,
        moduleId: moduleId,
        editorId: editorEmail,
        score: newPolicyScore,
      ),
    );

    final policiesResult =
        await _getAllPoliciesUseCase.call(moduleId: moduleId);
    final policies = policiesResult.fold((_) => <PolicyEntity>[], (p) => p);
    final newModuleScore = computeModuleScore(policies);

    await _updateGrcModuleUseCase.execute(
      id: moduleId,
      editorId: editorEmail,
      score: newModuleScore,
    );
  }
}
