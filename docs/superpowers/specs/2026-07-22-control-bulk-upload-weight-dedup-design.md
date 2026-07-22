# Control Bulk Upload: Equal/Distinct Weight Dialog, Policy Date Bounds, Duplicate Name/Number

Date: 2026-07-22
Status: Approved

## Context

`ControlBulkUploadPage` (`lib/features/grc/control/presentation/ui/pages/control_bulk_upload/`) lets a user upload an Excel workbook of Controls under a Policy, review/edit them in an editable preview table (`ControlBulkUploadRows` / `ControlBulkRowForm`), then submit them one row at a time via `CreateControlUseCase`.

Three gaps exist relative to the single-Control Add/Edit flow (`add_edit_control_page.dart`):

1. There's no equivalent of that page's "Equal Weights" toggle — bulk upload always requires the Department Weight column to be filled in manually and sum to 100.
2. Commit `24aead8` added Start/End Date bounds against the parent Policy's own date range to the single-Control page. Bulk upload rows have no such check.
3. Nothing prevents two rows in the same uploaded batch from sharing the same Control Name or Control Number.

This spec covers adding all three to the bulk upload flow, scoped to `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/`.

## 1. Equal/Distinct weight dialog

**Trigger & timing:** A dialog appears automatically the moment `ControlBulkUploadPage` opens (`initState`), before the user interacts with the drag & drop area or Browse Files. It is non-dismissible (no barrier-tap-to-close, no back button escape) — the user must pick an answer. If there is no way to answer other than picking one of the two options, there is no "cancel" path; the only way off the page without answering is not applicable since the dialog blocks interaction until answered. (If the platform back gesture must be handled, treat it as popping the whole page, same as Discard.)

**Question / options:** Something to the effect of "Assign equal weight to every department?" with **Yes** / **No** answers:
- **Yes → Equal.** Every row's per-department weight is computed as `100 / count(departments in that row's Applied Departments)`, overriding whatever is in the Excel/table's Department Weight column. The Department Weight column becomes read-only display-only (or hidden — implementation detail for the plan) since it's no longer a validated input.
- **No → Distinct.** Unchanged from today: Department Weight column is read, split by comma same as Applied Departments, and must be numeric and sum to exactly 100 per row.

**Storage:** The chosen mode (`equalWeights: bool`) is captured once, before `ControlBulkUploadCubit` is even constructed (since the cubit is created after a file is parsed, further down in `ControlBulkUploadPage._processBytes`), and threaded through:
- `ControlBulkUploadPage` (new `bool` local state, set once by the dialog's result)
- `ControlBulkUploadCubit` (new constructor param, stored, passed to `ControlBulkUploadRows` and used in `submit()`)
- `ControlBulkUploadRows` (new constructor param, passed to every row's `validate()`)
- `ControlBulkRowForm.validate()` (new required param `bool equalWeights`)

It is not a per-row override and not editable after the dialog closes — the whole batch uses one mode.

**Validation changes in `ControlBulkRowForm._validateDepartments`:**
- When `equalWeights == true`: the Department Weight cell/column is not read or validated at all (no "must be numbers" / "must sum to 100" checks). Only Applied Departments is validated (non-empty department names, all known). `departmentWeights` is derived as `List.filled(departmentNames.length, 100 / departmentNames.length)`.
- When `equalWeights == false`: unchanged — today's logic.

**Submission (`ControlBulkUploadCubit.submit`):** `CreateControlParams.equalWeights` is set from the batch-level `equalWeights` flag (today it's hardcoded to `false`); `departmentsWeights` comes from the row's already-computed `departmentWeights` either way.

## 2. Control dates constrained to the parent Policy's date range

Mirrors commit `24aead8`'s logic for `add_edit_control_page.dart`, applied to bulk row validation instead of a date-picker widget (bulk upload's Start/End Date cells are plain text fields parsed via `parsePolicyBulkDate`, not `CustomDropdownCalendar`, so there's no `firstDate`/`lastDate` widget constraint — this is validation-message-only).

**Threading policy dates in:**
- `ControlBulkUploadPage` gains two new required constructor params: `DateTime policyStartDate`, `DateTime policyEndDate`.
- Caller `policy_details_page.dart`'s `_onBulkUploadControls()` passes `_policy!.startDate` / `_policy!.endDate` — same fields `_openAddEditControl()` already passes to `AddEditControlPage`.
- Passed down through `ControlBulkUploadCubit` → `ControlBulkUploadRows` → `ControlBulkRowForm.validate(..., required DateTime policyStartDate, required DateTime policyEndDate)`.

**New checks in `ControlBulkRowForm.validate()`** (added alongside the existing start/end parsing, same error-slot pattern — `errors['startDate']` / `errors['endDate']`, only set when not already carrying a different error):
- Start Date before `policyStartDate` → "Start date cannot be before the Policy start date."
- Start Date after `policyEndDate` → "Start date cannot be after the Policy end date."
- End Date (when non-empty) before `policyStartDate` → "End date cannot be before the Policy start date."
- End Date (when non-empty) after `policyEndDate` → "End date cannot be after the Policy end date."

These are checked in addition to (not instead of) the existing Start-before-End check. Message strings follow this file's existing convention of plain (non-`.tr`) literals, matching its other messages like `'Required'`, `'Invalid date (dd-MM-yyyy)'`.

## 3. No duplicate Name/Number within the uploaded file

**Scope:** within the current batch only — not checked against Controls already saved under the Policy (existing sibling Controls are out of scope per explicit decision).

**Fields checked independently:** Control Name EN, Control Name AR, Control Number EN, Control Number AR — four separate duplicate checks, not a combined key. A row can be flagged as duplicate on one field without the others.

**Matching rule:** trim + case-insensitive equality. Empty values are never compared (already caught by the existing "Required" check on that field) — this keeps the duplicate check from firing on a table full of still-blank rows.

**Where this lives:** duplicate detection is inherently cross-row, so it can't live inside `ControlBulkRowForm.validate()` (which only sees its own row). It becomes a new method on `ControlBulkUploadRows`, e.g. `_recomputeDuplicates()`, that:
1. For each of the 4 field keys, clears any `errors[fieldKey]` entry that is currently the duplicate-flag message (leaves `'Required'` alone — the two are mutually exclusive per field per row, since duplicate-checking only considers non-empty values).
2. Builds a normalized-value → row-indices map per field, skipping empty values.
3. For every group with 2+ rows, sets `errors[fieldKey] = 'Duplicate value'` on every row in that group.

**When it runs:** after every operation that can change row content or row count — constructor's initial per-row validation loop, `addBlankRow`, `removeSelected`, `duplicateSelected`, `removeAt`, and per-keystroke revalidation. This last one requires moving `ControlBulkUploadCubit.revalidateRow`'s logic (currently calls `_rows.rows[index].validate(...)` directly) into a new `ControlBulkUploadRows.revalidateRow(index)` method that validates that one row and then calls `_recomputeDuplicates()`, so the cubit method becomes a thin delegator.

**Known consequence (intended):** "Duplicate Row" copies all 4 field values verbatim into a new row, which will immediately flag both the source and the copy as duplicates on all 4 fields until the user edits at least one field on one of them. This is correct given the rule, not a bug to guard against.

## Out of scope

- No duplicate check against Controls already saved under the Policy (only within the uploaded batch).
- No per-row override of the Equal/Distinct choice.
- No changes to the single-Control Add/Edit page (already has its own Equal Weights toggle and Policy date bounds).
- No changes to Policy-level bulk upload (`policy_bulk_upload/`) — Control-only.
