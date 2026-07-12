# GRC Module Storage Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the GRC Module vertical slice compile again and align its Firestore storage with the rules in the design spec: tenant-scoped path, string-formatted dates, nullable image, owner emails (not ids), and a derived Scheduled/Active status.

**Architecture:** `GRCModuleModel`/`GRCModuleEntity` (`lib/features/grc/data/models/grc_module_model.dart`, `lib/features/grc/domain/entities/grc_module_entity.dart`) are the frozen target shape — every other file in the slice adapts to them. Fix flows bottom-up: model → Firestore/Storage data sources → repository → cubits → UI pages, so each task's fixes are consumable by the next.

**Tech Stack:** Flutter, `cloud_firestore`, `intl` (`DateFormat`), `flutter_bloc` (Cubit), `get_it`, `dartz` (`Either`).

**Spec:** `docs/superpowers/specs/2026-07-12-grc-module-storage-alignment-design.md`

## Global Constraints

- `GRCModuleModel`/`GRCModuleEntity` field names do not change (`moduleId`, `moduleNameEn`, `moduleImage`, etc.) — every task adapts to them, never the reverse.
- Firestore path for GRC Module records: `Demo/{companyId}/Modules/grc/GRC Modules/{moduleId}`, built via the existing `getBaseUrl('Modules')` helper (`lib/core/network/get_base_url.dart`) — never hand-parse `companyId`.
- Dates are stored as `d MMM yyyy` strings (e.g. `4 Jul 2026`) via `DateFormat('d MMM yyyy', 'en')` — locale pinned to `'en'` explicitly since the data layer has no `BuildContext` to read the app locale from. This is a storage format, independent of whatever locale the UI displays dates in.
- `Module_Image` / `moduleImage` is nullable (`String?` end-to-end) — write `null`, never `''`, when no image is set.
- `Module_Owners` / `moduleOwners` stores owner **email addresses**, not employee ids. `GRCModuleModel.moduleOwners`'s Dart *type* doesn't change (still `List<String>` of JSON-encoded per-revision lists) — only the semantic content of what's inside does.
- Status: `'Inactive'` and `'Removed'` are the only two states ever explicitly requested by a caller, and they're sticky (persist until an explicit later action changes them). Any other requested status (including the `'Active'` the status-switch UI already sends) is *derived*: `'Scheduled'` if `Activation_Date` is after today, else `'Active'`. This derivation runs both when writing (`GRCModuleModel.create`/`copyWithUpdate`) and when reading (`GRCModuleModel.toEntity()`).
- The `editorId` parameter name is unchanged across the repository interface, use cases, and cubit (out of scope to rename) — it now carries the acting user's **email**, not their id, matching what `modifierEmail` expects on the model. This is a pre-existing public API surface; only its meaning changes.
- **Sandbox limitation:** this environment has no Flutter SDK installed (`flutter` command not found; `dart test` fails resolving `flutter_test` from `sdk: flutter`). `dart analyze <path>` **is** confirmed working here and is the compile-correctness gate for every task below. `flutter test`/`flutter analyze` are the canonical commands and must additionally be run by the user (or CI) wherever the Flutter SDK is available — do not claim a test "passes" based on `dart analyze` alone, only that it compiles.

---

## File Structure

| File | Responsibility |
|---|---|
| `lib/features/grc/data/models/grc_module_model.dart` | Status derivation, date string (de)serialization, nullable image (Task 1) |
| `test/features/grc/grc_module_model_test.dart` (new) | Unit tests for the above (Task 1) |
| `lib/features/grc/domain/entities/grc_module_entity.dart` | `moduleImage` nullable (Task 2) |
| `lib/features/grc/data/data_source/grc_module_firebase_data_source.dart` | New collection path, `.moduleId`, status via `modifierEmail` (Task 3) |
| `lib/features/grc/data/repository/grc_module_repository_impl.dart` | Correct model param names, nullable image passthrough (Task 4) |
| `lib/features/grc/data/data_source/policy_firebase_data_source.dart` | One path constant, so Policies keep nesting under their module (Task 5) |
| `lib/features/grc/presentation/controller/grc_module_cubit.dart` | `_currentUserEmail` instead of `_currentUserId` (Task 6) |
| `lib/features/grc/presentation/controller/grc_owner_cubit.dart` | `OwnerData.email`, `loadOwners` param rename (Task 7) |
| `lib/features/grc/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart` | Prop rename to match (Task 7) |
| `lib/features/grc/presentation/ui/pages/grc_details_page.dart` | Renamed entity field references, owner emails (Task 8) |
| `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart` | Renamed entity field references (Task 9) |
| `lib/features/grc/presentation/ui/pages/grc_page.dart` | Renamed entity field references, `isRemoved`, owner-by-email lookup (Task 10) |

---

### Task 1: `GRCModuleModel` — derived status, string dates, nullable image

**Files:**
- Modify: `lib/features/grc/data/models/grc_module_model.dart`
- Test: `test/features/grc/grc_module_model_test.dart` (new)

**Interfaces:**
- Produces: `GRCModuleModel.create({required String moduleId, String? moduleImage, required String moduleNameEn, required String moduleNameAr, required String moduleDescriptionEn, required String moduleDescriptionAr, required String moduleOwningDepartment, required DateTime moduleActivationDate, required List<String> owners, required String status, required String modifierEmail})` — `moduleImage` becomes optional/nullable (was `required String`).
- Produces: `GRCModuleModel.copyWithUpdate({...same optional params..., required String modifierEmail})` — unchanged signature, changed internal derivation.
- Produces: `GRCModuleModel.moduleImage` is now `List<String?>` (was `List<String>`).
- Produces: `GRCModuleModel.toEntity()` returns a `GRCModuleEntity` whose `status` is the *derived* value and whose `moduleImage` is `String?` (Task 2 makes the entity field nullable to match).

- [ ] **Step 1: Write the failing test file**

Create `test/features/grc/grc_module_model_test.dart`:

```dart
import 'package:demo_app/features/grc/data/models/grc_module_model.dart';
import 'package:flutter_test/flutter_test.dart';

GRCModuleModel _buildModel({
  required DateTime activationDate,
  required String status,
  String? moduleImage,
}) {
  return GRCModuleModel.create(
    moduleId: 'm1',
    moduleImage: moduleImage,
    moduleNameEn: 'Module',
    moduleNameAr: 'وحدة',
    moduleDescriptionEn: 'desc',
    moduleDescriptionAr: 'وصف',
    moduleOwningDepartment: 'IT',
    moduleActivationDate: activationDate,
    owners: ['owner@example.com'],
    status: status,
    modifierEmail: 'editor@example.com',
  );
}

void main() {
  final future = DateTime.now().add(const Duration(days: 30));
  final past = DateTime.now().subtract(const Duration(days: 1));

  group('status derivation', () {
    test('future Activation_Date is Scheduled on create', () {
      final model = _buildModel(activationDate: future, status: 'Active');
      expect(model.toEntity().status, 'Scheduled');
    });

    test('past Activation_Date is Active on create', () {
      final model = _buildModel(activationDate: past, status: 'Active');
      expect(model.toEntity().status, 'Active');
    });

    test('explicit Inactive stays Inactive regardless of date', () {
      final pastModel = _buildModel(activationDate: past, status: 'Inactive');
      expect(pastModel.toEntity().status, 'Inactive');
      final futureModel =
          _buildModel(activationDate: future, status: 'Inactive');
      expect(futureModel.toEntity().status, 'Inactive');
    });

    test('explicit Removed stays Removed regardless of date', () {
      final model = _buildModel(activationDate: past, status: 'Removed');
      expect(model.toEntity().status, 'Removed');
    });

    test('restoring a future-dated module returns to Scheduled, not forced Active', () {
      final inactive = _buildModel(activationDate: future, status: 'Inactive');
      final restored = inactive.copyWithUpdate(
        status: 'Active',
        modifierEmail: 'editor2@example.com',
      );
      expect(restored.toEntity().status, 'Scheduled');
    });

    test('editing a field on an Inactive module keeps it Inactive', () {
      final inactive = _buildModel(activationDate: past, status: 'Inactive');
      final edited = inactive.copyWithUpdate(
        moduleNameEn: 'Renamed',
        modifierEmail: 'editor2@example.com',
      );
      expect(edited.toEntity().status, 'Inactive');
    });
  });

  group('date serialization', () {
    test('toJson stores Activation_Date as a d MMM yyyy string', () {
      final model =
          _buildModel(activationDate: DateTime(2026, 7, 4), status: 'Active');
      final json = model.toJson();
      expect(json['Module_Activation_Date'], ['4 Jul 2026']);
    });

    test('toJson/fromJson round-trips the activation date', () {
      final model =
          _buildModel(activationDate: DateTime(2026, 7, 4), status: 'Active');
      final rebuilt = GRCModuleModel.fromJson(model.toJson());
      expect(rebuilt.moduleActivationDate.last, DateTime(2026, 7, 4));
    });
  });

  group('image nullability', () {
    test('a module created without an image serializes Module_Image as null', () {
      final model =
          _buildModel(activationDate: past, status: 'Active', moduleImage: null);
      final json = model.toJson();
      expect(json['Module_Image'], [null]);
      expect(model.toEntity().moduleImage, isNull);
    });

    test('toJson/fromJson round-trips a null image', () {
      final model =
          _buildModel(activationDate: past, status: 'Active', moduleImage: null);
      final rebuilt = GRCModuleModel.fromJson(model.toJson());
      expect(rebuilt.moduleImage.last, isNull);
    });
  });
}
```

- [ ] **Step 2: Confirm the test file fails to compile against the current model**

Run: `dart analyze test/features/grc/grc_module_model_test.dart lib/features/grc/data/models/grc_module_model.dart`
Expected: errors — `moduleImage` param isn't nullable yet (`_buildModel` passes `null` where `String` is required), and `json['Module_Image']` won't be `[null]` (current code writes `''`, not implemented as an error but a future assertion mismatch you're about to fix).

- [ ] **Step 3: Implement the model changes**

In `lib/features/grc/data/models/grc_module_model.dart`:

Add the import (top of file, after `import 'dart:convert';`):

```dart
import 'package:intl/intl.dart';
```

Change the field declaration:

```dart
  final List<String?> moduleImage;
```

Add a private helper above the class (after imports):

```dart
final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

/// function name: [_deriveStatus]
///
/// purpose: 'Inactive' and 'Removed' are the only statuses a caller sets
///          explicitly, and they're sticky. Any other requested status
///          (including the default 'Active' the UI sends) is derived from
///          whether [activationDate] has arrived yet.
///
/// parameters:
///            [String] requestedStatus: the status a caller asked for
///            [DateTime] activationDate: the record's activation date
///
/// return type: [String] - 'Inactive' | 'Removed' | 'Scheduled' | 'Active'
String _deriveStatus({
  required String requestedStatus,
  required DateTime activationDate,
}) {
  if (requestedStatus == 'Inactive' || requestedStatus == 'Removed') {
    return requestedStatus;
  }
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return activationDate.isAfter(startOfToday) ? 'Scheduled' : 'Active';
}
```

Update `_allSameLength` — no change needed (nullability doesn't affect `.length`).

Update the `create` factory: change the `moduleImage` parameter to `String? moduleImage,` (drop `required`), and change the `status:` line:

```dart
  factory GRCModuleModel.create({
    required String moduleId,
    String? moduleImage,
    required String moduleNameEn,
    required String moduleNameAr,
    required String moduleDescriptionEn,
    required String moduleDescriptionAr,
    required String moduleOwningDepartment,
    required DateTime moduleActivationDate,
    required List<String> owners,
    required String status,
    required String modifierEmail,
  }) {
    final now = DateTime.now();
    return GRCModuleModel(
      moduleId: moduleId,
      moduleImage: [moduleImage],
      moduleNameEn: [moduleNameEn],
      moduleNameAr: [moduleNameAr],
      moduleDescriptionEn: [moduleDescriptionEn],
      moduleDescriptionAr: [moduleDescriptionAr],
      moduleOwningDepartment: [moduleOwningDepartment],
      moduleActivationDate: [moduleActivationDate],
      moduleOwners: [jsonEncode(owners)],
      status: [
        _deriveStatus(
          requestedStatus: status,
          activationDate: moduleActivationDate,
        ),
      ],
      modificationDate: [now],
      modifiers: [modifierEmail],
    );
  }
```

Update `copyWithUpdate`'s `status:` line (keep every other line as-is):

```dart
      status: [
        ...this.status,
        _deriveStatus(
          requestedStatus: status ?? this.status.last,
          activationDate: moduleActivationDate ?? this.moduleActivationDate.last,
        ),
      ],
```

Update `toJson()`'s date lines:

```dart
      'Module_Activation_Date':
          moduleActivationDate.map((d) => _storageDateFormat.format(d)).toList(),
      // Already JSON-encoded strings — stored as List<String> in Firestore.
      'Module_Owners': moduleOwners,
      'Status': status,
      'Modification_Date':
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
```

(`Module_Image` line is unchanged — `moduleImage` — Firestore accepts `null` array elements as-is.)

Update `fromJson()`:

```dart
      moduleImage: List<String?>.from(json['Module_Image'] ?? []),
```

```dart
      moduleActivationDate: (json['Module_Activation_Date'] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
```

```dart
      modificationDate: (json['Modification_Date'] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
```

Update `toEntity()`:

```dart
  GRCModuleEntity toEntity() {
    final currentActivationDate = moduleActivationDate.last;
    return GRCModuleEntity(
      moduleId: moduleId,
      moduleImage: moduleImage.last,
      moduleNameEn: moduleNameEn.last,
      moduleNameAr: moduleNameAr.last,
      moduleDescriptionEn: moduleDescriptionEn.last,
      moduleDescriptionAr: moduleDescriptionAr.last,
      moduleOwningDepartment: moduleOwningDepartment.last,
      moduleActivationDate: currentActivationDate,
      moduleOwners: List<String>.from(
        jsonDecode(moduleOwners.last) as List,
      ),
      status: _deriveStatus(
        requestedStatus: status.last,
        activationDate: currentActivationDate,
      ),
      createdAt: modificationDate.first,
      modificationDate: modificationDate.last,
      lastModifier: modifiers.last,
    );
  }
```

Also update the doc comment on `moduleOwners` (currently says "owner ids"):

```dart
  /// Each element is a JSON-encoded List<String> of owner **email addresses**.
  /// Firestore rejects nested arrays, so every revision's owner list is
  /// stored as jsonEncode(List<String>) and decoded on read.
  final List<String> moduleOwners;
```

- [ ] **Step 4: Verify the model and test file compile clean**

Run: `dart analyze lib/features/grc/data/models/grc_module_model.dart test/features/grc/grc_module_model_test.dart`
Expected: `No issues found!` (info-level "Dangling library doc comment" pre-existed and is out of scope; everything else must be clean)

- [ ] **Step 5: Run the tests (requires Flutter SDK — not available in this sandbox)**

Run: `flutter test test/features/grc/grc_module_model_test.dart -v`
Expected: all tests pass. If you're in an environment without Flutter, skip execution here but do not mark this task done until someone with Flutter confirms green — note that explicitly when reporting task status.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/data/models/grc_module_model.dart test/features/grc/grc_module_model_test.dart
git commit -m "feat(grc): derive module status from activation date, store dates as strings, make image nullable"
```

---

### Task 2: `GRCModuleEntity` — nullable image

**Files:**
- Modify: `lib/features/grc/domain/entities/grc_module_entity.dart`

**Interfaces:**
- Consumes: `GRCModuleModel.toEntity()` now passes `moduleImage: String?` (Task 1).
- Produces: `GRCModuleEntity.moduleImage` is `String?`; `copyWith({String? moduleImage, ...})` already accepted a nullable override param, but now `moduleImage ?? this.moduleImage` needs care — see step 2.

- [ ] **Step 1: Change the field type**

```dart
  final String? moduleImage;
```

- [ ] **Step 2: Fix `copyWith` so a caller can still pass `null` through unchanged**

`copyWith`'s existing `moduleImage: moduleImage ?? this.moduleImage,` line already does the right thing (nullable-in, nullable-out, `??` means "no override" — same pattern the rest of the class already uses for other fields). No change needed here beyond the field's type declaration in Step 1; leave `copyWith` as-is.

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/features/grc/domain/entities/grc_module_entity.dart lib/features/grc/data/models/grc_module_model.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/domain/entities/grc_module_entity.dart
git commit -m "feat(grc): make GRCModuleEntity.moduleImage nullable"
```

---

### Task 3: `GRCModuleFirebaseDataSource` — new path, fixed field references

**Files:**
- Modify: `lib/features/grc/data/data_source/grc_module_firebase_data_source.dart`

**Interfaces:**
- Consumes: `getBaseUrl(String path)` from `lib/core/network/get_base_url.dart` — returns `'${ApiConstants.baseUri}/$path'`, i.e. `'Demo/{companyId}/Modules'` for `getBaseUrl('Modules')`.
- Consumes: `GRCModuleModel.moduleId` (not `.id`), `GRCModuleModel.copyWithUpdate({String? status, required String modifierEmail, ...})` (Task 1).
- Produces: same public interface as before (`create`, `get`, `getAll`, `update`, `delete`, `restore`) — no signature changes, only internals and collection path.

- [ ] **Step 1: Add the import and replace the collection path**

Add near the top, after the `cloud_firestore` import:

```dart
import 'package:demo_app/core/network/get_base_url.dart';
```

Replace:

```dart
  static const String _collectionPath = 'GRC Modules';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionPath);
```

with:

```dart
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('${getBaseUrl('Modules')}/grc/GRC Modules');
```

- [ ] **Step 2: Fix `create` and `update` to use `.moduleId`**

In `create`, replace `_collection.doc(model.id).set(model.toJson());` with:

```dart
      await _collection.doc(model.moduleId).set(model.toJson());
```

In `update`, replace both `updatedModel.id` occurrences with `updatedModel.moduleId`:

```dart
  Future<GRCModuleModel> update(GRCModuleModel updatedModel) async {
    try {
      final docRef = _collection.doc(updatedModel.moduleId);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a Module that does not exist (id: ${updatedModel.moduleId})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the GRC Module: $e');
    }
  }
```

- [ ] **Step 3: Fix `getAll`'s soft-delete filtering (no more `isDeleted`)**

Replace:

```dart
      if (includeDeleted) return models.toList();
      return models.where((m) => !m.isDeleted.last).toList();
```

with:

```dart
      if (includeDeleted) return models.toList();
      return models.where((m) => m.status.last != 'Removed').toList();
```

- [ ] **Step 4: Fix `delete` and `restore` to use `status`/`modifierEmail` instead of `isDeleted`/`editorId`**

Replace `delete`'s body:

```dart
  @override
  Future<GRCModuleModel> delete(String id, {required String editorId}) async {
    try {
      final current = await get(id);
      if (current == null) {
        throw Exception('Cannot delete a Module that does not exist (id: $id)');
      }
      final deletedModel = current.copyWithUpdate(
        status: 'Removed',
        modifierEmail: editorId,
      );
      await _collection.doc(id).set(deletedModel.toJson());
      return deletedModel;
    } catch (e) {
      throw Exception('Failed to delete the GRC Module: $e');
    }
  }
```

Replace `restore`'s body:

```dart
  @override
  Future<GRCModuleModel> restore(String id, {required String editorId}) async {
    try {
      final current = await get(id);
      if (current == null) {
        throw Exception('Cannot restore a Module that does not exist (id: $id)');
      }
      final restoredModel = current.copyWithUpdate(
        status: 'Active',
        modifierEmail: editorId,
      );
      await _collection.doc(id).set(restoredModel.toJson());
      return restoredModel;
    } catch (e) {
      throw Exception('Failed to restore the GRC Module: $e');
    }
  }
```

(`status: 'Active'` here means "not manually paused" per the Global Constraints derivation rule — a restored module with a future `Activation_Date` correctly comes back as `Scheduled`, not forced `Active`. Covered by the Task 1 test `'restoring a future-dated module returns to Scheduled, not forced Active'`.)

- [ ] **Step 5: Verify it compiles**

Run: `dart analyze lib/features/grc/data/data_source/grc_module_firebase_data_source.dart`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/data/data_source/grc_module_firebase_data_source.dart
git commit -m "fix(grc): point GRCModuleFirebaseDataSource at Demo/{companyId}/Modules/grc and fix stale model references"
```

---

### Task 4: `GRCModuleRepositoryImpl` — correct model param names, nullable image

**Files:**
- Modify: `lib/features/grc/data/repository/grc_module_repository_impl.dart`

**Interfaces:**
- Consumes: `GRCModuleModel.create`/`copyWithUpdate` param names from Task 1 (`moduleId`, `moduleImage` (nullable), `moduleNameEn`, `moduleNameAr`, `moduleDescriptionEn`, `moduleDescriptionAr`, `moduleOwningDepartment`, `moduleActivationDate`, `owners`, `status`, `modifierEmail`).
- Produces: unchanged public `GRCModuleRepository` interface (`createModule`, `getModule`, `getAllModules`, `updateModule`, `deleteModule`, `restoreModule` — same param names as before, e.g. `grcModuleNameEnglish`, `editorId`).

- [ ] **Step 1: Fix `createModule`'s model construction**

Replace:

```dart
      final model = GRCModuleModel.create(
        id: id,
        image: resolvedImageUrl ?? '',
        grcModuleNameEnglish: grcModuleNameEnglish,
        grcModuleNameArabic: grcModuleNameArabic,
        descriptionEnglish: descriptionEnglish,
        descriptionArabic: descriptionArabic,
        owningDepartment: owningDepartment,
        activationDate: activationDate,
        owners: owners,
        status: status,
        editorId: editorId,
      );
```

with:

```dart
      final model = GRCModuleModel.create(
        moduleId: id,
        moduleImage: resolvedImageUrl,
        moduleNameEn: grcModuleNameEnglish,
        moduleNameAr: grcModuleNameArabic,
        moduleDescriptionEn: descriptionEnglish,
        moduleDescriptionAr: descriptionArabic,
        moduleOwningDepartment: owningDepartment,
        moduleActivationDate: activationDate,
        owners: owners,
        status: status,
        modifierEmail: editorId,
      );
```

- [ ] **Step 2: Fix `updateModule`'s `copyWithUpdate` call**

Replace:

```dart
      final updatedModel = currentModel.copyWithUpdate(
        image: resolvedImageUrl,
        grcModuleNameEnglish: grcModuleNameEnglish,
        grcModuleNameArabic: grcModuleNameArabic,
        descriptionEnglish: descriptionEnglish,
        descriptionArabic: descriptionArabic,
        owningDepartment: owningDepartment,
        activationDate: activationDate,
        owners: owners,
        status: status,
        editorId: editorId,
      );
```

with:

```dart
      final updatedModel = currentModel.copyWithUpdate(
        moduleImage: resolvedImageUrl,
        moduleNameEn: grcModuleNameEnglish,
        moduleNameAr: grcModuleNameArabic,
        moduleDescriptionEn: descriptionEnglish,
        moduleDescriptionAr: descriptionArabic,
        moduleOwningDepartment: owningDepartment,
        moduleActivationDate: activationDate,
        owners: owners,
        status: status,
        modifierEmail: editorId,
      );
```

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/features/grc/data/repository/grc_module_repository_impl.dart`
Expected: `No issues found!` (the pre-existing `uuid` "not a dependency" info is out of scope)

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/data/repository/grc_module_repository_impl.dart
git commit -m "fix(grc): call GRCModuleModel with its current param names, pass image through as nullable"
```

---

### Task 5: `PolicyFirebaseDataSource` — keep Policies nested under their module

**Files:**
- Modify: `lib/features/grc/data/data_source/policy_firebase_data_source.dart`

**Interfaces:**
- Consumes: `getBaseUrl(String path)` (same helper as Task 3).
- Produces: no change to `PolicyFirebaseDataSource`'s public interface — only where its collection reference resolves to.

- [ ] **Step 1: Add the import and replace the path constant**

Add near the top, after the `cloud_firestore` import:

```dart
import 'package:demo_app/core/network/get_base_url.dart';
```

Replace:

```dart
  static const String _modulesCollectionPath = 'GRC Modules';
```

with:

```dart
  static String get _modulesCollectionPath =>
      '${getBaseUrl('Modules')}/grc/GRC Modules';
```

(Every existing usage is `.collection(_modulesCollectionPath)`, which works identically whether `_modulesCollectionPath` is a `const` or a getter — no other line in this file changes.)

- [ ] **Step 2: Verify it compiles**

Run: `dart analyze lib/features/grc/data/data_source/policy_firebase_data_source.dart`
Expected: no new errors (the pre-existing `isDeleted`/`editorId` references on `PolicyModel` are untouched — `PolicyModel` itself is out of scope for this plan and still uses its own older shape)

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/data/data_source/policy_firebase_data_source.dart
git commit -m "fix(grc): point PolicyFirebaseDataSource at the new tenant-scoped module path"
```

---

### Task 6: `GRCModuleCubit` — resolve the acting user's email, not id

**Files:**
- Modify: `lib/features/grc/presentation/controller/grc_module_cubit.dart`

**Interfaces:**
- Consumes: `Constant.emailUser` (`static String? emailUser` in `lib/features/employee/presentation/controller/main_core_employee_controller.dart`), `MainCoreEmployeeController.employeeEntity?.email`.
- Produces: `GRCModuleCubit._currentUserEmail` (renamed from `_currentUserId`) — used as the `editorId:` argument to every use case call (name unchanged per Global Constraints, now holds an email).

- [ ] **Step 1: Rename the getter and switch its source fields**

Replace:

```dart
  /// Resolves the currently logged-in user's id.
  /// Falls back to MainCoreEmployeeController if Constant.idUser isn't set yet.
  String get _currentUserId {
    final fromConstant = Constant.idUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final id = Get.find<MainCoreEmployeeController>().employeeEntity?.id;
      if (id != null && id.isNotEmpty) return id;
    }
    return '';
  }
```

with:

```dart
  /// Resolves the currently logged-in user's email (every GRC Module
  /// revision is attributed to an email, not an id — see Modifiers on
  /// GRCModuleModel).
  /// Falls back to MainCoreEmployeeController if Constant.emailUser isn't set yet.
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }
```

- [ ] **Step 2: Update every call site**

There are 4 occurrences of `editorId: _currentUserId,` (in `createModule`, `updateModule`, `deleteModule`, `restoreModule`) — replace each with `editorId: _currentUserEmail,`.

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/features/grc/presentation/controller/grc_module_cubit.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/controller/grc_module_cubit.dart
git commit -m "fix(grc): resolve the acting user's email instead of id for module revisions"
```

---

### Task 7: `GrcOwnerCubit` + `GrcOwnerSection` — owners keyed by email

**Files:**
- Modify: `lib/features/grc/presentation/controller/grc_owner_cubit.dart`
- Modify: `lib/features/grc/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart`

**Interfaces:**
- Consumes: `EmployeeEntityPro.email` (`String?`, already exists on the employee entity used by `MainCoreEmployeeController.allEmployeesEntities`).
- Produces: `OwnerData.email` (`String`, new field); `GrcOwnerCubit.loadOwners({required BuildContext context, List<String> initialOwnerEmails = const [], String? selectedDepartmentId})` (renamed from `initialOwnerIds`); `GrcOwnerSection.initialOwnerEmails` (renamed prop, same type `List<String>`).

- [ ] **Step 1: Add `email` to `OwnerData` and populate it in `loadOwners`**

In `grc_owner_cubit.dart`, replace the `OwnerData` class:

```dart
class OwnerData {
  final String id;
  final String name;
  final String email;
  final String department;
  final String departmentId;
  final String jobTitle;
  final String photo;
  bool isSelected;

  OwnerData({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.departmentId,
    required this.jobTitle,
    required this.photo,
    this.isSelected = false,
  });
}
```

- [ ] **Step 2: Rename `loadOwners`'s parameter and match by email**

Replace:

```dart
  void loadOwners(
    BuildContext context, {
    List<String> initialOwnerIds = const [],
    String? selectedDepartmentId,
  }) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return;
    final ctrl = Get.find<MainCoreEmployeeController>();
    final employees = ctrl.allEmployeesEntities ?? [];
    _allOwners = employees.map((e) {
      return OwnerData(
        id: e.id ?? '',
        name: EmployeeHelper.getEmployeeLocalizedName(employee: e, context: context),
        department: EmployeeHelper.getEmployeeLocalizeDepartment(employee: e, context: context),
        departmentId: e.departmentId ?? '',
        jobTitle: EmployeeHelper.getEmployeeLocalizedTitle(employee: e, context: context)?.toString() ?? '',
        photo: EmployeeHelper.getEmployeeImage(employee: e),
        isSelected: initialOwnerIds.contains(e.id ?? ''),
      );
    }).toList();
    _selectedDepartmentId = selectedDepartmentId;
    _applyFilters();
  }
```

with:

```dart
  void loadOwners(
    BuildContext context, {
    List<String> initialOwnerEmails = const [],
    String? selectedDepartmentId,
  }) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return;
    final ctrl = Get.find<MainCoreEmployeeController>();
    final employees = ctrl.allEmployeesEntities ?? [];
    _allOwners = employees.map((e) {
      return OwnerData(
        id: e.id ?? '',
        name: EmployeeHelper.getEmployeeLocalizedName(employee: e, context: context),
        email: e.email ?? '',
        department: EmployeeHelper.getEmployeeLocalizeDepartment(employee: e, context: context),
        departmentId: e.departmentId ?? '',
        jobTitle: EmployeeHelper.getEmployeeLocalizedTitle(employee: e, context: context)?.toString() ?? '',
        photo: EmployeeHelper.getEmployeeImage(employee: e),
        isSelected: initialOwnerEmails.contains(e.email ?? ''),
      );
    }).toList();
    _selectedDepartmentId = selectedDepartmentId;
    _applyFilters();
  }
```

- [ ] **Step 3: Update `GrcOwnerSection` to match**

In `grc_owner_section.dart`, replace the doc comment + field:

```dart
  /// Emails of owners already assigned to the module.
  /// - In view/restore mode  → only these owners are displayed.
  /// - In create/edit mode   → these owners are pre-selected.
  final List<String> initialOwnerEmails;
```

Replace the constructor param `this.initialOwnerIds = const [],` with `this.initialOwnerEmails = const [],`.

Replace the `loadOwners` call in `initState`:

```dart
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cubit.loadOwners(
        context,
        initialOwnerEmails: widget.initialOwnerEmails,
        selectedDepartmentId: widget.selectedDepartmentId,
      ),
    );
```

- [ ] **Step 4: Verify it compiles**

Run: `dart analyze lib/features/grc/presentation/controller/grc_owner_cubit.dart lib/features/grc/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart`
Expected: errors remain only in `grc_details_page.dart` (still passes the old `initialOwnerIds:` name — fixed in Task 8). No errors in the two files touched by this task themselves.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/presentation/controller/grc_owner_cubit.dart lib/features/grc/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart
git commit -m "feat(grc): key the owner picker by employee email instead of id"
```

---

### Task 8: `grc_details_page.dart` — fix renamed entity/cubit references

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/grc_details_page.dart`

**Interfaces:**
- Consumes: `GRCModuleEntity.{moduleId, moduleNameEn, moduleNameAr, moduleDescriptionEn, moduleDescriptionAr, moduleOwningDepartment, moduleActivationDate, moduleOwners, moduleImage, status}` (Tasks 1–2); `GrcOwnerSection.initialOwnerEmails` and `OwnerData.email` (Task 7); `GRCModuleCubit.createModule`/`updateModule`/`deleteModule`/`restoreModule` (unchanged param names, Task 6 only changed the internal email source).

- [ ] **Step 1: Rename the owners state field**

Replace `List<String> _selectedOwnerIds = [];` with `List<String> _selectedOwnerEmails = [];`.

- [ ] **Step 2: Fix `_prefillFromEntity`**

Replace:

```dart
  void _prefillFromEntity(GRCModuleEntity? entity) {
    if (entity == null) return;
    _nameEnController.text = entity.grcModuleNameEnglish;
    _nameArController.text = entity.grcModuleNameArabic;
    _descEnController.text = entity.descriptionEnglish;
    _descArController.text = entity.descriptionArabic;
    _selectedDepartment = entity.owningDepartment;
    _activationDate = entity.activationDate;
    _statusValue = entity.status == 'Active';
    _selectedOwnerIds = List.from(entity.owners);
  }
```

with:

```dart
  void _prefillFromEntity(GRCModuleEntity? entity) {
    if (entity == null) return;
    _nameEnController.text = entity.moduleNameEn;
    _nameArController.text = entity.moduleNameAr;
    _descEnController.text = entity.moduleDescriptionEn;
    _descArController.text = entity.moduleDescriptionAr;
    _selectedDepartment = entity.moduleOwningDepartment;
    _activationDate = entity.moduleActivationDate;
    _statusValue = entity.status == 'Active';
    _selectedOwnerEmails = List.from(entity.moduleOwners);
  }
```

- [ ] **Step 3: Fix `_onCreate`/`_onUpdate`/`_onDelete`/`_onRestore`**

In `_onCreate`, replace `owners: _selectedOwnerIds,` with `owners: _selectedOwnerEmails,`.

In `_onUpdate`, replace `id: widget.entity!.id,` with `id: widget.entity!.moduleId,` and `owners: _selectedOwnerIds,` with `owners: _selectedOwnerEmails,`.

In `_onDelete`, replace `cubit.deleteModule(id: widget.entity!.id);` with `cubit.deleteModule(id: widget.entity!.moduleId);`.

In `_onRestore`, replace `cubit.restoreModule(id: widget.entity!.id);` with `cubit.restoreModule(id: widget.entity!.moduleId);`.

- [ ] **Step 4: Fix the image picker and owner section wiring in `build`**

Replace `imageUrl: widget.entity?.image,` with `imageUrl: widget.entity?.moduleImage,`.

Replace:

```dart
                                  GrcOwnerSection(
                                    isViewMode: (_currentMode ==
                                            GrcPageMode.view ||
                                        _currentMode == GrcPageMode.restore),
                                    initialOwnerIds: _selectedOwnerIds,
                                    selectedDepartmentId: _selectedDepartment,
                                    onOwnersChanged: (selected) {
                                      _selectedOwnerIds =
                                          selected.map((o) => o.id).toList();
                                    },
                                  ),
```

with:

```dart
                                  GrcOwnerSection(
                                    isViewMode: (_currentMode ==
                                            GrcPageMode.view ||
                                        _currentMode == GrcPageMode.restore),
                                    initialOwnerEmails: _selectedOwnerEmails,
                                    selectedDepartmentId: _selectedDepartment,
                                    onOwnersChanged: (selected) {
                                      _selectedOwnerEmails =
                                          selected.map((o) => o.email).toList();
                                    },
                                  ),
```

- [ ] **Step 5: Verify it compiles**

Run: `dart analyze lib/features/grc/presentation/ui/pages/grc_details_page.dart`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/grc_details_page.dart
git commit -m "fix(grc): update GovernanceRiskAndComplianceDetails to the current entity field names and owner emails"
```

---

### Task 9: `grc_module_details_page.dart` — fix renamed entity references

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart`

**Interfaces:**
- Consumes: `GRCModuleEntity.{moduleId, moduleNameEn, moduleNameAr}` (Tasks 1–2).

- [ ] **Step 1: Fix the three `.id` references**

Replace `GetIt.instance<PolicyCubit>()..getAllPolicies(moduleId: module.id),` with `GetIt.instance<PolicyCubit>()..getAllPolicies(moduleId: module.moduleId),`.

Replace `navigateTo(context, CreateNewPolicyPage(moduleId: widget.module.id));` with `navigateTo(context, CreateNewPolicyPage(moduleId: widget.module.moduleId));`.

Replace `navigateTo(context, PolicyBulkUploadPage(moduleId: widget.module.id));` with `navigateTo(context, PolicyBulkUploadPage(moduleId: widget.module.moduleId));`.

- [ ] **Step 2: Fix the title fields**

Replace:

```dart
                      context.isArabic
                          ? widget.module.grcModuleNameArabic
                          : widget.module.grcModuleNameEnglish,
```

with:

```dart
                      context.isArabic
                          ? widget.module.moduleNameAr
                          : widget.module.moduleNameEn,
```

- [ ] **Step 3: Verify it compiles**

Run: `dart analyze lib/features/grc/presentation/ui/pages/grc_module_details_page.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/grc_module_details_page.dart
git commit -m "fix(grc): update GrcModuleDetailsPage to the current entity field names"
```

---

### Task 10: `grc_page.dart` — fix renamed entity references, `isRemoved`, owner-by-email lookup

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/grc_page.dart`

**Interfaces:**
- Consumes: `GRCModuleEntity.{moduleId, moduleNameEn, moduleNameAr, moduleOwners, status, isRemoved, createdAt, modificationDate}` (Tasks 1–2); `EmployeeHelper.getEmployeeLocalizedNameWithEmail({required String employeeEmail})` (already exists in `lib/core/helper/main_helper/employee_helper.dart`).

- [ ] **Step 1: Fix `_applyFilters`**

Replace:

```dart
    if (_selectedStatus == 'Active') {
      result =
          result.where((m) => !m.isDeleted && m.status == 'Active').toList();
    } else if (_selectedStatus == 'Inactive') {
      result =
          result.where((m) => !m.isDeleted && m.status == 'Inactive').toList();
    } else if (_selectedStatus == 'Removed') {
      result = result.where((m) => m.isDeleted).toList();
    }
    // 'all' → no filter, show everything

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((m) =>
              m.grcModuleNameEnglish.toLowerCase().contains(q) ||
              m.grcModuleNameArabic.toLowerCase().contains(q))
          .toList();
    }

    // Sort
    if (_sortOrder == 'ASC') {
      result.sort(
          (a, b) => a.grcModuleNameEnglish.compareTo(b.grcModuleNameEnglish));
    } else if (_sortOrder == 'DES') {
      result.sort(
          (a, b) => b.grcModuleNameEnglish.compareTo(a.grcModuleNameEnglish));
    } else if (_sortOrder == 'Last Update') {
      result.sort((a, b) => b.lastModifiedDate.compareTo(a.lastModifiedDate));
    } else if (_sortOrder == 'Creation Date') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
```

with:

```dart
    if (_selectedStatus == 'Active') {
      result =
          result.where((m) => !m.isRemoved && m.status == 'Active').toList();
    } else if (_selectedStatus == 'Inactive') {
      result =
          result.where((m) => !m.isRemoved && m.status == 'Inactive').toList();
    } else if (_selectedStatus == 'Removed') {
      result = result.where((m) => m.isRemoved).toList();
    }
    // 'all' → no filter, show everything

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((m) =>
              m.moduleNameEn.toLowerCase().contains(q) ||
              m.moduleNameAr.toLowerCase().contains(q))
          .toList();
    }

    // Sort
    if (_sortOrder == 'ASC') {
      result.sort((a, b) => a.moduleNameEn.compareTo(b.moduleNameEn));
    } else if (_sortOrder == 'DES') {
      result.sort((a, b) => b.moduleNameEn.compareTo(a.moduleNameEn));
    } else if (_sortOrder == 'Last Update') {
      result.sort((a, b) => b.modificationDate.compareTo(a.modificationDate));
    } else if (_sortOrder == 'Creation Date') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
```

- [ ] **Step 2: Fix `_countByStatus`**

Replace:

```dart
  Map<String, int> _countByStatus(List<GRCModuleEntity> modules) {
    return {
      'all': modules.length,
      'Active':
          modules.where((m) => !m.isDeleted && m.status == 'Active').length,
      'Inactive':
          modules.where((m) => !m.isDeleted && m.status == 'Inactive').length,
      'Removed': modules.where((m) => m.isDeleted).length,
    };
  }
```

with:

```dart
  Map<String, int> _countByStatus(List<GRCModuleEntity> modules) {
    return {
      'all': modules.length,
      'Active':
          modules.where((m) => !m.isRemoved && m.status == 'Active').length,
      'Inactive':
          modules.where((m) => !m.isRemoved && m.status == 'Inactive').length,
      'Removed': modules.where((m) => m.isRemoved).length,
    };
  }
```

- [ ] **Step 3: Fix the popup-menu `isDeleted` check (around line 204)**

Replace `items: module.isDeleted` with `items: module.isRemoved`.

- [ ] **Step 4: Fix the card-tap handler (around line 425)**

Replace:

```dart
                final entity = moduleAt(index);
                if (entity.isDeleted) {
```

with:

```dart
                final entity = moduleAt(index);
                if (entity.isRemoved) {
```

- [ ] **Step 5: Fix `_resolveOwnerName` to look up by email**

Replace:

```dart
  String _resolveOwnerName(BuildContext context, String ownerId) {
    try {
      return EmployeeHelper.getEmployeeLocalizedNameWithId(
        employeeId: ownerId,
        context: context,
      );
    } catch (_) {
      return ownerId;
    }
  }
```

with:

```dart
  String _resolveOwnerName(BuildContext context, String ownerEmail) {
    try {
      return EmployeeHelper.getEmployeeLocalizedNameWithEmail(
        employeeEmail: ownerEmail,
      );
    } catch (_) {
      return ownerEmail;
    }
  }
```

- [ ] **Step 6: Fix the card's title/owner/date fields in `build`**

Replace:

```dart
      title: context.isArabic
          ? module.grcModuleNameArabic
          : module.grcModuleNameEnglish,
      infoRows: [
        if (module.owners.isNotEmpty)
          CardInfo(
            label: '${'Owner'.tr} :',
            value: _resolveOwnerName(context, module.owners.first),
          ),
        CardInfo(
          label: '${'Creation Date'.tr} :',
          value: DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
              .format(module.createdAt),
        ),
      ],
      complianceLabel: '${'Compliance Score'.tr} :',
      complianceScore: '-',
      footerLabel: '${'Last Update'.tr} :',
      footerValue: DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
          .format(module.lastModifiedDate),
```

with:

```dart
      title: context.isArabic ? module.moduleNameAr : module.moduleNameEn,
      infoRows: [
        if (module.moduleOwners.isNotEmpty)
          CardInfo(
            label: '${'Owner'.tr} :',
            value: _resolveOwnerName(context, module.moduleOwners.first),
          ),
        CardInfo(
          label: '${'Creation Date'.tr} :',
          value: DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
              .format(module.createdAt),
        ),
      ],
      complianceLabel: '${'Compliance Score'.tr} :',
      complianceScore: '-',
      footerLabel: '${'Last Update'.tr} :',
      footerValue: DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
          .format(module.modificationDate),
```

- [ ] **Step 7: Verify it compiles**

Run: `dart analyze lib/features/grc/presentation/ui/pages/grc_page.dart`
Expected: `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/grc_page.dart
git commit -m "fix(grc): update GRC module list page to the current entity field names and owner emails"
```

---

### Task 11: Full-slice verification

**Files:** none (verification only)

**Interfaces:** none — this task confirms every prior task's changes compose correctly across the whole feature.

- [ ] **Step 1: Analyze the entire GRC feature**

Run: `dart analyze lib/features/grc/`
Expected: `0` errors. The only acceptable remaining output is pre-existing `info`/`warning` lines unrelated to this plan (dangling library doc comments, `withOpacity` deprecation notices, the `uuid` dependency notice, the unrelated `_isWeightValid` unused-element warning, and anything still inside `PolicyModel`/`PolicyRepositoryImpl`/`ControlModel`, which are out of scope). If you see any `error -` line, find which task should have fixed it and go back.

- [ ] **Step 2: Run the full test suite (requires Flutter SDK)**

Run: `flutter test test/features/grc/ -v`
Expected: all tests pass, including the pre-existing `policy_model_nested_array_test.dart` (untouched by this plan) and the new `grc_module_model_test.dart` (Task 1). If Flutter isn't available in your environment, state that explicitly instead of claiming this step passed.

- [ ] **Step 3: Manual smoke test (requires a running app + Firebase project)**

With the app running and signed in to a tenant:
1. Create a GRC Module with an activation date a month in the future, no image, and no owners selected. Confirm the list shows it under "Scheduled".
2. In the Firestore console, confirm the document exists at `Demo/{companyId}/Modules/grc/GRC Modules/{moduleId}`, `Module_Activation_Date` is a string like `4 Jul 2026`, `Module_Image` is `null`, and `Status` is `["Scheduled"]`.
3. Create a second module with today's date and at least one owner. Confirm it shows "Active", and `Module_Owners` in Firestore contains that owner's email, not their employee id.
4. Edit the first module and toggle the status switch off. Confirm it shows "Inactive" both in the app and in Firestore.
5. Delete the second module, then restore it. Confirm `Status` ends at `["Active", ..., "Removed", "Active"]` (or similar) and it reappears in the "Active"/"all" tabs.
6. Open a module's details page (`GrcModuleDetailsPage`) and confirm its Policies still load (verifies Task 5 didn't orphan them).

- [ ] **Step 4: Final commit (if any cleanup was needed)**

Only if Step 1–3 surfaced something to fix that wasn't already committed in its owning task:

```bash
git add -A
git commit -m "fix(grc): address remaining issues found during full-slice verification"
```
