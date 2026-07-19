# Control Champions/Owners picker on the Add/Edit Control page — design

Date: 2026-07-19

## Problem

`AddEditControlPage` (`lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart`)
lets a user create/edit one Control, including which Departments it's
scoped to (`_buildDepartmentsSection`). There's no way, today, to also pick
who's responsible for that Control — a user has to leave the Control form,
go to the Module's Control Champions/Owners tab, and use "+ Champion"/"Add
Owner" separately, with no department-aware filtering tied to the Control
they're actually editing.

The ask: right below `_buildDepartmentsSection`, show two sections —
"Control Champions" and "Control Owner" — each a searchable, department-
filtered people grid (already-assigned people marked with a red remove
icon, everyone else with a checkbox to add them). Nothing is written to
Firestore until the page's own Save button is pressed.

## Scope decisions (confirmed)

- **Edit mode only.** A new Control has no id until it's created, so there's
  nothing to assign it to yet. The two sections don't render when
  `widget.existingControl == null`.
- **Department filter follows the Control's live selection.** As the user
  changes `_selectedDepartments` in `_buildDepartmentsSection`, the
  candidate list in both new sections re-filters immediately (matching the
  ask: "والجديد بيتفلتر علي اساس الديبارتمنت الي انا مختارها").
- **Removing someone's last Control leaves them `Active` with an empty
  `Assigning_Controls`**, not auto-`Removed` — status is a separate,
  intentionally-triggered lifecycle concept (see the original Champion/Owner
  spec's scope decisions), not something this page infers.
- **Reuse `GrcOwnerSection`/`GrcOwnerCubit`, extended, not duplicated.** The
  job — searchable, department-filtered, toggleable people grid — is
  exactly what that widget already does for Module Owners. Two small,
  additive extensions cover the gaps (multi-department filtering; a
  red-remove-icon visual for already-selected people) without touching the
  Module Owner picker's existing behavior or look.

## Extension 1: `GrcOwnerCubit` multi-department filtering

Today: `_selectedDepartmentName: String?`, `filterByDepartment(String?
departmentName)`, and `_applyFilters` matches
`o.department == _selectedDepartmentName`. A Control can have several
Departments selected at once, so single-department matching isn't enough.

Change `_selectedDepartmentName` to `_selectedDepartmentNames: List<String>?`
internally. `_applyFilters`'s department check becomes
`_selectedDepartmentNames == null || _selectedDepartmentNames!.isEmpty ||
_selectedDepartmentNames!.contains(o.department)`. Add
`filterByDepartments(List<String>? departmentNames)` as the new general
method; keep `filterByDepartment(String? departmentName)` as a thin
backward-compatible wrapper (`filterByDepartments(departmentName == null ?
null : [departmentName])`) so the existing Module Owner call site in
`grc_owner_section.dart` needs no change. `loadOwners(..., {String?
selectedDepartmentName, List<String>? selectedDepartmentNames})` resolves
to whichever is non-null (list wins if both are somehow passed, which
never happens in practice — each caller uses one or the other).

## Extension 2: `GrcOwnerSection` red-remove-icon mode

Add `final bool showRemoveIconWhenSelected;` (default `false`) and `final
List<String>? selectedDepartmentNames;` (alongside the existing
`selectedDepartmentName`, both threaded into `GrcOwnerCubit.loadOwners`/
`didUpdateWidget`'s department-change handling). In `_buildOwnerGrid`'s two
`PersonChipCard` call sites (tablet 2-column, mobile 1-column), change:

```dart
trailing: (widget.showRemoveIconWhenSelected && owner.isSelected)
    ? Icon(Icons.remove_circle, color: AppColors.red, size: 20.sp)
    : null,
showCheckBox: !widget.isViewMode,
```

`PersonChipCard` already renders `trailing ?? CustomCheckBox(...)` — so
this is the only change needed. Unselected people keep the normal empty
checkbox; selected people show the red icon instead of a checkmark, when
this flag is on. The whole card's existing `onTap` still toggles
selection — tapping anywhere on a red-icon card removes that person, no
separate button needed. Module Owner picker usage doesn't set this flag,
so its look is unchanged.

## New widget: `ControlAssigneesSection`

`lib/features/grc/control/presentation/ui/widgets/control_assignees_section.dart`
— a thin wrapper, not a new picker:

```dart
class ControlAssigneesSection extends StatelessWidget {
  final String title;
  final List<String> alreadyAssignedEmails;
  final List<String> selectedDepartmentNames;
  final void Function(List<String> selectedEmails) onSelectionChanged;
}
```

Renders a section label (`title`) followed by one `GrcOwnerSection`:
`initialOwnerEmails: alreadyAssignedEmails`, `selectedDepartmentNames:
selectedDepartmentNames`, `showRemoveIconWhenSelected: true`,
`onOwnersChanged: (selected) =>
onSelectionChanged(selected.map((o) => o.email).toList())`.
`alreadyAssignedEmails` is only used to seed the initial selection
(`GrcOwnerSection`'s existing behavior — it doesn't react to that list
changing later, same as today), which is fine here since it's computed
once from an already-loaded Cubit snapshot before this widget is ever
built (see below) and never changes mid-session.

## `AddEditControlPage` integration

- **Providers:** wrap the page's existing single `BlocProvider<PolicyCubit>`
  in a `MultiBlocProvider` that also provides `ChampionCubit` and
  `OwnerCubit`, each firing `getAllChampions(moduleId:
  widget.moduleId)`/`getAllOwners(moduleId: widget.moduleId)` on create —
  unconditionally (cheap, keeps the widget tree simple), even though the
  sections themselves only render in edit mode.
- **Computing "already assigned":** `allChampions.where((c) =>
  c.assigningControls.any((a) => a.policyId == widget.policyId && a.controlId
  == widget.existingControl!.id)).map((c) => c.championEmail).toList()`
  (mirrored for owners). Computed inside nested `BlocBuilder<ChampionCubit,
  ChampionState>`/`BlocBuilder<OwnerCubit, OwnerState>` around the two new
  sections — while state isn't `ChampionListLoaded`/`OwnerListLoaded` yet, a
  small inline loading spinner shows instead of the section.
- **Tracking the live selection:** two new state fields,
  `List<String>? _currentChampionEmails` and `List<String>?
  _currentOwnerEmails` (`null` until first computed/toggled). Each
  `ControlAssigneesSection.onSelectionChanged` callback just assigns the
  reported list to the matching field via `setState`.
- **Where it renders:** right after `_buildDepartmentsSection()` in the
  scrollable form body, only `if (_isEdit)`, passing
  `selectedDepartmentNames: _realSelectedDepartments` (the same getter
  `_buildDepartmentsSection` already uses) so both new sections re-filter
  live as the user edits the Control's departments.
- **Applying on save:** in `_onStateChange`, when `state is
  PolicyControlActionSuccess` and `_isEdit`, before showing the success
  dialog: read `context.read<ChampionCubit>().state`/
  `context.read<OwnerCubit>().state` synchronously (already loaded, no new
  fetch — the page never re-calls `getAllChampions`/`getAllOwners` after its
  initial load, so this list is identical to the one the sections rendered
  from). If either isn't `ChampionListLoaded`/`OwnerListLoaded` (the initial
  fetch failed), skip that side's diffing entirely — nothing to compare
  against, so no assignee changes are applied for it. Otherwise, recompute
  the "already assigned" set the exact same way the render-time
  `BlocBuilder` did (see "Computing 'already assigned'" above), and diff
  that against `_currentChampionEmails` (falling back to the already-assigned
  set itself — i.e. an empty diff — if the user never touched that
  section). `controlId` below is `widget.existingControl!.id` (guaranteed
  non-null: this whole block only runs `if (_isEdit)`):
  - **Newly selected** email → look up an existing `ChampionEntity` for
    that email in the loaded list. Found: `championCubit.updateChampion(
    championEmail: email, moduleId: widget.moduleId, assigningControls:
    [...existing.assigningControls, AssigningControlEntity(policyId:
    widget.policyId, controlId: controlId)])`. Not found: `championCubit
    .createChampion(moduleId: widget.moduleId, championEmail: email,
    assigningControls: [AssigningControlEntity(policyId: widget.policyId,
    controlId: controlId)])`.
  - **Deselected** email → always found (it was in the already-assigned
    set): `championCubit.updateChampion(..., assigningControls:
    existing.assigningControls.where((a) => !(a.policyId ==
    widget.policyId && a.controlId == controlId)).toList())`.
  - Same logic for owners via `ownerCubit`/`OwnerEntity`.
  - Every call is `await`ed sequentially (not `Future.wait` in parallel —
    simpler to reason about, and this is at most a handful of people per
    save). This is fire-and-forget relative to the page's own navigation:
    the Control itself already saved successfully, so a failure here
    surfaces as a `SnackBar` ("Some champion/owner assignments couldn't be
    saved.") without blocking the existing success dialog/`Navigator.pop`.

## Out of scope

- Create-mode assignee picking (see scope decisions).
- Any change to the Module-level Control Champions/Owners tabs, their Add
  pages, or the `Control_Owners_Permissions` field — untouched.
- Undo/confirmation before a removal takes effect on Save — the existing
  "Are You Sure You Want To Edit This Control?" confirm dialog already
  covers the whole save action, assignee changes included.

## Testing

No new pure-Dart unit-testable logic beyond what's already covered
(`GrcOwnerCubit`'s filtering has no existing tests either — this matches
the codebase's current test coverage for this widget family, i.e. none).
Manual check: open an existing Control that already has a Champion and an
Owner assigned, confirm both show with the red remove icon and everyone
else in their department(s) shows an empty checkbox; toggle a removal and
an addition in each section, change the Control's Departments and confirm
the candidate list re-filters live; Save; reopen the same Control and
confirm the new assignment state persisted (and, separately, open the
Module's Control Champions/Owners tab and confirm the same change is
reflected there).
