# Assignment Controls (Control Champion) — Design

## Context

The GRC Module Details page has three stubbed buttons scoped to different roles in the
control-submission workflow: "Approvals" (Department Manager), "Assignment Controls"
(Control Champion), and "My Audits" (Control Owner). See
[grc_module_details_page.dart:338-364](../../../lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart#L338-L364).

This spec covers **only the Control Champion–facing "Assignment Controls" screen**:
where a champion opens it and sees every control they're personally responsible for,
grouped by workflow status, and can upload evidence / submit / resubmit.

"Approvals" (Department Manager) and "My Audits" (Control Owner) are explicitly **out of
scope** — they will be separate follow-up specs, reusing the same shared
`Assignment_Controls` Firestore model and `AssignmentControlEntity`, the same way Policy
and the Control Weight Issue mini-features were split from one shared Control model.

## Full workflow (for context — only the Champion actions below are built now)

1. **Pending** — Champion hasn't submitted evidence yet. Actions: Upload Evidence → Submit
   (waits on Department Manager) or (once rejected) Edit → replace evidence → Submit.
2. **Submitted** — waiting on the Department Manager's Approve/Reject decision.
3. **In Review** — Department Manager approved; waiting on the Control Owner's
   Approve/Reject (+ optional score) decision.
4. **Approved** — terminal positive state (both Manager and Owner approved).
5. **Rejected** — either role rejected; goes back to the Champion to edit and resubmit.
6. **Overdue** — the control's deadline (`ControlEntity.endDate`) has passed with no
   submission ever made. **Computed, never stored** — a Pending control becomes Overdue
   purely by date comparison at render time.

Steps 2-5's Manager/Owner-side actions (Approve/Reject/score) are out of scope for this
spec; they belong to the future Approvals/My Audits specs.

## Architecture

New feature folder `lib/features/grc/assignment_control/`, following the same Clean
Architecture layout as `control_champion/` and `control_owner/`:
`data/{data_source,repository,models}`, `domain/{entities,repository,use_cases}`,
`presentation/{controller,ui/pages}`.

Firestore path: `GRC_Modules/{Module_ID}/Assignment_Controls/{Assignment_Controls_ID}` —
a top-level subcollection under the Module (sibling of `Policies`, `Control_Champions`,
`Control_Owners`), since one assignment spans a Policy+Control pair by reference, not a
nested resource of either.

**Doc ID convention:** `Assignment_Controls_ID = "${controlId}_${championEmail}"` — a
deterministic ID (not a query), enabling a direct `.doc(id).get()` lookup instead of a
composite-index query. This value is also stored inside the document as the
`Submission_ID` field, mirroring how `ControlModel` stores its own `Controls_ID` inside
the document body in addition to being the Firestore key
([control_model.dart:60,78](../../../lib/features/grc/control/data/models/control_model.dart#L60)).

## Key decision: no pre-created documents

The Champion's list is **not** backed by a stored `Assignment_Controls` document until
they actually act. It's derived live by joining two already-existing data sources:

1. `ChampionModel(championEmail).assigningControls` → every `{policyId, controlId}`
   currently assigned to this champion (existing collection, no new writes).
2. `ControlModel` (via the existing `getAllControlsForPolicy` + `findControlInPolicy`
   helper already used by `control_champion_details_page.dart`) → control display
   details (name, description, `endDate`).

For each `{policyId, controlId}` pair, attempt to read
`Assignment_Controls/{controlId}_{championEmail}`:

- **Doc doesn't exist** → tab = `Overdue` if `control.endDate` has passed (compared at
  day granularity, matching `findExpiredControls`'s existing date-comparison style in
  [grc_assignment_lookup.dart](../../../lib/features/grc/shared/helpers/grc_assignment_lookup.dart)),
  else `Pending`.
- **Doc exists** → tab = derived from `status.last`: `Submitted` → "Submitted",
  `In review` → "In Review", `Rejected` → "Rejected", `Approved` → "Approved".

This avoids stale/duplicate documents when a champion is reassigned or a control is
edited — there's nothing to keep in sync until a real submission exists.

Tabs shown: **Pending, Submitted, In Review, Rejected, Approved, Overdue**. Only
Pending, Overdue, and Rejected are actionable by the Champion (Upload/Edit → Submit);
the rest are read-only status views.

## `AssignmentControlModel` (Firestore model)

Follows the exact history-list pattern used by `GRCModuleModel`/`ControlModel`/
`ChampionModel`: every mutable field is a `List<T>`, index *i* is one revision, and
`copyWithUpdate` appends a new revision reusing the previous value for anything not
explicitly changed. See `Code Quality Standards.md`'s Model Class guidance and the
`SingleValueTrackingModel` example.

**Fixed fields** (set once at creation, not history lists — matches the schema's
non-list fields):

| Field | Firestore key | Notes |
|---|---|---|
| `submissionId` | `Submission_ID` | = the doc's own ID (`controlId_championEmail`) |
| `controlChampionEmail` | `Control_Champion_Email` | |
| `policyId` | `Policy_ID` | shared key: `GrcFirestoreKeys.policyId` |
| `controlId` | `Control_ID` | |
| `controlOwner` | `Control_Owner` | resolved from `OwnerModel` the same way `ChampionModel` is resolved — the owner whose `assigningControls` contains this policy+control |
| `departmentManager` | `Department_Manager` | **`null` for now** — no dept-manager concept exists yet in the codebase (no `managerEmail` on `EmployeeEntity`, no department→manager mapping). Left as an explicit gap; the future Approvals spec must resolve this before it can query "my pending approvals" by manager email. |

**History-list fields** (index *i* = one revision — Submit, Reject, Resubmit, Approve...):

| Field | Firestore key | Dart type |
|---|---|---|
| `submissionDocument` | `Submission_Document` | `List<String>` — evidence file download URL per revision (Firebase Storage, same convention as `controlsDocumentEn`) |
| `submissionNote` | `Submission_Note` | `List<String>` |
| `status` | `Status` | `List<String>` — `Pending\|Submitted\|In review\|Rejected\|Approved` (Overdue is never stored) |
| `modifier` | `Modifier` | `List<String>` — acting user's email |
| `modificationDate` | `Modification_Date` | `List<DateTime>` |
| `departmentManagerRejectionReasons` | `Department_Manager_Reasons of Rejection` | `List<String?>` |
| `controlScore` | `Control_Score` | `List<double?>` |
| `controlOwnerJustifications` | `Control_Owner_Justifications` | `List<String?>` |
| `controlOwnerRejectionReasons` | `Control_Owner_Reasons of Rejection` | `List<String?>` |

The last four are declared now for schema completeness (so the future Approvals/My
Audits specs can read+write them without a migration), but **this feature never writes
them** — it only reads `status.last` and `departmentManagerRejectionReasons.last` (to
show the Champion why a submission was rejected).

**What this feature writes:**

- `AssignmentControlModel.create(...)` on first Submit → `status: ['Submitted']`,
  `submissionDocument: [url]`, `submissionNote: [note]`, `modifier: [championEmail]`,
  the four Manager/Owner-owned lists start as `[null]`.
- `copyWithUpdate(...)` on resubmit-after-rejection → appends `status: 'Submitted'`, new
  `submissionDocument`/`submissionNote`, `modifier: championEmail`,
  `modificationDate: now`; every other list (including the Manager/Owner-owned ones)
  reuses its last value — standard convention, no special reset semantics.

`AssignmentControlEntity` is the flat (`.last`-of-everything) counterpart, following
`ControlEntity`/`ChampionEntity`'s shape.

## UI flow

**Entry point:** wire the "Assignment Controls" button
([grc_module_details_page.dart:347-355](../../../lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart#L347-L355))
to navigate to `AssignmentControlsListPage(module: widget.module)`.

**Pages** (`assignment_control/presentation/ui/pages/`):

- `AssignmentControlsListPage` — `CustomTabs` ([10-custom_tabs.dart](../../../lib/core/custom/10-custom_tabs.dart)) with the 6 tabs above, each
  rendering a card per assigned control (name, number, status badge, deadline).
- `AssignmentControlDetailsPage` — the "Cards Detail" screen. Shows control info plus,
  if any, the latest submission's note/evidence/rejection reason. Actions depend on tab:
  - **Pending / Overdue:** "Upload Evidence" → `showUploadDialog(...)` (reused as-is,
    [10_custom_upload_document.dart](../../../lib/core/custom/10_custom_upload_document.dart)) + a note text field → "Submit" enabled once a file is picked.
  - **Rejected:** shows whichever of `departmentManagerRejectionReasons.last` /
    `controlOwnerRejectionReasons.last` is non-null (only one is ever set for a given
    rejection, since a submission is rejected by exactly one role at a time)
    read-only, plus "Edit" → same upload dialog, pre-cleared → "Submit" to resubmit.
  - **Submitted / In Review / Approved:** read-only — note/evidence/score/status, no
    actions.

**Cubit:** `AssignmentControlCubit` mirrors `ChampionCubit`'s state shape —
`AssignmentControlInitial/Loading/ListLoaded(List<AssignmentControlItem>)/
ActionSuccess/Failure(String)`, where `AssignmentControlItem` bundles
`{ControlEntity control, AssignmentControlEntity? assignment, computed tab}` (the join
result above). Two real actions: `getMyAssignmentControls(moduleId)` and
`submitEvidence(...)`.

**Data/Repository:** `AssignmentControlFirebaseDataSource` (get-by-id, create, update
against the deterministic doc ID) + reuses `PolicyStorageDataSource`
([policy_storage_data_source.dart](../../../lib/features/grc/policy/data/data_source/policy_storage_data_source.dart)) — add one method
`uploadAssignmentEvidence({moduleId, controlId, championEmail, file})` following the
exact same storage-path/upload-URL pattern as `uploadControlDocument`.

## Error handling

Follows `Code Quality Standards.md`: no try/catch in the UI. The data source and storage
upload call route through `ErrorHandler.handle` → `ApiErrorModel`; repository returns
`Either<Failure, T>`; cubit folds into `AssignmentControlFailure(message)`; UI shows
`showErrorDialog` (per the established GRC dialog convention — no SnackBars). A confirm
dialog precedes Submit, and `showSuccessDialog` follows a successful submit.

## Testing

Unit tests for `AssignmentControlModel` (create/copyWithUpdate/toJson/fromJson
round-trip, `_allSameLength` invariant) and for the list-derivation/join logic (pure
function: champion assignments + control + optional assignment doc → tab) — that join is
the one genuinely new piece of business logic. No new widget/integration tests beyond
the existing manual `/verify` smoke-test pattern used elsewhere in GRC.

## Open items carried to future specs

- **Department_Manager resolution** — no lookup exists yet; the field stays `null` until
  the Approvals spec defines and builds it.
- **Approvals (Department Manager)** and **My Audits (Control Owner)** screens — separate
  specs, reusing this same `AssignmentControlModel`/`AssignmentControlEntity`.
