# My Audit Submission History — design

Date: 2026-07-29

## Problem

`MyAuditDetailsPage`'s "Submission" sub-tab (`my_audit_details_page.dart:413-514`)
only shows the *current* `AssignmentControlEntity` values — one file, one
note, and (if the item is currently in the Rejected tab) the latest
rejection reason. If a Control Champion has been rejected and resubmitted
before, the Control Owner has no way to see what was submitted the first
time, why it was rejected, or to compare the old file against the new one
— that data is silently overwritten from the UI's point of view even
though it still exists in Firestore.

`AssignmentControlModel` already stores every revision as parallel Lists
(`submissionDocument`, `submissionNote`, `status`, `modificationDate`,
`departmentManagerRejectionReasons`, ...) — the exact same
history-list convention `ControlModel`/`PolicyModel`/`GRCModuleModel` use
for their own `toWeightHistory()`/`toOwnerHistory()` derivations. No new
Firestore fields or collections are needed; this is a read-only
derivation + UI feature.

## Scope decisions (confirmed)

- **Inline in the existing Submission tab, not a separate page.** The
  current single card becomes a vertical stack of cards (one per distinct
  file submitted), inside the same scrolling `ListView` that already
  hosts the rest of the page. No new route/page.
- **Grouped by file, not by raw revision.** A resubmission appends a new
  revision to every list; a Reject also appends a new revision but
  reuses the *same* `submissionDocument` value (confirmed by reading
  `AssignmentControlRepositoryImpl.applyManagerDecision`, which calls
  `copyWithUpdate(status: ..., departmentManagerRejectionReason: ...)`
  without passing `submissionDocument`, so `copyWithUpdate` carries the
  previous document/note forward — see `assignment_control_model.dart:154-161`).
  So for `[Submitted(A), Rejected(A), Submitted(B)]` the list must show
  **2 cards** (file A — Rejected, with reason; file B — Submitted), not 3.
  A new card only starts when `submissionDocument` actually changes value
  (or at index 0); the card's status/rejection reason are read from the
  **last** revision in that file's run (i.e. whatever the file's
  outcome ended up being before the next file replaced it).
- **Newest file first.** Most recent submission card on top.
- **Rejection reason field: read `departmentManagerRejectionReasons` as-is,
  no write-path change.** `AssignmentControlModel` has a
  `controlOwnerRejectionReasons` field that reads as the "correct" name
  for this actor, but `MyAuditCubit.reject` → `ApplyManagerDecisionUseCase`
  actually writes the Control Owner's rejection reason into
  `departmentManagerRejectionReasons` (confirmed in
  `assignment_control_repository_impl.dart:80-84`) — `controlOwnerRejectionReasons`
  is never populated by any current call path. This spec explicitly reads
  from the field that is actually written, and does not touch the write
  path — fixing that naming mismatch is out of scope here.
- **Every card gets a status pill** (`GrcStatusPill`, same widget already
  used elsewhere), not just one pill below the whole list. New
  `AssignmentControlStatusStyle.of(AssignmentControlStatus)` mapper
  (submitted → `AppColors.warning`/upload icon, rejected →
  `Colors.red`/block icon, approved → `Colors.green`/check icon), mirroring
  the existing `ApprovalStatusStyle`/`MyAuditTabStyle` convention — there is
  no existing status→style mapper keyed directly on `AssignmentControlStatus`
  today, every existing one is keyed on a page-specific Tab enum instead.
- **Approve/Reject buttons unchanged** — they stay below the whole list and
  keep operating on the item's overall latest state, not on a specific card.

## Data model

No Firestore schema changes. Everything is derived from the existing
`AssignmentControlModel` document (`GRC Modules/{Module_ID}/Assignment
Controls/{controlId}_{championEmail}`), which already guarantees all its
Lists are the same length (`_allSameLength()`,
`assignment_control_model.dart:83-96`).

### Algorithm: `AssignmentControlModel.toSubmissionHistory()`

Returns `List<SubmissionHistoryEntry>`, newest-first:

1. Walk indices `0..submissionDocument.length-1`. Start a new "run"
   whenever `submissionDocument[i] != submissionDocument[i-1]` (or
   `i == 0`).
2. For each run `[start, end]` (same document value throughout):
   - `document` / `note` / `submittedDate` = `submissionDocument[start]` /
     `submissionNote[start]` / `modificationDate[start]` (when this file
     first appeared).
   - `status` = `AssignmentControlStatus.fromString(status[end])` (the
     file's final outcome before being replaced, or its current status if
     it's the last run).
   - `rejectionReason` = `departmentManagerRejectionReasons[end]` (only
     meaningful when `status == rejected`).
3. Reverse the resulting list (newest run first) before returning.

This exactly mirrors the shape of `ControlModel.toWeightHistory()` /
`GRCModuleModel.toOwnerHistory()` (a pure-Dart diff over parallel Lists,
no Firebase calls), just keyed on "did the document value change"
instead of "did an owner-email set change".

## New/changed pieces

### Domain
- **`lib/features/grc/assignment_control/domain/entities/submission_history_entry.dart`**
  (new): `SubmissionHistoryEntry` — fields `document` (String), `note`
  (String), `submittedDate` (DateTime), `status`
  (`AssignmentControlStatus`), `rejectionReason` (String?).
- **`assignment_control_model.dart`** (modify): add
  `toSubmissionHistory()` per the algorithm above.
- **`assignment_control_repository.dart`** (modify): add
  `Future<Either<Failure, List<SubmissionHistoryEntry>>>
  getSubmissionHistory({required String moduleId, required String
  controlId, required String championEmail});` — following the
  `getControlWeightHistory` precedent of returning derived entries
  directly, never the raw model (avoids importing the data-layer model
  into the domain-layer repository interface).
- **`assignment_control_repository_impl.dart`** (modify): implement via
  `_dataSource.get(_docId(...), moduleId: moduleId)?.toSubmissionHistory()
  ?? []`, wrapped in try/catch like every other method here.
- **`lib/features/grc/assignment_control/domain/use_cases/get_submission_history_usecase.dart`**
  (new): thin pass-through, same shape as `GetAssignmentControlByIdUseCase`
  — `call({required moduleId, required controlId, required championEmail})`.

### Presentation
- **`AssignmentControlStatusStyle`** (new, small class — lives alongside
  `AssignmentControlStatus` in
  `assignment_control_status.dart` or as its own file, matching where
  `ApprovalStatusStyle` lives relative to `ApprovalStatus`): `.of(status)`
  → `{color, icon}` for submitted/rejected/approved (pending/overdue never
  appear in stored history, per the enum's own doc comment).
- **`MyAuditCubit`** (modify): add a `GetSubmissionHistoryUseCase`
  dependency and a method (e.g. `loadSubmissionHistory({required
  moduleId, required controlId, required championEmail})`) plus a new
  state case (e.g. `MyAuditSubmissionHistoryLoaded(List<SubmissionHistoryEntry>
  entries)`) alongside the existing `MyAuditListLoaded`/`MyAuditActionSuccess`/etc.
  in `my_audit_state.dart`. Exact state shape (separate state vs. a field
  added to a loaded-details state) to be finalized during planning —
  whichever fits the existing Cubit's state machine with least
  disruption to the approve/reject/score flows already wired through
  `BlocConsumer` in `my_audit_details_page.dart`.
- **`my_audit_details_page.dart`** (modify): trigger the history load once
  when the page opens (e.g. `initState`), show a loading placeholder
  (reusing `GrcButtonLoadingPlaceholder`-style skeleton) under
  `GrcSectionSubTabs` while it loads, then replace the current single
  `GrcSectionCard` submission block with a `Column` of one `GrcSectionCard`
  per `SubmissionHistoryEntry` (newest first), each containing:
  - `GrcSubmitterRow(email: assignmentControl.controlChampionEmail)` +
    `'${'Submission Date'.tr}: ...'` using the entry's own
    `submittedDate` (not the overall `assignmentControl.lastModificationDate`).
  - `ProductWarrantyCard` for the entry's `document`.
  - `GrcLabelValueRow('Submission Notes', entry.note)` if non-empty.
  - `GrcLabelValueRow('Reasons of Rejection', entry.rejectionReason, color:
    Colors.red)` if the entry's status is rejected and reason is non-empty.
  - `GrcStatusPill` built from `AssignmentControlStatusStyle.of(entry.status)`
    in the same bottom-right position the single pill occupies today.
  - `SizedBox(height: 12.h)` between cards.

### Wiring
- **`grc_get_it.dart`** (modify): register `GetSubmissionHistoryUseCase`
  alongside the other `AssignmentControlRepository`-based use cases, and
  update `MyAuditCubit`'s registration to inject it.

## Out of scope

- Any change to the `submitEvidence`/`applyManagerDecision`/`applyOwnerScore`
  write paths, including the `departmentManagerRejectionReasons` vs.
  `controlOwnerRejectionReasons` naming mismatch — this spec only adds a
  read-side derivation.
- A side-by-side / diff file viewer — "comparing old vs new file" is
  satisfied by having both files openable as separate cards in the same
  scrollable list; no special comparison UI.
- Any change to the "Inquires" sub-tab (still a "coming soon" placeholder).
- A dedicated Firestore submissions collection/subcollection — the
  existing parallel-list revision history on one document is sufficient,
  same rejection as every other "history" mini-feature in this app.

## Testing

`AssignmentControlModel.toSubmissionHistory()` is pure Dart (no Firebase)
and unit-testable directly:
- Single submission, still pending review → 1 entry, status submitted.
- `[Submitted(A), Rejected(A), Submitted(B)]` → 2 entries: file B
  (submitted, newest) then file A (rejected, with reason).
- `[Submitted(A), Rejected(A), Submitted(B), Approved(B)]` → 2 entries:
  file B (approved) then file A (rejected).
- `[Submitted(A), Approved(A)]` (approved on the first try, no rejection
  ever) → 1 entry, status approved, `rejectionReason` null.
- Multiple reject/resubmit cycles on different files → one entry per
  distinct file, correctly ordered newest-first.

Everywhere else, verify with `dart analyze` (or `puro flutter analyze` on
this machine) plus a manual walkthrough once a Flutter environment is
available: open a My Audit item that has been rejected and
resubmitted at least once, confirm the Submission tab shows one card per
distinct file (newest first), each with the correct file/note/date/status
pill, and that the rejected card shows its rejection reason.
