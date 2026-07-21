# Add/Edit Control Page: Arabic Toggle, Create-Mode Simplification, Save For Later, Scheduled Status Design

**Goal:** Bring `AddEditControlPage` in line with the Policy create/edit flows: an Arabic toggle in both modes, a stripped-down Create form (no Start/End Date, no Department/Equal Weights), a Create-only "Save For Later" action that persists a Draft, and automatic Scheduled-vs-Active status on the main Create action based on the parent Policy's Start Date.

**Architecture:** No cubit, use case, repository, or Firestore schema changes — `PolicyCubit.createControl`/`updateControl` already accept every field this needs, including `status` directly. This is entirely a page-level change to `AddEditControlPage`, plus threading two new required params (`policyStartDate`/`policyEndDate`) through its two call sites so Create mode has something to inherit dates from.

**Tech Stack:** Flutter, existing `PolicyCubit`, `ControlStatus`, `showConfirmDialog`/`showSuccessDialog` — no new dependencies.

## Global Constraints

- No changes to `ControlEntity`, `ControlModel`, `ControlStatus`, `PolicyCubit.createControl`/`updateControl`, or any repository/data-source file.
- Edit mode (`existingControl != null`) is unaffected except for the Arabic toggle: Start/End Date, Department, and Equal Weights keep their exact current UI and behavior. Editing an existing control's status is left completely alone — no automatic Scheduled/Active recomputation on Save, since that risked silently reactivating a control someone had deliberately set to Inactive/Expired elsewhere, which is out of scope here.
- Create mode (`existingControl == null`) hides Start/End Date and Department/Equal Weights entirely; the Control is created with `startDate`/`endDate` copied from the parent Policy (via new required `policyStartDate`/`policyEndDate` constructor params) and `departments: const []`, `departmentsWeights: null`, `equalWeights: true`.
- The Arabic toggle applies to both modes: Create defaults it on (matching `CreateNewPolicyPage`); Edit infers on/off from whether the existing control already has any Arabic content (matching `PolicyEditPage`). Arabic fields are required only once touched (same `_arabicTouched` pattern used everywhere else in this feature) — not just because the toggle is on.
- "Save For Later" is a new button shown only in Create mode, next to Discard/Add. It calls the existing `createControl` with `status: ControlStatus.draft` — same use case, no new cubit method.
- The main Create action ("Add") computes `status` itself: `ControlStatus.scheduled` if the inherited Policy Start Date is strictly after today (start-of-day comparison), otherwise `ControlStatus.active`. This computation only ever runs for the Create path.
- Follow this repo's existing doc-comment convention (`/// function name: [X]` / `/// purpose:` / `/// parameters:` / `/// return type:`) for every new method, matching the rest of this file.

---

## 1. New required params: `policyStartDate` / `policyEndDate`

`AddEditControlPage` gains two new required constructor fields:

```dart
final DateTime policyStartDate;
final DateTime policyEndDate;
```

Both call sites already have the parent `PolicyEntity` in scope and pass these through unchanged otherwise:

- `lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart` (`_openAddEditControl`, `_PolicyDetailsBodyState` already holds `_policy`): adds `policyStartDate: _policy!.startDate, policyEndDate: _policy!.endDate,`.
- `lib/features/grc/control/presentation/ui/pages/control_details_page.dart` (its own `AddEditControlPage` push, `widget.policy` already a `PolicyEntity`): adds `policyStartDate: widget.policy.startDate, policyEndDate: widget.policy.endDate,`. This call site is edit-only (`existingControl` is always set there), so the values are never actually read for date-inheritance in practice, but the param is required on the widget either way — passing the real dates costs nothing and keeps the constructor honest.

## 2. Arabic toggle

A `bool _isArabicEnabled` field on `_AddEditControlPageState`:

- Create mode: defaults to `true` (a brand-new control, matching `CreateNewPolicyPage`'s default).
- Edit mode: in `initState`, set from `existing.controlsNameAr.trim().isNotEmpty || existing.controlsNumberAr.trim().isNotEmpty || existing.controlsDescriptionAr.trim().isNotEmpty` (matching `PolicyEditPage`'s inference — every control created before this feature already has AR content, since it used to be unconditionally required, so this reliably infers `true` for all of them).

A `bool get _arabicTouched` getter (same shape as `PolicyEditPage`'s), checking the three AR controllers for any non-empty text.

UI: a "Create Arabic Version" `FlutterSwitch` row (identical styling to `PolicyEditModeWidget`'s), placed above the Name row. Each AR `CustomTextField` (Name/Number/Description) is wrapped in `if (_isArabicEnabled) ...`; its `submitted` flag becomes `_submitted && _arabicTouched` instead of the current bare `_submitted`, matching the touched-based requirement used everywhere else. When Arabic is off, the EN field simply renders alone (no side-by-side partner) instead of in the current `isTablet ? Row(EN, AR) : Column(EN, AR)` pairing — no other layout rework (e.g. pairing EN Name with EN Number the way `PolicyInfoFormWidget`/`PolicyControlItemWidget` do) is in scope here; that wasn't asked for on this page.

## 3. Create-mode field hiding

Start/End Date section and `_buildDepartmentsSection()` are each wrapped so they only render `if (_isEdit)`. In Create mode nothing replaces them — the form simply gets shorter.

New getters:

```dart
DateTime get _effectiveStartDate => _isEdit ? _startDate! : widget.policyStartDate;
DateTime get _effectiveEndDate => _isEdit ? _endDate! : widget.policyEndDate;
```

`_validate()`'s Start/End Date and Department checks become conditional on `_isEdit` — in Create mode they're skipped entirely (there's nothing on screen to fail validation on):

```dart
(!_isEdit || (_startDate != null && _endDate != null && !endBeforeStart)) &&
...
(!_isEdit || (_realSelectedDepartments.isNotEmpty && (_equalWeights || _totalDepartmentsWeight == 100)))
```

## 4. Save For Later (Create mode only)

A new button, visible only when `!_isEdit`, added to the bottom row alongside Discard/Add (Edit mode's row is untouched: still just Discard + Save). Confirms first via `showConfirmDialog` with the same copy `CreateNewPolicyPage` uses for its own Save For Later ("Save As Draft" / "Are you sure you want to save this policy as a draft?" adapted to "this control"), then calls:

```dart
cubit.createControl(
  ...same fields as today's create path...
  startDate: widget.policyStartDate,
  endDate: widget.policyEndDate,
  departments: const [],
  departmentsWeights: null,
  equalWeights: true,
  status: ControlStatus.draft,
);
```

## 5. Scheduled vs. Active on Add

```dart
ControlStatus get _computedCreateStatus {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return widget.policyStartDate.isAfter(startOfToday)
      ? ControlStatus.scheduled
      : ControlStatus.active;
}
```

`_onSave` gains a required `status` parameter instead of reading the `_status` field directly for the create branch:

- **Add** (Create mode's main button) → `_onSave(cubit, status: _computedCreateStatus)`.
- **Save For Later** (Create mode) → `_onSave(cubit, status: ControlStatus.draft)`.
- **Save** (Edit mode's only button) → `_onSave(cubit, status: _status)` — unchanged value, no recomputation.

`_onSave`'s create branch passes `startDate`/`endDate` from `_effectiveStartDate`/`_effectiveEndDate` and the fixed `departments`/`equalWeights` defaults above instead of the current `_startDate!`/`_endDate!`/`_departmentsForSave`/`_departmentWeightsForSave`/`_equalWeights`.

## 6. Success dialog wording

`_onStateChange`'s `PolicyControlActionSuccess` branch already carries the saved `ControlEntity` (`state.control`). Add a Draft check ahead of the existing `_isEdit` branch, matching `CreateNewPolicyPage`'s `isDraft` pattern:

```dart
final isDraft = state.control.status == ControlStatus.draft;
showSuccessDialog(
  context: context,
  title: isDraft ? 'Saved as Draft'.tr : (_isEdit ? 'Control Updated'.tr : 'Control Created'.tr),
  subtitle: isDraft
      ? 'Control saved as draft successfully'.tr
      : (_isEdit ? 'You successfully updated this control.'.tr : 'You successfully created this control.'.tr),
);
```

(The Champion/Owner assignee-diff step that currently only runs `if (_isEdit)` is untouched — a fresh Create, draft or not, still has no assignees to diff against.)

## Error Handling

No new failure states — `createControl`/`updateControl` already return `PolicyControlActionSuccess`/`PolicyFailure` exactly as today; Save For Later and Add just supply a different `status` value into the same call.

## Out of Scope

- Any background/scheduled job to flip `Scheduled` → `Active` once the date arrives — this design only computes the status once, at save time. Revisiting it later (e.g., a page reload recomputing stale Scheduled controls) is a separate concern not requested here.
- Recomputing Scheduled/Active when editing an existing control's Start Date.
- Any change to the Champions/Owners assignment section, siblings-weight validation, or document upload behavior.
