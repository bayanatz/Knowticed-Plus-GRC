# Control Details Page — design

Date: 2026-07-21

## Problem

Tapping a `ControlCardWidget` in the Policy Details page's Controls list
(`PolicyViewModeWidget._buildControlsList`, `policy_view_mode_widget.dart:409-449`)
currently calls `widget.onControlTap(control)`, which opens `AddEditControlPage`
directly in edit mode
(`policy_details_page.dart:193-213`, `_openAddEditControl`). There is no
read-only "Control Details" screen — unlike Policy, which has
`PolicyDetailsPage` sitting between the list and its edit page
(`PolicyEditPage`).

The ask: add a `ControlDetailsPage`, opened on tap, matching a design mock —
breadcrumb, Edit/Delete, a Score badge, a "Previous Control Owners" button,
and a details card (description, owner, documents, frequency/weight/dates,
per-department weight chips). `AddEditControlPage` becomes reachable only via
this new page's Edit button, mirroring the Policy → `PolicyDetailsPage` →
`PolicyEditPage` split.

## Scope decisions (confirmed)

- **"Previous Control Owners" button is a placeholder** — no cubit/use case/
  history page built for it in this pass (unlike Module-level
  `GrcPreviousOwnersCubit`/`GrcPreviousModuleOwnersPage`, which already
  exist). The button renders but its tap does nothing yet.
- **Control Owner**: a Control can have more than one assigned `OwnerEntity`
  (via `assigningControls`, `owner_entity.dart:20`). Only the **first**
  matching owner is shown (avatar + name + Message button), same
  first-owner-only convention `GrcOwnerBadge` already uses for Modules
  (`grc_owner_badge.dart:79-86`).
- **Departments**: rendered as wrapping chips, one per `DepartmentWeight` in
  `control.departments`, each reading `"<department> | <weight>"`. If the
  list is empty, render a single **"Not Assigned"** badge instead of an empty
  chip row.
- **No single-Control fetch exists** (`PolicyCubit` only has `getAllControls`,
  no `getControl`/`PolicyControlSingleLoaded` — confirmed by reading
  `policy_cubit.dart`). After editing, `ControlDetailsPage` re-runs
  `getAllControls` and picks the matching entity back out by `id`, the same
  refresh shape the parent list already uses.

## New/changed pieces

### Presentation — new page
- **`lib/features/grc/control/presentation/ui/pages/control_details_page.dart`**
  (new): `ControlDetailsPage({required GRCModuleEntity module, required
  PolicyEntity policy, required ControlEntity control, required
  List<ControlEntity> siblingControls})`. Structure mirrors
  `PolicyDetailsPage`: a `StatelessWidget` wrapper providing `PolicyCubit`
  (delete + refresh-after-edit) and `OwnerCubit` (owner lookup), wrapping a
  `_ControlDetailsBody` `StatefulWidget` that holds the current
  `ControlEntity` in state (seeded from the constructor, replaced after a
  successful edit).

  Layout, top to bottom:
  1. `PaginationAppBar` breadcrumb: `['GRC'.tr, module name, policy name,
     control name]` (localized per `context.isArabic`), same 4-level pattern
     `ControlWeightIssuePage` already uses.
  2. `GrcActionButtons(onEditTap, onDeleteTap, deleteDialogTitle: 'Deleting
     Control', deleteDialogSubtitle: 'Are You Sure You Want To Delete This
     Control ?')` — reused as-is.
  3. A row: `Score: <control.score>` badge (green value, left) and a
     "Previous Control Owners" button (`customButton`, right, `function: ()
     {}` — placeholder).
  4. The main details card (`AppColors.field` container, `CardStyles`
     label/value text styles, matching `PolicyViewModeWidget`'s info-card
     look):
     - Row: **"Control Description"** label (left) + **"Last Update:
       `dateFormat.format(control.lastModifiedDate)`"** (right).
     - Description text (`controlsDescriptionAr`/`En` per locale).
     - Control Owner row: avatar + name + Message button for the first
       `OwnerEntity` whose `assigningControls` contains this
       `{policyId, controlId}` pair (looked up from `OwnerCubit`'s loaded
       list, same matching logic `AddEditControlPage._alreadyAssignedOwnerEmails`
       already uses) — or nothing if no owner is assigned.
     - Documents row: `controlsDocumentEn`/`controlsDocumentAr` side by side
       via the same `ProductWarrantyCard`-based layout
       `PolicyViewModeWidget._buildDocumentsRow` uses, hidden entirely if
       neither document exists.
     - Row: **Frequency | Control Weight | Start Date | End Date**, four
       columns.
     - **Departments Weight**: label + `Wrap` of chips, one per
       `DepartmentWeight` (`"<department> | <weight>"`); "Not Assigned"
       badge if `control.departments` is empty.

### Presentation — generalize `GrcOwnerBadge`
- **`lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart`**
  (modify): the label is currently hardcoded to `'Module Owner:'.tr`
  (`grc_owner_badge.dart:92`). Add a `label` constructor parameter
  (default `'Module Owner:'` to keep every existing call site unchanged) so
  `ControlDetailsPage` can pass `'Control Owner:'` instead of forking a
  near-duplicate widget. Note: `GrcOwnerBadge` currently drives its own
  `GrcOwnerCubit` fetch from `ownerEmails` (Module-owner emails via
  `GrcOwnerCubit.loadOwners`); `ControlDetailsPage` does not reuse that
  fetch path — it resolves the owner from the already-loaded `OwnerCubit`
  list and passes the single resolved `OwnerData`-equivalent info directly
  into a small presentational reuse of `GrcOwnerBadge`'s row (avatar + name
  + Message button), not its Module-owner-fetching state logic. If wiring
  this cleanly through `GrcOwnerBadge` as-is proves awkward once in the
  code, the fallback is extracting just the presentational row (avatar +
  name + Message button) into a shared stateless widget — a decision left
  for implementation, not a scope change.

### Wiring
- **`policy_view_mode_widget.dart`** (modify): `_buildControlsList`'s
  `ControlCardWidget.onTap` callbacks switch from calling
  `widget.onControlTap(controls[i])` (which opens `AddEditControlPage`) to
  pushing `ControlDetailsPage(module: widget.module, policy: widget.policy,
  control: controls[i], siblingControls: widget.controls)` via the same
  `PageRouteBuilder` + fade-transition convention used everywhere else. On
  pop with `true` (delete succeeded), refresh `getAllControls` the same way
  `_openAddEditControl`'s pop handler already does today.
- `widget.onControlTap` stays as the callback `ControlDetailsPage`'s own
  Edit button uses to open `AddEditControlPage` (passed down or replicated
  as a local `_openAddEditControl` inside the new page, matching
  `PolicyDetailsPage`'s existing method of the same name) — "Add Control"
  (from the toolbar's dropdown, `_controlMenuItem('Add Control'.tr, ...)`)
  keeps going straight to `AddEditControlPage` unchanged, since there's
  nothing to view yet for a control that doesn't exist.

## Out of scope

- Building the "Previous Control Owners" history feature (entity + use case
  + cubit + page) — explicitly deferred; the button is a placeholder.
- Any change to `AddEditControlPage` itself.
- A single-Control Firestore fetch/use case — re-deriving the updated entity
  from `getAllControls` after edit is sufficient, matching the existing
  refresh pattern.

## Testing

No new business logic (pure UI composition + wiring over already-tested
cubit methods), so no new unit tests are planned. Verify with `dart analyze`
plus a manual walkthrough once a Flutter environment is available: open a
Policy with at least one Control, tap a Control card, confirm the Details
page renders (breadcrumb, Score, description, owner + Message button,
documents if present, frequency/weight/dates, department chips or "Not
Assigned"), Edit opens `AddEditControlPage` pre-filled and returns here with
updated data, Delete removes the Control and returns to Policy Details.
