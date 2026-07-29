# Final Weighted Score Rollup (Control → Policy → Module) — Design

> **Amendment (2026-07-29, after first real-world test):** the formulas below in "The
> rollup itself" were corrected. Originally `Policy.score` was a standalone 0-100 grade
> of the Policy's own Controls (independent of the Policy's own weight within its
> Module), and the Policy→Module weight multiplication happened only at the Module step.
> Testing with a real Module (1 Policy at 30% weight, 1 Control at 100% weight, scored
> 80) showed this produces a confusing `Policy.score` of 80 when the user expected 24
> (`80 × 30%`). The corrected design bakes the Policy's own weight into `Policy.score`
> itself — `Policy.score` now means "how many of this Policy's weight-share points were
> earned," bounded to `[0, policyWeight]` rather than `[0, 100]` — and `computeModuleScore`
> becomes a straight sum of already-weighted Policy scores (no second multiplication).
> The Module's final number is identical either way; only what `Policy.score` itself
> displays changed. See the corrected formulas below.

## Context

This supersedes [2026-07-29-control-final-score-design.md](2026-07-29-control-final-score-design.md).
The weighted score rollup (Module → Policy → Control) was explicitly deferred when My
Audits was designed — see
[My Audits design, "Open items carried to a future Dashboard spec"](2026-07-28-my-audits-design.md).
The user has now decided to build it, using the hierarchical formula given when My Audits
was first specced:

```
Module
    ↓
Policy Weight
    ↓
Control Weight
    ↓
Control Owner Score
    ↓
Final Module Score
```

**Confirmed scope for this pass:** Control → Policy → Module only. Department-level
weighting (the "Level 3 — Department Weight" tier from the original algorithm) stays out
of scope — every Control currently has exactly one Champion/submission, so there is
nothing to split by department yet.

## Current gaps (confirmed by reading the code)

- `ControlEntity`/`ControlModel` already have a `score` field (`int`, Firestore key
  `Controls_Score`) — created as `0` and never updated by anything today.
- `PolicyEntity`/`PolicyModel` have **no score field at all**.
- `GRCModuleEntity`/`GRCModuleModel` have **no score field at all** — the "Compliance
  Score" shown in the module UI today is a hardcoded `'-'` placeholder, not backed by
  data.
- `UpdateControlUseCase`, `UpdatePolicyUseCase`, and `UpdateGRCModuleUseCase` (note: this
  one's method is `execute()`, not `call()`) already exist and already support "change
  only the fields you pass, leave everything else alone" partial updates — this rollup
  reuses all three untouched except for adding one new parameter to the latter two.

## Model changes

**`PolicyEntity`** (`lib/features/grc/policy/domain/entities/policy_entity.dart`): add
`final double score;` (required constructor param, like every other Entity field).

**`PolicyModel`** (`lib/features/grc/policy/data/models/policy_model.dart`): add
`final List<double> score;`, new key `static const String _keyPolicyScore = 'Policy_Score';`.
Threaded through:
- `PolicyModel(...)` raw constructor: `required this.score`, added to `_allSameLength()`.
- `PolicyModel.create(...)`: new **optional** `double score = 0` param (default, not
  required — so the existing Policy-creation call site in `policy_cubit.dart` doesn't
  need to change) → `score: [score]`.
- `copyWithUpdate(...)`: new optional `double? score` → `score: [...this.score, score ?? this.score.last]`.
- `toJson()`: `_keyPolicyScore: score`.
- `fromJson(...)`: `score: (json[_keyPolicyScore] as List? ?? []).map((e) => (e as num).toDouble()).toList()`
  — but existing documents won't have this key yet, so this needs the same
  length-backfill trick `status` already uses for old documents
  (`List<double>.filled(editorsRaw.length, 0)` when the key is absent), otherwise
  `_allSameLength()` throws on every pre-existing Policy document.
- `toEntity()`: `score: score.last`.

**`GRCModuleEntity`** (`lib/features/grc/module/domain/entities/grc_module_entity.dart`):
add `final double score;` (required constructor param).

**`GRCModuleModel`** (`lib/features/grc/module/data/models/grc_module_model.dart`): add
`final List<double> score;`, new key `static const String _keyModuleScore = 'Module_Score';`.
Same threading as Policy: optional `double score = 0` default in `create()`, optional
`double? score` in `copyWithUpdate()`, `toJson`/`fromJson` (same old-document backfill
concern as Policy — `modifiersRaw.length` is already used as the backfill-length
reference for `status`, reuse it for `score` too), `toEntity()`.

**`ControlEntity`/`ControlModel`**: no changes — the existing `int score` field is exactly
what this rollup writes to via the already-existing `UpdateControlUseCase`. The Control
Owner's raw 0–100 score is rounded (`.round()`) when passed in, since `Assignment_Controls`/
`My_Audit`'s `controlScore` is `double?` but `Control.score` is `int`.

## Repository / use case changes

**`PolicyRepository.updatePolicy` / `PolicyRepositoryImpl.updatePolicy` / `UpdatePolicyParams` / `UpdatePolicyUseCase`**:
add one new optional parameter, `double? score`, threaded straight through to
`currentModel.copyWithUpdate(score: score, ...)`. Nothing else in that method changes.

**`GRCModuleRepository.updateModule` / `GRCModuleRepositoryImpl.updateModule` / `UpdateGRCModuleUseCase.execute`**:
same — one new optional `double? score` parameter threaded through to `copyWithUpdate`.

**`UpdateControlUseCase`**: unchanged — it already accepts `int? score`.

## The rollup itself: `RecalculateScoreRollupUseCase`

New file: `lib/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart`. This
is the "domain-layer service" the user asked for — it is the only place this
calculation happens, and it is not a Cubit. It depends only on already-existing
repositories/use cases (`UpdateControlUseCase`, `GetAllControlsUseCase`,
`GetPolicyUseCase`, `UpdatePolicyUseCase`, `GetAllPoliciesUseCase`,
`UpdateGRCModuleUseCase`) — no new Firestore access code anywhere.

```
call({moduleId, policyId, controlId, controlScore, editorEmail}):
  1. UpdateControlUseCase(id: controlId, moduleId, policyId, editorId: editorEmail,
     score: controlScore.round())
     — persists the raw Control Owner score onto Control.score, unweighted.

  2. GetAllControlsUseCase(moduleId, policyId) -> all Controls under this Policy.
     Exclude everything except ControlStatus.active/scheduled/unassigned (matches
     the existing hasControlWeightIssue/totalControlWeight convention in
     control_entity.dart's ControlListWeightX).
     controlsGrade = Σ(control.score × control.controlsWeight / 100)
     — the Policy's own 0-100 grade from its Controls.

     GetPolicyUseCase(policyId, moduleId) -> the Policy's current policyWeight (its
     share of the Module).
     newPolicyScore = controlsGrade × policyWeight / 100
     — bounded to [0, policyWeight], not [0, 100]: this is "how many of this
     Policy's weight-share points were earned."
     UpdatePolicyUseCase(id: policyId, moduleId, editorId: editorEmail, score: newPolicyScore)

  3. GetAllPoliciesUseCase(moduleId) -> all Policies under this Module.
     Keep only PolicyStatus.active or PolicyStatus.scheduled (matches the existing
     weightScopedPolicies filter in grc_module_policies_tab.dart).
     newModuleScore = Σ(policy.score)
     — a straight sum: each Policy's score is already its own weighted share (step
     2), so no further multiplication by policyWeight happens here.
     UpdateGRCModuleUseCase.execute(id: moduleId, editorId: editorEmail, score: newModuleScore)
```

Worked example (the scenario that caught the original bug): 1 Module, 1 Policy at 30%
weight, 1 Control at 100% weight, scored 80. `controlsGrade` = 80 × 100/100 = 80.
`newPolicyScore` = 80 × 30/100 = **24**. `newModuleScore` = Σ(24) = **24**. Both numbers
now match what the user expects to see in Firestore.

Weight is used as a plain percentage divisor (`/ 100`) at each step — no normalization is
applied if a Policy's Controls (or a Module's Policies) don't actually sum to 100% weight
(that drift is what the existing "Policy Weight Issue"/"Control Weight Issue" features
are for; this rollup does not second-guess or correct it).

Every step reads fresh data right before computing (no cached/incremental values), so a
recalculation always reflects the current state of every sibling Control/Policy — this
satisfies "do not calculate on every read" (nothing here runs on a read path) while still
always producing a currently-correct value on write.

**Failure handling:** every step's `Either` result is unwrapped with a safe fallback
(e.g. an empty list on a failed fetch) rather than short-circuiting the whole call — this
mirrors the already-established pattern where `ApprovalCubit.approve`'s
`CreateOrUpdatePendingMyAuditUseCase` call isn't folded/checked either. The method returns
`Future<void>`; its caller does not gate success on it.

## Trigger point

`MyAuditCubit.submitScore` (`lib/features/grc/my_audit/presentation/controller/my_audit_cubit.dart`)
gains one more step, after `ApplyOwnerScoreUseCase` succeeds and before emitting
`MyAuditActionSuccess`:

```
Save Assignment Control (ApplyOwnerScoreUseCase, existing)
↓
Save My Audit (ApplyMyAuditScoreUseCase, existing — already runs first today)
↓
RecalculateScoreRollupUseCase.call(...)   ← new
↓
emit MyAuditActionSuccess (existing)
```

`submitScore` doesn't currently take `policyId` (only `moduleId`/`controlId`/
`championEmail`/`ownerEmail`/`score`/`justification`) — `MyAuditItem.control.policyId`
already has it, so `my_audit_details_page.dart`'s `_onScorePressed` passes it through as
one new required argument, same as the earlier (superseded) spec planned.

If `RecalculateScoreRollupUseCase` fails partway, `MyAuditActionSuccess` is still emitted —
same best-effort precedent as the Control-only spec this replaces.

**Not in scope:** editing a Control's or Policy's *weight* (in the Control/Policy edit
forms, or the Policy/Control Weight Issue features) does not trigger a recalculation.
Only submitting/editing a Control Owner score does, per the user's stated trigger. A
weight edit leaving stale Policy/Module scores until the next score submission is an
accepted limitation of this pass, not a bug to fix here.

## DI

- `RecalculateScoreRollupUseCase` registered in `grc_get_it.dart`, built from the
  already-registered `UpdateControlUseCase`/`GetAllControlsUseCase`/`UpdatePolicyUseCase`/
  `GetAllPoliciesUseCase`/`UpdateGRCModuleUseCase`.
- `MyAuditCubit`'s registration gains one more constructor argument.

## UI

No new UI. `ControlEntity.score`, once non-zero, already shows on the existing Control
score badges. `PolicyEntity.score`/`GRCModuleEntity.score` are new fields with no display
surface yet — wiring them into the Policy/Module UI (replacing the hardcoded `'-'`
Compliance Score placeholder) is explicitly left for a future pass, since the user's
request here is scoped to calculating and persisting the values, not displaying them.

## Error handling & testing

Pure, mock-free unit tests are worth writing for the actual arithmetic (the
weighted-sum formulas and the Draft/Active-Scheduled exclusion filters) since that's the
one genuinely new piece of business logic here — everything else (model field threading,
repository/use-case parameter passing) mirrors already-built, already-working code. Per
this session's established execution mode, whether those tests actually get written is
an execution-time choice, not a design constraint.
