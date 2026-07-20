# Control Weight Issue — design

Date: 2026-07-20

## Problem

`PolicyViewModeWidget` (the Policy Details page's read-only body) already has a
"Control Weight Issue" banner button (`_buildWeightIssueBanner`,
`policy_view_mode_widget.dart:368-378`), shown whenever the visible Policy's
Controls don't sum to exactly 100 (`_hasControlWeightIssue`,
`policy_view_mode_widget.dart:176-177`). The button's `function: () {}` does
nothing.

This mirrors the "Policy Weight Issue" feature already built (see
`2026-07-19-policy-weight-issue-design.md`) one level down the hierarchy:
Controls under one Policy instead of Policies under one Module. The ask is
the same shape — tapping the button opens a page to view/fix the imbalance
(Equal Weight or manual edit) and see a History of past changes — scoped to
this Policy's Controls.

## Scope decisions (confirmed)

- **Keep the existing trigger condition as-is**: `total != 100` (both over
  *and* under trigger the banner), and **all** Controls under the Policy are
  included regardless of status (no Active/Scheduled-only filter). This is
  a deliberate difference from Policy Weight Issue (which used `> 100` and
  an Active+Scheduled filter) — the existing Control code already works
  this way and isn't being changed.
- **Table column swap**: Policy's "No of Controls" column becomes **"No of
  Departments"** (`control.departments.length`) — a Control's children are
  departments (`List<DepartmentWeight>`), not sub-controls.
- Equal Weight, Apply-blocked-until-100, stay-on-page-after-apply, and
  History-only-logs-actual-changes all carry over unchanged from the Policy
  design (see that spec for the reasoning — it's the same mechanism, just
  scoped to Controls instead of Policies).

## Data model

`ControlModel` (`lib/features/grc/control/data/models/control_model.dart`)
already carries the exact same shape of per-field revision history as
`PolicyModel`: `controlsWeight`, `editors`, `lastModifiedDate` are all
parallel `List<...>`s, one element per revision. No new Firestore
collection needed — same derive-on-read technique as
`PolicyModel.toWeightHistory()`.

### Algorithm: `ControlModel.toWeightHistory()`

Identical to `PolicyModel.toWeightHistory()`: for `i` from 1 to
`controlsWeight.length - 1`, if `controlsWeight[i] != controlsWeight[i-1]`,
emit a `ControlWeightHistoryEntry(controlId: id, policyId: policyId,
controlNameEn: controlsNameEn[i], controlNameAr: controlsNameAr[i],
weightPrevious: controlsWeight[i-1], weightCurrent: controlsWeight[i],
changedByEmail: editors[i], dateOfAction: lastModifiedDate[i])`.

## New/changed pieces

### Domain
- **`lib/features/grc/control/domain/entities/control_weight_history_entry.dart`**
  (new): `ControlWeightHistoryEntry` — fields `controlId`, `policyId`,
  `controlNameEn`, `controlNameAr`, `weightPrevious`, `weightCurrent`,
  `changedByEmail`, `dateOfAction`.
- **`control_model.dart`** (modify): add `toWeightHistory()`.
- **`control_repository.dart`** (modify): add
  `Future<Either<Failure, List<ControlWeightHistoryEntry>>> getControlWeightHistory({required String moduleId, required String policyId});`
- **`control_repository_impl.dart`** (modify): implement via
  `_firebaseDataSource.getAll(moduleId: moduleId, policyId: policyId)` +
  flat-map `toWeightHistory()` + sort by `dateOfAction` descending.
- **`lib/features/grc/control/domain/use_cases/get_control_weight_history_use_case.dart`**
  (new): thin pass-through, same shape as `GetPolicyWeightHistoryUseCase`.

### Presentation — new folder `control_weight_issue/` (sibling of
`policy_weight_issue/`, under
`lib/features/grc/control/presentation/ui/pages/`)
- **`control_weight_issue_row.dart`** (new): `ControlWeightIssueRow` (one
  editable row — wraps a `ControlEntity`, exposes `noOfDepartments` from
  `control.departments.length`, a `weightController`, `currentWeight`,
  `hasChanged`, `setWeight`, `resetToInitial`, `dispose`) +
  `ControlWeightIssueRows` (table: `totalWeight`, `totalWeightValid`,
  `applyEqualWeight()`, `discardChanges()`, `changedRows`, `dispose()`) —
  pure Dart, no Firebase, mirrors `PolicyWeightIssueRow`/`Rows` exactly.
- **`control_weight_issue_cubit.dart`** + **`control_weight_issue_state.dart`**
  (new): mirrors `PolicyWeightIssueCubit` exactly, except `load` takes
  `(moduleId, policyId)`, uses `GetAllControlsUseCase` directly (no
  secondary per-row fetch needed — Controls have no further nested count to
  resolve, unlike Policy needing a separate Controls-count fetch), applies
  no status/scope filter (per the confirmed scope decision), and
  `applyChanges` calls `UpdateControlUseCase` per changed row.
- **`control_weight_history_cubit.dart`** + **`control_weight_history_state.dart`**
  (new): mirrors `PolicyWeightHistoryCubit`, calling
  `GetControlWeightHistoryUseCase.execute(moduleId, policyId)`. No
  secondary per-entry count fetch needed (no departments-count-over-time
  concept — `noOfDepartments` in a history row uses each entry's Control's
  *current* `departments.length`, resolved the same way Policy History
  resolved current Controls counts: a `Map<String controlId, int>` built
  from one `GetAllControlsUseCase` call for the policy, since all entries
  share the same `moduleId`/`policyId`).
- **`control_weight_history_tab.dart`** (new): mirrors
  `PolicyWeightHistoryTab`, columns NO | Changed By | Control Name | No of
  Departments | Control Weight Current | Control Weight Previous | Date Of
  Action.
- **`control_weight_issue_page.dart`** (new): mirrors
  `PolicyWeightIssuePage` — two tabs ("Controls Weight" / "History"),
  breadcrumb `GRC > {Module Name} > {Policy Name} > Control Weight Issue`
  (four levels — `PaginationAppBar` already truncates to the last 3 on
  tablet when more are given, same as any other 4+-level breadcrumb in this
  app). Constructor: `ControlWeightIssuePage({required GRCModuleEntity
  module, required PolicyEntity policy})`. "Controls Weight" tab table
  columns: NO | Control Number | Control Name | Control Description |
  Control Weight | No of Departments | Start Date | End Date.
- **`grc_get_it.dart`** (modify): register
  `GetControlWeightHistoryUseCase`, `ControlWeightIssueCubit`,
  `ControlWeightHistoryCubit`.
- **`policy_view_mode_widget.dart`** (modify): wire
  `_buildWeightIssueBanner`'s `function` to push `ControlWeightIssuePage(module:
  widget.module, policy: widget.policy)` (same `PageRouteBuilder` +
  fade-transition convention used everywhere else in this app).

### Translations (`lib/core/helper/data_grc_module/constant/translation.dart`)
New keys needed (checked against the existing file — these do not exist
yet, unlike `'Control Weight Issue'`'s *permission-string* counterpart in
`strings.dart`, which is a different, unrelated constant):
`'Control Weight Issue'`, `'Equal Control Weight'`, `'Control Number'`,
`'No of Departments'`, `'Controls Weight'` (tab label), `'Control Weight
Current'`, `'Control Weight Previous'`, `'You Have Successfully Edited
Controls Weights'`. Reused as-is (already exist, generic wording): `'Edit'`,
`'Discard Changes'`, `'Apply Changes'`, `'History'`, `'Changed By'`, `'Date
Of Action'`, `'Total Weight'`, `'Total Weight Should be 100'`, `'Control
Name'`, `'Control Description'`, `'Control Weight'`, `'Start Date'`, `'End
Date'`, `'Back'`.

## Out of scope

- Wiring `GrcControlPermissions.controlWeightIssue`/`.editControlWeightIssue`
  into a visibility/enable check — same reasoning as Policy Weight Issue:
  no other GRC action currently reads these permission enums, so gating
  here alone would be inconsistent; a future pass across all GRC
  permissions should do this uniformly.
- Any change to `_hasControlWeightIssue`'s trigger condition or the
  Controls list's status filtering — explicitly kept as-is per the
  confirmed scope decision.
- A dedicated Firestore log of Control weight changes — same rejection as
  Policy Weight Issue; the existing `ControlModel` revision history is
  sufficient.
- Department-level weight balancing (each Control's own
  `departments`/`equalWeights` already has its own 100%-sum guarantee via
  `equalWeights` generation, per `control_model.dart`'s existing doc
  comments) — this feature only balances `controlsWeight` across Controls
  within one Policy, exactly parallel to how Policy Weight Issue only
  balances `policyWeight` across Policies within one Module.

## Testing

Same approach as the Policy Weight Issue plan: unit test
`ControlModel.toWeightHistory()` directly (pure Dart, no Firebase) — weight
never changed → empty; changed once → one entry with correct fields;
changed multiple times → one entry per change; a no-op update that didn't
touch weight → no entry. Everywhere else, verify with `dart analyze` (no
Flutter binary in this sandbox) plus a manual walkthrough once a Flutter
environment is available: open a Policy whose Controls don't sum to 100,
confirm the banner appears/Equal Weight/manual edit/Apply Changes/History
all behave exactly like Policy Weight Issue did, scoped to that Policy's
Controls.
