# GRC Request Details — Requester View — Design

## Overview

`GrcRequestDetailsPage` currently renders the same layout no matter who opens it: Approve/Reject buttons while `pending`, or a two-way (approved/else-treated-as-rejected) status banner once decided. It has no notion of "I am the person who submitted this request" — that distinction exists today only in `GrcRequestsListPage` via its `onlyRequestedBy` scoping param, which also backs that page's card-level Cancel button (`_canCancel` / `_onCancel`, using the already-implemented `GrcRequestCubit.cancelRequest`).

This change threads that same requester/approver distinction into the details page, so a requester opening their own pending request from "My Requests" sees a Cancel action and a read-only "Pending" status instead of Approve/Reject buttons meant for an approver.

## Goals

- `GrcRequestDetailsPage` knows whether it was opened from "My Requests" (`isMyRequest: true`) or from the general/approver requests list (`isMyRequest: false`).
- When `isMyRequest && status == pending`: no Approve/Reject buttons (a requester cannot approve their own request). A "Cancel" action appears top-right, next to the breadcrumb, gated by the same eligibility rule already used on the list page. A right-aligned "Pending" status banner appears where the action buttons would otherwise be.
- When `!isMyRequest && status == pending`: unchanged — Approve/Reject buttons, right-aligned.
- Any decided status (`approved` / `rejected` / `canceled`), regardless of viewer: a single right-aligned status banner, colored and labeled from `ApprovalStatus.color`/`.getName` (the existing shared source of truth), with the rejection reason appended only for `rejected`. This fixes today's bug where a `canceled` request — visible in "My Requests" since cancellation, unlike the module-wide view, doesn't hide canceled requests — falls into the banner's `else` branch and renders as `Rejected: ` with an empty reason.

## Non-goals

- No change to `GrcRequestsListPage`'s own card-level Cancel/status pill — it already works correctly; this spec only reads its existing rule to mirror on the details page.
- No new shared "status pill" widget. Only one file (`grc_request_details_page.dart`) needs this rendering, so its existing ad-hoc `Container`/`Text` styling is consolidated into a single private method there, not extracted to `lib/core/custom/`.
- No role/permission gating beyond the existing `isMyRequest` flag — matches this app's established no-gating convention elsewhere in the GRC request flow.
- No change to `_buildUnsupportedRequestTypeScaffold` — unreachable from the list page's `onTap` (which already filters to `request.type.isReassignment` before navigating), so out of scope.

## UI / behavior changes

### `GrcRequestDetailsPage` gains `required bool isMyRequest`

Threaded through `_GrcRequestDetailsBody` the same way `module`/`request` already are. The single existing call site, `GrcRequestsListPage`'s `_buildRequestCard` `onTap` (`grc_requests_list_page.dart` around line 196), passes `isMyRequest: widget.onlyRequestedBy != null`.

### Top row: breadcrumb + Cancel

In `_buildReassignmentScaffold`, `PaginationAppBar` moves into a `Row`:

```dart
Row(
  children: [
    Expanded(child: PaginationAppBar(screensTitles: [...])),
    if (_canCancel) _cancelButton(context),
  ],
),
```

`_canCancel` mirrors the list page's rule exactly:

```dart
bool get _canCancel =>
    widget.isMyRequest &&
    _request.status == ApprovalStatus.pending &&
    _request.startDate != null &&
    _request.startDate!.isAfter(DateTime.now());
```

`_cancelButton` is a small bordered pill (red border, "Cancel".tr text) matching the list page's existing Cancel pill styling, opening the same `showConfirmDialog` ("Cancel Request".tr / "Are you sure you want to cancel this request?".tr / "No".tr / "Yes".tr) and calling `context.read<GrcRequestCubit>().cancelRequest(moduleId: widget.module.moduleId, requestId: _request.id)` on confirm. The existing `BlocConsumer` listener (already updating `_request` on `GrcRequestActionSuccess`) picks up the resulting `canceled` status with no further wiring — the same mechanism that already refreshes the page after Approve/Reject.

### `_buildActionOrStatusSection` rewrite

```dart
Widget _buildActionOrStatusSection(BuildContext context) {
  if (_request.status == ApprovalStatus.pending && !widget.isMyRequest) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [ /* existing Reject + Approve buttons, unchanged */ ],
    );
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [_statusBanner(_request.status)],
  );
}

Widget _statusBanner(ApprovalStatus status) {
  final color = status.color;
  final text = status == ApprovalStatus.rejected
      ? '${'Rejected'.tr}: ${_request.rejectionReason ?? ''}'
      : status.getName;
  return Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(text,
        style: StyleText.fontSize14Weight500.copyWith(color: color)),
  );
}
```

`_statusBanner` handles `pending` (my-request case), `approved`, `rejected`, and `canceled` uniformly via the shared `ApprovalStatus.color`/`.getName` extensions already used elsewhere in the codebase as the single source of truth for status styling — no new enum branching to maintain here.

## Resolved decisions (from brainstorming)

- Requester/approver distinction is an explicit `required bool isMyRequest` param, not inferred by comparing emails inside the details page.
- Approve/Reject buttons are fully hidden (not disabled/grayed) when `isMyRequest && pending`.
- Cancel eligibility on the details page matches the list page exactly (`pending` + `startDate` in the future) rather than a looser `pending`-only check.
- `canceled` gets a real, correctly-labeled banner state as part of this change rather than a follow-up.
- Right-alignment uses `MainAxisAlignment.end` on a `Row`, matching the convention already established by the existing Approve/Reject row in this same file.

## Open items for the implementation plan

- Exact icon/spacing for the top-row Cancel pill relative to the breadcrumb on narrow (mobile) layouts vs. tablet (`PaginationAppBar` renders differently per `ContextExtension(context).isTablet`).
- Whether any test coverage exists/is expected for this page today (no existing widget tests found for `grc_request_details_page.dart`); if the project's test conventions call for one, scope it to the new `isMyRequest` branching and the `canceled` banner fix.
