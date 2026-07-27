# Control Cubit Extraction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the Control feature its own `ControlCubit` (mirroring `ChampionCubit`/`OwnerCubit`), removing all standalone Control operations from `PolicyCubit` so each feature owns its own presentation-layer state, per `Code Quality Standards.md`'s Single Responsibility and Folder Structure conventions.

**Architecture:** Pure presentation-layer move. A new `ControlCubit` (in `lib/features/grc/control/presentation/controller/`) takes over `createControl`/`updateControl`/`deleteControl`/`getAllControls`, reusing the same four already-registered use cases `PolicyCubit` currently calls. Two pure business-rule methods (`computeDateBasedStatus`/`resolveControlStatus`) become static methods on the `ControlStatus` enum instead of living on any Cubit. `PolicyCubit` keeps its Policy CRUD and the "save a Policy plus its bundled initial Controls" wizard orchestration, which keeps its own direct dependency on `CreateControlUseCase`/`UpdateControlUseCase`/`DeleteControlUseCase` (not `GetAllControlsUseCase`, and not by calling `ControlCubit` — Cubit-to-Cubit calls are avoided). No domain or data layer changes.

**Tech Stack:** Flutter, flutter_bloc (Cubit), GetIt (`sl`), dartz (`Either`), flutter_test.

## Global Constraints

- No behavior change anywhere — this is a structural move. Every existing user-facing flow (view/create/edit/delete a Control, create a Policy with initial Controls) must work identically after this plan.
- Follow `Code Quality Standards.md`: snake_case filenames, PascalCase classes, camelCase functions, static const Firestore keys (N/A here, no data-layer change), `Either<Failure, T>` for all repository-backed operations (already true, preserved).
- Do not touch `ControlRepository`, `ControlFirebaseDataSource`, `ControlModel`, or any of the five Control use cases (`CreateControlUseCase`, `GetControlUseCase`, `GetAllControlsUseCase`, `UpdateControlUseCase`, `DeleteControlUseCase`).
- Do not touch `ChampionCubit`/`OwnerCubit`'s own duplicate Control/Policy use-case wrappers — explicitly out of scope (confirmed follow-up).
- Every task must leave `flutter analyze` clean (no new warnings/errors) on every file it touches. Run analyze with:
  `/Users/bstar/.puro/bin/puro flutter analyze <file1> <file2> ...`
- Every task must leave `flutter test` green on every existing and new test file it touches. Run tests with:
  `/Users/bstar/.puro/bin/puro flutter test <test file>`
- Never use `flutter` directly — this machine only has it via `/Users/bstar/.puro/bin/puro flutter`.
- Keep the codebase compiling after every task (tasks are ordered so nothing references a symbol that doesn't exist yet).

Reference spec: `docs/superpowers/specs/2026-07-28-control-cubit-extraction-design.md`

---

### Task 1: `ControlStatus.computeDateBased` / `ControlStatus.resolve`

**Files:**
- Modify: `lib/features/grc/control/domain/entities/control_status.dart`
- Test: `test/features/grc/control/domain/entities/control_status_test.dart` (new)

**Interfaces:**
- Produces: `ControlStatus.computeDateBased(DateTime effectiveStartDate) -> ControlStatus` (static)
- Produces: `ControlStatus.resolve({required ControlStatus requested, required bool manualInactive, required bool hasAnyAssignee}) -> ControlStatus` (static)

- [ ] **Step 1: Write the failing test**

Create `test/features/grc/control/domain/entities/control_status_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';

void main() {
  group('ControlStatus.computeDateBased', () {
    test('returns scheduled when the start date is after today', () {
      final future = DateTime.now().add(const Duration(days: 5));
      expect(ControlStatus.computeDateBased(future), ControlStatus.scheduled);
    });

    test('returns active when the start date is today', () {
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);
      expect(
        ControlStatus.computeDateBased(startOfToday),
        ControlStatus.active,
      );
    });

    test('returns active when the start date is in the past', () {
      final past = DateTime.now().subtract(const Duration(days: 5));
      expect(ControlStatus.computeDateBased(past), ControlStatus.active);
    });
  });

  group('ControlStatus.resolve', () {
    test('draft always wins regardless of other flags', () {
      final result = ControlStatus.resolve(
        requested: ControlStatus.draft,
        manualInactive: true,
        hasAnyAssignee: true,
      );
      expect(result, ControlStatus.draft);
    });

    test('manualInactive wins when requested is not draft', () {
      final result = ControlStatus.resolve(
        requested: ControlStatus.active,
        manualInactive: true,
        hasAnyAssignee: true,
      );
      expect(result, ControlStatus.inactive);
    });

    test('becomes unassigned when there is no assignee', () {
      final result = ControlStatus.resolve(
        requested: ControlStatus.active,
        manualInactive: false,
        hasAnyAssignee: false,
      );
      expect(result, ControlStatus.unassigned);
    });

    test('keeps requested status when an assignee exists', () {
      final result = ControlStatus.resolve(
        requested: ControlStatus.scheduled,
        manualInactive: false,
        hasAnyAssignee: true,
      );
      expect(result, ControlStatus.scheduled);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/control/domain/entities/control_status_test.dart`
Expected: FAIL to compile — `The method 'computeDateBased' isn't defined for the type 'ControlStatus'` (and same for `resolve`).

- [ ] **Step 3: Write minimal implementation**

In `lib/features/grc/control/domain/entities/control_status.dart`, add these two static methods inside the `ControlStatus` enum, right after the existing `fromString` static method (after its closing `}`, before the enum's final closing `}`):

```dart

  /// function name: [computeDateBased]
  ///
  /// purpose: date-based "would-be" status before any assignee/manual
  ///          override: Scheduled if [effectiveStartDate] hasn't arrived yet
  ///          (strictly after the start of today), otherwise Active.
  ///
  /// parameters:
  ///            [DateTime] effectiveStartDate: the control's effective start date
  ///
  /// return type: [ControlStatus] - scheduled or active
  static ControlStatus computeDateBased(DateTime effectiveStartDate) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return effectiveStartDate.isAfter(startOfToday)
        ? ControlStatus.scheduled
        : ControlStatus.active;
  }

  /// function name: [resolve]
  ///
  /// purpose: applies the manual-Inactive and assignee-based overrides on
  ///          top of [requested]: Draft (Save For Later) always wins as-is.
  ///          Otherwise, if the user flipped the "Status" switch to Inactive
  ///          ([manualInactive]), that wins next. Failing both, any other
  ///          status becomes Unassigned unless at least one Champion or
  ///          Owner is currently assigned ([hasAnyAssignee]), in which case
  ///          [requested] (the date-computed Scheduled/Active) stands.
  ///
  /// parameters:
  ///            [ControlStatus] requested: the status requested before overrides
  ///            [bool] manualInactive: whether the user manually set Inactive
  ///            [bool] hasAnyAssignee: whether at least one Champion/Owner is assigned
  ///
  /// return type: [ControlStatus] - the final resolved status
  static ControlStatus resolve({
    required ControlStatus requested,
    required bool manualInactive,
    required bool hasAnyAssignee,
  }) {
    if (requested == ControlStatus.draft) return requested;
    if (manualInactive) return ControlStatus.inactive;
    return hasAnyAssignee ? requested : ControlStatus.unassigned;
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/control/domain/entities/control_status_test.dart`
Expected: PASS (7 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control/domain/entities/control_status.dart test/features/grc/control/domain/entities/control_status_test.dart
git commit -m "feat(grc): add ControlStatus.computeDateBased/resolve static methods"
```

---

### Task 2: New `ControlCubit` + `ControlState`

**Files:**
- Create: `lib/features/grc/control/presentation/controller/control_cubit.dart`
- Create: `lib/features/grc/control/presentation/controller/control_state.dart`
- Test: `test/features/grc/control/presentation/controller/control_cubit_test.dart` (new)

**Interfaces:**
- Consumes: `ControlStatus.computeDateBased`/`.resolve` are NOT used by this cubit (only by pages, see Task 4) — this cubit only consumes the four existing use cases: `CreateControlUseCase.call(CreateControlParams)`, `UpdateControlUseCase.call(UpdateControlParams)`, `DeleteControlUseCase.call(DeleteControlParams)`, `GetAllControlsUseCase.call({required moduleId, required policyId})`.
- Produces: `ControlCubit` with methods `createControl(...)`, `updateControl(...)`, `deleteControl({required id, required moduleId, required policyId})`, `getAllControls({required moduleId, required policyId})`. States: `ControlInitial`, `ControlLoading`, `ControlActionSuccess(ControlEntity control)`, `ControlsListLoaded(List<ControlEntity> controls)`, `ControlDeleted(String controlId)`, `ControlFailure(String message)`. Later tasks (4, 5, 6, 7, 8) depend on these exact names.

- [ ] **Step 1: Write the failing test**

Create `test/features/grc/control/presentation/controller/control_cubit_test.dart`:

```dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:demo_app/features/grc/control/domain/repository/control_repository.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:demo_app/features/grc/control/presentation/controller/control_cubit.dart';

class _FakeControlRepository implements ControlRepository {
  Either<Failure, ControlEntity>? createResult;
  Either<Failure, ControlEntity>? updateResult;
  Either<Failure, Unit>? deleteResult;
  Either<Failure, List<ControlEntity>>? getAllResult;

  @override
  Future<Either<Failure, ControlEntity>> createControl({
    required String moduleId,
    required String policyId,
    required String editorId,
    required String controlsNameEn,
    required String controlsNameAr,
    required String controlsNumberEn,
    required String controlsNumberAr,
    required String controlsDescriptionEn,
    required String controlsDescriptionAr,
    required double controlsWeight,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> departments,
    List<double>? departmentsWeights,
    required bool equalWeights,
    required int score,
    required ControlStatus status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async =>
      createResult!;

  @override
  Future<Either<Failure, ControlEntity>> updateControl({
    required String id,
    required String moduleId,
    required String policyId,
    required String editorId,
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsNumberEn,
    String? controlsNumberAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    double? controlsWeight,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? departments,
    List<double>? departmentsWeights,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async =>
      updateResult!;

  @override
  Future<Either<Failure, Unit>> deleteControl(
    String id, {
    required String moduleId,
    required String policyId,
  }) async =>
      deleteResult!;

  @override
  Future<Either<Failure, List<ControlEntity>>> getAllControls({
    required String moduleId,
    required String policyId,
  }) async =>
      getAllResult!;

  @override
  Future<Either<Failure, ControlEntity>> getControl(
    String id, {
    required String moduleId,
    required String policyId,
  }) {
    throw UnimplementedError('not needed by ControlCubit');
  }

  @override
  Future<Either<Failure, List<ControlWeightHistoryEntry>>>
      getControlWeightHistory({
    required String moduleId,
    required String policyId,
  }) {
    throw UnimplementedError('not needed by ControlCubit');
  }
}

ControlEntity _buildControl({String id = 'c1'}) {
  final now = DateTime.now();
  return ControlEntity(
    id: id,
    policyId: 'p1',
    controlsNameEn: 'Name',
    controlsNameAr: 'اسم',
    controlsNumberEn: '1',
    controlsNumberAr: '١',
    controlsDescriptionEn: 'desc',
    controlsDescriptionAr: 'وصف',
    controlsDocumentEn: null,
    controlsDocumentAr: null,
    controlsWeight: 10.0,
    frequency: 'Monthly',
    startDate: now,
    endDate: now,
    departments: const [],
    equalWeights: true,
    score: 0,
    status: ControlStatus.active,
    lastModifiedDate: now,
    lastEditor: 'a@a.com',
  );
}

ControlCubit _buildCubit(_FakeControlRepository repo) {
  return ControlCubit(
    createControlUseCase: CreateControlUseCase(repo),
    updateControlUseCase: UpdateControlUseCase(repo),
    deleteControlUseCase: DeleteControlUseCase(repo),
    getAllControlsUseCase: GetAllControlsUseCase(repo),
  );
}

void main() {
  test('createControl emits [ControlLoading, ControlActionSuccess] on success',
      () async {
    final control = _buildControl();
    final repo = _FakeControlRepository()..createResult = Right(control);
    final cubit = _buildCubit(repo);
    final states = <ControlState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.createControl(
      moduleId: 'm1',
      policyId: 'p1',
      controlsNameEn: 'Name',
      controlsNameAr: 'اسم',
      controlsNumberEn: '1',
      controlsNumberAr: '١',
      controlsDescriptionEn: 'desc',
      controlsDescriptionAr: 'وصف',
      controlsWeight: 10.0,
      frequency: 'Monthly',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      departments: const [],
      equalWeights: true,
      score: 0,
      status: ControlStatus.active,
    );

    await sub.cancel();
    expect(states, [isA<ControlLoading>(), isA<ControlActionSuccess>()]);
    expect((states[1] as ControlActionSuccess).control, control);
    await cubit.close();
  });

  test('createControl emits [ControlLoading, ControlFailure] on failure',
      () async {
    final repo = _FakeControlRepository()
      ..createResult = const Left(FeatureFailure('boom'));
    final cubit = _buildCubit(repo);
    final states = <ControlState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.createControl(
      moduleId: 'm1',
      policyId: 'p1',
      controlsNameEn: 'Name',
      controlsNameAr: 'اسم',
      controlsNumberEn: '1',
      controlsNumberAr: '١',
      controlsDescriptionEn: 'desc',
      controlsDescriptionAr: 'وصف',
      controlsWeight: 10.0,
      frequency: 'Monthly',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      departments: const [],
      equalWeights: true,
      score: 0,
      status: ControlStatus.active,
    );

    await sub.cancel();
    expect(states, [isA<ControlLoading>(), isA<ControlFailure>()]);
    expect((states[1] as ControlFailure).message, 'boom');
    await cubit.close();
  });

  test('updateControl emits [ControlLoading, ControlActionSuccess] on success',
      () async {
    final control = _buildControl();
    final repo = _FakeControlRepository()..updateResult = Right(control);
    final cubit = _buildCubit(repo);
    final states = <ControlState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.updateControl(id: 'c1', moduleId: 'm1', policyId: 'p1');

    await sub.cancel();
    expect(states, [isA<ControlLoading>(), isA<ControlActionSuccess>()]);
    expect((states[1] as ControlActionSuccess).control, control);
    await cubit.close();
  });

  test('updateControl emits [ControlLoading, ControlFailure] on failure',
      () async {
    final repo = _FakeControlRepository()
      ..updateResult = const Left(FeatureFailure('boom'));
    final cubit = _buildCubit(repo);
    final states = <ControlState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.updateControl(id: 'c1', moduleId: 'm1', policyId: 'p1');

    await sub.cancel();
    expect(states, [isA<ControlLoading>(), isA<ControlFailure>()]);
    expect((states[1] as ControlFailure).message, 'boom');
    await cubit.close();
  });

  test('deleteControl emits [ControlLoading, ControlDeleted] on success',
      () async {
    final repo = _FakeControlRepository()..deleteResult = const Right(unit);
    final cubit = _buildCubit(repo);
    final states = <ControlState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.deleteControl(id: 'c1', moduleId: 'm1', policyId: 'p1');

    await sub.cancel();
    expect(states, [isA<ControlLoading>(), isA<ControlDeleted>()]);
    expect((states[1] as ControlDeleted).controlId, 'c1');
    await cubit.close();
  });

  test('deleteControl emits [ControlLoading, ControlFailure] on failure',
      () async {
    final repo = _FakeControlRepository()
      ..deleteResult = const Left(FeatureFailure('boom'));
    final cubit = _buildCubit(repo);
    final states = <ControlState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.deleteControl(id: 'c1', moduleId: 'm1', policyId: 'p1');

    await sub.cancel();
    expect(states, [isA<ControlLoading>(), isA<ControlFailure>()]);
    await cubit.close();
  });

  test('getAllControls emits [ControlLoading, ControlsListLoaded] on success',
      () async {
    final control = _buildControl();
    final repo = _FakeControlRepository()..getAllResult = Right([control]);
    final cubit = _buildCubit(repo);
    final states = <ControlState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.getAllControls(moduleId: 'm1', policyId: 'p1');

    await sub.cancel();
    expect(states, [isA<ControlLoading>(), isA<ControlsListLoaded>()]);
    expect((states[1] as ControlsListLoaded).controls, [control]);
    await cubit.close();
  });

  test('getAllControls emits [ControlLoading, ControlFailure] on failure',
      () async {
    final repo = _FakeControlRepository()
      ..getAllResult = const Left(FeatureFailure('boom'));
    final cubit = _buildCubit(repo);
    final states = <ControlState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.getAllControls(moduleId: 'm1', policyId: 'p1');

    await sub.cancel();
    expect(states, [isA<ControlLoading>(), isA<ControlFailure>()]);
    await cubit.close();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/control/presentation/controller/control_cubit_test.dart`
Expected: FAIL to compile — `Target of URI doesn't exist: 'package:demo_app/features/grc/control/presentation/controller/control_cubit.dart'`.

- [ ] **Step 3: Write minimal implementation**

Create `lib/features/grc/control/presentation/controller/control_state.dart`:

```dart
part of 'control_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_state.dart
/// Purpose: Contains all sealed state classes emitted by [ControlCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

sealed class ControlState {}

/// State emitted before any action has been requested.
final class ControlInitial extends ControlState {}

/// State emitted while any async operation is in progress.
final class ControlLoading extends ControlState {}

/// State emitted when a single Control create/update completes successfully.
final class ControlActionSuccess extends ControlState {
  final ControlEntity control;

  ControlActionSuccess(this.control);
}

/// State emitted when a Policy's Controls have been fetched successfully.
final class ControlsListLoaded extends ControlState {
  final List<ControlEntity> controls;

  ControlsListLoaded(this.controls);
}

/// State emitted when a Control has been deleted successfully.
final class ControlDeleted extends ControlState {
  final String controlId;

  ControlDeleted(this.controlId);
}

/// State emitted when any operation fails.
final class ControlFailure extends ControlState {
  final String message;

  ControlFailure(this.message);
}
```

Create `lib/features/grc/control/presentation/controller/control_cubit.dart`:

```dart
/// Module: Policy Management
/// Description: BLoC Cubit that manages standalone Control state for the
///              presentation layer. Delegates all operations to the
///              corresponding use cases and emits typed [ControlState]
///              subclasses. Extracted from PolicyCubit, which previously
///              owned these operations even though neither
///              ControlDetailsPage nor AddEditControlPage ever needs a
///              Policy operation — see
///              docs/superpowers/specs/2026-07-28-control-cubit-extraction-design.md.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
/// Dependencies: flutter_bloc, get, use cases, ControlEntity
/// Revision History: 2026-07-28 - Extracted from PolicyCubit
library;

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'control_state.dart';

/// class name: [ControlCubit]
///
/// purpose: manage all standalone Control UI state (create/update/delete/
///          list-all). Each public method maps to one use case and follows
///          the pattern: emit [ControlLoading] → call use case → emit a
///          success state or [ControlFailure].
class ControlCubit extends Cubit<ControlState> {
  ControlCubit({
    required CreateControlUseCase createControlUseCase,
    required UpdateControlUseCase updateControlUseCase,
    required DeleteControlUseCase deleteControlUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _createControlUseCase = createControlUseCase,
        _updateControlUseCase = updateControlUseCase,
        _deleteControlUseCase = deleteControlUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        super(ControlInitial());

  final CreateControlUseCase _createControlUseCase;
  final UpdateControlUseCase _updateControlUseCase;
  final DeleteControlUseCase _deleteControlUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;

  /// Resolves the currently logged-in user's email. Duplicated from
  /// PolicyCubit (not shared via inheritance/composition) because both
  /// Cubits independently need it and Cubits should not depend on each
  /// other.
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  Future<void> createControl({
    required String moduleId,
    required String policyId,
    required String controlsNameEn,
    required String controlsNameAr,
    required String controlsNumberEn,
    required String controlsNumberAr,
    required String controlsDescriptionEn,
    required String controlsDescriptionAr,
    required double controlsWeight,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> departments,
    required bool equalWeights,
    required int score,
    required ControlStatus status,
    List<double>? departmentsWeights,
    controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    emit(ControlLoading());
    final result = await _createControlUseCase.call(
      CreateControlParams(
        moduleId: moduleId,
        policyId: policyId,
        editorId: _currentUserEmail,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        departmentsWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        controlsDocumentFileEn: controlsDocumentFileEn,
        controlsDocumentUrlEn: controlsDocumentUrlEn,
        controlsDocumentFileAr: controlsDocumentFileAr,
        controlsDocumentUrlAr: controlsDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(ControlFailure(failure.message)),
      (control) => emit(ControlActionSuccess(control)),
    );
  }

  Future<void> updateControl({
    required String id,
    required String moduleId,
    required String policyId,
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsNumberEn,
    String? controlsNumberAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    double? controlsWeight,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? departments,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    List<double>? departmentsWeights,
    controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    emit(ControlLoading());
    final result = await _updateControlUseCase.call(
      UpdateControlParams(
        id: id,
        moduleId: moduleId,
        policyId: policyId,
        editorId: _currentUserEmail,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        departmentsWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        controlsDocumentFileEn: controlsDocumentFileEn,
        controlsDocumentUrlEn: controlsDocumentUrlEn,
        controlsDocumentFileAr: controlsDocumentFileAr,
        controlsDocumentUrlAr: controlsDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(ControlFailure(failure.message)),
      (control) => emit(ControlActionSuccess(control)),
    );
  }

  Future<void> deleteControl({
    required String id,
    required String moduleId,
    required String policyId,
  }) async {
    emit(ControlLoading());
    final result = await _deleteControlUseCase.call(
      DeleteControlParams(id: id, moduleId: moduleId, policyId: policyId),
    );
    result.fold(
      (failure) => emit(ControlFailure(failure.message)),
      (_) => emit(ControlDeleted(id)),
    );
  }

  Future<void> getAllControls({
    required String moduleId,
    required String policyId,
  }) async {
    emit(ControlLoading());
    final result = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    result.fold(
      (failure) => emit(ControlFailure(failure.message)),
      (controls) => emit(ControlsListLoaded(controls)),
    );
  }
}
```

**Note on the `controlsDocumentFileEn`/`controlsDocumentFileAr` parameters above:** they are typed `File?` in the original `PolicyCubit` methods (`import 'dart:io'` for `File`). Add `import 'dart:io';` as the first import line of `control_cubit.dart` and type both parameters explicitly as `File?` (the snippet above omits the explicit type only because inference from `CreateControlParams`/`UpdateControlParams` would otherwise force you to check — write them as `File? controlsDocumentFileEn,` and `File? controlsDocumentFileAr,` in both methods, matching `PolicyCubit`'s original signatures exactly).

- [ ] **Step 4: Run test to verify it passes**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/control/presentation/controller/control_cubit_test.dart`
Expected: PASS (8 tests).

Then run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control/presentation/controller/control_cubit.dart lib/features/grc/control/presentation/controller/control_state.dart`
Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control/presentation/controller/control_cubit.dart lib/features/grc/control/presentation/controller/control_state.dart test/features/grc/control/presentation/controller/control_cubit_test.dart
git commit -m "feat(grc): add ControlCubit, extracted standalone Control ops from PolicyCubit"
```

---

### Task 3: Register `ControlCubit` in `grc_get_it.dart`

**Files:**
- Modify: `lib/features/grc/grc_get_it.dart:72-73` (import), `:494-515` (registration)

**Interfaces:**
- Consumes: `ControlCubit` from Task 2, `CreateControlUseCase`/`UpdateControlUseCase`/`DeleteControlUseCase`/`GetAllControlsUseCase` (already registered at lines 313-341).
- Produces: `sl<ControlCubit>()` resolvable via GetIt for Task 4 onward.

This task is purely additive (does not remove anything from `PolicyCubit`'s registration yet — that happens in Task 8, after every consumer has migrated).

- [ ] **Step 1: Add the import**

In `lib/features/grc/grc_get_it.dart`, find line 72:
```dart
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart';
```
Add immediately after it:
```dart
import 'package:demo_app/features/grc/control/presentation/controller/control_cubit.dart';
```

- [ ] **Step 2: Register the cubit**

Find this block (around line 494-515):
```dart
  /// class name: [PolicyCubit]
  /// purpose: presentation-layer state manager for all Policy and Control
  /// operations. Registered as a factory so each flow-start page gets an
  /// independent cubit instance (the policy list, the Policy Details page, and
  /// the standalone Create flow each resolve their own). Pages pushed as a
  /// continuation of an existing flow do NOT resolve a fresh one — e.g. the
  /// Policy Edit page reuses the Details page's instance via
  /// BlocProvider.value so the two never diverge.
  sl.registerFactory<PolicyCubit>(
    () => PolicyCubit(
      createPolicyUseCase: sl<CreatePolicyUseCase>(),
      getPolicyUseCase: sl<GetPolicyUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      deletePolicyUseCase: sl<DeletePolicyUseCase>(),
      restorePolicyUseCase: sl<RestorePolicyUseCase>(),
      createControlUseCase: sl<CreateControlUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
      deleteControlUseCase: sl<DeleteControlUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );
```

Insert this new block immediately **before** it (so `ControlCubit` is registered right above `PolicyCubit`):
```dart
  /// class name: [ControlCubit]
  /// purpose: presentation-layer state manager for standalone Control
  /// operations (create/update/delete/list-all). Registered as a factory so
  /// each flow-start page gets an independent instance, same convention as
  /// PolicyCubit/ChampionCubit/OwnerCubit.
  sl.registerFactory<ControlCubit>(
    () => ControlCubit(
      createControlUseCase: sl<CreateControlUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
      deleteControlUseCase: sl<DeleteControlUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );

```

Leave the `PolicyCubit` registration itself untouched for now (Task 8 removes its `getAllControlsUseCase` line once nothing references `PolicyCubit`'s control methods anymore).

- [ ] **Step 3: Verify it compiles**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/grc_get_it.dart`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): register ControlCubit in GetIt"
```

---

### Task 4: Migrate `control_details_page.dart` + `add_edit_control_page.dart` to `ControlCubit`

**Files:**
- Modify: `lib/features/grc/control/presentation/ui/pages/control_details_page.dart`
- Modify: `lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart`

**Interfaces:**
- Consumes: `ControlCubit` (Task 2/3), `ControlState`/`ControlLoading`/`ControlActionSuccess`/`ControlsListLoaded`/`ControlDeleted`/`ControlFailure`, `ControlStatus.computeDateBased`/`.resolve` (Task 1).

These two files depend on nothing Policy-specific (confirmed during design: no `PolicyEntity`-only operation is called anywhere in either file besides the `PolicyEntity policy` field, which comes from `policy_entity.dart`, not `policy_cubit.dart`). Both files drop `PolicyCubit` entirely.

- [ ] **Step 1: `control_details_page.dart` — swap the import**

Replace:
```dart
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
```
with:
```dart
import 'package:demo_app/features/grc/control/presentation/controller/control_cubit.dart';
```
(keep this in the same alphabetical position in the import list — right where `policy_cubit.dart` was is fine, since this file's imports are not strictly sorted).

- [ ] **Step 2: `control_details_page.dart` — update the class doc comment**

Replace:
```dart
/// Dependencies: flutter_bloc, PolicyCubit, OwnerCubit, ControlEntity,
///               GRCModuleEntity, PolicyEntity, get_it
```
with:
```dart
/// Dependencies: flutter_bloc, ControlCubit, ChampionCubit, OwnerCubit,
///               ControlEntity, GRCModuleEntity, PolicyEntity, get_it
```

And replace:
```dart
/// purpose: entry-point widget for the Control Details screen. Provides its
///          own [PolicyCubit] (delete + post-edit refresh), [ChampionCubit]
///          and [OwnerCubit] (champion/owner lookup), and hands all three
///          down to [AddEditControlPage] via `BlocProvider.value` so state
///          doesn't diverge between the two pages.
```
with:
```dart
/// purpose: entry-point widget for the Control Details screen. Provides its
///          own [ControlCubit] (delete + post-edit refresh), [ChampionCubit]
///          and [OwnerCubit] (champion/owner lookup), and hands all three
///          down to [AddEditControlPage] via `BlocProvider.value` so state
///          doesn't diverge between the two pages.
```

- [ ] **Step 3: `control_details_page.dart` — swap the root `BlocProvider`**

Replace:
```dart
        BlocProvider<PolicyCubit>(
          create: (_) => GetIt.instance<PolicyCubit>(),
        ),
```
with:
```dart
        BlocProvider<ControlCubit>(
          create: (_) => GetIt.instance<ControlCubit>(),
        ),
```

- [ ] **Step 4: `control_details_page.dart` — swap method signatures and bodies**

Replace:
```dart
  Future<void> _openEditControl(PolicyCubit cubit) async {
```
with:
```dart
  Future<void> _openEditControl(ControlCubit cubit) async {
```

Replace:
```dart
            BlocProvider<PolicyCubit>.value(value: cubit),
```
with:
```dart
            BlocProvider<ControlCubit>.value(value: cubit),
```

Replace:
```dart
  void _onDelete(PolicyCubit cubit) {
```
with:
```dart
  void _onDelete(ControlCubit cubit) {
```

Replace:
```dart
  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyControlsListLoaded) {
      final updated = state.controls.where((c) => c.id == _control.id);
      if (updated.isNotEmpty) setState(() => _control = updated.first);
      return;
    }

    if (state is PolicyControlDeleted) {
      showSuccessDialog(
        context: context,
        title: 'Control Deleted'.tr,
        subtitle: 'You successfully deleted this control.'.tr,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyFailure) {
      showErrorDialog(context: context, subtitle: state.message);
    }
  }
```
with:
```dart
  void _onStateChange(BuildContext context, ControlState state) {
    if (state is ControlLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is ControlsListLoaded) {
      final updated = state.controls.where((c) => c.id == _control.id);
      if (updated.isNotEmpty) setState(() => _control = updated.first);
      return;
    }

    if (state is ControlDeleted) {
      showSuccessDialog(
        context: context,
        title: 'Control Deleted'.tr,
        subtitle: 'You successfully deleted this control.'.tr,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is ControlFailure) {
      showErrorDialog(context: context, subtitle: state.message);
    }
  }
```

- [ ] **Step 5: `control_details_page.dart` — swap `build()`**

Replace:
```dart
    final cubit = context.read<PolicyCubit>();
```
with:
```dart
    final cubit = context.read<ControlCubit>();
```

Replace:
```dart
    return BlocListener<PolicyCubit, PolicyState>(
```
with:
```dart
    return BlocListener<ControlCubit, ControlState>(
```

- [ ] **Step 6: `add_edit_control_page.dart` — swap the import and doc comment**

Replace:
```dart
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
```
with:
```dart
import 'package:demo_app/features/grc/control/presentation/controller/control_cubit.dart';
```

Replace:
```dart
/// Dependencies: flutter_bloc, PolicyCubit, ControlEntity, ControlStatus, get_it
```
with:
```dart
/// Dependencies: flutter_bloc, ControlCubit, ControlEntity, ControlStatus, get_it
```

- [ ] **Step 7: `add_edit_control_page.dart` — swap `_onSave`**

Replace:
```dart
  void _onSave(PolicyCubit cubit, {required ControlStatus status}) {
```
with:
```dart
  void _onSave(ControlCubit cubit, {required ControlStatus status}) {
```

- [ ] **Step 8: `add_edit_control_page.dart` — swap `_onStateChange`**

Replace the signature line:
```dart
  Future<void> _onStateChange(BuildContext context, PolicyState state) async {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyControlActionSuccess) {
```
with:
```dart
  Future<void> _onStateChange(BuildContext context, ControlState state) async {
    if (state is ControlLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is ControlActionSuccess) {
```

Then, further down in the same method, replace:
```dart
    if (state is PolicyFailure) {
      showErrorDialog(context: context, subtitle: state.message);
    }
  }
```
with:
```dart
    if (state is ControlFailure) {
      showErrorDialog(context: context, subtitle: state.message);
    }
  }
```

- [ ] **Step 9: `add_edit_control_page.dart` — swap `_buildActionButtons` and the `resolveControlStatus`/`computeDateBasedStatus` call**

Replace:
```dart
  /// The bottom action bar: Discard on the left, and (Save For Later +)
  /// Add/Save on the right. [ctx] is the Builder context that carries the
  /// Policy/Champion/Owner cubits; [cubit] is the already-read PolicyCubit.
  Widget _buildActionButtons(PolicyCubit cubit, BuildContext ctx) {
```
with:
```dart
  /// The bottom action bar: Discard on the left, and (Save For Later +)
  /// Add/Save on the right. [ctx] is the Builder context that carries the
  /// Champion/Owner cubits; [cubit] is the already-read ControlCubit.
  Widget _buildActionButtons(ControlCubit cubit, BuildContext ctx) {
```

Replace:
```dart
          onConfirm: () => _onSave(
            cubit,
            status: cubit.resolveControlStatus(
              requested: cubit.computeDateBasedStatus(_effectiveStartDate),
              manualInactive: _manualInactive,
              hasAnyAssignee: _assignees.hasAnyAssignee(
                context: ctx,
                isEdit: _isEdit,
                policyId: widget.policyId,
                controlId: widget.existingControl?.id ?? '',
              ),
            ),
          ),
```
with:
```dart
          onConfirm: () => _onSave(
            cubit,
            status: ControlStatus.resolve(
              requested: ControlStatus.computeDateBased(_effectiveStartDate),
              manualInactive: _manualInactive,
              hasAnyAssignee: _assignees.hasAnyAssignee(
                context: ctx,
                isEdit: _isEdit,
                policyId: widget.policyId,
                controlId: widget.existingControl?.id ?? '',
              ),
            ),
          ),
```

- [ ] **Step 10: `add_edit_control_page.dart` — swap `build()`**

Replace:
```dart
    // Policy/Champion/Owner cubits are provided by whichever page pushed
    // this route (ControlDetailsPage reuses its own instances via
    // BlocProvider.value; flow-start entry points such as "Add Control"
    // create fresh ones) — this page only ever reads them.
    return Builder(
      builder: (ctx) {
        final cubit = ctx.read<PolicyCubit>();
        return BlocListener<PolicyCubit, PolicyState>(
          listener: _onStateChange,
```
with:
```dart
    // Control/Champion/Owner cubits are provided by whichever page pushed
    // this route (ControlDetailsPage reuses its own instances via
    // BlocProvider.value; flow-start entry points such as "Add Control"
    // create fresh ones) — this page only ever reads them.
    return Builder(
      builder: (ctx) {
        final cubit = ctx.read<ControlCubit>();
        return BlocListener<ControlCubit, ControlState>(
          listener: _onStateChange,
```

- [ ] **Step 11: Verify both files compile clean**

Run:
```bash
/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control/presentation/ui/pages/control_details_page.dart lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart
```
Expected: No issues found (pre-existing unrelated warnings such as `_siblingsWeight`/`_validate` unused-element notices may still appear — those predate this plan and are not in scope; only confirm no NEW errors referencing `PolicyCubit`/`PolicyState`/`PolicyLoading`/etc. remain in these two files).

- [ ] **Step 12: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_details_page.dart lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart
git commit -m "refactor(grc): migrate control_details_page/add_edit_control_page to ControlCubit"
```

---

### Task 5: Migrate `policy_details_page.dart` to add `ControlCubit`

**Files:**
- Modify: `lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart`

**Interfaces:**
- Consumes: `ControlCubit` (Task 2/3).

This page keeps `PolicyCubit` (Policy CRUD) and adds `ControlCubit` alongside it. All `getAllControls` calls and the `PolicyControlsListLoaded` listener branch move to `ControlCubit`/`ControlState`. `_openAddEditControl` currently creates a **fresh** `PolicyCubit` even though the page already holds its own — since that `PolicyCubit` only existed to give `AddEditControlPage` Control operations, this fresh instance is replaced with a **shared** `ControlCubit` (via `.value`), fixing the pre-existing anti-pattern instead of relocating it.

- [ ] **Step 1: Add the import**

Add after the existing `policy_cubit.dart` import:
```dart
import 'package:demo_app/features/grc/control/presentation/controller/control_cubit.dart';
```

- [ ] **Step 2: Provide `ControlCubit` alongside `PolicyCubit` at the page root**

Replace:
```dart
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<PolicyCubit>(),
      child: _PolicyDetailsBody(
        policyId: policyId,
        moduleId: moduleId,
        module: module,
      ),
    );
  }
}
```
with:
```dart
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(
          create: (_) => GetIt.instance<PolicyCubit>(),
        ),
        BlocProvider<ControlCubit>(
          create: (_) => GetIt.instance<ControlCubit>(),
        ),
      ],
      child: _PolicyDetailsBody(
        policyId: policyId,
        moduleId: moduleId,
        module: module,
      ),
    );
  }
}
```

- [ ] **Step 3: Move the `getAllControls` call in `_loadAll`**

Replace:
```dart
  Future<void> _loadAll() async {
    final cubit = context.read<PolicyCubit>();
    await cubit.getPolicy(widget.policyId, moduleId: widget.moduleId);
    await cubit.getAllControls(
      moduleId: widget.moduleId,
      policyId: widget.policyId,
    );
  }
```
with:
```dart
  Future<void> _loadAll() async {
    final cubit = context.read<PolicyCubit>();
    await cubit.getPolicy(widget.policyId, moduleId: widget.moduleId);
    await context.read<ControlCubit>().getAllControls(
          moduleId: widget.moduleId,
          policyId: widget.policyId,
        );
  }
```

- [ ] **Step 4: Split `_onStateChange` — remove the Control branch from the Policy listener**

Replace:
```dart
  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      if (_policy != null) showLoadingIndicator();
      return;
    }
    if (_policy != null) hideLoadingIndicator();

    if (state is PolicySingleLoaded) {
      setState(() => _policy = state.policy);
      return;
    }

    if (state is PolicyControlsListLoaded) {
      setState(() => _controls = state.controls);
      return;
    }

    if (state is PolicyActionSuccess) {
```
with:
```dart
  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      if (_policy != null) showLoadingIndicator();
      return;
    }
    if (_policy != null) hideLoadingIndicator();

    if (state is PolicySingleLoaded) {
      setState(() => _policy = state.policy);
      return;
    }

    if (state is PolicyActionSuccess) {
```

Then, immediately after the closing brace of `_onStateChange` (right after its final `}`), add a new sibling method:
```dart

  void _onControlStateChange(BuildContext context, ControlState state) {
    if (state is ControlLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is ControlsListLoaded) {
      setState(() => _controls = state.controls);
    }
  }
```

- [ ] **Step 5: Fix `_openAddEditControl` to share `ControlCubit` instead of creating a fresh `PolicyCubit`**

Replace:
```dart
  // Flow-start entry point (Add Control / edit-from-list) — there is no
  // ancestor page already holding these cubits, so a fresh set is created
  // here and handed to AddEditControlPage, matching the set ControlDetailsPage
  // provides when its own edit flow pushes the same page.
  Future<void> _openAddEditControl({ControlEntity? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MultiBlocProvider(
          providers: [
            BlocProvider<PolicyCubit>(
              create: (_) => GetIt.instance<PolicyCubit>(),
            ),
            BlocProvider<ChampionCubit>(
              create: (_) => GetIt.instance<ChampionCubit>()
                ..getAllChampions(moduleId: widget.moduleId),
            ),
            BlocProvider<OwnerCubit>(
              create: (_) => GetIt.instance<OwnerCubit>()
                ..getAllOwners(moduleId: widget.moduleId),
            ),
          ],
          child: AddEditControlPage(
            policy: _policy!,
            moduleId: widget.moduleId,
            policyId: widget.policyId,
            existingControl: existing,
            siblingControls: _controls,
            policyStartDate: _policy!.startDate,
            policyEndDate: _policy!.endDate,
            policyHasArabic: _policy!.policyNameAr.trim().isNotEmpty ||
                _policy!.policyNumberAr.trim().isNotEmpty ||
                _policy!.policyDescriptionAr.trim().isNotEmpty,
          ),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      context
          .read<PolicyCubit>()
          .getAllControls(moduleId: widget.moduleId, policyId: widget.policyId);
    }
  }
```
with:
```dart
  // Flow-start entry point (Add Control / edit-from-list). This page already
  // holds its own ControlCubit at the root (see build()), so it's shared via
  // BlocProvider.value rather than resolved fresh — matching the pattern
  // _openEditPolicy above uses for PolicyCubit. ChampionCubit/OwnerCubit have
  // no ancestor here, so those stay fresh, matching the set ControlDetailsPage
  // provides when its own edit flow pushes the same page.
  Future<void> _openAddEditControl({ControlEntity? existing}) async {
    final controlCubit = context.read<ControlCubit>();
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MultiBlocProvider(
          providers: [
            BlocProvider<ControlCubit>.value(value: controlCubit),
            BlocProvider<ChampionCubit>(
              create: (_) => GetIt.instance<ChampionCubit>()
                ..getAllChampions(moduleId: widget.moduleId),
            ),
            BlocProvider<OwnerCubit>(
              create: (_) => GetIt.instance<OwnerCubit>()
                ..getAllOwners(moduleId: widget.moduleId),
            ),
          ],
          child: AddEditControlPage(
            policy: _policy!,
            moduleId: widget.moduleId,
            policyId: widget.policyId,
            existingControl: existing,
            siblingControls: _controls,
            policyStartDate: _policy!.startDate,
            policyEndDate: _policy!.endDate,
            policyHasArabic: _policy!.policyNameAr.trim().isNotEmpty ||
                _policy!.policyNumberAr.trim().isNotEmpty ||
                _policy!.policyDescriptionAr.trim().isNotEmpty,
          ),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      controlCubit.getAllControls(
        moduleId: widget.moduleId,
        policyId: widget.policyId,
      );
    }
  }
```

- [ ] **Step 6: Fix the bulk-upload refresh call**

Replace:
```dart
    if (result == true && mounted) {
      context
          .read<PolicyCubit>()
          .getAllControls(moduleId: widget.moduleId, policyId: widget.policyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PolicyCubit>();
```
with:
```dart
    if (result == true && mounted) {
      context.read<ControlCubit>().getAllControls(
            moduleId: widget.moduleId,
            policyId: widget.policyId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PolicyCubit>();
```

(Note: this `old_string` spans from the end of `_onBulkUploadControls` into the start of `build()` — match it exactly as shown to target the right occurrence, since an identical-looking refresh call also appears in `_openAddEditControl`, already handled in Step 5.)

- [ ] **Step 7: Wrap the page body in a `MultiBlocListener` and wire the new listener**

Replace:
```dart
    return BlocListener<PolicyCubit, PolicyState>(
      listener: _onStateChange,
      child: Scaffold(
```
with:
```dart
    return MultiBlocListener(
      listeners: [
        BlocListener<PolicyCubit, PolicyState>(listener: _onStateChange),
        BlocListener<ControlCubit, ControlState>(
          listener: _onControlStateChange,
        ),
      ],
      child: Scaffold(
```

Since this changes the outer widget from `BlocListener` to `MultiBlocListener`, find the matching closing of that widget (the final `);` that currently closes the `BlocListener(...)` call — it is the very last two lines of `_PolicyDetailsBodyState.build()`, right before that method's own closing `}`. Confirm the file still parses as one expression by running analyze in Step 9 below; if the closing parenthesis needs adjusting, `MultiBlocListener(...)` still takes exactly one `child:` parameter like `BlocListener` did, so no other structural change is needed.

- [ ] **Step 8: Fix the last `getAllControls` call site (`onControlsChanged`)**

Replace:
```dart
                              onControlsChanged: () =>
                                  context.read<PolicyCubit>().getAllControls(
                                        moduleId: widget.moduleId,
                                        policyId: widget.policyId,
                                      ),
```
with:
```dart
                              onControlsChanged: () =>
                                  context.read<ControlCubit>().getAllControls(
                                        moduleId: widget.moduleId,
                                        policyId: widget.policyId,
                                      ),
```

- [ ] **Step 9: Verify it compiles**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart`
Expected: No issues found.

- [ ] **Step 10: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart
git commit -m "refactor(grc): add ControlCubit to policy_details_page, fix fresh-cubit anti-pattern"
```

---

### Task 6: Migrate `create_new_policy.dart` to add `ControlCubit`

**Files:**
- Modify: `lib/features/grc/policy/presentation/ui/pages/create_new_policy.dart`

**Interfaces:**
- Consumes: `ControlCubit` (Task 2/3).

- [ ] **Step 1: Add the import**

Add after the existing `policy_cubit.dart` import:
```dart
import 'package:demo_app/features/grc/control/presentation/controller/control_cubit.dart';
```

- [ ] **Step 2: Split the `PolicyControlsListLoaded` branch out of `_onStateChange`**

Replace:
```dart
    if (state is PolicyControlsListLoaded) {
      if (widget.existingPolicy == null) return;
      _originalControlIds = state.controls.map((c) => c.id).toSet();
      setState(() {
        for (final c in _controls) c.dispose();
        _controls = state.controls.isEmpty
            ? [PolicyControlModel()]
            : state.controls.map(_controlModelFromEntity).toList();
      });
      return;
    }

    if (state is PolicyActionSuccess) {
```
with:
```dart
    if (state is PolicyActionSuccess) {
```

Then, immediately after the closing `}` of `_onStateChange`, add:
```dart

  void _onControlStateChange(BuildContext context, ControlState state) {
    if (state is ControlsListLoaded) {
      if (widget.existingPolicy == null) return;
      _originalControlIds = state.controls.map((c) => c.id).toSet();
      setState(() {
        for (final c in _controls) c.dispose();
        _controls = state.controls.isEmpty
            ? [PolicyControlModel()]
            : state.controls.map(_controlModelFromEntity).toList();
      });
    }
  }
```

- [ ] **Step 3: Provide `ControlCubit` alongside `PolicyCubit` and wire the new listener**

Replace:
```dart
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = GetIt.instance<PolicyCubit>();
        final existing = widget.existingPolicy;
        if (existing != null) {
          cubit.getAllControls(moduleId: widget.moduleId, policyId: existing.id);
        }
        return cubit;
      },
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<PolicyCubit>();
          return BlocListener<PolicyCubit, PolicyState>(
            listener: _onStateChange,
            child: Scaffold(
```
with:
```dart
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(create: (_) => GetIt.instance<PolicyCubit>()),
        BlocProvider<ControlCubit>(
          create: (_) {
            final cubit = GetIt.instance<ControlCubit>();
            final existing = widget.existingPolicy;
            if (existing != null) {
              cubit.getAllControls(
                moduleId: widget.moduleId,
                policyId: existing.id,
              );
            }
            return cubit;
          },
        ),
      ],
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<PolicyCubit>();
          return MultiBlocListener(
            listeners: [
              BlocListener<PolicyCubit, PolicyState>(listener: _onStateChange),
              BlocListener<ControlCubit, ControlState>(
                listener: _onControlStateChange,
              ),
            ],
            child: Scaffold(
```

- [ ] **Step 4: Verify it compiles**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/policy/presentation/ui/pages/create_new_policy.dart`
Expected: No issues found. (If analyze reports a mismatched-parentheses/brace error, check that the `Scaffold(` block's own closing still lines up one level deeper than before — `MultiBlocListener`'s `child:` parameter takes the exact same `Scaffold(...)` subtree `BlocListener`'s did, so only the wrapping widget name and the `providers`/`listeners` list changed, nothing inside `Scaffold(...)` moved.)

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/create_new_policy.dart
git commit -m "refactor(grc): add ControlCubit to create_new_policy"
```

---

### Task 7: Migrate `policy_view_mode_widget.dart`'s standalone entry point

**Files:**
- Modify: `lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart`

**Interfaces:**
- Consumes: `ControlCubit` (Task 2/3).

This is the third (and last) place that pushes `AddEditControlPage`. Unlike Task 5's `_openAddEditControl`, this widget has no ancestor `PolicyCubit`/`ControlCubit` in scope (per its own existing comment), so it keeps creating a **fresh** cubit here — only the type changes from `PolicyCubit` to `ControlCubit`.

- [ ] **Step 1: Swap the import**

Replace:
```dart
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
```
with:
```dart
import 'package:demo_app/features/grc/control/presentation/controller/control_cubit.dart';
```

- [ ] **Step 2: Swap the fresh provider**

Replace:
```dart
      // Flow-start entry point (editing a draft Control straight from the
      // list, bypassing ControlDetailsPage) — no ancestor page already
      // holds these cubits, so a fresh set is created here, same as the
      // "Add Control" entry point in PolicyDetailsPage.
      await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider<PolicyCubit>(
                create: (_) => GetIt.instance<PolicyCubit>(),
              ),
```
with:
```dart
      // Flow-start entry point (editing a draft Control straight from the
      // list, bypassing ControlDetailsPage) — no ancestor page already
      // holds these cubits, so a fresh set is created here, same as the
      // "Add Control" entry point in PolicyDetailsPage.
      await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider<ControlCubit>(
                create: (_) => GetIt.instance<ControlCubit>(),
              ),
```

- [ ] **Step 3: Verify it compiles**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart`
Expected: No issues found. If an `unused_import` warning appears for anything else, leave it (out of scope) unless it references `PolicyCubit`/`PolicyState`, in which case double-check Step 1/2 caught every occurrence with `grep -n "PolicyCubit" lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart` (should return nothing).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart
git commit -m "refactor(grc): migrate policy_view_mode_widget's Control entry point to ControlCubit"
```

---

### Task 8: Remove the now-dead Control surface from `PolicyCubit`/`PolicyState`

**Files:**
- Modify: `lib/features/grc/policy/presentation/controller/policy_cubit.dart`
- Modify: `lib/features/grc/policy/presentation/controller/policy_state.dart`
- Modify: `lib/features/grc/grc_get_it.dart`

**Interfaces:**
- Produces: `PolicyCubit` constructor no longer takes `getAllControlsUseCase`. `PolicyState` no longer has `PolicyControlActionSuccess`/`PolicyControlsListLoaded`/`PolicyControlDeleted`.

Before starting, confirm nothing outside `policy_cubit.dart` itself still references the methods/states being removed:

```bash
grep -rn "\.createControl(\|\.updateControl(\|\.deleteControl(\|\.getAllControls(\|computeDateBasedStatus\|resolveControlStatus\|PolicyControlActionSuccess\|PolicyControlsListLoaded\|PolicyControlDeleted" lib/features/grc --include="*.dart"
```
Expected at this point: the only remaining hits should be inside `policy_cubit.dart`/`policy_state.dart` themselves (the orchestration helpers still legitimately calling `_createControlUseCase`/`_updateControlUseCase`/`_deleteControlUseCase`, which is expected — those three use cases are NOT being removed from `PolicyCubit`) plus the domain/use-case files that define these methods (`create_control_usecase.dart`, etc. — unrelated, do not touch) and `ControlCubit`'s own copies (expected, different class). If anything in another page still shows up, STOP — Tasks 4-7 were not fully applied; go back and fix that file before continuing.

- [ ] **Step 1: Remove the four standalone methods and two business-rule methods from `PolicyCubit`**

In `lib/features/grc/policy/presentation/controller/policy_cubit.dart`, delete this entire block (from the `// CONTROL (standalone — always against an existing Policy)` section header down to the end of `getAllControls`, i.e. everything from `computeDateBasedStatus`'s preceding section through the class's closing brace minus the final `}`):

```dart
  // ================================================================
  // CONTROL (standalone — always against an existing Policy)
  // ================================================================

  Future<void> createControl({
    required String moduleId,
    required String policyId,
    required String controlsNameEn,
    required String controlsNameAr,
    required String controlsNumberEn,
    required String controlsNumberAr,
    required String controlsDescriptionEn,
    required String controlsDescriptionAr,
    required double controlsWeight,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> departments,
    required bool equalWeights,
    required int score,
    required ControlStatus status,
List<double>? departmentsWeights,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final result = await _createControlUseCase.call(
      CreateControlParams(
        moduleId: moduleId,
        policyId: policyId,
        editorId: _currentUserEmail,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsWeight: controlsWeight,

        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        departmentsWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        controlsDocumentFileEn: controlsDocumentFileEn,
        controlsDocumentUrlEn: controlsDocumentUrlEn,
        controlsDocumentFileAr: controlsDocumentFileAr,
        controlsDocumentUrlAr: controlsDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (control) => emit(PolicyControlActionSuccess(control)),
    );
  }

  Future<void> updateControl({
    required String id,
    required String moduleId,
    required String policyId,
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsNumberEn,
    String? controlsNumberAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    double? controlsWeight,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? departments,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    List<double>? departmentsWeights,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final result = await _updateControlUseCase.call(
      UpdateControlParams(
        id: id,
        moduleId: moduleId,
        policyId: policyId,
        editorId: _currentUserEmail,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        
        departments: departments,
        departmentsWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        controlsDocumentFileEn: controlsDocumentFileEn,
        controlsDocumentUrlEn: controlsDocumentUrlEn,
        controlsDocumentFileAr: controlsDocumentFileAr,
        controlsDocumentUrlAr: controlsDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (control) => emit(PolicyControlActionSuccess(control)),
    );
  }

  /// Date-based "would-be" status before any assignee/manual override:
  /// Scheduled if [effectiveStartDate] hasn't arrived yet (strictly after the
  /// start of today), otherwise Active. Moved verbatim from
  /// AddEditControlPage's former `_computedStatus` getter — the caller passes
  /// the effective start date (inherited Policy date in Create mode, the
  /// control's own edited date in Edit mode).
  ControlStatus computeDateBasedStatus(DateTime effectiveStartDate) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return effectiveStartDate.isAfter(startOfToday)
        ? ControlStatus.scheduled
        : ControlStatus.active;
  }

  /// Applies the manual-Inactive and assignee-based overrides on top of
  /// [requested]: Draft (Save For Later) always wins as-is. Otherwise, if the
  /// user flipped the "Status" switch to Inactive ([manualInactive]), that
  /// wins next. Failing both, any other status becomes Unassigned unless at
  /// least one Champion or Owner is currently assigned ([hasAnyAssignee]), in
  /// which case [requested] (the date-computed Scheduled/Active) stands.
  /// Moved verbatim from AddEditControlPage's former `_resolvedStatus`; the
  /// `_hasAnyAssignee` check it used to call is now resolved by the caller and
  /// passed in as [hasAnyAssignee].
  ControlStatus resolveControlStatus({
    required ControlStatus requested,
    required bool manualInactive,
    required bool hasAnyAssignee,
  }) {
    if (requested == ControlStatus.draft) return requested;
    if (manualInactive) return ControlStatus.inactive;
    return hasAnyAssignee ? requested : ControlStatus.unassigned;
  }

  Future<void> deleteControl({
    required String id,
    required String moduleId,
    required String policyId,
  }) async {
    emit(PolicyLoading());
    final result = await _deleteControlUseCase.call(
      DeleteControlParams(id: id, moduleId: moduleId, policyId: policyId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (_) => emit(PolicyControlDeleted(id)),
    );
  }

  Future<void> getAllControls({
    required String moduleId,
    required String policyId,
  }) async {
    emit(PolicyLoading());
    final result = await _getAllControlsUseCase.call(
      moduleId: moduleId,
      policyId: policyId,
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (controls) => emit(PolicyControlsListLoaded(controls)),
    );
  }
}
```

Replace it with just the class's closing brace:
```dart
}
```

- [ ] **Step 2: Remove the now-unused `getAllControlsUseCase` constructor parameter**

Replace:
```dart
class PolicyCubit extends Cubit<PolicyState> {
  PolicyCubit({
    required CreatePolicyUseCase createPolicyUseCase,
    required GetPolicyUseCase getPolicyUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
    required DeletePolicyUseCase deletePolicyUseCase,
    required RestorePolicyUseCase restorePolicyUseCase,
    required CreateControlUseCase createControlUseCase,
    required UpdateControlUseCase updateControlUseCase,
    required DeleteControlUseCase deleteControlUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _createUseCase = createPolicyUseCase,
        _getUseCase = getPolicyUseCase,
        _getAllUseCase = getAllPoliciesUseCase,
        _updateUseCase = updatePolicyUseCase,
        _deleteUseCase = deletePolicyUseCase,
        _restoreUseCase = restorePolicyUseCase,
        _createControlUseCase = createControlUseCase,
        _updateControlUseCase = updateControlUseCase,
        _deleteControlUseCase = deleteControlUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        super(PolicyInitial());

  final CreatePolicyUseCase _createUseCase;
  final GetPolicyUseCase _getUseCase;
  final GetAllPoliciesUseCase _getAllUseCase;
  final UpdatePolicyUseCase _updateUseCase;
  final DeletePolicyUseCase _deleteUseCase;
  final RestorePolicyUseCase _restoreUseCase;
  final CreateControlUseCase _createControlUseCase;
  final UpdateControlUseCase _updateControlUseCase;
  final DeleteControlUseCase _deleteControlUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
```
with:
```dart
class PolicyCubit extends Cubit<PolicyState> {
  PolicyCubit({
    required CreatePolicyUseCase createPolicyUseCase,
    required GetPolicyUseCase getPolicyUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
    required DeletePolicyUseCase deletePolicyUseCase,
    required RestorePolicyUseCase restorePolicyUseCase,
    required CreateControlUseCase createControlUseCase,
    required UpdateControlUseCase updateControlUseCase,
    required DeleteControlUseCase deleteControlUseCase,
  })  : _createUseCase = createPolicyUseCase,
        _getUseCase = getPolicyUseCase,
        _getAllUseCase = getAllPoliciesUseCase,
        _updateUseCase = updatePolicyUseCase,
        _deleteUseCase = deletePolicyUseCase,
        _restoreUseCase = restorePolicyUseCase,
        _createControlUseCase = createControlUseCase,
        _updateControlUseCase = updateControlUseCase,
        _deleteControlUseCase = deleteControlUseCase,
        super(PolicyInitial());

  final CreatePolicyUseCase _createUseCase;
  final GetPolicyUseCase _getUseCase;
  final GetAllPoliciesUseCase _getAllUseCase;
  final UpdatePolicyUseCase _updateUseCase;
  final DeletePolicyUseCase _deleteUseCase;
  final RestorePolicyUseCase _restoreUseCase;
  final CreateControlUseCase _createControlUseCase;
  final UpdateControlUseCase _updateControlUseCase;
  final DeleteControlUseCase _deleteControlUseCase;
```

- [ ] **Step 3: Update the class doc comment and revision history**

Replace:
```dart
/// Module: Policy Management
/// Description: BLoC Cubit that manages Policy and Control state for the
///              presentation layer. Delegates all operations to the
///              corresponding use cases and emits typed [PolicyState]
///              subclasses. Owns both Policy and Control operations (one
///              cubit for this feature) because the Create-Policy UI treats
///              "policy + its initial controls" as a single user action.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-05
/// Dependencies: flutter_bloc, use cases, PolicyEntity, ControlEntity
/// Revision History: 2026-07-05 - Initial creation
///                   2026-07-06 - Added saveAsDraft and status-aware methods
///                   2026-07-14 - Reworked for the new schema: Policy
///                                creation no longer bundles Controls at the
///                                repository level (see
///                                _createPolicyWithControls for the
///                                orchestration), split single document
///                                fields into En/Ar, added standalone
///                                Control methods (createControl/
///                                updateControl/deleteControl/getAllControls)
library;
```
with:
```dart
/// Module: Policy Management
/// Description: BLoC Cubit that manages Policy state for the presentation
///              layer. Delegates all operations to the corresponding use
///              cases and emits typed [PolicyState] subclasses. Still holds
///              a direct dependency on CreateControlUseCase/
///              UpdateControlUseCase/DeleteControlUseCase for
///              createPolicy/saveAsDraft/updatePolicyWithControls, which
///              treat "Policy + its bundled initial Controls" as one wizard
///              action — that's a Policy-workflow concern, not Control
///              state, so it stays here rather than moving to ControlCubit
///              (see docs/superpowers/specs/2026-07-28-control-cubit-extraction-design.md).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-05
/// Dependencies: flutter_bloc, use cases, PolicyEntity, ControlEntity
/// Revision History: 2026-07-05 - Initial creation
///                   2026-07-06 - Added saveAsDraft and status-aware methods
///                   2026-07-14 - Reworked for the new schema: Policy
///                                creation no longer bundles Controls at the
///                                repository level (see
///                                _createPolicyWithControls for the
///                                orchestration), split single document
///                                fields into En/Ar
///                   2026-07-28 - Extracted the standalone Control methods
///                                (createControl/updateControl/
///                                deleteControl/getAllControls) and the
///                                two ControlStatus business-rule helpers
///                                into ControlCubit/ControlStatus
library;
```

- [ ] **Step 4: Remove the three Control states from `PolicyState`**

In `lib/features/grc/policy/presentation/controller/policy_state.dart`, replace:
```dart
/// State emitted when any operation fails.
final class PolicyFailure extends PolicyState {
  final String message;

  PolicyFailure(this.message);
}

/// State emitted when a single Control create/update completes successfully.
final class PolicyControlActionSuccess extends PolicyState {
  final ControlEntity control;

  PolicyControlActionSuccess(this.control);
}

/// State emitted when a Policy's Controls have been fetched successfully.
final class PolicyControlsListLoaded extends PolicyState {
  final List<ControlEntity> controls;

  PolicyControlsListLoaded(this.controls);
}

/// State emitted when a Control has been deleted successfully.
final class PolicyControlDeleted extends PolicyState {
  final String controlId;

  PolicyControlDeleted(this.controlId);
}
```
with:
```dart
/// State emitted when any operation fails.
final class PolicyFailure extends PolicyState {
  final String message;

  PolicyFailure(this.message);
}
```

Also update the file header comment — replace:
```dart
/// Revision History: 2026-07-14 - Added PolicyActionPartialSuccess,
///                                PolicyControlActionSuccess,
///                                PolicyControlsListLoaded,
///                                PolicyControlDeleted for the Control side
///                                of PolicyCubit
```
with:
```dart
/// Revision History: 2026-07-14 - Added PolicyActionPartialSuccess
///                   2026-07-28 - Removed PolicyControlActionSuccess/
///                                PolicyControlsListLoaded/
///                                PolicyControlDeleted — moved to
///                                ControlState (ControlCubit extraction)
```

- [ ] **Step 5: Check whether `ControlEntity` is still imported/used in `policy_state.dart`**

Run:
```bash
grep -n "ControlEntity" lib/features/grc/policy/presentation/controller/policy_state.dart
```
If no `ControlEntity` occurrence remains (expected, since it was only used by the three removed states), remove any now-unused import in `policy_cubit.dart` for it — but check first, since `PolicyActionPartialSuccess.failedControls` uses `PendingControlInput`, not `ControlEntity`, so `control_entity.dart`'s import in `policy_cubit.dart` may still be needed elsewhere in that file (e.g. `_upsertControlForUpdate`'s return type `Either<Failure, ControlEntity>`). Confirm with:
```bash
grep -n "ControlEntity" lib/features/grc/policy/presentation/controller/policy_cubit.dart
```
Only remove the `import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';` line if this grep returns nothing.

- [ ] **Step 6: Remove `getAllControlsUseCase` from `PolicyCubit`'s GetIt registration**

In `lib/features/grc/grc_get_it.dart`, replace:
```dart
  sl.registerFactory<PolicyCubit>(
    () => PolicyCubit(
      createPolicyUseCase: sl<CreatePolicyUseCase>(),
      getPolicyUseCase: sl<GetPolicyUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      deletePolicyUseCase: sl<DeletePolicyUseCase>(),
      restorePolicyUseCase: sl<RestorePolicyUseCase>(),
      createControlUseCase: sl<CreateControlUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
      deleteControlUseCase: sl<DeleteControlUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );
```
with:
```dart
  sl.registerFactory<PolicyCubit>(
    () => PolicyCubit(
      createPolicyUseCase: sl<CreatePolicyUseCase>(),
      getPolicyUseCase: sl<GetPolicyUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      deletePolicyUseCase: sl<DeletePolicyUseCase>(),
      restorePolicyUseCase: sl<RestorePolicyUseCase>(),
      createControlUseCase: sl<CreateControlUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
      deleteControlUseCase: sl<DeleteControlUseCase>(),
    ),
  );
```

- [ ] **Step 7: Verify everything still compiles**

Run:
```bash
/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/policy/presentation/controller/policy_cubit.dart lib/features/grc/policy/presentation/controller/policy_state.dart lib/features/grc/grc_get_it.dart
```
Expected: No issues found.

- [ ] **Step 8: Commit**

```bash
git add lib/features/grc/policy/presentation/controller/policy_cubit.dart lib/features/grc/policy/presentation/controller/policy_state.dart lib/features/grc/grc_get_it.dart
git commit -m "refactor(grc): remove dead standalone Control surface from PolicyCubit/PolicyState"
```

---

### Task 9: Full verification

**Files:** none (verification only)

- [ ] **Step 1: Analyze the whole `control` and `policy` feature folders**

```bash
/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control lib/features/grc/policy lib/features/grc/grc_get_it.dart
```
Expected: no errors. Any warnings must be pre-existing (compare against `git stash`-ing this branch's changes and re-running if in doubt — see how the earlier assert-to-ArgumentError fix in this same codebase verified pre-existing warnings this same way).

- [ ] **Step 2: Run the full test suite touched by this plan**

```bash
/Users/bstar/.puro/bin/puro flutter test test/features/grc/control/domain/entities/control_status_test.dart test/features/grc/control/presentation/controller/control_cubit_test.dart
```
Expected: all tests pass (7 + 8 = 15 tests).

- [ ] **Step 3: Grep for any leftover reference to the removed API**

```bash
grep -rn "PolicyControlActionSuccess\|PolicyControlsListLoaded\|PolicyControlDeleted\|computeDateBasedStatus\|resolveControlStatus" lib/features/grc --include="*.dart"
```
Expected: no output at all.

- [ ] **Step 4: Manual smoke-test checklist (once a Flutter environment/emulator is available)**

Record these as manual QA steps for a human (or a `/run`-driven session) to execute — do not mark this step done without actually running the app:
1. Open a Policy that has at least one Control → Control list renders.
2. Tap a Control → `ControlDetailsPage` opens with correct data.
3. Edit that Control (change the name) → Save → returns to details with updated name, list still correct on going back to Policy Details.
4. Delete a Control → confirm dialog → success dialog → returns to Policy Details with the Control removed from the list.
5. From Policy Details, use "Add Control" → create a new Control → returns and the new Control appears in the list.
6. Create a brand-new Policy with at least one initial Control via the Create New Policy wizard → Publish → Policy and its Control(s) both appear correctly.
7. Resume an existing Draft Policy in the wizard → its previously-saved Controls prefill correctly (exercises `create_new_policy.dart`'s `ControlCubit.getAllControls` call in `initState`/`BlocProvider.create`).

- [ ] **Step 5: Final commit (if Step 4 surfaces any fix)**

Only if Step 4 finds a regression: fix it, re-run Steps 1-3, then commit with a message describing the specific fix. If Step 4 finds nothing, no commit is needed for this task — Task 8's commit is the last one.

---

## Self-Review Notes (for whoever executes this plan)

- Spec coverage: every "New/changed pieces" bullet in the design spec maps to a task above (ControlStatus → Task 1; ControlCubit/ControlState → Task 2; DI → Task 3; control_details_page.dart/add_edit_control_page.dart → Task 4; policy_details_page.dart (incl. the `_openAddEditControl` anti-pattern fix) → Task 5; create_new_policy.dart → Task 6; policy_view_mode_widget.dart → Task 7; PolicyCubit/PolicyState cleanup + DI cleanup → Task 8; testing → Tasks 1, 2, 9).
- The `_currentUserEmail` getter is intentionally duplicated into `ControlCubit` (Task 2) rather than removed from `PolicyCubit` — both cubits need it independently; this was not explicit in the design spec (a presentation-layer implementation detail correctly deferred to the plan) but is called out here to avoid it being missed or misread as "move, don't duplicate."
- Task ordering keeps the codebase compiling at every commit: additive first (Tasks 1-3), then consumers migrated one at a time while `PolicyCubit`'s old methods still exist unused (Tasks 4-7), then dead code removed last (Task 8), then full verification (Task 9).
