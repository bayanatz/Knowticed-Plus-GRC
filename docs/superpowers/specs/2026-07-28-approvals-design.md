# Approvals (Department Manager) — Design

## Context

This is the second of the three role-scoped mini-features that share the `Assignment_Controls`
workflow (see [grc_module_details_page.dart:338-364](../../../lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart#L338-L364)
and the earlier [Assignment Controls design](2026-07-27-assignment-controls-champion-design.md)).
That spec built the Control Champion side (submit evidence) and deliberately left
`Department_Manager` resolution as an open gap. This spec builds the Department
Manager side — reviewing and Approving/Rejecting a Champion's submitted evidence —
and closes that gap.

"My Audits" (Control Owner) remains out of scope, a future third spec.

## Full workflow recap (for context)

1. Champion submits evidence → `Assignment_Controls.status = Submitted`.
2. **This spec:** Department Manager reviews → Approve or Reject.
   - Approve → `Assignment_Controls.status = In review` (awaits the future
     Control Owner step — Approving here is not the final word).
   - Reject → `Assignment_Controls.status = Rejected` → Champion edits and
     resubmits (already-built Champion flow).
3. *(future spec)* Control Owner reviews the `In review` item → Approve
   (→ `Approved`, optionally scored) or Reject (→ `Rejected`, same as above).

## Department Manager resolution

Each employee record (`EmployeeEntityPro`) carries a `departmentId` (raw FK,
not a name — see `lib/features/employee/domain/entities/employee_entity.dart`)
and a `title` (English job title). There is no stored "manager" reference
anywhere in this codebase today. The manager for a given Champion is defined
as: **another employee sharing the Champion's `departmentId` whose `title`
starts with "Chief"** (case-insensitive) — e.g. CEO, COO, CFO, CXO.

This resolution happens once, at Champion submit time (Section 3), and the
result is written into `Assignment_Controls.Department_Manager` — the field
that already exists in the model but has been `null` since the Assignment
Controls spec. If no "Chief*" employee exists in the Champion's department,
`Department_Manager` stays `null` and the submit still succeeds; the request
simply won't appear in anyone's Approvals list until an admin fixes that
department's job titles. This is a deliberate, confirmed trade-off — not an
error condition.

## Architecture

New feature folder `lib/features/grc/approval/`, mirroring `assignment_control/`'s
Clean Architecture layout exactly: `data/{data_source,repository,models}`,
`domain/{entities,repository,use_cases}`, `presentation/{controller,ui/pages}`.

Firestore path: `GRC Modules/{Module_ID}/Approvals/{Approval_ID}` — a sibling
subcollection to `Assignment Controls` (not nested under it), following the
same pattern as `Control Champions`/`Control Owners`/`Assignment Controls`
all living directly under the Module.

**Doc ID convention:** `Approval_ID = "${controlId}_${championEmail}"` — the
same deterministic scheme as `Assignment_Controls`, so there is exactly one
Approval document per control+champion pair, **reused across resubmission
cycles** (confirmed with the user — Assignment Controls already preserves
full history via its own parallel lists, so a second, per-cycle history
here would just duplicate it). `Request_ID` (stored inside the document,
matching the `ControlModel.id`-in-doc convention) equals this same ID.
`Submission_ID` is a separate field holding the FK to the linked
`Assignment_Controls` document — equal to `Request_ID` in practice (both
derive from the same control+champion pair) but kept as two distinct fields
because that is how the schema was specified, and it keeps the door open
for the two IDs to diverge later without a schema change.

## `ApprovalModel` (Firestore model)

Follows the exact history-list pattern used by `AssignmentControlModel`:
every mutable field is a `List<T>`, index *i* is one revision, `copyWithUpdate`
appends a new revision reusing the previous value for anything not passed.

**Fixed fields** (set once at creation):

| Field | Firestore key |
|---|---|
| `requestId` | `Request_ID` |
| `submissionId` | `Submission_ID` |

**History-list fields:**

| Field | Firestore key | Dart type |
|---|---|---|
| `status` | `Status` | `List<String>` — `Pending\|Approved\|Rejected` |
| `reasonsOfRejection` | `Reasons_of_Rejection` | `List<String?>` |
| `approvalComments` | `Approval_Comments` | `List<String?>` — new field not in the user's literal schema text, added to store the optional Approve-time comment (confirmed with the user) |
| `modifier` | `Modifier` | `List<String>` |
| `modificationDate` | `Modification_Date` | `List<DateTime>` |

`ApprovalEntity` is the flat (`.last`-of-everything) counterpart, same shape
convention as `AssignmentControlEntity`.

**Lifecycle:**
- Champion Submit/Resubmit (via `AssignmentControlCubit.submitEvidence`,
  extended — see below): if no Approval doc exists yet, `ApprovalModel.create(...)`
  with `status: ['Pending']`; if one already exists (a prior cycle was
  rejected), `copyWithUpdate(status: 'Pending', editorEmail: championEmail)` —
  appending a fresh "Pending" revision, never erasing the prior Rejected one.
- Manager Approve → `copyWithUpdate(status: 'Approved', approvalComment: <optional>, editorEmail: managerEmail)`.
- Manager Reject → `copyWithUpdate(status: 'Rejected', reasonOfRejection: <required>, editorEmail: managerEmail)`.

Only `Pending` Approval documents can be acted on by a manager (business rule,
enforced in the UI by only showing the Approve/Reject actions when
`status.last == 'Pending'`, matching how Assignment Controls gates its own
Upload/Edit actions by tab).

## Integration into the existing Submit flow

**New pure function** `findDepartmentManagerEmail(List<EmployeeEntityPro> employees, {required String championEmail})`,
added alongside `findOwnerEmailForControl` in
`lib/features/grc/assignment_control/domain/entities/assignment_control_resolver.dart`
(or a new shared resolver file, decided at planning time):
1. Find the Champion's own `EmployeeEntityPro` by email to read their `departmentId`.
2. Scan `employees` for another employee sharing that `departmentId` whose
   `title?.trim().toLowerCase().startsWith('chief') == true`.
3. Return that employee's email, or `null` if the Champion isn't found or no
   "Chief*" peer exists in their department.

**`AssignmentControlCubit.submitEvidence` (existing, extended):**
1. *(already there)* resolve `ownerEmail` via `GetAllOwnersUseCase` + `findOwnerEmailForControl`.
2. *(new)* resolve `departmentManagerEmail` via `MainCoreEmployeeController.allEmployeesEntities`
   (same defensive `Get.isRegistered` guard `findEmployeeByEmail` already uses)
   + `findDepartmentManagerEmail`.
3. *(already there, extended)* call `SubmitEvidenceUseCase`, now also passing
   `departmentManagerEmail` so `AssignmentControlModel.create()`'s
   `departmentManager` field — hardcoded `null` today — gets populated.
   `copyWithUpdate` on resubmit leaves it untouched (a fixed field, same as
   `controlOwner`).
4. *(new)* on success, call a new `ApprovalCubit`/use-case (or a plain
   `ApprovalRepository` call injected into `AssignmentControlCubit`, decided
   at planning time) to create-or-update the linked Approval doc to
   `Pending`. This is a direct sibling call — **not** routed through
   `AssignmentControlRepository` — keeping the two features' repositories
   independent, mirroring how `ChampionCubit` already orchestrates
   `ChampionRepository` + `GrcRequestRepository` together without either
   repository knowing about the other.

## Manager-facing UI

**Entry point:** wire the already-stubbed "Approvals" button at
[grc_module_details_page.dart:338-345](../../../lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart#L338-L345)
to `ApprovalsListPage(module: GRCModuleEntity)`.

**Building the manager's list** (`ApprovalCubit.getMyApprovals({moduleId, managerEmail})`):
1. Fetch every Approval doc in the module (`ApprovalFirebaseDataSource.getAll`,
   mirroring `ChampionFirebaseDataSource.getAll`).
2. Keep only those whose `status.last == 'Pending'`.
3. For each, fetch its linked `Assignment_Controls` doc directly by ID
   (`Submission_ID` is that doc's key — reuses the existing
   `AssignmentControlDataSource.get`) and keep only where
   `assignmentControl.departmentManager == managerEmail`.
4. For each surviving pair, resolve its `PolicyEntity`/`ControlEntity` (same
   per-policy caching pattern already in `AssignmentControlCubit`) and the
   Champion's `EmployeeEntityPro` (via `findEmployeeByEmail`, for
   name/email/department display).
5. Emit a list of `ApprovalItem { approval, assignmentControl, control,
   policy, championEmail }`.

**`ApprovalsListPage`:** reuses the `FilterBarItem` status-row (just a
Pending count — Approved/Rejected requests leave the manager's queue
entirely once decided) and the 2-column grid + search bar already built for
Assignment Controls. Each card shows: Policy Name, Control Name, Champion
Name, Champion Email, Department, Submission Date, status badge.

**`ApprovalDetailsPage`:** reuses the Policy Details / Control Details card
layout already built for Assignment Controls (not rebuilt), plus a Champion/
Submission info block, plus **Approve** / **Reject** actions at the bottom:
- **Approve** → `showConfirmDialog` ("Approve this request?") → on Yes, an
  optional single-line comment prompt → `ApprovalCubit.approve(...)`.
- **Reject** → `showConfirmDialog` ("Reject this request?") → on Yes, a
  required reason field (blocks submit while empty) → `ApprovalCubit.reject(...)`.
- Both reuse the loading-spinner-on-button treatment and the
  refresh-list-before-pop pattern already built for Assignment Controls'
  submit flow.

## Error handling & testing

Same conventions as Assignment Controls: `Either<Failure, T>` from the
repository, no try/catch in the UI, `showErrorDialog`/`showSuccessDialog`/
`showConfirmDialog` (no SnackBars). Unit tests cover `ApprovalModel`
(create/copyWithUpdate/toJson/fromJson round-trip) and the two new pure
resolver functions (`findDepartmentManagerEmail`, and the manager-list
filter/join logic) — the same scope of testing as the Assignment Controls
spec, for the same reason (these are the only genuinely new pieces of
business logic; the data/repository/UI layers mirror already-built code).

## Open items carried to the future My Audits spec

- Control Owner's Approve/Reject step, and the final `Approved` status
  transition, is out of scope here — `In review` is this spec's terminal
  success state.
- `Approval_Comments` and `Reasons_of_Rejection` are declared now but only
  ever have at most one non-null entry each in practice (index 0 is always
  `null`, since the initial `Pending` revision has neither) — a future
  spec could tighten this if it ever needs multiple comments per approval.
