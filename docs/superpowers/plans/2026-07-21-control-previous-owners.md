# Previous Control Owners Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire up `ControlDetailsPage`'s placeholder "Previous Control Owners" button to a new page showing every completed Control Owner assignment stint (owner, who assigned them, start/end date) for that Control — mirroring the existing GRC Module Previous Owners feature one level down the hierarchy.

**Architecture:** Flutter + flutter_bloc + Clean Architecture layers, exactly mirroring the already-shipped `GrcPreviousOwnersCubit`/`GrcPreviousModuleOwnersPage`/`GetGRCModuleOwnerHistoryUseCase`/`GRCModuleModel.toOwnerHistory()` stack. `OwnerModel` already stores `assigningControls`/`modificationDate`/`modifiers` as parallel per-revision lists (same shape as `GRCModuleModel`'s `moduleOwners`/`modificationDate`/`modifiers`), so the history is derived the same way: diff consecutive revisions, no new Firestore fields or collections.

**Tech Stack:** Flutter, flutter_bloc, dartz (Either), get_it, flutter_screenutil, intl, flutter_test.

## Global Constraints

- Where a task's logic is plain Dart with no Firebase/BuildContext dependency (the `OwnerModel` diffing algorithm), write a real unit test using `flutter_test`, following TDD (write failing test, verify it fails, implement, verify it passes). Everywhere else, verify with `dart analyze` (no Flutter binary in this sandbox — confirmed `flutter`/`flutter test`/`dart test` cannot run here at all, since `flutter_test` resolves from `sdk: flutter` which isn't installed; a real Flutter environment can run the `flutter test` commands given in Task 1).
- Text-only history table, no avatar images — confirmed against the existing Module Previous Owners page's own convention, even though an earlier mockup showed avatars.
- Include removed Control Owners when deriving history (`includeRemoved: true`) — a Control Owner who has since been fully removed from the Module can still have real historical stints on this Control.
- Currently-active assignments never produce an entry — only completed (later-removed) stints show, matching the Module convention exactly.
- Follow existing patterns exactly: `PageRouteBuilder` + `FadeTransition` (300ms) for navigation, `context.isArabic` for localization, `.tr` on every user-facing string, `sl.registerLazySingleton`/`sl.registerFactory` in `grc_get_it.dart` matching neighboring registrations' style.
- Do not modify `GRCModuleModel.toOwnerHistory()`, `OwnerCubit`, or `ControlDetailsPage`'s own "Control Owner" badge (`GrcOwnerBadge`) — this plan only adds the history feature and wires the one button.
- Commit after each task with `git add <files>` + a descriptive message (no `--no-verify`).

---

### Task 1: `ControlOwnerHistoryEntry` entity + `OwnerModel.toControlAssignmentHistory()` (unit tested)

**Files:**
- Create: `lib/features/grc/control_owner/domain/entities/control_owner_history_entry.dart`
- Modify: `lib/features/grc/control_owner/data/models/owner_model.dart`
- Test: `test/features/grc/control_owner/data/models/owner_model_control_history_test.dart`

**Interfaces:**
- Produces: `ControlOwnerHistoryEntry({required String ownerEmail, required String assignedByEmail, required DateTime startDate, required DateTime endDate})`; `OwnerModel.toControlAssignmentHistory({required String policyId, required String controlId}) -> List<ControlOwnerHistoryEntry>` — Task 2 calls this on every `OwnerModel` fetched for a Module and flat-maps the results.
- Consumes: `AssigningControlModel` (existing, `policyId`/`controlId` fields, `lib/features/grc/control/data/models/assigning_control_model.dart`).

- [ ] **Step 1: Create the entity**

Create `lib/features/grc/control_owner/domain/entities/control_owner_history_entry.dart`:

```dart
/// Module: Control Owner Management
/// Description: One completed Control Owner assignment stint on a single
///              {Policy, Control} pair — who held the role, who assigned
///              them, and the date range they held it. Reconstructed from
///              OwnerModel's revision history; never persisted on its own.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: None
/// Revision History: 2026-07-21 - Initial creation
library;

/// class name: [ControlOwnerHistoryEntry]
///
/// purpose: represents a single completed stint of one person being the
///          Owner of a specific Control: they were assigned on [startDate]
///          (by [assignedByEmail]) and stopped being the Owner of that
///          Control on [endDate]. Only ever produced for assignments that
///          have since ended — a currently-active assignment has no
///          [ControlOwnerHistoryEntry].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class ControlOwnerHistoryEntry {
  final String ownerEmail;
  final String assignedByEmail;
  final DateTime startDate;
  final DateTime endDate;

  const ControlOwnerHistoryEntry({
    required this.ownerEmail,
    required this.assignedByEmail,
    required this.startDate,
    required this.endDate,
  });
}
```

- [ ] **Step 2: Write the failing test for `toControlAssignmentHistory()`**

Create `test/features/grc/control_owner/data/models/owner_model_control_history_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/control/data/models/assigning_control_model.dart';
import 'package:demo_app/features/grc/control_owner/data/models/owner_model.dart';

void main() {
  const policyId = 'policy-1';
  const controlId = 'control-1';
  const otherControlId = 'control-2';

  OwnerModel buildOwner({
    required List<List<AssigningControlModel>> assigningControls,
    required List<DateTime> modificationDate,
    required List<String> modifiers,
  }) {
    return OwnerModel(
      ownerEmail: 'owner@example.com',
      assigningControls: assigningControls,
      status: List<String>.filled(assigningControls.length, 'Active'),
      controlOwnerPermissions: List<List<String>>.generate(
        assigningControls.last.length,
        (_) => <String>[],
      ),
      modificationDate: modificationDate,
      modifiers: modifiers,
    );
  }

  group('OwnerModel.toControlAssignmentHistory', () {
    test('never assigned to this control returns an empty list', () {
      final owner = buildOwner(
        assigningControls: [
          [
            const AssigningControlModel(
                policyId: policyId, controlId: otherControlId),
          ],
        ],
        modificationDate: [DateTime(2026, 1, 1)],
        modifiers: ['creator@example.com'],
      );

      expect(
        owner.toControlAssignmentHistory(
            policyId: policyId, controlId: controlId),
        isEmpty,
      );
    });

    test('assigned once then removed returns one entry with correct fields',
        () {
      final owner = buildOwner(
        assigningControls: [
          [
            const AssigningControlModel(
                policyId: policyId, controlId: controlId),
          ],
          <AssigningControlModel>[],
        ],
        modificationDate: [DateTime(2026, 1, 1), DateTime(2026, 2, 1)],
        modifiers: ['creator@example.com', 'remover@example.com'],
      );

      final history = owner.toControlAssignmentHistory(
          policyId: policyId, controlId: controlId);

      expect(history, hasLength(1));
      expect(history.first.ownerEmail, 'owner@example.com');
      expect(history.first.assignedByEmail, 'creator@example.com');
      expect(history.first.startDate, DateTime(2026, 1, 1));
      expect(history.first.endDate, DateTime(2026, 2, 1));
    });

    test(
        'assigned, removed, reassigned, removed again returns two entries',
        () {
      final owner = buildOwner(
        assigningControls: [
          <AssigningControlModel>[],
          [
            const AssigningControlModel(
                policyId: policyId, controlId: controlId),
          ],
          <AssigningControlModel>[],
          [
            const AssigningControlModel(
                policyId: policyId, controlId: controlId),
          ],
          <AssigningControlModel>[],
        ],
        modificationDate: [
          DateTime(2026, 1, 1),
          DateTime(2026, 2, 1),
          DateTime(2026, 3, 1),
          DateTime(2026, 4, 1),
          DateTime(2026, 5, 1),
        ],
        modifiers: [
          'creator@example.com',
          'assigner1@example.com',
          'remover1@example.com',
          'assigner2@example.com',
          'remover2@example.com',
        ],
      );

      final history = owner.toControlAssignmentHistory(
          policyId: policyId, controlId: controlId);

      expect(history, hasLength(2));
      expect(history[0].assignedByEmail, 'assigner1@example.com');
      expect(history[0].startDate, DateTime(2026, 2, 1));
      expect(history[0].endDate, DateTime(2026, 3, 1));
      expect(history[1].assignedByEmail, 'assigner2@example.com');
      expect(history[1].startDate, DateTime(2026, 4, 1));
      expect(history[1].endDate, DateTime(2026, 5, 1));
    });

    test('still currently assigned (never removed) produces no entry', () {
      final owner = buildOwner(
        assigningControls: [
          [
            const AssigningControlModel(
                policyId: policyId, controlId: controlId),
          ],
        ],
        modificationDate: [DateTime(2026, 1, 1)],
        modifiers: ['creator@example.com'],
      );

      expect(
        owner.toControlAssignmentHistory(
            policyId: policyId, controlId: controlId),
        isEmpty,
      );
    });

    test('an unrelated control change on the same owner produces no entry',
        () {
      final owner = buildOwner(
        assigningControls: [
          [
            const AssigningControlModel(
                policyId: policyId, controlId: controlId),
          ],
          [
            const AssigningControlModel(
                policyId: policyId, controlId: controlId),
            const AssigningControlModel(
                policyId: policyId, controlId: otherControlId),
          ],
        ],
        modificationDate: [DateTime(2026, 1, 1), DateTime(2026, 2, 1)],
        modifiers: ['creator@example.com', 'adder@example.com'],
      );

      expect(
        owner.toControlAssignmentHistory(
            policyId: policyId, controlId: controlId),
        isEmpty,
      );
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/features/grc/control_owner/data/models/owner_model_control_history_test.dart`
Expected: FAIL — `toControlAssignmentHistory` isn't defined on `OwnerModel` yet. (In this sandbox, `flutter test` cannot run at all — no Flutter SDK installed. Skip straight to Step 4 and rely on `dart analyze` in Step 5; run this step for real in a Flutter environment.)

- [ ] **Step 4: Implement `toControlAssignmentHistory()`**

In `lib/features/grc/control_owner/data/models/owner_model.dart`, add this import alongside the existing ones:

```dart
import 'package:demo_app/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
```

Add this private helper class right before `class OwnerModel {`:

```dart
class _OpenControlStint {
  final DateTime startDate;
  final String assignedByEmail;

  _OpenControlStint({required this.startDate, required this.assignedByEmail});
}

```

Add this method inside `OwnerModel`, right after `toEntity()`'s closing brace (i.e. as the new last method in the class, before the final `}`):

```dart

  /// function name: [toControlAssignmentHistory]
  ///
  /// purpose: reconstruct every completed assignment stint this owner held
  ///          on one specific {policyId, controlId} pair, by diffing
  ///          [assigningControls] between consecutive revisions. The pair
  ///          appearing in revision N but not N-1 opens a stint (assigned
  ///          by [modifiers] at N); it disappearing between N-1 and N
  ///          closes the currently open stint (ends at [modificationDate]
  ///          at N) and emits one [ControlOwnerHistoryEntry]. A pair that
  ///          is still currently assigned (never removed) produces no
  ///          entry for that open stint.
  ///
  /// parameters:
  ///            [String] policyId: the Policy id half of the pair to track
  ///            [String] controlId: the Control id half of the pair to track
  ///
  /// return type: [List<ControlOwnerHistoryEntry>] - this owner's completed stints on this Control
  List<ControlOwnerHistoryEntry> toControlAssignmentHistory({
    required String policyId,
    required String controlId,
  }) {
    bool hasControl(List<AssigningControlModel> revision) => revision
        .any((a) => a.policyId == policyId && a.controlId == controlId);

    _OpenControlStint? open;
    if (hasControl(assigningControls.first)) {
      open = _OpenControlStint(
        startDate: modificationDate.first,
        assignedByEmail: modifiers.first,
      );
    }

    final entries = <ControlOwnerHistoryEntry>[];
    for (var i = 1; i < assigningControls.length; i++) {
      final wasAssigned = hasControl(assigningControls[i - 1]);
      final isAssigned = hasControl(assigningControls[i]);

      if (isAssigned && !wasAssigned) {
        open = _OpenControlStint(
          startDate: modificationDate[i],
          assignedByEmail: modifiers[i],
        );
      }

      if (!isAssigned && wasAssigned && open != null) {
        entries.add(ControlOwnerHistoryEntry(
          ownerEmail: ownerEmail,
          assignedByEmail: open.assignedByEmail,
          startDate: open.startDate,
          endDate: modificationDate[i],
        ));
        open = null;
      }
    }

    return entries;
  }
```

- [ ] **Step 5: Verify**

Run: `dart analyze lib/features/grc/control_owner/data/models/owner_model.dart lib/features/grc/control_owner/domain/entities/control_owner_history_entry.dart test/features/grc/control_owner/data/models/owner_model_control_history_test.dart`
Expected: no errors. (Run `flutter test test/features/grc/control_owner/data/models/owner_model_control_history_test.dart` for real in a Flutter environment — expect PASS, 5 tests.)

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/control_owner/domain/entities/control_owner_history_entry.dart lib/features/grc/control_owner/data/models/owner_model.dart test/features/grc/control_owner/data/models/owner_model_control_history_test.dart
git commit -m "feat(grc): add ControlOwnerHistoryEntry + OwnerModel.toControlAssignmentHistory"
```

---

### Task 2: Repository method + `GetControlOwnerHistoryUseCase`

**Files:**
- Modify: `lib/features/grc/control_owner/domain/repository/owner_repository.dart`
- Modify: `lib/features/grc/control_owner/data/repository/owner_repository_impl.dart`
- Create: `lib/features/grc/control_owner/domain/use_cases/get_control_owner_history_use_case.dart`

**Interfaces:**
- Consumes: `OwnerModel.toControlAssignmentHistory({required policyId, required controlId})` (Task 1); `OwnerFirebaseDataSource.getAll({required moduleId, bool includeRemoved})` (existing, returns `List<OwnerModel>`).
- Produces: `OwnerRepository.getControlOwnerHistory({required String moduleId, required String policyId, required String controlId}) -> Future<Either<Failure, List<ControlOwnerHistoryEntry>>>`; `GetControlOwnerHistoryUseCase.execute({required moduleId, required policyId, required controlId})` — Task 3's cubit calls this.

- [ ] **Step 1: Add the abstract method to `OwnerRepository`**

In `lib/features/grc/control_owner/domain/repository/owner_repository.dart`, add this import:

```dart
import 'package:demo_app/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
```

Then replace the closing of the abstract class:

```dart
  Future<Either<Failure, OwnerEntity>> updateOwner({
    required String ownerEmail,
    required String moduleId,
    required String editorId,
    List<AssigningControlEntity>? assigningControls,
    List<List<String>>? controlOwnerPermissions,
    OwnerStatus? status,
  });
}
```

with:

```dart
  Future<Either<Failure, OwnerEntity>> updateOwner({
    required String ownerEmail,
    required String moduleId,
    required String editorId,
    List<AssigningControlEntity>? assigningControls,
    List<List<String>>? controlOwnerPermissions,
    OwnerStatus? status,
  });

  Future<Either<Failure, List<ControlOwnerHistoryEntry>>> getControlOwnerHistory({
    required String moduleId,
    required String policyId,
    required String controlId,
  });
}
```

- [ ] **Step 2: Implement it in `OwnerRepositoryImpl`**

In `lib/features/grc/control_owner/data/repository/owner_repository_impl.dart`, add this import:

```dart
import 'package:demo_app/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
```

Then replace the closing of the class:

```dart
      final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
```

with:

```dart
      final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [getControlOwnerHistory]
  ///
  /// purpose: fetch every Control Owner ever recorded for [moduleId]
  ///          (including removed ones — their past stints on this Control
  ///          are still real history), and flat-map each one's completed
  ///          assignment stints on the {policyId, controlId} pair via
  ///          [OwnerModel.toControlAssignmentHistory], sorted by endDate
  ///          descending.
  ///
  /// parameters: see [OwnerRepository.getControlOwnerHistory]
  ///
  /// return type: [Future<Either<Failure, List<ControlOwnerHistoryEntry>>>] - completed stints, or a Failure
  @override
  Future<Either<Failure, List<ControlOwnerHistoryEntry>>> getControlOwnerHistory({
    required String moduleId,
    required String policyId,
    required String controlId,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        includeRemoved: true,
      );
      final entries = models
          .expand((m) => m.toControlAssignmentHistory(
                policyId: policyId,
                controlId: controlId,
              ))
          .toList();
      entries.sort((a, b) => b.endDate.compareTo(a.endDate));
      return Right(entries);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 3: Create the use case**

Create `lib/features/grc/control_owner/domain/use_cases/get_control_owner_history_use_case.dart`:

```dart
/// Module: Control Owner Management
/// Description: Use case responsible for fetching one Control's Owner
///              assignment history.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: dartz, OwnerRepository, ControlOwnerHistoryEntry, Failure
/// Revision History: 2026-07-21 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
import 'package:demo_app/features/grc/control_owner/domain/repository/owner_repository.dart';

/// class name: [GetControlOwnerHistoryUseCase]
///
/// purpose: encapsulate the business logic for fetching one Control's
///          Owner-assignment history. Delegates to
///          [OwnerRepository.getControlOwnerHistory] and returns the
///          result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class GetControlOwnerHistoryUseCase {
  final OwnerRepository _repository;

  GetControlOwnerHistoryUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch the Owner-assignment history for the Control matching
  ///          [policyId] + [controlId] inside Module [moduleId].
  ///
  /// parameters:
  ///            [String] moduleId: the GRC Module this Control belongs to
  ///            [String] policyId: the Policy this Control belongs to
  ///            [String] controlId: the Control to fetch history for
  ///
  /// return type: [Future<Either<Failure, List<ControlOwnerHistoryEntry>>>] - completed stints, or a Failure
  Future<Either<Failure, List<ControlOwnerHistoryEntry>>> execute({
    required String moduleId,
    required String policyId,
    required String controlId,
  }) {
    return _repository.getControlOwnerHistory(
      moduleId: moduleId,
      policyId: policyId,
      controlId: controlId,
    );
  }
}
```

- [ ] **Step 4: Verify**

Run: `dart analyze lib/features/grc/control_owner/domain/repository/owner_repository.dart lib/features/grc/control_owner/data/repository/owner_repository_impl.dart lib/features/grc/control_owner/domain/use_cases/get_control_owner_history_use_case.dart`
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control_owner/domain/repository/owner_repository.dart lib/features/grc/control_owner/data/repository/owner_repository_impl.dart lib/features/grc/control_owner/domain/use_cases/get_control_owner_history_use_case.dart
git commit -m "feat(grc): add getControlOwnerHistory repository method + use case"
```

---

### Task 3: `ControlPreviousOwnersCubit`

**Files:**
- Create: `lib/features/grc/control_owner/presentation/controller/control_previous_owners_cubit.dart`
- Create: `lib/features/grc/control_owner/presentation/controller/control_previous_owners_state.dart`

**Interfaces:**
- Consumes: `GetControlOwnerHistoryUseCase.execute({required moduleId, required policyId, required controlId})` (Task 2).
- Produces: `ControlPreviousOwnersCubit({required GetControlOwnerHistoryUseCase getOwnerHistoryUseCase})` with `loadHistory({required String moduleId, required String policyId, required String controlId})`; states `ControlPreviousOwnersInitial`/`Loading`/`Loaded(List<ControlOwnerHistoryEntry> entries)`/`Failure(String message)` — Task 4's page consumes these.

- [ ] **Step 1: Create the cubit**

Create `lib/features/grc/control_owner/presentation/controller/control_previous_owners_cubit.dart`:

```dart
/// Module: Control Owner Management
/// Description: BLoC Cubit that manages the Previous Control Owners page's
///              state. Delegates to GetControlOwnerHistoryUseCase and emits
///              typed ControlPreviousOwnersState subclasses.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter_bloc, GetControlOwnerHistoryUseCase, ControlOwnerHistoryEntry
/// Revision History: 2026-07-21 - Initial creation
library;

import 'package:demo_app/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/get_control_owner_history_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'control_previous_owners_state.dart';

/// class name: [ControlPreviousOwnersCubit]
///
/// purpose: load and expose the completed Owner-assignment history for one
///          Control.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class ControlPreviousOwnersCubit extends Cubit<ControlPreviousOwnersState> {
  ControlPreviousOwnersCubit({
    required GetControlOwnerHistoryUseCase getOwnerHistoryUseCase,
  })  : _getOwnerHistoryUseCase = getOwnerHistoryUseCase,
        super(ControlPreviousOwnersInitial());

  final GetControlOwnerHistoryUseCase _getOwnerHistoryUseCase;

  Future<void> loadHistory({
    required String moduleId,
    required String policyId,
    required String controlId,
  }) async {
    emit(ControlPreviousOwnersLoading());
    final result = await _getOwnerHistoryUseCase.execute(
      moduleId: moduleId,
      policyId: policyId,
      controlId: controlId,
    );
    result.fold(
      (failure) => emit(ControlPreviousOwnersFailure(failure.message)),
      (entries) => emit(ControlPreviousOwnersLoaded(entries)),
    );
  }
}
```

- [ ] **Step 2: Create the state file**

Create `lib/features/grc/control_owner/presentation/controller/control_previous_owners_state.dart`:

```dart
part of 'control_previous_owners_cubit.dart';

sealed class ControlPreviousOwnersState {}

final class ControlPreviousOwnersInitial extends ControlPreviousOwnersState {}

final class ControlPreviousOwnersLoading extends ControlPreviousOwnersState {}

final class ControlPreviousOwnersLoaded extends ControlPreviousOwnersState {
  final List<ControlOwnerHistoryEntry> entries;

  ControlPreviousOwnersLoaded(this.entries);
}

final class ControlPreviousOwnersFailure extends ControlPreviousOwnersState {
  final String message;

  ControlPreviousOwnersFailure(this.message);
}
```

- [ ] **Step 3: Verify**

Run: `dart analyze lib/features/grc/control_owner/presentation/controller/control_previous_owners_cubit.dart lib/features/grc/control_owner/presentation/controller/control_previous_owners_state.dart`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control_owner/presentation/controller/control_previous_owners_cubit.dart lib/features/grc/control_owner/presentation/controller/control_previous_owners_state.dart
git commit -m "feat(grc): add ControlPreviousOwnersCubit"
```

---

### Task 4: `ControlPreviousOwnersPage`

**Files:**
- Create: `lib/features/grc/control_owner/presentation/ui/pages/control_previous_owners_page.dart`

**Interfaces:**
- Consumes: `ControlPreviousOwnersCubit` (Task 3); `ControlOwnerHistoryEntry` (Task 1); `ControlEntity.id/controlsNameEn/controlsNameAr` (existing); `GRCModuleEntity.moduleId/moduleNameEn/moduleNameAr` (existing); `PolicyEntity.id/policyNameEn/policyNameAr` (existing); `EmployeeHelper.getEmployeeLocalizedNameWithEmail({required String employeeEmail})` (existing, `lib/core/helper/main_helper/employee_helper.dart:67`).
- Produces: `ControlPreviousOwnersPage({required GRCModuleEntity module, required PolicyEntity policy, required ControlEntity control})` — Task 5 pushes this from `ControlDetailsPage`.

- [ ] **Step 1: Create the page**

Create `lib/features/grc/control_owner/presentation/ui/pages/control_previous_owners_page.dart`:

```dart
/// Module: Control Owner Management
/// Description: Page that shows every completed Control Owner assignment
///              stint for one Control, including who assigned them and the
///              date range of each completed stint.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter_bloc, ControlPreviousOwnersCubit, EmployeeHelper,
///               PaginationAppBar, AppColors, AppTheme, intl
/// Revision History: 2026-07-21 - Initial creation
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/control_previous_owners_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// class name: [ControlPreviousOwnersPage]
///
/// purpose: entry-point widget for the Previous Control Owners screen.
///          Provides its own [ControlPreviousOwnersCubit] and loads history
///          for the given {module, policy, control}.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class ControlPreviousOwnersPage extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity control;

  const ControlPreviousOwnersPage({
    super.key,
    required this.module,
    required this.policy,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ControlPreviousOwnersCubit>()
        ..loadHistory(
          moduleId: module.moduleId,
          policyId: policy.id,
          controlId: control.id,
        ),
      child: _ControlPreviousOwnersBody(
        module: module,
        policy: policy,
        control: control,
      ),
    );
  }
}

class _ControlPreviousOwnersBody extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity control;

  const _ControlPreviousOwnersBody({
    required this.module,
    required this.policy,
    required this.control,
  });

  String _displayName(BuildContext context, String email) {
    try {
      return EmployeeHelper.getEmployeeLocalizedNameWithEmail(
        employeeEmail: email,
      );
    } catch (_) {
      return email;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    return BlocBuilder<ControlPreviousOwnersCubit, ControlPreviousOwnersState>(
      builder: (context, state) {
        final List<ControlOwnerHistoryEntry> entries =
            state is ControlPreviousOwnersLoaded ? state.entries : const [];

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaginationAppBar(
                      screensTitles: [
                        'GRC'.tr,
                        isArabic ? module.moduleNameAr : module.moduleNameEn,
                        isArabic ? policy.policyNameAr : policy.policyNameEn,
                        isArabic
                            ? control.controlsNameAr
                            : control.controlsNameEn,
                        'History Of Control Owners'.tr,
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildBody(context, state, entries),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ControlPreviousOwnersState state,
    List<ControlOwnerHistoryEntry> entries,
  ) {
    if (state is ControlPreviousOwnersLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state is ControlPreviousOwnersFailure) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.message,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () =>
                  context.read<ControlPreviousOwnersCubit>().loadHistory(
                        moduleId: module.moduleId,
                        policyId: policy.id,
                        controlId: control.id,
                      ),
              child: Text('Retry'.tr),
            ),
          ],
        ),
      );
    }

    if (entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            'No Previous Control Owners'.tr,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(52.w),
            1: FlexColumnWidth(2.4),
            2: FlexColumnWidth(2.4),
            3: FlexColumnWidth(1.4),
            4: FlexColumnWidth(1.4),
          },
          children: [
            _buildHeaderRow(),
            for (var i = 0; i < entries.length; i++)
              _buildDataRow(
                context: context,
                entry: entries[i],
                index: i,
                dateFormat: dateFormat,
              ),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    final headers = [
      'NO',
      'Control Owner',
      'Assigned By',
      'Start Date',
      'End Date',
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

  TableRow _buildDataRow({
    required BuildContext context,
    required ControlOwnerHistoryEntry entry,
    required int index,
    required DateFormat dateFormat,
  }) {
    final isEven = index % 2 == 0;
    return TableRow(
      decoration: BoxDecoration(
        color: isEven ? AppColors.background : AppColors.field,
      ),
      children: [
        _cell(
          Text(
            '${index + 1}',
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
        _cell(
          Text(
            _displayName(context, entry.ownerEmail),
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _cell(
          Text(
            _displayName(context, entry.assignedByEmail),
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _cell(
          Text(
            dateFormat.format(entry.startDate),
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
        _cell(
          Text(
            dateFormat.format(entry.endDate),
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      ],
    );
  }

  Widget _cell(Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: child,
    );
  }
}
```

- [ ] **Step 2: Verify**

Run: `dart analyze lib/features/grc/control_owner/presentation/ui/pages/control_previous_owners_page.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/control_owner/presentation/ui/pages/control_previous_owners_page.dart
git commit -m "feat(grc): add ControlPreviousOwnersPage"
```

---

### Task 5: DI registration + wire the button

**Files:**
- Modify: `lib/features/grc/grc_get_it.dart`
- Modify: `lib/features/grc/control/presentation/ui/pages/control_details_page.dart`

**Interfaces:**
- Consumes: `GetControlOwnerHistoryUseCase` (Task 2), `ControlPreviousOwnersCubit` (Task 3), `ControlPreviousOwnersPage` (Task 4).
- Produces: nothing further — this is the last task.

- [ ] **Step 1: Add the two imports to `grc_get_it.dart`**

Add this import right after the existing `get_owner_usecases.dart` import (around line 40):

```dart
import 'package:demo_app/features/grc/control_owner/domain/use_cases/get_control_owner_history_use_case.dart';
```

Add this import right after the existing `owner_cubit.dart` import (around line 56):

```dart
import 'package:demo_app/features/grc/control_owner/presentation/controller/control_previous_owners_cubit.dart';
```

- [ ] **Step 2: Register `GetControlOwnerHistoryUseCase`**

Replace:

```dart
  /// class name: [UpdateOwnerUseCase]
  /// purpose: business logic for updating (or soft-deleting/restoring) a Control Owner.
  sl.registerLazySingleton<UpdateOwnerUseCase>(
    () => UpdateOwnerUseCase(sl<OwnerRepository>()),
  );

  // ─── 4. Cubit (Presentation) ────────────────────────────────────────────────
```

with:

```dart
  /// class name: [UpdateOwnerUseCase]
  /// purpose: business logic for updating (or soft-deleting/restoring) a Control Owner.
  sl.registerLazySingleton<UpdateOwnerUseCase>(
    () => UpdateOwnerUseCase(sl<OwnerRepository>()),
  );

  /// class name: [GetControlOwnerHistoryUseCase]
  /// purpose: business logic for fetching a single Control's Owner-assignment history.
  sl.registerLazySingleton<GetControlOwnerHistoryUseCase>(
    () => GetControlOwnerHistoryUseCase(sl<OwnerRepository>()),
  );

  // ─── 4. Cubit (Presentation) ────────────────────────────────────────────────
```

- [ ] **Step 3: Register `ControlPreviousOwnersCubit`**

Replace:

```dart
  /// class name: [OwnerCubit]
  /// purpose: presentation-layer state manager for Control Owner operations.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<OwnerCubit>(
    () => OwnerCubit(
      createOwnerUseCase: sl<CreateOwnerUseCase>(),
      getOwnerUseCase: sl<GetOwnerUseCase>(),
      getAllOwnersUseCase: sl<GetAllOwnersUseCase>(),
      updateOwnerUseCase: sl<UpdateOwnerUseCase>(),
    ),
  );
}
```

with:

```dart
  /// class name: [OwnerCubit]
  /// purpose: presentation-layer state manager for Control Owner operations.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<OwnerCubit>(
    () => OwnerCubit(
      createOwnerUseCase: sl<CreateOwnerUseCase>(),
      getOwnerUseCase: sl<GetOwnerUseCase>(),
      getAllOwnersUseCase: sl<GetAllOwnersUseCase>(),
      updateOwnerUseCase: sl<UpdateOwnerUseCase>(),
    ),
  );

  /// class name: [ControlPreviousOwnersCubit]
  /// purpose: presentation-layer state manager for the previous control owners page.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<ControlPreviousOwnersCubit>(
    () => ControlPreviousOwnersCubit(
      getOwnerHistoryUseCase: sl<GetControlOwnerHistoryUseCase>(),
    ),
  );
}
```

- [ ] **Step 4: Wire the button in `ControlDetailsPage`**

In `lib/features/grc/control/presentation/ui/pages/control_details_page.dart`, add this import alongside the existing ones:

```dart
import 'package:demo_app/features/grc/control_owner/presentation/ui/pages/control_previous_owners_page.dart';
```

Add this method to `_ControlDetailsBodyState`, right above `_buildScoreAndPreviousOwnersRow`:

```dart
  void _openPreviousControlOwners() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ControlPreviousOwnersPage(
          module: widget.module,
          policy: widget.policy,
          control: _control,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

```

Then replace:

```dart
        customButton(
          title: 'Previous Control Owners'.tr,
          function: () {},
          height: 38.h,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
```

with:

```dart
        customButton(
          title: 'Previous Control Owners'.tr,
          function: _openPreviousControlOwners,
          height: 38.h,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
```

- [ ] **Step 5: Verify**

Run: `dart analyze lib/features/grc/grc_get_it.dart lib/features/grc/control/presentation/ui/pages/control_details_page.dart`
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/grc_get_it.dart lib/features/grc/control/presentation/ui/pages/control_details_page.dart
git commit -m "feat(grc): wire the Previous Control Owners button to the new page"
```

---

## Final check

- [ ] **Run a full analyze pass**

Run: `dart analyze lib/features/grc`
Expected: no new errors introduced by this plan (pre-existing warnings unrelated to these files are fine).
