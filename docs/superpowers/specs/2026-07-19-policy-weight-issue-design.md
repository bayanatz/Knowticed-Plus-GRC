# Policy Weight Issue — design

Date: 2026-07-19

## Problem

`GrcModuleDetailsPage` already computes `hasPolicyWeightIssue` (true when the
sum of `policyWeight` across all Active + Scheduled policies in a module
exceeds 100) and renders a "Policy Weight Issue" button when it's true
(`grc_module_details_page.dart:490-499`). The button currently does nothing
(`function: () {}`).

The ask: tapping it should open a page where the user can see exactly which
policies make up that total, and either let the system spread the weight
evenly ("Equal Weight") or edit each policy's weight by hand, then apply the
fix. A second tab on the same page ("History") shows every past change to a
policy's weight: who changed it, old value, new value, and when.

## Scope decisions (confirmed)

- **Table scope**: only policies whose status is Active or Scheduled — the
  same set already used to compute `hasPolicyWeightIssue`. Draft/Inactive/
  Expired/Removed policies never appear on this page.
- **Equal Weight is not a separate save path.** It's a button inside Edit
  mode that fills every weight cell with an equal share; the user can still
  hand-edit any cell afterward. There is one save action either way: Apply
  Changes.
- **Equal Weight split**: exact decimal division, `100 / n` for every row
  (e.g. 8 policies → 12.5 each). No rounding/remainder redistribution.
- **Apply Changes is blocked until the sum is exactly 100.** Same
  enabled/disabled convention as `Activate` in
  `PolicyBulkUploadPreviewPage` (grey when disabled).
- **After a successful Apply**, the page stays put (view mode, refreshed
  values, success snackbar) — it does not auto-navigate back. The user hits
  the existing "Back" button when done.
- **History only logs policies whose weight actually changed** in a given
  Apply. If a batch only changes one of eight policies, only that one gets a
  row — unchanged rows are not written as no-op revisions. This matches how
  `updatePolicy`/`copyWithUpdate` already work everywhere else: a revision is
  only appended when a real update call is made for that policy.

## Data model

`PolicyModel` already stores every field as a parallel history list,
including `policyWeight`, `editors` ("who saved this revision"), and
`lastModifiedDate` — exactly the shape `GRCModuleModel` used to derive
`toOwnerHistory()`. No new Firestore collection, no schema change.

### Algorithm: `PolicyModel.toWeightHistory()`

New method, same spirit as `toOwnerHistory()` but a scalar diff instead of a
set diff:

1. For `i` from 1 to `policyWeight.length - 1`:
   - If `policyWeight[i] != policyWeight[i - 1]`, emit a
     `PolicyWeightHistoryEntry`:
     - `policyId: id`, `policyNameEn/Ar: policyNameEn[i]/policyNameAr[i]`
     - `weightPrevious: policyWeight[i - 1]`, `weightCurrent: policyWeight[i]`
     - `changedByEmail: editors[i]`
     - `dateOfAction: lastModifiedDate[i]`
2. Index 0 (creation) never emits — there's no "previous" to diff against.
3. Return all emitted entries (no ordering requirement at this level; the
   repository sorts across policies).

`noOfControls` is not part of the Policy revision history (Controls are a
separate subcollection) — it's resolved separately when building rows for
display (see "No/of Controls" below), using the *current* control count for
that policy at read time, not a historical count.

## New/changed pieces

### Domain
- **`lib/features/grc/policy/domain/entities/policy_weight_history_entry.dart`**
  (new):
  ```dart
  class PolicyWeightHistoryEntry {
    final String policyId;
    final String policyNameEn;
    final String policyNameAr;
    final double weightPrevious;
    final double weightCurrent;
    final String changedByEmail;
    final DateTime dateOfAction;
  }
  ```
- **`policy_model.dart`** (modify): add `toWeightHistory()` as described
  above.
- **`policy_repository.dart`** (modify): add
  `Future<Either<Failure, List<PolicyWeightHistoryEntry>>> getPolicyWeightHistory({required String moduleId});`
- **`policy_repository_impl.dart`** (modify): implement by calling the raw
  `_firebaseDataSource.getAll(moduleId: moduleId)` (already returns full
  `PolicyModel`s, not entities), flat-mapping `toWeightHistory()` across every
  policy, and sorting the combined list by `dateOfAction` descending.
  `FirebaseFailure` on exceptions, same pattern as `getAllPolicies`.
- **`lib/features/grc/policy/domain/use_cases/get_policy_weight_history_use_case.dart`**
  (new): thin pass-through, same shape as `GetGRCModuleOwnerHistoryUseCase`.

### Presentation — new folder `policy_weight_issue/`
- **`policy_weight_issue_page.dart`**: hosts the two-tab layout (Policies
  Weight / History) behind one `PaginationAppBar` breadcrumb
  `['GRC'.tr, moduleName, 'Policy Weight Issue'.tr]`.
- **`policy_weight_issue_cubit.dart`** + **`policy_weight_issue_state.dart`**:
  - Loads Active+Scheduled policies for the module (reuses
    `PolicyCubit`'s existing `getAllPolicies` use case or is handed the
    already-filtered list from the caller — see "Data flow" below).
  - For each policy, calls the existing `GetAllControlsUseCase` to resolve
    `noOfControls` (same per-policy fetch pattern already used in
    `add_champion_page.dart` / `add_owner_page.dart`).
  - Holds one `TextEditingController` per row (weight only) + `isEditing`
    flag, mirroring `PolicyBulkUploadRows`' controller-per-row approach.
  - `enterEditMode()` / `discardChanges()` (resets controllers to last-saved
    values, exits edit mode) / `applyEqualWeight()` (fills every controller
    with `100 / n`) / `applyChanges()`: for every row whose parsed value
    differs from the last-saved `policyWeight`, calls
    `PolicyRepository.updatePolicy(id, moduleId, editorId, policyWeight: ...)`
    (existing method, unchanged); on all-success, reloads the row data and
    exits edit mode.
  - Exposes `totalWeight` (sum of live controller values) and
    `totalWeightValid` (`== 100`, with a small epsilon for double
    comparison) the same way `PolicyBulkUploadRows.totalWeight` /
    `.totalWeightValid` already do.
- **`policy_weight_history_cubit.dart`** + **`policy_weight_history_state.dart`**:
  small dedicated cubit (`Initial`/`Loading`/`Loaded(entries)`/`Failure`),
  same shape as `GrcPreviousOwnersCubit`. Calls
  `GetPolicyWeightHistoryUseCase.execute(moduleId)` on init.
- **`grc_get_it.dart`** (modify): register the new use case + both cubits.
- **`grc_module_details_page.dart`** (modify): wire the existing "Policy
  Weight Issue" button's `function` to push `PolicyWeightIssuePage(module: widget.module)`.

## The page

### Tabs
Two plain underlined text tabs — "Policies Weight" (default) / "History" —
not the pill-style `CustomTabs` used for Policies/Champions/Owners, matching
the reference mockup's simpler look. Local `setState` toggle, same as
`_selectedStatusFilter` elsewhere on this page.

### Policies Weight — view mode
Black-header `Table` (same visual pattern as
`GrcPreviousModuleOwnersPage._buildBody`: black header row, alternating
`AppColors.background`/`AppColors.field` rows, `d MMM yyyy` dates via
`intl`). Columns: NO | Policy Number | Policy Name | Policy Description |
Policy Weight | No of Controls | Start Date | End Date.

Below the table, bottom-right: the exact `Total Weight` box widget from
`PolicyBulkUploadPreviewPage._buildTotalWeight` (green border when the sum
is 100, red border + "Total Weight should be 100" text otherwise) — reused
as-is, just fed this page's row data instead of bulk-upload row data.

Top-right: "Edit" button (`customButton`, same yellow/primary style already
used throughout this page) → calls `cubit.enterEditMode()`.

### Policies Weight — edit mode
- Top-left: button labeled with the existing `'Equal Policy Weight'`
  translation key (already present in `translation.dart`, both En/Ar) —
  no new translation key needed.
- Policy Weight column becomes editable `TextField` cells — same styling as
  `PolicyBulkUploadPreviewPage._buildCell` (numeric input, error border on
  invalid entry).
- Bottom: "Discard Changes" (secondary/grey button, resets and exits edit
  mode) and "Apply Changes" (primary button, disabled/greyed while
  `!totalWeightValid`, same convention as `Activate`).
- On Apply success: snackbar, cubit reloads policies + control counts,
  exits edit mode. On any per-row failure, snackbar with the error and stay
  in edit mode so the user doesn't lose their in-progress values.

### History
Same black-header `Table` pattern. Columns: NO | Changed By (avatar +
`EmployeeHelper.getEmployeeLocalizedNameWithEmail`/`getEmployeeImageWithEmail`,
same as `GrcPreviousModuleOwnersPage`) | Policy Name | No of Controls |
Policy Weight Current | Policy Weight Previous | Date Of Action. Sorted
newest first. Empty state: centered "No Weight Changes" text, same visual
treatment as the owner-history page's empty state.

`No of Controls` on a history row uses the *current* control count for that
`policyId` (resolved the same per-policy way as the Policies Weight tab),
not a historical count — Controls aren't versioned the way Policy fields
are.

## Data flow

`PolicyWeightIssuePage` is pushed with `module: GRCModuleEntity` only (same
signature as other pages pushed from `GrcModuleDetailsPage`). It provisions
its own `PolicyWeightIssueCubit`/`PolicyWeightHistoryCubit` and does its own
`getAllPolicies(moduleId)` + per-policy `getAllControls` fetch on init,
rather than trying to reuse the parent page's already-loaded `PolicyCubit`
state — this keeps the new page self-contained and matches how
`GrcPreviousModuleOwnersPage` and `AddChampionPage`/`AddOwnerPage` already
provision their own cubits when pushed.

## Out of scope

- Wiring `GrcModulePermissions.policyWeightIssue` /
  `.editPolicyWeightIssue` into a visibility/enable check. No other action
  in the GRC feature currently reads this permission enum (it exists but is
  unused everywhere) — adding gating here alone would be inconsistent with
  the rest of the feature and is better done as one pass across all GRC
  permissions later.
- A dedicated Firestore log of weight-change events. Rejected for the same
  reason `toOwnerHistory()` rejected one: it would be a second source of
  truth that can drift from the Policy's own revision history, which is
  already trusted everywhere else in this feature.
- Changing how/when `hasPolicyWeightIssue` itself is computed on
  `GrcModuleDetailsPage` — untouched.
- Any policy field other than weight is editable on this page.

## Testing

- Unit test `PolicyModel.toWeightHistory()` directly (no Firebase/UI
  needed):
  - A policy whose weight never changed → empty list.
  - Weight changed once → one entry with correct previous/current/editor/date.
  - Weight changed multiple times → one entry per change, in revision order.
  - A no-op `copyWithUpdate` call that doesn't touch weight → no entry.
- Unit test the repository's cross-policy merge + sort (newest first).
- Manual check: open Policy Weight Issue on a module with a real >100 total,
  confirm Equal Weight fills the exact `100/n` split, hand-edit a cell,
  confirm Apply Changes stays disabled until the sum is exactly 100, apply,
  confirm the module page's button disappears next time it's built, and
  confirm the History tab shows only the row(s) that actually changed.
