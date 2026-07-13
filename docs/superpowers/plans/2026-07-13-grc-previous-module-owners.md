# GRC Previous Module Owners Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the "Previous Module Owners" page — reachable from the already-existing (currently dead) menu item on each GRC Module card — showing every owner who has ever been removed from the module, who assigned them, and the date range they held the role.

**Architecture:** A new pure function on `GRCModuleModel` (`toOwnerHistory()`) reconstructs owner-assignment stints by diffing the existing per-revision `moduleOwners`/`modifiers`/`modificationDate` history lists — no new Firestore reads, writes, or schema. That flows up through one new repository method, one new use case, one new small cubit, and one new page, following the exact layering already used by the rest of the GRC Module feature.

**Tech Stack:** Flutter, `cloud_firestore` (indirectly, via the existing `GRCModuleFirebaseDataSource.get`), `dartz` (`Either`), `flutter_bloc` (Cubit), `get_it`, `intl` (`DateFormat`).

**Spec:** `docs/superpowers/specs/2026-07-13-grc-previous-module-owners-design.md`

## Global Constraints

- Only **removed** owners appear on this page — current owners never show up here, regardless of how long they've held the role.
- **Assigned By** = the email in `Modifiers` at the revision where that owner's stint started (i.e. whoever saved the edit that added them).
- **One row per stint, not per person** — if the same person is added, removed, added again, and removed again, that's two separate rows with independent Start/End dates.
- No new Firestore location, no new writes, no schema change — this reads the same document `GRCModuleFirebaseDataSource.get` already fetches.
- Dates render as `d MMM yyyy` via `intl`'s `DateFormat`, matching the rest of the GRC feature.
- Owners/Assigned-By are resolved by **email** via the existing `EmployeeHelper.getEmployeeLocalizedNameWithEmail({required String employeeEmail})` / `EmployeeHelper.getEmployeeImageWithEmail({required String employeeEmail})` — matches how the rest of this feature already stores/looks up owners (see `docs/superpowers/plans/2026-07-12-grc-module-storage-alignment.md`).
- Follow existing GRC-feature conventions exactly: `PaginationAppBar` as a `Column` child inside `Scaffold.body` (not `Scaffold.appBar`) — see `grc_details_page.dart`; dark-header/alternating-row `Table` styling — see `policy_controls_table_widget.dart`; cubits registered via `sl.registerFactory` so each page gets its own instance — see `grc_get_it.dart`.

---

## File Structure

| File | Responsibility |
|---|---|
| `lib/features/grc/domain/entities/grc_module_owner_history_entry.dart` (new) | Plain entity: one completed owner stint |
| `lib/features/grc/data/models/grc_module_model.dart` (modify) | `toOwnerHistory()` — reconstructs stints from revision history |
| `test/features/grc/grc_module_owner_history_test.dart` (new) | Unit tests for `toOwnerHistory()` |
| `lib/features/grc/domain/repository/grc_module_repository.dart` (modify) | Add `getModuleOwnerHistory(String id)` to the interface |
| `lib/features/grc/data/repository/grc_module_repository_impl.dart` (modify) | Implement it |
| `lib/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart` (new) | Thin pass-through to the repository |
| `lib/features/grc/presentation/controller/grc_previous_owners_cubit.dart` + `grc_previous_owners_state.dart` (new) | Loading/Loaded/Failure state for the page |
| `lib/features/grc/presentation/ui/pages/grc_previous_module_owners_page.dart` (new) | The page + its table widget |
| `lib/features/grc/grc_get_it.dart` (modify) | Register the new use case + cubit |
| `lib/features/grc/presentation/ui/pages/grc_page.dart` (modify) | Wire the dead `'previousModuleOwners'` menu branch |

---

### Task 1: `GRCModuleOwnerHistoryEntry` entity + `GRCModuleModel.toOwnerHistory()`

**Files:**
- Create: `lib/features/grc/domain/entities/grc_module_owner_history_entry.dart`
- Modify: `lib/features/grc/data/models/grc_module_model.dart`
- Test: `test/features/grc/grc_module_owner_history_test.dart`

**Interfaces:**
- Produces: `class GRCModuleOwnerHistoryEntry { final String ownerEmail; final String assignedByEmail; final DateTime startDate; final DateTime endDate; const GRCModuleOwnerHistoryEntry({required this.ownerEmail, required this.assignedByEmail, required this.startDate, required this.endDate}); }`
- Produces: `GRCModuleModel.toOwnerHistory()` → `List<GRCModuleOwnerHistoryEntry>`, sorted by `endDate` descending, containing only completed (removed) stints.

- [ ] **Step 1: Create the entity**

Create `lib/features/grc/domain/entities/grc_module_owner_history_entry.dart`:

```dart
/// Module: GRC Module Management
/// Description: One completed owner-assignment stint for a GRC Module —
///              who held the "owner" role, who assigned them, and the date
///              range they held it. Reconstructed from GRCModuleModel's
///              revision history; never persisted on its own.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-13
/// Dependencies: None
/// Revision History: 2026-07-13 - Initial creation

/// class name: [GRCModuleOwnerHistoryEntry]
///
/// purpose: represents a single completed stint of one person being an
///          owner of a GRC Module: they were assigned on [startDate] (by
///          [assignedByEmail]) and stopped being an owner on [endDate].
///          Only ever produced for owners who have since been removed —
///          a currently-active owner has no [GRCModuleOwnerHistoryEntry].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 13/7/2026
class GRCModuleOwnerHistoryEntry {
  final String ownerEmail;
  final String assignedByEmail;
  final DateTime startDate;
  final DateTime endDate;

  const GRCModuleOwnerHistoryEntry({
    required this.ownerEmail,
    required this.assignedByEmail,
    required this.startDate,
    required this.endDate,
  });
}
```

- [ ] **Step 2: Write the failing tests**

Create `test/features/grc/grc_module_owner_history_test.dart`:

```dart
import 'package:demo_app/features/grc/data/models/grc_module_model.dart';
import 'package:flutter_test/flutter_test.dart';

GRCModuleModel _buildBase({required List<String> owners}) {
  return GRCModuleModel.create(
    moduleId: 'm1',
    moduleImage: null,
    moduleNameEn: 'Module',
    moduleNameAr: 'وحدة',
    moduleDescriptionEn: 'desc',
    moduleDescriptionAr: 'وصف',
    moduleOwningDepartment: 'IT',
    moduleActivationDate: DateTime(2026, 1, 1),
    owners: owners,
    status: 'Active',
    modifierEmail: 'creator@example.com',
  );
}

void main() {
  group('GRCModuleModel.toOwnerHistory', () {
    test('owners that never changed produce no history entries', () {
      final model = _buildBase(owners: ['a@example.com']);
      expect(model.toOwnerHistory(), isEmpty);
    });

    test('an owner added at creation then removed produces one entry', () {
      final model = _buildBase(owners: ['a@example.com']).copyWithUpdate(
        owners: [],
        modifierEmail: 'remover@example.com',
      );

      final history = model.toOwnerHistory();
      expect(history, hasLength(1));
      expect(history.first.ownerEmail, 'a@example.com');
      expect(history.first.assignedByEmail, 'creator@example.com');
      expect(history.first.startDate, model.modificationDate.first);
      expect(history.first.endDate, model.modificationDate.last);
    });

    test(
        'the same owner added, removed, re-added, removed again produces two entries',
        () {
      var model = _buildBase(owners: ['a@example.com']);
      model = model.copyWithUpdate(
        owners: [],
        modifierEmail: 'remover1@example.com',
      );
      model = model.copyWithUpdate(
        owners: ['a@example.com'],
        modifierEmail: 're-adder@example.com',
      );
      model = model.copyWithUpdate(
        owners: [],
        modifierEmail: 'remover2@example.com',
      );

      final history = model.toOwnerHistory();
      expect(history, hasLength(2));
      expect(history.every((e) => e.ownerEmail == 'a@example.com'), isTrue);
      expect(history[0].assignedByEmail, isNot(history[1].assignedByEmail));
    });

    test('a currently-active owner (never removed) does not appear', () {
      final model = _buildBase(owners: ['a@example.com', 'b@example.com'])
          .copyWithUpdate(
        owners: ['a@example.com'],
        modifierEmail: 'remover@example.com',
      );

      final history = model.toOwnerHistory();
      expect(history, hasLength(1));
      expect(history.first.ownerEmail, 'b@example.com');
    });

    test('multiple entries are sorted by endDate descending', () {
      var model = _buildBase(owners: ['a@example.com', 'b@example.com']);
      model = model.copyWithUpdate(
        owners: ['b@example.com'],
        modifierEmail: 'remover1@example.com',
      );
      model = model.copyWithUpdate(
        owners: [],
        modifierEmail: 'remover2@example.com',
      );

      final history = model.toOwnerHistory();
      expect(history, hasLength(2));
      expect(
        history[0].endDate.isAfter(history[1].endDate) ||
            history[0].endDate.isAtSameMomentAs(history[1].endDate),
        isTrue,
      );
    });
  });
}
```

- [ ] **Step 3: Confirm the test file fails to compile (the method doesn't exist yet)**

Run: `dart analyze test/features/grc/grc_module_owner_history_test.dart lib/features/grc/data/models/grc_module_model.dart`
Expected: an error like "The method 'toOwnerHistory' isn't defined for the type 'GRCModuleModel'".

- [ ] **Step 4: Implement `toOwnerHistory()`**

In `lib/features/grc/data/models/grc_module_model.dart`, add this import near the top (after the existing `grc_module_entity.dart` import):

```dart
import 'package:demo_app/features/grc/domain/entities/grc_module_owner_history_entry.dart';
```

Add this private helper class right after the `_deriveStatus` function (before `class GRCModuleModel`):

```dart
/// Tracks an owner stint that has been opened (added) but not yet closed
/// (removed), while [GRCModuleModel.toOwnerHistory] walks the revisions.
class _OpenOwnerStint {
  final DateTime startDate;
  final String assignedByEmail;

  _OpenOwnerStint({required this.startDate, required this.assignedByEmail});
}
```

Add this method inside `class GRCModuleModel`, right after `toEntity()` (before the class's closing `}`):

```dart
  /// function name: [toOwnerHistory]
  ///
  /// purpose: reconstruct every completed owner-assignment stint by diffing
  ///          [moduleOwners] between consecutive revisions. An owner email
  ///          appearing in revision N but not N-1 opens a stint (assigned by
  ///          [modifiers] at N); an owner email disappearing between N-1 and
  ///          N closes their currently open stint (ends at
  ///          [modificationDate] at N) and emits one
  ///          [GRCModuleOwnerHistoryEntry]. Currently-active owners (never
  ///          removed) never appear in the result. If the same owner is
  ///          added and removed multiple times, each removal produces its
  ///          own entry.
  ///
  /// parameters: none
  ///
  /// return type: [List<GRCModuleOwnerHistoryEntry>] - completed stints only, sorted by endDate descending
  List<GRCModuleOwnerHistoryEntry> toOwnerHistory() {
    final ownerSets = moduleOwners
        .map((raw) => Set<String>.from(jsonDecode(raw) as List))
        .toList();

    final openStints = <String, _OpenOwnerStint>{};
    for (final email in ownerSets.first) {
      openStints[email] = _OpenOwnerStint(
        startDate: modificationDate.first,
        assignedByEmail: modifiers.first,
      );
    }

    final entries = <GRCModuleOwnerHistoryEntry>[];
    for (var i = 1; i < ownerSets.length; i++) {
      final previous = ownerSets[i - 1];
      final current = ownerSets[i];

      for (final email in current.difference(previous)) {
        openStints[email] = _OpenOwnerStint(
          startDate: modificationDate[i],
          assignedByEmail: modifiers[i],
        );
      }

      for (final email in previous.difference(current)) {
        final stint = openStints.remove(email);
        if (stint == null) continue;
        entries.add(GRCModuleOwnerHistoryEntry(
          ownerEmail: email,
          assignedByEmail: stint.assignedByEmail,
          startDate: stint.startDate,
          endDate: modificationDate[i],
        ));
      }
    }

    entries.sort((a, b) => b.endDate.compareTo(a.endDate));
    return entries;
  }
```

- [ ] **Step 5: Verify the tests compile**

Run: `dart analyze test/features/grc/grc_module_owner_history_test.dart lib/features/grc/data/models/grc_module_model.dart lib/features/grc/domain/entities/grc_module_owner_history_entry.dart`
Expected: `No issues found!` (ignore pre-existing "Dangling library doc comment" info lines).

- [ ] **Step 6: Run the tests (requires Flutter SDK)**

Run: `flutter test test/features/grc/grc_module_owner_history_test.dart -v`
Expected: all 5 tests pass. If Flutter isn't available in your environment, say so explicitly rather than claiming this passed — `dart analyze` in Step 5 only proves it compiles, not that the assertions hold.

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/domain/entities/grc_module_owner_history_entry.dart lib/features/grc/data/models/grc_module_model.dart test/features/grc/grc_module_owner_history_test.dart
git commit -m "feat(grc): reconstruct owner assignment history from GRCModuleModel's revision list"
```

---

### Task 2: Repository — `getModuleOwnerHistory`

**Files:**
- Modify: `lib/features/grc/domain/repository/grc_module_repository.dart`
- Modify: `lib/features/grc/data/repository/grc_module_repository_impl.dart`

**Interfaces:**
- Consumes: `GRCModuleModel.toOwnerHistory()` (Task 1), `GRCModuleOwnerHistoryEntry` (Task 1), `GRCModuleFirebaseDataSource.get(String id)` (already exists, returns `Future<GRCModuleModel?>`).
- Produces: `GRCModuleRepository.getModuleOwnerHistory(String id)` → `Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>`.

- [ ] **Step 1: Add the method to the interface**

In `lib/features/grc/domain/repository/grc_module_repository.dart`, add this import:

```dart
import '../entities/grc_module_owner_history_entry.dart';
```

Add this method to `abstract class GRCModuleRepository`, after `restoreModule`:

```dart
  /// function name: [getModuleOwnerHistory]
  ///
  /// purpose: fetch the full owner-assignment history of a GRC Module —
  ///          every owner who has since been removed, who assigned them,
  ///          and the date range they held the role.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module
  ///
  /// return type: [Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>] - completed owner stints, or a Failure
  Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>
      getModuleOwnerHistory(String id);
```

- [ ] **Step 2: Implement it**

In `lib/features/grc/data/repository/grc_module_repository_impl.dart`, add this import:

```dart
import '../../domain/entities/grc_module_owner_history_entry.dart';
```

Add this method to `class GRCModuleRepositoryImpl`, after `restoreModule`:

```dart
  /// function name: [getModuleOwnerHistory]
  ///
  /// purpose: fetch a module by id from the Firestore data source and map
  ///          its full revision history to completed owner-assignment
  ///          stints via [GRCModuleModel.toOwnerHistory].
  ///
  /// parameters: see [GRCModuleRepository.getModuleOwnerHistory]
  ///
  /// return type: [Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>] - completed owner stints, a [ValidationError], or a [FirebaseFailure]
  @override
  Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>
      getModuleOwnerHistory(String id) async {
    try {
      final model = await _firebaseDataSource.get(id);
      if (model == null) {
        return Left(ValidationError('GRC Module not found (id: $id)'));
      }
      return Right(model.toOwnerHistory());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/features/grc/domain/repository/grc_module_repository.dart lib/features/grc/data/repository/grc_module_repository_impl.dart`
Expected: zero `error -` lines (the pre-existing `uuid` dependency info in the impl file is out of scope).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/domain/repository/grc_module_repository.dart lib/features/grc/data/repository/grc_module_repository_impl.dart
git commit -m "feat(grc): add getModuleOwnerHistory to GRCModuleRepository"
```

---

### Task 3: `GetGRCModuleOwnerHistoryUseCase`

**Files:**
- Create: `lib/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart`

**Interfaces:**
- Consumes: `GRCModuleRepository.getModuleOwnerHistory(String id)` (Task 2).
- Produces: `class GetGRCModuleOwnerHistoryUseCase { GetGRCModuleOwnerHistoryUseCase(GRCModuleRepository repository); Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>> execute(String id); }`.

- [ ] **Step 1: Create the use case**

Create `lib/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart`:

```dart
/// Module: GRC Module Management
/// Description: Use case responsible for fetching a GRC Module's owner
///              assignment history.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-13
/// Dependencies: dartz, GRCModuleRepository, GRCModuleOwnerHistoryEntry, Failure
/// Revision History: 2026-07-13 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/grc_module_owner_history_entry.dart';
import 'package:demo_app/features/grc/domain/repository/grc_module_repository.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: get_grc_module_owner_history_use_case.dart
/// Purpose: Contains the GetGRCModuleOwnerHistoryUseCase class, which
///          encapsulates the business logic for fetching a module's owner
///          assignment history.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 13/7/2026

/// class name: [GetGRCModuleOwnerHistoryUseCase]
///
/// purpose: encapsulate the business logic for fetching a single GRC
///          Module's owner-assignment history by its id. Delegates to
///          [GRCModuleRepository.getModuleOwnerHistory] and returns the
///          result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 13/7/2026
class GetGRCModuleOwnerHistoryUseCase {
  final GRCModuleRepository _repository;

  GetGRCModuleOwnerHistoryUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch the owner-assignment history for the module matching [id].
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module
  ///
  /// return type: [Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>] - completed owner stints, or a Failure
  Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>> execute(
      String id) {
    return _repository.getModuleOwnerHistory(id);
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `dart analyze lib/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart
git commit -m "feat(grc): add GetGRCModuleOwnerHistoryUseCase"
```

---

### Task 4: `GrcPreviousOwnersCubit`

**Files:**
- Create: `lib/features/grc/presentation/controller/grc_previous_owners_cubit.dart`
- Create: `lib/features/grc/presentation/controller/grc_previous_owners_state.dart`

**Interfaces:**
- Consumes: `GetGRCModuleOwnerHistoryUseCase.execute(String id)` (Task 3).
- Produces: `class GrcPreviousOwnersCubit extends Cubit<GrcPreviousOwnersState> { GrcPreviousOwnersCubit({required GetGRCModuleOwnerHistoryUseCase getOwnerHistoryUseCase}); Future<void> loadHistory(String moduleId); }`; states `GrcPreviousOwnersInitial`, `GrcPreviousOwnersLoading`, `GrcPreviousOwnersLoaded(List<GRCModuleOwnerHistoryEntry> entries)`, `GrcPreviousOwnersFailure(String message)`.

- [ ] **Step 1: Create the state file**

Create `lib/features/grc/presentation/controller/grc_previous_owners_state.dart`:

```dart
part of 'grc_previous_owners_cubit.dart';

sealed class GrcPreviousOwnersState {}

final class GrcPreviousOwnersInitial extends GrcPreviousOwnersState {}

final class GrcPreviousOwnersLoading extends GrcPreviousOwnersState {}

final class GrcPreviousOwnersLoaded extends GrcPreviousOwnersState {
  final List<GRCModuleOwnerHistoryEntry> entries;
  GrcPreviousOwnersLoaded(this.entries);
}

final class GrcPreviousOwnersFailure extends GrcPreviousOwnersState {
  final String message;
  GrcPreviousOwnersFailure(this.message);
}
```

- [ ] **Step 2: Create the cubit**

Create `lib/features/grc/presentation/controller/grc_previous_owners_cubit.dart`:

```dart
/// Module: GRC Module Management
/// Description: BLoC Cubit that manages the Previous Module Owners page's
///              state. Delegates to GetGRCModuleOwnerHistoryUseCase and
///              emits typed GrcPreviousOwnersState subclasses.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-13
/// Dependencies: flutter_bloc, GetGRCModuleOwnerHistoryUseCase, GRCModuleOwnerHistoryEntry
/// Revision History: 2026-07-13 - Initial creation
library;

import 'package:demo_app/features/grc/domain/entities/grc_module_owner_history_entry.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'grc_previous_owners_state.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_previous_owners_cubit.dart
/// Purpose: Contains the GrcPreviousOwnersCubit class, the presentation-
///          layer state manager for the Previous Module Owners page.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 13/7/2026

/// class name: [GrcPreviousOwnersCubit]
///
/// purpose: load a GRC Module's owner-assignment history and expose it as
///          typed state for [GrcPreviousModuleOwnersPage].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 13/7/2026
class GrcPreviousOwnersCubit extends Cubit<GrcPreviousOwnersState> {
  GrcPreviousOwnersCubit({
    required GetGRCModuleOwnerHistoryUseCase getOwnerHistoryUseCase,
  })  : _getOwnerHistoryUseCase = getOwnerHistoryUseCase,
        super(GrcPreviousOwnersInitial());

  final GetGRCModuleOwnerHistoryUseCase _getOwnerHistoryUseCase;

  /// function name: [loadHistory]
  ///
  /// purpose: fetch the owner-assignment history for [moduleId] and emit
  ///          [GrcPreviousOwnersLoaded] on success or
  ///          [GrcPreviousOwnersFailure] on failure.
  ///
  /// parameters:
  ///            [String] moduleId: unique identifier of the module
  ///
  /// return type: [Future<void>]
  Future<void> loadHistory(String moduleId) async {
    emit(GrcPreviousOwnersLoading());
    final result = await _getOwnerHistoryUseCase.execute(moduleId);
    result.fold(
      (failure) => emit(GrcPreviousOwnersFailure(failure.message)),
      (entries) => emit(GrcPreviousOwnersLoaded(entries)),
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/features/grc/presentation/controller/grc_previous_owners_cubit.dart lib/features/grc/presentation/controller/grc_previous_owners_state.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/controller/grc_previous_owners_cubit.dart lib/features/grc/presentation/controller/grc_previous_owners_state.dart
git commit -m "feat(grc): add GrcPreviousOwnersCubit"
```

---

### Task 5: DI registration

**Files:**
- Modify: `lib/features/grc/grc_get_it.dart`

**Interfaces:**
- Consumes: `GetGRCModuleOwnerHistoryUseCase` (Task 3), `GrcPreviousOwnersCubit` (Task 4), `GRCModuleRepository` (already registered).

- [ ] **Step 1: Add the imports**

Add these two imports to `lib/features/grc/grc_get_it.dart`, alongside the existing `use_cases`/`controller` imports (keep alphabetical order within each group):

```dart
import 'package:demo_app/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart';
```

```dart
import 'package:demo_app/features/grc/presentation/controller/grc_previous_owners_cubit.dart';
```

- [ ] **Step 2: Register the use case**

In the `// ─── 3. Use Cases ───` section, add this registration right after `RestoreGRCModuleUseCase`'s block:

```dart
  /// class name: [GetGRCModuleOwnerHistoryUseCase]
  /// purpose: business logic for fetching a module's owner assignment history.
  sl.registerLazySingleton<GetGRCModuleOwnerHistoryUseCase>(
    () => GetGRCModuleOwnerHistoryUseCase(sl<GRCModuleRepository>()),
  );
```

- [ ] **Step 3: Register the cubit**

In the `// ─── 4. Cubit (Presentation) ───` section, add this registration right after `GRCModuleCubit`'s block (before `PolicyCubit`'s):

```dart
  /// class name: [GrcPreviousOwnersCubit]
  /// purpose: presentation-layer state manager for the Previous Module
  /// Owners page. Registered as a factory so each page gets an
  /// independent cubit instance.
  sl.registerFactory<GrcPreviousOwnersCubit>(
    () => GrcPreviousOwnersCubit(
      getOwnerHistoryUseCase: sl<GetGRCModuleOwnerHistoryUseCase>(),
    ),
  );
```

- [ ] **Step 4: Verify it compiles**

Run: `dart analyze lib/features/grc/grc_get_it.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): register GetGRCModuleOwnerHistoryUseCase and GrcPreviousOwnersCubit"
```

---

### Task 6: `GrcPreviousModuleOwnersPage`

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/grc_previous_module_owners_page.dart`

**Interfaces:**
- Consumes: `GrcPreviousOwnersCubit` + its states (Task 4), `GRCModuleOwnerHistoryEntry` (Task 1), `EmployeeHelper.getEmployeeLocalizedNameWithEmail({required String employeeEmail})` / `getEmployeeImageWithEmail({required String employeeEmail})` (already exist in `lib/core/helper/main_helper/employee_helper.dart`), `PaginationAppBar({required List<String> screensTitles})` (already exists).
- Produces: `class GrcPreviousModuleOwnersPage extends StatelessWidget { const GrcPreviousModuleOwnersPage({required String moduleId}); }` — the widget Task 7 navigates to.

- [ ] **Step 1: Create the page**

Create `lib/features/grc/presentation/ui/pages/grc_previous_module_owners_page.dart`:

```dart
/// Module: GRC Module Management
/// Description: Shows every owner who has ever been removed from a GRC
///              Module, who assigned them, and the date range they held
///              the role.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-13
/// Dependencies: flutter_bloc, get_it, GrcPreviousOwnersCubit, EmployeeHelper
/// Revision History: 2026-07-13 - Initial creation
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/grc/domain/entities/grc_module_owner_history_entry.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_previous_owners_cubit.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_previous_module_owners_page.dart
/// Purpose: Contains GrcPreviousModuleOwnersPage and the table widget it
///          renders.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 13/7/2026

/// class name: [GrcPreviousModuleOwnersPage]
///
/// purpose: load and display [moduleId]'s owner-assignment history.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 13/7/2026
class GrcPreviousModuleOwnersPage extends StatelessWidget {
  final String moduleId;

  const GrcPreviousModuleOwnersPage({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<GrcPreviousOwnersCubit>()
        ..loadHistory(moduleId),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(
                  screensTitles: ['GRC'.tr, 'Previous Module Owner'.tr],
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: BlocBuilder<GrcPreviousOwnersCubit,
                      GrcPreviousOwnersState>(
                    builder: (context, state) {
                      if (state is GrcPreviousOwnersFailure) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: AppColors.red),
                          ),
                        );
                      }
                      if (state is! GrcPreviousOwnersLoaded) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (state.entries.isEmpty) {
                        return Center(
                          child: Text(
                            'No previous owners'.tr,
                            style: AppTextStyles.font16BlackRegularCairo
                                .copyWith(
                              fontSize: 13.sp,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: _PreviousOwnersTable(entries: state.entries),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// class name: [_PreviousOwnersTable]
///
/// purpose: renders [entries] as a table (NO | Module Owner | Assigned By |
///          Start Date | End Date), matching the dark-header /
///          alternating-row styling already used by
///          `PolicyControlsTableWidget`.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 13/7/2026
class _PreviousOwnersTable extends StatelessWidget {
  final List<GRCModuleOwnerHistoryEntry> entries;

  const _PreviousOwnersTable({required this.entries});

  ImageProvider _avatar(String photo) {
    if (photo.startsWith('http')) return NetworkImage(photo);
    return AssetImage(photo);
  }

  Widget _personCell(String email) {
    final name =
        EmployeeHelper.getEmployeeLocalizedNameWithEmail(employeeEmail: email);
    final photo =
        EmployeeHelper.getEmployeeImageWithEmail(employeeEmail: email);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 14.r, backgroundImage: _avatar(photo)),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            name,
            style: AppTextStyles.font16BlackRegularCairo
                .copyWith(fontSize: 13.sp),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _cell(Widget child) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        child: child,
      );

  TableRow _headerRow() {
    final headers = [
      'NO',
      'Module Owner',
      'Assigned By',
      'Start Date',
      'End Date',
    ];
    return TableRow(
      decoration: const BoxDecoration(color: Colors.black),
      children: headers
          .map(
            (h) => _cell(
              Text(
                h.tr,
                style: AppTextStyles.font16BlackRegularCairo.copyWith(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _dataRow(
    BuildContext context,
    int index,
    GRCModuleOwnerHistoryEntry entry,
  ) {
    final isEven = index % 2 == 0;
    final dateFormat =
        DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');
    return TableRow(
      decoration:
          BoxDecoration(color: isEven ? AppColors.background : AppColors.field),
      children: [
        _cell(
          Text(
            '${index + 1}',
            style: AppTextStyles.font16BlackRegularCairo
                .copyWith(fontSize: 13.sp, color: AppColors.secondaryText),
          ),
        ),
        _cell(_personCell(entry.ownerEmail)),
        _cell(_personCell(entry.assignedByEmail)),
        _cell(
          Text(
            dateFormat.format(entry.startDate),
            style: AppTextStyles.font16BlackRegularCairo
                .copyWith(fontSize: 13.sp),
          ),
        ),
        _cell(
          Text(
            dateFormat.format(entry.endDate),
            style: AppTextStyles.font16BlackRegularCairo
                .copyWith(fontSize: 13.sp),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(44),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.5),
          },
          children: [
            _headerRow(),
            for (var i = 0; i < entries.length; i++)
              _dataRow(context, i, entries[i]),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `dart analyze lib/features/grc/presentation/ui/pages/grc_previous_module_owners_page.dart`
Expected: zero `error -` lines.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/grc_previous_module_owners_page.dart
git commit -m "feat(grc): add GrcPreviousModuleOwnersPage"
```

---

### Task 7: Wire the menu item

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/grc_page.dart`

**Interfaces:**
- Consumes: `GrcPreviousModuleOwnersPage({required String moduleId})` (Task 6), `GRCModuleEntity.moduleId` (already exists).

- [ ] **Step 1: Add the import**

Add this import to `lib/features/grc/presentation/ui/pages/grc_page.dart`, alongside the other `pages/` imports:

```dart
import 'package:demo_app/features/grc/presentation/ui/pages/grc_previous_module_owners_page.dart';
```

- [ ] **Step 2: Add the menu branch**

In `_showModuleMenu`, the popup already offers `'previousModuleOwners'` as a menu value but nothing handles it. Add this branch right after the existing `if (selected == 'delete') { ... return; }` block, before the `if (selected == 'restore')` block:

```dart
    if (selected == 'previousModuleOwners') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              GrcPreviousModuleOwnersPage(moduleId: module.moduleId),
        ),
      );
      return;
    }
```

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/features/grc/presentation/ui/pages/grc_page.dart`
Expected: zero `error -` lines.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/grc_page.dart
git commit -m "feat(grc): wire the Previous Module Owners menu item to the new page"
```

---

### Task 8: Full-slice verification

**Files:** none (verification only)

- [ ] **Step 1: Analyze the entire GRC feature**

Run: `dart analyze lib/features/grc/`
Expected: `0` errors. Any remaining output must be the same pre-existing warnings/infos already present before this plan (dangling doc comments, `withOpacity`/`color` deprecations, the `uuid` dependency notice, the unrelated `_isWeightValid` unused-element warning, and anything still inside `PolicyModel`/`PolicyRepositoryImpl`, which are out of scope).

- [ ] **Step 2: Run the full test suite (requires Flutter SDK)**

Run: `flutter test test/features/grc/ -v`
Expected: all tests pass, including `grc_module_owner_history_test.dart` (Task 1) and the two pre-existing test files. State explicitly if Flutter isn't available rather than claiming this passed.

- [ ] **Step 3: Manual smoke test (requires a running app + Firebase project)**

With the app running and signed in to a tenant, on a module with at least two owners:
1. Remove one owner and save. Open the module's "⋮" menu → "Previous Module Owners". Confirm one row appears with the correct owner, the correct "Assigned By" (whoever created/last added them), a Start Date matching when they were added, and an End Date matching just now.
2. Re-add that same owner, save, remove them again. Confirm the page now shows **two** rows for that person with different date ranges, not one row overwritten.
3. Open "Previous Module Owners" on a module that has never had an owner removed. Confirm the empty state shows.
4. Confirm a currently-active owner (never removed) never appears on this page.
