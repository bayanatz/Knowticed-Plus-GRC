# Previous Control Owners — design

Date: 2026-07-21

## Problem

`ControlDetailsPage` (added 2026-07-21, see
`2026-07-21-control-details-page-design.md`) has a "Previous Control
Owners" button that was deliberately built as a placeholder
(`function: () {}`, `control_details_page.dart:340-347`) — no history
feature existed yet for Control Owners. This mirrors "GRC Module Previous
Owners" one level down the hierarchy: Module has
`GrcPreviousOwnersCubit`/`GrcPreviousModuleOwnersPage`, showing every
completed owner-assignment stint (who, assigned by whom, start/end date)
derived from the Module's own revision history. The ask is the same shape,
scoped to one Control's Owner assignments instead of a Module's.

## Scope decisions (confirmed)

- **Text-only table, no avatars**: even though the mockup shown had avatar
  images for Control Owner/Assigned By, the existing Module Previous Owners
  page is text-only (`_displayName`, no `CircleAvatar`) — the Control
  version stays consistent with that, not the mockup's avatars.
- **Include removed owners** (`includeRemoved: true`) when deriving history
  — a Control Owner who has since been fully removed from the Module can
  still have real historical stints on this Control that must not be
  silently dropped.
- **Currently-active assignments never appear** — same convention as
  Module: only *completed* stints (owner later removed from this specific
  Control) show up. This matches the user's own description ("لو حصل تغيير
  في الـ Control Owner هيتسجل هنا").
- **Reuse the existing `'History Of Control Owners'` translation key**
  (already present, En/Ar) for the page's breadcrumb/title crumb, instead of
  adding a new "History Control Owners" key — same meaning as the mockup,
  and this codebase already tolerates missing/approximate translation keys
  by falling back to literal text (confirmed: `'Previous Owner'`, `'No
  Previous Module Owners'`, `'Retry'` — all used in the existing Module
  page — have no translation.dart entry at all).

## Data model

`OwnerModel` (`lib/features/grc/control_owner/data/models/owner_model.dart`)
already stores `assigningControls: List<List<AssigningControlModel>>`,
`modificationDate: List<DateTime>`, `modifiers: List<String>` as parallel
per-revision lists — the exact same shape `GRCModuleModel` uses for
`toOwnerHistory()`. No new Firestore fields or collections needed.

### Algorithm: `OwnerModel.toControlAssignmentHistory({required policyId, required controlId})`

For one `OwnerModel`, define `hasControl(List<AssigningControlModel> rev) =>
rev.any((a) => a.policyId == policyId && a.controlId == controlId)`.

- If `hasControl(assigningControls.first)` is true, open a stint:
  `startDate = modificationDate.first`, `assignedByEmail = modifiers.first`.
- For `i` from 1 to `assigningControls.length - 1`: compare
  `hasControl(assigningControls[i-1])` vs `hasControl(assigningControls[i])`.
  - false → true: open a new stint (`startDate = modificationDate[i]`,
    `assignedByEmail = modifiers[i]`).
  - true → false: close the open stint, emitting
    `ControlOwnerHistoryEntry(ownerEmail: this owner's email, assignedByEmail:
    <stint's>, startDate: <stint's>, endDate: modificationDate[i])`.
- Returns only this owner's completed stints for this one Control — the
  caller (repository) aggregates across every `OwnerModel` in the Module.

This exactly mirrors `GRCModuleModel.toOwnerHistory()`'s diff (`grc_module_model.dart:416-455`), except keyed on one `{policyId, controlId}` boolean-membership check instead of a set of owner emails (a Module directly stores its own owner-email-set history; a Control's owner history is scattered across every Owner document in the Module, each carrying a list of controls it's assigned to).

## New/changed pieces

### Domain
- **`lib/features/grc/control_owner/domain/entities/control_owner_history_entry.dart`**
  (new): `ControlOwnerHistoryEntry` — fields `ownerEmail`, `assignedByEmail`,
  `startDate`, `endDate` (identical shape to `GRCModuleOwnerHistoryEntry`).
- **`owner_model.dart`** (modify): add `toControlAssignmentHistory({required
  String policyId, required String controlId})` per the algorithm above.
- **`owner_repository.dart`** (modify): add
  `Future<Either<Failure, List<ControlOwnerHistoryEntry>>>
  getControlOwnerHistory({required String moduleId, required String
  policyId, required String controlId});`
- **`owner_repository_impl.dart`** (modify): implement via
  `_firebaseDataSource.getAll(moduleId: moduleId, includeRemoved: true)`,
  flat-map each model's `toControlAssignmentHistory(policyId: policyId,
  controlId: controlId)`, sort the combined list by `endDate` descending
  (mirrors `toOwnerHistory()`'s own sort, done here instead since this
  aggregates across multiple Owner documents rather than one Module
  document).
- **`lib/features/grc/control_owner/domain/use_cases/get_control_owner_history_use_case.dart`**
  (new): thin pass-through, same shape as `GetGRCModuleOwnerHistoryUseCase`
  — `execute({required moduleId, required policyId, required controlId})`.

### Presentation — new files under
`lib/features/grc/control_owner/presentation/`
- **`controller/control_previous_owners_cubit.dart`** +
  **`controller/control_previous_owners_state.dart`** (new): mirrors
  `GrcPreviousOwnersCubit`/`grc_previous_owners_state.dart` exactly —
  `ControlPreviousOwnersInitial/Loading/Loaded(entries)/Failure(message)`,
  one method `loadHistory({required String moduleId, required String
  policyId, required String controlId})` calling
  `GetControlOwnerHistoryUseCase.execute(...)`.
- **`ui/pages/control_previous_owners_page.dart`** (new):
  `ControlPreviousOwnersPage({required GRCModuleEntity module, required
  PolicyEntity policy, required ControlEntity control})`. Structure mirrors
  `GrcPreviousModuleOwnersPage` line for line: `BlocProvider` creating
  `GetIt.instance<ControlPreviousOwnersCubit>()..loadHistory(moduleId:
  module.moduleId, policyId: policy.id, controlId: control.id)`; breadcrumb
  `['GRC'.tr, module name, policy name, control name, 'History Of Control
  Owners'.tr]`; same black-header `Table` (columns NO | Control Owner |
  Assigned By | Start Date | End Date, using `EmployeeHelper
  .getEmployeeLocalizedNameWithEmail` for both owner columns, no avatars);
  same loading/empty (`'No Previous Control Owners'.tr`)/failure+Retry
  states copied verbatim from the Module page, adapted to call
  `loadHistory` with this page's three ids on retry.

### Wiring
- **`grc_get_it.dart`** (modify): register `GetControlOwnerHistoryUseCase`
  and `ControlPreviousOwnersCubit`, alongside the existing Control Owner
  registrations.
- **`control_details_page.dart`** (modify): `_buildScoreAndPreviousOwnersRow`'s
  "Previous Control Owners" `customButton`'s `function: () {}` becomes a
  push to `ControlPreviousOwnersPage(module: widget.module, policy:
  widget.policy, control: _control)` via the same `PageRouteBuilder` +
  fade-transition convention used everywhere else in this app.

## Out of scope

- Avatar images in the history table — explicitly rejected; stays
  text-only like the Module page.
- Any change to `GRCModuleModel.toOwnerHistory()`, `OwnerCubit`, or
  `ControlDetailsPage`'s own "Control Owner" badge (`GrcOwnerBadge`) — this
  plan only adds the history feature and wires the one button.
- A dedicated Firestore log/collection for Control Owner history — the
  existing `OwnerModel` revision history is sufficient, same rejection as
  every other "history" mini-feature in this app.

## Testing

`OwnerModel.toControlAssignmentHistory()` is pure Dart (no Firebase) and
unit-testable directly: never assigned → empty; assigned once then removed
→ one entry with correct fields; assigned/removed/reassigned/removed again
→ two entries; currently still assigned (never removed) → no entry for
that stint; a revision change unrelated to this control (e.g. a different
control added/removed from the same owner) → no entry. Everywhere else,
verify with `dart analyze` (no Flutter binary in this sandbox) plus a
manual walkthrough once a Flutter environment is available: open a
Control's Details page, tap "Previous Control Owners", confirm the
breadcrumb/table/empty/failure states render, and that removing a Control
Owner's assignment to this Control (via `AddEditControlPage`'s owner
picker) produces a new row here afterward.
