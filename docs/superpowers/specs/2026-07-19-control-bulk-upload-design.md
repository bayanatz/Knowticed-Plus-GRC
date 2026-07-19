# Control Bulk Upload — design

Date: 2026-07-19

## Problem

`PolicyDetailsPage`'s "Control" dropdown already has an "Add Control" /
"Bulk Upload" menu (`policy_view_mode_widget.dart`), but "Bulk Upload"
(`_onBulkUploadControls` in `policy_details_page.dart`) is a stub snackbar
("Bulk upload coming soon"). The ask: build the real flow, mirroring the
already-shipped Policy Bulk Upload feature
(`lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/`)
field-for-field adapted to Controls, including two things Policy's sheet
doesn't have — Control Champion/Owner assignment by email, and a
per-Control Applied Departments + Department Weight pair.

## Prior art (Policy Bulk Upload) — what carries over unchanged

- **Pipeline**: an Excel parser validates the header row against a fixed
  column list and produces raw-string rows → an editable row-form wraps
  each field in a `TextEditingController` with live `validate()` → a rows
  model owns the row list (select/add/remove/duplicate) and aggregates
  errors → a Cubit drives submit (`CreateControlUseCase` once per row,
  best-effort — one row's failure doesn't stop the rest; failed rows stay
  visible with their reason, succeeded rows disappear).
- **Two pages**: a drag-&-drop/browse upload screen, and an editable
  preview table with red-bordered/tooltipped invalid cells and a prev/next
  "Error: N" navigation that scrolls to and focuses the next bad cell.
- **Date format**: `dd-MM-yyyy`, parsed/formatted by the existing
  `parsePolicyBulkDate`/`formatPolicyBulkDate`
  (`policy_bulk_date_format.dart`) — reused directly (they're generic, not
  Policy-specific) rather than duplicated into a new file.

## What's different for Controls (confirmed scope decisions)

- **No batch-level weight check.** Policy's "Total Weight" (sum of every
  row's weight across the whole sheet must be 100) doesn't apply — Control
  Weight is just required + a positive number, independently per row (same
  as Policy's own single-Control Add form, which has no sibling-sum
  validation live today).
- **Applied Departments + Department Weight is a per-row pair**, not a
  page-level footer: comma-separated department names, comma-separated
  weights, both optional together (a Control can have zero departments),
  but if either is filled: every name must be a real department
  (`MainCoreDepartmentController`), the name count must equal the weight
  count, and the weights must sum to exactly 100 — any violation is a
  **blocking row error** (same severity as a missing required field, gates
  Activate), not informational. When valid, a small per-row green/red
  "Total Weight" box renders next to that row; it's hidden entirely
  (matching the reference mockup) when the departments themselves are
  invalid, since there's nothing meaningful to sum yet.
- **Control Champion / Control Owner are optional, comma-separated email
  lists** (multiple people per Control, matching the multi-assignee picker
  already built into `AddEditControlPage`). Every email must match a real
  employee (`MainCoreEmployeeController`) — no match is a blocking row
  error.
- **Frequency must match one of the 6 fixed values** (`Weekly`, `Bi
  weekly`, `Monthly`, `Quarterly`, `Semi Annual`, `Annually`),
  case-insensitively — `"weekly"` and `"WEEKLY"` both resolve to
  `"Weekly"`.
- **Scoped to one Policy.** Every row in one sheet creates Controls under
  the same `{moduleId, policyId}` — no per-row Policy column, since the
  entry point is already inside a single Policy's details page.
- **Champion/Owner assignment happens after each row's Control is
  created**, reusing the exact "find an existing Champion/Owner doc for
  that email and append `{policyId, controlId}`, or create a new doc if
  none exists" logic already built for `AddEditControlPage`'s
  `_applyChampionDiff`/`_applyOwnerDiff` (this case is simpler — pure
  addition, no removal branch, since these are brand-new Controls).

## Columns (header row, in order)

`Control Name` | `اسم ضابط` | `Control Number` | `رقم ضابط` | `Control
Description` | `وصف ضابط` | `Start Date` | `End Date` | `Control Weight` |
`Frequency` | `Control Champion` | `Control Owner` | `Applied Departments`
| `Department Weight`

(`Control Number`/`رقم ضابط` mirrors Policy's two-independent-strings
pattern for `controlsNumberEn`/`controlsNumberAr`, but using the literal
Arabic header text the user specified rather than Policy's `"Policy Number
Ar"` English-label convention — the two features' header styles diverge
here on purpose, per the request.)

## New files

Under `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/`:

- **`control_excel_parser.dart`** — `controlBulkUploadExpectedHeaders`
  (the 14 columns above), `ControlBulkRow` (14 raw string fields:
  `controlNameEn`, `controlNameAr`, `controlNumberEn`, `controlNumberAr`,
  `controlDescriptionEn`, `controlDescriptionAr`, `startDate`, `endDate`,
  `controlWeight`, `frequency`, `controlChampion`, `controlOwner`,
  `appliedDepartments`, `departmentWeight`), `parseControlExcel(bytes)` —
  same structure as `policy_excel_parser.dart` (header-match check, skip
  fully-blank rows, one sealed `ControlExcelParseResult` with
  `Success`/`HeaderMismatch`/`Empty` variants).

- **`control_bulk_row_form.dart`** — `ControlBulkRowForm`: one
  `TextEditingController` + `FocusNode` per field (14, same keys as
  `ControlBulkRow`), plus `validate() -> Map<String, String>` covering:
  - Required: `controlNameEn/Ar`, `controlNumberEn/Ar`,
    `controlDescriptionEn/Ar`, `startDate`, `frequency`.
  - Date parse + Start-before-End (End optional), reusing
    `parsePolicyBulkDate`.
  - `controlWeight` parses as a number `> 0`.
  - `frequency` case-insensitively matches one of the 6 allowed values
    (error otherwise); on match, the value used for `CreateControlParams`
    is the canonical-cased string (e.g. user typed `"weekly"` → stored as
    `"Weekly"`), not the raw input.
  - `controlChampion`/`controlOwner`: split on `,`, trim each, drop empty
    tokens; if any remaining token doesn't match an employee email in
    `Get.find<MainCoreEmployeeController>().allEmployeesEntities`, error
    that field (message lists which email(s) failed).
  - `appliedDepartments`/`departmentWeight`: split both on `,`, trim each
    token; if both lists are empty, valid (no departments). Otherwise:
    every department name must exist in
    `Get.find<MainCoreDepartmentController>()`'s department list, the two
    lists must be the same length, and the weights must parse as numbers
    summing to exactly 100 — any failure sets one error on
    `appliedDepartments` (the field the red-bordered cell in the mockup is
    on) describing the specific problem (unknown department name / count
    mismatch / sum != 100).
  - A `bool departmentsValidAndComplete` getter (true only when the
    departments/weight pair is non-empty, matches counts, all names real,
    and sums to 100) — used **only** by the preview page, to decide
    whether to render the per-row Total Weight box at all (hidden when
    false, whether that's because the pair is empty or because it has an
    error). Submit-time logic (below) doesn't need this getter — it reads
    the row's raw parsed department/weight lists directly.

- **`control_bulk_upload_rows.dart`** — `ControlBulkUploadRows`: same
  row-list management as `PolicyBulkUploadRows` (`toggleSelected`,
  `addBlankRow`, `removeSelected`, `duplicateSelected`, `removeAt`,
  `errorCount`, `errorLocations`, `dispose`) but **no** `totalWeight`/
  `totalWeightValid` getters — `isValid` is simply `errorCount == 0 &&
  rows.isNotEmpty`.

- **`control_bulk_upload_cubit.dart`** — `ControlBulkUploadCubit`:
  ```dart
  ControlBulkUploadCubit({
    required CreateControlUseCase createControlUseCase,
    required ChampionCubit championCubit,
    required OwnerCubit ownerCubit,
    required List<ControlBulkRow> parsedRows,
  });
  ```
  Row-management methods mirror `PolicyBulkUploadCubit` 1:1
  (`toggleRowSelected`, `addRow`, `removeSelectedRows`,
  `duplicateSelectedRow`, `revalidateRow`). `submit({required moduleId,
  required policyId})`:
  1. Emits `ControlBulkUploadSubmitting()`.
  2. For each row, sequentially: build `CreateControlParams` (`status:
     ControlStatus.active`, `equalWeights: false`, `score: 0`,
     `departments`/`departmentsWeights` from the row's parsed
     department-name list / weight list directly — empty lists when the
     row left both fields blank). This is always safe at submit time
     without re-checking validity: Activate is only reachable when
     `errorCount == 0` across every row, and a partial/broken
     departments-weight pair is itself a blocking error (see above), so
     the only two states a row can be in here are "both lists empty" or
     "both lists present, matched, and summing to 100" — never a broken
     in-between. Call `CreateControlUseCase`.
  3. On success: parse that row's Champion/Owner email lists, and for each
     email call `championCubit.createChampion`/`updateChampion` (mirroring
     `AddEditControlPage._applyChampionDiff`'s "look up existing champion
     for this email in `championCubit.state` if it's `ChampionListLoaded`,
     append `{policyId, controlId}` if found, otherwise create a new
     Champion doc with just this pair" — no removal branch needed here).
     Same for Owner via `ownerCubit`. A Champion/Owner assignment failure
     does **not** fail the row — the Control itself already saved
     successfully, so the row still counts as succeeded and disappears
     from the table, matching the "assignee changes are best-effort
     relative to the save" precedent from `AddEditControlPage` (no new UI
     affordance for a partial champion/owner failure — out of scope, not
     requested).
  4. On failure: record `ControlBulkRowFailure(reason: failure.message)`,
     row stays.
  5. Emits `ControlBulkUploadSubmitResult(succeededCount, failed)`, same
     shape as Policy's.
  Constructor calls `championCubit.getAllChampions(moduleId:)` /
  `ownerCubit.getAllOwners(moduleId:)` are the *caller's* responsibility
  (the page provides already-loading Cubits, same as `AddEditControlPage`
  does today) — the Bulk Upload Cubit itself never fetches, only reads
  `championCubit.state`/`ownerCubit.state` when it needs the lookup, at
  submit time.

- **`control_bulk_upload_page.dart`** — `ControlBulkUploadPage(moduleId,
  policyId)`: identical drag-&-drop/browse screen to Policy's, parses via
  `parseControlExcel`, on success provides `ChampionCubit`/`OwnerCubit`
  (via `GetIt`, `getAllChampions`/`getAllOwners` fired on create — same
  pattern `AddEditControlPage` already uses) alongside a fresh
  `ControlBulkUploadCubit`, then navigates to the preview page.

- **`control_bulk_upload_preview_page.dart`** — `ControlBulkUploadPreviewPage(moduleId,
  policyId)`: same toolbar (Error nav, Remove Selection, Duplication, +
  Row) and same per-cell text-field rendering as Policy's, with the 14
  columns above. Difference: no page-footer Total Weight — instead, each
  row's Applied Departments cell is followed by a small inline
  green/red box (only rendered when `row.appliedDepartments Controller` is
  non-empty), matching the reference mockup: green `"Total Weight :
  100"` when `departmentsValidAndComplete`, hidden entirely when the
  departments/weight pair itself has an error (the row's red-bordered
  cell + tooltip already communicates the problem).

## Entry point

`_onBulkUploadControls()` in `policy_details_page.dart` (`_PolicyDetailsBodyState`,
which already has `widget.moduleId`/`widget.policyId` in scope) replaces its
TODO snackbar with:
```dart
Future<void> _onBulkUploadControls() async {
  final result = await Navigator.push<bool>(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => ControlBulkUploadPage(
        moduleId: widget.moduleId,
        policyId: widget.policyId,
      ),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
  if (result == true && mounted) {
    context.read<PolicyCubit>().getAllControls(
        moduleId: widget.moduleId, policyId: widget.policyId);
  }
}
```
(mirrors `_openAddEditControl`'s exact push/refresh pattern already in this
file). The preview page pops `true` once at least one row succeeded, same
condition as Policy's (`state.failed.isEmpty` after a submit that had at
least one success — full parity with `PolicyBulkUploadPreviewPage`'s
listener).

## Out of scope

- Control Document upload per row — Policy's sheet doesn't have a document
  column either (URL-only, and even that's absent here since no document
  column was requested for Controls).
- `Control_Owners_Permissions` — left empty per assigned control, same as
  every other Owner-creation path in this codebase.
- Any change to the single-Control `AddEditControlPage` flow, or to
  `CreateControlUseCase`/`ControlModel`/`ControlRepository`.
- Cross-row Control Weight validation (sum-to-100 across the batch) — not
  requested, and the single-Control form doesn't enforce it either.

## Testing

- Unit test `control_excel_parser.dart`: valid header parses correctly;
  wrong/renamed header is rejected.
- Unit test `ControlBulkRowForm.validate()`: required-field, date-order,
  weight>0, frequency case-insensitive match, Champion/Owner email
  validation (valid email passes, unknown email errors, multiple
  comma-separated emails all checked), and the Applied Departments/Weight
  matrix (empty pair valid, unknown department name errors, count
  mismatch errors, sum != 100 errors, valid pair summing to 100 passes and
  sets `departmentsValidAndComplete`).
- Manual: upload a sample sheet under a real Policy, fix a flagged cell,
  confirm Activate creates real Control documents with the right
  Champion/Owner/department assignments, and that a deliberately-broken
  row is reported as failed while the others still succeed.
