# Control Weight Issue Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing "Control Weight Issue" banner button on `PolicyViewModeWidget` open a page where the user can view the Controls under one Policy that make its total weight != 100, fix the imbalance (equal-split or manual edit), and see a History of every past weight change — the same feature already built for Policy Weight Issue, one level down the hierarchy.

**Architecture:** New `ControlWeightHistoryEntry` domain entity + `ControlModel.toWeightHistory()` reconstruct weight-change history from the revision-history lists `ControlModel` already stores (identical technique to `PolicyModel.toWeightHistory()`) — no new Firestore collection. A new self-contained `control_weight_issue/` presentation folder (sibling of `policy_weight_issue/`) holds two cubits (`ControlWeightIssueCubit` for the editable table, `ControlWeightHistoryCubit` for the History tab) and one page with two tabs, following the exact patterns used by `PolicyWeightIssuePage`/`PolicyWeightHistoryTab`/`PolicyWeightIssueRow`.

**Tech Stack:** Flutter, flutter_bloc (Cubit), GetIt (`sl`), dartz (`Either<Failure, T>`), Cloud Firestore (existing `ControlFirebaseDataSource`, untouched), GetX `.tr()` translations, `intl` `DateFormat`.

## Global Constraints

- The banner's existing trigger condition is kept exactly as-is: `total != 100` (over OR under), and **every** Control under the Policy is included regardless of status — no Active/Scheduled-only filter (this is a deliberate difference from Policy Weight Issue's `> 100` + Active/Scheduled-only rule; the existing `_hasControlWeightIssue`/`_buildWeightIssueBanner(widget.controls)` code in `policy_view_mode_widget.dart` already works this way and is not being changed).
- The "No of Controls" column from Policy Weight Issue becomes **"No of Departments"** here (`control.departments.length`) — a Control's children are departments, not sub-controls. Unlike Policy (which needed a separate per-policy Controls-count fetch), `ControlEntity` already carries its own `departments` list directly, so no secondary fetch loop is needed anywhere in this plan.
- Equal Weight fills every row with the exact decimal `100 / n` (no rounding/remainder redistribution) — same as Policy Weight Issue.
- Apply Changes stays disabled until the live sum of all rows is 100 (small epsilon tolerance for double math — see Task 5).
- After a successful Apply Changes, the page stays on the Controls Weight tab in view mode (refreshed values) — no auto-navigation.
- History logs only Controls whose weight actually changed in a given Apply — no no-op rows for unchanged Controls.
- No new Firestore collection/subcollection. History is derived, on read, from `ControlModel`'s existing per-field revision-history lists.
- This codebase has no existing test/mock infrastructure for Firebase-backed cubits/repositories. Where a task's logic is plain Dart with no Firebase/BuildContext dependency (the model diffing algorithm, the row/total-weight math), write a real unit test. Everywhere else, verify with `dart analyze`/`flutter analyze` (whichever is available) plus the manual run-through in the final task.
- Follow existing GRC naming/file-header conventions (see any file under `lib/features/grc/` for the `/// Module: ... /// Author: ...` header block style) when creating new files. `ControlEntity`/`ControlModel` name their fields with a "Controls" (plural) prefix even for single-control fields (`controlsNameEn`, `controlsWeight`, etc.) — new types in this plan mirror that naming exactly rather than switching to a singular "control" prefix, so field names match their source 1:1.

---

## File Structure

New files:
- `lib/features/grc/control/domain/entities/control_weight_history_entry.dart`
- `lib/features/grc/control/domain/use_cases/get_control_weight_history_use_case.dart`
- `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart` (pure row/table math — no Firebase)
- `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart` + `control_weight_issue_state.dart`
- `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart` + `control_weight_history_state.dart`
- `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart`
- `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_tab.dart`
- `test/features/grc/control/data/models/control_model_weight_history_test.dart`
- `test/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row_test.dart`

Modified files:
- `lib/features/grc/control/data/models/control_model.dart` (add `toWeightHistory()`)
- `lib/features/grc/control/domain/repository/control_repository.dart` (add `getControlWeightHistory` to the interface)
- `lib/features/grc/control/data/repository/control_repository_impl.dart` (implement it)
- `lib/features/grc/grc_get_it.dart` (register the new use case + 2 cubits)
- `lib/core/helper/data_grc_module/constant/translation.dart` (add missing En/Ar keys)
- `lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart` (wire the banner button)

---

### Task 1: `ControlWeightHistoryEntry` entity + `ControlModel.toWeightHistory()`

**Files:**
- Create: `lib/features/grc/control/domain/entities/control_weight_history_entry.dart`
- Modify: `lib/features/grc/control/data/models/control_model.dart:495-528` (add a method right after `toEntity()`, before the class's closing brace)
- Test: `test/features/grc/control/data/models/control_model_weight_history_test.dart`

**Interfaces:**
- Produces: `ControlWeightHistoryEntry` (fields: `controlId`, `policyId`, `controlsNameEn`, `controlsNameAr`, `weightPrevious`, `weightCurrent`, `changedByEmail`, `dateOfAction`), `ControlModel.toWeightHistory() -> List<ControlWeightHistoryEntry>`.

- [ ] **Step 1: Create the entity**

```dart
/// Module: Policy Management
/// Description: One recorded change to a Control's weight — reconstructed
///              from ControlModel's revision history, never persisted on
///              its own.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: None
/// Revision History: 2026-07-20 - Initial creation
library;

/// class name: [ControlWeightHistoryEntry]
///
/// purpose: represents one revision where a Control's weight changed from
///          [weightPrevious] to [weightCurrent], saved by [changedByEmail]
///          on [dateOfAction]. Only ever produced for revisions where the
///          weight actually changed — see [ControlModel.toWeightHistory].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightHistoryEntry {
  final String controlId;
  final String policyId;
  final String controlsNameEn;
  final String controlsNameAr;
  final double weightPrevious;
  final double weightCurrent;
  final String changedByEmail;
  final DateTime dateOfAction;

  const ControlWeightHistoryEntry({
    required this.controlId,
    required this.policyId,
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.weightPrevious,
    required this.weightCurrent,
    required this.changedByEmail,
    required this.dateOfAction,
  });
}
```

- [ ] **Step 2: Write the failing test for `toWeightHistory()`**

Create `test/features/grc/control/data/models/control_model_weight_history_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/control/data/models/control_model.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_department_weight.dart';

ControlModel _baseModel({required List<double> weights, required List<String> editors}) {
  final n = weights.length;
  final baseDate = DateTime(2026, 1, 1);
  return ControlModel(
    id: 'c1',
    policyId: 'p1',
    controlsNameEn: List<String>.filled(n, 'Access Review'),
    controlsNameAr: List<String>.filled(n, 'مراجعة الوصول'),
    controlsNumberEn: List<String>.filled(n, 'CN-1'),
    controlsNumberAr: List<String>.filled(n, 'CN-1'),
    controlsDescriptionEn: List<String>.filled(n, 'desc'),
    controlsDescriptionAr: List<String>.filled(n, 'desc'),
    controlsDocumentEn: List<String?>.filled(n, null),
    controlsDocumentAr: List<String?>.filled(n, null),
    controlsWeight: weights,
    frequency: List<String>.filled(n, 'Quarterly'),
    startDate: List<DateTime>.filled(n, baseDate),
    endDate: List<DateTime>.filled(n, baseDate.add(const Duration(days: 365))),
    departments: List<List<DepartmentWeight>>.generate(n, (_) => <DepartmentWeight>[]),
    equalWeights: List<bool>.filled(n, false),
    score: List<int>.filled(n, 0),
    status: List<String>.filled(n, ControlStatus.active.value),
    lastModifiedDate: List<DateTime>.generate(n, (i) => baseDate.add(Duration(days: i))),
    editors: editors,
  );
}

void main() {
  group('ControlModel.toWeightHistory', () {
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
      expect(history.first.controlId, 'c1');
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

Run: `flutter test test/features/grc/control/data/models/control_model_weight_history_test.dart`
Expected: FAIL — `The method 'toWeightHistory' isn't defined for the type 'ControlModel'`.

- [ ] **Step 4: Add `toWeightHistory()` to `ControlModel`**

In `lib/features/grc/control/data/models/control_model.dart`, add this import at the top (alongside the other three entity imports):

```dart
import 'package:demo_app/features/grc/control/domain/entities/control_weight_history_entry.dart';
```

Then insert this method right after `toEntity()` (which currently ends the class at line 527-528), before the final closing `}`:

```dart
  /// function name: [toWeightHistory]
  ///
  /// purpose: reconstruct every recorded weight change by diffing
  ///          [controlsWeight] between consecutive revisions. A change at
  ///          revision N is credited to whoever saved that revision
  ///          ([editors][N]) on [lastModifiedDate][N]. Revisions that
  ///          didn't touch the weight (previous == current) emit nothing.
  ///
  /// parameters: none
  ///
  /// return type: [List<ControlWeightHistoryEntry>] - one entry per weight change, in revision order
  List<ControlWeightHistoryEntry> toWeightHistory() {
    final entries = <ControlWeightHistoryEntry>[];
    for (var i = 1; i < controlsWeight.length; i++) {
      if (controlsWeight[i] == controlsWeight[i - 1]) continue;
      entries.add(
        ControlWeightHistoryEntry(
          controlId: id,
          policyId: policyId,
          controlsNameEn: controlsNameEn[i],
          controlsNameAr: controlsNameAr[i],
          weightPrevious: controlsWeight[i - 1],
          weightCurrent: controlsWeight[i],
          changedByEmail: editors[i],
          dateOfAction: lastModifiedDate[i],
        ),
      );
    }
    return entries;
  }
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/grc/control/data/models/control_model_weight_history_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/control/domain/entities/control_weight_history_entry.dart lib/features/grc/control/data/models/control_model.dart test/features/grc/control/data/models/control_model_weight_history_test.dart
git commit -m "feat(grc): add ControlWeightHistoryEntry and ControlModel.toWeightHistory()"
```

---

### Task 2: `ControlRepository.getControlWeightHistory` + implementation

**Files:**
- Modify: `lib/features/grc/control/domain/repository/control_repository.dart:60-63` (add the method signature right after `getAllControls`)
- Modify: `lib/features/grc/control/data/repository/control_repository_impl.dart:152-165` (add the implementation right after `getAllControls`)

**Interfaces:**
- Consumes: `ControlWeightHistoryEntry`, `ControlModel.toWeightHistory()` from Task 1; `ControlFirebaseDataSource.getAll({required moduleId, required policyId})` (existing — note Controls have no `includeRemoved` flag, unlike Policies, since Controls have no Removed status).
- Produces: `ControlRepository.getControlWeightHistory({required String moduleId, required String policyId}) -> Future<Either<Failure, List<ControlWeightHistoryEntry>>>`, sorted by `dateOfAction` descending.

- [ ] **Step 1: Add the method to the `ControlRepository` interface**

In `lib/features/grc/control/domain/repository/control_repository.dart`, add this import near the top:

```dart
import 'package:demo_app/features/grc/control/domain/entities/control_weight_history_entry.dart';
```

Then insert this method into the `abstract class ControlRepository` body, right after the closing `});` of `getAllControls` (currently ending at line 63) and before the `Future<Either<Failure, ControlEntity>> updateControl({` signature:

```dart
  /// function name: [getControlWeightHistory]
  ///
  /// purpose: fetch every recorded weight change across all Controls under
  ///          one Policy, reconstructed from each Control's own revision
  ///          history (see [ControlModel.toWeightHistory]). No dedicated
  ///          Firestore log exists for this — it's derived on read.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<Either<Failure, List<ControlWeightHistoryEntry>>>] - every weight-change entry across the policy's controls, sorted by date descending, or a Failure
  Future<Either<Failure, List<ControlWeightHistoryEntry>>> getControlWeightHistory({
    required String moduleId,
    required String policyId,
  });
```

- [ ] **Step 2: Implement it in `ControlRepositoryImpl`**

In `lib/features/grc/control/data/repository/control_repository_impl.dart`, add this import (with the others):

```dart
import 'package:demo_app/features/grc/control/domain/entities/control_weight_history_entry.dart';
```

Then insert this method right after the closing `}` of the `getAllControls` override (currently ending at line 165), before the `updateControl` override:

```dart
  /// function name: [getControlWeightHistory]
  ///
  /// purpose: fetch every Control's full revision history for
  ///          [moduleId]/[policyId] and flat-map
  ///          [ControlModel.toWeightHistory] across all of them, sorted by
  ///          date descending (most recent change first).
  ///
  /// parameters: see [ControlRepository.getControlWeightHistory]
  ///
  /// return type: [Future<Either<Failure, List<ControlWeightHistoryEntry>>>] - see [ControlRepository.getControlWeightHistory]
  @override
  Future<Either<Failure, List<ControlWeightHistoryEntry>>> getControlWeightHistory({
    required String moduleId,
    required String policyId,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        policyId: policyId,
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

Run: `flutter analyze lib/features/grc/control/domain/repository/control_repository.dart lib/features/grc/control/data/repository/control_repository_impl.dart`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/domain/repository/control_repository.dart lib/features/grc/control/data/repository/control_repository_impl.dart
git commit -m "feat(grc): add ControlRepository.getControlWeightHistory"
```

---

### Task 3: `GetControlWeightHistoryUseCase` + DI registration

**Files:**
- Create: `lib/features/grc/control/domain/use_cases/get_control_weight_history_use_case.dart`
- Modify: `lib/features/grc/grc_get_it.dart:284-288` (add registration right after `DeleteControlUseCase`)

**Interfaces:**
- Consumes: `ControlRepository.getControlWeightHistory` (Task 2).
- Produces: `GetControlWeightHistoryUseCase.execute(String moduleId, String policyId) -> Future<Either<Failure, List<ControlWeightHistoryEntry>>>`.

- [ ] **Step 1: Create the use case**

```dart
/// Module: Policy Management
/// Description: Use case responsible for fetching every recorded weight
///              change across one Policy's Controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: dartz, ControlRepository, ControlWeightHistoryEntry, Failure
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:demo_app/features/grc/control/domain/repository/control_repository.dart';

/// class name: [GetControlWeightHistoryUseCase]
///
/// purpose: encapsulate the business logic for fetching a Policy's Control
///          weight-change history. Delegates to
///          [ControlRepository.getControlWeightHistory].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class GetControlWeightHistoryUseCase {
  final ControlRepository _repository;

  GetControlWeightHistoryUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch the weight-change history for every Control under
  ///          [moduleId]/[policyId].
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<Either<Failure, List<ControlWeightHistoryEntry>>>] - every weight-change entry, or a Failure
  Future<Either<Failure, List<ControlWeightHistoryEntry>>> execute(
    String moduleId,
    String policyId,
  ) {
    return _repository.getControlWeightHistory(
      moduleId: moduleId,
      policyId: policyId,
    );
  }
}
```

- [ ] **Step 2: Register it in `grc_get_it.dart`**

Add this import at the top of `lib/features/grc/grc_get_it.dart` alongside the other Control use-case imports:

```dart
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_weight_history_use_case.dart';
```

Insert this block right after the existing `DeleteControlUseCase` registration (ends at line 288), before the `CreateChampionUseCase` registration:

```dart

  /// class name: [GetControlWeightHistoryUseCase]
  /// purpose: business logic for fetching a policy's Control weight history.
  sl.registerLazySingleton<GetControlWeightHistoryUseCase>(
    () => GetControlWeightHistoryUseCase(sl<ControlRepository>()),
  );
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/features/grc/grc_get_it.dart`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/domain/use_cases/get_control_weight_history_use_case.dart lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): add GetControlWeightHistoryUseCase and register it"
```

---

### Task 4: Missing translation keys

**Files:**
- Modify: `lib/core/helper/data_grc_module/constant/translation.dart` (En block around line 1697, Ar block around line 1953)

**Interfaces:**
- Produces: translation keys `'Control Weight Issue'`, `'Equal Control Weight'`, `'Control Number'`, `'No of Departments'`, `'Controls Weight'`, `'Control Weight Current'`, `'Control Weight Previous'`, `'You Have Successfully Edited Controls Weights'` in both `en_US` and `ar_EG`. (`'Edit'`, `'Discard Changes'`, `'Apply Changes'`, `'History'`, `'Changed By'`, `'Date Of Action'`, `'Total Weight'`, `'Total Weight Should be 100'`, `'Control Name'`, `'Control Description'`, `'Control Weight'`, `'Start Date'`, `'End Date'`, `'Back'` already exist with generic wording — reused as-is, not re-added.)

- [ ] **Step 1: Add the En keys**

In the `en_US` map, right after the existing line `'Control Weight': 'Control Weight',` (line 1697), insert:

```dart
          'Control Weight Issue': 'Control Weight Issue',
          'Equal Control Weight': 'Equal Control Weight',
          'Control Number': 'Control Number',
          'No of Departments': 'No of Departments',
          'Controls Weight': 'Controls Weight',
          'Control Weight Current': 'Control Weight Current',
          'Control Weight Previous': 'Control Weight Previous',
          'You Have Successfully Edited Controls Weights': 'You Have Successfully Edited Controls Weights',
```

- [ ] **Step 2: Add the Ar keys**

In the `ar_EG` map, right after the existing line `'Control Weight': 'وزن الضابط',` (line 1953), insert:

```dart
          'Control Weight Issue': 'قضية وزن الضابط',
          'Equal Control Weight': 'وزن الضابط المتساوي',
          'Control Number': 'رقم الضابط',
          'No of Departments': 'عدد الأقسام',
          'Controls Weight': 'أوزان الضوابط',
          'Control Weight Current': 'الوزن الحالي للضابط',
          'Control Weight Previous': 'الوزن السابق للضابط',
          'You Have Successfully Edited Controls Weights': 'لقد قمت بتحرير أوزان الضوابط بنجاح',
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/core/helper/data_grc_module/constant/translation.dart`
Expected: No errors (this just confirms no stray syntax typo, e.g. a missing comma).

- [ ] **Step 4: Commit**

```bash
git add lib/core/helper/data_grc_module/constant/translation.dart
git commit -m "feat(grc): add translation keys for the Control Weight Issue page"
```

---

### Task 5: `ControlWeightIssueRow` — pure row/table math (unit tested)

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart`
- Test: `test/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row_test.dart`

**Interfaces:**
- Consumes: `ControlEntity` (existing).
- Produces: `ControlWeightIssueRow` (one row: `controlId`, `controlsNumberEn/Ar`, `controlsNameEn/Ar`, `controlsDescriptionEn/Ar`, `startDate`, `endDate`, `noOfDepartments`, `initialWeight`, `weightController`, `currentWeight` getter, `hasChanged` getter, `resetToInitial()`, `setWeight(double)`, `dispose()`) and `ControlWeightIssueRows` (the table: `rows`, `totalWeight`, `totalWeightValid`, `applyEqualWeight()`, `discardChanges()`, `changedRows`, `dispose()`). No Firebase/BuildContext dependency — mirrors `PolicyWeightIssueRow`/`Rows`.

- [ ] **Step 1: Write the failing test**

Create `test/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_department_weight.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart';

ControlEntity _control({required String id, required double weight, int departmentCount = 1}) {
  final now = DateTime(2026, 1, 1);
  return ControlEntity(
    id: id,
    policyId: 'p1',
    controlsNameEn: 'Control $id',
    controlsNameAr: 'ضابط $id',
    controlsNumberEn: id,
    controlsNumberAr: id,
    controlsDescriptionEn: 'desc',
    controlsDescriptionAr: 'desc',
    controlsDocumentEn: null,
    controlsDocumentAr: null,
    controlsWeight: weight,
    frequency: 'Quarterly',
    startDate: now,
    endDate: now.add(const Duration(days: 365)),
    departments: List<DepartmentWeight>.generate(
      departmentCount,
      (i) => DepartmentWeight(department: 'Dept $i', weight: 100 / departmentCount),
    ),
    equalWeights: true,
    score: 0,
    status: ControlStatus.active,
    lastModifiedDate: now,
    lastEditor: 'a@x.com',
  );
}

void main() {
  group('ControlWeightIssueRow', () {
    test('currentWeight starts equal to the control weight, hasChanged is false', () {
      final row = ControlWeightIssueRow.fromControl(_control(id: 'c1', weight: 20, departmentCount: 3));
      expect(row.currentWeight, 20);
      expect(row.noOfDepartments, 3);
      expect(row.hasChanged, isFalse);
      row.dispose();
    });

    test('setWeight updates currentWeight and hasChanged', () {
      final row = ControlWeightIssueRow.fromControl(_control(id: 'c1', weight: 20));
      row.setWeight(15);
      expect(row.currentWeight, 15);
      expect(row.hasChanged, isTrue);
      row.dispose();
    });

    test('resetToInitial reverts an edited row', () {
      final row = ControlWeightIssueRow.fromControl(_control(id: 'c1', weight: 20));
      row.setWeight(15);
      row.resetToInitial();
      expect(row.currentWeight, 20);
      expect(row.hasChanged, isFalse);
      row.dispose();
    });
  });

  group('ControlWeightIssueRows', () {
    ControlWeightIssueRows buildRows(List<double> weights) {
      final rows = <ControlWeightIssueRow>[];
      for (var i = 0; i < weights.length; i++) {
        rows.add(ControlWeightIssueRow.fromControl(_control(id: 'c$i', weight: weights[i])));
      }
      return ControlWeightIssueRows(rows);
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
      expect(changed.first.controlId, 'c0');
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

Run: `flutter test test/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row_test.dart`
Expected: FAIL — the target file doesn't exist yet (import error).

- [ ] **Step 3: Implement `ControlWeightIssueRow` and `ControlWeightIssueRows`**

```dart
/// Module: Policy Management
/// Description: In-memory row/table model behind the Control Weight Issue
///              page's editable table: one TextEditingController per row's
///              weight, plus the derived Total Weight the page needs.
///              Deliberately has no dependency on Firestore or use cases so
///              it can be unit tested directly (same spirit as
///              PolicyWeightIssueRow/Rows).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter, ControlEntity
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:flutter/widgets.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';

/// class name: [ControlWeightIssueRow]
///
/// purpose: one editable row of the Controls Weight table. Wraps a single
///          [ControlEntity] and a weight [TextEditingController] the UI
///          edits directly. [noOfDepartments] is read straight off the
///          entity's own `departments` list — unlike Policy (which needed
///          a separate Controls-count fetch per row), a Control already
///          carries its department count directly, no secondary fetch
///          needed.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightIssueRow {
  final String controlId;
  final String controlsNumberEn;
  final String controlsNumberAr;
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final DateTime startDate;
  final DateTime endDate;
  final int noOfDepartments;
  final double initialWeight;
  final TextEditingController weightController;

  ControlWeightIssueRow._({
    required this.controlId,
    required this.controlsNumberEn,
    required this.controlsNumberAr,
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.noOfDepartments,
    required this.initialWeight,
  }) : weightController = TextEditingController(text: _format(initialWeight));

  /// function name: [ControlWeightIssueRow.fromControl]
  ///
  /// purpose: build a row from a loaded [ControlEntity].
  ///
  /// parameters:
  ///            [ControlEntity] control: the source control
  ///
  /// return type: [ControlWeightIssueRow] - the new row
  factory ControlWeightIssueRow.fromControl(ControlEntity control) {
    return ControlWeightIssueRow._(
      controlId: control.id,
      controlsNumberEn: control.controlsNumberEn,
      controlsNumberAr: control.controlsNumberAr,
      controlsNameEn: control.controlsNameEn,
      controlsNameAr: control.controlsNameAr,
      controlsDescriptionEn: control.controlsDescriptionEn,
      controlsDescriptionAr: control.controlsDescriptionAr,
      startDate: control.startDate,
      endDate: control.endDate,
      noOfDepartments: control.departments.length,
      initialWeight: control.controlsWeight,
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
  ///          [ControlWeightIssueRows] holding this row is discarded.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    weightController.dispose();
  }
}

/// class name: [ControlWeightIssueRows]
///
/// purpose: own the full row list for the Controls Weight table and expose
///          the derived Total Weight / validity / Equal Weight / Discard /
///          changed-rows operations the cubit and page need.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightIssueRows {
  ControlWeightIssueRows(this.rows);

  final List<ControlWeightIssueRow> rows;

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
  List<ControlWeightIssueRow> get changedRows =>
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

Run: `flutter test test/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row_test.dart`
Expected: PASS (9 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart test/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row_test.dart
git commit -m "feat(grc): add ControlWeightIssueRow/Rows table math for the Control Weight Issue page"
```

---

### Task 6: `ControlWeightIssueCubit` + state + DI registration

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart`
- Create: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_state.dart`
- Modify: `lib/features/grc/grc_get_it.dart` (register the cubit)

**Interfaces:**
- Consumes: `GetAllControlsUseCase`, `UpdateControlUseCase`, `UpdateControlParams` (all existing), `ControlWeightIssueRow`/`ControlWeightIssueRows` (Task 5).
- Produces: `ControlWeightIssueCubit` with `load(String moduleId, String policyId)`, `enterEditMode()`, `discardChanges()`, `applyEqualWeight()`, `revalidate()`, `applyChanges(String moduleId, String policyId)`, `rowsData` getter, `hasRows` getter. States: `ControlWeightIssueInitial`, `ControlWeightIssueLoading`, `ControlWeightIssueLoaded({required bool isEditing})`, `ControlWeightIssueApplySuccess`, `ControlWeightIssueFailure(String message)`.

- [ ] **Step 1: Create the state file**

```dart
part of 'control_weight_issue_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_weight_issue_state.dart
/// Purpose: Contains all sealed state classes emitted by
///          [ControlWeightIssueCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 20/7/2026

sealed class ControlWeightIssueState {}

/// State emitted before the page has requested anything.
final class ControlWeightIssueInitial extends ControlWeightIssueState {}

/// State emitted while Controls are being fetched.
final class ControlWeightIssueLoading extends ControlWeightIssueState {}

/// State emitted once the row data is ready. [isEditing] drives whether
/// the Controls Weight tab renders view mode or edit mode.
final class ControlWeightIssueLoaded extends ControlWeightIssueState {
  final bool isEditing;

  ControlWeightIssueLoaded({required this.isEditing});
}

/// State emitted once after Apply Changes completes successfully, before
/// the cubit reloads and emits a fresh [ControlWeightIssueLoaded]. The page
/// listens for this to show a one-time success snackbar.
final class ControlWeightIssueApplySuccess extends ControlWeightIssueState {}

/// State emitted when any operation fails.
final class ControlWeightIssueFailure extends ControlWeightIssueState {
  final String message;

  ControlWeightIssueFailure(this.message);
}
```

- [ ] **Step 2: Create the cubit**

```dart
/// Module: Policy Management
/// Description: BLoC Cubit that manages the Control Weight Issue page's
///              state: loading the Controls under one Policy, editing
///              their weights (Equal Weight or by hand), and applying the
///              changed rows back through UpdateControlUseCase.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, GetAllControlsUseCase, UpdateControlUseCase,
///               ControlWeightIssueRow/Rows
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'control_weight_issue_state.dart';

/// class name: [ControlWeightIssueCubit]
///
/// purpose: manage all state for the Control Weight Issue page: fetching
///          the Controls under one Policy (no status filter — every
///          Control counts toward this Policy's total, matching the
///          existing `_hasControlWeightIssue` check this page's entry
///          button uses), editing their weights in memory, and persisting
///          the changed rows via [UpdateControlUseCase] on Apply Changes.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightIssueCubit extends Cubit<ControlWeightIssueState> {
  ControlWeightIssueCubit({
    required GetAllControlsUseCase getAllControlsUseCase,
    required UpdateControlUseCase updateControlUseCase,
  })  : _getAllControlsUseCase = getAllControlsUseCase,
        _updateControlUseCase = updateControlUseCase,
        super(ControlWeightIssueInitial());

  final GetAllControlsUseCase _getAllControlsUseCase;
  final UpdateControlUseCase _updateControlUseCase;

  ControlWeightIssueRows? _rowsData;

  /// The current row/table data. Only valid once a
  /// [ControlWeightIssueLoaded] state has been emitted at least once.
  ControlWeightIssueRows get rowsData => _rowsData!;

  /// Whether [load] has ever completed successfully — false only before
  /// the very first load, or if that first load failed. Lets the page
  /// tell "failed before there was any data to show" apart from "failed
  /// midway through an edit session, but the table is still there."
  bool get hasRows => _rowsData != null;

  /// Resolves the currently logged-in user's email (same pattern as
  /// PolicyCubit._currentUserEmail / PolicyWeightIssueCubit._currentUserEmail).
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
  /// purpose: fetch every Control under [moduleId]/[policyId] and build
  ///          fresh row data. Disposes any previously held row data first.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<void>]
  Future<void> load(String moduleId, String policyId) async {
    emit(ControlWeightIssueLoading());

    final result = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    final controls = result.fold((failure) {
      emit(ControlWeightIssueFailure(failure.message));
      return null;
    }, (controls) => controls);
    if (controls == null) return;

    _rowsData?.dispose();
    _rowsData = ControlWeightIssueRows(
      controls.map(ControlWeightIssueRow.fromControl).toList(),
    );
    emit(ControlWeightIssueLoaded(isEditing: false));
  }

  /// function name: [enterEditMode]
  ///
  /// purpose: switch the Controls Weight tab into edit mode (the "Edit"
  ///          button).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void enterEditMode() {
    emit(ControlWeightIssueLoaded(isEditing: true));
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
    emit(ControlWeightIssueLoaded(isEditing: false));
  }

  /// function name: [applyEqualWeight]
  ///
  /// purpose: fill every row with an equal share of 100 (the "Equal
  ///          Weight" button). Stays in edit mode so the user can still
  ///          hand-edit afterward.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void applyEqualWeight() {
    rowsData.applyEqualWeight();
    emit(ControlWeightIssueLoaded(isEditing: true));
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
    emit(ControlWeightIssueLoaded(isEditing: true));
  }

  /// function name: [applyChanges]
  ///
  /// purpose: persist every row whose weight actually changed via
  ///          [UpdateControlUseCase], one call per changed row. No-op if
  ///          the live total isn't exactly 100. On full success, reloads
  ///          fresh data and returns to view mode; on any failure, emits
  ///          Failure for the listener snackbar then immediately re-emits
  ///          an editing Loaded state so the table stays visible in edit
  ///          mode (rows/controllers untouched) instead of falling back to
  ///          a bare error screen.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<void>]
  Future<void> applyChanges(String moduleId, String policyId) async {
    if (!rowsData.totalWeightValid) return;

    final changed = rowsData.changedRows;
    final editorId = _currentUserEmail;

    for (final row in changed) {
      final result = await _updateControlUseCase.call(
        UpdateControlParams(
          id: row.controlId,
          moduleId: moduleId,
          policyId: policyId,
          editorId: editorId,
          controlsWeight: row.currentWeight,
        ),
      );
      final failureMessage = result.fold((failure) => failure.message, (_) => null);
      if (failureMessage != null) {
        emit(ControlWeightIssueFailure(failureMessage));
        emit(ControlWeightIssueLoaded(isEditing: true));
        return;
      }
    }

    emit(ControlWeightIssueApplySuccess());
    await load(moduleId, policyId);
  }

  @override
  Future<void> close() {
    _rowsData?.dispose();
    return super.close();
  }
}
```

- [ ] **Step 3: Register it in `grc_get_it.dart`**

Add this import at the top of `lib/features/grc/grc_get_it.dart`:

```dart
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart';
```

Insert this block right after the `PolicyWeightHistoryCubit` registration (which ends right before the `ChampionCubit` registration):

```dart

  /// class name: [ControlWeightIssueCubit]
  /// purpose: presentation-layer state manager for the Control Weight
  /// Issue page's editable table. Registered as a factory so each page
  /// gets an independent cubit instance.
  sl.registerFactory<ControlWeightIssueCubit>(
    () => ControlWeightIssueCubit(
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
    ),
  );
```

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart lib/features/grc/grc_get_it.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_state.dart lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): add ControlWeightIssueCubit and register it"
```

---

### Task 7: `ControlWeightHistoryCubit` + state + DI registration

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart`
- Create: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_state.dart`
- Modify: `lib/features/grc/grc_get_it.dart` (register the cubit)

**Interfaces:**
- Consumes: `GetControlWeightHistoryUseCase` (Task 3), `GetAllControlsUseCase` (existing), `ControlWeightHistoryEntry` (Task 1).
- Produces: `ControlWeightHistoryCubit.loadHistory(String moduleId, String policyId)`. States: `ControlWeightHistoryInitial`, `ControlWeightHistoryLoading`, `ControlWeightHistoryLoaded(List<ControlWeightHistoryEntry> entries, Map<String, int> departmentCounts)`, `ControlWeightHistoryFailure(String message)`. `departmentCounts` maps `controlId -> current departments.length`, resolved from **one** `GetAllControlsUseCase` call for `(moduleId, policyId)` — unlike `PolicyWeightHistoryCubit` (which needed a call per distinct policyId since Policy History spans many policies), every entry here shares the same moduleId/policyId, so one call covers them all.

- [ ] **Step 1: Create the state file**

```dart
part of 'control_weight_history_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_weight_history_state.dart
/// Purpose: Contains all sealed state classes emitted by
///          [ControlWeightHistoryCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 20/7/2026

sealed class ControlWeightHistoryState {}

final class ControlWeightHistoryInitial extends ControlWeightHistoryState {}

final class ControlWeightHistoryLoading extends ControlWeightHistoryState {}

/// [departmentCounts] maps controlId -> current department count.
final class ControlWeightHistoryLoaded extends ControlWeightHistoryState {
  final List<ControlWeightHistoryEntry> entries;
  final Map<String, int> departmentCounts;

  ControlWeightHistoryLoaded(this.entries, this.departmentCounts);
}

final class ControlWeightHistoryFailure extends ControlWeightHistoryState {
  final String message;

  ControlWeightHistoryFailure(this.message);
}
```

- [ ] **Step 2: Create the cubit**

```dart
/// Module: Policy Management
/// Description: BLoC Cubit that manages the Control Weight Issue page's
///              History tab: loads every recorded weight change for one
///              Policy's Controls and each affected control's current
///              department count.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, GetControlWeightHistoryUseCase, GetAllControlsUseCase
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:demo_app/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_weight_history_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'control_weight_history_state.dart';

/// class name: [ControlWeightHistoryCubit]
///
/// purpose: load and expose the Control weight-change history for one
///          Policy, plus each affected control's current department count.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightHistoryCubit extends Cubit<ControlWeightHistoryState> {
  ControlWeightHistoryCubit({
    required GetControlWeightHistoryUseCase getControlWeightHistoryUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _getControlWeightHistoryUseCase = getControlWeightHistoryUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        super(ControlWeightHistoryInitial());

  final GetControlWeightHistoryUseCase _getControlWeightHistoryUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;

  /// function name: [loadHistory]
  ///
  /// purpose: fetch [moduleId]/[policyId]'s full weight-change history,
  ///          then resolve the current department count for every Control
  ///          under that same policy in one call (all history entries
  ///          share this moduleId/policyId).
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<void>]
  Future<void> loadHistory(String moduleId, String policyId) async {
    emit(ControlWeightHistoryLoading());

    final result = await _getControlWeightHistoryUseCase.execute(moduleId, policyId);
    final entries = result.fold((failure) {
      emit(ControlWeightHistoryFailure(failure.message));
      return null;
    }, (entries) => entries);
    if (entries == null) return;

    final controlsResult = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    final departmentCounts = controlsResult.fold(
      (_) => <String, int>{},
      (controls) => {for (final c in controls) c.id: c.departments.length},
    );

    emit(ControlWeightHistoryLoaded(entries, departmentCounts));
  }
}
```

- [ ] **Step 3: Register it in `grc_get_it.dart`**

Add this import at the top of `lib/features/grc/grc_get_it.dart`:

```dart
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart';
```

Insert this block right after the `ControlWeightIssueCubit` registration from Task 6, before the `ChampionCubit` registration:

```dart

  /// class name: [ControlWeightHistoryCubit]
  /// purpose: presentation-layer state manager for the Control Weight
  /// Issue page's History tab. Registered as a factory so each page gets
  /// an independent cubit instance.
  sl.registerFactory<ControlWeightHistoryCubit>(
    () => ControlWeightHistoryCubit(
      getControlWeightHistoryUseCase: sl<GetControlWeightHistoryUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );
```

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart lib/features/grc/grc_get_it.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_state.dart lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): add ControlWeightHistoryCubit and register it"
```

---

### Task 8: `ControlWeightHistoryTab` widget

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_tab.dart`

**Interfaces:**
- Consumes: `ControlWeightHistoryCubit` (Task 7, provided by the parent page — see Task 9), `EmployeeHelper.getEmployeeLocalizedNameWithEmail`/`getEmployeeImageWithEmail` (existing), `AppColors`/`StyleText` (existing theme).
- Produces: `ControlWeightHistoryTab` — a `StatelessWidget` that reads the already-provided `ControlWeightHistoryCubit` via `context.read` and renders its state. Does not create its own `BlocProvider`.

- [ ] **Step 1: Implement the widget**

```dart
/// Module: Policy Management
/// Description: The Control Weight Issue page's History tab: a table of
///              every recorded weight change across one Policy's Controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, ControlWeightHistoryCubit, EmployeeHelper, intl
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

/// class name: [ControlWeightHistoryTab]
///
/// purpose: render the History tab of the Control Weight Issue page,
///          reading an already-provided [ControlWeightHistoryCubit] (the
///          parent page owns the [BlocProvider]).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightHistoryTab extends StatelessWidget {
  const ControlWeightHistoryTab({super.key});

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
    return BlocBuilder<ControlWeightHistoryCubit, ControlWeightHistoryState>(
      builder: (context, state) {
        if (state is ControlWeightHistoryLoading || state is ControlWeightHistoryInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state is ControlWeightHistoryFailure) {
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

        final loaded = state as ControlWeightHistoryLoaded;
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
                  3: FlexColumnWidth(1.4),
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
                      noOfDepartments: loaded.departmentCounts[loaded.entries[i].controlId] ?? 0,
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
      'Control Name',
      'No of Departments',
      'Control Weight Current',
      'Control Weight Previous',
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
    required ControlWeightHistoryEntry entry,
    required int noOfDepartments,
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
        _cell(Text(context.isArabic ? entry.controlsNameAr : entry.controlsNameEn,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
        _cell(Text('$noOfDepartments', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
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

Run: `flutter analyze lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_tab.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_tab.dart
git commit -m "feat(grc): add ControlWeightHistoryTab widget"
```

---

### Task 9: `ControlWeightIssuePage` — tabs, breadcrumb, Controls Weight (view + edit mode)

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart`

**Interfaces:**
- Consumes: `ControlWeightIssueCubit` (Task 6), `ControlWeightHistoryCubit` (Task 7), `ControlWeightHistoryTab` (Task 8), `GRCModuleEntity`/`PolicyEntity` (existing), `customButton` (existing), `PaginationAppBar` (existing).
- Produces: `ControlWeightIssuePage({required GRCModuleEntity module, required PolicyEntity policy})` — the page pushed from `PolicyViewModeWidget`'s banner (wired in Task 10).

- [ ] **Step 1: Implement the page**

```dart
/// Module: Policy Management
/// Description: Page opened from PolicyViewModeWidget's "Control Weight
///              Issue" banner. Two tabs: "Controls Weight" (an editable
///              table of the Controls under this Policy, with Equal Weight
///              / manual editing) and "History" (every recorded weight
///              change).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, get_it, ControlWeightIssueCubit,
///               ControlWeightHistoryCubit, ControlWeightHistoryTab
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_tab.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// class name: [ControlWeightIssuePage]
///
/// purpose: host the Controls Weight / History tabs for one Policy's
///          Controls, provisioning its own [ControlWeightIssueCubit] and
///          [ControlWeightHistoryCubit] (same pattern as
///          `PolicyWeightIssuePage`).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightIssuePage extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;

  const ControlWeightIssuePage({
    super.key,
    required this.module,
    required this.policy,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ControlWeightIssueCubit>(
          create: (_) => GetIt.instance<ControlWeightIssueCubit>()
            ..load(module.moduleId, policy.id),
        ),
        BlocProvider<ControlWeightHistoryCubit>(
          create: (_) => GetIt.instance<ControlWeightHistoryCubit>()
            ..loadHistory(module.moduleId, policy.id),
        ),
      ],
      child: _ControlWeightIssueBody(module: module, policy: policy),
    );
  }
}

class _ControlWeightIssueBody extends StatefulWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;

  const _ControlWeightIssueBody({required this.module, required this.policy});

  @override
  State<_ControlWeightIssueBody> createState() => _ControlWeightIssueBodyState();
}

class _ControlWeightIssueBodyState extends State<_ControlWeightIssueBody> {
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
                  context.isArabic ? widget.policy.policyNameAr : widget.policy.policyNameEn,
                  'Control Weight Issue'.tr,
                ],
              ),
              SizedBox(height: 15.h),
              _buildTabs(),
              SizedBox(height: 15.h),
              Expanded(
                child: _selectedTab == 0
                    ? _buildControlsWeightTab(context)
                    : const ControlWeightHistoryTab(),
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
        _tabItem('Controls Weight', 0),
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

  Widget _buildControlsWeightTab(BuildContext context) {
    return BlocConsumer<ControlWeightIssueCubit, ControlWeightIssueState>(
      listener: (context, state) {
        if (state is ControlWeightIssueApplySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You Have Successfully Edited Controls Weights'.tr)),
          );
        }
        if (state is ControlWeightIssueFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is ControlWeightIssueLoading || state is ControlWeightIssueInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final cubit = context.read<ControlWeightIssueCubit>();

        // A failure on the very first load means `_rowsData` was never set
        // (cubit.rowsData would throw) — show the error instead of the
        // table. A failure from Apply Changes never reaches here because
        // applyChanges() only emits Failure before touching `_rowsData`.
        if (state is ControlWeightIssueFailure && !cubit.hasRows) {
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

        final isEditing = state is ControlWeightIssueLoaded && state.isEditing;
        final rowsData = cubit.rowsData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (isEditing)
                  customButton(
                    title: 'Equal Control Weight'.tr,
                    function: cubit.applyEqualWeight,
                    width: 170.w,
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
                        ? () => cubit.applyChanges(widget.module.moduleId, widget.policy.id)
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

  static const List<double> _columnWidths = [40, 110, 150, 200, 110, 130, 110, 110];
  static const List<String> _headers = [
    'NO', 'Control Number', 'Control Name', 'Control Description',
    'Control Weight', 'No of Departments', 'Start Date', 'End Date',
  ];

  Widget _buildTable(
    BuildContext context,
    ControlWeightIssueRows rowsData,
    bool isEditing,
    ControlWeightIssueCubit cubit,
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
    ControlWeightIssueRow row,
    int index,
    bool isEditing,
    ControlWeightIssueCubit cubit,
    DateFormat dateFormat,
  ) {
    final isArabic = context.isArabic;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cell(0, Text('${index + 1}', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
          _cell(1, Text(isArabic ? row.controlsNumberAr : row.controlsNumberEn, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
          _cell(2, Text(isArabic ? row.controlsNameAr : row.controlsNameEn, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
          _cell(3, Text(isArabic ? row.controlsDescriptionAr : row.controlsDescriptionEn, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
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
          _cell(5, Text('${row.noOfDepartments}', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
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

  Widget _buildTotalWeight(ControlWeightIssueRows rowsData) {
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

Run: `flutter analyze lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart
git commit -m "feat(grc): add ControlWeightIssuePage with Controls Weight + History tabs"
```

---

### Task 10: Wire the banner on `PolicyViewModeWidget`

**Files:**
- Modify: `lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart:368-378`

**Interfaces:**
- Consumes: `ControlWeightIssuePage` (Task 9).

- [ ] **Step 1: Add the import**

At the top of `lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart`, add (alongside the other GRC control imports, e.g. right after the `control_status.dart` import):

```dart
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart';
```

- [ ] **Step 2: Wire the banner's `function`**

Replace this method (`policy_view_mode_widget.dart:368-378`):

```dart
  Widget _buildWeightIssueBanner(List<ControlEntity> controls) {
    if (!_hasControlWeightIssue(controls)) return const SizedBox.shrink();
    return customButton(
      title: 'Control Weight Issue'.tr,
      function: () {},
      height: 38.h,
      color: AppColors.primary,
      textStyle:
          StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
    );
  }
```

with:

```dart
  Widget _buildWeightIssueBanner(List<ControlEntity> controls) {
    if (!_hasControlWeightIssue(controls)) return const SizedBox.shrink();
    return customButton(
      title: 'Control Weight Issue'.tr,
      function: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ControlWeightIssuePage(
            module: widget.module,
            policy: widget.policy,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      height: 38.h,
      color: AppColors.primary,
      textStyle:
          StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
    );
  }
```

(`context`, `widget.module`, and `widget.policy` are all already available inside `_PolicyViewModeWidgetState` — this matches the exact `PageRouteBuilder` + fade-transition convention already used by `_showPolicyCreationMenu` in `grc_module_details_page.dart` and by the Policy Weight Issue button wiring.)

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart`
Expected: No new errors (this file may have pre-existing unrelated warnings — only care that your edit doesn't add new ones).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart
git commit -m "feat(grc): wire the Control Weight Issue banner to open the new page"
```

---

### Task 11: Full-project analyze + manual verification

**Files:** none (verification only)

- [ ] **Step 1: Run the full analyzer**

Run: `flutter analyze`
Expected: No new errors introduced by this feature (pre-existing warnings elsewhere in the repo are out of scope).

- [ ] **Step 2: Run every unit test added in this plan**

Run: `flutter test test/features/grc/control/`
Expected: All tests from Tasks 1 and 5 PASS.

- [ ] **Step 3: Manual run-through**

Run the app (`flutter run`), open a Policy whose Controls don't sum to exactly 100 (or temporarily edit one Control's weight via the existing Edit Control flow to create that condition), on the Policy Details page:

1. Confirm the "Control Weight Issue" banner is visible (shown whenever the Controls' total != 100, regardless of status) and tapping it opens the new page with breadcrumb `GRC > {Module Name} > {Policy Name} > Control Weight Issue`.
2. On the "Controls Weight" tab (view mode): confirm the table lists every Control under this Policy (no status filter), the Total Weight box is red with "Total Weight Should be 100" shown, and there's an "Edit" button.
3. Tap "Edit": confirm the Control Weight column becomes editable and an "Equal Control Weight" button appears.
4. Tap "Equal Control Weight": confirm every row now shows `100 / n` and the Total Weight box turns green with "Apply Changes" enabled.
5. Hand-edit one cell so the sum is no longer 100: confirm the Total Weight box turns red again and "Apply Changes" is disabled/grey.
6. Fix the cell back to a sum of exactly 100 and tap "Apply Changes": confirm a success snackbar appears, the page stays on the Controls Weight tab in view mode with the new values, and re-opening the Policy Details page no longer shows the "Control Weight Issue" banner.
7. Switch to the "History" tab: confirm it lists only the Control row(s) whose weight actually changed in step 6, with the correct Changed By (your logged-in user), Control Weight Current/Previous, and today's date — and that Controls whose weight didn't change in that Apply do not appear.

- [ ] **Step 4: Report results**

If any manual-verification step fails, note exactly which step and what was observed instead before moving on — do not mark this task done until all 7 checks pass.
