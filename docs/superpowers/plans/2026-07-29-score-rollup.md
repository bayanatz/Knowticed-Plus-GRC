# Final Weighted Score Rollup (Control → Policy → Module) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Whenever a Control Owner submits or edits a score in My Audits, immediately
recompute and persist the Control's, its parent Policy's, and its parent Module's final
scores — turning `ControlEntity.score` (already declared, always 0 today) into a real
value, and adding a brand-new `score` field to `PolicyEntity`/`GRCModuleEntity`.

**Architecture:** Two Entity/Model pairs (`PolicyEntity`/`PolicyModel`,
`GRCModuleEntity`/`GRCModuleModel`) each gain one new `double score` history field,
threaded through their existing `updatePolicy`/`updateModule` repository methods and use
cases (`UpdatePolicyUseCase`, `UpdateGRCModuleUseCase`) — no new repository methods, no
new Firestore access code. A new domain-layer use case,
`RecalculateScoreRollupUseCase` (`lib/features/grc/shared/use_cases/`), is the only place
the Control→Policy→Module weighted-sum calculation happens; it is called once from
`MyAuditCubit.submitScore` after the existing Assignment-Control/My-Audit writes succeed.
See `docs/superpowers/specs/2026-07-29-score-rollup-design.md` for full rationale —
in particular: every Control currently has exactly one Champion (no cross-submission
averaging needed), department-level weighting stays explicitly out of scope, and the
rollup is best-effort (its failure never blocks the Control Owner's score submission
from succeeding).

**Tech Stack:** Flutter, flutter_bloc (Cubit), get_it (DI), cloud_firestore, dartz
(`Either<Failure, T>`).

## Global Constraints

- Follow `Code Quality Standards.md`: Clean Architecture layering, `Either<Failure, T>`
  from repositories, static Firestore key constants on models.
- New `score` fields follow the exact history-list pattern already used by every field
  on `PolicyModel`/`GRCModuleModel`: `List<double>`, index *i* = one revision,
  `copyWithUpdate` appends a new revision reusing the previous value when the parameter
  is left `null`.
- **Firestore keys:** `Policy_Score` on `PolicyModel`, `Module_Score` on
  `GRCModuleModel`. Existing documents predate these keys — `fromJson` must backfill a
  same-length `List<double>` of zeros when the key is absent, exactly like `PolicyModel`
  already does for its own `status` key on old documents.
- **Exclusion filters** (confirmed against already-existing code, do not invent new
  ones): Control→Policy rollup excludes only `ControlStatus.draft` (matches
  `ControlListWeightX.hasControlWeightIssue` in `control_entity.dart`). Policy→Module
  rollup keeps only `PolicyStatus.active`/`PolicyStatus.scheduled` (matches
  `weightScopedPolicies` in `grc_module_policies_tab.dart`).
- **No normalization:** weights are used as plain `/ 100` divisors. If a Policy's
  Controls (or a Module's Policies) don't actually sum to 100% weight, the rollup does
  not correct for it — that drift is what the existing Weight Issue features are for.
- **Trigger scope:** only `MyAuditCubit.submitScore` triggers a recalculation. Editing a
  Control's/Policy's weight elsewhere does NOT trigger one — that's an accepted,
  explicitly out-of-scope limitation of this pass.
- Use `puro flutter analyze`/`puro flutter test` (not bare `flutter`) — this machine's
  Flutter is at `/Users/bstar/.puro/bin/puro flutter`.

---

### Task 1: Add `score` to `PolicyEntity`/`PolicyModel` and thread through `updatePolicy`

**Files:**
- Modify: `lib/features/grc/policy/domain/entities/policy_entity.dart`
- Modify: `lib/features/grc/policy/data/models/policy_model.dart`
- Modify: `lib/features/grc/policy/domain/repository/policy_repository.dart`
- Modify: `lib/features/grc/policy/data/repository/policy_repository_impl.dart`
- Modify: `lib/features/grc/policy/domain/use_cases/update_policy_usecase.dart`

**Interfaces:**
- Consumes: nothing from other tasks.
- Produces: `PolicyEntity.score` (`double`, required), `PolicyModel.score`
  (`List<double>`), `UpdatePolicyParams.score`/`UpdatePolicyUseCase.call(...)` accepting
  a new optional `double? score`. Task 3 depends on `UpdatePolicyUseCase` accepting
  `score`; Task 3's tests depend on `PolicyEntity.score`/`PolicyEntity.policyWeight`/
  `PolicyEntity.status`.

- [ ] **Step 1: Add `score` to `PolicyEntity`**

Read `lib/features/grc/policy/domain/entities/policy_entity.dart` first. Add
`final double score;` right after `final PolicyStatus status;`, add `required this.score,`
to the constructor right after `required this.status,`, and add `double? score,` /
`score: score ?? this.score,` to `copyWith` right after the `status` parameter:

```dart
  // in the field list, right after `final PolicyStatus status;`
  final double score;
```

```dart
  // in the constructor, right after `required this.status,`
    required this.score,
```

```dart
  // in copyWith's parameter list, right after `PolicyStatus? status,`
    double? score,
```

```dart
  // in copyWith's returned PolicyEntity(...), right after `status: status ?? this.status,`
      score: score ?? this.score,
```

- [ ] **Step 2: Add `score` to `PolicyModel`**

Read `lib/features/grc/policy/data/models/policy_model.dart` first. Make these additions:

Firestore key constant, right after `static const String _keyPolicyStatus = 'Policy_Status';`:

```dart
  static const String _keyPolicyScore = 'Policy_Score';
```

Field, right after `final List<String> status; // PolicyStatus.value strings`:

```dart
  final List<double> score;
```

Raw constructor: add `required this.score,` right after `required this.status,`, and add
`score.length,` to the `_allSameLength()` set right after `status.length,`.

`PolicyModel.create(...)`: add a new **optional, defaulted** parameter (not required — so
the existing Policy-creation call site doesn't need to change), right after
`required PolicyStatus status,`:

```dart
    double score = 0,
```

and in the returned `PolicyModel(...)`, right after `status: [status.value],`:

```dart
      score: [score],
```

`copyWithUpdate(...)`: add `double? score,` right after `PolicyStatus? status,`, and in
the returned `PolicyModel(...)`, right after
`status: [...this.status, status?.value ?? this.status.last],`:

```dart
      score: [...this.score, score ?? this.score.last],
```

`toJson()`: add right after `_keyPolicyStatus: status,`:

```dart
      _keyPolicyScore: score,
```

`fromJson(...)`: add right after the `status:` block (which already backfills using
`editorsRaw.length` for documents written before that key existed — reuse the same
`editorsRaw` for this new key):

```dart
      score: json[_keyPolicyScore] != null
          ? (json[_keyPolicyScore] as List)
              .map((e) => (e as num).toDouble())
              .toList()
          : List<double>.filled(editorsRaw.length, 0),
```

`toEntity()`: add right after `status: _deriveStatus(...)`'s closing `),`:

```dart
      score: score.last,
```

- [ ] **Step 3: Thread `score` through `updatePolicy`**

Read `lib/features/grc/policy/domain/repository/policy_repository.dart` first. Add
`double? score,` to the `updatePolicy` method signature, right after `double? policyWeight,`.

Read `lib/features/grc/policy/data/repository/policy_repository_impl.dart` first. Add
`double? score,` to `updatePolicy`'s parameter list (same location as above), and add
`score: score,` to the `currentModel.copyWithUpdate(...)` call right after
`policyWeight: policyWeight,`.

Read `lib/features/grc/policy/domain/use_cases/update_policy_usecase.dart` first. Add
`final double? score;` to `UpdatePolicyParams` right after `final double? policyWeight;`,
add `this.score,` to its constructor right after `this.policyWeight,`, and add
`score: params.score,` to `UpdatePolicyUseCase.call`'s `_repository.updatePolicy(...)`
call right after `policyWeight: params.policyWeight,`.

- [ ] **Step 4: Verify it compiles**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/policy`
Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/policy/domain/entities/policy_entity.dart \
        lib/features/grc/policy/data/models/policy_model.dart \
        lib/features/grc/policy/domain/repository/policy_repository.dart \
        lib/features/grc/policy/data/repository/policy_repository_impl.dart \
        lib/features/grc/policy/domain/use_cases/update_policy_usecase.dart
git commit -m "feat(grc): add score field to Policy for the final score rollup"
```

---

### Task 2: Add `score` to `GRCModuleEntity`/`GRCModuleModel` and thread through `updateModule`

**Files:**
- Modify: `lib/features/grc/module/domain/entities/grc_module_entity.dart`
- Modify: `lib/features/grc/module/data/models/grc_module_model.dart`
- Modify: `lib/features/grc/module/domain/repository/grc_module_repository.dart`
- Modify: `lib/features/grc/module/data/repository/grc_module_repository_impl.dart`
- Modify: `lib/features/grc/module/domain/use_cases/update_grc_module_use_case.dart`

**Interfaces:**
- Consumes: nothing from other tasks.
- Produces: `GRCModuleEntity.score` (`double`, required), `GRCModuleModel.score`
  (`List<double>`), `UpdateGRCModuleUseCase.execute(...)` (note: this use case's method
  is named `execute`, not `call`) accepting a new optional `double? score`. Task 3
  depends on this.

- [ ] **Step 1: Add `score` to `GRCModuleEntity`**

Read `lib/features/grc/module/domain/entities/grc_module_entity.dart` first. Add
`final double score;` right after `final String status;` (before the "Tracking fields"
comment), add `required this.score,` to the constructor right after `required this.status,`,
and add `double? score,` / `score: score ?? this.score,` to `copyWith` right after the
`status` parameter (same pattern as Task 1 Step 1):

```dart
  // field list, right after `final String status;`
  final double score;
```

```dart
  // constructor, right after `required this.status,`
    required this.score,
```

```dart
  // copyWith's parameter list, right after `String? status,`
    double? score,
```

```dart
  // copyWith's returned GRCModuleEntity(...), right after `status: status ?? this.status,`
      score: score ?? this.score,
```

- [ ] **Step 2: Add `score` to `GRCModuleModel`**

Read `lib/features/grc/module/data/models/grc_module_model.dart` first. Make these
additions:

Firestore key constant, right after `static const String _keyStatus = 'Status';`:

```dart
  static const String _keyModuleScore = 'Module_Score';
```

Field, right after `final List<String> status;`:

```dart
  final List<double> score;
```

Raw constructor: add `required this.score,` right after `required this.status,`, and add
`score.length,` to the `_allSameLength()` set right after `status.length,`.

`GRCModuleModel.create(...)`: add a new **optional, defaulted** parameter, right after
`required String status,`:

```dart
    double score = 0,
```

and in the returned `GRCModuleModel(...)`, right after the `status: [...]` block's
closing `],`:

```dart
      score: [score],
```

`copyWithUpdate(...)`: add `double? score,` right after `String? status,`, and in the
returned `GRCModuleModel(...)`, right after the `status: [...]` block's closing `],`:

```dart
      score: [...this.score, score ?? this.score.last],
```

`toJson()`: add right after `_keyStatus: status,`:

```dart
      _keyModuleScore: score,
```

`fromJson(...)`: add right after the `status:` block (reuse the already-computed
`modifiersRaw` for the backfill length, same as `status`'s own backwards-compat
fallback):

```dart
      score: json[_keyModuleScore] != null
          ? (json[_keyModuleScore] as List)
              .map((e) => (e as num).toDouble())
              .toList()
          : List<double>.filled(modifiersRaw.length, 0),
```

`toEntity()`: add right after `status: _deriveStatus(...)`'s closing `),`:

```dart
      score: score.last,
```

- [ ] **Step 3: Thread `score` through `updateModule`**

Read `lib/features/grc/module/domain/repository/grc_module_repository.dart` first. Add
`String? status,` is already there — add `double? score,` right after it in
`updateModule`'s signature.

Read `lib/features/grc/module/data/repository/grc_module_repository_impl.dart` first.
Add `double? score,` to `updateModule`'s parameter list (same location), and add
`score: score,` to the `currentModel.copyWithUpdate(...)` call right after
`status: status,`.

Read `lib/features/grc/module/domain/use_cases/update_grc_module_use_case.dart` first.
Add `double? score,` to `execute`'s parameter list right after `String? status,`, and add
`score: score,` to its `_repository.updateModule(...)` call right after `status: status,`.

- [ ] **Step 4: Verify it compiles**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/module`
Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/module/domain/entities/grc_module_entity.dart \
        lib/features/grc/module/data/models/grc_module_model.dart \
        lib/features/grc/module/domain/repository/grc_module_repository.dart \
        lib/features/grc/module/data/repository/grc_module_repository_impl.dart \
        lib/features/grc/module/domain/use_cases/update_grc_module_use_case.dart
git commit -m "feat(grc): add score field to GRC Module for the final score rollup"
```

---

### Task 3: `RecalculateScoreRollupUseCase`

**Files:**
- Create: `lib/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart`
- Test: `test/features/grc/shared/recalculate_score_rollup_usecase_test.dart`

**Interfaces:**
- Consumes: `UpdateControlUseCase`/`UpdateControlParams` (existing,
  `lib/features/grc/control/domain/use_cases/update_control_usecase.dart`),
  `GetAllControlsUseCase` (existing,
  `lib/features/grc/control/domain/use_cases/get_control_usecases.dart`),
  `UpdatePolicyUseCase`/`UpdatePolicyParams` (Task 1),
  `GetAllPoliciesUseCase` (existing,
  `lib/features/grc/policy/domain/use_cases/get_policy_usecases.dart`),
  `UpdateGRCModuleUseCase` (Task 2).
- Produces: two pure top-level functions `computePolicyScore(List<ControlEntity>)` and
  `computeModuleScore(List<PolicyEntity>)`, plus `RecalculateScoreRollupUseCase.call({
  required moduleId, required policyId, required controlId, required controlScore,
  required editorEmail})` returning `Future<void>`. Task 4 depends on this exact
  class name and `call(...)` signature.

- [ ] **Step 1: Write the failing tests for the two pure formulas**

```dart
// test/features/grc/shared/recalculate_score_rollup_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart';

ControlEntity _control({
  required int score,
  required double weight,
  ControlStatus status = ControlStatus.active,
}) {
  final now = DateTime.now();
  return ControlEntity(
    id: 'c',
    policyId: 'p',
    controlsNameEn: 'c',
    controlsNameAr: 'c',
    controlsNumberEn: 'c',
    controlsNumberAr: 'c',
    controlsDescriptionEn: 'd',
    controlsDescriptionAr: 'd',
    controlsDocumentEn: null,
    controlsDocumentAr: null,
    controlsWeight: weight,
    frequency: 'Monthly',
    startDate: now,
    endDate: now,
    departments: const [],
    equalWeights: true,
    score: score,
    status: status,
    lastModifiedDate: now,
    lastEditor: 'editor@x.com',
  );
}

PolicyEntity _policy({
  required double score,
  required double weight,
  PolicyStatus status = PolicyStatus.active,
}) {
  final now = DateTime.now();
  return PolicyEntity(
    id: 'p',
    moduleId: 'm',
    policyImage: null,
    policyNameEn: 'p',
    policyNameAr: 'p',
    policyNumberEn: 'p',
    policyNumberAr: 'p',
    policyDescriptionEn: 'd',
    policyDescriptionAr: 'd',
    startDate: now,
    endDate: now,
    policyWeight: weight,
    policyDocumentEn: null,
    policyDocumentAr: null,
    status: status,
    score: score,
    lastModifiedDate: now,
    lastEditor: 'editor@x.com',
  );
}

void main() {
  group('computePolicyScore', () {
    test('matches the worked example from the design spec', () {
      final controls = [
        _control(score: 80, weight: 50),
        _control(score: 100, weight: 25),
        _control(score: 60, weight: 25),
      ];
      expect(computePolicyScore(controls), 80);
    });

    test('excludes Draft controls', () {
      final controls = [
        _control(score: 80, weight: 50),
        _control(score: 100, weight: 25),
        _control(score: 999, weight: 25, status: ControlStatus.draft),
      ];
      expect(computePolicyScore(controls), 40 + 25);
    });

    test('empty list yields 0', () {
      expect(computePolicyScore(const []), 0);
    });
  });

  group('computeModuleScore', () {
    test('matches the worked example from the design spec', () {
      final policies = [
        _policy(score: 80, weight: 25),
        _policy(score: 100, weight: 25),
        _policy(score: 60, weight: 50),
      ];
      expect(computeModuleScore(policies), 75);
    });

    test('excludes everything except Active/Scheduled', () {
      final policies = [
        _policy(score: 80, weight: 25),
        _policy(score: 100, weight: 25, status: PolicyStatus.scheduled),
        _policy(score: 999, weight: 50, status: PolicyStatus.draft),
      ];
      expect(computeModuleScore(policies), 20 + 25);
    });

    test('empty list yields 0', () {
      expect(computeModuleScore(const []), 0);
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `puro flutter test test/features/grc/shared/recalculate_score_rollup_usecase_test.dart`
Expected: FAIL — `recalculate_score_rollup_usecase.dart` doesn't exist yet.

- [ ] **Step 3: Write the use case**

```dart
// lib/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart
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
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `puro flutter test test/features/grc/shared/recalculate_score_rollup_usecase_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 5: Verify it compiles**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/shared`
Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart \
        test/features/grc/shared/recalculate_score_rollup_usecase_test.dart
git commit -m "feat(grc): add RecalculateScoreRollupUseCase"
```

---

### Task 4: Wire the rollup into `MyAuditCubit.submitScore`, DI, verify end-to-end

**Files:**
- Modify: `lib/features/grc/my_audit/presentation/controller/my_audit_cubit.dart`
- Modify: `lib/features/grc/my_audit/presentation/ui/pages/my_audit_details_page.dart`
- Modify: `lib/features/grc/grc_get_it.dart`

**Interfaces:**
- Consumes: `RecalculateScoreRollupUseCase` (Task 3).
- Produces: `MyAuditCubit.submitScore` gains a new required `policyId` parameter and
  calls the rollup after `ApplyOwnerScoreUseCase` succeeds. Nothing else depends on this
  (final task).

- [ ] **Step 1: Extend `MyAuditCubit`**

Read `lib/features/grc/my_audit/presentation/controller/my_audit_cubit.dart` first. Add
this import:

```dart
import 'package:demo_app/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart';
```

Add `required RecalculateScoreRollupUseCase recalculateScoreRollupUseCase` to the
constructor's parameter list and `_recalculateScoreRollupUseCase = recalculateScoreRollupUseCase,`
to its initializer list (alongside the existing `_applyOwnerScoreUseCase` field), and add
the corresponding field:

```dart
  final RecalculateScoreRollupUseCase _recalculateScoreRollupUseCase;
```

Replace the whole `submitScore` method with:

```dart
  Future<void> submitScore({
    required String moduleId,
    required String policyId,
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
        await acResult.fold(
          (failure) async => emit(MyAuditFailure(failure.message)),
          (_) async {
            await _recalculateScoreRollupUseCase.call(
              moduleId: moduleId,
              policyId: policyId,
              controlId: controlId,
              controlScore: score,
              editorEmail: ownerEmail,
            );
            emit(MyAuditActionSuccess(audit));
          },
        );
      },
    );
  }
```

(Every other method — `getMyAudits`, `approve`, `reject` — is unchanged.)

- [ ] **Step 2: Pass `policyId` from the details page**

Read `lib/features/grc/my_audit/presentation/ui/pages/my_audit_details_page.dart` first
(search for `cubit.submitScore(` inside `_onScorePressed`). Add one new argument,
`policyId: widget.item.control.policyId,`, right after `moduleId: widget.module.moduleId,`.

- [ ] **Step 3: Register `RecalculateScoreRollupUseCase` and update `MyAuditCubit`'s registration**

Read `lib/features/grc/grc_get_it.dart` first. Add this import near the other
`my_audit`/shared imports:

```dart
import 'package:demo_app/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart';
```

Add to the "3. Use Cases" section (anywhere after `ApplyOwnerScoreUseCase`,
`UpdatePolicyUseCase`, `GetAllPoliciesUseCase`, and `UpdateGRCModuleUseCase` are all
already registered above it — search for each to confirm, they predate this feature):

```dart
  /// class name: [RecalculateScoreRollupUseCase]
  /// purpose: recomputes and persists Control -> Policy -> Module scores
  /// after a Control Owner submits or edits a score in My Audits.
  sl.registerLazySingleton<RecalculateScoreRollupUseCase>(
    () => RecalculateScoreRollupUseCase(
      updateControlUseCase: sl<UpdateControlUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      updateGrcModuleUseCase: sl<UpdateGRCModuleUseCase>(),
    ),
  );
```

Update the existing `MyAuditCubit` registration (search for `MyAuditCubit(` in the
"4. Cubit (Presentation)" section) to add one more constructor argument:

```dart
      recalculateScoreRollupUseCase: sl<RecalculateScoreRollupUseCase>(),
```

(Add only this line inside the existing `MyAuditCubit(...)` call — do not duplicate the
other existing lines.)

- [ ] **Step 4: Verify it compiles**

Run: `/Users/bstar/.puro/bin/puro flutter analyze`
Expected: No new errors introduced by this feature (pre-existing unrelated issues
elsewhere in this large repo are out of scope).

- [ ] **Step 5: Run the full test suite**

Run: `puro flutter test`
Expected: All tests pass, including the 6 new `recalculate_score_rollup_usecase_test.dart`
tests from Task 3, plus every pre-existing test (unaffected, since none of them construct
`MyAuditCubit`/`PolicyEntity`/`GRCModuleEntity` in a way this plan's additive-only
signature changes would break — `score` is either a new optional parameter or, on the two
Entities, a new required one whose only construction sites are each model's own
`toEntity()`, confirmed by this plan's research to have no other direct callers).

- [ ] **Step 6: Manual smoke test**

1. As a Control Owner, open My Audits → Add Score (or Edit Score) on an Outstanding/Scored
   item, submit a score.
2. In Firestore, confirm `Assignment_Controls` and `My_Audit` updated as before (no
   regression), AND confirm the Control's own document under
   `GRC Modules/{moduleId}/Policies/{policyId}/Controls/{controlId}` now has a
   `Controls_Score` value matching the rounded submitted score.
3. Confirm the parent Policy document (`GRC Modules/{moduleId}/Policies/{policyId}`) now
   has a `Policy_Score` field, and that its value equals
   Σ(non-Draft control.score × control.controlsWeight / 100) across every Control under
   that Policy.
4. Confirm the Module document (`GRC Modules/{moduleId}`) now has a `Module_Score` field
   equal to Σ(Active/Scheduled policy.score × policy.policyWeight / 100) across every
   Policy under that Module.
5. Submit a second score for a different Control under the same Policy, and confirm both
   the Policy's and Module's scores update again to reflect the new total.

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/my_audit/presentation/controller/my_audit_cubit.dart \
        lib/features/grc/my_audit/presentation/ui/pages/my_audit_details_page.dart \
        lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): trigger the score rollup from MyAuditCubit.submitScore"
```
