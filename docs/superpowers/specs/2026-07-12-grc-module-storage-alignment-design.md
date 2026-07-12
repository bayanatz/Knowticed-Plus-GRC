# GRC Module storage alignment — design

Date: 2026-07-12

## Problem

`GRCModuleModel`/`GRCModuleEntity` were reworked on 2026-07-06 (new field
names, `Status` list instead of `isDeleted`, `Modifiers` stores email). The
rest of the vertical slice was never updated to match, so it currently fails
to compile: `dart analyze lib/features/grc/` reports 74 real errors across
`grc_module_firebase_data_source.dart`, `grc_module_repository_impl.dart`,
`grc_details_page.dart`, `grc_module_details_page.dart`, and `grc_page.dart`
(undefined getters like `.id`, `.owners`, `.isDeleted`,
`.grcModuleNameEnglish`; missing/renamed constructor params on the model).

On top of getting it compiling again, the storage rules need to change:

- Records must live under the tenant (`Demo/{companyId}/...`), not a flat
  top-level collection.
- Dates must be stored as readable strings (e.g. `4 Jul 2026`), not ISO8601.
- A missing image must serialize as `null`, never `""`.
- `Module_Owners` must store owner **emails**, not employee ids.
- `Status` must reflect `Scheduled`/`Active` based on `Activation_Date`
  automatically; `Inactive` and `Removed` only change via explicit user
  action (status switch / delete / restore).

`GRCModuleModel` and `GRCModuleEntity` themselves are the given/frozen
target shape for this change — every other file adapts to them; their field
names (`moduleId`, `moduleNameEn`, `moduleImage`, etc.) do not change.

## Out of scope

- `PolicyModel`/`PolicyFirebaseDataSource`/`PolicyRepositoryImpl` — still on
  the older `isDeleted`/`editorId` shape. Not migrated here. The only Policy
  file touched is the one hardcoded path constant described in section A,
  so Policies keep resolving under their parent module.
- Any other GRC feature file that doesn't reference the renamed
  entity/model fields and currently analyzes clean.
- Deprecation warnings / lint infos unrelated to this change
  (`withOpacity`, dangling library doc comments, etc.).

## A. Firestore path

`Demo/{companyId}/Modules/grc` is a **document** — it mirrors the existing
"roles" module convention already used elsewhere in the app
(`Demo/{companyId}/Modules/roles`, built via `getBaseUrl('Modules')`).
Individual GRC Module records live in a subcollection under that document:

```
Demo/{companyId}/Modules/grc/GRC Modules/{moduleId}
```

`GRCModuleFirebaseDataSource` builds this with the existing `getBaseUrl`
helper (the app's established tenant-scoping convention) instead of the
current hardcoded top-level `'GRC Modules'` string:

```dart
CollectionReference<Map<String, dynamic>> get _collection =>
    _firestore.collection('${getBaseUrl('Modules')}/grc/GRC Modules');
```

**Policy coupling:** `PolicyFirebaseDataSource._modulesCollectionPath` is
currently `'GRC Modules'` (top-level), used to nest
`.../GRC Modules/{moduleId}/Policies`. It gets updated to the same new base
path so Policies keep resolving under their parent module doc. This is a
one-line constant change, not a Policy model migration.

## B. Dates stored as formatted strings

`Module_Activation_Date` and `Modification_Date` are written as `d MMM yyyy`
strings (e.g. `4 Jul 2026`) via `intl`'s `DateFormat`, matching the format
already used for on-screen display in `grc_form_fields.dart`. Internally the
model keeps `DateTime` (needed for status comparisons and sorting) — only
`toJson`/`fromJson` change:

```dart
'Module_Activation_Date': moduleActivationDate
    .map((d) => DateFormat('d MMM yyyy').format(d))
    .toList(),
```

`fromJson` parses back with the same formatter. `createdAt` (currently
`modificationDate.first`) is unaffected structurally.

## C. Image: null when absent, not `""`

`moduleImage` becomes nullable end-to-end:

- `GRCModuleModel.moduleImage`: `List<String?>`
- `GRCModuleEntity.moduleImage`: `String?`
- `toJson`/`fromJson` read/write `null` elements as-is (Firestore supports
  `null` array elements).
- `GRCModuleRepositoryImpl._resolveImageUrl` returns `null` (not `''`) when
  there's no file and no fallback URL; `createModule`/`updateModule` pass
  that through unchanged instead of coalescing to `''`.

No other field in the create/edit form is optional (name/description/
department/date are all required by validation), so this rule only applies
to Image in practice.

## D. Owners: store email, not id

- `GrcOwnerCubit.OwnerData` gains an `email` field, sourced from
  `EmployeeEntity.email` (already available, just unused today).
- The picker UI still selects by employee id internally (natural identity
  for a selection list) — only the value handed to
  `GRCModuleCubit.createModule`/`updateModule` changes, from
  `selectedOwners.map((o) => o.id)` to `selectedOwners.map((o) => o.email)`.
- Pre-selecting existing owners when editing (`loadOwners(initialOwnerIds:
  ...)`) currently matches `initialOwnerIds.contains(e.id)`. Since stored
  values are now emails, this becomes `initialOwnerEmails.contains(e.email)`
  — the cubit's `loadOwners` parameter is renamed accordingly and
  `grc_details_page.dart`'s `_selectedOwnerIds` (built from
  `entity.moduleOwners`, which now holds emails) is renamed
  `_selectedOwnerEmails` for clarity at that call site.
- `GRCModuleModel.moduleOwners` keeps its `List<String>` (JSON-encoded per
  revision) type — only the semantic content changes, from ids to emails.

## E. Status: derived from Activation_Date, with sticky manual states

`Inactive` and `Removed` are the only states a caller sets explicitly, and
they're sticky — they persist until a subsequent explicit action (status
switch toggled back on, or `restore`). Any other status value passed in
(including the `'Active'` the create/edit form's status switch currently
sends when toggled on) is treated as "not manually paused" and gets
**derived** from `Activation_Date`:

```dart
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

This runs in two places:

1. **Write time** — inside `GRCModuleModel.create` and `copyWithUpdate`, so
   the value actually persisted to Firestore is correct as of the moment of
   the write.
2. **Read time** — inside `GRCModuleModel.toEntity()`, using the same
   derivation against `status.last` / `moduleActivationDate.last`, so the
   app always displays the correct state even when nobody has edited the
   record since its `Activation_Date` passed.

There is no Cloud Function / scheduled job in this app, so the *raw*
Firestore field can lag between edits (a module can sit showing `Scheduled`
in the console after its date has passed, until the next write or read).
The app-facing value (`GRCModuleEntity.status`) is always accurate because
of the read-time derivation. `delete`/`restore` pass `'Removed'`/`'Active'`
explicitly, per the existing soft-delete convention (setting status back to
`'Active'` on restore re-enters the normal derivation going forward, so it
correctly shows `Scheduled` if the activation date is still in the future).

No changes needed to `GrcStatusSwitch` or how `grc_details_page.dart` calls
`createModule`/`updateModule` — the switch already only ever sends
`'Active'` or `'Inactive'`.

## F. Files touched

Data/domain layer (per the file list originally given):

- `grc_module_data_source.dart` — interface, minor doc updates only if
  signatures change (they don't; `create`/`update`/`delete`/`restore` keep
  their current shapes).
- `grc_module_firebase_data_source.dart` — new collection path (A); replace
  every `.id`/`isDeleted`/`editorId` reference with `.moduleId`/derived
  status handling/`modifierEmail`.
- `grc_module_storage_data_source.dart` — no changes expected (already
  returns a plain download-URL string; nullability is handled by the
  repository, not here).
- `grc_module_repository_impl.dart` — call `GRCModuleModel.create`/
  `copyWithUpdate` with the current param names; `_resolveImageUrl` returns
  `String?` (C).
- `grc_module_repository.dart` — no signature changes expected.
- `domain/use_cases/*_grc_module_use_case.dart` — no signature changes
  expected (they pass through to the repository unchanged).
- `grc_module_cubit.dart` — `_currentUserId` getter becomes
  `_currentUserEmail`, resolved from `Constant.emailUser` (falling back to
  `MainCoreEmployeeController.employeeEntity?.email`), since every model
  call now expects `modifierEmail`, not an id.
- `grc_owner_cubit.dart` — `OwnerData.email` (D), `loadOwners` param rename.

Cascading fixes needed to make the feature compile/run at all (found via
`dart analyze`, not in the original file list):

- `grc_details_page.dart` — update all `entity.*` references to the current
  field names (`moduleId`, `moduleNameEn`/`moduleNameAr`,
  `moduleDescriptionEn`/`moduleDescriptionAr`, `moduleOwningDepartment`,
  `moduleActivationDate`, `moduleOwners`, `moduleImage`); owners email
  wiring (D).
- `grc_module_details_page.dart` — same field-name updates where it reads
  `GRCModuleEntity`.
- `grc_page.dart` — same field-name updates, plus replacing `entity.isDeleted`
  checks with `entity.isRemoved` (already exists on the entity) and
  `entity.lastModifiedDate` with `entity.modificationDate`.
- `policy_firebase_data_source.dart` — one constant (A).

## Testing

- Unit test `_deriveStatus`-equivalent logic (or the model's `create`/
  `copyWithUpdate`/`toEntity` behavior) for: future date → `Scheduled`;
  past/today date → `Active`; explicit `Inactive` stays `Inactive`
  regardless of date; explicit `Removed` stays `Removed`; restoring a
  future-dated module returns to `Scheduled` (not forced `Active`).
- Unit test `toJson`/`fromJson` round-trip for dates (string format) and a
  null image.
- Manual run: create a module with a future activation date (expect
  `Scheduled`), create one with today's date (expect `Active`), toggle
  Inactive, delete, restore — check the actual Firestore document lands at
  `Demo/{companyId}/Modules/grc/GRC Modules/{id}` with string dates, `null`
  image when none was picked, and owner emails in `Module_Owners`.
