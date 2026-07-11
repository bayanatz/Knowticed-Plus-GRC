# Policy Bulk Upload — design

Date: 2026-07-11

## Problem

`GrcModuleDetailsPage` currently only lets a user create one Policy at a
time via `CreateNewPolicyPage` (info → controls → preview, three steps).
There is no way to create many policies at once from a spreadsheet.

## Goal

From a module's details page, the user can pick **Bulk Upload** as an
alternative to **Add Policy**: upload an Excel sheet of policies, review/edit
the parsed data in an inline-editable table (fixing anything wrong before
committing), and create all valid rows as real Policy documents under that
module.

## Out of scope

- Bulk-uploading `Controls` per policy — bulk-created policies always have
  `controls: []`. Controls remain addable only through the existing
  single-policy `Add Policy` flow (edit after creation, once a policy
  edit/view page exists).
- A "Download Template" button — not present in the mockups, can be a
  follow-up.
- Atomic all-or-nothing creation — bulk create is best-effort per row.
- Policy Number uniqueness validation.
- Per-row `Policy Document` file upload — the sheet's `Policy Document`
  column is a plain URL string, stored directly as `policyDocumentUrl`
  (no Firebase Storage upload happens for bulk rows).
- Any change to `PolicyEntity`, `PolicyModel`, `CreatePolicyUseCase`,
  `PolicyCubit`, or the existing single-policy `Add Policy` flow — bulk
  upload is purely a new caller of the existing create-policy path.
- Any change to the unrelated existing bulk-import feature under
  `lib/features/roles/user_management/` — it's prior art to mirror, not
  code to refactor or share.

## A. Entry point

`GrcModuleDetailsPage`'s existing "Policy" button (tablet ~line 318, mobile
~line 351 in `grc_module_details_page.dart`) changes from a direct
`navigateTo(context, CreateNewPolicyPage(moduleId: widget.module.id))` into a
menu (`PopupMenuButton` or equivalent) with two entries:

- **Add Policy** — unchanged, still opens
  `CreateNewPolicyPage(moduleId: widget.module.id)`.
- **Bulk Upload** — new, opens
  `PolicyBulkUploadPage(moduleId: widget.module.id)`.

## B. New files

All new code lives under
`lib/features/grc/presentation/ui/pages/policy_bulk_upload/`:

- `policy_bulk_upload_page.dart` — upload screen (drag&drop/browse).
- `policy_bulk_upload_preview_page.dart` — editable table screen.
- `policy_bulk_upload_cubit.dart` + a matching state file — owns parsed
  rows, per-cell validation, row selection, and submit.
- `policy_excel_parser.dart` — pure function, bytes → validated header
  check → `List<PolicyBulkRow>` (raw strings, not yet controllers/typed).

No existing GRC domain/data files change. Both screens depend only on
`CreatePolicyUseCase` (already exists, resolved via `grc_get_it.dart`) and
`PolicyBulkRow`/`PolicyBulkUploadCubit` (new).

## C. Upload page (`policy_bulk_upload_page.dart`)

- Drag&drop zone (`desktop_drop`, already a dependency) + "Browse Files"
  (`file_picker`, restricted to `.xlsx`/`.xls`) + "Discard" (pops back).
- Mirrors the parsing approach in
  `lib/features/roles/user_management/ui/widgets/import_page_methods1.dart`
  (`Excel.decodeBytes`, header-row validation against a fixed
  `expectedHeaders` list): `Policy Number, Policy Name, اسم السياسة,
  Policy Description, وصف السياسة, Start Date, End Date, Policy Weight,
  Policy Document`.
- Header mismatch → inline error on this page, file rejected, no
  navigation.
- Header match → rows passed into a fresh `PolicyBulkUploadCubit`, then
  navigate to `PolicyBulkUploadPreviewPage(moduleId: ...)`.

## D. Preview/table page (`policy_bulk_upload_preview_page.dart`)

- One row per parsed policy; each field (Policy Number, Policy Name En/Ar,
  Policy Description En/Ar, Start Date, End Date, Policy Weight, Policy
  Document) is backed by a `TextEditingController`, editable inline —
  mirrors the per-cell controller pattern in
  `lib/features/roles/user_management/ui/widgets/upload_build_page.dart`.
- Yellow checkbox per row selects rows for the **Remove Selection** and
  **Duplication** actions. **+ Row** appends one blank editable row.
- Live per-cell validation:
  - Required (non-empty): Policy Number, Policy Name En, Policy Name Ar,
    Policy Description En, Policy Description Ar, Start Date.
  - Start Date must be strictly before End Date whenever End Date is
    filled in (same rule as the single Add Policy flow).
  - Policy Weight must parse as a number and be `> 0`.
  - End Date and Policy Document are optional — no required-field error
    on empty.
- "Error: N" counter (top-left) with prev/next navigation that focuses the
  next invalid cell, matching the existing import table's error-nav UX.
- Footer recomputes `Total Weight` live as the sum of the Policy Weight
  column across all rows (batch-level rule, independent of per-row
  validation); shows "Total Weight should be 100" in red whenever the sum
  is not exactly 100.
- **Activate** is disabled while any per-row validation error exists or
  `Total Weight != 100`; **Discard** pops back to `GrcModuleDetailsPage`
  without creating anything.

## E. Submit flow

`PolicyBulkUploadCubit.submit()`:

1. For each valid row, builds a `CreatePolicyParams` with: the row's
   moduleId, Policy Number/Name/Description/Start/End Date/Weight fields,
   `controls: []`, `status: PolicyStatus.active`,
   `policyDocumentUrl:` the row's Policy Document text (nullable),
   `image: null`.
2. Calls the existing `CreatePolicyUseCase` once per row, sequentially,
   best-effort (a failure on one row doesn't stop the rest).
3. Emits a single result: `succeeded: List<PolicyEntity>`,
   `failed: List<({int rowIndex, String reason})>`.

UI reaction to the result:

- All succeeded → snackbar with the created count, navigate back to
  `GrcModuleDetailsPage` (its policy list/counts refresh via the existing
  `getAllPolicies` call).
- Some failed → stay on the preview page; remove the succeeded rows from
  the table, keep the failed rows visible with their failure reason shown
  inline so the user can fix and re-submit just those.
- While submitting: show a loading indicator, disable Activate/Discard to
  prevent double submits.

## Testing

- Unit test for `policy_excel_parser.dart`: valid header row parses
  correctly; a header row missing/renaming a column is rejected with an
  error.
- Unit test for `PolicyBulkUploadCubit` validation logic: required-field,
  date-order, and weight>0 rules produce the expected per-cell errors;
  Total Weight check flips Activate's availability.
- Manual verification: upload a sample sheet, edit a cell to fix a
  flagged error, confirm Activate creates real Policy documents under
  `GRC Modules/{moduleId}/Policies/{policyId}`, and that a deliberately
  broken row (e.g. bad moduleId) is reported as failed while the other
  rows still succeed.
