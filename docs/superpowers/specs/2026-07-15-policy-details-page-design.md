# Policy Details Page — Design

Date: 2026-07-15

## 1. Scope

**In scope:**
- New `PolicyDetailsPage`, opened by tapping a policy card in `GrcModuleDetailsPage`.
- Policy: view details, in-place Edit, Delete (soft-delete, existing pattern).
- Controls: read-only display list with a status filter (All/Active/Inactive/Expired/Unassigned/Draft) with counts; Add Control and Edit Control via a full-page form, enforcing the 100%-weight-sum rule across sibling controls.

**Non-goals:** Control Champions/Owners tabs (remain stubs), a messaging feature, a department picker for controls (`departments` stays `[]`, matching the existing creation wizard), any change to `CreateNewPolicyPage`'s creation flow, automated tests (explicitly out of scope for this task).

## 2. Navigation entry point

`grc_module_details_page.dart`'s `_PolicyCard` (currently a documented no-op — "Tapping is a no-op for now") gets:

```dart
onTap: () => navigateTo(
  context,
  PolicyDetailsPage(policyId: policy.id, moduleId: widget.module.moduleId, module: widget.module),
),
```

`PolicyDetailsPage` re-fetches the policy itself via `PolicyCubit.getPolicy(id, moduleId: moduleId)` rather than trusting a passed-in `PolicyEntity`, so it reflects the latest state after any edit made elsewhere. The `GRCModuleEntity` (needed for the owner row) is passed in directly since the caller already holds it — no extra fetch.

Uses plain `Navigator` via the existing `navigateTo`/`navigateAndFinish` helper (`lib/core/custom/37-custom_navigate.dart`); this app has no `GetPage` route table, so no route registration is needed.

## 3. Policy header (view mode)

- `PaginationAppBar(screensTitles: ['GRC', module.moduleNameEn/Ar, policy.policyNameEn/Ar])` for the breadcrumb.
- `GrcActionButtons(onEditTap, onDeleteTap)` reused as-is (same widget used on the GRC Module details page).
- Body: info rows for Policy Number, Description, Weight, Start/End Date, Last Edit, following the label/value layout already used by `ModuleInfoCard`.
- `GrcOwnerSection(isViewMode: true, initialOwnerEmails: module.moduleOwners)` reused verbatim for the "Module Owner" row — it already resolves owner ids to name/photo via `GrcOwnerCubit`. No Message button (no messaging feature exists in this codebase).

## 4. Edit mode (in-place)

Toggling Edit swaps the read-only rows for the same form fields used in `CreateNewPolicyPage` step 0 (`PolicyInfoFormWidget`), pre-filled from the loaded `PolicyEntity`. Save calls `PolicyCubit.updatePolicy(...)`; Discard reverts to the last-loaded values. Controls are **not** touched by this mode — they're managed independently (see §7–8). This mirrors `grc_details_page.dart`'s `GrcPageMode` view/edit toggle, applied only to the policy's own fields.

## 5. Delete flow

`onDeleteTap` → `showConfirmDialog` (same call as `GrcActionButtons` today, retitled "Deleting Policy" / "Are you sure you want to delete this Policy?") → on confirm, `PolicyCubit.deletePolicy(id: policy.id, moduleId: moduleId)` (existing soft-delete to `PolicyStatus.removed`) → on success, `Navigator.pop(context, true)` so `GrcModuleDetailsPage` reloads its policy list, matching `grc_details_page.dart`'s existing success pattern (`showSuccessDialog` then pop).

## 6. Document display

`policy.policyDocumentEn` / `policyDocumentAr` are plain download-URL strings today, but `PolicyDocumentPreviewWidget` / `PolicyDocumentInfo` currently only know how to render a local, not-yet-uploaded `File` (`PolicyDocumentInfo.fromPlatformFile`).

Add:
- `PolicyDocumentInfo.fromUrl(String url)` — derives a display name from the URL path and omits a byte size if it can't be determined without a network call.
- A read-only render mode on `PolicyDocumentPreviewWidget` (hide the remove button) for use here.

This is additive only — no change to the existing local-file upload usage in `CreateNewPolicyPage`/`AddPolicyControlsPage`.

## 7. Controls list + status filter

On page load, `PolicyCubit.getAllControls(moduleId: moduleId, policyId: policy.id)` fetches the full control list once (emits `PolicyControlsListLoaded`). Filtering/counting is done client-side in `PolicyDetailsPage`'s state, copying the `_countByStatus` / `_applyStatusFilter` pattern already used for the Policy status row in `grc_module_details_page.dart` (lines 135–175), driving a row of `FilterBarItem`s: "All" + one chip per `ControlStatus` value (`draft, active, inactive, expired, unassigned`).

Each control renders in a new lightweight read-only card widget (existing `PolicyControlItemWidget`/`PolicyControlsTableWidget` are edit-mode form widgets bound to `PolicyControlModel`, not display widgets for `ControlEntity` — not reusable here). The card shows: status, weight, frequency, start/end date, and last edit — i.e. exactly what `ControlEntity` actually holds. (`ControlEntity` has no per-control owner field, so no owner is shown on the card.)

Tapping a control card navigates to §8 in edit mode.

## 8. Add/Edit Control page

New `AddEditControlPage({required moduleId, required policyId, ControlEntity? existingControl, required List<ControlEntity> siblingControls})`, pushed via `navigateTo`.

Fields: Name (En/Ar), Number (En/Ar), Description (En/Ar), Weight, Frequency, Start/End Date, Status (dropdown over `ControlStatus`), Document (En/Ar upload). This mirrors `PolicyControlItemWidget`'s field set plus a Status picker (the creation wizard doesn't need one since it sets status implicitly via Save-for-Later/Publish; a standalone control needs it set explicitly).

`departments` / `equalWeights` / `score` stay hardcoded (`[]` / `false` / `0`) exactly as `create_new_policy.dart`'s `_buildPendingControls` already does — consistent with current behavior, not a regression.

**Weight validation:** before Save, sum this control's weight with all `siblingControls` weights (`existingControl` excluded from the sibling sum if editing) and block Save with an inline error unless the total equals 100 — same rule already enforced for policy creation.

On Save: `PolicyCubit.createControl(...)` (add) or `PolicyCubit.updateControl(...)` (edit) using the already-implemented use cases/params (`CreateControlParams`/`UpdateControlParams`). On success, pop back to `PolicyDetailsPage`, which re-fetches controls.

## 9. State management & error handling

`PolicyDetailsPage` is a `StatefulWidget` wrapped in one `BlocProvider<PolicyCubit>` (factory-registered in `grc_get_it.dart`, same DI pattern as `GrcModuleDetailsPage`/`GovernanceRiskAndComplianceDetails`). A `BlocListener` handles:
- `PolicyLoading` → `showLoadingIndicator()` / `hideLoadingIndicator()`.
- `PolicyFailure(message)` → red `SnackBar`.
- `PolicySingleLoaded` → populate view state.
- `PolicyActionSuccess` (update/delete) → `showSuccessDialog` then refresh or pop, per §4/§5.
- `PolicyControlsListLoaded` → populate the controls list + recompute filter counts.
- `PolicyControlActionSuccess` / `PolicyControlDeleted` → refresh controls list.

This mirrors `grc_details_page.dart`'s existing `_onStateChange` listener pattern. Weight-sum validation (§8) is a pure client-side check performed before calling the cubit — no new domain/repository code required anywhere in this feature; every cubit method it depends on (`getPolicy`, `updatePolicy`, `deletePolicy`, `getAllControls`, `createControl`, `updateControl`) already exists and is DI-wired.
