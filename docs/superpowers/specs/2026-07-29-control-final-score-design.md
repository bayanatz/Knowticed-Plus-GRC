# Control Final Score — Design

> **Superseded** by [2026-07-29-score-rollup-design.md](2026-07-29-score-rollup-design.md) —
> the user decided not to defer the Policy/Module rollup after all. The Control-level
> write described below is still accurate but is now one step inside that larger design's
> `RecalculateScoreRollupUseCase`, not a standalone Cubit-level call. Kept for history.

## Context

`ControlEntity.score` (an `int`, Firestore key `Score`) has existed since the Control
model's initial schema but has never had a real value — there is no manual input field
for it anywhere in the Control create/edit forms, so every Control is created with
`score: 0` and it never changes. It is already displayed today (Control Details page's
score badge, the Control card in the Policy view) but always shows `0`.

This is the first step toward the full weighted score rollup (Module → Policy → Control
→ Department → Final Module Score) that was described when the My Audits feature was
designed, and deliberately deferred at the time — see
[My Audits design, "Open items carried to a future Dashboard spec"](2026-07-28-my-audits-design.md).
This spec covers only the **Control level**: turning `Control.score` from a permanently-0
placeholder into the real score the Control Owner assigned via My Audits. Department
weighting and the Policy/Module rollup stay deferred.

**Confirmed with the user:**
- Every Control currently has exactly one Champion (no multi-submission averaging
  needed at the Control level — that scenario doesn't exist in the data yet).
- The Control's score is written to Firestore immediately when the Control Owner
  submits a score (Add Score or Edit Score in My Audits) — not computed live on read.

## Design

**Where it's written:** `MyAuditCubit.submitScore` (`lib/features/grc/my_audit/presentation/controller/my_audit_cubit.dart`)
already calls `ApplyOwnerScoreUseCase` to write the score onto the linked
`Assignment_Controls` document. This adds one more step after that succeeds: call the
**already-existing** `UpdateControlUseCase` (`lib/features/grc/control/domain/use_cases/update_control_usecase.dart`)
with only `id`/`moduleId`/`policyId`/`editorId`/`score` set (every other field left
`null`, which `ControlRepositoryImpl.updateControl` already treats as "unchanged" —
confirmed by reading its implementation). No new repository method, no new Firestore
write path — this reuses the same update path the Control edit UI already uses.

**Type conversion:** `Assignment_Controls`/`My_Audit`'s `controlScore` is `double?`;
`ControlEntity.score` is `int`. Round with `.round()` when passing it to
`UpdateControlUseCase`.

**Failure handling:** matches the precedent already established when `ApprovalCubit.approve`
creates the linked My Audit doc — that call's `Either` result is not folded/checked; the
primary action's success does not depend on it. Same here: if the Control update fails,
`MyAuditActionSuccess` is still emitted (the My Audit + Assignment Control writes already
succeeded, which is what matters to the user in that flow) — this is a deliberate,
already-accepted pattern in this codebase, not an oversight.

**New parameter needed:** `MyAuditCubit.submitScore` doesn't currently take `policyId`
(only `moduleId`/`controlId`/`championEmail`/`ownerEmail`/`score`/`justification`), but
`UpdateControlUseCase` requires it. `MyAuditItem.control.policyId` already has it —
`my_audit_details_page.dart`'s `_onScorePressed` passes it through as a new required
argument.

**DI:** `UpdateControlUseCase` is already registered in `grc_get_it.dart`
(`sl<UpdateControlUseCase>()`); `MyAuditCubit`'s registration there gains one more
constructor argument.

**No other changes:** the existing score badges/displays (Control Details page, Control
card) already read `ControlEntity.score` — they start showing the real value
automatically once it's non-zero, no UI changes needed there.

## Error handling & testing

No behavior branches beyond a straight-line "update, ignore failure" — no new tests
needed beyond a compile-sanity check, matching how the rest of this feature has been
built (this session's execution mode skips writing new automated tests).
