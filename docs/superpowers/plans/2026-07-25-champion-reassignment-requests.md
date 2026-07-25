# Champion Reassignment Requests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn "Reassign Control Champion" into a request/approval workflow — creating a request instead of an immediate change, deferring the actual control transfer until the request's Start Date arrives (recompute-on-read, no cron), auto-expiring the new champion's controls at End Date, and wiring the previously-stubbed "Requests" button to a new list/details/approve/reject UI.

**Architecture:** New `lib/features/grc/grc_request/` sub-feature, Clean Architecture (data source → model → repository → use cases → cubit), mirroring `lib/features/grc/control_champion/` exactly. `AssigningControlEntity`/`AssigningControlModel` gain a nullable `expiresOn` field. A new pure-function resolver (`champion_request_resolver.dart`, mirroring `control_status_resolver.dart`'s style) decides which approved requests are due and which assigned controls have expired; `ChampionCubit.getAllChampions()` runs that resolver and persists the resulting changes before emitting, exactly like every other "future date" case in this app.

**Tech Stack:** Flutter, `flutter_bloc` (Cubit, `sealed class` states, no `Equatable`), `get_it` (`GetIt.instance<T>()`, no global `sl`), `dartz` (`Either<Failure, T>`), `cloud_firestore`, `intl` for date (de)serialization.

## Global Constraints

- Every new class/file gets the same doc-comment header style already used across `lib/features/grc/control_champion/` (`/// Module:`, `/// Description:`, `/// Author:`, `/// Date: 2026-07-25`, `/// Dependencies:`).
- No test infrastructure exists in this repo (no mocktail/bloc_test, one placeholder `test/widget_test.dart`) and no prior GRC sub-feature added any — per explicit user decision, this plan does **not** add test infra. Each task's verification step is `flutter analyze` (must be clean for the touched files) plus a concrete manual check (either a Dart-level sanity check via a throwaway `main()` print, or exercising the running app) — not an automated unit test.
- Firestore paths follow the existing per-module nesting convention: `GRC Modules/{Module_ID}/<Subcollection>/{doc_id}`, built via `getBaseUrl('Modules')` from `lib/core/network/get_base_url.dart`.
- Use `GetIt.instance<T>()` for all DI resolution (no global `sl` variable exists in this codebase outside the parameter name inside `setupGRCDependencies`).
- Reuse `ApprovalStatus` from `lib/core/enums/approval_status.dart` for request status — do not create a parallel status enum.
- Reuse `showCommentDialog` and `showConfirmDialog` from `lib/core/custom/11_custom_confirm_diaolog.dart` for reject/approve confirmation — do not build new dialogs.
- Reuse `GrcOwnerBadge` (`lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart`) for the "Department Manager" display, fed from `GRCModuleEntity.moduleOwners`.
- `controlChanges` is a reserved `GrcRequestType` enum value only — no creation flow, no fields, no business logic. If ever opened, its details view is a one-line "not supported" placeholder.

---

## Task 1: Add `expiresOn` to `AssigningControlEntity` and `AssigningControlModel`

**Files:**
- Modify: `lib/features/grc/control/domain/entities/assigning_control.dart`
- Modify: `lib/features/grc/control/data/models/assigning_control_model.dart`

**Interfaces:**
- Produces: `AssigningControlEntity(policyId, controlId, expiresOn)` with a `copyWith({policyId, controlId, expiresOn})` method (new — none existed before); `AssigningControlModel(policyId, controlId, expiresOn)` with matching `toJson`/`fromJson`/`toEntity`.

- [ ] **Step 1: Update `AssigningControlEntity`**

Replace the full contents of `lib/features/grc/control/domain/entities/assigning_control.dart` with:

```dart
class AssigningControlEntity {
  final String policyId;
  final String controlId;
  final DateTime? expiresOn;

  const AssigningControlEntity({
    required this.policyId,
    required this.controlId,
    this.expiresOn,
  });

  AssigningControlEntity copyWith({
    String? policyId,
    String? controlId,
    DateTime? expiresOn,
  }) {
    return AssigningControlEntity(
      policyId: policyId ?? this.policyId,
      controlId: controlId ?? this.controlId,
      expiresOn: expiresOn ?? this.expiresOn,
    );
  }
}
```

- [ ] **Step 2: Update `AssigningControlModel`**

Replace the full contents of `lib/features/grc/control/data/models/assigning_control_model.dart` with:

```dart
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:intl/intl.dart';

final DateFormat _assigningControlDateFormat = DateFormat('d MMM yyyy', 'en');

class AssigningControlModel {
  final String policyId;
  final String controlId;
  final DateTime? expiresOn;

  const AssigningControlModel({
    required this.policyId,
    required this.controlId,
    this.expiresOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'Policy_ID': policyId,
      'Control_ID': controlId,
      'Expires_On':
          expiresOn != null ? _assigningControlDateFormat.format(expiresOn!) : null,
    };
  }

  factory AssigningControlModel.fromJson(Map<String, dynamic> json) {
    final expiresOnRaw = json['Expires_On'] as String?;
    return AssigningControlModel(
      policyId: json['Policy_ID'] as String,
      controlId: json['Control_ID'] as String,
      expiresOn:
          expiresOnRaw != null ? _assigningControlDateFormat.parse(expiresOnRaw) : null,
    );
  }

  AssigningControlEntity toEntity() {
    return AssigningControlEntity(
      policyId: policyId,
      controlId: controlId,
      expiresOn: expiresOn,
    );
  }
}
```

Note: `lib/features/grc/control_champion/data/models/champion_model.dart:112-114` calls `AssigningControlModel.fromJson(item as Map<String, dynamic>)` and `champion_repository_impl.dart:27` constructs `AssigningControlModel(policyId: ..., controlId: ...)` with only 2 named args — both remain valid since `expiresOn` is optional and not required. No other call site needs to change for this task.

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/features/grc/control/`
Expected: No new errors (existing code that constructs `AssigningControlEntity`/`AssigningControlModel` with only `policyId`/`controlId` still compiles since `expiresOn` is optional).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/domain/entities/assigning_control.dart lib/features/grc/control/data/models/assigning_control_model.dart
git commit -m "feat(grc): add optional expiresOn to AssigningControlEntity/Model"
```

---

## Task 2: `GrcRequestType` enum

**Files:**
- Create: `lib/features/grc/grc_request/domain/entities/grc_request_type.dart`

**Interfaces:**
- Produces: `enum GrcRequestType { reassignChampion, controlChanges }` with `.value` (String) and `.fromString(String)`.

- [ ] **Step 1: Write the file**

```dart
/// Module: GRC Request Management
/// Description: Discriminates what kind of GRC approval request a
///              GrcRequestEntity represents. Only [reassignChampion] has a
///              working creation flow / business logic in this feature —
///              [controlChanges] is reserved for a future feature and must
///              not be given speculative fields or logic.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: None

enum GrcRequestType {
  reassignChampion,
  controlChanges;

  String get value {
    switch (this) {
      case GrcRequestType.reassignChampion:
        return 'Reassign Control Champion';
      case GrcRequestType.controlChanges:
        return 'Control Changes';
    }
  }

  static GrcRequestType fromString(String value) {
    switch (value) {
      case 'Control Changes':
        return GrcRequestType.controlChanges;
      case 'Reassign Control Champion':
      default:
        return GrcRequestType.reassignChampion;
    }
  }
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/features/grc/grc_request/`
Expected: Clean (no errors on this new file).

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/grc_request/domain/entities/grc_request_type.dart
git commit -m "feat(grc): add GrcRequestType enum"
```

---

## Task 3: `GrcRequestEntity`

**Files:**
- Create: `lib/features/grc/grc_request/domain/entities/grc_request_entity.dart`

**Interfaces:**
- Consumes: `GrcRequestType` (Task 2), `ApprovalStatus` (`lib/core/enums/approval_status.dart`), `AssigningControlEntity` (Task 1).
- Produces: `GrcRequestEntity` with all fields listed below — later tasks (repository, model, cubit, UI) construct and read this exact shape.

- [ ] **Step 1: Write the file**

```dart
/// Module: GRC Request Management
/// Description: Flat (non-list, non-history) representation of a GRC
///              approval request — currently only populated for
///              GrcRequestType.reassignChampion. The reassign-specific
///              fields are nullable because a future controlChanges
///              request would not use them.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: GrcRequestType, ApprovalStatus, AssigningControlEntity

import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';

class GrcRequestEntity {
  final String id;
  final String moduleId;
  final GrcRequestType type;
  final ApprovalStatus status;
  final String requestedBy;
  final DateTime requestDate;
  final String note;

  // Decision metadata — null until approved/rejected
  final String? rejectionReason;
  final String? decidedBy;
  final DateTime? decisionDate;

  // Reassign-specific (null/unused for other request types)
  final String? currentChampionEmail;
  final String? newChampionEmail;
  final List<AssigningControlEntity>? controls;
  final DateTime? startDate;
  final DateTime? endDate;

  // Set once the recompute-on-read transfer has actually run
  final DateTime? appliedAt;

  const GrcRequestEntity({
    required this.id,
    required this.moduleId,
    required this.type,
    required this.status,
    required this.requestedBy,
    required this.requestDate,
    required this.note,
    this.rejectionReason,
    this.decidedBy,
    this.decisionDate,
    this.currentChampionEmail,
    this.newChampionEmail,
    this.controls,
    this.startDate,
    this.endDate,
    this.appliedAt,
  });
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/features/grc/grc_request/`
Expected: Clean.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/grc_request/domain/entities/grc_request_entity.dart
git commit -m "feat(grc): add GrcRequestEntity"
```

---

## Task 4: `GrcRequestRepository` interface

**Files:**
- Create: `lib/features/grc/grc_request/domain/repository/grc_request_repository.dart`

**Interfaces:**
- Consumes: `GrcRequestEntity` (Task 3), `GrcRequestType` (Task 2), `AssigningControlEntity`, `Failure`/`Either` (`lib/core/network/failure_model.dart`, `dartz`).
- Produces: `GrcRequestRepository` abstract methods used by every use case in Task 6 and by `GrcRequestRepositoryImpl` in Task 5.

- [ ] **Step 1: Write the file**

```dart
/// Module: GRC Request Management
/// Description: Domain-layer repository contract for GRC approval
///              requests. Knows only about Entities and Failures.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestType, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';

abstract class GrcRequestRepository {
  Future<Either<Failure, GrcRequestEntity>> createReassignChampionRequest({
    required String moduleId,
    required String requestedBy,
    required String note,
    required String currentChampionEmail,
    required String newChampionEmail,
    required List<AssigningControlEntity> controls,
    required DateTime startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, List<GrcRequestEntity>>> getRequestsForModule(
    String moduleId,
  );

  Future<Either<Failure, GrcRequestEntity>> approveRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
  });

  Future<Either<Failure, GrcRequestEntity>> rejectRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
    required String reason,
  });

  Future<Either<Failure, GrcRequestEntity>> markApplied({
    required String moduleId,
    required String requestId,
  });
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/features/grc/grc_request/`
Expected: Clean.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/grc_request/domain/repository/grc_request_repository.dart
git commit -m "feat(grc): add GrcRequestRepository contract"
```

---

## Task 5: `GrcRequestModel`, `GrcRequestDataSource`, `GrcRequestFirebaseDataSource`, `GrcRequestRepositoryImpl`

**Files:**
- Create: `lib/features/grc/grc_request/data/models/grc_request_model.dart`
- Create: `lib/features/grc/grc_request/data/data_source/grc_request_data_source.dart`
- Create: `lib/features/grc/grc_request/data/data_source/grc_request_firebase_data_source.dart`
- Create: `lib/features/grc/grc_request/data/repository/grc_request_repository_impl.dart`

**Interfaces:**
- Consumes: `GrcRequestEntity`/`GrcRequestType` (Tasks 2-3), `GrcRequestRepository` (Task 4), `AssigningControlModel`/`AssigningControlEntity` (Task 1), `ApprovalStatus`, `Failure`.
- Produces: `GrcRequestModel.toEntity()`/`.fromJson()`/`.toJson()`; `GrcRequestFirebaseDataSource` (Firestore path `GRC Modules/{moduleId}/Champion Requests/{requestId}`, auto-id on create); `GrcRequestRepositoryImpl` implementing every `GrcRequestRepository` method — consumed by Task 6's use cases and Task 10's DI registration.

- [ ] **Step 1: Write `GrcRequestModel`**

A request is a single decided event (create → optionally approve/reject once), unlike Champion/Policy's history-list-of-lists — a plain document is enough, per the design spec.

```dart
/// Module: GRC Request Management
/// Description: Firestore model for a GRC approval request. Unlike
///              ChampionModel/PolicyModel, this is NOT a history list — a
///              request is a single decided event (create, then optionally
///              approve/reject once), so its status/decision fields are
///              plain mutable values, not append-only revision lists.
///              Firestore path: GRC Modules/{Module_ID}/Champion Requests/{Request_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: AssigningControlModel, GrcRequestEntity, GrcRequestType, ApprovalStatus, intl

import 'package:intl/intl.dart';
import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/features/grc/control/data/models/assigning_control_model.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';

final DateFormat _requestDateFormat = DateFormat('d MMM yyyy', 'en');

class GrcRequestModel {
  final String id;
  final String moduleId;
  final String type; // GrcRequestType.value
  final String status; // 'pending' | 'approved' | 'rejected'
  final String requestedBy;
  final DateTime requestDate;
  final String note;

  final String? rejectionReason;
  final String? decidedBy;
  final DateTime? decisionDate;

  final String? currentChampionEmail;
  final String? newChampionEmail;
  final List<AssigningControlModel>? controls;
  final DateTime? startDate;
  final DateTime? endDate;

  final DateTime? appliedAt;

  const GrcRequestModel({
    required this.id,
    required this.moduleId,
    required this.type,
    required this.status,
    required this.requestedBy,
    required this.requestDate,
    required this.note,
    this.rejectionReason,
    this.decidedBy,
    this.decisionDate,
    this.currentChampionEmail,
    this.newChampionEmail,
    this.controls,
    this.startDate,
    this.endDate,
    this.appliedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'Request_ID': id,
      'Module_ID': moduleId,
      'Type': type,
      'Status': status,
      'Requested_By': requestedBy,
      'Request_Date': _requestDateFormat.format(requestDate),
      'Note': note,
      'Rejection_Reason': rejectionReason,
      'Decided_By': decidedBy,
      'Decision_Date':
          decisionDate != null ? _requestDateFormat.format(decisionDate!) : null,
      'Current_Champion_Email': currentChampionEmail,
      'New_Champion_Email': newChampionEmail,
      'Controls': controls?.map((c) => c.toJson()).toList(),
      'Start_Date': startDate != null ? _requestDateFormat.format(startDate!) : null,
      'End_Date': endDate != null ? _requestDateFormat.format(endDate!) : null,
      'Applied_At': appliedAt != null ? _requestDateFormat.format(appliedAt!) : null,
    };
  }

  factory GrcRequestModel.fromJson(Map<String, dynamic> json) {
    final decisionDateRaw = json['Decision_Date'] as String?;
    final startDateRaw = json['Start_Date'] as String?;
    final endDateRaw = json['End_Date'] as String?;
    final appliedAtRaw = json['Applied_At'] as String?;
    return GrcRequestModel(
      id: json['Request_ID'] as String,
      moduleId: json['Module_ID'] as String,
      type: json['Type'] as String,
      status: json['Status'] as String,
      requestedBy: json['Requested_By'] as String,
      requestDate: _requestDateFormat.parse(json['Request_Date'] as String),
      note: json['Note'] as String? ?? '',
      rejectionReason: json['Rejection_Reason'] as String?,
      decidedBy: json['Decided_By'] as String?,
      decisionDate:
          decisionDateRaw != null ? _requestDateFormat.parse(decisionDateRaw) : null,
      currentChampionEmail: json['Current_Champion_Email'] as String?,
      newChampionEmail: json['New_Champion_Email'] as String?,
      controls: (json['Controls'] as List?)
          ?.map((c) => AssigningControlModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      startDate: startDateRaw != null ? _requestDateFormat.parse(startDateRaw) : null,
      endDate: endDateRaw != null ? _requestDateFormat.parse(endDateRaw) : null,
      appliedAt: appliedAtRaw != null ? _requestDateFormat.parse(appliedAtRaw) : null,
    );
  }

  GrcRequestEntity toEntity() {
    return GrcRequestEntity(
      id: id,
      moduleId: moduleId,
      type: GrcRequestType.fromString(type),
      status: ApprovalStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => ApprovalStatus.pending,
      ),
      requestedBy: requestedBy,
      requestDate: requestDate,
      note: note,
      rejectionReason: rejectionReason,
      decidedBy: decidedBy,
      decisionDate: decisionDate,
      currentChampionEmail: currentChampionEmail,
      newChampionEmail: newChampionEmail,
      controls: controls?.map((c) => c.toEntity()).toList(),
      startDate: startDate,
      endDate: endDate,
      appliedAt: appliedAt,
    );
  }
}
```

Note: `status` is persisted via `ApprovalStatus.name` (i.e. `'pending'`/`'approved'`/`'rejected'`), not `.getName` (which is a display label like `'Pending'`) — the model's `toJson`/reading code below in Task 6 must use `.name` consistently.

- [ ] **Step 2: Write `GrcRequestDataSource`**

```dart
/// Module: GRC Request Management
/// Description: Data source contract for GRC Request CRUD operations,
///              independent of any specific backend.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: GrcRequestModel

import 'package:demo_app/features/grc/grc_request/data/models/grc_request_model.dart';

abstract class GrcRequestDataSource {
  Future<GrcRequestModel> create(GrcRequestModel model, {required String moduleId});

  Future<List<GrcRequestModel>> getAll({required String moduleId});

  Future<GrcRequestModel> update(GrcRequestModel updatedModel, {required String moduleId});
}
```

- [ ] **Step 3: Write `GrcRequestFirebaseDataSource`**

```dart
/// Module: GRC Request Management
/// Description: Cloud Firestore implementation of [GrcRequestDataSource].
///              Firestore path: GRC Modules/{Module_ID}/Champion Requests/{Request_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: cloud_firestore, GrcRequestDataSource, GrcRequestModel

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/features/grc/grc_request/data/models/grc_request_model.dart';

import 'grc_request_data_source.dart';

class GrcRequestFirebaseDataSource implements GrcRequestDataSource {
  GrcRequestFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath =>
      '${getBaseUrl('Modules')}/grc/GRC Modules';
  static const String _requestsSubcollectionPath = 'Champion Requests';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_requestsSubcollectionPath);

  @override
  Future<GrcRequestModel> create(
    GrcRequestModel model, {
    required String moduleId,
  }) async {
    try {
      final docRef = _collection(moduleId).doc();
      final withId = GrcRequestModel(
        id: docRef.id,
        moduleId: model.moduleId,
        type: model.type,
        status: model.status,
        requestedBy: model.requestedBy,
        requestDate: model.requestDate,
        note: model.note,
        rejectionReason: model.rejectionReason,
        decidedBy: model.decidedBy,
        decisionDate: model.decisionDate,
        currentChampionEmail: model.currentChampionEmail,
        newChampionEmail: model.newChampionEmail,
        controls: model.controls,
        startDate: model.startDate,
        endDate: model.endDate,
        appliedAt: model.appliedAt,
      );
      await docRef.set(withId.toJson());
      return withId;
    } catch (e) {
      throw Exception('Failed to create the GRC Request: $e');
    }
  }

  @override
  Future<List<GrcRequestModel>> getAll({required String moduleId}) async {
    try {
      final snapshot = await _collection(moduleId).get();
      return snapshot.docs
          .map((doc) => GrcRequestModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch the GRC Requests: $e');
    }
  }

  @override
  Future<GrcRequestModel> update(
    GrcRequestModel updatedModel, {
    required String moduleId,
  }) async {
    try {
      final docRef = _collection(moduleId).doc(updatedModel.id);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a GRC Request that does not exist (id: ${updatedModel.id})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the GRC Request: $e');
    }
  }
}
```

- [ ] **Step 4: Write `GrcRequestRepositoryImpl`**

```dart
/// Module: GRC Request Management
/// Description: Data-layer implementation of [GrcRequestRepository]. Maps
///              between Models (persistence) and Entities (domain), and
///              wraps every result in Either<Failure, T>.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, GrcRequestRepository, GrcRequestFirebaseDataSource, GrcRequestModel

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/control/data/models/assigning_control_model.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/grc_request/data/data_source/grc_request_firebase_data_source.dart';
import 'package:demo_app/features/grc/grc_request/data/models/grc_request_model.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class GrcRequestRepositoryImpl implements GrcRequestRepository {
  GrcRequestRepositoryImpl({required GrcRequestFirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  final GrcRequestFirebaseDataSource _firebaseDataSource;

  List<AssigningControlModel> _toModels(List<AssigningControlEntity> entities) {
    return entities
        .map((a) => AssigningControlModel(
              policyId: a.policyId,
              controlId: a.controlId,
              expiresOn: a.expiresOn,
            ))
        .toList();
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> createReassignChampionRequest({
    required String moduleId,
    required String requestedBy,
    required String note,
    required String currentChampionEmail,
    required String newChampionEmail,
    required List<AssigningControlEntity> controls,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final model = GrcRequestModel(
        id: '', // overwritten by the data source on create
        moduleId: moduleId,
        type: GrcRequestType.reassignChampion.value,
        status: ApprovalStatus.pending.name,
        requestedBy: requestedBy,
        requestDate: DateTime.now(),
        note: note,
        currentChampionEmail: currentChampionEmail,
        newChampionEmail: newChampionEmail,
        controls: _toModels(controls),
        startDate: startDate,
        endDate: endDate,
      );
      final created = await _firebaseDataSource.create(model, moduleId: moduleId);
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GrcRequestEntity>>> getRequestsForModule(
    String moduleId,
  ) async {
    try {
      final models = await _firebaseDataSource.getAll(moduleId: moduleId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, GrcRequestModel>> _getById({
    required String moduleId,
    required String requestId,
  }) async {
    final all = await _firebaseDataSource.getAll(moduleId: moduleId);
    final match = all.where((m) => m.id == requestId);
    if (match.isEmpty) {
      return Left(ValidationError('GRC Request not found (id: $requestId)'));
    }
    return Right(match.first);
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> approveRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = GrcRequestModel(
            id: current.id,
            moduleId: current.moduleId,
            type: current.type,
            status: ApprovalStatus.approved.name,
            requestedBy: current.requestedBy,
            requestDate: current.requestDate,
            note: current.note,
            rejectionReason: current.rejectionReason,
            decidedBy: decidedBy,
            decisionDate: DateTime.now(),
            currentChampionEmail: current.currentChampionEmail,
            newChampionEmail: current.newChampionEmail,
            controls: current.controls,
            startDate: current.startDate,
            endDate: current.endDate,
            appliedAt: current.appliedAt,
          );
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> rejectRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
    required String reason,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = GrcRequestModel(
            id: current.id,
            moduleId: current.moduleId,
            type: current.type,
            status: ApprovalStatus.rejected.name,
            requestedBy: current.requestedBy,
            requestDate: current.requestDate,
            note: current.note,
            rejectionReason: reason,
            decidedBy: decidedBy,
            decisionDate: DateTime.now(),
            currentChampionEmail: current.currentChampionEmail,
            newChampionEmail: current.newChampionEmail,
            controls: current.controls,
            startDate: current.startDate,
            endDate: current.endDate,
            appliedAt: current.appliedAt,
          );
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> markApplied({
    required String moduleId,
    required String requestId,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = GrcRequestModel(
            id: current.id,
            moduleId: current.moduleId,
            type: current.type,
            status: current.status,
            requestedBy: current.requestedBy,
            requestDate: current.requestDate,
            note: current.note,
            rejectionReason: current.rejectionReason,
            decidedBy: current.decidedBy,
            decisionDate: current.decisionDate,
            currentChampionEmail: current.currentChampionEmail,
            newChampionEmail: current.newChampionEmail,
            controls: current.controls,
            startDate: current.startDate,
            endDate: current.endDate,
            appliedAt: DateTime.now(),
          );
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/features/grc/grc_request/`
Expected: Clean.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/grc_request/data/
git commit -m "feat(grc): add GrcRequest data layer (model, data source, repository impl)"
```

---

## Task 6: Use cases — Create, GetAll, Approve, Reject

**Files:**
- Create: `lib/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart`
- Create: `lib/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart`
- Create: `lib/features/grc/grc_request/domain/use_cases/approve_grc_request_usecase.dart`
- Create: `lib/features/grc/grc_request/domain/use_cases/reject_grc_request_usecase.dart`

**Interfaces:**
- Consumes: `GrcRequestRepository` (Task 4).
- Produces: `CreateGrcRequestUseCase(CreateGrcRequestParams)`, `GetGrcRequestsUseCase(moduleId)`, `ApproveGrcRequestUseCase(ApproveGrcRequestParams)`, `RejectGrcRequestUseCase(RejectGrcRequestParams)` — consumed by Task 8 (`GrcRequestCubit`) and Task 10 (DI registration).

- [ ] **Step 1: `create_grc_request_usecase.dart`**

```dart
/// Module: GRC Request Management
/// Description: Use case for creating a new Reassign Control Champion request.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class CreateGrcRequestParams {
  final String moduleId;
  final String requestedBy;
  final String note;
  final String currentChampionEmail;
  final String newChampionEmail;
  final List<AssigningControlEntity> controls;
  final DateTime startDate;
  final DateTime? endDate;

  const CreateGrcRequestParams({
    required this.moduleId,
    required this.requestedBy,
    required this.note,
    required this.currentChampionEmail,
    required this.newChampionEmail,
    required this.controls,
    required this.startDate,
    this.endDate,
  });
}

class CreateGrcRequestUseCase {
  const CreateGrcRequestUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, GrcRequestEntity>> call(CreateGrcRequestParams params) {
    return _repository.createReassignChampionRequest(
      moduleId: params.moduleId,
      requestedBy: params.requestedBy,
      note: params.note,
      currentChampionEmail: params.currentChampionEmail,
      newChampionEmail: params.newChampionEmail,
      controls: params.controls,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
```

- [ ] **Step 2: `get_grc_requests_usecase.dart`**

```dart
/// Module: GRC Request Management
/// Description: Use case for reading all GRC requests for a module.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class GetGrcRequestsUseCase {
  const GetGrcRequestsUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, List<GrcRequestEntity>>> call(String moduleId) {
    return _repository.getRequestsForModule(moduleId);
  }
}
```

- [ ] **Step 3: `approve_grc_request_usecase.dart`**

```dart
/// Module: GRC Request Management
/// Description: Use case for approving a pending GRC request. Approval only
///              flips status — the actual champion transfer is deferred
///              until Start Date via the recompute-on-read resolver.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class ApproveGrcRequestParams {
  final String moduleId;
  final String requestId;
  final String decidedBy;

  const ApproveGrcRequestParams({
    required this.moduleId,
    required this.requestId,
    required this.decidedBy,
  });
}

class ApproveGrcRequestUseCase {
  const ApproveGrcRequestUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, GrcRequestEntity>> call(ApproveGrcRequestParams params) {
    return _repository.approveRequest(
      moduleId: params.moduleId,
      requestId: params.requestId,
      decidedBy: params.decidedBy,
    );
  }
}
```

- [ ] **Step 4: `reject_grc_request_usecase.dart`**

```dart
/// Module: GRC Request Management
/// Description: Use case for rejecting a pending GRC request with a reason.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class RejectGrcRequestParams {
  final String moduleId;
  final String requestId;
  final String decidedBy;
  final String reason;

  const RejectGrcRequestParams({
    required this.moduleId,
    required this.requestId,
    required this.decidedBy,
    required this.reason,
  });
}

class RejectGrcRequestUseCase {
  const RejectGrcRequestUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, GrcRequestEntity>> call(RejectGrcRequestParams params) {
    return _repository.rejectRequest(
      moduleId: params.moduleId,
      requestId: params.requestId,
      decidedBy: params.decidedBy,
      reason: params.reason,
    );
  }
}
```

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/features/grc/grc_request/`
Expected: Clean.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/grc_request/domain/use_cases/
git commit -m "feat(grc): add GrcRequest use cases (create/getAll/approve/reject)"
```

---

## Task 7: `champion_request_resolver.dart` and `ApplyChampionReassignmentUseCase`

This is the core "recompute-on-read" logic: deciding which approved requests are due for transfer, and which assigned controls have expired — plus the use case that actually performs a due transfer.

**Files:**
- Create: `lib/features/grc/control_champion/domain/entities/champion_request_resolver.dart`
- Create: `lib/features/grc/control_champion/domain/use_cases/apply_champion_reassignment_usecase.dart`

**Interfaces:**
- Consumes: `GrcRequestEntity` (Task 3), `ChampionEntity`/`ChampionRepository` (existing), `GrcRequestRepository` (Task 4), `AssigningControlEntity` (Task 1), `ApprovalStatus`.
- Produces: `findDueReassignmentRequests(requests) -> List<GrcRequestEntity>`, `findExpiredControls(champion) -> List<AssigningControlEntity>` (pure functions — consumed by Task 9's `ChampionCubit.getAllChampions()`); `ApplyChampionReassignmentUseCase.call(request)` (consumed by the same Task 9 hook).

- [ ] **Step 1: Write the pure resolver functions**

```dart
/// Module: Control Champion Management
/// Description: Pure "would-be" decisions for the Champion Reassignment
///              Request workflow — mirrors control_status_resolver.dart's
///              shape. No persistence, no side effects: callers (Champion
///              Cubit) are responsible for acting on what these return.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: GrcRequestEntity, ApprovalStatus, AssigningControlEntity, ChampionEntity

import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';

/// function name: [findDueReassignmentRequests]
///
/// purpose: from a module's full request list, find every approved,
///          not-yet-applied Reassign Control Champion request whose Start
///          Date has arrived (today >= startDate, compared at day
///          granularity) — these are the requests a caller must apply.
///
/// parameters:
///            [List<GrcRequestEntity>] requests: every request for one module
///
/// return type: [List<GrcRequestEntity>] - requests ready to be applied
List<GrcRequestEntity> findDueReassignmentRequests(
  List<GrcRequestEntity> requests,
) {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return requests.where((r) {
    if (r.type != GrcRequestType.reassignChampion) return false;
    if (r.status != ApprovalStatus.approved) return false;
    if (r.appliedAt != null) return false;
    final startDate = r.startDate;
    if (startDate == null) return false;
    final startOfStart = DateTime(startDate.year, startDate.month, startDate.day);
    return !startOfStart.isAfter(startOfToday);
  }).toList();
}

/// function name: [findExpiredControls]
///
/// purpose: from one Champion's current assigned controls, find every
///          control whose [AssigningControlEntity.expiresOn] has passed
///          (today >= expiresOn, compared at day granularity) — these must
///          be stripped so the control becomes unassigned.
///
/// parameters:
///            [ChampionEntity] champion: the champion whose controls to check
///
/// return type: [List<AssigningControlEntity>] - controls that have expired
List<AssigningControlEntity> findExpiredControls(ChampionEntity champion) {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return champion.assigningControls.where((c) {
    final expiresOn = c.expiresOn;
    if (expiresOn == null) return false;
    final startOfExpiry = DateTime(expiresOn.year, expiresOn.month, expiresOn.day);
    return !startOfExpiry.isAfter(startOfToday);
  }).toList();
}
```

- [ ] **Step 2: Write `ApplyChampionReassignmentUseCase`**

This extracts the transfer logic currently living in `reassign_champion_page.dart`'s `_submit()` (lines 174-268 of the current file), reused from the recompute-on-read hook instead of being run immediately on form submit.

```dart
/// Module: Control Champion Management
/// Description: Applies one due Reassign Control Champion request: moves
///              its controls from the current champion to the new champion
///              (tagging each with the request's End Date as expiresOn),
///              then marks the request applied. This is the logic that used
///              to run immediately on ReassignChampionPage's submit button —
///              it now only runs once a request's Start Date has arrived,
///              found by champion_request_resolver.findDueReassignmentRequests.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, ChampionRepository, GrcRequestRepository, GrcRequestEntity

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:demo_app/features/grc/control_champion/domain/repository/champion_repository.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class ApplyChampionReassignmentUseCase {
  const ApplyChampionReassignmentUseCase({
    required ChampionRepository championRepository,
    required GrcRequestRepository requestRepository,
  })  : _championRepository = championRepository,
        _requestRepository = requestRepository;

  final ChampionRepository _championRepository;
  final GrcRequestRepository _requestRepository;

  Future<Either<Failure, Unit>> call(GrcRequestEntity request) async {
    final currentEmail = request.currentChampionEmail;
    final newEmail = request.newChampionEmail;
    final controls = request.controls;
    if (currentEmail == null || newEmail == null || controls == null) {
      return Left(ValidationError(
        'Reassignment request ${request.id} is missing champion/control data',
      ));
    }

    final currentResult = await _championRepository.getChampion(
      currentEmail,
      moduleId: request.moduleId,
    );
    final removalResult = await currentResult.fold<Future<Either<Failure, Unit>>>(
      (failure) async => Left(failure),
      (current) async {
        final remaining = current.assigningControls.where((ac) {
          return !controls.any(
            (rc) => rc.policyId == ac.policyId && rc.controlId == ac.controlId,
          );
        }).toList();
        final updateResult = await _championRepository.updateChampion(
          championEmail: currentEmail,
          moduleId: request.moduleId,
          editorId: request.requestedBy,
          assigningControls: remaining,
          status: remaining.isEmpty ? ChampionStatus.removed : null,
        );
        return updateResult.fold((f) => Left(f), (_) => const Right(unit));
      },
    );
    if (removalResult.isLeft()) {
      return removalResult;
    }

    final taggedControls = controls
        .map((c) => c.copyWith(expiresOn: request.endDate))
        .toList();

    final newChampionResult = await _championRepository.getChampion(
      newEmail,
      moduleId: request.moduleId,
    );
    final additionResult = await newChampionResult.fold<Future<Either<Failure, Unit>>>(
      (failure) async {
        final createResult = await _championRepository.createChampion(
          moduleId: request.moduleId,
          championEmail: newEmail,
          assigningControls: taggedControls,
          editorId: request.requestedBy,
        );
        return createResult.fold((f) => Left(f), (_) => const Right(unit));
      },
      (existing) async {
        final merged = <AssigningControlEntity>[...existing.assigningControls];
        for (final tc in taggedControls) {
          final exists = merged.any(
            (ac) => ac.policyId == tc.policyId && ac.controlId == tc.controlId,
          );
          if (!exists) merged.add(tc);
        }
        final updateResult = await _championRepository.updateChampion(
          championEmail: newEmail,
          moduleId: request.moduleId,
          editorId: request.requestedBy,
          assigningControls: merged,
          status: ChampionStatus.active,
        );
        return updateResult.fold((f) => Left(f), (_) => const Right(unit));
      },
    );
    if (additionResult.isLeft()) {
      return additionResult;
    }

    final markResult = await _requestRepository.markApplied(
      moduleId: request.moduleId,
      requestId: request.id,
    );
    return markResult.fold((f) => Left(f), (_) => const Right(unit));
  }
}
```

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/features/grc/control_champion/`
Expected: Clean.

- [ ] **Step 4: Manual sanity check of the pure functions**

Since there's no test infra, sanity-check the two pure functions directly. Create a throwaway scratch file (do not commit it) at `/private/tmp/claude-501/-Users-bstar-Knowticed-Plus-Demo-App/36b3761b-fc78-4b5a-b37a-f8055222328a/scratchpad/resolver_check.dart` that imports both functions and prints results for: (a) a request with `startDate` yesterday, `status: approved`, `appliedAt: null` → should appear in `findDueReassignmentRequests`; (b) same but `appliedAt` set → should NOT appear; (c) a champion with one control `expiresOn` yesterday and one `expiresOn: null` → `findExpiredControls` should return only the first. Run it with `dart run <path>` and confirm the printed booleans match expectations, then delete the scratch file.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control_champion/domain/entities/champion_request_resolver.dart lib/features/grc/control_champion/domain/use_cases/apply_champion_reassignment_usecase.dart
git commit -m "feat(grc): add recompute-on-read resolver and apply-reassignment use case"
```

---

## Task 8: `GrcRequestCubit`

**Files:**
- Create: `lib/features/grc/grc_request/presentation/controller/grc_request_cubit.dart`
- Create: `lib/features/grc/grc_request/presentation/controller/grc_request_state.dart`

**Interfaces:**
- Consumes: `CreateGrcRequestUseCase`, `GetGrcRequestsUseCase`, `ApproveGrcRequestUseCase`, `RejectGrcRequestUseCase` (Task 6).
- Produces: `GrcRequestCubit` with `getRequestsForModule(moduleId)`, `createRequest(CreateGrcRequestParams)`, `approveRequest(moduleId, requestId)`, `rejectRequest(moduleId, requestId, reason)` — consumed by Task 11 (`GrcRequestsListPage`) and Task 12 (`GrcRequestDetailsPage`).

- [ ] **Step 1: Write `grc_request_state.dart`**

```dart
part of 'grc_request_cubit.dart';

sealed class GrcRequestState {}

final class GrcRequestInitial extends GrcRequestState {}

final class GrcRequestLoading extends GrcRequestState {}

final class GrcRequestListLoaded extends GrcRequestState {
  final List<GrcRequestEntity> requests;

  GrcRequestListLoaded(this.requests);
}

final class GrcRequestActionSuccess extends GrcRequestState {
  final GrcRequestEntity request;

  GrcRequestActionSuccess(this.request);
}

final class GrcRequestFailure extends GrcRequestState {
  final String message;

  GrcRequestFailure(this.message);
}
```

- [ ] **Step 2: Write `grc_request_cubit.dart`**

```dart
/// Module: GRC Request Management
/// Description: BLoC Cubit that manages GRC Request state for the
///              presentation layer, mirroring ChampionCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, use cases, GrcRequestEntity

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/approve_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/reject_grc_request_usecase.dart';
import 'package:get/get.dart';

part 'grc_request_state.dart';

class GrcRequestCubit extends Cubit<GrcRequestState> {
  GrcRequestCubit({
    required CreateGrcRequestUseCase createGrcRequestUseCase,
    required GetGrcRequestsUseCase getGrcRequestsUseCase,
    required ApproveGrcRequestUseCase approveGrcRequestUseCase,
    required RejectGrcRequestUseCase rejectGrcRequestUseCase,
  })  : _createUseCase = createGrcRequestUseCase,
        _getAllUseCase = getGrcRequestsUseCase,
        _approveUseCase = approveGrcRequestUseCase,
        _rejectUseCase = rejectGrcRequestUseCase,
        super(GrcRequestInitial());

  final CreateGrcRequestUseCase _createUseCase;
  final GetGrcRequestsUseCase _getAllUseCase;
  final ApproveGrcRequestUseCase _approveUseCase;
  final RejectGrcRequestUseCase _rejectUseCase;

  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  Future<void> getRequestsForModule(String moduleId) async {
    emit(GrcRequestLoading());
    final result = await _getAllUseCase.call(moduleId);
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (requests) => emit(GrcRequestListLoaded(requests)),
    );
  }

  Future<void> createRequest(CreateGrcRequestParams params) async {
    emit(GrcRequestLoading());
    final result = await _createUseCase.call(params);
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) => emit(GrcRequestActionSuccess(request)),
    );
  }

  Future<void> approveRequest({
    required String moduleId,
    required String requestId,
  }) async {
    emit(GrcRequestLoading());
    final result = await _approveUseCase.call(
      ApproveGrcRequestParams(
        moduleId: moduleId,
        requestId: requestId,
        decidedBy: _currentUserEmail,
      ),
    );
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) => emit(GrcRequestActionSuccess(request)),
    );
  }

  Future<void> rejectRequest({
    required String moduleId,
    required String requestId,
    required String reason,
  }) async {
    emit(GrcRequestLoading());
    final result = await _rejectUseCase.call(
      RejectGrcRequestParams(
        moduleId: moduleId,
        requestId: requestId,
        decidedBy: _currentUserEmail,
        reason: reason,
      ),
    );
    result.fold(
      (failure) => emit(GrcRequestFailure(failure.message)),
      (request) => emit(GrcRequestActionSuccess(request)),
    );
  }
}
```

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/features/grc/grc_request/`
Expected: Clean.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/grc_request/presentation/controller/
git commit -m "feat(grc): add GrcRequestCubit"
```

---

## Task 9: Register the `grc_request` layer in DI; hook recompute-on-read into `ChampionCubit`

**Files:**
- Modify: `lib/features/grc/grc_get_it.dart`
- Modify: `lib/features/grc/control_champion/presentation/controller/champion_cubit.dart`

**Interfaces:**
- Consumes: everything from Tasks 1-8.
- Produces: `GetIt.instance<GrcRequestFirebaseDataSource>()`, `GetIt.instance<GrcRequestRepository>()`, all 4 use cases, `GetIt.instance<GrcRequestCubit>()`, `GetIt.instance<ApplyChampionReassignmentUseCase>()` all resolvable; `ChampionCubit.getAllChampions()` now runs the full recompute-on-read pass before emitting — consumed by every existing caller unchanged (same method signature).

- [ ] **Step 1: Add imports to `grc_get_it.dart`**

Add alongside the existing `control_champion` imports (near lines 14-56):

```dart
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_request_resolver.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/apply_champion_reassignment_usecase.dart';
import 'package:demo_app/features/grc/grc_request/data/data_source/grc_request_firebase_data_source.dart';
import 'package:demo_app/features/grc/grc_request/data/repository/grc_request_repository_impl.dart';
import 'package:demo_app/features/grc/grc_request/domain/repository/grc_request_repository.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/approve_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/reject_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
```

`champion_request_resolver.dart` exports top-level functions, not a class — no registration needed for it, only the import where it's used (Step 3 below).

- [ ] **Step 2: Register data source and repository**

In the "Section 1: data sources" block (near the existing `ChampionFirebaseDataSource` registration at lines 121-125), add:

```dart
sl.registerLazySingleton<GrcRequestFirebaseDataSource>(
  () => GrcRequestFirebaseDataSource(),
);
```

In the "Section 2: repositories" block (near lines 163-169), add:

```dart
sl.registerLazySingleton<GrcRequestRepository>(
  () => GrcRequestRepositoryImpl(
    firebaseDataSource: sl<GrcRequestFirebaseDataSource>(),
  ),
);
```

- [ ] **Step 3: Register use cases**

In the "Section 3: use cases" block (near lines 301-323), add:

```dart
sl.registerLazySingleton<CreateGrcRequestUseCase>(
  () => CreateGrcRequestUseCase(sl<GrcRequestRepository>()),
);
sl.registerLazySingleton<GetGrcRequestsUseCase>(
  () => GetGrcRequestsUseCase(sl<GrcRequestRepository>()),
);
sl.registerLazySingleton<ApproveGrcRequestUseCase>(
  () => ApproveGrcRequestUseCase(sl<GrcRequestRepository>()),
);
sl.registerLazySingleton<RejectGrcRequestUseCase>(
  () => RejectGrcRequestUseCase(sl<GrcRequestRepository>()),
);
sl.registerLazySingleton<ApplyChampionReassignmentUseCase>(
  () => ApplyChampionReassignmentUseCase(
    championRepository: sl<ChampionRepository>(),
    requestRepository: sl<GrcRequestRepository>(),
  ),
);
```

- [ ] **Step 4: Register the cubit**

In the "Section 4: cubits" block (near lines 445-455), add:

```dart
sl.registerFactory<GrcRequestCubit>(
  () => GrcRequestCubit(
    createGrcRequestUseCase: sl<CreateGrcRequestUseCase>(),
    getGrcRequestsUseCase: sl<GetGrcRequestsUseCase>(),
    approveGrcRequestUseCase: sl<ApproveGrcRequestUseCase>(),
    rejectGrcRequestUseCase: sl<RejectGrcRequestUseCase>(),
  ),
);
```

- [ ] **Step 5: Hook recompute-on-read into `ChampionCubit`**

Modify `lib/features/grc/control_champion/presentation/controller/champion_cubit.dart`. Add imports:

```dart
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_request_resolver.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/apply_champion_reassignment_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
```

Change the constructor to accept two new required dependencies:

```dart
class ChampionCubit extends Cubit<ChampionState> {
  ChampionCubit({
    required CreateChampionUseCase createChampionUseCase,
    required GetChampionUseCase getChampionUseCase,
    required GetAllChampionsUseCase getAllChampionsUseCase,
    required UpdateChampionUseCase updateChampionUseCase,
    required GetGrcRequestsUseCase getGrcRequestsUseCase,
    required ApplyChampionReassignmentUseCase applyChampionReassignmentUseCase,
  })  : _createUseCase = createChampionUseCase,
        _getUseCase = getChampionUseCase,
        _getAllUseCase = getAllChampionsUseCase,
        _updateUseCase = updateChampionUseCase,
        _getGrcRequestsUseCase = getGrcRequestsUseCase,
        _applyReassignmentUseCase = applyChampionReassignmentUseCase,
        super(ChampionInitial());

  final CreateChampionUseCase _createUseCase;
  final GetChampionUseCase _getUseCase;
  final GetAllChampionsUseCase _getAllUseCase;
  final UpdateChampionUseCase _updateUseCase;
  final GetGrcRequestsUseCase _getGrcRequestsUseCase;
  final ApplyChampionReassignmentUseCase _applyReassignmentUseCase;
```

Replace `getAllChampions` with a version that runs the recompute pass first:

```dart
  Future<void> getAllChampions({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    emit(ChampionLoading());
    await _applyDueReassignments(moduleId);
    await _stripExpiredControls(moduleId, includeRemoved: includeRemoved);
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    result.fold(
      (failure) => emit(ChampionFailure(failure.message)),
      (champions) => emit(ChampionListLoaded(champions)),
    );
  }

  Future<void> _applyDueReassignments(String moduleId) async {
    final requestsResult = await _getGrcRequestsUseCase.call(moduleId);
    await requestsResult.fold(
      (_) async {}, // no requests fetched — nothing to apply, champion list still loads
      (requests) async {
        final due = findDueReassignmentRequests(requests);
        for (final request in due) {
          await _applyReassignmentUseCase.call(request);
        }
      },
    );
  }

  Future<void> _stripExpiredControls(
    String moduleId, {
    required bool includeRemoved,
  }) async {
    final currentResult = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    await currentResult.fold(
      (_) async {},
      (champions) async {
        for (final champion in champions) {
          final expired = findExpiredControls(champion);
          if (expired.isEmpty) continue;
          final remaining = champion.assigningControls.where((ac) {
            return !expired.any(
              (ex) => ex.policyId == ac.policyId && ex.controlId == ac.controlId,
            );
          }).toList();
          await _updateUseCase.call(
            UpdateChampionParams(
              championEmail: champion.championEmail,
              moduleId: moduleId,
              editorId: _currentUserEmail,
              assigningControls: remaining,
              status: remaining.isEmpty ? ChampionStatus.removed : null,
            ),
          );
        }
      },
    );
  }
```

Leave every other existing method (`getChampion`, `createChampion`, `updateChampion`) unchanged.

- [ ] **Step 6: Update the `ChampionCubit` DI registration to pass the two new dependencies**

In `grc_get_it.dart`'s cubit section, change the existing `ChampionCubit` registration to:

```dart
sl.registerFactory<ChampionCubit>(
  () => ChampionCubit(
    createChampionUseCase: sl<CreateChampionUseCase>(),
    getChampionUseCase: sl<GetChampionUseCase>(),
    getAllChampionsUseCase: sl<GetAllChampionsUseCase>(),
    updateChampionUseCase: sl<UpdateChampionUseCase>(),
    getGrcRequestsUseCase: sl<GetGrcRequestsUseCase>(),
    applyChampionReassignmentUseCase: sl<ApplyChampionReassignmentUseCase>(),
  ),
);
```

Since `ChampionCubit` is registered as `registerFactory` and depends on `GrcRequestCubit`'s sibling use cases (not the cubit itself), and `sl.registerLazySingleton<GrcRequestRepository>` must be registered before this point in the file (GetIt resolves lazily so registration order across `registerLazySingleton` calls doesn't matter, but keep it in the same "use cases" section as the rest for readability, after Step 3's additions).

- [ ] **Step 7: Verify**

Run: `flutter analyze lib/features/grc/`
Expected: Clean. This is the first point where a compile error would surface if any signature across Tasks 1-8 was mismatched — pay attention to any error here.

- [ ] **Step 8: Manual verification**

Run the app (`flutter run`), navigate to a GRC Module's Control Champions tab, and confirm the champion list still loads without error (it will call the new recompute pass every time, which should no-op safely when there are zero requests for that module yet).

- [ ] **Step 9: Commit**

```bash
git add lib/features/grc/grc_get_it.dart lib/features/grc/control_champion/presentation/controller/champion_cubit.dart
git commit -m "feat(grc): wire GrcRequest DI and recompute-on-read into ChampionCubit"
```

---

## Task 10: `GrcRequestsListPage`

**Files:**
- Create: `lib/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart`

**Interfaces:**
- Consumes: `GrcRequestCubit` (Task 8), `GrcRequestEntity`/`GrcRequestType`, `ApprovalStatus`, `GrcOwnerBadge` (`lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart`), `GRCModuleEntity`.
- Produces: `GrcRequestsListPage({required GRCModuleEntity module})` — consumed by Task 12's wiring of the `Requests` button, and by Task 11's details-page navigation-back target.

- [ ] **Step 1: Write the page**

```dart
/// Module: GRC Request Management
/// Description: Module-scoped list of GRC approval requests — All/Approved/
///              Pending/Rejected count tabs, search, and a card grid that
///              navigates to GrcRequestDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, get_it, GrcRequestCubit, GRCModuleEntity

import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:demo_app/features/grc/grc_request/presentation/ui/pages/grc_request_details_page.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class GrcRequestsListPage extends StatelessWidget {
  final GRCModuleEntity module;

  const GrcRequestsListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>()
        ..getRequestsForModule(module.moduleId),
      child: _GrcRequestsListBody(module: module),
    );
  }
}

class _GrcRequestsListBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _GrcRequestsListBody({required this.module});

  @override
  State<_GrcRequestsListBody> createState() => _GrcRequestsListBodyState();
}

class _GrcRequestsListBodyState extends State<_GrcRequestsListBody> {
  ApprovalStatus _selectedFilter = ApprovalStatus.all;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GrcRequestEntity> _applyFilters(List<GrcRequestEntity> requests) {
    var filtered = requests;
    if (_selectedFilter != ApprovalStatus.all) {
      filtered = filtered.where((r) => r.status == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((r) =>
              (r.newChampionEmail ?? '').toLowerCase().contains(q) ||
              (r.currentChampionEmail ?? '').toLowerCase().contains(q) ||
              r.requestedBy.toLowerCase().contains(q))
          .toList();
    }
    return filtered;
  }

  Widget _countChip(String label, int count, ApprovalStatus status, Color color) {
    final selected = _selectedFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = status),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count',
                style: StyleText.fontSize14Weight600.copyWith(
                    color: selected ? Colors.black : AppColors.text)),
            SizedBox(width: 6.w),
            Text(label, style: StyleText.fontSize14Weight500.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(ApprovalStatus status) {
    final Color color;
    switch (status) {
      case ApprovalStatus.approved:
        color = Colors.green;
        break;
      case ApprovalStatus.rejected:
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(status.getName,
          style: StyleText.fontSize12Weight500.copyWith(color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [widget.module.moduleNameEn, 'Requests'.tr],
              ),
              SizedBox(height: 16.h),
              BlocBuilder<GrcRequestCubit, GrcRequestState>(
                builder: (context, state) {
                  final requests =
                      state is GrcRequestListLoaded ? state.requests : <GrcRequestEntity>[];
                  final counts = {
                    for (final s in [
                      ApprovalStatus.all,
                      ApprovalStatus.approved,
                      ApprovalStatus.pending,
                      ApprovalStatus.rejected,
                    ])
                      s: s == ApprovalStatus.all
                          ? requests.length
                          : requests.where((r) => r.status == s).length,
                  };
                  final filtered = _applyFilters(requests);

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _countChip('All', counts[ApprovalStatus.all]!,
                                ApprovalStatus.all, AppColors.text),
                            _countChip('Approved', counts[ApprovalStatus.approved]!,
                                ApprovalStatus.approved, Colors.green),
                            _countChip('Pending', counts[ApprovalStatus.pending]!,
                                ApprovalStatus.pending, Colors.orange),
                            _countChip('Rejected', counts[ApprovalStatus.rejected]!,
                                ApprovalStatus.rejected, Colors.red),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        AppSearchTextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          hintText: 'Search'.tr,
                          controller: _searchController,
                        ),
                        SizedBox(height: 16.h),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(child: Text('No requests found'.tr))
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 420,
                                    mainAxisExtent: 220,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final request = filtered[index];
                                    return GestureDetector(
                                      onTap: () {
                                        if (request.type !=
                                            GrcRequestType.reassignChampion) {
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => GrcRequestDetailsPage(
                                              module: widget.module,
                                              request: request,
                                            ),
                                          ),
                                        ).then((_) => context
                                            .read<GrcRequestCubit>()
                                            .getRequestsForModule(widget.module.moduleId));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(16.r),
                                        decoration: BoxDecoration(
                                          color: AppColors.card,
                                          borderRadius: BorderRadius.circular(8.r),
                                          boxShadow: [
                                            BoxShadow(
                                                color: AppColors.dropShadow,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2)),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${'Request Type'.tr}: ${request.type.value}',
                                                    style: StyleText.fontSize14Weight600
                                                        .copyWith(color: AppColors.text),
                                                  ),
                                                ),
                                                Text(
                                                  '${'Request Date'.tr}: ${dateFormat.format(request.requestDate)}',
                                                  style: StyleText.fontSize12Weight400
                                                      .copyWith(
                                                          color: AppColors.secondaryText),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            GrcOwnerBadge(
                                              ownerEmails: widget.module.moduleOwners,
                                              label: 'Department Manager:'.tr,
                                            ),
                                            SizedBox(height: 8.h),
                                            Expanded(
                                              child: Text(
                                                '${'Request Note'.tr}: ${request.note}',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: StyleText.fontSize12Weight400
                                                    .copyWith(color: AppColors.text),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: _statusPill(request.status),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/features/grc/grc_request/`
Expected: Clean.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart
git commit -m "feat(grc): add GrcRequestsListPage"
```

---

## Task 11: `GrcRequestDetailsPage`

**Files:**
- Create: `lib/features/grc/grc_request/presentation/ui/pages/grc_request_details_page.dart`

**Interfaces:**
- Consumes: `GrcRequestCubit` (Task 8), `showCommentDialog`/`showConfirmDialog` (`lib/core/custom/11_custom_confirm_diaolog.dart`), `EmployeeHelper`/`MainCoreEmployeeController` (name/photo/dept/title lookups, same as `reassign_champion_page.dart`).
- Produces: `GrcRequestDetailsPage({required GRCModuleEntity module, required GrcRequestEntity request})` — consumed by Task 10's card tap.

- [ ] **Step 1: Write the page**

```dart
/// Module: GRC Request Management
/// Description: Details view for a single GRC Request. For
///              GrcRequestType.reassignChampion, shows Current vs New
///              Control Champion, dates, note, and assigned controls, with
///              Approve/Reject actions while pending. Any other request
///              type renders a "not supported" placeholder.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, get_it, GrcRequestCubit, custom_confirm_dialog

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class GrcRequestDetailsPage extends StatelessWidget {
  final GRCModuleEntity module;
  final GrcRequestEntity request;

  const GrcRequestDetailsPage({
    super.key,
    required this.module,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>(),
      child: _GrcRequestDetailsBody(module: module, request: request),
    );
  }
}

class _GrcRequestDetailsBody extends StatefulWidget {
  final GRCModuleEntity module;
  final GrcRequestEntity request;

  const _GrcRequestDetailsBody({required this.module, required this.request});

  @override
  State<_GrcRequestDetailsBody> createState() => _GrcRequestDetailsBodyState();
}

class _GrcRequestDetailsBodyState extends State<_GrcRequestDetailsBody> {
  late GrcRequestEntity _request;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  EmployeeEntityPro? _findEmployee(String email) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
    final employees = Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
    for (final e in employees) {
      if (e.email == email) return e;
    }
    return null;
  }

  String _employeeDisplayName(BuildContext context, String email) {
    final employee = _findEmployee(email);
    if (employee == null) return email;
    return EmployeeHelper.getEmployeeLocalizedName(employee: employee, context: context);
  }

  Widget _championCard(BuildContext context, String title, String email) {
    final employee = _findEmployee(email);
    final photo = employee != null
        ? EmployeeHelper.getEmployeeImage(employee: employee)
        : 'assets/icons_assets/main_icons_assets/assets_male.svg';
    final name = _employeeDisplayName(context, email);
    final dept = employee != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(employee: employee, context: context)
        : '';
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [BoxShadow(color: AppColors.dropShadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
          SizedBox(height: 8.h),
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: photo.startsWith('http') ? NetworkImage(photo) : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                    if (dept.isNotEmpty)
                      Text(dept, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onApprove() {
    showConfirmDialog(
      context: context,
      title: 'Approve Request'.tr,
      subtitle: 'Are you sure you want to approve this request?'.tr,
      onConfirm: () {
        context.read<GrcRequestCubit>().approveRequest(
              moduleId: widget.module.moduleId,
              requestId: _request.id,
            );
      },
    );
  }

  void _onReject() {
    showCommentDialog(
      context: context,
      title: 'Reason Of Rejection'.tr,
      fieldLabel: 'Justifications'.tr,
      onSubmit: (reason) {
        context.read<GrcRequestCubit>().rejectRequest(
              moduleId: widget.module.moduleId,
              requestId: _request.id,
              reason: reason,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GrcRequestCubit, GrcRequestState>(
      listener: (context, state) {
        if (state is GrcRequestActionSuccess && state.request.id == _request.id) {
          setState(() => _request = state.request);
        } else if (state is GrcRequestFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Action failed: ${state.message}')),
          );
        }
      },
      builder: (context, state) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_request.type != GrcRequestType.reassignChampion) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(
                  screensTitles: [widget.module.moduleNameEn, 'Requests'.tr, 'Request Details'.tr],
                ),
                SizedBox(height: 40.h),
                Center(child: Text('This request type is not supported yet.'.tr)),
              ],
            ),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('d MMM yyyy');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [widget.module.moduleNameEn, 'Requests'.tr, 'Request Details'.tr],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _championCard(context, 'Current Control Champion'.tr,
                          _request.currentChampionEmail ?? ''),
                      SizedBox(height: 16.h),
                      _championCard(context, 'New Control Champion'.tr,
                          _request.newChampionEmail ?? ''),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${'Start Date'.tr}: ${_request.startDate != null ? dateFormat.format(_request.startDate!) : '-'}',
                              style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${'End Date'.tr}: ${_request.endDate != null ? dateFormat.format(_request.endDate!) : '-'}',
                              style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Text('Request Note'.tr, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                      SizedBox(height: 6.h),
                      Text(_request.note, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
                      SizedBox(height: 20.h),
                      Text('Assigned Controls'.tr, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: (_request.controls ?? []).map((c) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(c.controlId, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 40.h),
                      if (_request.status == ApprovalStatus.pending)
                        Row(
                          children: [
                            Expanded(
                              child: customButton(
                                title: 'Reject'.tr,
                                function: _onReject,
                                color: Colors.red,
                                textStyle: StyleText.fontSize16Weight500.copyWith(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: customButton(
                                title: 'Approve'.tr,
                                function: _onApprove,
                                color: Colors.green,
                                textStyle: StyleText.fontSize16Weight500.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: _request.status == ApprovalStatus.approved
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            _request.status == ApprovalStatus.approved
                                ? 'Approved'.tr
                                : '${'Rejected'.tr}: ${_request.rejectionReason ?? ''}',
                            style: StyleText.fontSize14Weight500.copyWith(
                              color: _request.status == ApprovalStatus.approved ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Note: `EmployeeEntityPro` is the type used by `MainCoreEmployeeController.allEmployeesEntities` (confirmed via `reassign_champion_page.dart:73-79`'s identical `_findEmployee` helper) — this page's version is a deliberate copy since it's a `State` on a different widget tree, not a shared mixin (matching this codebase's existing convention of duplicating this exact small helper per page rather than extracting a shared utility, as seen in both `reassign_champion_page.dart` and `grc_module_details_page.dart`'s own `_employeeDisplayName`).

The Assigned Controls chips render `c.controlId` directly rather than a resolved control name (unlike `reassign_champion_page.dart`, which resolves names via a `policyControls` map) because this page is not given that map — it only receives the already-created `request`. This is an intentional, smaller scope than the create-flow's chip display; if control names are needed here later, `GrcRequestDetailsPage` would need `allPolicies`/`policyControls` passed in the same way `ControlChampionDetailsPage` already threads them through.

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/features/grc/grc_request/`
Expected: Clean.

- [ ] **Step 3: Manual verification**

Run the app, open a module's Control Champions tab (Requests page is not wired yet at this point in the plan — Task 12 does that — so for now confirm only that this file compiles and has no analyzer errors).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/grc_request/presentation/ui/pages/grc_request_details_page.dart
git commit -m "feat(grc): add GrcRequestDetailsPage with approve/reject flows"
```

---

## Task 12: Wire the "Requests" button

**Files:**
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart:754-757`

**Interfaces:**
- Consumes: `GrcRequestsListPage` (Task 10).

- [ ] **Step 1: Add the import**

Near the other page imports (around line 25-30):

```dart
import 'package:demo_app/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart';
```

- [ ] **Step 2: Replace the stub `onTap`**

Change:

```dart
                CustomButton(
                  buttonText: 'Requests',
                  onTap: () {},
                ),
```

to:

```dart
                CustomButton(
                  buttonText: 'Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GrcRequestsListPage(module: widget.module),
                      ),
                    );
                  },
                ),
```

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/features/grc/module/`
Expected: Clean.

- [ ] **Step 4: Manual verification**

Run the app, open a GRC Module's details page, switch to the "Control Champions" tab, and tap "Requests". Confirm `GrcRequestsListPage` opens showing an empty state (0/0/0/0 counts, "No requests found") since no requests exist yet.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart
git commit -m "feat(grc): wire the Requests button to GrcRequestsListPage"
```

---

## Task 13: Rewire `ReassignChampionPage` to create a request instead of an immediate change

**Files:**
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/reassign_champion_page.dart`

**Interfaces:**
- Consumes: `GrcRequestCubit.createRequest` (Task 8), `CreateGrcRequestParams` (Task 6).
- Produces: `ReassignChampionPage`'s public constructor is unchanged — only `_submit()`'s body changes, so `control_champion_details_page.dart:387-419`'s existing push/pop wiring (Section 10 of the earlier research) needs no changes.

- [ ] **Step 1: Add the required imports**

Add to the top of `reassign_champion_page.dart` alongside the existing imports:

```dart
import 'package:demo_app/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:demo_app/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

`GetIt` is already imported (line 26) — no change needed there. Remove the three now-unused imports for `CreateChampionUseCase`, `GetChampionUseCase`, `UpdateChampionUseCase` (lines 13-15) since `_submit()` no longer calls them directly.

- [ ] **Step 2: Wrap the page in a `GrcRequestCubit` provider**

The page must be able to call `context.read<GrcRequestCubit>()`. Since `ReassignChampionPage` is currently a plain `StatefulWidget` (not itself wrapped by a `BlocProvider` at its call site — `control_champion_details_page.dart:397-409` wraps it in `BlocProvider.value` for `ChampionCubit` only), add a second `BlocProvider` inside this file's own `build()` rather than touching the caller. Change the `build` method's very first line from:

```dart
  @override
  Widget build(BuildContext context) {
    final currentEmp = _findEmployee(widget.champion.championEmail);
```

to:

```dart
  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>(),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    final currentEmp = _findEmployee(widget.champion.championEmail);
```

And change the final `return Scaffold(` in the old `build` method to `return Scaffold(` inside `_buildPage` (no other change to the body — it's the same widget tree, just moved one method down so `context` inside it can see the new `BlocProvider`).

- [ ] **Step 3: Add Start Date validation and replace `_submit()`'s body**

Replace the full `_submit()` method (previously lines 150-278) with:

```dart
  Future<void> _submit() async {
    if (_newSelectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a new Control Champion'.tr)),
      );
      return;
    }
    if (_reassignedControls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please assign at least one Control'.tr)),
      );
      return;
    }
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please choose a start date'.tr)),
      );
      return;
    }

    final newChampionEmail = _newSelectedEmployees.first.email;
    if (newChampionEmail == widget.champion.championEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New champion cannot be the current champion'.tr)),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final requestCubit = context.read<GrcRequestCubit>();
      await requestCubit.createRequest(
        CreateGrcRequestParams(
          moduleId: widget.module.moduleId,
          requestedBy: _currentUserEmail,
          note: _noteController.text,
          currentChampionEmail: widget.champion.championEmail,
          newChampionEmail: newChampionEmail,
          controls: _reassignedControls,
          startDate: _startDate!,
          endDate: _endDate,
        ),
      );

      final state = requestCubit.state;
      if (state is GrcRequestActionSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request submitted'.tr)),
        );
        Navigator.pop(context, true);
      } else if (state is GrcRequestFailure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: ${state.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
```

Note: `Navigator.pop(context, true)` still fires on success, so `control_champion_details_page.dart:412-416`'s existing `if (result == true && mounted) { context.read<ChampionCubit>().getAllChampions(...); Navigator.pop(context, true); }` continues to work unchanged — it will simply reload a champion list where nothing has changed yet (the request is `pending`), which is correct: no visible transfer should happen until the request is approved and its Start Date arrives.

- [ ] **Step 4: Verify**

Run: `flutter analyze lib/features/grc/control_champion/`
Expected: Clean.

- [ ] **Step 5: Manual verification**

Run the app: open a champion's details page → Reassign → pick a new champion, at least one control, a Start Date, and submit. Confirm:
1. Submitting without a Start Date shows "Please choose a start date" and does not proceed.
2. Submitting with all fields shows "Request submitted" and returns to the champion details page with the **old champion's assigned controls unchanged** (since the request is only `pending`).
3. Open the module's Requests list (Task 12's entry point) and confirm the new request appears under "Pending" with the correct champion emails, note, and dates.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/control_champion/presentation/ui/pages/reassign_champion_page.dart
git commit -m "feat(grc): reassign champion now creates a request instead of an immediate change"
```

---

## Task 14: End-to-end manual verification of the full workflow

No new files — this task exercises everything built in Tasks 1-13 together, since the recompute-on-read mechanics (the riskiest part of this feature) can only be verified by actually waiting for/simulating a date crossing.

- [ ] **Step 1: Verify the full happy path with a same-day Start Date**

Run the app. Create a reassignment request with **Start Date = today** and no End Date. Approve it from the Requests details page. Navigate back to the Control Champions tab (which calls `getAllChampions`, triggering the recompute pass) and confirm: the controls have moved from the old champion to the new champion, and the request (if you inspect Firestore directly, or by reopening its details page) now shows `appliedAt` set and does not re-apply on a second reload (no duplicate controls, no errors).

- [ ] **Step 2: Verify a future Start Date stays pending-transfer**

Create a second request with **Start Date = tomorrow**, approve it, then reload the Control Champions tab. Confirm the controls have **not** moved yet (old champion still holds them) since `findDueReassignmentRequests` only includes requests whose Start Date has arrived.

- [ ] **Step 3: Verify End Date expiry**

Using Firestore console (or a temporary code tweak reverted afterward), set an already-applied request's champion's `Expires_On` (on one of the transferred `AssigningControlModel` entries) to yesterday. Reload the Control Champions tab and confirm that specific control is now stripped from the new champion (becomes unassigned) while any other controls without an `expiresOn` remain untouched.

- [ ] **Step 4: Verify reject flow**

Create a third request, open its details page, tap Reject, and submit a reason via the "Reason Of Rejection" dialog. Confirm the request now shows under "Rejected" in the list with the entered reason visible on its details page, and that no champion data changed.

- [ ] **Step 5: Final analyzer pass**

Run: `flutter analyze`
Expected: Clean across the whole `lib/` tree (not just the GRC folder), confirming nothing outside the touched files regressed.

- [ ] **Step 6: No commit for this task** — it is verification-only. If any step surfaces a bug, fix it in the relevant earlier task's file(s) and commit that fix with a `fix(grc): ...` message before considering the plan complete.

---

## Self-Review Notes (from plan authoring)

- **Spec coverage:** every "Goals" bullet and every UI/business-logic point in `docs/superpowers/specs/2026-07-25-champion-reassignment-requests-design.md` maps to a task above (data model → Tasks 1-5; recompute-on-read → Tasks 7, 9; UI → Tasks 10-13; wiring → Task 12; end-to-end proof → Task 14).
- **Type consistency:** `ApprovalStatus.name` (not `.getName`) is used consistently for persistence in Task 5's model and Task 6/9's cubit/resolver logic — `.getName` is display-only and must never be written to Firestore or compared against stored values.
- **`controlChanges`** appears only as an enum value (Task 2) and a one-line placeholder branch (Task 11) — no speculative fields or repository methods were added for it, per the design spec's non-goals.
