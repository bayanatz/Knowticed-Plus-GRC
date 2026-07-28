# My Audits (Control Owner) — Design

## Context

This is the third and final role-scoped mini-feature sharing the `Assignment_Controls`
workflow, completing the chain started by the
[Assignment Controls](2026-07-27-assignment-controls-champion-design.md) (Champion) and
[Approvals](2026-07-28-approvals-design.md) (Department Manager) specs. It builds the
Control Owner's review step: opening a Department-Manager-approved request, approving or
rejecting it, and — once approved — giving it a score.

**Explicitly out of scope:** the weighted score rollup formula (Module → Policy →
Control → Department weights → Final Module Score) the user described as long-term
business logic. It is documented here for future reference but not built, because
`Assignment_Controls` has no per-submission Department field yet (a Control spanning
multiple Departments currently produces one `Assignment_Controls` doc per Champion with
no Department tag), so a correct rollup isn't possible without a further schema change.
That belongs to a future Dashboard spec — confirmed with the user.

## Full corrected workflow

The user's initial message described a workflow that turned out, on clarification, to
have an extra step. This is the confirmed, final version:

```
Champion Submit → Assignment_Controls.status = Submitted
Department Manager Approves (Approvals feature, extended) →
    Assignment_Controls.status = In review
    My_Audit created-or-reset: status = Pending
Control Owner opens the request → sees Approve/Reject:
    Reject (reason required) → My_Audit.status = Rejected
                                 → Assignment_Controls.status = Rejected → back to Champion
    Approve                   → My_Audit.status = Outstanding (ready to score, no score yet)
Control Owner adds a score (from Outstanding) →
    My_Audit.status = Scored
    → Assignment_Controls.status = Approved (terminal — the 6-state Champion workflow's
      final state)
"Edit Score" available any time after Scored → re-opens the same dialog, appends a new
  revision, stays Scored
```

`Pending` and `Outstanding` are two genuinely distinct states (confirmed after an initial
ambiguity): `Pending` = the Owner hasn't acted on the request at all yet (no
Approve/Reject decision made); `Outstanding` = the Owner already approved it and it's
now ready for scoring, but no score has been entered.

Tabs on the Owner's list: **All / Outstanding / Pending / Scored / Rejected / Overdue**.
`Overdue` is derived, never stored (see "Building the Owner's list" below) — it means the
Champion never submitted at all, so no Approval/My_Audit chain exists for that control.

## `MyAuditModel` (Firestore model)

Firestore path: `GRC Modules/{Module_ID}/My Audit/{My_Audit_ID}`, sibling to `Approvals`
and `Assignment Controls`. Doc ID: `"${controlId}_${championEmail}"` — same deterministic
scheme as the other two features, one document per control+champion pair, reused across
resubmission cycles.

**Fixed fields:**

| Field | Firestore key | Meaning |
|---|---|---|
| `auditId` | `Audit_ID` | the doc's own ID (self-reference, matching `ControlModel.id`-in-doc convention) |
| `requestId` | `Request_ID` | FK to the linked `Approvals` document |
| `submissionId` | `Submission_ID` | FK to the linked `Assignment_Controls` document |

**History-list fields** (index *i* = one revision):

| Field | Firestore key | Dart type |
|---|---|---|
| `status` | `Status` | `List<String>` — `Pending\|Outstanding\|Scored\|Rejected` (`Overdue` is never persisted) |
| `controlScore` | `Control_Score` | `List<double?>` |
| `controlOwnerJustifications` | `Control_Owner_Justifications` | `List<String?>` |
| `controlOwnerReasonsOfRejection` | `Control_Owner_Reasons_of_Rejection` | `List<String?>` |
| `modifier` | `Modifier` | `List<String>` |
| `modificationDate` | `Modification_Date` | `List<DateTime>` |

`MyAuditEntity` is the flat (`.last`-of-everything) counterpart, same shape convention as
`ApprovalEntity`/`AssignmentControlEntity`.

**Lifecycle / who writes what:**
- **Approvals feature, extended:** when a manager approves a request (`ApprovalCubit.approve`,
  already built), after its existing `applyManagerDecision` call it now *also*
  creates-or-resets the linked `My_Audit` doc to `status: 'Pending'` (mirrors how
  `AssignmentControlCubit.submitEvidence` already creates/resets the linked `Approval`
  doc to `Pending` on submit — same pattern, one layer further down the chain).
- **Owner Reject** (from Pending) → `MyAuditModel.copyWithUpdate(status: 'Rejected',
  reasonOfRejection: <required>)` + `AssignmentControlRepository.applyManagerDecision(
  newStatus: AssignmentControlStatus.rejected, rejectionReason: ...)` — the exact same
  repository method Approvals already uses; no Assignment Controls change needed for
  this transition.
- **Owner Approve** (Pending → Outstanding) → `copyWithUpdate(status: 'Outstanding')`
  only. Assignment Controls stays `In review` — nothing to write there yet, since no
  score exists.
- **Owner Add/Edit Score** (Outstanding or Scored → Scored) → `copyWithUpdate(status:
  'Scored', controlScore: <required>, controlOwnerJustification: <optional>)` + a **new**
  `AssignmentControlRepository.applyOwnerScore(...)` method that writes
  `Assignment_Controls.Control_Score`/`Control_Owner_Justifications` (fields already
  declared on `AssignmentControlModel` since the very first spec, unused until now) and
  sets `status = AssignmentControlStatus.approved` (the terminal state of the whole
  6-state Champion workflow).

## Building the Owner's list

`MyAuditCubit.getMyAudits({moduleId, ownerEmail})`:
1. Fetch every `My_Audit` doc in the module (`MyAuditFirebaseDataSource.getAll`,
   mirroring `ApprovalFirebaseDataSource.getAll`).
2. For each, fetch its linked `Assignment_Controls` doc by raw ID
   (`GetAssignmentControlByIdUseCase`, already built for Approvals) and keep only where
   `assignmentControl.controlOwner == ownerEmail`.
3. Resolve each surviving pair's `Control`/`Policy` via the same per-policy caching
   pattern already used by Assignment Controls and Approvals.
4. **Derived Overdue set:** fetch this Owner's own `OwnerModel` (`GetOwnerUseCase`,
   existing) → `assigningControls`. For each `{policyId, controlId}` pair with **no**
   linked `Assignment_Controls` doc at all (nothing surfaced in step 2), compare
   `control.endDate` to today at day granularity (same comparison already used in
   `computeAssignmentControlTab`) — if passed, synthesize a read-only Overdue row.
5. Emit the combined list; the list page's tabs filter client-side, exactly like the
   other two features' list pages.

`MyAuditItem`: `{ MyAuditEntity? audit, AssignmentControlEntity? assignmentControl,
ControlEntity control, PolicyEntity policy }` — `audit` and `assignmentControl` are both
null only for a derived-Overdue row (nothing to open or act on).

## UI: list, details, actions

**Entry point:** wire the already-stubbed "My Audits" button on
[grc_module_details_page.dart](../../../lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart)
to `MyAuditsListPage(module)`.

**`MyAuditsListPage`:** same shell as the Approvals list page — breadcrumb with module
name, `FilterBarItem` status row with live counts (All/Outstanding/Pending/Scored/
Rejected/Overdue), search bar, 2-column grid — reusing every shared widget already
extracted (`GrcStatusPill`, `GrcScoreBadge`, `GrcSectionCard`, etc.). Card: Control Name,
Policy Name, Control Champion (avatar), Request Date, Score badge when scored, status
pill (colors: Pending = amber/`schedule`, Outstanding = amber/`hourglass_bottom`, Scored
= green/`check_circle`, Rejected = red/`block`, Overdue = red/`alarm`).

**`MyAuditDetailsPage`:** reuses the Policy Details / Control Details cards verbatim
(both Control Owner and Control Champion shown via `GrcContactInlineRow`, same as
Approvals). The bottom section's title is **"Submission"** (not "Approvals") with the
same "Submission | Inquires" sub-tab toggle (`GrcSectionSubTabs`, reused). Action area
depends on state:
- **Pending:** Reject/Approve buttons. Confirm dialogs: **"Reject Evidence"/"Approve
  Evidence"** titles (distinct wording from Approvals' "Reject Document"/"Approve
  Request" — confirmed from the user's mockups), success dialogs say "Successfully
  Rejected/Approved This Evidence". Reject's reason dialog: title "Reason Of Rejection",
  field "Justifications" (same `showCommentDialog` reuse as Approvals).
- **Outstanding:** shows the status pill **and** an "Add Score" button *together* (unlike
  Approvals, where the pill replaces the action buttons once decided — confirmed
  distinct behavior from the mockup) → opens a "Give a Score" dialog (a required Score
  field + an optional Justifications field) → Submit.
- **Scored:** shows the Score badge + status pill + an "Edit Score" button that reopens
  the same dialog pre-filled with the current score/justification.
- **Rejected:** shows the rejection reason, read-only, just the status pill.
- **Overdue (derived row):** read-only informational card ("No submission was made
  before the deadline") — no Submission section content and no actions, since nothing
  was ever submitted.

## Error handling & testing

Same conventions as the other two GRC mini-features: `Either<Failure, T>` from
repositories, no try/catch in the UI, `showConfirmDialog`/`showCommentDialog`/
`showSuccessDialog`/`showErrorDialog` (no SnackBars). Unit tests cover `MyAuditModel`
(create/copyWithUpdate/toJson/fromJson round-trip) and the list-building/derived-Overdue
resolver logic — the same scope as the other two specs, for the same reason (these are
the only genuinely new pieces of business logic; the data/repository/UI layers mirror
already-built code).

## Open items carried to a future Dashboard spec

- The full weighted score rollup (Module → Policy → Control → Department weights →
  Final Module Score) described by the user, including the need to add a per-submission
  Department field to `Assignment_Controls` before a Control spanning multiple
  Departments can be scored/rolled-up correctly per Department.
- No field currently exists on `GRCModuleEntity`/`GRCModuleModel` to store a
  Module-level rolled-up compliance score — a future spec would need to add one.
