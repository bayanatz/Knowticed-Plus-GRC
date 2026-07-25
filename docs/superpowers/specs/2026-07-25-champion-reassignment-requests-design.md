# Champion Reassignment Requests — Design

## Overview

Turn `ReassignChampionPage` from an immediate-effect action into a request/approval workflow. Reassigning a Control Champion no longer mutates champion data on submit — it creates a request. Once approved, the actual transfer of controls from the old champion to the new one is deferred until the request's Start Date arrives; the new champion's End Date (optional) later causes those specific controls to auto-expire back to unassigned. A new module-scoped "Requests" list/details UI (wired from the previously-stubbed `Requests` button on the Control Champions tab) lets someone review, approve, or reject pending requests, with rejection requiring a written reason.

The request framework is built generically (a `GrcRequestType` discriminator, a shared list/details/status shape) so a second request type (`controlChanges`, seen as a card type in the reference mockups) can be added later without redesigning the list/approve/reject machinery. Only `reassignChampion` gets a working create flow, details view, and business logic in this pass — `controlChanges` is a reserved enum value with no creation entry point; if a details page for it is ever opened it renders a simple "not supported" placeholder rather than speculative fields/logic.

## Goals

- Reassigning a champion creates a `pending` request instead of an immediate change.
- A request can be Approved or Rejected. Rejection requires a written reason (reusing the existing, currently-unused `showCommentDialog`).
- Approval does not itself move any controls. The move happens automatically once the request's Start Date has arrived, discovered via a recompute-on-read check (this app has no background job/cron anywhere; every other "future date" case — Control/Policy `Scheduled` status — is handled the same way).
- If the request's End Date is set, the controls the new champion received from that specific request auto-expire (become unassigned) once that date passes — also recompute-on-read.
- A "Requests" list page (module-scoped) with All/Approved/Pending/Rejected count tabs and a search bar, plus a request details page with Approve/Reject actions, wired from the existing stub button.

## Non-goals

- `controlChanges` request type: no creation flow, no business logic. Reserved enum value only.
- Role/permission gating on who can Approve/Reject — anyone who opens the details page can act on a pending request (matches this demo app's existing lack of gating elsewhere).
- A generic notification/messaging system — the existing "Message" pill buttons stay stubs where already stubbed.
- Any real scheduler/cron job. Deferred effects are entirely recompute-on-read.

## Data model

### Reused: `ApprovalStatus`

`lib/core/enums/approval_status.dart` already defines `enum ApprovalStatus { all, approved, pending, rejected, canceled }` with `getName`/`getOrderName` extensions. Requests reuse this directly for their `status` field. Only `pending`/`approved`/`rejected` are ever persisted; `all` is a UI-only aggregate filter tab; `canceled` is unused.

### New: `GrcRequestType`

```dart
enum GrcRequestType { reassignChampion, controlChanges }
```

With `.value`/`fromString` following the same convention as `ChampionStatus`.

### New: `GrcRequestEntity`

One flat entity — not a sealed/subclassed hierarchy. `controlChanges` has no defined fields yet, so introducing a class hierarchy for it now would be speculative; the reassign-specific fields are simply nullable and unused by any future `controlChanges` request until that type is actually designed.

```dart
class GrcRequestEntity {
  final String id;
  final String moduleId;
  final GrcRequestType type;
  final ApprovalStatus status;
  final String requestedBy;       // email of whoever submitted the request
  final DateTime requestDate;
  final String note;

  // Decision metadata — null until decided
  final String? rejectionReason;
  final String? decidedBy;
  final DateTime? decisionDate;

  // Reassign-specific (null/unused for other request types)
  final String? currentChampionEmail;
  final String? newChampionEmail;
  final List<AssigningControlEntity>? controls;
  final DateTime? startDate;
  final DateTime? endDate;

  // Deferred-application bookkeeping — null until the recompute-on-read
  // transfer has actually run
  final DateTime? appliedAt;
}
```

### Changed: `AssigningControlEntity` gains `expiresOn`

Today: `{ policyId, controlId }` only — no dates anywhere on this entity. Add one nullable field:

```dart
class AssigningControlEntity {
  final String policyId;
  final String controlId;
  final DateTime? expiresOn; // set only when this control arrived via an applied reassignment request with an End Date
}
```

Manually-assigned controls (via `add_champion_page.dart` / `edit_champion_controls_page.dart`) leave `expiresOn` null and never expire. Mirrored in `AssigningControlModel`.

### Storage

Nested per module, mirroring the champions path convention:

```
GRC Modules/{moduleId}/Champion Requests/{requestId}
```

A request is a single decided event (create → optionally approve/reject once) — no revision-history-of-lists like `ChampionModel`/`PolicyModel` use. A plain document with mutable `status`/`rejectionReason`/`decidedBy`/`decisionDate`/`appliedAt` fields is sufficient.

### Repository / use cases

`GrcRequestRepository`:
- `createRequest(...) → GrcRequestEntity`
- `getRequestsForModule(moduleId) → List<GrcRequestEntity>`
- `approveRequest(requestId, decidedBy)`
- `rejectRequest(requestId, decidedBy, reason)`
- `markApplied(requestId)`

Thin use-case wrappers matching the `Champion`/`Policy` convention: `CreateGrcRequestUseCase`, `GetGrcRequestsUseCase`, `ApproveGrcRequestUseCase`, `RejectGrcRequestUseCase`.

`GrcRequestCubit` (states: `Initial`, `Loading`, `ListLoaded(requests)`, `ActionSuccess`, `Failure(message)`), exposing `getRequestsForModule`, `createRequest`, `approveRequest`, `rejectRequest`.

## Business logic: recompute-on-read

Hooked into `ChampionCubit.getAllChampions()` — the single existing read path already used by every champion-list-consuming screen (so both mechanics apply everywhere consistently, without touching individual callers). Before returning results for a module:

1. **Apply due transfers.** Fetch the module's requests. For each with `status == approved`, `appliedAt == null`, and `startDate <= today`, run `ApplyChampionReassignmentUseCase` (the logic currently living in `reassign_champion_page.dart`'s `_submit()`, extracted and reused):
   - Remove the request's `controls` from `currentChampionEmail`'s `assigningControls`.
   - Add them to `newChampionEmail`'s `assigningControls`, each tagged `expiresOn = request.endDate` (creating the new champion record if none exists yet, same fallback the current code already has).
   - Persist both champion writes, then set the request's `appliedAt = now`.
   - `appliedAt` is the idempotency guard — `getAllChampions()` may run this check many times; each request is only applied once.

2. **Strip expired controls.** For every champion in the module, find any `assigningControls` entries whose `expiresOn` has passed (`today >= expiresOn`) and remove them, persisting the champion document write-back (not just an in-memory filter — every future reader must see it gone, matching how the transfer step itself writes back rather than only computing a display value).

Both checks live in a new pure-logic module mirroring the naming/style of `control_status_resolver.dart` (e.g. `champion_request_resolver.dart`), called from the cubit around the existing data-source fetch.

## UI

1. **Wire the stub.** `grc_module_details_page.dart:754-757`'s `CustomButton(buttonText: 'Requests', onTap: () {})` navigates to `GrcRequestsListPage(module: ...)`.

2. **`GrcRequestsListPage`** — module-scoped (per the breadcrumb `GRC > {Module} > Requests`). Breadcrumb, 4 count chips (All/Approved/Pending/Rejected — client-side filter over one loaded list from `GrcRequestCubit`), search bar (substring match on champion/requester name), card grid. Each card: Request Type label, Request Date, `GrcOwnerBadge` fed from `module.moduleOwners` with `label: 'Department Manager:'`, truncated Request Note, status pill. The secondary filter icon next to search stays an unwired stub, matching this page's own established convention elsewhere for not-yet-specified advanced filters.

3. **`GrcRequestDetailsPage`** — Current Control Champion card vs New Control Champion card, reusing the existing name/photo/department/title lookup helpers already written in `reassign_champion_page.dart` (`_findEmployee`, `_employeeDisplayName`, `EmployeeHelper.*`). Read-only Start/End Date, read-only Request Note, read-only Assigned Controls chips (resolved the same way the existing page resolves them via `policyControls`). If `status == pending`: Approve/Reject buttons. If already decided: a read-only status banner replaces the buttons (showing the stored rejection reason when rejected).

4. **Reject flow** — reuses `showCommentDialog` from `lib/core/custom/11_custom_confirm_diaolog.dart:365-494` (the "Reason Of Rejection" / "Justifications" / 500-char-counter / Submit dialog — built previously but never wired to any caller). Submitting calls `GrcRequestCubit.rejectRequest(requestId, reason)`.

5. **Approve flow** — Approve button calls `GrcRequestCubit.approveRequest(requestId)` directly (simple confirm, no reason capture, matching the mockup). Only flips status — the actual transfer still waits for Start Date via the recompute-on-read mechanics above.

6. **Rewire `ReassignChampionPage`.** `_submit()` no longer touches champion data. It validates the form (adds a new required check: "Please choose a start date" — today `_startDate` is picked but silently discarded) and calls `GrcRequestCubit.createRequest(...)` with the current champion, new champion, `_reassignedControls`, note, start/end dates. On success: "Request submitted" snackbar, pop. The direct `UpdateChampionUseCase`/`CreateChampionUseCase`/`GetChampionUseCase` calls currently in this file's `_submit()` are deleted from here (their logic moves into `ApplyChampionReassignmentUseCase`, called only from the recompute-on-read path).

## Resolved decisions (from brainstorming)

- Generic request framework (not reassign-only) — enables a future `controlChanges` type without redesign.
- Transfer timing: recompute-on-read, consistent with existing Control/Policy `Scheduled` status pattern — no cron/scheduler.
- Approve/Reject: no role gating, anyone opening the details page can act.
- End Date behavior: auto-expire (become unassigned), not revert-to-previous-champion.
- Expiry persistence: physically rewritten to Firestore, not an in-memory-only filter.
- Requests list scope: current module only.
- "Department Manager" field: sourced from `GRCModuleEntity.moduleOwners` via the existing `GrcOwnerBadge` widget.

## Open items for the implementation plan

- Exact Firestore field names/encoding for `GrcRequestModel` (flat document, no history-list encoding needed).
- Whether `getAllChampions()`'s recompute pass needs a lightweight in-flight/re-entrancy guard if called concurrently from multiple widgets during a single frame.
- Test coverage for: request creation, approve/reject transitions, the two recompute-on-read behaviors (transfer-on-start-date, expiry-on-end-date) including idempotency of `appliedAt`.
