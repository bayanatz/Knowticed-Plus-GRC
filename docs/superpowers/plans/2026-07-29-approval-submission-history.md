# Approval Submission History Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On `ApprovalDetailsPage` (the Department Manager's review view), show one card per distinct file the Champion has ever submitted for this Control (newest first), same as the sibling features already shipped for `MyAuditDetailsPage` (Control Owner) and `AssignmentControlDetailsPage` (Control Champion).

**Architecture:** Pure reuse — `SubmissionHistoryEntry`, `AssignmentControlModel.toSubmissionHistory()`, `GetSubmissionHistoryUseCase`, `AssignmentControlStatus.label`/`AssignmentControlStatusStyle`, and `SubmissionHistoryCubit` all already exist in `lib/features/grc/assignment_control/` and are already registered in `grc_get_it.dart`. This plan only wires the same `SubmissionHistoryCubit` into a third page. No domain/data/DI changes.

**Tech Stack:** Flutter, `flutter_bloc` (Cubit), `get_it`, `flutter_screenutil`.

## Global Constraints

- Prior art (do not re-derive, do not touch their files): `docs/superpowers/plans/2026-07-29-my-audit-submission-history.md` (original feature + the "why a dedicated Cubit, not the shared page cubit" rationale) and `docs/superpowers/plans/2026-07-29-assignment-control-submission-history.md` (first reuse). This is the second reuse, retargeted at `approval_details_page.dart`.
- No changes to `lib/features/grc/assignment_control/domain/`, `lib/features/grc/assignment_control/data/`, or `grc_get_it.dart` — every piece this plan needs already exists and is already registered there.
- `SubmissionHistoryCubit` must be a **new, independent instance** here (via `GetIt.instance<SubmissionHistoryCubit>()` in `initState`, same as the other two pages), never `context.read<SubmissionHistoryCubit>()` reused across pages — `ApprovalDetailsPage` shares its `ApprovalCubit` instance with the Approvals list page (`BlocProvider.value` in `approvals_list_page.dart:191-192`), the exact same shared-cubit hazard the original My Audit plan identified; `SubmissionHistoryCubit` must stay off that shared stream.
- Delta vs. both prior pages: `ApprovalItem.assignmentControl` is **non-nullable** (an Approval only ever exists once a submission was made — see `approval_item.dart`), so `initState` does not need a null-guard before calling `loadHistory` the way the other two pages do.
- Delta vs. both prior pages: the bottom action row keeps this page's own existing Approve/Reject buttons (`_onApprovePressed`/`_onRejectPressed` on `ApprovalCubit`) and non-pending `GrcStatusPill` (of `widget.item.approval.status`) — same shape as the *original* My Audit page's bottom row, not the Assignment Control page's Upload/Resubmit button.
- The page's current rejection-reason display reads `widget.item.approval.reasonOfRejection` (a separate `ApprovalEntity`/document, analogous to `MyAuditEntity`). Per the original design's decision, per-card rejection reason comes from each `SubmissionHistoryEntry.rejectionReason` (sourced from `AssignmentControlModel`'s own index-aligned list) instead — do not wire anything to `widget.item.approval.reasonOfRejection` in the new cards.
- This repo has no widget-test infrastructure for GRC pages — this task is verified via `puro flutter analyze` plus a manual walkthrough, no automated test.

---

### Task 1: Wire the stacked cards into `ApprovalDetailsPage`

**Files:**
- Modify: `lib/features/grc/approval/presentation/ui/pages/approval_details_page.dart`

**Interfaces:**
- Consumes (all pre-existing, no changes): `SubmissionHistoryCubit`/`SubmissionHistoryState`/`SubmissionHistoryInitial`/`Loading`/`Loaded(entries)`/`Failure(message)` (`lib/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart`), `SubmissionHistoryEntry` (`lib/features/grc/assignment_control/domain/entities/submission_history_entry.dart`), `AssignmentControlStatus`/`.label`/`AssignmentControlStatusStyle` (`lib/features/grc/assignment_control/domain/entities/assignment_control_status.dart`).
- Produces: no new public interface — leaf UI consumer, same as the other two pages.

- [ ] **Step 1: Add imports**

Add these to the top of `approval_details_page.dart`, alongside the existing imports:

```dart
import 'package:get_it/get_it.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
```

(Do not import `submission_history_entry.dart` directly — its type is only ever used via inference, e.g. `final entries = historyState.entries;`, never written out literally in code, so a direct import would be flagged as unused, same as happened on the Assignment Control page's first pass.)

- [ ] **Step 2: Add the Cubit field and lifecycle wiring**

Add a field to `_ApprovalDetailsPageState`, right after `int _approvalsTab = 0; // 0 = Approvals, 1 = Inquires`:

```dart
  late final SubmissionHistoryCubit _historyCubit;
```

Add these two overrides to `_ApprovalDetailsPageState` (e.g. right before `_onApprovePressed`):

```dart
  @override
  void initState() {
    super.initState();
    _historyCubit = GetIt.instance<SubmissionHistoryCubit>();
    _historyCubit.loadHistory(
      moduleId: widget.module.moduleId,
      controlId: widget.item.control.id,
      championEmail: widget.item.assignmentControl.controlChampionEmail,
    );
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }
```

(No null-check here — `widget.item.assignmentControl` is non-nullable, unlike the other two pages.)

- [ ] **Step 3: Replace the single-submission block with the stacked-cards `BlocBuilder`**

Find this block inside the `build` method (the `else` branch right after `if (_approvalsTab == 1) GrcSectionCard(...) else`):

```dart
                        else
                          GrcSectionCard(children: [
                            GrcSubmitterRow(email: championEmail),
                            SizedBox(height: 8.h),
                            Text(
                              '${'Submission Date'.tr}: '
                              '${_cardDateFormat.format(assignmentControl.lastModificationDate)} '
                              '${'At'.tr} '
                              '${_cardTimeFormat.format(assignmentControl.lastModificationDate)}',
                              style: CardStyles.label(12),
                            ),
                            SizedBox(height: 12.h),
                            if (assignmentControl.submissionDocument.isNotEmpty)
                              ProductWarrantyCard(
                                fileName: assignmentControl.submissionDocument
                                    .split('/')
                                    .last
                                    .split('?')
                                    .first,
                                onTapFile: () => openGrcDocument(
                                    assignmentControl.submissionDocument),
                              ),
                            SizedBox(height: 12.h),
                            if (assignmentControl
                                .submissionNote.isNotEmpty) ...[
                              GrcLabelValueRow('Submission Notes'.tr,
                                  assignmentControl.submissionNote),
                              SizedBox(height: 12.h),
                            ],
                            if (widget.item.approval.reasonOfRejection !=
                                    null &&
                                widget.item.approval.reasonOfRejection!
                                    .isNotEmpty) ...[
                              GrcLabelValueRow(
                                'Reasons of Rejection'.tr,
                                widget.item.approval.reasonOfRejection!,
                                color: Colors.red,
                              ),
                              SizedBox(height: 12.h),
                            ],
                            SizedBox(height: 8.h),
                            if (isPending)
                              isSaving
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: GrcButtonLoadingPlaceholder(
                                        width: 120.w,
                                        height: 44.h,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        customButton(
                                          width: 120.w,
                                          title: 'Reject'.tr,
                                          function: () =>
                                              _onRejectPressed(context),
                                          color: AppColors.red,
                                          textStyle: StyleText
                                              .fontSize16Weight500
                                              .copyWith(
                                                  color: AppColors.textButton),
                                        ),
                                        SizedBox(width: 12.w),
                                        customButton(
                                          width: 120.w,
                                          title: 'Approve'.tr,
                                          function: () =>
                                              _onApprovePressed(context),
                                          color: AppColors.primary,
                                          textStyle: StyleText
                                              .fontSize16Weight500
                                              .copyWith(
                                                  color: AppColors.textButton),
                                        ),
                                      ],
                                    )
                            else
                              Align(
                                alignment: Alignment.centerRight,
                                child: GrcStatusPill(
                                  label: widget.item.approval.status.value.tr,
                                  color: style.color,
                                  icon: style.icon,
                                ),
                              ),
                          ]),
```

Replace it with:

```dart
                        else
                          Column(
                            children: [
                              BlocBuilder<SubmissionHistoryCubit,
                                  SubmissionHistoryState>(
                                bloc: _historyCubit,
                                builder: (context, historyState) {
                                  if (historyState
                                      is SubmissionHistoryFailure) {
                                    return GrcSectionCard(children: [
                                      Text(
                                        historyState.message,
                                        style: CardStyles.value(12)
                                            .copyWith(color: Colors.red),
                                      ),
                                    ]);
                                  }
                                  if (historyState
                                      is! SubmissionHistoryLoaded) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 24.h),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary),
                                      ),
                                    );
                                  }
                                  final entries = historyState.entries;
                                  return Column(
                                    children: [
                                      for (final entry in entries) ...[
                                        GrcSectionCard(children: [
                                          GrcSubmitterRow(email: championEmail),
                                          SizedBox(height: 8.h),
                                          Text(
                                            '${'Submission Date'.tr}: '
                                            '${_cardDateFormat.format(entry.submittedDate)} '
                                            '${'At'.tr} '
                                            '${_cardTimeFormat.format(entry.submittedDate)}',
                                            style: CardStyles.label(12),
                                          ),
                                          SizedBox(height: 12.h),
                                          if (entry.document.isNotEmpty)
                                            ProductWarrantyCard(
                                              fileName: entry.document
                                                  .split('/')
                                                  .last
                                                  .split('?')
                                                  .first,
                                              onTapFile: () =>
                                                  openGrcDocument(entry.document),
                                            ),
                                          SizedBox(height: 12.h),
                                          if (entry.note.isNotEmpty) ...[
                                            GrcLabelValueRow(
                                                'Submission Notes'.tr,
                                                entry.note),
                                            SizedBox(height: 12.h),
                                          ],
                                          if (entry.status ==
                                                  AssignmentControlStatus
                                                      .rejected &&
                                              (entry.rejectionReason
                                                      ?.isNotEmpty ??
                                                  false)) ...[
                                            GrcLabelValueRow(
                                              'Reasons of Rejection'.tr,
                                              entry.rejectionReason!,
                                              color: Colors.red,
                                            ),
                                            SizedBox(height: 12.h),
                                          ],
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: GrcStatusPill(
                                              label: entry.status.label.tr,
                                              color:
                                                  AssignmentControlStatusStyle
                                                          .of(entry.status)
                                                      .color,
                                              icon: AssignmentControlStatusStyle
                                                      .of(entry.status)
                                                  .icon,
                                            ),
                                          ),
                                        ]),
                                        SizedBox(height: 12.h),
                                      ],
                                    ],
                                  );
                                },
                              ),
                              SizedBox(height: 8.h),
                              if (isPending)
                                isSaving
                                    ? Align(
                                        alignment: Alignment.centerRight,
                                        child: GrcButtonLoadingPlaceholder(
                                          width: 120.w,
                                          height: 44.h,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          customButton(
                                            width: 120.w,
                                            title: 'Reject'.tr,
                                            function: () =>
                                                _onRejectPressed(context),
                                            color: AppColors.red,
                                            textStyle: StyleText
                                                .fontSize16Weight500
                                                .copyWith(
                                                    color:
                                                        AppColors.textButton),
                                          ),
                                          SizedBox(width: 12.w),
                                          customButton(
                                            width: 120.w,
                                            title: 'Approve'.tr,
                                            function: () =>
                                                _onApprovePressed(context),
                                            color: AppColors.primary,
                                            textStyle: StyleText
                                                .fontSize16Weight500
                                                .copyWith(
                                                    color:
                                                        AppColors.textButton),
                                          ),
                                        ],
                                      )
                              else
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GrcStatusPill(
                                    label: widget.item.approval.status.value.tr,
                                    color: style.color,
                                    icon: style.icon,
                                  ),
                                ),
                            ],
                          ),
```

Note: `widget.item.approval.reasonOfRejection` is no longer referenced anywhere in this block — that's expected, its former use is superseded by each card's own `entry.rejectionReason`. `ApprovalEntity`'s `reasonOfRejection` field/import stay untouched elsewhere in the codebase; this task only stops reading it in this one spot.

- [ ] **Step 4: Verify with static analysis**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/approval/`
Expected: no errors and no unused-import/unused-variable warnings this time (unlike the other two pages, nothing here becomes dead: `championEmail`, `assignmentControl`, and `isPending` are all still used elsewhere in `build`).

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/approval/presentation/ui/pages/approval_details_page.dart
git commit -m "feat(grc): show one card per submitted file on the Approval details page"
```

---

### Task 2: Manual walkthrough

**Files:** none (verification only).

- [ ] **Step 1: Manual walkthrough**

With a Flutter environment connected to the real/staging Firestore project, as the Department Manager:
1. Open a pending Approval — confirm exactly 1 card shows (the Champion's first submission), "Submitted" pill, no rejection reason, Approve/Reject buttons still below the card(s).
2. Reject it with a reason.
3. As the Champion, resubmit a different file + note for the same Control.
4. As the Manager, reopen the same Approval (it should be back in the pending list once resubmitted — verify against existing Approval re-pending behavior, unrelated to this task) — confirm **2 cards** show, newest (the resubmission, "Submitted") on top, the original rejected file below it with its reason, and Approve/Reject buttons still work.
5. Approve it — confirm the success dialog and that the item leaves the pending list, same as before this change.

No commit for this task (verification only).
