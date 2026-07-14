# Policy/Control Repository Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the Policy repository/use-case/cubit/DI chain back into a compiling, consistent state and add the missing `ControlRepository` layer, so `dart analyze lib/features/grc/domain/ lib/features/grc/data/ lib/features/grc/presentation/controller/ lib/features/grc/grc_get_it.dart` reports zero errors.

**Architecture:** Clean Architecture, one repository per Firestore aggregate (`PolicyRepository` for Policy documents, new `ControlRepository` for the Controls subcollection), Params-object use cases (`XxxParams` + `.call()`), single `PolicyCubit` that orchestrates both Policy and Control use cases for the presentation layer.

**Tech Stack:** Dart 3.5+, `dartz` (`Either<Failure, T>`), `flutter_bloc` (Cubit), `get_it` (DI), `cloud_firestore`, `uuid`.

## Global Constraints

- No automated tests this round (matches this repo's established fast-iteration convention for GRC work). Verification per task is `dart analyze` on the touched files reporting no new errors.
- Controls have no "Removed" lifecycle state — `deleteControl` is always a hard delete, never a status change.
- Firestore path convention (already implemented in the data layer, do not change): `GRC Modules/{Module_ID}/Policies/{Policy_ID}/Controls/{Control_ID}`.
- Use-case layer convention for this feature: a `XxxParams` class + a `call(params)` method (not `.execute(...)` with flat args — that's the GRC Module feature's own convention, not Policy/Control's).
- Files under `lib/features/grc/presentation/ui/**` are out of scope. They currently call the old Cubit signatures and will show new `dart analyze` errors after Task 5 — that is expected; a separate follow-up plan fixes the UI.
- `PolicyRepository`'s interface (`domain/repository/policy_repository.dart`) does **not** change — it already has no `controls` param on `createPolicy`/`updatePolicy`. Only its implementation and the layers above it are out of sync today.

---

### Task 1: `ControlRepository` domain interface

**Files:**
- Create: `lib/features/grc/domain/repository/control_repository.dart`

**Interfaces:**
- Consumes: `ControlEntity` (`lib/features/grc/domain/entities/control_entity.dart`), `ControlStatus` (`lib/features/grc/domain/entities/control_status.dart`), `Failure`/`FirebaseFailure`/`ValidationError` (`lib/core/network/failure_model.dart`) — all already exist, unchanged.
- Produces: abstract class `ControlRepository` with methods `createControl`, `getControl`, `getAllControls`, `updateControl`, `deleteControl` — the exact signatures below are the contract every later task in this plan relies on.

- [ ] **Step 1: Create the interface**

```dart
/// Module: Policy Management
/// Description: Defines the Domain-layer repository contract for Control
///              operations. Controls are their own Firestore subcollection
///              nested under a Policy document:
///              GRC Modules/{Module_ID}/Policies/{Policy_ID}/Controls/{Control_ID}.
///              Unlike Policies, Controls have no "Removed" status, so
///              delete is always a hard delete.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: dartz, Failure, ControlEntity, ControlStatus
/// Revision History: 2026-07-14 - Initial creation

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';

/// class name: [ControlRepository]
///
/// purpose: define the contract for all Control operations exposed to the
///          rest of the app. Uses Entities (not Models) and returns
///          [Either<Failure, T>] so callers handle success and failure
///          explicitly.
abstract class ControlRepository {
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
    required bool equalWeights,
    required int score,
    required ControlStatus status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  });

  Future<Either<Failure, ControlEntity>> getControl(
    String id, {
    required String moduleId,
    required String policyId,
  });

  Future<Either<Failure, List<ControlEntity>>> getAllControls({
    required String moduleId,
    required String policyId,
  });

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
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  });

  /// hard delete — Controls have no Removed status.
  Future<Either<Failure, Unit>> deleteControl(
    String id, {
    required String moduleId,
    required String policyId,
  });
}
```

- [ ] **Step 2: Verify**

Run: `dart analyze lib/features/grc/domain/repository/control_repository.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/domain/repository/control_repository.dart
git commit -m "feat(grc): add ControlRepository domain interface"
```

---

### Task 2: `ControlRepositoryImpl` + `PolicyRepositoryImpl` cleanup

**Files:**
- Create: `lib/features/grc/data/repository/control_repository_impl.dart`
- Modify: `lib/features/grc/data/repository/policy_repository_impl.dart` (full rewrite — see Step 2)

**Interfaces:**
- Consumes: `ControlRepository` (Task 1), `ControlFirebaseDataSource`/`ControlModel` (existing, unchanged), `PolicyStorageDataSource`/`DocumentLanguage` (existing, unchanged — `uploadControlDocument`), `PolicyRepository` (existing, unchanged).
- Produces: `ControlRepositoryImpl implements ControlRepository`, constructor `ControlRepositoryImpl({required ControlFirebaseDataSource firebaseDataSource, required PolicyStorageDataSource storageDataSource})`. `PolicyRepositoryImpl` constructor drops `controlDataSource` — now `PolicyRepositoryImpl({required PolicyFirebaseDataSource firebaseDataSource, required PolicyStorageDataSource storageDataSource})` (used by Task 6 DI wiring).

This task moves the Control CRUD logic that is currently (incorrectly) sitting inside `PolicyRepositoryImpl` into its own file, and removes it from `PolicyRepositoryImpl`. Both edits must land together — doing one without the other either duplicates the logic or deletes it outright.

- [ ] **Step 1: Create `control_repository_impl.dart`**

```dart
/// Module: Policy Management
/// Description: Data-layer implementation of [ControlRepository]. Combines
///              [ControlFirebaseDataSource] (Firestore) with
///              [PolicyStorageDataSource] (Firebase Storage, for Control
///              document uploads), and maps between Models (persistence)
///              and Entities (domain/UI).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: dartz, uuid, ControlRepository, ControlFirebaseDataSource,
///               PolicyStorageDataSource, ControlModel
/// Revision History: 2026-07-14 - Initial creation, extracted from the
///                                ad-hoc Control handling that had been
///                                sitting inside PolicyRepositoryImpl
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/data/data_source/control_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/policy_storage_data_source.dart';
import 'package:demo_app/features/grc/data/models/control_model.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/domain/repository/control_repository.dart';
import 'package:uuid/uuid.dart';

/// class name: [ControlRepositoryImpl]
///
/// purpose: implement [ControlRepository] by orchestrating calls to
///          [ControlFirebaseDataSource] (the Controls subcollection) and
///          [PolicyStorageDataSource] (Control document uploads),
///          converting Models to Entities and wrapping every result in
///          [Either<Failure, T>].
class ControlRepositoryImpl implements ControlRepository {
  ControlRepositoryImpl({
    required ControlFirebaseDataSource firebaseDataSource,
    required PolicyStorageDataSource storageDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _storageDataSource = storageDataSource;

  final ControlFirebaseDataSource _firebaseDataSource;
  final PolicyStorageDataSource _storageDataSource;

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
    required bool equalWeights,
    required int score,
    required ControlStatus status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    try {
      final controlId = const Uuid().v4();

      final resolvedDocumentEn = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadControlDocument(
          policyId: policyId,
          controlId: controlId,
          documentFile: controlsDocumentFileEn!,
          language: DocumentLanguage.en,
        ),
        file: controlsDocumentFileEn,
        fallbackUrl: controlsDocumentUrlEn,
      );

      final resolvedDocumentAr = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadControlDocument(
          policyId: policyId,
          controlId: controlId,
          documentFile: controlsDocumentFileAr!,
          language: DocumentLanguage.ar,
        ),
        file: controlsDocumentFileAr,
        fallbackUrl: controlsDocumentUrlAr,
      );

      final model = ControlModel.create(
        id: controlId,
        policyId: policyId,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsDocumentEn: resolvedDocumentEn ?? '',
        controlsDocumentAr: resolvedDocumentAr ?? '',
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        equalWeights: equalWeights,
        score: score,
        status: status,
        editorId: editorId,
      );

      final created = await _firebaseDataSource.create(
        model,
        moduleId: moduleId,
        policyId: policyId,
      );
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ControlEntity>> getControl(
    String id, {
    required String moduleId,
    required String policyId,
  }) async {
    try {
      final model = await _firebaseDataSource.get(
        id,
        moduleId: moduleId,
        policyId: policyId,
      );
      if (model == null) {
        return Left(ValidationError('Control not found (id: $id)'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ControlEntity>>> getAllControls({
    required String moduleId,
    required String policyId,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        policyId: policyId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

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
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    try {
      final currentModel = await _firebaseDataSource.get(
        id,
        moduleId: moduleId,
        policyId: policyId,
      );
      if (currentModel == null) {
        return Left(ValidationError('Control not found (id: $id)'));
      }

      final resolvedDocumentEn = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadControlDocument(
          policyId: policyId,
          controlId: id,
          documentFile: controlsDocumentFileEn!,
          language: DocumentLanguage.en,
        ),
        file: controlsDocumentFileEn,
        fallbackUrl: controlsDocumentUrlEn,
      );

      final resolvedDocumentAr = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadControlDocument(
          policyId: policyId,
          controlId: id,
          documentFile: controlsDocumentFileAr!,
          language: DocumentLanguage.ar,
        ),
        file: controlsDocumentFileAr,
        fallbackUrl: controlsDocumentUrlAr,
      );

      final updatedModel = currentModel.copyWithUpdate(
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsDocumentEn: resolvedDocumentEn,
        controlsDocumentAr: resolvedDocumentAr,
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        equalWeights: equalWeights,
        score: score,
        status: status,
        editorId: editorId,
      );

      final saved = await _firebaseDataSource.update(
        updatedModel,
        moduleId: moduleId,
        policyId: policyId,
      );
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteControl(
    String id, {
    required String moduleId,
    required String policyId,
  }) async {
    try {
      await _firebaseDataSource.delete(
        id,
        moduleId: moduleId,
        policyId: policyId,
      );
      return const Right(unit);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<String?> _resolveFile({
    required Future<String> Function() uploadCallback,
    File? file,
    String? fallbackUrl,
  }) async {
    if (file != null) return uploadCallback();
    return fallbackUrl;
  }
}
```

- [ ] **Step 2: Overwrite `policy_repository_impl.dart`** with the Control-free version (drops `controlDataSource`, all `createControl`/`getControl`/`getAllControls`/`updateControl`/`deleteControl` overrides, `_createControlModel`, and the `controls` param + creation loop inside `createPolicy`):

```dart
/// Module: Policy Management
/// Description: Data-layer implementation of [PolicyRepository]. Combines
///              [PolicyFirebaseDataSource] (Firestore) with
///              [PolicyStorageDataSource] (Firebase Storage), and maps
///              between Models (persistence) and Entities (domain/UI).
///              Control operations live in [ControlRepositoryImpl].
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, uuid, PolicyRepository, PolicyFirebaseDataSource,
///               PolicyStorageDataSource, PolicyModel
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Migrated to the new schema: soft-delete /
///                                restore now toggle PolicyStatus.removed
///                                instead of an Is_Deleted flag
///                   2026-07-14 - Extracted all Control CRUD into the
///                                dedicated ControlRepositoryImpl so
///                                PolicyRepositoryImpl only depends on
///                                Policy data sources again
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/data/data_source/policy_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/policy_storage_data_source.dart';
import 'package:demo_app/features/grc/data/models/policy_model.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';
import 'package:uuid/uuid.dart';

/// class name: [PolicyRepositoryImpl]
///
/// purpose: implement [PolicyRepository] by orchestrating calls to
///          [PolicyFirebaseDataSource] and [PolicyStorageDataSource],
///          converting Models to Entities and wrapping every result in
///          [Either<Failure, T>]. Controls are handled by
///          [ControlRepositoryImpl], not here.
class PolicyRepositoryImpl implements PolicyRepository {
  PolicyRepositoryImpl({
    required PolicyFirebaseDataSource firebaseDataSource,
    required PolicyStorageDataSource storageDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _storageDataSource = storageDataSource;

  final PolicyFirebaseDataSource _firebaseDataSource;
  final PolicyStorageDataSource _storageDataSource;

  @override
  Future<Either<Failure, PolicyEntity>> createPolicy({
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String editorId,
    required String moduleId,
    required PolicyStatus status,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    try {
      final policyId = const Uuid().v4();

      final resolvedImage = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyImage(
          policyId: policyId,
          imageFile: imageFile!,
        ),
        file: imageFile,
        fallbackUrl: imageUrl,
      );

      final resolvedDocumentEn = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: policyId,
          documentFile: policyDocumentFileEn!,
          language: DocumentLanguage.en,
        ),
        file: policyDocumentFileEn,
        fallbackUrl: policyDocumentUrlEn,
      );

      final resolvedDocumentAr = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: policyId,
          documentFile: policyDocumentFileAr!,
          language: DocumentLanguage.ar,
        ),
        file: policyDocumentFileAr,
        fallbackUrl: policyDocumentUrlAr,
      );

      final model = PolicyModel.create(
        id: policyId,
        moduleId: moduleId,
        policyImage: resolvedImage ?? '',
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        policyDocumentEn: resolvedDocumentEn ?? '',
        policyDocumentAr: resolvedDocumentAr ?? '',
        status: status,
        editorId: editorId,
      );

      final created = await _firebaseDataSource.create(model, moduleId: moduleId);
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PolicyEntity>> getPolicy(
    String id, {
    required String moduleId,
  }) async {
    try {
      final model = await _firebaseDataSource.get(id, moduleId: moduleId);
      if (model == null) {
        return Left(ValidationError('Policy not found (id: $id)'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PolicyEntity>>> getAllPolicies({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        includeRemoved: includeRemoved,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PolicyEntity>> updatePolicy({
    required String id,
    required String editorId,
    required String moduleId,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    PolicyStatus? status,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    try {
      final currentModel = await _firebaseDataSource.get(id, moduleId: moduleId);
      if (currentModel == null) {
        return Left(ValidationError('Policy not found (id: $id)'));
      }

      final resolvedImage = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyImage(
          policyId: id,
          imageFile: imageFile!,
        ),
        file: imageFile,
        fallbackUrl: imageUrl,
      );

      final resolvedDocumentEn = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: id,
          documentFile: policyDocumentFileEn!,
          language: DocumentLanguage.en,
        ),
        file: policyDocumentFileEn,
        fallbackUrl: policyDocumentUrlEn,
      );

      final resolvedDocumentAr = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: id,
          documentFile: policyDocumentFileAr!,
          language: DocumentLanguage.ar,
        ),
        file: policyDocumentFileAr,
        fallbackUrl: policyDocumentUrlAr,
      );

      final updatedModel = currentModel.copyWithUpdate(
        policyImage: resolvedImage,
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        policyDocumentEn: resolvedDocumentEn,
        policyDocumentAr: resolvedDocumentAr,
        status: status,
        editorId: editorId,
      );

      final saved = await _firebaseDataSource.update(updatedModel, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PolicyEntity>> deletePolicy({
    required String id,
    required String editorId,
    required String moduleId,
  }) async {
    try {
      final deleted = await _firebaseDataSource.delete(
        id,
        moduleId: moduleId,
        editorId: editorId,
      );
      return Right(deleted.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PolicyEntity>> restorePolicy({
    required String id,
    required String editorId,
    required String moduleId,
  }) async {
    try {
      final restored = await _firebaseDataSource.restore(
        id,
        moduleId: moduleId,
        editorId: editorId,
      );
      return Right(restored.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<String?> _resolveFile({
    required Future<String> Function() uploadCallback,
    File? file,
    String? fallbackUrl,
  }) async {
    if (file != null) return uploadCallback();
    return fallbackUrl;
  }
}
```

- [ ] **Step 3: Verify**

Run: `dart analyze lib/features/grc/data/repository/control_repository_impl.dart lib/features/grc/data/repository/policy_repository_impl.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/data/repository/control_repository_impl.dart lib/features/grc/data/repository/policy_repository_impl.dart
git commit -m "feat(grc): extract Control CRUD into ControlRepositoryImpl"
```

---

### Task 3: Fix Policy use cases

**Files:**
- Modify: `lib/features/grc/domain/use_cases/create_policy_usecase.dart` (full rewrite)
- Modify: `lib/features/grc/domain/use_cases/update_policy_usecase.dart` (full rewrite)
- Modify: `lib/features/grc/domain/use_cases/get_policy_usecases.dart:65-87` (targeted edit)

**Interfaces:**
- Consumes: `PolicyRepository` (Task 2's cleaned-up impl satisfies the unchanged interface).
- Produces: `CreatePolicyParams` (no `controls` field; `policyDocumentFileEn/Ar` + `policyDocumentUrlEn/Ar` instead of single `policyDocumentFile`/`policyDocumentUrl`), `UpdatePolicyParams` (same two fixes), `GetAllPoliciesUseCase.call({required moduleId, bool includeRemoved = false})`. Task 5 (`PolicyCubit`) constructs these directly.

- [ ] **Step 1: Overwrite `create_policy_usecase.dart`**

```dart
/// Module: Policy Management
/// Description: Use case responsible for creating a new Policy record.
///              Controls are created separately via CreateControlUseCase
///              once the Policy id is known — see PolicyCubit for the
///              orchestration.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, Failure, PolicyEntity, PolicyRepository
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Removed the `controls` field (Controls are
///                                no longer created through PolicyRepository)
///                                and split policyDocumentFile/Url into
///                                En/Ar pairs to match the current
///                                PolicyRepository.createPolicy signature

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';

/// class name: [CreatePolicyParams]
///
/// purpose: groups every field needed to create a new Policy record into a
///          single strongly-typed object passed to [CreatePolicyUseCase].
class CreatePolicyParams {
  final String policyNameEn;
  final String policyNameAr;
  final String policyNumberEn;
  final String policyNumberAr;
  final String policyDescriptionEn;
  final String policyDescriptionAr;
  final DateTime startDate;
  final DateTime endDate;
  final double policyWeight;
  final String editorId;
  final String moduleId;
  final PolicyStatus status;
  final File? imageFile;
  final String? imageUrl;
  final File? policyDocumentFileEn;
  final String? policyDocumentUrlEn;
  final File? policyDocumentFileAr;
  final String? policyDocumentUrlAr;

  const CreatePolicyParams({
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.policyWeight,
    required this.editorId,
    required this.moduleId,
    required this.status,
    this.imageFile,
    this.imageUrl,
    this.policyDocumentFileEn,
    this.policyDocumentUrlEn,
    this.policyDocumentFileAr,
    this.policyDocumentUrlAr,
  });
}

/// class name: [CreatePolicyUseCase]
///
/// purpose: encapsulate the "create a Policy" business action.
class CreatePolicyUseCase {
  const CreatePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  Future<Either<Failure, PolicyEntity>> call(CreatePolicyParams params) {
    return _repository.createPolicy(
      status: params.status,
      policyNameEn: params.policyNameEn,
      policyNameAr: params.policyNameAr,
      policyNumberEn: params.policyNumberEn,
      policyNumberAr: params.policyNumberAr,
      policyDescriptionEn: params.policyDescriptionEn,
      policyDescriptionAr: params.policyDescriptionAr,
      startDate: params.startDate,
      endDate: params.endDate,
      policyWeight: params.policyWeight,
      editorId: params.editorId,
      moduleId: params.moduleId,
      imageFile: params.imageFile,
      imageUrl: params.imageUrl,
      policyDocumentFileEn: params.policyDocumentFileEn,
      policyDocumentUrlEn: params.policyDocumentUrlEn,
      policyDocumentFileAr: params.policyDocumentFileAr,
      policyDocumentUrlAr: params.policyDocumentUrlAr,
    );
  }
}
```

- [ ] **Step 2: Overwrite `update_policy_usecase.dart`**

```dart
/// Module: Policy Management
/// Description: Use case responsible for updating an existing Policy
///              record. Controls are updated separately via
///              UpdateControlUseCase.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, Failure, PolicyEntity, PolicyRepository
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Removed the `controls` field and split
///                                policyDocumentFile/Url into En/Ar pairs

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';

/// class name: [UpdatePolicyParams]
///
/// purpose: groups every field that can be changed on an existing Policy
///          record. Fields left null are not changed.
class UpdatePolicyParams {
  final String id;
  final String editorId;
  final String moduleId;
  final String? policyNameEn;
  final String? policyNameAr;
  final String? policyNumberEn;
  final String? policyNumberAr;
  final String? policyDescriptionEn;
  final String? policyDescriptionAr;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? policyWeight;
  final PolicyStatus? status;
  final File? imageFile;
  final String? imageUrl;
  final File? policyDocumentFileEn;
  final String? policyDocumentUrlEn;
  final File? policyDocumentFileAr;
  final String? policyDocumentUrlAr;

  const UpdatePolicyParams({
    required this.id,
    required this.editorId,
    required this.moduleId,
    this.policyNameEn,
    this.policyNameAr,
    this.policyNumberEn,
    this.policyNumberAr,
    this.policyDescriptionEn,
    this.policyDescriptionAr,
    this.startDate,
    this.endDate,
    this.policyWeight,
    this.status,
    this.imageFile,
    this.imageUrl,
    this.policyDocumentFileEn,
    this.policyDocumentUrlEn,
    this.policyDocumentFileAr,
    this.policyDocumentUrlAr,
  });
}

/// class name: [UpdatePolicyUseCase]
///
/// purpose: encapsulate the "update a Policy" business action.
class UpdatePolicyUseCase {
  const UpdatePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  Future<Either<Failure, PolicyEntity>> call(UpdatePolicyParams params) {
    return _repository.updatePolicy(
      id: params.id,
      editorId: params.editorId,
      moduleId: params.moduleId,
      policyNameEn: params.policyNameEn,
      policyNameAr: params.policyNameAr,
      policyNumberEn: params.policyNumberEn,
      policyNumberAr: params.policyNumberAr,
      policyDescriptionEn: params.policyDescriptionEn,
      policyDescriptionAr: params.policyDescriptionAr,
      startDate: params.startDate,
      endDate: params.endDate,
      policyWeight: params.policyWeight,
      status: params.status,
      imageFile: params.imageFile,
      imageUrl: params.imageUrl,
      policyDocumentFileEn: params.policyDocumentFileEn,
      policyDocumentUrlEn: params.policyDocumentUrlEn,
      policyDocumentFileAr: params.policyDocumentFileAr,
      policyDocumentUrlAr: params.policyDocumentUrlAr,
    );
  }
}
```

- [ ] **Step 3: Fix `GetAllPoliciesUseCase` in `get_policy_usecases.dart`**

Find this block (lines 65-87):

```dart
class GetAllPoliciesUseCase {
  const GetAllPoliciesUseCase(this._repository);

  final PolicyRepository _repository;

  /// function name: [call]
  ///
  /// purpose: forward the fetch-all request to [PolicyRepository.getAllPolicies].
  ///
  /// parameters:
  ///            [bool] includeDeleted: when false (default), soft-deleted policies are excluded
  ///
  /// return type: [Future<Either<Failure, List<PolicyEntity>>>] - the list of entities, or a Failure
  Future<Either<Failure, List<PolicyEntity>>> call({
    required String moduleId,
    bool includeDeleted = false,
  }) {
    return _repository.getAllPolicies(
      moduleId: moduleId,
      includeDeleted: includeDeleted,
    );
  }
}
```

Replace with:

```dart
class GetAllPoliciesUseCase {
  const GetAllPoliciesUseCase(this._repository);

  final PolicyRepository _repository;

  /// function name: [call]
  ///
  /// purpose: forward the fetch-all request to [PolicyRepository.getAllPolicies].
  ///
  /// parameters:
  ///            [bool] includeRemoved: when false (default), removed policies are excluded
  ///
  /// return type: [Future<Either<Failure, List<PolicyEntity>>>] - the list of entities, or a Failure
  Future<Either<Failure, List<PolicyEntity>>> call({
    required String moduleId,
    bool includeRemoved = false,
  }) {
    return _repository.getAllPolicies(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
  }
}
```

- [ ] **Step 4: Verify**

Run: `dart analyze lib/features/grc/domain/use_cases/create_policy_usecase.dart lib/features/grc/domain/use_cases/update_policy_usecase.dart lib/features/grc/domain/use_cases/get_policy_usecases.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/domain/use_cases/create_policy_usecase.dart lib/features/grc/domain/use_cases/update_policy_usecase.dart lib/features/grc/domain/use_cases/get_policy_usecases.dart
git commit -m "fix(grc): drop controls param and split document field in Policy use cases"
```

---

### Task 4: Control use cases

**Files:**
- Create: `lib/features/grc/domain/use_cases/create_control_usecase.dart`
- Create: `lib/features/grc/domain/use_cases/update_control_usecase.dart`
- Create: `lib/features/grc/domain/use_cases/get_control_usecases.dart`

**Interfaces:**
- Consumes: `ControlRepository` (Task 1).
- Produces: `CreateControlParams` + `CreateControlUseCase.call(params)`, `UpdateControlParams` + `UpdateControlUseCase.call(params)`, `GetControlUseCase.call(id, {required moduleId, required policyId})`, `GetAllControlsUseCase.call({required moduleId, required policyId})`, `DeleteControlParams` + `DeleteControlUseCase.call(params) → Either<Failure, Unit>`. Task 5 (`PolicyCubit`) and Task 6 (DI) depend on these exact names.

- [ ] **Step 1: Create `create_control_usecase.dart`**

```dart
/// Module: Policy Management
/// Description: Use case responsible for creating a new Control record
///              inside a Policy's Controls subcollection.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: dartz, Failure, ControlEntity, ControlRepository
/// Revision History: 2026-07-14 - Initial creation

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/domain/repository/control_repository.dart';

/// class name: [CreateControlParams]
///
/// purpose: groups every field needed to create a new Control record,
///          including the ids of its parent Module/Policy.
class CreateControlParams {
  final String moduleId;
  final String policyId;
  final String editorId;
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsNumberEn;
  final String controlsNumberAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final double controlsWeight;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> departments;
  final bool equalWeights;
  final int score;
  final ControlStatus status;
  final File? controlsDocumentFileEn;
  final String? controlsDocumentUrlEn;
  final File? controlsDocumentFileAr;
  final String? controlsDocumentUrlAr;

  const CreateControlParams({
    required this.moduleId,
    required this.policyId,
    required this.editorId,
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsNumberEn,
    required this.controlsNumberAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.controlsWeight,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.departments,
    required this.equalWeights,
    required this.score,
    required this.status,
    this.controlsDocumentFileEn,
    this.controlsDocumentUrlEn,
    this.controlsDocumentFileAr,
    this.controlsDocumentUrlAr,
  });
}

/// class name: [CreateControlUseCase]
///
/// purpose: encapsulate the "create a Control" business action.
class CreateControlUseCase {
  const CreateControlUseCase(this._repository);

  final ControlRepository _repository;

  Future<Either<Failure, ControlEntity>> call(CreateControlParams params) {
    return _repository.createControl(
      moduleId: params.moduleId,
      policyId: params.policyId,
      editorId: params.editorId,
      controlsNameEn: params.controlsNameEn,
      controlsNameAr: params.controlsNameAr,
      controlsNumberEn: params.controlsNumberEn,
      controlsNumberAr: params.controlsNumberAr,
      controlsDescriptionEn: params.controlsDescriptionEn,
      controlsDescriptionAr: params.controlsDescriptionAr,
      controlsWeight: params.controlsWeight,
      frequency: params.frequency,
      startDate: params.startDate,
      endDate: params.endDate,
      departments: params.departments,
      equalWeights: params.equalWeights,
      score: params.score,
      status: params.status,
      controlsDocumentFileEn: params.controlsDocumentFileEn,
      controlsDocumentUrlEn: params.controlsDocumentUrlEn,
      controlsDocumentFileAr: params.controlsDocumentFileAr,
      controlsDocumentUrlAr: params.controlsDocumentUrlAr,
    );
  }
}
```

- [ ] **Step 2: Create `update_control_usecase.dart`**

```dart
/// Module: Policy Management
/// Description: Use case responsible for updating an existing Control
///              record.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: dartz, Failure, ControlEntity, ControlRepository
/// Revision History: 2026-07-14 - Initial creation

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/domain/repository/control_repository.dart';

/// class name: [UpdateControlParams]
///
/// purpose: groups every field that can be changed on an existing Control
///          record. Fields left null are not changed.
class UpdateControlParams {
  final String id;
  final String moduleId;
  final String policyId;
  final String editorId;
  final String? controlsNameEn;
  final String? controlsNameAr;
  final String? controlsNumberEn;
  final String? controlsNumberAr;
  final String? controlsDescriptionEn;
  final String? controlsDescriptionAr;
  final double? controlsWeight;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? departments;
  final bool? equalWeights;
  final int? score;
  final ControlStatus? status;
  final File? controlsDocumentFileEn;
  final String? controlsDocumentUrlEn;
  final File? controlsDocumentFileAr;
  final String? controlsDocumentUrlAr;

  const UpdateControlParams({
    required this.id,
    required this.moduleId,
    required this.policyId,
    required this.editorId,
    this.controlsNameEn,
    this.controlsNameAr,
    this.controlsNumberEn,
    this.controlsNumberAr,
    this.controlsDescriptionEn,
    this.controlsDescriptionAr,
    this.controlsWeight,
    this.frequency,
    this.startDate,
    this.endDate,
    this.departments,
    this.equalWeights,
    this.score,
    this.status,
    this.controlsDocumentFileEn,
    this.controlsDocumentUrlEn,
    this.controlsDocumentFileAr,
    this.controlsDocumentUrlAr,
  });
}

/// class name: [UpdateControlUseCase]
///
/// purpose: encapsulate the "update a Control" business action.
class UpdateControlUseCase {
  const UpdateControlUseCase(this._repository);

  final ControlRepository _repository;

  Future<Either<Failure, ControlEntity>> call(UpdateControlParams params) {
    return _repository.updateControl(
      id: params.id,
      moduleId: params.moduleId,
      policyId: params.policyId,
      editorId: params.editorId,
      controlsNameEn: params.controlsNameEn,
      controlsNameAr: params.controlsNameAr,
      controlsNumberEn: params.controlsNumberEn,
      controlsNumberAr: params.controlsNumberAr,
      controlsDescriptionEn: params.controlsDescriptionEn,
      controlsDescriptionAr: params.controlsDescriptionAr,
      controlsWeight: params.controlsWeight,
      frequency: params.frequency,
      startDate: params.startDate,
      endDate: params.endDate,
      departments: params.departments,
      equalWeights: params.equalWeights,
      score: params.score,
      status: params.status,
      controlsDocumentFileEn: params.controlsDocumentFileEn,
      controlsDocumentUrlEn: params.controlsDocumentUrlEn,
      controlsDocumentFileAr: params.controlsDocumentFileAr,
      controlsDocumentUrlAr: params.controlsDocumentUrlAr,
    );
  }
}
```

- [ ] **Step 3: Create `get_control_usecases.dart`**

```dart
/// Module: Policy Management
/// Description: Use cases for reading (single/all) and deleting Control
///              records. No restore use case — Controls have no Removed
///              status.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: dartz, Failure, ControlEntity, ControlRepository
/// Revision History: 2026-07-14 - Initial creation

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/repository/control_repository.dart';

/// class name: [GetControlUseCase]
///
/// purpose: encapsulate the "fetch a single Control" business action.
class GetControlUseCase {
  const GetControlUseCase(this._repository);

  final ControlRepository _repository;

  Future<Either<Failure, ControlEntity>> call(
    String id, {
    required String moduleId,
    required String policyId,
  }) {
    return _repository.getControl(id, moduleId: moduleId, policyId: policyId);
  }
}

/// class name: [GetAllControlsUseCase]
///
/// purpose: encapsulate the "fetch all Controls for a Policy" business
///          action.
class GetAllControlsUseCase {
  const GetAllControlsUseCase(this._repository);

  final ControlRepository _repository;

  Future<Either<Failure, List<ControlEntity>>> call({
    required String moduleId,
    required String policyId,
  }) {
    return _repository.getAllControls(moduleId: moduleId, policyId: policyId);
  }
}

/// class name: [DeleteControlParams]
///
/// purpose: groups the fields required to hard-delete a Control record.
class DeleteControlParams {
  final String id;
  final String moduleId;
  final String policyId;

  const DeleteControlParams({
    required this.id,
    required this.moduleId,
    required this.policyId,
  });
}

/// class name: [DeleteControlUseCase]
///
/// purpose: encapsulate the "delete a Control" business action (hard
///          delete — Controls have no Removed status).
class DeleteControlUseCase {
  const DeleteControlUseCase(this._repository);

  final ControlRepository _repository;

  Future<Either<Failure, Unit>> call(DeleteControlParams params) {
    return _repository.deleteControl(
      params.id,
      moduleId: params.moduleId,
      policyId: params.policyId,
    );
  }
}
```

- [ ] **Step 4: Verify**

Run: `dart analyze lib/features/grc/domain/use_cases/create_control_usecase.dart lib/features/grc/domain/use_cases/update_control_usecase.dart lib/features/grc/domain/use_cases/get_control_usecases.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/domain/use_cases/create_control_usecase.dart lib/features/grc/domain/use_cases/update_control_usecase.dart lib/features/grc/domain/use_cases/get_control_usecases.dart
git commit -m "feat(grc): add Control use cases (create/update/get/getAll/delete)"
```

---

### Task 5: `PolicyCubit` — bundled create orchestration + standalone Control methods

**Files:**
- Modify: `lib/features/grc/presentation/controller/policy_cubit.dart` (full rewrite)
- Modify: `lib/features/grc/presentation/controller/policy_state.dart` (full rewrite)

**Interfaces:**
- Consumes: `CreatePolicyUseCase`/`UpdatePolicyUseCase`/`GetPolicyUseCase`/`GetAllPoliciesUseCase`/`DeletePolicyUseCase`/`RestorePolicyUseCase` (Task 3, unchanged names), `CreateControlUseCase`/`UpdateControlUseCase`/`DeleteControlUseCase`/`GetAllControlsUseCase` (Task 4).
- Produces: `PolicyCubit` constructor now requires 4 additional named params (`createControlUseCase`, `updateControlUseCase`, `deleteControlUseCase`, `getAllControlsUseCase`) — Task 6's DI registration must supply all of them. `PendingControlInput` (new public class, defined in `policy_cubit.dart`, used by `createPolicy`/`saveAsDraft`'s `controls` param — this is what the (out-of-scope) UI follow-up will construct instead of the old `CreateControlParams`). New states in `policy_state.dart`: `PolicyActionPartialSuccess`, `PolicyControlActionSuccess`, `PolicyControlsListLoaded`, `PolicyControlDeleted`.

- [ ] **Step 1: Overwrite `policy_state.dart`**

```dart
part of 'policy_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_state.dart
/// Purpose: Contains all sealed state classes emitted by [PolicyCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026
/// Revision History: 2026-07-14 - Added PolicyActionPartialSuccess,
///                                PolicyControlActionSuccess,
///                                PolicyControlsListLoaded,
///                                PolicyControlDeleted for the Control side
///                                of PolicyCubit

sealed class PolicyState {}

/// State emitted before any action has been requested.
final class PolicyInitial extends PolicyState {}

/// State emitted while any async operation is in progress.
final class PolicyLoading extends PolicyState {}

/// State emitted when the full list of policies has been loaded successfully.
final class PolicyListLoaded extends PolicyState {
  final List<PolicyEntity> policies;

  PolicyListLoaded(this.policies);
}

/// State emitted when a single policy has been loaded successfully.
final class PolicySingleLoaded extends PolicyState {
  final PolicyEntity policy;

  PolicySingleLoaded(this.policy);
}

/// State emitted when a create / update / delete / restore action completes
/// successfully. [policy] holds the entity that was affected.
final class PolicyActionSuccess extends PolicyState {
  final PolicyEntity policy;

  PolicyActionSuccess(this.policy);
}

/// State emitted when a Policy was created successfully but one or more of
/// its initial Controls failed to be created. The Policy already exists in
/// Firestore at this point (Policy + Controls creation is not
/// transactional), so this is surfaced distinctly from [PolicyActionSuccess]
/// instead of silently dropping the failed controls.
final class PolicyActionPartialSuccess extends PolicyState {
  final PolicyEntity policy;
  final List<({PendingControlInput input, String message})> failedControls;

  PolicyActionPartialSuccess(this.policy, this.failedControls);
}

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

- [ ] **Step 2: Overwrite `policy_cubit.dart`**

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

import 'dart:io';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_control_usecase.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_policy_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'policy_state.dart';

/// class name: [PendingControlInput]
///
/// purpose: groups the fields needed to create one Control alongside a new
///          Policy, before that Policy's id exists yet.
///          [PolicyCubit.createPolicy]/[PolicyCubit.saveAsDraft] resolve
///          moduleId/policyId/editorId for each of these once the Policy
///          itself has been created, then forward the rest to
///          [CreateControlUseCase].
class PendingControlInput {
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsNumberEn;
  final String controlsNumberAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final double controlsWeight;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> departments;
  final bool equalWeights;
  final int score;
  final ControlStatus status;
  final File? controlsDocumentFileEn;
  final String? controlsDocumentUrlEn;
  final File? controlsDocumentFileAr;
  final String? controlsDocumentUrlAr;

  const PendingControlInput({
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsNumberEn,
    required this.controlsNumberAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.controlsWeight,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.departments,
    required this.equalWeights,
    required this.score,
    required this.status,
    this.controlsDocumentFileEn,
    this.controlsDocumentUrlEn,
    this.controlsDocumentFileAr,
    this.controlsDocumentUrlAr,
  });
}

/// class name: [PolicyCubit]
///
/// purpose: manage all Policy and Control UI state. Each public method maps
///          to one use case (or, for [createPolicy]/[saveAsDraft], two —
///          Policy then Controls) and follows the pattern: emit
///          [PolicyLoading] → call use case(s) → emit a success state or
///          [PolicyFailure].
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

  /// Resolves the currently logged-in user's id.
  String get _currentUserId {
    final fromConstant = Constant.idUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final id = Get.find<MainCoreEmployeeController>().employeeEntity?.id;
      if (id != null && id.isNotEmpty) return id;
    }
    return '';
  }

  // ================================================================
  // GET ALL / GET SINGLE
  // ================================================================

  Future<void> getAllPolicies({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    emit(PolicyLoading());
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policies) => emit(PolicyListLoaded(policies)),
    );
  }

  Future<void> getPolicy(String id, {required String moduleId}) async {
    emit(PolicyLoading());
    final result = await _getUseCase.call(id, moduleId: moduleId);
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicySingleLoaded(policy)),
    );
  }

  // ================================================================
  // CREATE (Active / Publish) and SAVE AS DRAFT
  // ================================================================

  /// function name: [createPolicy]
  ///
  /// purpose: create a new Policy with [PolicyStatus.active] (Publish),
  ///          then create every [controls] entry against the new Policy's
  ///          id. See [_createPolicyWithControls] for state semantics.
  Future<void> createPolicy({
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String moduleId,
    List<PendingControlInput> controls = const [],
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    await _createPolicyWithControls(
      status: PolicyStatus.active, // Publish = Active
      policyNameEn: policyNameEn,
      policyNameAr: policyNameAr,
      policyNumberEn: policyNumberEn,
      policyNumberAr: policyNumberAr,
      policyDescriptionEn: policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr,
      startDate: startDate,
      endDate: endDate,
      policyWeight: policyWeight,
      moduleId: moduleId,
      controls: controls,
      imageFile: imageFile,
      imageUrl: imageUrl,
      policyDocumentFileEn: policyDocumentFileEn,
      policyDocumentUrlEn: policyDocumentUrlEn,
      policyDocumentFileAr: policyDocumentFileAr,
      policyDocumentUrlAr: policyDocumentUrlAr,
    );
  }

  /// function name: [saveAsDraft]
  ///
  /// purpose: create a new Policy with [PolicyStatus.draft] (Save For
  ///          Later), then create every [controls] entry (may be empty).
  Future<void> saveAsDraft({
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String moduleId,
    List<PendingControlInput> controls = const [],
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    await _createPolicyWithControls(
      status: PolicyStatus.draft, // Save For Later = Draft
      policyNameEn: policyNameEn,
      policyNameAr: policyNameAr,
      policyNumberEn: policyNumberEn,
      policyNumberAr: policyNumberAr,
      policyDescriptionEn: policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr,
      startDate: startDate,
      endDate: endDate,
      policyWeight: policyWeight,
      moduleId: moduleId,
      controls: controls,
      imageFile: imageFile,
      imageUrl: imageUrl,
      policyDocumentFileEn: policyDocumentFileEn,
      policyDocumentUrlEn: policyDocumentUrlEn,
      policyDocumentFileAr: policyDocumentFileAr,
      policyDocumentUrlAr: policyDocumentUrlAr,
    );
  }

  /// function name: [_createPolicyWithControls]
  ///
  /// purpose: shared orchestration for [createPolicy]/[saveAsDraft]. Creates
  ///          the Policy first (repository/use-case layer knows nothing
  ///          about Controls); if that fails, emits [PolicyFailure] and
  ///          stops — no Control is ever attempted without a persisted
  ///          Policy. On Policy success, creates every [controls] entry
  ///          against the new `policy.id`, collecting failures instead of
  ///          throwing, then emits [PolicyActionSuccess] if all controls
  ///          succeeded (or there were none) or
  ///          [PolicyActionPartialSuccess] if some failed.
  Future<void> _createPolicyWithControls({
    required PolicyStatus status,
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String moduleId,
    required List<PendingControlInput> controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final editorId = _currentUserId;
    final result = await _createUseCase.call(
      CreatePolicyParams(
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        editorId: editorId,
        moduleId: moduleId,
        status: status,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFileEn: policyDocumentFileEn,
        policyDocumentUrlEn: policyDocumentUrlEn,
        policyDocumentFileAr: policyDocumentFileAr,
        policyDocumentUrlAr: policyDocumentUrlAr,
      ),
    );

    await result.fold(
      (failure) async => emit(PolicyFailure(failure.message)),
      (policy) async {
        if (controls.isEmpty) {
          emit(PolicyActionSuccess(policy));
          return;
        }

        final failedControls = <({PendingControlInput input, String message})>[];
        for (final input in controls) {
          final controlResult = await _createControlUseCase.call(
            CreateControlParams(
              moduleId: moduleId,
              policyId: policy.id,
              editorId: editorId,
              controlsNameEn: input.controlsNameEn,
              controlsNameAr: input.controlsNameAr,
              controlsNumberEn: input.controlsNumberEn,
              controlsNumberAr: input.controlsNumberAr,
              controlsDescriptionEn: input.controlsDescriptionEn,
              controlsDescriptionAr: input.controlsDescriptionAr,
              controlsWeight: input.controlsWeight,
              frequency: input.frequency,
              startDate: input.startDate,
              endDate: input.endDate,
              departments: input.departments,
              equalWeights: input.equalWeights,
              score: input.score,
              status: input.status,
              controlsDocumentFileEn: input.controlsDocumentFileEn,
              controlsDocumentUrlEn: input.controlsDocumentUrlEn,
              controlsDocumentFileAr: input.controlsDocumentFileAr,
              controlsDocumentUrlAr: input.controlsDocumentUrlAr,
            ),
          );
          controlResult.fold(
            (failure) =>
                failedControls.add((input: input, message: failure.message)),
            (_) {},
          );
        }

        if (failedControls.isEmpty) {
          emit(PolicyActionSuccess(policy));
        } else {
          emit(PolicyActionPartialSuccess(policy, failedControls));
        }
      },
    );
  }

  // ================================================================
  // UPDATE / DELETE / RESTORE (Policy)
  // ================================================================

  Future<void> updatePolicy({
    required String id,
    required String moduleId,
    PolicyStatus? status,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final result = await _updateUseCase.call(
      UpdatePolicyParams(
        id: id,
        editorId: _currentUserId,
        moduleId: moduleId,
        status: status,
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFileEn: policyDocumentFileEn,
        policyDocumentUrlEn: policyDocumentUrlEn,
        policyDocumentFileAr: policyDocumentFileAr,
        policyDocumentUrlAr: policyDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

  Future<void> deletePolicy({
    required String id,
    required String moduleId,
  }) async {
    emit(PolicyLoading());
    final result = await _deleteUseCase.call(
      DeletePolicyParams(id: id, editorId: _currentUserId, moduleId: moduleId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

  Future<void> restorePolicy({
    required String id,
    required String moduleId,
  }) async {
    emit(PolicyLoading());
    final result = await _restoreUseCase.call(
      RestorePolicyParams(id: id, editorId: _currentUserId, moduleId: moduleId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

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
        editorId: _currentUserId,
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
        editorId: _currentUserId,
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

- [ ] **Step 3: Verify**

Run: `dart analyze lib/features/grc/presentation/controller/policy_cubit.dart lib/features/grc/presentation/controller/policy_state.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/controller/policy_cubit.dart lib/features/grc/presentation/controller/policy_state.dart
git commit -m "feat(grc): rework PolicyCubit for decoupled Policy/Control creation"
```

---

### Task 6: DI wiring (`grc_get_it.dart`)

**Files:**
- Modify: `lib/features/grc/grc_get_it.dart`

**Interfaces:**
- Consumes: `ControlFirebaseDataSource` (existing, unchanged), `ControlRepositoryImpl`/`ControlRepository` (Task 2/1), `CreateControlUseCase`/`UpdateControlUseCase`/`GetControlUseCase`/`GetAllControlsUseCase`/`DeleteControlUseCase` (Task 4), `PolicyCubit`'s new constructor shape (Task 5).
- Produces: a fully wired `sl<ControlRepository>()`, `sl<PolicyCubit>()` (now includes Control use cases), ready for the (out-of-scope) UI follow-up to call `GetIt.instance<PolicyCubit>()` exactly as it does today.

- [ ] **Step 1: Add the new import for `ControlFirebaseDataSource`**

In `lib/features/grc/grc_get_it.dart`, find:

```dart
import 'package:demo_app/features/grc/data/data_source/grc_module_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/grc_module_storage_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/policy_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/policy_storage_data_source.dart';
import 'package:demo_app/features/grc/data/repository/grc_module_repository_impl.dart';
import 'package:demo_app/features/grc/data/repository/policy_repository_impl.dart';
import 'package:demo_app/features/grc/domain/repository/grc_module_repository.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/domain/use_cases/delete_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_all_grc_modules_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/domain/use_cases/restore_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_policy_usecase.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_module_cubit.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_previous_owners_cubit.dart';
import 'package:demo_app/features/grc/presentation/controller/policy_cubit.dart';
import 'package:get_it/get_it.dart';
```

Replace with:

```dart
import 'package:demo_app/features/grc/data/data_source/control_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/grc_module_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/grc_module_storage_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/policy_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/policy_storage_data_source.dart';
import 'package:demo_app/features/grc/data/repository/control_repository_impl.dart';
import 'package:demo_app/features/grc/data/repository/grc_module_repository_impl.dart';
import 'package:demo_app/features/grc/data/repository/policy_repository_impl.dart';
import 'package:demo_app/features/grc/domain/repository/control_repository.dart';
import 'package:demo_app/features/grc/domain/repository/grc_module_repository.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/domain/use_cases/delete_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_all_grc_modules_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/domain/use_cases/restore_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_control_usecase.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_policy_usecase.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_module_cubit.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_previous_owners_cubit.dart';
import 'package:demo_app/features/grc/presentation/controller/policy_cubit.dart';
import 'package:get_it/get_it.dart';
```

- [ ] **Step 2: Register `ControlFirebaseDataSource`**

Find:

```dart
  /// class name: [PolicyStorageDataSource]
  /// purpose: Firebase Storage upload/delete for Policy images and documents.
  sl.registerLazySingleton<PolicyStorageDataSource>(
    () => PolicyStorageDataSource(),
  );

  // ─── 2. Repository ──────────────────────────────────────────────────────────
```

Replace with:

```dart
  /// class name: [PolicyStorageDataSource]
  /// purpose: Firebase Storage upload/delete for Policy images and documents.
  sl.registerLazySingleton<PolicyStorageDataSource>(
    () => PolicyStorageDataSource(),
  );

  /// class name: [ControlFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Control documents (the
  /// Controls subcollection nested under each Policy).
  sl.registerLazySingleton<ControlFirebaseDataSource>(
    () => ControlFirebaseDataSource(),
  );

  // ─── 2. Repository ──────────────────────────────────────────────────────────
```

- [ ] **Step 3: Register `ControlRepository`**

The existing `PolicyRepositoryImpl` registration below already omits
`controlDataSource` (it was never added there, even though the pre-Task-2
`PolicyRepositoryImpl` constructor required it — that mismatch was one of
the original compile errors). After Task 2, `PolicyRepositoryImpl`'s
constructor no longer takes that param at all, so this block needs no
change on its own — only the new `ControlRepository` registration is
inserted right after it.

Find:

```dart
  /// class name: [PolicyRepositoryImpl] registered as [PolicyRepository]
  /// purpose: orchestrates the data sources and maps models to entities.
  sl.registerLazySingleton<PolicyRepository>(
    () => PolicyRepositoryImpl(
      firebaseDataSource: sl<PolicyFirebaseDataSource>(),
      storageDataSource: sl<PolicyStorageDataSource>(),
    ),
  );

  // ─── 3. Use Cases ───────────────────────────────────────────────────────────
```

Replace with:

```dart
  /// class name: [PolicyRepositoryImpl] registered as [PolicyRepository]
  /// purpose: orchestrates the data sources and maps models to entities.
  sl.registerLazySingleton<PolicyRepository>(
    () => PolicyRepositoryImpl(
      firebaseDataSource: sl<PolicyFirebaseDataSource>(),
      storageDataSource: sl<PolicyStorageDataSource>(),
    ),
  );

  /// class name: [ControlRepositoryImpl] registered as [ControlRepository]
  /// purpose: orchestrates the Controls subcollection data source and Storage
  /// uploads, and maps models to entities.
  sl.registerLazySingleton<ControlRepository>(
    () => ControlRepositoryImpl(
      firebaseDataSource: sl<ControlFirebaseDataSource>(),
      storageDataSource: sl<PolicyStorageDataSource>(),
    ),
  );

  // ─── 3. Use Cases ───────────────────────────────────────────────────────────
```

- [ ] **Step 4: Register the five Control use cases**

Find:

```dart
  /// class name: [RestorePolicyUseCase]
  /// purpose: business logic for restoring a soft-deleted Policy.
  sl.registerLazySingleton<RestorePolicyUseCase>(
    () => RestorePolicyUseCase(sl<PolicyRepository>()),
  );

  // ─── 4. Cubit (Presentation) ────────────────────────────────────────────────
```

Replace with:

```dart
  /// class name: [RestorePolicyUseCase]
  /// purpose: business logic for restoring a soft-deleted Policy.
  sl.registerLazySingleton<RestorePolicyUseCase>(
    () => RestorePolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [CreateControlUseCase]
  /// purpose: business logic for creating a new Control.
  sl.registerLazySingleton<CreateControlUseCase>(
    () => CreateControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [GetControlUseCase]
  /// purpose: business logic for fetching a single Control by id.
  sl.registerLazySingleton<GetControlUseCase>(
    () => GetControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [GetAllControlsUseCase]
  /// purpose: business logic for fetching all Controls under a Policy.
  sl.registerLazySingleton<GetAllControlsUseCase>(
    () => GetAllControlsUseCase(sl<ControlRepository>()),
  );

  /// class name: [UpdateControlUseCase]
  /// purpose: business logic for updating an existing Control.
  sl.registerLazySingleton<UpdateControlUseCase>(
    () => UpdateControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [DeleteControlUseCase]
  /// purpose: business logic for hard-deleting a Control.
  sl.registerLazySingleton<DeleteControlUseCase>(
    () => DeleteControlUseCase(sl<ControlRepository>()),
  );

  // ─── 4. Cubit (Presentation) ────────────────────────────────────────────────
```

- [ ] **Step 5: Update the `PolicyCubit` registration**

Find:

```dart
  /// class name: [PolicyCubit]
  /// purpose: presentation-layer state manager for all Policy operations.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<PolicyCubit>(
    () => PolicyCubit(
      createPolicyUseCase: sl<CreatePolicyUseCase>(),
      getPolicyUseCase: sl<GetPolicyUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      deletePolicyUseCase: sl<DeletePolicyUseCase>(),
      restorePolicyUseCase: sl<RestorePolicyUseCase>(),
    ),
  );
}
```

Replace with:

```dart
  /// class name: [PolicyCubit]
  /// purpose: presentation-layer state manager for all Policy and Control
  /// operations. Registered as a factory so each page gets an independent
  /// cubit instance.
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
}
```

- [ ] **Step 6: Verify**

Run: `dart analyze lib/features/grc/grc_get_it.dart`
Expected: `No issues found!`

Then run the full-layer check (UI errors under `presentation/ui/**` are expected — confirm there are none anywhere else):

Run: `dart analyze lib/features/grc/domain/ lib/features/grc/data/ lib/features/grc/presentation/controller/ lib/features/grc/grc_get_it.dart`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): wire ControlRepository and Control use cases into DI"
```

---

## Self-Review Notes

- **Spec coverage:** Sections A (Task 1, 2), B (Task 2), C (Task 3, 4), D (Task 5), E (Task 6) of the design spec are each covered by exactly one task above.
- **Type consistency checked:** `CreateControlParams`/`UpdateControlParams`/`DeleteControlParams` (Task 4, use-case layer) vs. the flat named params on `ControlRepository`/`ControlRepositoryImpl` (Task 1/2) vs. `PendingControlInput` (Task 5, cubit-only input type that never crosses into the repository layer) — three distinct types by design, verified every field name/type matches 1:1 across the three where they map into each other (`PendingControlInput` → `CreateControlParams` inside `_createPolicyWithControls`).
- **No placeholders:** every step has complete, final file content or an exact find/replace block — nothing marked TBD.
