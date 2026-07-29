# Assignment Control Submission History Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On `AssignmentControlDetailsPage` (the Control Champion's own view of their submission), show one card per distinct file the Champion has ever submitted for this Control (newest first), same as the sibling feature already shipped for `MyAuditDetailsPage` (the Control Owner's review view).

**Architecture:** Pure reuse — `SubmissionHistoryEntry`, `AssignmentControlModel.toSubmissionHistory()`, `GetSubmissionHistoryUseCase`, `AssignmentControlStatus.label`/`AssignmentControlStatusStyle`, and `SubmissionHistoryCubit` all already exist in `lib/features/grc/assignment_control/` (built for the My Audit feature, but scoped to the Assignment Control entity itself — not My-Audit-specific) and are already registered in `grc_get_it.dart`. This plan only wires the same `SubmissionHistoryCubit` into a second page. No domain/data/DI changes.

**Tech Stack:** Flutter, `flutter_bloc` (Cubit), `get_it`, `flutter_screenutil`.

## Global Constraints

- Design/prior art: `docs/superpowers/specs/2026-07-29-my-audit-submission-history-design.md` and `docs/superpowers/plans/2026-07-29-my-audit-submission-history.md` — this plan mirrors that one's Task 5 exactly, retargeted at `assignment_control_details_page.dart`. Do not re-derive the grouping algorithm or touch any file from that plan.
- No changes to `lib/features/grc/assignment_control/domain/`, `lib/features/grc/assignment_control/data/`, or `grc_get_it.dart` — every piece this plan needs already exists and is already registered there.
- `SubmissionHistoryCubit` must be a **second, independent instance** here (via `GetIt.instance<SubmissionHistoryCubit>()` in `initState`, same as `MyAuditDetailsPage`), never `context.read<SubmissionHistoryCubit>()` reused across pages — each page's `initState` loads its own controlId/championEmail pair.
- Confirmed delta vs. the My Audit version: each card's `GrcSubmitterRow` uses `assignment.controlChampionEmail` (not `assignment.lastModifier`, which the page's *old* single-card view used and which can drift to the Owner/Manager's email after a reject/approve/score revision) — every submission on this page is by definition made by the currently logged-in Champion, so the submitter is always the same fixed email, matching `MyAuditDetailsPage`'s existing convention.
- Confirmed delta vs. the My Audit version: the action row below the cards keeps this page's own existing Upload/Resubmit Evidence button (`_submitButton`/`_onActionPressed`) and empty-state (no submission yet at all) — untouched. Only the "at least one submission exists" branch's single card becomes a stacked list; nothing about Approve/Reject (that's the Owner's action, not shown on this page) changes.
- This repo has no widget-test infrastructure for GRC pages (see the My Audit plan's own Task 5) — this task is verified via `puro flutter analyze` plus a manual walkthrough, no automated test.

---

### Task 1: Wire the stacked cards into `AssignmentControlDetailsPage`

**Files:**
- Modify: `lib/features/grc/assignment_control/presentation/ui/pages/assignment_control_details_page.dart`

**Interfaces:**
- Consumes (all pre-existing, no changes): `SubmissionHistoryCubit`/`SubmissionHistoryState`/`SubmissionHistoryInitial`/`Loading`/`Loaded(entries)`/`Failure(message)` (`lib/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart`), `SubmissionHistoryEntry` (`lib/features/grc/assignment_control/domain/entities/submission_history_entry.dart`), `AssignmentControlStatus`/`.label`/`AssignmentControlStatusStyle` (`lib/features/grc/assignment_control/domain/entities/assignment_control_status.dart`).
- Produces: no new public interface — leaf UI consumer, same as the My Audit page.

- [ ] **Step 1: Add imports**

Add these to the top of `assignment_control_details_page.dart`, alongside the existing imports:

```dart
import 'package:get_it/get_it.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
```

(This file does not currently import `assignment_control_status.dart` directly — it only gets `AssignmentControlTab`/`AssignmentControlTabStyle` from `assignment_control_tab.dart`, a separate file. The new import above is required for `AssignmentControlStatus.rejected` and `AssignmentControlStatusStyle` used in Step 3.)

- [ ] **Step 2: Add the Cubit field and lifecycle wiring**

Add a field to `_AssignmentControlDetailsPageState`, right after `int _submissionsTab = 0; // 0 = Submission, 1 = Inquires`:

```dart
  late final SubmissionHistoryCubit _historyCubit;
```

Add these two overrides to `_AssignmentControlDetailsPageState` (e.g. right before `bool get _isRejected`):

```dart
  @override
  void initState() {
    super.initState();
    _historyCubit = GetIt.instance<SubmissionHistoryCubit>();
    final assignment = widget.item.assignment;
    if (assignment != null) {
      _historyCubit.loadHistory(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: assignment.controlChampionEmail,
      );
    }
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }
```

- [ ] **Step 3: Replace the single-submission block with the stacked-cards `BlocBuilder`**

Find this block inside the `build` method — the `if (assignment == null) [...] else [...]` branch's `else` arm (everything from the `Row` with `GrcSubmitterRow` down to the closing `],` right before the outer `]),` that closes `GrcSectionCard`):

```dart
                            ] else ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GrcSubmitterRow(email: assignment.lastModifier),
                                  Text(
                                    '${'Submission Date'.tr}: '
                                    '${_cardDateFormat.format(assignment.lastModificationDate)} '
                                    '${'At'.tr} '
                                    '${_cardTimeFormat.format(assignment.lastModificationDate)}',
                                    style: CardStyles.label(12),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              if (assignment.submissionDocument.isNotEmpty)
                                ProductWarrantyCard(
                                  fileName: assignment.submissionDocument
                                      .split('/')
                                      .last
                                      .split('?')
                                      .first,
                                  onTapFile: () =>
                                      openGrcDocument(assignment.submissionDocument),
                                ),
                              SizedBox(height: 12.h),
                              if (assignment.submissionNote.isNotEmpty) ...[
                                GrcLabelValueRow('Submission Notes'.tr,
                                    assignment.submissionNote),
                                SizedBox(height: 12.h),
                              ],
                              if (rejectionReason != null &&
                                  rejectionReason.isNotEmpty) ...[
                                GrcLabelValueRow(
                                  'Reasons of Rejection'.tr,
                                  rejectionReason,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 12.h),
                              ],
                              if (_isRejected)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _submitButton(context, isSaving),
                                    GrcStatusPill(
                                      label: widget.item.tab.label.tr,
                                      color: style.color,
                                      icon: style.icon,
                                    ),
                                  ],
                                )
                              else
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GrcStatusPill(
                                    label: widget.item.tab.label.tr,
                                    color: style.color,
                                    icon: style.icon,
                                  ),
                                ),
                            ],
```

Replace it with:

```dart
                            ] else ...[
                              BlocBuilder<SubmissionHistoryCubit,
                                  SubmissionHistoryState>(
                                bloc: _historyCubit,
                                builder: (context, historyState) {
                                  if (historyState
                                      is SubmissionHistoryFailure) {
                                    return Text(
                                      historyState.message,
                                      style: CardStyles.value(12)
                                          .copyWith(color: Colors.red),
                                    );
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
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GrcSubmitterRow(
                                                  email: assignment
                                                      .controlChampionEmail),
                                              Text(
                                                '${'Submission Date'.tr}: '
                                                '${_cardDateFormat.format(entry.submittedDate)} '
                                                '${'At'.tr} '
                                                '${_cardTimeFormat.format(entry.submittedDate)}',
                                                style: CardStyles.label(12),
                                              ),
                                            ],
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
                              if (_isRejected)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _submitButton(context, isSaving),
                                    GrcStatusPill(
                                      label: widget.item.tab.label.tr,
                                      color: style.color,
                                      icon: style.icon,
                                    ),
                                  ],
                                )
                              else
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GrcStatusPill(
                                    label: widget.item.tab.label.tr,
                                    color: style.color,
                                    icon: style.icon,
                                  ),
                                ),
                            ],
```

Note: this new block still uses `rejectionReason` (the page's existing top-of-`build` combined getter) nowhere anymore — that's expected, its one former use is superseded by each card's own `entry.rejectionReason`. Leave the `final rejectionReason = ...` declaration in place; do not remove it without first confirming (via analyze) that it truly has no other reference in the file.

- [ ] **Step 4: Verify with static analysis**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/assignment_control/`
Expected: no errors. If `AssignmentControlStatus` fails to resolve, add its import per Step 1's parenthetical note. An "unused variable `rejectionReason`" warning, if it appears, is expected and harmless (same class of warning as the My Audit plan's `audit` variable) — leave it, do not remove the declaration.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/assignment_control/presentation/ui/pages/assignment_control_details_page.dart
git commit -m "feat(grc): show one card per submitted file on Assignment Control's Submission tab"
```

---

### Task 2: Manual walkthrough

**Files:** none (verification only).

- [ ] **Step 1: Manual walkthrough**

With a Flutter environment connected to the real/staging Firestore project, as the Control Champion:
1. Open an Assignment Control that has never had evidence submitted — confirm the empty state (upload icon + "Upload Evidence" button) still shows, unchanged.
2. Submit evidence (file + note) for a Control.
3. Reopen that Control's details — confirm exactly 1 card shows, "Submitted" pill, no rejection reason, and (since not rejected) just the status pill at the bottom (no resubmit button).
4. As the Control Owner, reject it with a reason (via My Audits).
5. As the Champion, reopen the same Control — confirm the single card now shows "Rejected" pill + the reason, and the "Resubmit Evidence" button + pill row appears below the card (unchanged from before this plan).
6. Resubmit a different file + note.
7. Reopen the Control again — confirm **2 cards** now show, newest (the resubmission, "Submitted") on top, the original rejected file below it with its reason — same shape as the My Audit page's own walkthrough.

No commit for this task (verification only).
