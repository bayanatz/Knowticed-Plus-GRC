# My Audit Submission History Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On `MyAuditDetailsPage`'s Submission tab, show one card per distinct file the Control Champion has ever submitted for this Control (newest first), each with its own status pill and rejection reason, instead of only the single latest submission.

**Architecture:** A pure derivation (`AssignmentControlModel.toSubmissionHistory()`) groups the model's existing parallel-history Lists into `SubmissionHistoryEntry` value objects, exposed through a new repository method → use case, loaded by a small dedicated `SubmissionHistoryCubit` (kept separate from the page's existing, list-page-shared `MyAuditCubit` — see Task 5's note on why), and rendered as a stack of `GrcSectionCard`s in `my_audit_details_page.dart`.

**Tech Stack:** Flutter, `flutter_bloc` (Cubit), `dartz` (`Either`/`Failure`), `get_it`, `flutter_screenutil`.

## Global Constraints

- Design spec: `docs/superpowers/specs/2026-07-29-my-audit-submission-history-design.md` — every requirement in this plan traces back to it.
- No changes to `submitEvidence`/`applyManagerDecision`/`applyOwnerScore` write paths, including the pre-existing `departmentManagerRejectionReasons` vs. `controlOwnerRejectionReasons` naming mismatch (spec's "Out of scope"). This plan only reads `departmentManagerRejectionReasons`.
- A submission "entry" = a run of consecutive revisions sharing the same `submissionDocument` value. A Reject never changes `submissionDocument` (confirmed: `applyManagerDecision` calls `copyWithUpdate` without passing `submissionDocument`, so it's carried forward) — grouping is by document value, not by raw revision index.
- Newest file first; every card gets its own `GrcStatusPill`; Approve/Reject buttons stay below the whole list, unchanged, operating on the item's overall latest state.
- This repo has no mocking library (`flutter_test` + plain `test()` only, see `test/features/grc/assignment_control/data/models/assignment_control_model_test.dart`) and no Firebase emulator in this sandbox — automated tests target pure logic only (the model's derivation method); repository/Cubit/page code is verified via `puro flutter analyze` per-task (this machine uses `puro`, not a bare `flutter` binary — confirmed working: `/Users/bstar/.puro/bin/puro flutter --version`).

---

### Task 1: `SubmissionHistoryEntry` entity + `AssignmentControlModel.toSubmissionHistory()`

**Files:**
- Create: `lib/features/grc/assignment_control/domain/entities/submission_history_entry.dart`
- Modify: `lib/features/grc/assignment_control/data/models/assignment_control_model.dart`
- Modify: `test/features/grc/assignment_control/data/models/assignment_control_model_test.dart`

**Interfaces:**
- Produces: `SubmissionHistoryEntry` (fields: `document` String, `note` String, `submittedDate` DateTime, `status` AssignmentControlStatus, `rejectionReason` String?); `AssignmentControlModel.toSubmissionHistory() -> List<SubmissionHistoryEntry>` (newest-first). Both consumed by Task 3 (repository).

- [ ] **Step 1: Create the entity**

```dart
// lib/features/grc/assignment_control/domain/entities/submission_history_entry.dart
import 'assignment_control_status.dart';

/// One distinct file ever submitted for a Control+Champion pair, derived by
/// [AssignmentControlModel.toSubmissionHistory]. Consecutive revisions that
/// share the same `submissionDocument` value (e.g. a Reject, which reuses
/// the previous file rather than replacing it) collapse into a single
/// entry, carrying that file's *final* status/rejection reason — whatever
/// happened to it right before a newer file replaced it, or its current
/// outcome if it's the most recent file.
class SubmissionHistoryEntry {
  final String document;
  final String note;
  final DateTime submittedDate;
  final AssignmentControlStatus status;
  final String? rejectionReason;

  const SubmissionHistoryEntry({
    required this.document,
    required this.note,
    required this.submittedDate,
    required this.status,
    required this.rejectionReason,
  });
}
```

- [ ] **Step 2: Write the failing tests**

Append this new group to the existing test file (keep the existing `_build`/tests as-is, add below them):

```dart
// Append to test/features/grc/assignment_control/data/models/assignment_control_model_test.dart
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';

AssignmentControlModel _buildHistory({
  required List<String> submissionDocument,
  required List<String> submissionNote,
  required List<String> status,
  required List<DateTime> modificationDate,
  required List<String?> departmentManagerRejectionReasons,
}) {
  final n = status.length;
  return AssignmentControlModel(
    submissionId: 's1',
    controlChampionEmail: 'champion@a.com',
    policyId: 'p1',
    controlId: 'c1',
    controlOwner: null,
    departmentManager: null,
    submissionDocument: submissionDocument,
    submissionNote: submissionNote,
    status: status,
    modifier: List.filled(n, 'a@a.com'),
    modificationDate: modificationDate,
    departmentManagerRejectionReasons: departmentManagerRejectionReasons,
    controlScore: List.filled(n, null),
    controlOwnerJustifications: List.filled(n, null),
    controlOwnerRejectionReasons: List.filled(n, null),
  );
}

void main() {
  // ... existing tests above stay unchanged ...

  group('toSubmissionHistory', () {
    test('single submission still pending review -> 1 entry, submitted', () {
      final model = _buildHistory(
        submissionDocument: const ['docA'],
        submissionNote: const ['noteA'],
        status: const ['Submitted'],
        modificationDate: [DateTime(2026, 1, 1)],
        departmentManagerRejectionReasons: const [null],
      );

      final history = model.toSubmissionHistory();

      expect(history, hasLength(1));
      expect(history.single.document, 'docA');
      expect(history.single.note, 'noteA');
      expect(history.single.submittedDate, DateTime(2026, 1, 1));
      expect(history.single.status, AssignmentControlStatus.submitted);
      expect(history.single.rejectionReason, isNull);
    });

    test('Submitted(A) -> Rejected(A) -> Submitted(B) collapses to 2 entries',
        () {
      final model = _buildHistory(
        submissionDocument: const ['docA', 'docA', 'docB'],
        submissionNote: const ['noteA', 'noteA', 'noteB'],
        status: const ['Submitted', 'Rejected', 'Submitted'],
        modificationDate: [
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 2),
          DateTime(2026, 1, 3),
        ],
        departmentManagerRejectionReasons: const [null, 'too vague', 'too vague'],
      );

      final history = model.toSubmissionHistory();

      expect(history, hasLength(2));
      expect(history[0].document, 'docB');
      expect(history[0].status, AssignmentControlStatus.submitted);
      expect(history[0].submittedDate, DateTime(2026, 1, 3));
      expect(history[0].rejectionReason, isNull);
      expect(history[1].document, 'docA');
      expect(history[1].status, AssignmentControlStatus.rejected);
      expect(history[1].submittedDate, DateTime(2026, 1, 1));
      expect(history[1].rejectionReason, 'too vague');
    });

    test('resubmission later approved -> 2 entries, newest is approved', () {
      final model = _buildHistory(
        submissionDocument: const ['docA', 'docA', 'docB', 'docB'],
        submissionNote: const ['noteA', 'noteA', 'noteB', 'noteB'],
        status: const ['Submitted', 'Rejected', 'Submitted', 'Approved'],
        modificationDate: [
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 2),
          DateTime(2026, 1, 3),
          DateTime(2026, 1, 4),
        ],
        departmentManagerRejectionReasons: const ['bad', 'bad', 'bad', 'bad'],
      );

      final history = model.toSubmissionHistory();

      expect(history, hasLength(2));
      expect(history[0].document, 'docB');
      expect(history[0].status, AssignmentControlStatus.approved);
      expect(history[0].rejectionReason, isNull,
          reason: 'a stale carried-forward reason must not leak onto a '
              'non-rejected entry');
      expect(history[1].document, 'docA');
      expect(history[1].status, AssignmentControlStatus.rejected);
      expect(history[1].rejectionReason, 'bad');
    });

    test('approved on the first try, never rejected -> 1 entry, no reason',
        () {
      final model = _buildHistory(
        submissionDocument: const ['docA', 'docA'],
        submissionNote: const ['noteA', 'noteA'],
        status: const ['Submitted', 'Approved'],
        modificationDate: [DateTime(2026, 1, 1), DateTime(2026, 1, 2)],
        departmentManagerRejectionReasons: const [null, null],
      );

      final history = model.toSubmissionHistory();

      expect(history, hasLength(1));
      expect(history.single.status, AssignmentControlStatus.approved);
      expect(history.single.rejectionReason, isNull);
    });

    test('two reject/resubmit cycles on 3 different files -> 3 entries, '
        'newest-first', () {
      final model = _buildHistory(
        submissionDocument: const ['docA', 'docA', 'docB', 'docB', 'docC'],
        submissionNote: const ['a', 'a', 'b', 'b', 'c'],
        status: const [
          'Submitted',
          'Rejected',
          'Submitted',
          'Rejected',
          'Submitted',
        ],
        modificationDate: [
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 2),
          DateTime(2026, 1, 3),
          DateTime(2026, 1, 4),
          DateTime(2026, 1, 5),
        ],
        departmentManagerRejectionReasons: const [
          null,
          'r1',
          'r1',
          'r2',
          'r2',
        ],
      );

      final history = model.toSubmissionHistory();

      expect(history, hasLength(3));
      expect(history.map((e) => e.document).toList(), ['docC', 'docB', 'docA']);
      expect(history[0].status, AssignmentControlStatus.submitted);
      expect(history[1].status, AssignmentControlStatus.rejected);
      expect(history[1].rejectionReason, 'r2');
      expect(history[2].status, AssignmentControlStatus.rejected);
      expect(history[2].rejectionReason, 'r1');
    });
  });
}
```

Note: merge this into the existing file's single `void main() { ... }` block (don't create a second `main()`), and move the new `import` to the top with the file's other imports.

- [ ] **Step 3: Run tests to verify they fail**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/assignment_control/data/models/assignment_control_model_test.dart`
Expected: FAIL — `toSubmissionHistory` is not a method on `AssignmentControlModel` yet (compile error).

- [ ] **Step 4: Implement `toSubmissionHistory()`**

Add this import near the top of `assignment_control_model.dart` (alongside its existing imports):

```dart
import 'package:demo_app/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
```

Add this method to the `AssignmentControlModel` class (e.g. right after `toEntity()`):

```dart
  /// Groups consecutive revisions that share the same [submissionDocument]
  /// value into one [SubmissionHistoryEntry] per distinct file, newest file
  /// first. A Reject (or Approve) never changes [submissionDocument] — it
  /// appends a revision carrying the same document forward (see
  /// [copyWithUpdate]) — so grouping by document value collapses those into
  /// one card, using the *last* revision of each run for status/rejection
  /// reason. [rejectionReason] is only ever non-null when that run's final
  /// status is Rejected, even if a stale value is still sitting in
  /// [departmentManagerRejectionReasons] from an earlier rejection.
  List<SubmissionHistoryEntry> toSubmissionHistory() {
    final entries = <SubmissionHistoryEntry>[];
    var runStart = 0;
    for (var i = 1; i <= submissionDocument.length; i++) {
      final runEnds = i == submissionDocument.length ||
          submissionDocument[i] != submissionDocument[runStart];
      if (!runEnds) continue;
      final end = i - 1;
      final parsedStatus = AssignmentControlStatus.fromString(status[end]);
      entries.add(SubmissionHistoryEntry(
        document: submissionDocument[runStart],
        note: submissionNote[runStart],
        submittedDate: modificationDate[runStart],
        status: parsedStatus,
        rejectionReason: parsedStatus == AssignmentControlStatus.rejected
            ? departmentManagerRejectionReasons[end]
            : null,
      ));
      runStart = i;
    }
    return entries.reversed.toList();
  }
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/assignment_control/data/models/assignment_control_model_test.dart`
Expected: PASS (all tests, old and new).

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/assignment_control/domain/entities/submission_history_entry.dart lib/features/grc/assignment_control/data/models/assignment_control_model.dart test/features/grc/assignment_control/data/models/assignment_control_model_test.dart
git commit -m "feat(grc): add AssignmentControlModel.toSubmissionHistory() derivation"
```

---

### Task 2: `AssignmentControlStatus.label` + `AssignmentControlStatusStyle`

**Files:**
- Modify: `lib/features/grc/assignment_control/domain/entities/assignment_control_status.dart`
- Test: `test/features/grc/assignment_control/domain/entities/assignment_control_status_style_test.dart`

**Interfaces:**
- Consumes: `AssignmentControlStatus` (Task 1's dependency, already exists).
- Produces: `AssignmentControlStatus.label` (String getter), `AssignmentControlStatusStyle.of(AssignmentControlStatus) -> {color: Color, icon: IconData}`. Both consumed by Task 5 (page UI, one pill per card).

- [ ] **Step 1: Write the failing test**

```dart
// test/features/grc/assignment_control/domain/entities/assignment_control_status_style_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';

void main() {
  test('label returns the same display strings as .value', () {
    expect(AssignmentControlStatus.submitted.label, 'Submitted');
    expect(AssignmentControlStatus.rejected.label, 'Rejected');
    expect(AssignmentControlStatus.approved.label, 'Approved');
  });

  group('AssignmentControlStatusStyle.of', () {
    test('submitted is warning-colored', () {
      expect(AssignmentControlStatusStyle.of(AssignmentControlStatus.submitted).color,
          AppColors.warning);
    });

    test('rejected is red with a block icon', () {
      final style = AssignmentControlStatusStyle.of(AssignmentControlStatus.rejected);
      expect(style.color, Colors.red);
      expect(style.icon, Icons.block);
    });

    test('approved is green with a check icon', () {
      final style = AssignmentControlStatusStyle.of(AssignmentControlStatus.approved);
      expect(style.color, Colors.green);
      expect(style.icon, Icons.check_circle);
    });
  });
}
```

Add this import at the top of the test file: `import 'package:demo_app/core/theme/app_colors.dart';`

- [ ] **Step 2: Run test to verify it fails**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/assignment_control/domain/entities/assignment_control_status_style_test.dart`
Expected: FAIL — `label` getter and `AssignmentControlStatusStyle` don't exist yet.

- [ ] **Step 3: Implement**

Replace the full contents of `assignment_control_status.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';

/// Lifecycle status of one Assignment_Controls submission cycle. Only
/// `submitted`, `inReview`, `rejected`, and `approved` are ever persisted by
/// this feature (Pending/Overdue are always derived, never stored — see the
/// design spec) — `pending`/`overdue` exist here only so `fromString` stays
/// total and forward-compatible with the future Approvals/My Audits specs.
enum AssignmentControlStatus {
  pending,
  submitted,
  inReview,
  rejected,
  approved,
  overdue;

  String get value {
    switch (this) {
      case AssignmentControlStatus.pending:
        return 'Pending';
      case AssignmentControlStatus.submitted:
        return 'Submitted';
      case AssignmentControlStatus.inReview:
        return 'In review';
      case AssignmentControlStatus.rejected:
        return 'Rejected';
      case AssignmentControlStatus.approved:
        return 'Approved';
      case AssignmentControlStatus.overdue:
        return 'Overdue';
    }
  }

  /// Display label for this status — same strings as [value] except
  /// "In review" is title-cased, matching `AssignmentControlTab.label`'s
  /// existing convention (both feed a `GrcStatusPill`, one for a page-level
  /// tab, one for a single Submission History card via
  /// [AssignmentControlStatusStyle]).
  String get label {
    switch (this) {
      case AssignmentControlStatus.pending:
        return 'Pending';
      case AssignmentControlStatus.submitted:
        return 'Submitted';
      case AssignmentControlStatus.inReview:
        return 'In Review';
      case AssignmentControlStatus.rejected:
        return 'Rejected';
      case AssignmentControlStatus.approved:
        return 'Approved';
      case AssignmentControlStatus.overdue:
        return 'Overdue';
    }
  }

  static AssignmentControlStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'submitted':
        return AssignmentControlStatus.submitted;
      case 'in review':
        return AssignmentControlStatus.inReview;
      case 'rejected':
        return AssignmentControlStatus.rejected;
      case 'approved':
        return AssignmentControlStatus.approved;
      case 'overdue':
        return AssignmentControlStatus.overdue;
      case 'pending':
      default:
        return AssignmentControlStatus.pending;
    }
  }
}

/// Visual identity (color + icon) for one [AssignmentControlStatus] at the
/// single-revision level — used by the Submission History cards (one pill
/// per past submission). Unlike `AssignmentControlTabStyle`/`MyAuditTabStyle`,
/// which style a page's overall *current* tab, this styles one specific
/// historical revision's own outcome.
class AssignmentControlStatusStyle {
  final Color color;
  final IconData icon;

  const AssignmentControlStatusStyle({required this.color, required this.icon});

  static AssignmentControlStatusStyle of(AssignmentControlStatus status) {
    switch (status) {
      case AssignmentControlStatus.submitted:
        return AssignmentControlStatusStyle(
            color: AppColors.warning, icon: Icons.upload_file);
      case AssignmentControlStatus.rejected:
        return const AssignmentControlStatusStyle(
            color: Colors.red, icon: Icons.block);
      case AssignmentControlStatus.approved:
        return const AssignmentControlStatusStyle(
            color: Colors.green, icon: Icons.check_circle);
      case AssignmentControlStatus.pending:
      case AssignmentControlStatus.inReview:
      case AssignmentControlStatus.overdue:
        return AssignmentControlStatusStyle(
            color: AppColors.warning, icon: Icons.schedule);
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/assignment_control/domain/entities/assignment_control_status_style_test.dart`
Expected: PASS.

- [ ] **Step 5: Run the full assignment_control test directory to check for regressions**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/assignment_control/`
Expected: PASS (Task 1's tests plus this task's, nothing broken).

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/assignment_control/domain/entities/assignment_control_status.dart test/features/grc/assignment_control/domain/entities/assignment_control_status_style_test.dart
git commit -m "feat(grc): add AssignmentControlStatus.label and AssignmentControlStatusStyle"
```

---

### Task 3: `getSubmissionHistory` repository method + use case + DI

**Files:**
- Modify: `lib/features/grc/assignment_control/domain/repository/assignment_control_repository.dart`
- Modify: `lib/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart`
- Create: `lib/features/grc/assignment_control/domain/use_cases/get_submission_history_usecase.dart`
- Modify: `lib/features/grc/grc_get_it.dart`

**Interfaces:**
- Consumes: `AssignmentControlModel.toSubmissionHistory()` (Task 1), `SubmissionHistoryEntry` (Task 1).
- Produces: `AssignmentControlRepository.getSubmissionHistory({required moduleId, required controlId, required championEmail}) -> Future<Either<Failure, List<SubmissionHistoryEntry>>>`; `GetSubmissionHistoryUseCase.call({required moduleId, required controlId, required championEmail})` (same return type) — registered in `grc_get_it.dart` as `GetSubmissionHistoryUseCase`. Consumed by Task 4 (`SubmissionHistoryCubit`).

No automated test for this task — it's a thin Firestore-backed repository method with no pure logic of its own (the logic it calls, `toSubmissionHistory()`, is already tested in Task 1), matching this repo's existing convention for repository/DI code (verified via `puro flutter analyze` only, same as every other repository method here).

- [ ] **Step 1: Add the repository interface method**

In `lib/features/grc/assignment_control/domain/repository/assignment_control_repository.dart`, add this import:

```dart
import 'package:demo_app/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
```

Then add this method inside the `AssignmentControlRepository` abstract class (after `submitEvidence`):

```dart
  /// Derives one entry per distinct file ever submitted for this
  /// control+champion pair, newest file first — see
  /// [AssignmentControlModel.toSubmissionHistory]. Returns an empty list
  /// (not a failure) when nothing has ever been submitted.
  Future<Either<Failure, List<SubmissionHistoryEntry>>> getSubmissionHistory({
    required String moduleId,
    required String controlId,
    required String championEmail,
  });
```

- [ ] **Step 2: Implement it in the repository impl**

In `lib/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart`, add this import:

```dart
import 'package:demo_app/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
```

Then add this method to `AssignmentControlRepositoryImpl` (after `submitEvidence`):

```dart
  @override
  Future<Either<Failure, List<SubmissionHistoryEntry>>> getSubmissionHistory({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final model = await _dataSource.get(id, moduleId: moduleId);
      return Right(model?.toSubmissionHistory() ?? const []);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

- [ ] **Step 3: Create the use case**

```dart
// lib/features/grc/assignment_control/domain/use_cases/get_submission_history_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
import 'package:demo_app/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class GetSubmissionHistoryUseCase {
  const GetSubmissionHistoryUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, List<SubmissionHistoryEntry>>> call({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) {
    return _repository.getSubmissionHistory(
      moduleId: moduleId,
      controlId: controlId,
      championEmail: championEmail,
    );
  }
}
```

- [ ] **Step 4: Register the use case in `grc_get_it.dart`**

Add this import near the other `assignment_control/domain/use_cases/` imports (e.g. right after the `get_assignment_control_by_id_usecase.dart` import, around line 39):

```dart
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/get_submission_history_usecase.dart';
```

Add this registration right after the existing `ApplyManagerDecisionUseCase` registration block (around line 524):

```dart
  /// class name: [GetSubmissionHistoryUseCase]
  /// purpose: business logic for deriving the per-file Submission History
  /// (one card per distinct file) shown on MyAuditDetailsPage.
  sl.registerLazySingleton<GetSubmissionHistoryUseCase>(
    () => GetSubmissionHistoryUseCase(sl<AssignmentControlRepository>()),
  );
```

- [ ] **Step 5: Verify with static analysis**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/assignment_control/ lib/features/grc/grc_get_it.dart`
Expected: No new errors (pre-existing warnings elsewhere in the repo are fine — only check nothing new appears in the files this task touched).

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/assignment_control/domain/repository/assignment_control_repository.dart lib/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart lib/features/grc/assignment_control/domain/use_cases/get_submission_history_usecase.dart lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): add getSubmissionHistory repository method, use case, and DI wiring"
```

---

### Task 4: `SubmissionHistoryCubit`

**Files:**
- Create: `lib/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart`
- Create: `lib/features/grc/assignment_control/presentation/controller/submission_history_state.dart`
- Modify: `lib/features/grc/grc_get_it.dart`

**Interfaces:**
- Consumes: `GetSubmissionHistoryUseCase` (Task 3).
- Produces: `SubmissionHistoryCubit` with `loadHistory({required moduleId, required controlId, required championEmail})`; states `SubmissionHistoryInitial`/`Loading`/`Loaded(entries)`/`Failure(message)`. Registered in `grc_get_it.dart` as a factory. Consumed by Task 5 (the page).

No automated test for this task — a 3-line pass-through Cubit with no branching logic of its own beyond `result.fold`, matching this repo's convention of verifying Cubits via `flutter analyze` (e.g. `ControlPreviousOwnersCubit` has no dedicated unit test either).

- [ ] **Step 1: Create the Cubit**

```dart
// lib/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart
/// Module: Assignment Controls (Control Champion)
/// Description: BLoC Cubit that loads and exposes the Submission History
///              (one card per distinct file ever submitted) for a single
///              Control+Champion Assignment Control, shown on
///              MyAuditDetailsPage's Submission tab. Deliberately separate
///              from MyAuditCubit: MyAuditDetailsPage is pushed with the
///              *same* MyAuditCubit instance the My Audits list page uses
///              (BlocProvider.value in my_audits_list_page.dart), so
///              emitting a history-only state on that shared cubit would
///              leave the list page's own BlocBuilder (which only
///              recognizes MyAuditListLoaded) showing a broken/loading view
///              the next time the user navigates back to it.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-29
/// Dependencies: flutter_bloc, GetSubmissionHistoryUseCase, SubmissionHistoryEntry
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/get_submission_history_usecase.dart';

part 'submission_history_state.dart';

class SubmissionHistoryCubit extends Cubit<SubmissionHistoryState> {
  SubmissionHistoryCubit({
    required GetSubmissionHistoryUseCase getSubmissionHistoryUseCase,
  })  : _getSubmissionHistoryUseCase = getSubmissionHistoryUseCase,
        super(SubmissionHistoryInitial());

  final GetSubmissionHistoryUseCase _getSubmissionHistoryUseCase;

  Future<void> loadHistory({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) async {
    emit(SubmissionHistoryLoading());
    final result = await _getSubmissionHistoryUseCase.call(
      moduleId: moduleId,
      controlId: controlId,
      championEmail: championEmail,
    );
    result.fold(
      (failure) => emit(SubmissionHistoryFailure(failure.message)),
      (entries) => emit(SubmissionHistoryLoaded(entries)),
    );
  }
}
```

- [ ] **Step 2: Create the state file**

```dart
// lib/features/grc/assignment_control/presentation/controller/submission_history_state.dart
part of 'submission_history_cubit.dart';

sealed class SubmissionHistoryState {}

final class SubmissionHistoryInitial extends SubmissionHistoryState {}

final class SubmissionHistoryLoading extends SubmissionHistoryState {}

final class SubmissionHistoryLoaded extends SubmissionHistoryState {
  final List<SubmissionHistoryEntry> entries;
  SubmissionHistoryLoaded(this.entries);
}

final class SubmissionHistoryFailure extends SubmissionHistoryState {
  final String message;
  SubmissionHistoryFailure(this.message);
}
```

- [ ] **Step 3: Register the Cubit in `grc_get_it.dart`**

Add this import near the other `assignment_control/presentation/controller/` imports (e.g. right after the `assignment_control_cubit.dart` import, around line 96):

```dart
import 'package:demo_app/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
```

Add this registration right after the existing `MyAuditCubit` registration block:

```dart
  /// class name: [SubmissionHistoryCubit]
  /// purpose: presentation-layer state manager for one Assignment
  /// Control's per-file Submission History cards, kept independent of the
  /// shared MyAuditCubit (see the class doc comment for why). Registered
  /// as a factory so each MyAuditDetailsPage instance gets its own cubit.
  sl.registerFactory<SubmissionHistoryCubit>(
    () => SubmissionHistoryCubit(
      getSubmissionHistoryUseCase: sl<GetSubmissionHistoryUseCase>(),
    ),
  );
```

- [ ] **Step 4: Verify with static analysis**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/assignment_control/ lib/features/grc/grc_get_it.dart`
Expected: No new errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart lib/features/grc/assignment_control/presentation/controller/submission_history_state.dart lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): add SubmissionHistoryCubit"
```

---

### Task 5: Wire the stacked cards into `MyAuditDetailsPage`

**Files:**
- Modify: `lib/features/grc/my_audit/presentation/ui/pages/my_audit_details_page.dart`

**Interfaces:**
- Consumes: `SubmissionHistoryCubit`/`SubmissionHistoryState`/`SubmissionHistoryLoaded`/`SubmissionHistoryFailure` (Task 4), `SubmissionHistoryEntry` (Task 1), `AssignmentControlStatus`/`AssignmentControlStatusStyle`/`.label` (Task 2).
- Produces: no new public interface — this is the leaf UI consumer.

No automated test for this task (no widget-test infrastructure exists in this repo for GRC pages — every other page-level task in this codebase's plans is verified via `flutter analyze` plus a manual walkthrough; see Task 6).

- [ ] **Step 1: Add imports**

Add these to the top of `my_audit_details_page.dart`, alongside the existing imports:

```dart
import 'package:get_it/get_it.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
```

- [ ] **Step 2: Add the Cubit field and lifecycle wiring**

Add a field to `_MyAuditDetailsPageState`, right after `int _submissionTab = 0; // 0 = Submission, 1 = Inquires`:

```dart
  late final SubmissionHistoryCubit _historyCubit;
```

Add these two overrides to `_MyAuditDetailsPageState` (e.g. right before `_onApprovePressed`):

```dart
  @override
  void initState() {
    super.initState();
    _historyCubit = GetIt.instance<SubmissionHistoryCubit>();
    final assignmentControl = widget.item.assignmentControl;
    if (assignmentControl != null) {
      _historyCubit.loadHistory(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: assignmentControl.controlChampionEmail,
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

Find this block inside the `build` method (the `else` branch right after `if (_submissionTab == 1) GrcSectionCard(...) else`):

```dart
                              else
                                GrcSectionCard(children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GrcSubmitterRow(
                                          email: assignmentControl
                                              .controlChampionEmail),
                                      Text(
                                        '${'Submission Date'.tr}: '
                                        '${_cardDateFormat.format(assignmentControl.lastModificationDate)} '
                                        '${'At'.tr} '
                                        '${_cardTimeFormat.format(assignmentControl.lastModificationDate)}',
                                        style: CardStyles.label(12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  if (assignmentControl
                                      .submissionDocument.isNotEmpty)
                                    ProductWarrantyCard(
                                      fileName: assignmentControl
                                          .submissionDocument
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
                                  if (audit?.controlOwnerReasonOfRejection !=
                                          null &&
                                      audit!.controlOwnerReasonOfRejection!
                                          .isNotEmpty) ...[
                                    GrcLabelValueRow(
                                      'Reasons of Rejection'.tr,
                                      audit.controlOwnerReasonOfRejection!,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                  SizedBox(height: 8.h),
                                  if (widget.item.tab == MyAuditTab.pending)
                                    isSaving
                                        ? Align(
                                            alignment: Alignment.centerRight,
                                            child: GrcButtonLoadingPlaceholder(
                                              width: 120.w,
                                              height: 44.h,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              customButton(
                                                title: 'Reject'.tr,
                                                function: () =>
                                                    _onRejectPressed(context),
                                                width: 120.w,
                                                color: AppColors.red,
                                                textStyle: StyleText
                                                    .fontSize16Weight500
                                                    .copyWith(
                                                        color: AppColors
                                                            .textButton),
                                              ),
                                              SizedBox(width: 12.w),
                                              customButton(
                                                title: 'Approve'.tr,
                                                function: () =>
                                                    _onApprovePressed(context),
                                                width: 120.w,
                                                color: AppColors.primary,
                                                textStyle: StyleText
                                                    .fontSize16Weight500
                                                    .copyWith(
                                                        color: AppColors
                                                            .textButton),
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
                                            padding: EdgeInsets.symmetric(
                                                vertical: 24.h),
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GrcSubmitterRow(
                                                        email: assignmentControl
                                                            .controlChampionEmail),
                                                    Text(
                                                      '${'Submission Date'.tr}: '
                                                      '${_cardDateFormat.format(entry.submittedDate)} '
                                                      '${'At'.tr} '
                                                      '${_cardTimeFormat.format(entry.submittedDate)}',
                                                      style:
                                                          CardStyles.label(12),
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
                                                        openGrcDocument(
                                                            entry.document),
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
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: GrcStatusPill(
                                                    label:
                                                        entry.status.label.tr,
                                                    color: AssignmentControlStatusStyle
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
                                    if (widget.item.tab == MyAuditTab.pending)
                                      isSaving
                                          ? Align(
                                              alignment: Alignment.centerRight,
                                              child: GrcButtonLoadingPlaceholder(
                                                width: 120.w,
                                                height: 44.h,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                customButton(
                                                  title: 'Reject'.tr,
                                                  function: () =>
                                                      _onRejectPressed(context),
                                                  width: 120.w,
                                                  color: AppColors.red,
                                                  textStyle: StyleText
                                                      .fontSize16Weight500
                                                      .copyWith(
                                                          color: AppColors
                                                              .textButton),
                                                ),
                                                SizedBox(width: 12.w),
                                                customButton(
                                                  title: 'Approve'.tr,
                                                  function: () =>
                                                      _onApprovePressed(
                                                          context),
                                                  width: 120.w,
                                                  color: AppColors.primary,
                                                  textStyle: StyleText
                                                      .fontSize16Weight500
                                                      .copyWith(
                                                          color: AppColors
                                                              .textButton),
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
                                ),
```

Note: `audit` (the `MyAuditEntity?` local, still used elsewhere on the page) is no longer referenced in this block — that's expected, its one former use (`audit?.controlOwnerReasonOfRejection`) is superseded by each card's own `entry.rejectionReason`. Leave the `final audit = widget.item.audit;` declaration at the top of `build` in place; it's still valid, unused-in-this-block is not unused-in-the-file.

- [ ] **Step 4: Verify with static analysis**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/my_audit/`
Expected: No errors (an "unused variable `audit`" warning would indicate it's no longer used anywhere else in the file — if that appears, search the file for other `audit.` / `audit?.` usages before removing the declaration; do not remove it if any other reference remains).

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/my_audit/presentation/ui/pages/my_audit_details_page.dart
git commit -m "feat(grc): show one card per submitted file in My Audit's Submission tab"
```

---

### Task 6: Full-suite verification and manual walkthrough

**Files:** none (verification only).

- [ ] **Step 1: Run the full test suite**

Run: `/Users/bstar/.puro/bin/puro flutter test`
Expected: PASS (no regressions anywhere in the repo).

- [ ] **Step 2: Run analyze on the whole repo**

Run: `/Users/bstar/.puro/bin/puro flutter analyze`
Expected: No new errors compared to the pre-existing baseline (this repo may already have unrelated warnings elsewhere — only flag anything new in the files this plan touched).

- [ ] **Step 3: Manual walkthrough**

With a Flutter environment connected to the real/staging Firestore project:
1. As a Control Champion, submit evidence for a Control (upload a file + note).
2. As the Control Owner, open My Audits → that item → Reject it with a reason.
3. As the Control Champion again, resubmit a *different* file + note for the same Control.
4. As the Control Owner, reopen the same My Audit item:
   - Confirm the Submission tab now shows **2 cards**, newest (the resubmission) on top.
   - Confirm the top card shows a "Submitted" pill, the new file, and the new note.
   - Confirm the bottom card shows a "Rejected" pill, the *original* file, the *original* note, and the rejection reason from step 2.
   - Confirm tapping each card's file opens the correct (different) file.
   - Confirm the Approve/Reject buttons are still present below both cards and still work (approve it, confirm the success dialog and that the item moves to the Outstanding tab).
5. Open a My Audit item that has never been rejected (approved or scored on the first submission) and confirm it shows exactly 1 card with no rejection-reason row.

No commit for this task (verification only).
