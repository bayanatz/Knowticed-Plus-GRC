# Policy Weight Issue Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing "Policy Weight Issue" button on `GrcModuleDetailsPage` open a page where the user can view the Active+Scheduled policies driving a module's >100% weight total, fix the imbalance (equal-split or manual edit), and see a History of every past weight change.

**Architecture:** New `PolicyWeightHistoryEntry` domain entity + `PolicyModel.toWeightHistory()` reconstruct weight-change history from the revision-history lists `PolicyModel` already stores (same technique as `GRCModuleModel.toOwnerHistory()`) — no new Firestore collection. A new self-contained `policy_weight_issue/` presentation folder holds two cubits (`PolicyWeightIssueCubit` for the editable table, `PolicyWeightHistoryCubit` for the History tab) and one page with two tabs, following the exact file/DI/table patterns already used by `PolicyBulkUploadPreviewPage` and `GrcPreviousModuleOwnersPage`.

**Tech Stack:** Flutter, flutter_bloc (Cubit), GetIt (`sl`), dartz (`Either<Failure, T>`), Cloud Firestore (existing `PolicyFirebaseDataSource`, untouched), GetX `.tr()` translations, `intl` `DateFormat`.

## Global Constraints

- Only Active + Scheduled policies appear on the Policies Weight tab and count toward the 100% total (matches the existing `hasPolicyWeightIssue` check in `grc_module_details_page.dart:251-256`).
- Equal Weight fills every row with the exact decimal `100 / n` (no rounding/remainder redistribution).
- Apply Changes stays disabled until the live sum of all rows is 100 (small epsilon tolerance for double math — see Task 7).
- After a successful Apply Changes, the page stays on the Policies Weight tab in view mode (refreshed values) — no auto-navigation.
- History logs only policies whose weight actually changed in a given Apply — no no-op rows for unchanged policies.
- No new Firestore collection/subcollection. History is derived, on read, from `PolicyModel`'s existing per-field revision-history lists.
- This codebase has no existing test/mock infrastructure for Firebase-backed cubits/repositories (there is exactly one test file in the whole repo: `test/widget_test.dart`, the default Flutter boilerplate). Do not invent Firebase mocking scaffolding for this feature. Where a task's logic is plain Dart with no Firebase/BuildContext dependency (the model diffing algorithm, the row/total-weight math), write a real unit test. Everywhere else, verify with `flutter analyze` plus the manual run-through in the final task.
- Follow existing GRC naming/file-header conventions (see any file under `lib/features/grc/` for the `/// Module: ... /// Author: ...` header block style) when creating new files.

---

## File Structure

New files:
- `lib/features/grc/policy/domain/entities/policy_weight_history_entry.dart`
- `lib/features/grc/policy/domain/use_cases/get_policy_weight_history_use_case.dart`
- `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row.dart` (pure row/table math — no Firebase)
- `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart` + `policy_weight_issue_state.dart`
- `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart` + `policy_weight_history_state.dart`
- `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart`
- `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_tab.dart`
- `test/features/grc/policy/data/models/policy_model_weight_history_test.dart`
- `test/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row_test.dart`

Modified files:
- `lib/features/grc/policy/data/models/policy_model.dart` (add `toWeightHistory()`)
- `lib/features/grc/policy/domain/repository/policy_repository.dart` (add `getPolicyWeightHistory` to the interface)
- `lib/features/grc/policy/data/repository/policy_repository_impl.dart` (implement it)
- `lib/features/grc/grc_get_it.dart` (register the new use case + 2 cubits)
- `lib/core/helper/data_grc_module/constant/translation.dart` (add missing En/Ar keys)
- `lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart` (wire the button)

---

### Task 1: `PolicyWeightHistoryEntry` entity + `PolicyModel.toWeightHistory()`

**Files:**
- Create: `lib/features/grc/policy/domain/entities/policy_weight_history_entry.dart`
- Modify: `lib/features/grc/policy/data/models/policy_model.dart:403-428` (add a method right after `toEntity()`, before the class's closing brace)
- Test: `test/features/grc/policy/data/models/policy_model_weight_history_test.dart`

**Interfaces:**
- Produces: `PolicyWeightHistoryEntry` (fields: `policyId`, `policyNameEn`, `policyNameAr`, `weightPrevious`, `weightCurrent`, `changedByEmail`, `dateOfAction`), `PolicyModel.toWeightHistory() -> List<PolicyWeightHistoryEntry>`.

- [ ] **Step 1: Create the entity**

```dart
/// Module: Policy Management
/// Description: One recorded change to a Policy's weight — reconstructed
///              from PolicyModel's revision history, never persisted on its
///              own.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: None
/// Revision History: 2026-07-19 - Initial creation
library;

/// class name: [PolicyWeightHistoryEntry]
///
/// purpose: represents one revision where a Policy's weight changed from
///          [weightPrevious] to [weightCurrent], saved by [changedByEmail]
///          on [dateOfAction]. Only ever produced for revisions where the
///          weight actually changed — see [PolicyModel.toWeightHistory].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightHistoryEntry {
  final String policyId;
  final String policyNameEn;
  final String policyNameAr;
  final double weightPrevious;
  final double weightCurrent;
  final String changedByEmail;
  final DateTime dateOfAction;

  const PolicyWeightHistoryEntry({
    required this.policyId,
    required this.policyNameEn,
    required this.policyNameAr,
    required this.weightPrevious,
    required this.weightCurrent,
    required this.changedByEmail,
    required this.dateOfAction,
  });
}
```

- [ ] **Step 2: Write the failing test for `toWeightHistory()`**

Create `test/features/grc/policy/data/models/policy_model_weight_history_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/policy/data/models/policy_model.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';

PolicyModel _baseModel({required List<double> weights, required List<String> editors}) {
  final n = weights.length;
  final baseDate = DateTime(2026, 1, 1);
  return PolicyModel(
    id: 'p1',
    moduleId: 'm1',
    policyImage: List<String?>.filled(n, null),
    policyNameEn: List<String>.filled(n, 'Data Retention'),
    policyNameAr: List<String>.filled(n, 'الاحتفاظ بالبيانات'),
    policyNumberEn: List<String>.filled(n, 'PN-1'),
    policyNumberAr: List<String>.filled(n, 'PN-1'),
    policyDescriptionEn: List<String>.filled(n, 'desc'),
    policyDescriptionAr: List<String>.filled(n, 'desc'),
    startDate: List<DateTime>.filled(n, baseDate),
    endDate: List<DateTime>.filled(n, baseDate.add(const Duration(days: 365))),
    policyWeight: weights,
    policyDocumentEn: List<String?>.filled(n, null),
    policyDocumentAr: List<String?>.filled(n, null),
    status: List<String>.filled(n, PolicyStatus.active.value),
    lastModifiedDate: List<DateTime>.generate(n, (i) => baseDate.add(Duration(days: i))),
    editors: editors,
  );
}

void main() {
  group('PolicyModel.toWeightHistory', () {
    test('weight never changed returns an empty list', () {
      final model = _baseModel(
        weights: [10, 10, 10],
        editors: ['a@x.com', 'a@x.com', 'a@x.com'],
      );
      expect(model.toWeightHistory(), isEmpty);
    });

    test('weight changed once returns one entry with correct fields', () {
      final model = _baseModel(
        weights: [20, 10],
        editors: ['creator@x.com', 'editor@x.com'],
      );
      final history = model.toWeightHistory();
      expect(history, hasLength(1));
      expect(history.first.policyId, 'p1');
      expect(history.first.weightPrevious, 20);
      expect(history.first.weightCurrent, 10);
      expect(history.first.changedByEmail, 'editor@x.com');
      expect(history.first.dateOfAction, DateTime(2026, 1, 2));
    });

    test('weight changed multiple times returns one entry per change, in order', () {
      final model = _baseModel(
        weights: [20, 20, 10, 10, 30],
        editors: ['a@x.com', 'a@x.com', 'b@x.com', 'b@x.com', 'c@x.com'],
      );
      final history = model.toWeightHistory();
      expect(history, hasLength(2));
      expect(history[0].weightPrevious, 20);
      expect(history[0].weightCurrent, 10);
      expect(history[0].changedByEmail, 'b@x.com');
      expect(history[1].weightPrevious, 10);
      expect(history[1].weightCurrent, 30);
      expect(history[1].changedByEmail, 'c@x.com');
    });

    test('a no-op update that never touched weight produces no entries', () {
      final model = _baseModel(
        weights: [15, 15, 15],
        editors: ['a@x.com', 'a@x.com', 'a@x.com'],
      );
      expect(model.toWeightHistory(), isEmpty);
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/features/grc/policy/data/models/policy_model_weight_history_test.dart`
Expected: FAIL — `The method 'toWeightHistory' isn't defined for the type 'PolicyModel'`.

- [ ] **Step 4: Add `toWeightHistory()` to `PolicyModel`**

In `lib/features/grc/policy/data/models/policy_model.dart`, add the import at the top (alongside the existing two entity imports):

```dart
import 'policy_weight_history_entry.dart';
```

(Full import line, matching the two already there: `import '../../domain/entities/policy_entity.dart';` — so this new one is `import '../../domain/entities/policy_weight_history_entry.dart';`.)

Then insert this method right after `toEntity()` (which currently ends the class at line 427-428), before the final closing `}`:

```dart
  /// function name: [toWeightHistory]
  ///
  /// purpose: reconstruct every recorded weight change by diffing
  ///          [policyWeight] between consecutive revisions. A change at
  ///          revision N is credited to whoever saved that revision
  ///          ([editors][N]) on [lastModifiedDate][N]. Revisions that
  ///          didn't touch the weight (previous == current) emit nothing.
  ///
  /// parameters: none
  ///
  /// return type: [List<PolicyWeightHistoryEntry>] - one entry per weight change, in revision order
  List<PolicyWeightHistoryEntry> toWeightHistory() {
    final entries = <PolicyWeightHistoryEntry>[];
    for (var i = 1; i < policyWeight.length; i++) {
      if (policyWeight[i] == policyWeight[i - 1]) continue;
      entries.add(
        PolicyWeightHistoryEntry(
          policyId: id,
          policyNameEn: policyNameEn[i],
          policyNameAr: policyNameAr[i],
          weightPrevious: policyWeight[i - 1],
          weightCurrent: policyWeight[i],
          changedByEmail: editors[i],
          dateOfAction: lastModifiedDate[i],
        ),
      );
    }
    return entries;
  }
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/grc/policy/data/models/policy_model_weight_history_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/policy/domain/entities/policy_weight_history_entry.dart lib/features/grc/policy/data/models/policy_model.dart test/features/grc/policy/data/models/policy_model_weight_history_test.dart
git commit -m "feat(grc): add PolicyWeightHistoryEntry and PolicyModel.toWeightHistory()"
```

---

### Task 2: `PolicyRepository.getPolicyWeightHistory` + implementation

**Files:**
- Modify: `lib/features/grc/policy/domain/repository/policy_repository.dart:132-135` (add the method signature right after `getAllPolicies`)
- Modify: `lib/features/grc/policy/data/repository/policy_repository_impl.dart:146-159` (add the implementation right after `getAllPolicies`)

**Interfaces:**
- Consumes: `PolicyWeightHistoryEntry`, `PolicyModel.toWeightHistory()` from Task 1; `PolicyFirebaseDataSource.getAll({required moduleId, bool includeRemoved})` (existing).
- Produces: `PolicyRepository.getPolicyWeightHistory({required String moduleId}) -> Future<Either<Failure, List<PolicyWeightHistoryEntry>>>`, sorted by `dateOfAction` descending.

- [ ] **Step 1: Add the method to the `PolicyRepository` interface**

In `lib/features/grc/policy/domain/repository/policy_repository.dart`, add this import near the top (with the other two entity imports):

```dart
import 'package:demo_app/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
```

Then insert this method into the `abstract class PolicyRepository` body, right after the closing `});` of `getAllPolicies` (currently ending at line 135) and before the `/// function name: [updatePolicy]` doc comment:

```dart
  /// function name: [getPolicyWeightHistory]
  ///
  /// purpose: fetch every recorded weight change across all Policies in a
  ///          Module, reconstructed from each Policy's own revision
  ///          history (see [PolicyModel.toWeightHistory]). No dedicated
  ///          Firestore log exists for this — it's derived on read.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<Either<Failure, List<PolicyWeightHistoryEntry>>>] - every weight-change entry across the module's policies, sorted by date descending, or a Failure
  Future<Either<Failure, List<PolicyWeightHistoryEntry>>> getPolicyWeightHistory({
    required String moduleId,
  });
```

- [ ] **Step 2: Implement it in `PolicyRepositoryImpl`**

In `lib/features/grc/policy/data/repository/policy_repository_impl.dart`, add this import (with the others):

```dart
import 'package:demo_app/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
```

Then insert this method right after the closing `}` of the `getAllPolicies` override (currently ending at line 159), before the `updatePolicy` override:

```dart
  /// function name: [getPolicyWeightHistory]
  ///
  /// purpose: fetch every Policy's full revision history for [moduleId] and
  ///          flat-map [PolicyModel.toWeightHistory] across all of them,
  ///          sorted by date descending (most recent change first). Uses
  ///          `includeRemoved: true` so a weight change is still visible in
  ///          history even if the policy was later removed.
  ///
  /// parameters: see [PolicyRepository.getPolicyWeightHistory]
  ///
  /// return type: [Future<Either<Failure, List<PolicyWeightHistoryEntry>>>] - see [PolicyRepository.getPolicyWeightHistory]
  @override
  Future<Either<Failure, List<PolicyWeightHistoryEntry>>> getPolicyWeightHistory({
    required String moduleId,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        includeRemoved: true,
      );
      final entries = models.expand((m) => m.toWeightHistory()).toList()
        ..sort((a, b) => b.dateOfAction.compareTo(a.dateOfAction));
      return Right(entries);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/features/grc/policy/domain/repository/policy_repository.dart lib/features/grc/policy/data/repository/policy_repository_impl.dart`
Expected: No errors (any other pre-existing warnings in these files are out of scope).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/policy/domain/repository/policy_repository.dart lib/features/grc/policy/data/repository/policy_repository_impl.dart
git commit -m "feat(grc): add PolicyRepository.getPolicyWeightHistory"
```

---

### Task 3: `GetPolicyWeightHistoryUseCase` + DI registration

**Files:**
- Create: `lib/features/grc/policy/domain/use_cases/get_policy_weight_history_use_case.dart`
- Modify: `lib/features/grc/grc_get_it.dart:213-214` (add registration right after `GetGRCModuleOwnerHistoryUseCase`)

**Interfaces:**
- Consumes: `PolicyRepository.getPolicyWeightHistory` (Task 2).
- Produces: `GetPolicyWeightHistoryUseCase.execute(String moduleId) -> Future<Either<Failure, List<PolicyWeightHistoryEntry>>>`.

- [ ] **Step 1: Create the use case**

```dart
/// Module: Policy Management
/// Description: Use case responsible for fetching every recorded weight
///              change across a Module's Policies.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, PolicyRepository, PolicyWeightHistoryEntry, Failure
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
import 'package:demo_app/features/grc/policy/domain/repository/policy_repository.dart';

/// class name: [GetPolicyWeightHistoryUseCase]
///
/// purpose: encapsulate the business logic for fetching a Module's Policy
///          weight-change history. Delegates to
///          [PolicyRepository.getPolicyWeightHistory].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class GetPolicyWeightHistoryUseCase {
  final PolicyRepository _repository;

  GetPolicyWeightHistoryUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch the weight-change history for every Policy under
  ///          [moduleId].
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<Either<Failure, List<PolicyWeightHistoryEntry>>>] - every weight-change entry, or a Failure
  Future<Either<Failure, List<PolicyWeightHistoryEntry>>> execute(
    String moduleId,
  ) {
    return _repository.getPolicyWeightHistory(moduleId: moduleId);
  }
}
```

- [ ] **Step 2: Register it in `grc_get_it.dart`**

In `lib/features/grc/grc_get_it.dart`, insert this block right after the existing `GetGRCModuleOwnerHistoryUseCase` registration (ends at line 213):

```dart

  /// class name: [GetPolicyWeightHistoryUseCase]
  /// purpose: business logic for fetching a module's Policy weight history.
  sl.registerLazySingleton<GetPolicyWeightHistoryUseCase>(
    () => GetPolicyWeightHistoryUseCase(sl<PolicyRepository>()),
  );
```

Add the import at the top of `grc_get_it.dart` alongside the other Policy use-case imports:

```dart
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_weight_history_use_case.dart';
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/features/grc/grc_get_it.dart`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/policy/domain/use_cases/get_policy_weight_history_use_case.dart lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): add GetPolicyWeightHistoryUseCase and register it"
```

---

### Task 4: Missing translation keys

**Files:**
- Modify: `lib/core/helper/data_grc_module/constant/translation.dart` (En block around line 1770-1771, Ar block around line 1911-1912)

**Interfaces:**
- Produces: translation keys `'Policies Weight'`, `'History'`, `'Apply Changes'`, `'Changed By'`, `'Date Of Action'`, `'Policy Weight Current'`, `'Policy Weight Previous'` in both `en_US` and `ar_EG`. (`'Policy Weight Issue'`, `'Total Weight Should be 100'`, `'Equal Policy Weight'`, `'Discard Changes'`, `'No of Controls'`, `'Total Weight'`, `'You Have Successfully Edited Policies Weights'` already exist — reused as-is, not re-added.)

- [ ] **Step 1: Add the En keys**

In the `en_US` map, right after the existing line `'Total Weight': 'Total Weight',` (line 1771), insert:

```dart
          'Policies Weight': 'Policies Weight',
          'History': 'History',
          'Apply Changes': 'Apply Changes',
          'Changed By': 'Changed By',
          'Date Of Action': 'Date Of Action',
          'Policy Weight Current': 'Policy Weight Current',
          'Policy Weight Previous': 'Policy Weight Previous',
```

- [ ] **Step 2: Add the Ar keys**

In the `ar_EG` map, right after the existing line `'Total Weight Should be 100': 'يجب أن يكون الوزن الإجمالي 100',` (line 1911), insert:

```dart
          'Policies Weight': 'أوزان السياسات',
          'History': 'السجل',
          'Apply Changes': 'تطبيق التغييرات',
          'Changed By': 'تم التغيير بواسطة',
          'Date Of Action': 'تاريخ الإجراء',
          'Policy Weight Current': 'الوزن الحالي للسياسة',
          'Policy Weight Previous': 'الوزن السابق للسياسة',
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/core/helper/data_grc_module/constant/translation.dart`
Expected: No errors (a Dart map literal with new string entries never breaks analysis on its own — this step just confirms no stray syntax typo, e.g. a missing comma).

- [ ] **Step 4: Commit**

```bash
git add lib/core/helper/data_grc_module/constant/translation.dart
git commit -m "feat(grc): add translation keys for the Policy Weight Issue page"
```

---

### Task 5: `PolicyWeightIssueRow` — pure row/table math (unit tested)

**Files:**
- Create: `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row.dart`
- Test: `test/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row_test.dart`

**Interfaces:**
- Consumes: `PolicyEntity` (existing).
- Produces: `PolicyWeightIssueRow` (one row: `policyId`, `policyNumberEn/Ar`, `policyNameEn/Ar`, `policyDescriptionEn/Ar`, `startDate`, `endDate`, `noOfControls`, `initialWeight`, `weightController`, `currentWeight` getter, `hasChanged` getter, `resetToInitial()`, `setWeight(double)`, `dispose()`) and `PolicyWeightIssueRows` (the table: `rows`, `totalWeight`, `totalWeightValid`, `applyEqualWeight()`, `discardChanges()`, `changedRows`, `dispose()`). No Firebase/BuildContext dependency — mirrors `PolicyBulkUploadRows`.

- [ ] **Step 1: Write the failing test**

Create `test/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row.dart';

PolicyEntity _policy({required String id, required double weight}) {
  final now = DateTime(2026, 1, 1);
  return PolicyEntity(
    id: id,
    moduleId: 'm1',
    policyImage: null,
    policyNameEn: 'Policy $id',
    policyNameAr: 'سياسة $id',
    policyNumberEn: id,
    policyNumberAr: id,
    policyDescriptionEn: 'desc',
    policyDescriptionAr: 'desc',
    startDate: now,
    endDate: now.add(const Duration(days: 365)),
    policyWeight: weight,
    policyDocumentEn: null,
    policyDocumentAr: null,
    status: PolicyStatus.active,
    lastModifiedDate: now,
    lastEditor: 'a@x.com',
  );
}

void main() {
  group('PolicyWeightIssueRow', () {
    test('currentWeight starts equal to the policy weight, hasChanged is false', () {
      final row = PolicyWeightIssueRow.fromPolicy(_policy(id: 'p1', weight: 20), noOfControls: 3);
      expect(row.currentWeight, 20);
      expect(row.hasChanged, isFalse);
      row.dispose();
    });

    test('setWeight updates currentWeight and hasChanged', () {
      final row = PolicyWeightIssueRow.fromPolicy(_policy(id: 'p1', weight: 20), noOfControls: 3);
      row.setWeight(15);
      expect(row.currentWeight, 15);
      expect(row.hasChanged, isTrue);
      row.dispose();
    });

    test('resetToInitial reverts an edited row', () {
      final row = PolicyWeightIssueRow.fromPolicy(_policy(id: 'p1', weight: 20), noOfControls: 3);
      row.setWeight(15);
      row.resetToInitial();
      expect(row.currentWeight, 20);
      expect(row.hasChanged, isFalse);
      row.dispose();
    });
  });

  group('PolicyWeightIssueRows', () {
    PolicyWeightIssueRows buildRows(List<double> weights) {
      final rows = <PolicyWeightIssueRow>[];
      for (var i = 0; i < weights.length; i++) {
        rows.add(PolicyWeightIssueRow.fromPolicy(_policy(id: 'p$i', weight: weights[i]), noOfControls: 1));
      }
      return PolicyWeightIssueRows(rows);
    }

    test('totalWeight sums every row, totalWeightValid true only at 100', () {
      final rows = buildRows([60, 60]);
      expect(rows.totalWeight, 120);
      expect(rows.totalWeightValid, isFalse);
      rows.dispose();
    });

    test('applyEqualWeight splits 100 exactly across every row', () {
      final rows = buildRows([60, 60]);
      rows.applyEqualWeight();
      expect(rows.rows[0].currentWeight, 50);
      expect(rows.rows[1].currentWeight, 50);
      expect(rows.totalWeight, 100);
      expect(rows.totalWeightValid, isTrue);
      rows.dispose();
    });

    test('applyEqualWeight on 8 rows matches the 12.5-per-row example', () {
      final rows = buildRows(List.filled(8, 15));
      rows.applyEqualWeight();
      for (final row in rows.rows) {
        expect(row.currentWeight, 12.5);
      }
      expect(rows.totalWeightValid, isTrue);
      rows.dispose();
    });

    test('changedRows only returns rows whose weight actually moved', () {
      final rows = buildRows([20, 10]);
      rows.rows[0].setWeight(10);
      final changed = rows.changedRows;
      expect(changed, hasLength(1));
      expect(changed.first.policyId, 'p0');
      rows.dispose();
    });

    test('discardChanges reverts every row to its initial weight', () {
      final rows = buildRows([20, 10]);
      rows.applyEqualWeight();
      rows.discardChanges();
      expect(rows.rows[0].currentWeight, 20);
      expect(rows.rows[1].currentWeight, 10);
      expect(rows.changedRows, isEmpty);
      rows.dispose();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row_test.dart`
Expected: FAIL — the target file doesn't exist yet (import error).

- [ ] **Step 3: Implement `PolicyWeightIssueRow` and `PolicyWeightIssueRows`**

```dart
/// Module: Policy Management
/// Description: In-memory row/table model behind the Policy Weight Issue
///              page's editable table: one TextEditingController per row's
///              weight, plus the derived Total Weight the page needs.
///              Deliberately has no dependency on Firestore or use cases so
///              it can be unit tested directly (same spirit as
///              PolicyBulkUploadRows).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter, PolicyEntity
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:flutter/widgets.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';

/// class name: [PolicyWeightIssueRow]
///
/// purpose: one editable row of the Policies Weight table. Wraps a single
///          [PolicyEntity] plus its [noOfControls] (resolved separately,
///          Controls are not part of PolicyEntity) and a weight
///          [TextEditingController] the UI edits directly.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightIssueRow {
  final String policyId;
  final String policyNumberEn;
  final String policyNumberAr;
  final String policyNameEn;
  final String policyNameAr;
  final String policyDescriptionEn;
  final String policyDescriptionAr;
  final DateTime startDate;
  final DateTime endDate;
  final int noOfControls;
  final double initialWeight;
  final TextEditingController weightController;

  PolicyWeightIssueRow._({
    required this.policyId,
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.noOfControls,
    required this.initialWeight,
  }) : weightController = TextEditingController(text: _format(initialWeight));

  /// function name: [PolicyWeightIssueRow.fromPolicy]
  ///
  /// purpose: build a row from a loaded [PolicyEntity] and its separately
  ///          resolved Controls count.
  ///
  /// parameters:
  ///            [PolicyEntity] policy: the source policy
  ///            [int] noOfControls: number of Controls under this policy
  ///
  /// return type: [PolicyWeightIssueRow] - the new row
  factory PolicyWeightIssueRow.fromPolicy(
    PolicyEntity policy, {
    required int noOfControls,
  }) {
    return PolicyWeightIssueRow._(
      policyId: policy.id,
      policyNumberEn: policy.policyNumberEn,
      policyNumberAr: policy.policyNumberAr,
      policyNameEn: policy.policyNameEn,
      policyNameAr: policy.policyNameAr,
      policyDescriptionEn: policy.policyDescriptionEn,
      policyDescriptionAr: policy.policyDescriptionAr,
      startDate: policy.startDate,
      endDate: policy.endDate,
      noOfControls: noOfControls,
      initialWeight: policy.policyWeight,
    );
  }

  static String _format(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  /// The live value typed into [weightController], or 0 if unparsable.
  double get currentWeight =>
      double.tryParse(weightController.text.trim()) ?? 0;

  /// Whether the user has changed this row's weight from its last-saved value.
  bool get hasChanged => currentWeight != initialWeight;

  /// function name: [setWeight]
  ///
  /// purpose: overwrite [weightController]'s text with [value] (used by
  ///          Equal Weight).
  ///
  /// parameters:
  ///            [double] value: the new weight to display
  ///
  /// return type: [void]
  void setWeight(double value) {
    weightController.text = _format(value);
  }

  /// function name: [resetToInitial]
  ///
  /// purpose: revert [weightController] back to [initialWeight] (Discard
  ///          Changes).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void resetToInitial() {
    weightController.text = _format(initialWeight);
  }

  /// function name: [dispose]
  ///
  /// purpose: release [weightController]. Must be called whenever a
  ///          [PolicyWeightIssueRows] holding this row is discarded.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    weightController.dispose();
  }
}

/// class name: [PolicyWeightIssueRows]
///
/// purpose: own the full row list for the Policies Weight table and expose
///          the derived Total Weight / validity / Equal Weight / Discard /
///          changed-rows operations the cubit and page need.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightIssueRows {
  PolicyWeightIssueRows(this.rows);

  final List<PolicyWeightIssueRow> rows;

  /// Sum of every row's live weight value.
  double get totalWeight =>
      rows.fold<double>(0, (sum, row) => sum + row.currentWeight);

  /// The rule this page enforces: the sum must be (within floating-point
  /// tolerance of) exactly 100. A small epsilon is used instead of strict
  /// equality because `100 / n` for some row counts (e.g. n = 3) is not
  /// exactly representable as a double, so an untouched Equal Weight split
  /// must still validate.
  bool get totalWeightValid => (totalWeight - 100).abs() < 0.001;

  /// function name: [applyEqualWeight]
  ///
  /// purpose: set every row's weight to the exact decimal share `100 / n`
  ///          (the "Equal Weight" action). No-op on an empty table.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void applyEqualWeight() {
    if (rows.isEmpty) return;
    final share = 100 / rows.length;
    for (final row in rows) {
      row.setWeight(share);
    }
  }

  /// function name: [discardChanges]
  ///
  /// purpose: revert every row back to its last-saved weight (the "Discard
  ///          Changes" action).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void discardChanges() {
    for (final row in rows) {
      row.resetToInitial();
    }
  }

  /// Rows whose live weight differs from their last-saved value — exactly
  /// the set Apply Changes needs to persist.
  List<PolicyWeightIssueRow> get changedRows =>
      rows.where((row) => row.hasChanged).toList();

  /// function name: [dispose]
  ///
  /// purpose: dispose every row's controller.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    for (final row in rows) {
      row.dispose();
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row_test.dart`
Expected: PASS (9 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row.dart test/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row_test.dart
git commit -m "feat(grc): add PolicyWeightIssueRow/Rows table math for the Weight Issue page"
```

---

### Task 6: `PolicyWeightIssueCubit` + state + DI registration

**Files:**
- Create: `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart`
- Create: `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_state.dart`
- Modify: `lib/features/grc/grc_get_it.dart` (register the cubit)

**Interfaces:**
- Consumes: `GetAllPoliciesUseCase`, `GetAllControlsUseCase`, `UpdatePolicyUseCase`, `UpdatePolicyParams` (all existing), `PolicyWeightIssueRow`/`PolicyWeightIssueRows` (Task 5), `PolicyStatus.active`/`.scheduled` (existing).
- Produces: `PolicyWeightIssueCubit` with `load(String moduleId)`, `enterEditMode()`, `discardChanges()`, `applyEqualWeight()`, `revalidate()`, `applyChanges(String moduleId)`, and a `rowsData` getter (`PolicyWeightIssueRows`). States: `PolicyWeightIssueInitial`, `PolicyWeightIssueLoading`, `PolicyWeightIssueLoaded({required bool isEditing})`, `PolicyWeightIssueApplySuccess`, `PolicyWeightIssueFailure(String message)`.

- [ ] **Step 1: Create the state file**

```dart
part of 'policy_weight_issue_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_weight_issue_state.dart
/// Purpose: Contains all sealed state classes emitted by
///          [PolicyWeightIssueCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 19/7/2026

sealed class PolicyWeightIssueState {}

/// State emitted before the page has requested anything.
final class PolicyWeightIssueInitial extends PolicyWeightIssueState {}

/// State emitted while policies/controls are being fetched.
final class PolicyWeightIssueLoading extends PolicyWeightIssueState {}

/// State emitted once the row data is ready. [isEditing] drives whether the
/// Policies Weight tab renders view mode or edit mode.
final class PolicyWeightIssueLoaded extends PolicyWeightIssueState {
  final bool isEditing;

  PolicyWeightIssueLoaded({required this.isEditing});
}

/// State emitted once after Apply Changes completes successfully, before
/// the cubit reloads and emits a fresh [PolicyWeightIssueLoaded]. The page
/// listens for this to show a one-time success snackbar.
final class PolicyWeightIssueApplySuccess extends PolicyWeightIssueState {}

/// State emitted when any operation fails.
final class PolicyWeightIssueFailure extends PolicyWeightIssueState {
  final String message;

  PolicyWeightIssueFailure(this.message);
}
```

- [ ] **Step 2: Create the cubit**

```dart
/// Module: Policy Management
/// Description: BLoC Cubit that manages the Policy Weight Issue page's
///              state: loading the Active/Scheduled policies (+ their
///              Controls count) that make up a module's weight total,
///              editing them (Equal Weight or by hand), and applying the
///              changed rows back through UpdatePolicyUseCase.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, GetAllPoliciesUseCase, GetAllControlsUseCase,
///               UpdatePolicyUseCase, PolicyWeightIssueRow/Rows
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/update_policy_usecase.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'policy_weight_issue_state.dart';

/// class name: [PolicyWeightIssueCubit]
///
/// purpose: manage all state for the Policy Weight Issue page: fetching the
///          Active+Scheduled policies for a module plus each one's Controls
///          count, editing their weights in memory, and persisting the
///          changed rows via [UpdatePolicyUseCase] on Apply Changes.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightIssueCubit extends Cubit<PolicyWeightIssueState> {
  PolicyWeightIssueCubit({
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
  })  : _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _updatePolicyUseCase = updatePolicyUseCase,
        super(PolicyWeightIssueInitial());

  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final UpdatePolicyUseCase _updatePolicyUseCase;

  PolicyWeightIssueRows? _rowsData;

  /// The current row/table data. Only valid once a
  /// [PolicyWeightIssueLoaded] state has been emitted at least once.
  PolicyWeightIssueRows get rowsData => _rowsData!;

  /// Whether [load] has ever completed successfully — false only before
  /// the very first load, or if that first load failed. Lets the page tell
  /// "failed before there was any data to show" apart from "failed midway
  /// through an edit session, but the table is still there."
  bool get hasRows => _rowsData != null;

  /// Resolves the currently logged-in user's email (same pattern as
  /// PolicyCubit._currentUserEmail).
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  /// function name: [load]
  ///
  /// purpose: fetch every Active/Scheduled policy under [moduleId], resolve
  ///          each one's Controls count, and build fresh row data. Disposes
  ///          any previously held row data first.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<void>]
  Future<void> load(String moduleId) async {
    emit(PolicyWeightIssueLoading());

    final policiesResult = await _getAllPoliciesUseCase.call(moduleId: moduleId);
    final policies = policiesResult.fold((failure) {
      emit(PolicyWeightIssueFailure(failure.message));
      return null;
    }, (policies) => policies);
    if (policies == null) return;

    final scoped = policies
        .where((p) =>
            p.status == PolicyStatus.active || p.status == PolicyStatus.scheduled)
        .toList();

    final rows = <PolicyWeightIssueRow>[];
    for (final policy in scoped) {
      final controlsResult = await _getAllControlsUseCase.call(
        moduleId: moduleId,
        policyId: policy.id,
      );
      final noOfControls = controlsResult.fold((_) => 0, (controls) => controls.length);
      rows.add(PolicyWeightIssueRow.fromPolicy(policy, noOfControls: noOfControls));
    }

    _rowsData?.dispose();
    _rowsData = PolicyWeightIssueRows(rows);
    emit(PolicyWeightIssueLoaded(isEditing: false));
  }

  /// function name: [enterEditMode]
  ///
  /// purpose: switch the Policies Weight tab into edit mode (the "Edit"
  ///          button).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void enterEditMode() {
    emit(PolicyWeightIssueLoaded(isEditing: true));
  }

  /// function name: [discardChanges]
  ///
  /// purpose: revert every row and exit edit mode (the "Discard Changes"
  ///          button).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void discardChanges() {
    rowsData.discardChanges();
    emit(PolicyWeightIssueLoaded(isEditing: false));
  }

  /// function name: [applyEqualWeight]
  ///
  /// purpose: fill every row with an equal share of 100 (the "Equal Weight"
  ///          button). Stays in edit mode so the user can still hand-edit
  ///          afterward.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void applyEqualWeight() {
    rowsData.applyEqualWeight();
    emit(PolicyWeightIssueLoaded(isEditing: true));
  }

  /// function name: [revalidate]
  ///
  /// purpose: re-emit the current edit-mode state so the page rebuilds
  ///          (Total Weight box, Apply Changes enabled state) after a
  ///          hand-edited cell. Called from each cell's `onChanged`.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void revalidate() {
    emit(PolicyWeightIssueLoaded(isEditing: true));
  }

  /// function name: [applyChanges]
  ///
  /// purpose: persist every row whose weight actually changed via
  ///          [UpdatePolicyUseCase], one call per changed row. No-op if the
  ///          live total isn't exactly 100. On full success, reloads fresh
  ///          data and returns to view mode; on any failure, stops and
  ///          stays in edit mode so in-progress edits aren't lost.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<void>]
  Future<void> applyChanges(String moduleId) async {
    if (!rowsData.totalWeightValid) return;

    final changed = rowsData.changedRows;
    final editorId = _currentUserEmail;

    for (final row in changed) {
      final result = await _updatePolicyUseCase.call(
        UpdatePolicyParams(
          id: row.policyId,
          editorId: editorId,
          moduleId: moduleId,
          policyWeight: row.currentWeight,
        ),
      );
      final failureMessage = result.fold((failure) => failure.message, (_) => null);
      if (failureMessage != null) {
        // Emit Failure so the page's listener can show the error snackbar,
        // then immediately follow it with an editing Loaded state so the
        // builder keeps rendering the table in edit mode (rows/controllers
        // are untouched) instead of falling back to a bare error screen.
        emit(PolicyWeightIssueFailure(failureMessage));
        emit(PolicyWeightIssueLoaded(isEditing: true));
        return;
      }
    }

    emit(PolicyWeightIssueApplySuccess());
    await load(moduleId);
  }

  @override
  Future<void> close() {
    _rowsData?.dispose();
    return super.close();
  }
}
```

- [ ] **Step 3: Register it in `grc_get_it.dart`**

Add these imports at the top of `lib/features/grc/grc_get_it.dart` alongside the other Policy imports:

```dart
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart';
```

Insert this block right after the `PolicyCubit` registration (which ends at line 372):

```dart

  /// class name: [PolicyWeightIssueCubit]
  /// purpose: presentation-layer state manager for the Policy Weight Issue
  /// page's editable table. Registered as a factory so each page gets an
  /// independent cubit instance.
  sl.registerFactory<PolicyWeightIssueCubit>(
    () => PolicyWeightIssueCubit(
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
    ),
  );
```

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart lib/features/grc/grc_get_it.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_state.dart lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): add PolicyWeightIssueCubit and register it"
```

---

### Task 7: `PolicyWeightHistoryCubit` + state + DI registration

**Files:**
- Create: `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart`
- Create: `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_state.dart`
- Modify: `lib/features/grc/grc_get_it.dart` (register the cubit)

**Interfaces:**
- Consumes: `GetPolicyWeightHistoryUseCase` (Task 3), `GetAllControlsUseCase` (existing), `PolicyWeightHistoryEntry` (Task 1).
- Produces: `PolicyWeightHistoryCubit.loadHistory(String moduleId)`. States: `PolicyWeightHistoryInitial`, `PolicyWeightHistoryLoading`, `PolicyWeightHistoryLoaded(List<PolicyWeightHistoryEntry> entries, Map<String, int> controlCounts)`, `PolicyWeightHistoryFailure(String message)`. `controlCounts` maps `policyId -> noOfControls` (resolved per distinct policyId in the loaded entries — Controls counts are not part of the entry itself, matching the "Out of scope" boundary that `PolicyRepositoryImpl` stays Policy-only).

- [ ] **Step 1: Create the state file**

```dart
part of 'policy_weight_history_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_weight_history_state.dart
/// Purpose: Contains all sealed state classes emitted by
///          [PolicyWeightHistoryCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 19/7/2026

sealed class PolicyWeightHistoryState {}

final class PolicyWeightHistoryInitial extends PolicyWeightHistoryState {}

final class PolicyWeightHistoryLoading extends PolicyWeightHistoryState {}

/// [controlCounts] maps policyId -> current Controls count, resolved
/// separately per distinct policyId in [entries] (Controls aren't part of
/// the Policy revision history [entries] is built from).
final class PolicyWeightHistoryLoaded extends PolicyWeightHistoryState {
  final List<PolicyWeightHistoryEntry> entries;
  final Map<String, int> controlCounts;

  PolicyWeightHistoryLoaded(this.entries, this.controlCounts);
}

final class PolicyWeightHistoryFailure extends PolicyWeightHistoryState {
  final String message;

  PolicyWeightHistoryFailure(this.message);
}
```

- [ ] **Step 2: Create the cubit**

```dart
/// Module: Policy Management
/// Description: BLoC Cubit that manages the Policy Weight Issue page's
///              History tab: loads every recorded weight change for a
///              module and each affected policy's current Controls count.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, GetPolicyWeightHistoryUseCase, GetAllControlsUseCase
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_weight_history_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'policy_weight_history_state.dart';

/// class name: [PolicyWeightHistoryCubit]
///
/// purpose: load and expose the Policy weight-change history for one GRC
///          Module, plus each affected policy's current Controls count.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightHistoryCubit extends Cubit<PolicyWeightHistoryState> {
  PolicyWeightHistoryCubit({
    required GetPolicyWeightHistoryUseCase getPolicyWeightHistoryUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _getPolicyWeightHistoryUseCase = getPolicyWeightHistoryUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        super(PolicyWeightHistoryInitial());

  final GetPolicyWeightHistoryUseCase _getPolicyWeightHistoryUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;

  /// function name: [loadHistory]
  ///
  /// purpose: fetch [moduleId]'s full weight-change history, then resolve
  ///          the current Controls count for every distinct policyId that
  ///          appears in it.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<void>]
  Future<void> loadHistory(String moduleId) async {
    emit(PolicyWeightHistoryLoading());

    final result = await _getPolicyWeightHistoryUseCase.execute(moduleId);
    final entries = result.fold((failure) {
      emit(PolicyWeightHistoryFailure(failure.message));
      return null;
    }, (entries) => entries);
    if (entries == null) return;

    final controlCounts = <String, int>{};
    for (final policyId in entries.map((e) => e.policyId).toSet()) {
      final controlsResult = await _getAllControlsUseCase.call(
        moduleId: moduleId,
        policyId: policyId,
      );
      controlCounts[policyId] = controlsResult.fold((_) => 0, (controls) => controls.length);
    }

    emit(PolicyWeightHistoryLoaded(entries, controlCounts));
  }
}
```

- [ ] **Step 3: Register it in `grc_get_it.dart`**

Add this import at the top of `lib/features/grc/grc_get_it.dart`:

```dart
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart';
```

Insert this block right after the `PolicyWeightIssueCubit` registration from Task 6:

```dart

  /// class name: [PolicyWeightHistoryCubit]
  /// purpose: presentation-layer state manager for the Policy Weight
  /// Issue page's History tab. Registered as a factory so each page gets
  /// an independent cubit instance.
  sl.registerFactory<PolicyWeightHistoryCubit>(
    () => PolicyWeightHistoryCubit(
      getPolicyWeightHistoryUseCase: sl<GetPolicyWeightHistoryUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );
```

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart lib/features/grc/grc_get_it.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_state.dart lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): add PolicyWeightHistoryCubit and register it"
```

---

### Task 8: `PolicyWeightHistoryTab` widget

**Files:**
- Create: `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_tab.dart`

**Interfaces:**
- Consumes: `PolicyWeightHistoryCubit` (Task 7, provided by the parent page — see Task 9), `EmployeeHelper.getEmployeeLocalizedNameWithEmail`/`getEmployeeImageWithEmail` (existing), `AppColors`/`StyleText` (existing theme).
- Produces: `PolicyWeightHistoryTab` — a `StatelessWidget` that reads the already-provided `PolicyWeightHistoryCubit` via `context.read` and renders its state. Does not create its own `BlocProvider` (the page owns that — see Task 9).

- [ ] **Step 1: Implement the widget**

```dart
/// Module: Policy Management
/// Description: The Policy Weight Issue page's History tab: a table of
///              every recorded weight change across the module's policies.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, PolicyWeightHistoryCubit, EmployeeHelper, intl
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

/// class name: [PolicyWeightHistoryTab]
///
/// purpose: render the History tab of the Policy Weight Issue page,
///          reading an already-provided [PolicyWeightHistoryCubit] (the
///          parent page owns the [BlocProvider], same convention as the
///          Policies/Champions/Owners tabs on GrcModuleDetailsPage).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightHistoryTab extends StatelessWidget {
  const PolicyWeightHistoryTab({super.key});

  String _displayName(String email) {
    try {
      return EmployeeHelper.getEmployeeLocalizedNameWithEmail(employeeEmail: email);
    } catch (_) {
      return email;
    }
  }

  String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PolicyWeightHistoryCubit, PolicyWeightHistoryState>(
      builder: (context, state) {
        if (state is PolicyWeightHistoryLoading || state is PolicyWeightHistoryInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state is PolicyWeightHistoryFailure) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                state.message,
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final loaded = state as PolicyWeightHistoryLoaded;
        if (loaded.entries.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                'No Weight Changes'.tr,
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText),
              ),
            ),
          );
        }

        final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');

        return SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(52),
                  1: FlexColumnWidth(2.2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1.2),
                  4: FlexColumnWidth(1.4),
                  5: FlexColumnWidth(1.4),
                  6: FlexColumnWidth(1.6),
                },
                children: [
                  _headerRow(),
                  for (var i = 0; i < loaded.entries.length; i++)
                    _dataRow(
                      context: context,
                      entry: loaded.entries[i],
                      noOfControls: loaded.controlCounts[loaded.entries[i].policyId] ?? 0,
                      index: i,
                      dateFormat: dateFormat,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _headerRow() {
    final headers = [
      'NO',
      'Changed By',
      'Policy Name',
      'No of Controls',
      'Policy Weight Current',
      'Policy Weight Previous',
      'Date Of Action',
    ];
    return TableRow(
      decoration: const BoxDecoration(color: Colors.black),
      children: headers
          .map(
            (header) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              child: Text(
                header.tr,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _dataRow({
    required BuildContext context,
    required PolicyWeightHistoryEntry entry,
    required int noOfControls,
    required int index,
    required DateFormat dateFormat,
  }) {
    final isEven = index % 2 == 0;
    return TableRow(
      decoration: BoxDecoration(color: isEven ? AppColors.background : AppColors.field),
      children: [
        _cell(Text('${index + 1}', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(_displayName(entry.changedByEmail),
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
        _cell(Text(context.isArabic ? entry.policyNameAr : entry.policyNameEn,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
        _cell(Text('$noOfControls', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(_formatWeight(entry.weightCurrent), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text))),
        _cell(Text(_formatWeight(entry.weightPrevious), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(dateFormat.format(entry.dateOfAction), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
      ],
    );
  }

  Widget _cell(Widget child) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h), child: child);
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_tab.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_tab.dart
git commit -m "feat(grc): add PolicyWeightHistoryTab widget"
```

---

### Task 9: `PolicyWeightIssuePage` — tabs, breadcrumb, Policies Weight (view + edit mode)

**Files:**
- Create: `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart`

**Interfaces:**
- Consumes: `PolicyWeightIssueCubit` (Task 6), `PolicyWeightHistoryCubit` (Task 7), `PolicyWeightHistoryTab` (Task 8), `GRCModuleEntity` (existing), `customButton` (existing, `lib/features/settings/core_widgets/main_widget/custom_button_widget.dart`), `PaginationAppBar` (existing).
- Produces: `PolicyWeightIssuePage({required GRCModuleEntity module})` — the page pushed from `GrcModuleDetailsPage`'s button (wired in Task 10).

- [ ] **Step 1: Implement the page**

```dart
/// Module: Policy Management
/// Description: Page opened from GrcModuleDetailsPage's "Policy Weight
///              Issue" button. Two tabs: "Policies Weight" (an editable
///              table of the Active/Scheduled policies making up the
///              module's weight total, with Equal Weight / manual editing)
///              and "History" (every recorded weight change).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, get_it, PolicyWeightIssueCubit,
///               PolicyWeightHistoryCubit, PolicyWeightHistoryTab
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_tab.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// class name: [PolicyWeightIssuePage]
///
/// purpose: host the Policies Weight / History tabs for one GRC Module,
///          provisioning its own [PolicyWeightIssueCubit] and
///          [PolicyWeightHistoryCubit] (same pattern as
///          GrcPreviousModuleOwnersPage / AddChampionPage provisioning
///          their own cubits when pushed).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightIssuePage extends StatelessWidget {
  final GRCModuleEntity module;

  const PolicyWeightIssuePage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyWeightIssueCubit>(
          create: (_) => GetIt.instance<PolicyWeightIssueCubit>()..load(module.moduleId),
        ),
        BlocProvider<PolicyWeightHistoryCubit>(
          create: (_) => GetIt.instance<PolicyWeightHistoryCubit>()..loadHistory(module.moduleId),
        ),
      ],
      child: _PolicyWeightIssueBody(module: module),
    );
  }
}

class _PolicyWeightIssueBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _PolicyWeightIssueBody({required this.module});

  @override
  State<_PolicyWeightIssueBody> createState() => _PolicyWeightIssueBodyState();
}

class _PolicyWeightIssueBodyState extends State<_PolicyWeightIssueBody> {
  int _selectedTab = 0;

  String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  'GRC'.tr,
                  context.isArabic ? widget.module.moduleNameAr : widget.module.moduleNameEn,
                  'Policy Weight Issue'.tr,
                ],
              ),
              SizedBox(height: 15.h),
              _buildTabs(),
              SizedBox(height: 15.h),
              Expanded(
                child: _selectedTab == 0
                    ? _buildPoliciesWeightTab(context)
                    : const PolicyWeightHistoryTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabItem('Policies Weight', 0),
        SizedBox(width: 24.w),
        _tabItem('History', 1),
      ],
    );
  }

  Widget _tabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr,
            style: StyleText.fontSize16Weight500.copyWith(
              color: isSelected ? AppColors.primary : AppColors.secondaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          if (isSelected)
            Container(height: 2.h, width: 90.w, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildPoliciesWeightTab(BuildContext context) {
    return BlocConsumer<PolicyWeightIssueCubit, PolicyWeightIssueState>(
      listener: (context, state) {
        if (state is PolicyWeightIssueApplySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You Have Successfully Edited Policies Weights'.tr)),
          );
        }
        if (state is PolicyWeightIssueFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is PolicyWeightIssueLoading || state is PolicyWeightIssueInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final cubit = context.read<PolicyWeightIssueCubit>();

        // A failure on the very first load means `_rowsData` was never set
        // (cubit.rowsData would throw) — show the error instead of the
        // table. A failure from Apply Changes never reaches here because
        // applyChanges() only emits Failure before touching `_rowsData`.
        if (state is PolicyWeightIssueFailure && !cubit.hasRows) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                state.message,
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final isEditing = state is PolicyWeightIssueLoaded && state.isEditing;
        final rowsData = cubit.rowsData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (isEditing)
                  customButton(
                    title: 'Equal Policy Weight'.tr,
                    function: cubit.applyEqualWeight,
                    width: 160.w,
                    height: 36.h,
                    color: AppColors.black,
                  ),
                const Spacer(),
                if (!isEditing)
                  customButton(
                    title: 'Edit'.tr,
                    function: cubit.enterEditMode,
                    width: 100.w,
                    height: 36.h,
                    color: AppColors.primary,
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: _buildTable(context, rowsData, isEditing, cubit),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Align(alignment: Alignment.centerRight, child: _buildTotalWeight(rowsData)),
            SizedBox(height: 12.h),
            if (isEditing)
              Row(
                children: [
                  customButton(
                    title: 'Discard Changes'.tr,
                    function: cubit.discardChanges,
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.secondaryText,
                  ),
                  const Spacer(),
                  customButton(
                    title: 'Apply Changes'.tr,
                    function: rowsData.totalWeightValid
                        ? () => cubit.applyChanges(widget.module.moduleId)
                        : () {},
                    width: 150.w,
                    height: 38.h,
                    color: rowsData.totalWeightValid ? AppColors.primary : AppColors.secondaryText,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  static const List<double> _columnWidths = [40, 110, 150, 200, 110, 100, 110, 110];
  static const List<String> _headers = [
    'NO', 'Policy Number', 'Policy Name', 'Policy Description',
    'Policy Weight', 'No of Controls', 'Start Date', 'End Date',
  ];

  Widget _buildTable(
    BuildContext context,
    PolicyWeightIssueRows rowsData,
    bool isEditing,
    PolicyWeightIssueCubit cubit,
  ) {
    final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < _headers.length; i++)
              SizedBox(
                width: _columnWidths[i].w,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(_headers[i].tr, style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text)),
                ),
              ),
          ],
        ),
        for (var i = 0; i < rowsData.rows.length; i++)
          _buildRow(context, rowsData.rows[i], i, isEditing, cubit, dateFormat),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    PolicyWeightIssueRow row,
    int index,
    bool isEditing,
    PolicyWeightIssueCubit cubit,
    DateFormat dateFormat,
  ) {
    final isArabic = context.isArabic;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cell(0, Text('${index + 1}', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
          _cell(1, Text(isArabic ? row.policyNumberAr : row.policyNumberEn, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
          _cell(2, Text(isArabic ? row.policyNameAr : row.policyNameEn, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
          _cell(3, Text(isArabic ? row.policyDescriptionAr : row.policyDescriptionEn, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
          _cell(
            4,
            isEditing
                ? TextField(
                    controller: row.weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => cubit.revalidate(),
                    style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
                    ),
                  )
                : Text(_formatWeight(row.currentWeight), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
          ),
          _cell(5, Text('${row.noOfControls}', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
          _cell(6, Text(dateFormat.format(row.startDate), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
          _cell(7, Text(dateFormat.format(row.endDate), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        ],
      ),
    );
  }

  Widget _cell(int columnIndex, Widget child) {
    return SizedBox(
      width: _columnWidths[columnIndex].w,
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: child),
    );
  }

  Widget _buildTotalWeight(PolicyWeightIssueRows rowsData) {
    final valid = rowsData.totalWeightValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: valid ? AppColors.green : AppColors.red),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '${'Total Weight'.tr} : ${_formatWeight(rowsData.totalWeight)}',
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        if (!valid) ...[
          SizedBox(height: 4.h),
          Text(
            'Total Weight Should be 100'.tr,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart
git commit -m "feat(grc): add PolicyWeightIssuePage with Policies Weight + History tabs"
```

---

### Task 10: Wire the button on `GrcModuleDetailsPage`

**Files:**
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart:490-499`

**Interfaces:**
- Consumes: `PolicyWeightIssuePage` (Task 9).

- [ ] **Step 1: Add the import**

At the top of `lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart`, add (alongside the other page imports, e.g. right after the `policy_details_page.dart` import):

```dart
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart';
```

- [ ] **Step 2: Wire the button's `function`**

Replace this block (`grc_module_details_page.dart:490-499`):

```dart
            if (hasPolicyWeightIssue)
              customButton(
                title: "Policy Weight Issue".tr,
                function: () {},
                width: isTablet ? 180.w : 160.w,
                height: 38.h,
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
              ),
```

with:

```dart
            if (hasPolicyWeightIssue)
              customButton(
                title: "Policy Weight Issue".tr,
                function: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        PolicyWeightIssuePage(module: widget.module),
                    transitionsBuilder: (_, animation, __, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
                width: isTablet ? 180.w : 160.w,
                height: 38.h,
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
              ),
```

(This matches the existing `PageRouteBuilder` + fade-transition convention already used by `_showPolicyCreationMenu` in the same file.)

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart
git commit -m "feat(grc): wire the Policy Weight Issue button to open the new page"
```

---

### Task 11: Full-project analyze + manual verification

**Files:** none (verification only)

- [ ] **Step 1: Run the full analyzer**

Run: `flutter analyze`
Expected: No new errors introduced by this feature (pre-existing warnings elsewhere in the repo are out of scope).

- [ ] **Step 2: Run every unit test added in this plan**

Run: `flutter test test/features/grc/policy/`
Expected: All tests from Tasks 1 and 5 PASS.

- [ ] **Step 3: Manual run-through**

Run the app (`flutter run`), navigate to a GRC Module whose Active+Scheduled policies sum to more than 100 (or temporarily edit one policy's weight via the existing Edit Policy flow to create that condition), then on `GrcModuleDetailsPage`:

1. Confirm the "Policy Weight Issue" button is visible (only appears when the sum > 100) and tapping it opens the new page with breadcrumb `GRC > {Module Name} > Policy Weight Issue`.
2. On the "Policies Weight" tab (view mode): confirm the table lists only Active/Scheduled policies, the Total Weight box is red with "Total Weight Should be 100" shown, and there's an "Edit" button.
3. Tap "Edit": confirm the Policy Weight column becomes editable and an "Equal Policy Weight" button appears.
4. Tap "Equal Policy Weight": confirm every row now shows `100 / n` and the Total Weight box turns green with "Apply Changes" enabled.
5. Hand-edit one cell so the sum is no longer 100: confirm the Total Weight box turns red again and "Apply Changes" is disabled/grey.
6. Fix the cell back to a sum of exactly 100 and tap "Apply Changes": confirm a success snackbar appears, the page stays on the Policies Weight tab in view mode with the new values, and re-opening `GrcModuleDetailsPage` no longer shows the "Policy Weight Issue" button.
7. Switch to the "History" tab: confirm it lists only the policy row(s) whose weight actually changed in step 6, with the correct Changed By (your logged-in user), Policy Weight Current/Previous, and today's date — and that policies whose weight didn't change in that Apply do not appear.

- [ ] **Step 4: Report results**

If any manual-verification step fails, note exactly which step and what was observed instead before moving on — do not mark this task done until all 7 checks pass.
