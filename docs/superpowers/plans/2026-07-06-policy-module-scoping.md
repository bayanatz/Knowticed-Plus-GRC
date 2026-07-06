# Policy Scoped Under GRC Module — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Nest the Policy Firestore collection under its parent GRC Module (`GRC Modules/{moduleId}/Policies/{policyId}`), thread `moduleId` through the whole Policy stack, and make tapping a module card open a real per-module dashboard where "Create Policy" carries that module's id.

**Architecture:** This is one connected refactor chain — data source → repository → use cases → cubit → `CreateNewPolicyPage` → `GrcModuleDetailsPage` → `grc_page.dart` navigation. Each layer in the chain calls the one below it, so a required `moduleId` parameter added at the bottom breaks every caller above it until that caller is updated too. Tasks are ordered bottom-up along this chain; each task's own files analyze cleanly, with any remaining `flutter analyze` errors confined to specific not-yet-updated files (called out explicitly per task) that get fixed in the next task.

**Tech Stack:** Flutter, Cloud Firestore (`cloud_firestore`), flutter_bloc (Cubit), get_it, dartz (`Either`), flutter_test.

**Spec:** `docs/superpowers/specs/2026-07-06-policy-module-scoping-design.md`

## Global Constraints

- Use the project's Flutter toolchain via puro, not a bare `flutter` command: `/Users/bstar/.puro/bin/puro flutter <args>`.
- Scope `flutter analyze` to this feature's files throughout: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`. Baseline on this branch (verified before this plan): **41 issues, 0 of them `error` severity** (all pre-existing `info`/`warning` — dangling doc comments, deprecated `withOpacity`/`color`, one unused import in `grc_page.dart`, one unused element in `policy_controls_table_widget.dart`). Every task below must not add any **new `error`-severity** line to this output. Don't fix the pre-existing `info`/`warning` noise — out of scope.
- No mocking library (mockito/mocktail) is present in `pubspec.yaml`'s `dev_dependencies`, and no `fake_cloud_firestore` package is available. Tasks that only thread a parameter through typed interfaces (no new business logic) are verified via `flutter analyze` (a real, meaningful compile-time contract check), not via invented unit tests with fake doubles. Task 1 (`PolicyModel`/`PolicyEntity`) has real, testable serialization logic, so it gets a real unit test.
- Never touch `_isWeightValid` in `policy_controls_table_widget.dart:121` or the unused import in `grc_page.dart:18` — pre-existing, unrelated to this work.

---

### Task 1: `PolicyModel` + `PolicyEntity` — add `moduleId`

**Files:**
- Modify: `lib/features/grc/data/models/policy_model.dart`
- Modify: `lib/features/grc/domain/entities/policy_entity.dart`
- Test: `test/features/grc/policy_model_module_id_test.dart` (new)

**Interfaces:**
- Consumes: nothing new — `ControlModel`, `PolicyStatus` already exist as read.
- Produces: `PolicyModel.moduleId` (`String`, required, non-history), `PolicyModel.create({..., required String moduleId})`, `PolicyModel.toJson()['Module_ID']`, `PolicyModel.fromJson(json)` reading `json['Module_ID']`, `PolicyEntity.moduleId` (`String`, required), `PolicyModel.toEntity()` populating `PolicyEntity.moduleId`. Every later task that builds a `PolicyModel` or `PolicyEntity` must pass `moduleId`.

This task will leave `flutter analyze` showing new errors in `lib/features/grc/data/repository/policy_repository_impl.dart` (it calls `PolicyModel.create(...)` without `moduleId`) — expected, fixed in Task 3.

- [ ] **Step 1: Write the failing test**

Create `test/features/grc/policy_model_module_id_test.dart`:

```dart
import 'package:demo_app/features/grc/data/models/policy_model.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PolicyModel carries moduleId through toJson/fromJson and toEntity',
      () {
    final policy = PolicyModel.create(
      id: 'p1',
      moduleId: 'm1',
      image: 'image.png',
      policyNameEn: 'Policy 1',
      policyNameAr: 'سياسة 1',
      policyNumberEn: 'P-1',
      policyNumberAr: 'س-1',
      policyDescriptionEn: 'desc',
      policyDescriptionAr: 'وصف',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      policyWeight: 1.0,
      policyDocument: 'doc.pdf',
      controls: const [],
      status: PolicyStatus.draft,
      editorId: 'editor-1',
    );

    expect(policy.moduleId, 'm1');
    expect(policy.toJson()['Module_ID'], 'm1');

    final rebuilt = PolicyModel.fromJson(policy.toJson());
    expect(rebuilt.moduleId, 'm1');
    expect(rebuilt.toEntity().moduleId, 'm1');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/policy_model_module_id_test.dart`
Expected: FAIL — `No named parameter with the name 'moduleId'` (or similar compile error), since `PolicyModel.create` doesn't accept `moduleId` yet.

- [ ] **Step 3: Add `moduleId` to `PolicyModel`**

In `lib/features/grc/data/models/policy_model.dart`:

Add the field, right after `final String id;`:

```dart
  final String id;
  final String moduleId;
```

In the main constructor, add `required this.moduleId,` right after `required this.id,`.

In `PolicyModel.create(...)`, add `required String moduleId,` to the parameter list (right after `required String id,`) and pass it through in the returned instance (right after `id: id,`):

```dart
    return PolicyModel(
      id: id,
      moduleId: moduleId,
```

In `copyWithUpdate(...)`, a policy never changes parent module, so no new parameter is needed — just pass the existing value through in the returned instance (right after `id: id,`):

```dart
    return PolicyModel(
      id: id,
      moduleId: moduleId,
```

In `toJson()`, add right after `'ID': id,`:

```dart
      'ID': id,
      'Module_ID': moduleId,
```

In `fromJson(...)`, add right after `id: json['ID'] as String,`:

```dart
      id: json['ID'] as String,
      moduleId: json['Module_ID'] as String,
```

In `toEntity()`, add `moduleId: moduleId,` right after `id: id,` in the returned `PolicyEntity(...)`.

- [ ] **Step 4: Add `moduleId` to `PolicyEntity`**

In `lib/features/grc/domain/entities/policy_entity.dart`:

Add the field, right after `final String id;`:

```dart
  final String id;
  final String moduleId;
```

In the constructor, add `required this.moduleId,` right after `required this.id,`.

`copyWith` does not need a `moduleId` parameter (it never changes), but must still carry the current value through — add `moduleId: moduleId,` right after `id: id,` in the returned `PolicyEntity(...)`.

- [ ] **Step 5: Run test to verify it passes**

Run: `/Users/bstar/.puro/bin/puro flutter test test/features/grc/policy_model_module_id_test.dart`
Expected: PASS (1 test).

- [ ] **Step 6: Confirm expected (and only expected) analyze errors**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`
Expected: new `error`-severity lines ONLY in `lib/features/grc/data/repository/policy_repository_impl.dart` (missing `moduleId` argument to `PolicyModel.create`). No errors in `policy_model.dart` or `policy_entity.dart` themselves.

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/data/models/policy_model.dart lib/features/grc/domain/entities/policy_entity.dart test/features/grc/policy_model_module_id_test.dart
git commit -m "feat(grc): add moduleId to PolicyModel and PolicyEntity"
```

---

### Task 2: `PolicyDataSource` + `PolicyFirebaseDataSource` — Policies as a subcollection

**Files:**
- Modify: `lib/features/grc/data/data_source/policy_data_source.dart`
- Modify: `lib/features/grc/data/data_source/policy_firebase_data_source.dart`

**Interfaces:**
- Consumes: `PolicyModel` (from Task 1, now carrying `moduleId`).
- Produces: every `PolicyDataSource`/`PolicyFirebaseDataSource` method now takes an explicit `required String moduleId`:
  - `create(PolicyModel model, {required String moduleId})`
  - `get(String id, {required String moduleId})`
  - `getAll({required String moduleId, bool includeDeleted = false})`
  - `update(PolicyModel updatedModel, {required String moduleId})`
  - `delete(String id, {required String moduleId, required String editorId})`
  - `restore(String id, {required String moduleId, required String editorId})`

This will leave errors confined to `lib/features/grc/data/repository/policy_repository_impl.dart` (it still calls these methods without `moduleId`, and still calls `PolicyModel.create` without `moduleId` from Task 1) — expected, fixed in Task 3.

- [ ] **Step 1: Update `PolicyDataSource` (interface)**

Replace the full body of `lib/features/grc/data/data_source/policy_data_source.dart`'s `PolicyDataSource` class method signatures with:

```dart
abstract class PolicyDataSource {
  Future<PolicyModel> create(PolicyModel model, {required String moduleId});

  Future<PolicyModel?> get(String id, {required String moduleId});

  Future<List<PolicyModel>> getAll({
    required String moduleId,
    bool includeDeleted = false,
  });

  Future<PolicyModel> update(PolicyModel updatedModel, {required String moduleId});

  Future<PolicyModel> delete(
    String id, {
    required String moduleId,
    required String editorId,
  });

  Future<PolicyModel> restore(
    String id, {
    required String moduleId,
    required String editorId,
  });
}
```

Keep the existing file's doc comments above the class as-is (only the method signatures inside change).

- [ ] **Step 2: Update `PolicyFirebaseDataSource` to use a per-module subcollection**

Replace the collection accessor and all six methods in `lib/features/grc/data/data_source/policy_firebase_data_source.dart`:

```dart
  static const String _modulesCollectionPath = 'GRC Modules';
  static const String _policiesSubcollectionPath = 'Policies';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_policiesSubcollectionPath);

  @override
  Future<PolicyModel> create(PolicyModel model, {required String moduleId}) async {
    try {
      await _collection(moduleId).doc(model.id).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Policy: $e');
    }
  }

  @override
  Future<PolicyModel?> get(String id, {required String moduleId}) async {
    try {
      final doc = await _collection(moduleId).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return PolicyModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Policy: $e');
    }
  }

  @override
  Future<List<PolicyModel>> getAll({
    required String moduleId,
    bool includeDeleted = false,
  }) async {
    try {
      final snapshot = await _collection(moduleId).get();
      final models =
          snapshot.docs.map((doc) => PolicyModel.fromJson(doc.data()));
      if (includeDeleted) return models.toList();
      return models.where((m) => !m.isDeleted.last).toList();
    } catch (e) {
      throw Exception('Failed to fetch the Policies: $e');
    }
  }

  @override
  Future<PolicyModel> update(PolicyModel updatedModel, {required String moduleId}) async {
    try {
      final docRef = _collection(moduleId).doc(updatedModel.id);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a Policy that does not exist (id: ${updatedModel.id})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the Policy: $e');
    }
  }

  @override
  Future<PolicyModel> delete(
    String id, {
    required String moduleId,
    required String editorId,
  }) async {
    try {
      final current = await get(id, moduleId: moduleId);
      if (current == null) {
        throw Exception(
          'Cannot delete a Policy that does not exist (id: $id)',
        );
      }
      final deletedModel = current.copyWithUpdate(
        isDeleted: true,
        editorId: editorId,
      );
      await _collection(moduleId).doc(id).set(deletedModel.toJson());
      return deletedModel;
    } catch (e) {
      throw Exception('Failed to delete the Policy: $e');
    }
  }

  @override
  Future<PolicyModel> restore(
    String id, {
    required String moduleId,
    required String editorId,
  }) async {
    try {
      final current = await get(id, moduleId: moduleId);
      if (current == null) {
        throw Exception(
          'Cannot restore a Policy that does not exist (id: $id)',
        );
      }
      final restoredModel = current.copyWithUpdate(
        isDeleted: false,
        editorId: editorId,
      );
      await _collection(moduleId).doc(id).set(restoredModel.toJson());
      return restoredModel;
    } catch (e) {
      throw Exception('Failed to restore the Policy: $e');
    }
  }
```

Remove the old `static const String _collectionPath = 'Policies';` and the old `_collection` getter — both are replaced by the two constants and the `_collection(moduleId)` method above.

- [ ] **Step 3: Confirm expected (and only expected) analyze errors**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`
Expected: new `error`-severity lines ONLY in `lib/features/grc/data/repository/policy_repository_impl.dart`. No errors in `policy_data_source.dart` or `policy_firebase_data_source.dart` themselves.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/data/data_source/policy_data_source.dart lib/features/grc/data/data_source/policy_firebase_data_source.dart
git commit -m "feat(grc): store Policies as a subcollection under GRC Modules"
```

---

### Task 3: `PolicyRepository` + `PolicyRepositoryImpl` — require `moduleId`

**Files:**
- Modify: `lib/features/grc/domain/repository/policy_repository.dart`
- Modify: `lib/features/grc/data/repository/policy_repository_impl.dart`

**Interfaces:**
- Consumes: `PolicyDataSource`/`PolicyFirebaseDataSource` (Task 2), `PolicyModel.create({required moduleId})` (Task 1).
- Produces: every `PolicyRepository`/`PolicyRepositoryImpl` method now takes `required String moduleId`:
  - `createPolicy({..., required String moduleId})`
  - `getPolicy(String id, {required String moduleId})`
  - `getAllPolicies({required String moduleId, bool includeDeleted = false})`
  - `updatePolicy({..., required String moduleId})`
  - `deletePolicy({required String id, required String editorId, required String moduleId})`
  - `restorePolicy({required String id, required String editorId, required String moduleId})`

This will leave errors confined to `lib/features/grc/domain/use_cases/create_policy_usecase.dart`, `update_policy_usecase.dart`, and `get_policy_usecases.dart` (they call these repository methods without `moduleId`) — expected, fixed in Task 4.

- [ ] **Step 1: Update `PolicyRepository` (interface)**

In `lib/features/grc/domain/repository/policy_repository.dart`:

`createPolicy` — add `required String moduleId,` to the parameter list (put it right after `required String editorId,`):

```dart
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
    required List<CreateControlParams> controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
    required PolicyStatus status,
  });
```

`getPolicy` — change to:

```dart
  Future<Either<Failure, PolicyEntity>> getPolicy(
    String id, {
    required String moduleId,
  });
```

`getAllPolicies` — change to:

```dart
  Future<Either<Failure, List<PolicyEntity>>> getAllPolicies({
    required String moduleId,
    bool includeDeleted = false,
  });
```

`updatePolicy` — add `required String moduleId,` right after `required String editorId,`:

```dart
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
    List<CreateControlParams>? controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
    PolicyStatus? status,
  });
```

`deletePolicy` — add `required String moduleId,`:

```dart
  Future<Either<Failure, PolicyEntity>> deletePolicy({
    required String id,
    required String editorId,
    required String moduleId,
  });
```

`restorePolicy` — add `required String moduleId,`:

```dart
  Future<Either<Failure, PolicyEntity>> restorePolicy({
    required String id,
    required String editorId,
    required String moduleId,
  });
```

- [ ] **Step 2: Update `PolicyRepositoryImpl`**

In `lib/features/grc/data/repository/policy_repository_impl.dart`:

`createPolicy` — add `required String moduleId,` to the parameter list (after `required String editorId,`), pass it to `PolicyModel.create` and to `_firebaseDataSource.create`:

```dart
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
    required List<CreateControlParams> controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
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

      final resolvedDocument = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: policyId,
          documentFile: policyDocumentFile!,
        ),
        file: policyDocumentFile,
        fallbackUrl: policyDocumentUrl,
      );

      final controlModels = await _buildControlModels(
        policyId: policyId,
        params: controls,
        editorId: editorId,
      );

      final model = PolicyModel.create(
        id: policyId,
        moduleId: moduleId,
        image: resolvedImage ?? '',
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        policyDocument: resolvedDocument ?? '',
        controls: controlModels,
        editorId: editorId,
        status: status,
      );

      final created = await _firebaseDataSource.create(model, moduleId: moduleId);
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

`getPolicy` — change to:

```dart
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
```

`getAllPolicies` — change to:

```dart
  Future<Either<Failure, List<PolicyEntity>>> getAllPolicies({
    required String moduleId,
    bool includeDeleted = false,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        includeDeleted: includeDeleted,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

`updatePolicy` — add `required String moduleId,` (after `required String editorId,`), pass it to both `_firebaseDataSource.get` and `_firebaseDataSource.update`:

```dart
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
    List<CreateControlParams>? controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
    PolicyStatus? status,
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

      final resolvedDocument = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: id,
          documentFile: policyDocumentFile!,
        ),
        file: policyDocumentFile,
        fallbackUrl: policyDocumentUrl,
      );

      List<ControlModel>? controlModels;
      if (controls != null) {
        controlModels = await _buildControlModels(
          policyId: id,
          params: controls,
          editorId: editorId,
        );
      }

      final updatedModel = currentModel.copyWithUpdate(
        image: resolvedImage,
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        policyDocument: resolvedDocument,
        controls: controlModels,
        editorId: editorId,
      );

      final saved = await _firebaseDataSource.update(updatedModel, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

`deletePolicy` — add `required String moduleId,`, pass to data source:

```dart
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
```

`restorePolicy` — add `required String moduleId,`, pass to data source:

```dart
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
```

Leave `_buildControlModels` and `_resolveFile` unchanged.

- [ ] **Step 3: Confirm expected (and only expected) analyze errors**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`
Expected: new `error`-severity lines ONLY in `lib/features/grc/domain/use_cases/create_policy_usecase.dart`, `update_policy_usecase.dart`, and `get_policy_usecases.dart`. No errors in `policy_repository.dart` or `policy_repository_impl.dart` themselves.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/domain/repository/policy_repository.dart lib/features/grc/data/repository/policy_repository_impl.dart
git commit -m "feat(grc): require moduleId on every PolicyRepository operation"
```

---

### Task 4: Policy use cases — require `moduleId`

**Files:**
- Modify: `lib/features/grc/domain/use_cases/create_policy_usecase.dart`
- Modify: `lib/features/grc/domain/use_cases/update_policy_usecase.dart`
- Modify: `lib/features/grc/domain/use_cases/get_policy_usecases.dart`

**Interfaces:**
- Consumes: `PolicyRepository` (Task 3, now requiring `moduleId` on every method).
- Produces:
  - `CreatePolicyParams.moduleId` (`String`, required)
  - `UpdatePolicyParams.moduleId` (`String`, required)
  - `GetPolicyUseCase.call(String id, {required String moduleId})`
  - `GetAllPoliciesUseCase.call({required String moduleId, bool includeDeleted = false})`
  - `DeletePolicyParams.moduleId` (`String`, required)
  - `RestorePolicyParams.moduleId` (`String`, required)

This will leave errors confined to `lib/features/grc/presentation/controller/policy_cubit.dart` (it calls these use cases without `moduleId`) — expected, fixed in Task 5.

- [ ] **Step 1: `create_policy_usecase.dart`**

In `CreatePolicyParams`, add the field (right after `final String editorId;`) and its constructor param (right after `required this.editorId,`):

```dart
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
  final List<CreateControlParams> controls;
  final PolicyStatus status;
  final File? imageFile;
  final String? imageUrl;
  final File? policyDocumentFile;
  final String? policyDocumentUrl;

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
    required this.controls,
    required this.status,
    this.imageFile,
    this.imageUrl,
    this.policyDocumentFile,
    this.policyDocumentUrl,
  });
}
```

In `CreatePolicyUseCase.call`, add `moduleId: params.moduleId,` to the `_repository.createPolicy(...)` call:

```dart
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
      controls: params.controls,
      imageFile: params.imageFile,
      imageUrl: params.imageUrl,
      policyDocumentFile: params.policyDocumentFile,
      policyDocumentUrl: params.policyDocumentUrl,
    );
  }
```

- [ ] **Step 2: `update_policy_usecase.dart`**

In `UpdatePolicyParams`, add the field (right after `final String editorId;`) and its constructor param (right after `required this.editorId,`):

```dart
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
  final List<CreateControlParams>? controls;
  final PolicyStatus? status;
  final File? imageFile;
  final String? imageUrl;
  final File? policyDocumentFile;
  final String? policyDocumentUrl;

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
    this.controls,
    this.status,
    this.imageFile,
    this.imageUrl,
    this.policyDocumentFile,
    this.policyDocumentUrl,
  });
}
```

In `UpdatePolicyUseCase.call`, add `moduleId: params.moduleId,` to the `_repository.updatePolicy(...)` call:

```dart
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
      controls: params.controls,
      status: params.status,
      imageFile: params.imageFile,
      imageUrl: params.imageUrl,
      policyDocumentFile: params.policyDocumentFile,
      policyDocumentUrl: params.policyDocumentUrl,
    );
  }
```

- [ ] **Step 3: `get_policy_usecases.dart`**

`GetPolicyUseCase.call` — change to:

```dart
  Future<Either<Failure, PolicyEntity>> call(
    String id, {
    required String moduleId,
  }) {
    return _repository.getPolicy(id, moduleId: moduleId);
  }
```

`GetAllPoliciesUseCase.call` — change to:

```dart
  Future<Either<Failure, List<PolicyEntity>>> call({
    required String moduleId,
    bool includeDeleted = false,
  }) {
    return _repository.getAllPolicies(
      moduleId: moduleId,
      includeDeleted: includeDeleted,
    );
  }
```

`DeletePolicyParams` — add `final String moduleId;` and `required this.moduleId,`:

```dart
class DeletePolicyParams {
  final String id;
  final String editorId;
  final String moduleId;

  const DeletePolicyParams({
    required this.id,
    required this.editorId,
    required this.moduleId,
  });
}
```

`DeletePolicyUseCase.call` — add `moduleId: params.moduleId,`:

```dart
  Future<Either<Failure, PolicyEntity>> call(DeletePolicyParams params) {
    return _repository.deletePolicy(
      id: params.id,
      editorId: params.editorId,
      moduleId: params.moduleId,
    );
  }
```

`RestorePolicyParams` — add `final String moduleId;` and `required this.moduleId,`:

```dart
class RestorePolicyParams {
  final String id;
  final String editorId;
  final String moduleId;

  const RestorePolicyParams({
    required this.id,
    required this.editorId,
    required this.moduleId,
  });
}
```

`RestorePolicyUseCase.call` — add `moduleId: params.moduleId,`:

```dart
  Future<Either<Failure, PolicyEntity>> call(RestorePolicyParams params) {
    return _repository.restorePolicy(
      id: params.id,
      editorId: params.editorId,
      moduleId: params.moduleId,
    );
  }
```

- [ ] **Step 4: Confirm expected (and only expected) analyze errors**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`
Expected: new `error`-severity lines ONLY in `lib/features/grc/presentation/controller/policy_cubit.dart`. No errors in the three use-case files themselves.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/domain/use_cases/create_policy_usecase.dart lib/features/grc/domain/use_cases/update_policy_usecase.dart lib/features/grc/domain/use_cases/get_policy_usecases.dart
git commit -m "feat(grc): require moduleId on all Policy use cases"
```

---

### Task 5: `PolicyCubit` — require `moduleId`

**Files:**
- Modify: `lib/features/grc/presentation/controller/policy_cubit.dart`

**Interfaces:**
- Consumes: the four use cases (Task 4, now requiring `moduleId`).
- Produces: every public `PolicyCubit` method now takes `required String moduleId`:
  - `getAllPolicies({required String moduleId, bool includeDeleted = false})`
  - `getPolicy(String id, {required String moduleId})`
  - `createPolicy({..., required String moduleId})`
  - `saveAsDraft({..., required String moduleId})`
  - `updatePolicy({required String id, ..., required String moduleId})`
  - `deletePolicy({required String id, required String moduleId})`
  - `restorePolicy({required String id, required String moduleId})`

This will leave errors confined to `lib/features/grc/presentation/ui/pages/create_new_policy.dart` (calls `cubit.saveAsDraft`/`cubit.createPolicy` without `moduleId`) — expected, fixed in Task 6.

- [ ] **Step 1: Update every public method**

In `lib/features/grc/presentation/controller/policy_cubit.dart`:

`getAllPolicies`:

```dart
  Future<void> getAllPolicies({
    required String moduleId,
    bool includeDeleted = false,
  }) async {
    emit(PolicyLoading());
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeDeleted: includeDeleted,
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policies) => emit(PolicyListLoaded(policies)),
    );
  }
```

`getPolicy`:

```dart
  Future<void> getPolicy(String id, {required String moduleId}) async {
    emit(PolicyLoading());
    final result = await _getUseCase.call(id, moduleId: moduleId);
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicySingleLoaded(policy)),
    );
  }
```

`createPolicy` — add `required String moduleId,` to the parameter list (after `required List<CreateControlParams> controls,`) and `moduleId: moduleId,` to the `CreatePolicyParams(...)` call:

```dart
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
    required List<CreateControlParams> controls,
    required String moduleId,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
  }) async {
    emit(PolicyLoading());
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
        editorId: _currentUserId,
        moduleId: moduleId,
        controls: controls,
        status: PolicyStatus.active,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFile: policyDocumentFile,
        policyDocumentUrl: policyDocumentUrl,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }
```

`saveAsDraft` — same shape as `createPolicy` (add `required String moduleId,` and pass `moduleId: moduleId,` into `CreatePolicyParams`, keep `status: PolicyStatus.draft`):

```dart
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
    required List<CreateControlParams> controls,
    required String moduleId,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
  }) async {
    emit(PolicyLoading());
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
        editorId: _currentUserId,
        moduleId: moduleId,
        controls: controls,
        status: PolicyStatus.draft,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFile: policyDocumentFile,
        policyDocumentUrl: policyDocumentUrl,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }
```

`updatePolicy` — add `required String moduleId,` (after `required String id,`) and `moduleId: moduleId,` to `UpdatePolicyParams(...)`:

```dart
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
    List<CreateControlParams>? controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFile,
    String? policyDocumentUrl,
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
        controls: controls,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFile: policyDocumentFile,
        policyDocumentUrl: policyDocumentUrl,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }
```

`deletePolicy`:

```dart
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
```

`restorePolicy`:

```dart
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
```

- [ ] **Step 2: Confirm expected (and only expected) analyze errors**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`
Expected: new `error`-severity lines ONLY in `lib/features/grc/presentation/ui/pages/create_new_policy.dart`. No errors in `policy_cubit.dart` itself.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/presentation/controller/policy_cubit.dart
git commit -m "feat(grc): require moduleId on every PolicyCubit method"
```

---

### Task 6: `CreateNewPolicyPage` — accept and forward `moduleId`

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/create_new_policy.dart`

**Interfaces:**
- Consumes: `PolicyCubit.createPolicy`/`saveAsDraft` (Task 5, now requiring `moduleId`).
- Produces: `CreateNewPolicyPage({super.key, required String moduleId})`. Later tasks construct it as `CreateNewPolicyPage(moduleId: <id>)`.

This will leave errors confined to `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart` (its two `CreateNewPolicyPage()` call sites don't pass `moduleId`) — expected, fixed in Task 7.

- [ ] **Step 1: Add the constructor field**

In `lib/features/grc/presentation/ui/pages/create_new_policy.dart`, change:

```dart
class CreateNewPolicyPage extends StatefulWidget {
  const CreateNewPolicyPage({super.key});

  @override
  State<CreateNewPolicyPage> createState() => _CreateNewPolicyPageState();
}
```

to:

```dart
class CreateNewPolicyPage extends StatefulWidget {
  final String moduleId;

  const CreateNewPolicyPage({super.key, required this.moduleId});

  @override
  State<CreateNewPolicyPage> createState() => _CreateNewPolicyPageState();
}
```

- [ ] **Step 2: Forward it to the cubit**

In `_onSaveForLater`, add `moduleId: widget.moduleId,` to the `cubit.saveAsDraft(...)` call (after `controls: _buildControlParams(),`):

```dart
  void _onSaveForLater(PolicyCubit cubit) {
    cubit.saveAsDraft(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      controls: _buildControlParams(),
      moduleId: widget.moduleId,
    );
  }
```

In `_onPublish`, add `moduleId: widget.moduleId,` to the `cubit.createPolicy(...)` call the same way:

```dart
    cubit.createPolicy(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      controls: _buildControlParams(),
      moduleId: widget.moduleId,
    );
```

- [ ] **Step 3: Confirm expected (and only expected) analyze errors**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`
Expected: new `error`-severity lines ONLY in `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart` (two call sites missing `moduleId`). No errors in `create_new_policy.dart` itself.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/create_new_policy.dart
git commit -m "feat(grc): CreateNewPolicyPage requires and forwards moduleId"
```

---

### Task 7: `GrcModuleDetailsPage` — scope to one module with a real policy list

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart`

**Interfaces:**
- Consumes: `GRCModuleEntity` (existing), `PolicyCubit`/`PolicyState`/`PolicyEntity`/`PolicyStatus` (existing + Tasks 1–5), `CreateNewPolicyPage({required moduleId})` (Task 6), `ModuleInfoCard`/`CardInfo` (existing, from `lib/core/custom/43_custom_module_info_card.dart` and `lib/core/custom/16-custom_card_styles.dart`), `context.isArabic` (existing, from `lib/core/extension/context_extensions.dart`).
- Produces: `GrcModuleDetailsPage({super.key, required GRCModuleEntity module})`. Task 8 constructs it as `GrcModuleDetailsPage(module: entity)`.

This will leave one remaining error in `lib/features/grc/presentation/ui/pages/grc_page.dart` (the top "Dashboard" button still calls `GrcModuleDetailsPage()` with no `module`) — expected, fixed in Task 8.

- [ ] **Step 1: Replace the whole file**

Replace the entire contents of `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart` with:

```dart
/// Module: GRC Module Management
/// Description: Provides the GRC dashboard/details page showing module
///              analytics, filter tabs, and quick-action buttons.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-28
/// Dependencies: Flutter SDK, AppColors, AppTheme, PaginationAppBar,
///               PolicyCubit, GRCModuleEntity
/// Revision History: 2026-06-28 - Initial creation
///                   2026-07-06 - Scoped to a single GRC Module: real title,
///                                real policy list/counts from PolicyCubit,
///                                Create Policy now passes moduleId
///                                (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_details_page.dart
/// Purpose: Contains GrcModuleDetailsPage, the GRC dashboard screen scoped
///          to a single GRC Module and its Policies.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/6/2026

import 'package:demo_app/core/custom/10-custom_tabs.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/custom/37-custom_navigate.dart';
import 'package:demo_app/core/custom/43_custom_module_info_card.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/create_new_policy.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// class name: [GrcModuleDetailsPage]
///
/// purpose: GRC dashboard screen scoped to a single [GRCModuleEntity].
///          Provides a [PolicyCubit] that loads every Policy belonging to
///          [module] and renders the real status counts and policy list.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GrcModuleDetailsPage extends StatelessWidget {
  final GRCModuleEntity module;

  const GrcModuleDetailsPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<PolicyCubit>()
        ..getAllPolicies(moduleId: module.id),
      child: _GrcModuleDetailsBody(module: module),
    );
  }
}

class _GrcModuleDetailsBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _GrcModuleDetailsBody({required this.module});

  @override
  State<_GrcModuleDetailsBody> createState() => _GrcModuleDetailsBodyState();
}

class _GrcModuleDetailsBodyState extends State<_GrcModuleDetailsBody> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PolicyEntity> _applySearch(List<PolicyEntity> policies) {
    if (_searchQuery.isEmpty) return policies;
    final q = _searchQuery.toLowerCase();
    return policies
        .where((p) =>
            p.policyNameEn.toLowerCase().contains(q) ||
            p.policyNameAr.toLowerCase().contains(q))
        .toList();
  }

  Map<String, int> _countByStatus(List<PolicyEntity> policies) {
    return {
      'all': policies.length,
      'Active': policies.where((p) => p.status == PolicyStatus.active).length,
      'Inactive':
          policies.where((p) => p.status == PolicyStatus.inactive).length,
      'Expired':
          policies.where((p) => p.status == PolicyStatus.expired).length,
      'Draft': policies.where((p) => p.status == PolicyStatus.draft).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return BlocBuilder<PolicyCubit, PolicyState>(
      builder: (context, state) {
        final allPolicies =
            state is PolicyListLoaded ? state.policies : <PolicyEntity>[];
        final counts = _countByStatus(allPolicies);
        final filtered = _applySearch(allPolicies);

        final List<MapEntry<String, Map<String, dynamic>>> status = [
          MapEntry(
              'all', {'num': counts['all'] ?? 0, 'color': AppColors.text}),
          MapEntry('Active',
              {'num': counts['Active'] ?? 0, 'color': AppColors.green}),
          MapEntry('Inactive',
              {'num': counts['Inactive'] ?? 0, 'color': AppColors.orange}),
          MapEntry('Expired',
              {'num': counts['Expired'] ?? 0, 'color': AppColors.red}),
          MapEntry('Draft',
              {'num': counts['Draft'] ?? 0, 'color': AppColors.colorGrey}),
        ];

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                    screensTitles: [
                      'GRC'.tr,
                      context.isArabic
                          ? widget.module.grcModuleNameArabic
                          : widget.module.grcModuleNameEnglish,
                    ],
                  ),

                  // Approved Evidence + Dashboard
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      customButtonWithSvg(
                        colorBorder: AppColors.primary,
                        space: 10.w,
                        radius: 8.r,
                        widthImage: 16.w,
                        heightImage: 16.h,
                        image: "assets/icons/edit.svg",
                        title: "Approved Evidence".tr,
                        function: () {},
                        width: isTablet ? 200.w : 180.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                      customButton(
                        title: "Dashboard".tr,
                        function: () {},
                        width: 135.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  // Approvals + Assignment Controls + My Audits
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      customButton(
                        title: "Approvals".tr,
                        function: () {},
                        width: 120.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                      customButton(
                        title: "Assignment Controls".tr,
                        function: () {},
                        width: isTablet ? 180.w : 170.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                      customButton(
                        title: "My Audits".tr,
                        function: () {},
                        width: 120.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  CustomTabs(
                    tabs: ['All', 'Pending', 'Approved'],
                    selectedValue: 0,
                    onChanged: (_) {},
                  ),
                  SizedBox(height: 15.h),

                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 30.sp,
                        children: [
                          for (var roleEntry in status)
                            FilterBarItem(
                              title: roleEntry.key,
                              numberOfItems: roleEntry.value['num'],
                              color: roleEntry.value['color'],
                              onTap: () {},
                              isSelected: roleEntry.key == 'all',
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Search + Create Policy — stack on mobile
                  if (isTablet)
                    Row(
                      spacing: 10.w,
                      children: [
                        AppSearchTextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          hintText: "Search".tr,
                          controller: _searchController,
                        ),
                        customButtonWithSvg(
                          colorBorder: AppColors.primary,
                          space: 10.w,
                          radius: 8.r,
                          widthImage: 16.w,
                          heightImage: 16.h,
                          function: () => navigateTo(
                            context,
                            CreateNewPolicyPage(moduleId: widget.module.id),
                          ),
                          title: 'Policy',
                          textStyle: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.textButton),
                          image: 'assets/icons/add.svg',
                          color: AppColors.primary,
                          width: 140.w,
                          height: 36.h,
                          svgColor: AppColors.textButton,
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            AppSearchTextField(
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              hintText: "Search".tr,
                              controller: _searchController,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        customButtonWithSvg(
                          colorBorder: AppColors.primary,
                          space: 10.w,
                          radius: 8.r,
                          widthImage: 16.w,
                          heightImage: 16.h,
                          function: () => navigateTo(
                            context,
                            CreateNewPolicyPage(moduleId: widget.module.id),
                          ),
                          title: 'Policy',
                          textStyle: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.textButton),
                          image: 'assets/icons/add.svg',
                          color: AppColors.primary,
                          width: double.infinity,
                          height: 36.h,
                          svgColor: AppColors.textButton,
                        ),
                      ],
                    ),
                  SizedBox(height: 15.h),

                  // Policy Weight Issue + view-mode icons
                  Row(
                    children: [
                      customButton(
                        title: "Policy Weight Issue".tr,
                        function: () {},
                        width: isTablet ? 180.w : 160.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                      const Spacer(),
                      Container(
                        width: 38.sp,
                        height: 38.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/tableView.svg",
                            width: 20.sp,
                            height: 20.sp,
                            fit: BoxFit.scaleDown,
                            semanticsLabel: 'Table View',
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Container(
                        width: 38.sp,
                        height: 38.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/gridView.svg",
                            width: 20.sp,
                            height: 20.sp,
                            fit: BoxFit.scaleDown,
                            semanticsLabel: 'Table View',
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  Expanded(
                    child: _buildPolicyList(context, state, filtered),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolicyList(
    BuildContext context,
    PolicyState state,
    List<PolicyEntity> policies,
  ) {
    if (state is PolicyLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is PolicyFailure) {
      return Center(
        child: Text(
          state.message,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (policies.isEmpty) {
      return Center(
        child: Text(
          'No Policies found'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        itemCount: policies.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) => _PolicyCard(policy: policies[index]),
      ),
    );
  }
}

// ── Policy list card ─────────────────────────────────────────────────────────

/// class name: [_PolicyCard]
///
/// purpose: private list-item card that displays a single [PolicyEntity]
///          with its name, number, status, and last-update date. Tapping is
///          a no-op for now — there is no Policy view/edit page yet.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 6/7/2026
class _PolicyCard extends StatelessWidget {
  final PolicyEntity policy;

  const _PolicyCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    return ModuleInfoCard(
      width: double.infinity,
      title: context.isArabic ? policy.policyNameAr : policy.policyNameEn,
      infoRows: [
        CardInfo(
          label: context.isArabic ? 'الرقم :' : 'Number :',
          value: context.isArabic
              ? policy.policyNumberAr
              : policy.policyNumberEn,
        ),
      ],
      complianceLabel: context.isArabic ? 'الحالة:' : 'Status:',
      complianceScore: policy.status.value.tr,
      footerLabel: context.isArabic ? 'آخر تحديث:' : 'Last Update:',
      footerValue: DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
          .format(policy.lastModifiedDate),
    );
  }
}
```

- [ ] **Step 2: Confirm expected (and only expected) analyze errors**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`
Expected: new `error`-severity line(s) ONLY in `lib/features/grc/presentation/ui/pages/grc_page.dart` (top "Dashboard" button constructs `GrcModuleDetailsPage()` with no `module`). No errors in `grc_module_details_page.dart` itself.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/grc_module_details_page.dart
git commit -m "feat(grc): scope GrcModuleDetailsPage to a single module with a real policy list"
```

---

### Task 8: `grc_page.dart` — navigation and top button

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/grc_page.dart`

**Interfaces:**
- Consumes: `GrcModuleDetailsPage({required GRCModuleEntity module})` (Task 7).
- Produces: nothing new consumed by later tasks — this is the top of the chain.

After this task, `flutter analyze lib/features/grc test/features/grc` must be back to the 41-issue, 0-error baseline (give or take line-number shifts from edits).

- [ ] **Step 1: Remove the top "Dashboard" button**

In `_GovernanceRiskAndCompliancePageState.build`, delete this whole block (currently right after the `PaginationAppBar` and before `SizedBox(height: 16.h)`):

```dart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      customButton(
                        title: "Dashboard".tr,
                        function: () {
                          navigateTo(context, GrcModuleDetailsPage());
                        },
                        width: 135.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                    ],
                  ),
```

Leave the `SizedBox(height: 16.h)` that follows it in place, so the `PaginationAppBar` is directly followed by that spacer.

- [ ] **Step 2: Change card-tap navigation**

In `_buildBody`, change `cardFor`:

```dart
        _GrcModuleCard cardFor(int index) => _GrcModuleCard(
              module: moduleAt(index),
              onTap: () => _openDetails(
                context,
                moduleAt(index).isDeleted
                    ? GrcPageMode.restore
                    : GrcPageMode.view,
                entity: moduleAt(index),
              ),
            );
```

to:

```dart
        _GrcModuleCard cardFor(int index) => _GrcModuleCard(
              module: moduleAt(index),
              onTap: () {
                final entity = moduleAt(index);
                if (entity.isDeleted) {
                  _openDetails(context, GrcPageMode.restore, entity: entity);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GrcModuleDetailsPage(module: entity),
                    ),
                  );
                }
              },
            );
```

- [ ] **Step 3: Confirm analyze is back to baseline**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`
Expected: 0 `error`-severity lines, and the issue count/content matches the pre-existing baseline (41 issues, all `info`/`warning`, same as before this plan — the removed "Dashboard" block doesn't touch the pre-existing unused-import warning on `grc_page.dart:18`, which stays).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/grc_page.dart
git commit -m "feat(grc): tapping a module card opens its scoped GrcModuleDetailsPage"
```

---

### Task 9: Full verification

**Files:** none (verification only).

- [ ] **Step 1: Run the full test suite**

Run: `/Users/bstar/.puro/bin/puro flutter test`
Expected: PASS — `test/features/grc/policy_model_nested_array_test.dart` (pre-existing), `test/features/grc/policy_model_module_id_test.dart` (Task 1), and `test/widget_test.dart` all pass.

- [ ] **Step 2: Run the scoped analyze one more time**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc test/features/grc`
Expected: 0 `error`-severity lines (same pre-existing 41 `info`/`warning` issues as the documented baseline).

- [ ] **Step 3: Manual verification checklist**

This step needs a running app connected to a real Firebase project, which this plan cannot execute — hand this checklist to whoever runs the app next:

- [ ] Open the GRC Modules list, tap a non-deleted module card → `GrcModuleDetailsPage` opens showing that module's real name in the title (not `"GRC Module Name"`), and an empty policy list (`"No Policies found"`) if it has none yet.
- [ ] Tap a deleted (Removed) module card → still opens the existing restore flow (`GovernanceRiskAndComplianceDetails` in restore mode), unchanged.
- [ ] From a module's details page, tap "Policy" to create one, fill it in, and Publish.
- [ ] Back on the module's details page, the new policy appears in the list and the status counts (`Active`/`Draft`/etc.) reflect it.
- [ ] In the Firebase console, confirm the new policy document lives at `GRC Modules/{moduleId}/Policies/{policyId}` — not in a top-level `Policies` collection.
- [ ] Confirm the top "Dashboard" button above the modules list (in `grc_page.dart`) is gone.

- [ ] **Step 4: Update memory**

The project memory file `project_grc_status.md` (referenced from `MEMORY.md`) currently says the GRC Module & Policy layers are wired end-to-end as a flat structure. After this plan lands, update that memory to note Policies now live in a subcollection under GRC Modules, keyed by `moduleId`, since that's a structural fact future sessions need to know before writing more Policy-related code.
