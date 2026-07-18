# Control Champions & Control Owners — design

Date: 2026-07-19

## Problem

`grc_module_details_page.dart` already defines four tabs — Policies, Control
Champions, Control Owners, Departments — but only "Policies" is wired up
(`_tabs[1..3]` fall through to a stub `Center(Text(...))`). This spec covers
building the "Control Champions" and "Control Owners" tabs end-to-end
(data/domain/presentation), per the provided schema and mockups:

```
GRC Modules/{Module_ID}/Control Champions/{Champion_Email}:{
  Champion_Email: String <Email>
  Assigning_Controls: List<Map>   // [{ "Items": [Assigning_Control_Model, ...] }, ...] per revision
  Champion_Status: Removed, Active
  Modification_Date: List<String>
  Modifiers: List<String>         // user email
}

GRC Modules/{Module_ID}/Control Owners/{Owner_Email}:{
  Owner_Email: String
  Assigning_Controls: List<Map>   // [{ "Items": [Controls_Assign_Model, ...] }, ...] per revision
  Owners_Status: Removed, Active
  Control_Owners_Permissions: List<List<String>>
  Modification_Date: List<String>
  Modifiers: List<String>
}
```

Mockups show: a list tab per feature (search + "+ Champion" button /
"Add Owner + Bulk Upload" menu + Department filter for Owners, cards with
avatar/name/department/job-title/Message button), and an "Adding New
Control Champion/Owner" page (single employee search-and-pick, then an
"Assigning Control" section with Policy + Control dropdowns per row and a
"+ Policy" button to add more rows).

## Scope decisions (confirmed)

- **One `{Policy, Control}` pair per row.** Each "+ Policy" click adds one
  row with one Policy dropdown and one Control dropdown (not multi-select).
- **Control_Owners_Permissions is current-state only, not history**, and is
  positionally parallel to the **latest** revision's `Assigning_Controls`
  `Items` list — `permissions[i]` belongs to the control at
  `assigningControls.last[i]`. No permission-picker UI is built this round:
  no mockup shows one and the permission vocabulary is undefined. The field
  is wired through structurally (written as `[]` per assigned control on
  create/update) so the schema shape is correct and a picker can be added
  later without a data migration.
- **Core only.** `Requests`, `Message`, the export/upload icon, and
  "Bulk Upload" (Owners) stay non-functional stubs — matching the existing
  convention on this page (`Dashboard`, `Approvals`, `Assignment Controls`,
  `My Audits` are already `function: () {}`). The Departments tab (4th tab)
  is untouched.
- **Single-select employee picker** on the Add page (`Champion_Email`/
  `Owner_Email` is one string, and the mockup shows exactly one person
  checked) — reuses `GrcOwnerSection`/`GrcOwnerCubit` with a new
  `singleSelect` flag rather than a parallel widget.
- **Status field exists for schema fidelity, no removal UI yet.** The model
  supports appending a revision with `status: 'Removed'` (same convention as
  `GRCModuleModel`/`PolicyModel` — no hard delete), reachable via
  `updateChampion(status: ChampionStatus.removed)` /
  `updateOwner(status: OwnerStatus.removed)`. No mockup shows a "remove
  Champion/Owner" action, so no button calls this yet — a future iteration
  can wire one without any data-layer change.

## Shared building block: `AssigningControlEntity` / `AssigningControlModel`

Both features need the same `{Policy, Control}` pair, so it's defined once,
placed alongside the existing `DepartmentWeight` value object (the
established home for control-related value objects):

- `lib/features/grc/control/domain/entities/assigning_control.dart`
  ```dart
  class AssigningControlEntity {
    final String policyId;
    final String controlId;
    const AssigningControlEntity({required this.policyId, required this.controlId});
  }
  ```
- `lib/features/grc/control/data/models/assigning_control_model.dart`
  ```dart
  class AssigningControlModel {
    final String policyId;
    final String controlId;
    const AssigningControlModel({required this.policyId, required this.controlId});

    Map<String, dynamic> toJson() => {'Policy_ID': policyId, 'Control_ID': controlId};
    factory AssigningControlModel.fromJson(Map<String, dynamic> json) =>
        AssigningControlModel(policyId: json['Policy_ID'] as String, controlId: json['Control_ID'] as String);
    AssigningControlEntity toEntity() => AssigningControlEntity(policyId: policyId, controlId: controlId);
  }
  ```

## Feature: `control_champion`

Firestore path: `GRC_Modules/{Module_ID}/Control_Champions/{Champion_Email}`
(document ID is the email itself, per the schema).

### `ChampionStatus` (domain enum)
`lib/features/grc/control_champion/domain/entities/champion_status.dart` —
same shape as `ControlStatus`: `active`, `removed`; `.value` → `'Active'`/
`'Removed'`; `.fromString()` defaults to `active` for unknown/legacy docs.

### `ChampionModel`
`lib/features/grc/control_champion/data/models/champion_model.dart`,
history-list pattern identical to `GRCModuleModel`:

```dart
class ChampionModel {
  final String championEmail;                              // doc key, not a history list
  final List<List<AssigningControlModel>> assigningControls; // one element per revision
  final List<String> status;                                 // 'Active' | 'Removed'
  final List<DateTime> modificationDate;
  final List<String> modifiers;                              // editor email per revision
}
```

- `ChampionModel.create({championEmail, initialAssigningControls, modifierEmail})`
  → each list seeded with one element, `status: ['Active']`.
- `copyWithUpdate({assigningControls, status, required modifierEmail})` →
  appends one revision to every list, reusing the previous value for any
  field not passed (exact same rule as `GRCModuleModel.copyWithUpdate`).
- `toJson()`:
  ```dart
  {
    'Champion_Email': championEmail,
    'Assigning_Controls': assigningControls
        .map((rev) => {'Items': rev.map((a) => a.toJson()).toList()})
        .toList(),
    'Champion_Status': status,
    'Modification_Date': modificationDate.map(_storageDateFormat.format).toList(),
    'Modifiers': modifiers,
  }
  ```
- `fromJson()` mirrors `ControlModel.fromJson`'s unwrap of `Controls_Departments`
  (read each revision's `Items`, map through `AssigningControlModel.fromJson`).
- `toEntity()` flattens the last index of every list into `ChampionEntity`.

### `ChampionEntity`
`lib/features/grc/control_champion/domain/entities/champion_entity.dart`:
`championEmail`, `assigningControls: List<AssigningControlEntity>` (current
only), `status: ChampionStatus`, `createdAt` (`modificationDate.first`),
`modificationDate` (latest), `lastModifier`.

### Data source / repository / use cases
- `ChampionFirebaseDataSource` (`data/data_source/`): `create(moduleId, ChampionModel)`,
  `get(moduleId, email)`, `getAll(moduleId, {includeRemoved})`,
  `update(moduleId, ChampionModel)` — same shape as
  `GRCModuleFirebaseDataSource`, scoped under the module's subcollection.
- `ChampionRepository` (interface) / `ChampionRepositoryImpl`: maps
  `Either<Failure, ...>`, `ValidationError` for not-found, `FirebaseFailure`
  on exceptions — same pattern as `GRCModuleRepositoryImpl`.
- Use cases: `CreateChampionUseCase`, `GetChampionUseCase`,
  `GetAllChampionsUseCase`, `UpdateChampionUseCase` (accepts an optional
  `status` param, same as `UpdatePolicyUseCase`) — thin pass-throughs, same
  shape as the `GRCModule`/`Policy` use cases. No separate Delete/Restore
  use case: nothing in this scope calls one (see scope decisions above), and
  `UpdateChampionUseCase(status: ChampionStatus.removed)` already covers the
  soft-delete path if/when a remove action is added later.

## Feature: `control_owner`

Firestore path: `GRC_Modules/{Module_ID}/Control_Owners/{Owner_Email}`.
Identical structure to `control_champion` (own `OwnerStatus` enum,
`OwnerModel`, `OwnerEntity`, data source, repository, use cases — same
names with `Owner` instead of `Champion`), plus:

```dart
final List<List<String>> controlOwnerPermissions; // current only, parallel to assigningControls.last
```

`toJson()` wraps this the same way as `Controls_Departments` (Firestore
rejects a raw nested array):
```dart
'Control_Owners_Permissions':
    controlOwnerPermissions.map((perms) => {'Items': perms}).toList(),
```
one map per assigned control, in the same order as
`assigningControls.last`. `OwnerModel.create()` seeds it as
`List.filled(initialAssigningControls.length, [])`. In
`copyWithUpdate()`, if `assigningControls` changes and the caller doesn't
pass new `controlOwnerPermissions`, existing per-control permissions are
carried over by matching `(policyId, controlId)` pairs between the old and
new `Items` lists; any newly-added control defaults to `[]`.

## Presentation layer

### Cubits
`ChampionCubit` / `OwnerCubit` — factory-registered (one instance per page,
same reasoning as `PolicyCubit`/`GRCModuleCubit`): `getAllChampions(moduleId)`,
`createChampion(...)`, `updateChampion(...)`, `deleteChampion(...)` /
`restoreChampion(...)`, and the `Owner` equivalents. State shape:
`Initial` / `Loading` / `ListLoaded(List<Entity>)` / `ActionSuccess(Entity)` /
`Failure(message)` — same as `PolicyState`.

### List tabs (`grc_module_details_page.dart`)
Replace the stub `Center(Text(_tabs[_selectedTab].tr))` branch with a real
switch over `_selectedTab` (0: Policies — unchanged, 1: Control Champions,
2: Control Owners, 3: Departments — stays stub, out of scope).

Each new tab body:
- `BlocProvider` wrapping a fresh `ChampionCubit`/`OwnerCubit` that loads on
  init (`getAllChampions(moduleId: module.moduleId)`), mirroring how the
  Policies tab already gets its `PolicyCubit` from the parent
  `GrcModuleDetailsPage`.
- `AppSearchTextField` filtering the loaded list client-side by employee
  name (resolved via `EmployeeHelper.getEmployeeLocalizedNameWithEmail`),
  same approach as `_applySearch` for policies.
- Owners tab only: a `CustomDropdownButton2` "Department" filter, client-side
  (resolve each owner's department via `EmployeeHelper.getEmployeeLocalizeDepartment`-by-email
  and filter the list), plus a two-item popup menu ("Add Owner" / "Bulk Upload")
  reusing the `_showPolicyCreationMenu` popup-positioning pattern — "Bulk
  Upload" is a visual-only stub tap (no handler), "Add Owner" pushes
  `AddOwnerPage`.
- Champions tab: a single "+ Champion" button (no menu) pushing
  `AddChampionPage`, matching the mockup.
- A new small private card widget per tab (`_ChampionCard`/`_OwnerCard`,
  declared in the same file as `_PolicyCard`) — avatar + localized name +
  department + job title (via `EmployeeHelper`) + a stub "Message" button —
  since the mockup's layout doesn't fit `ModuleInfoCard` or `PersonChipCard`
  as-is.
- Empty-state and loading/failure treatment copied from
  `_buildPolicyList`.

### Add pages
`AddChampionPage` / `AddOwnerPage`
(`lib/features/grc/control_champion/presentation/ui/pages/add_champion_page.dart`,
equivalent for owner), structured like `CreateNewPolicyPage`:

1. **Employee picker** — `GrcOwnerSection` gains a `singleSelect` bool
   (default `false`, unchanged for the Module Owner use case). When `true`,
   `GrcOwnerCubit.toggleOwner` clears every other selection before toggling
   the tapped one, so exactly one `OwnerData` can be selected — reused here
   instead of a new widget.
2. **"Assigning Control" section** — a `List<_AssigningRow>` in local state,
   starting with one empty row. Each row: Policy `CustomDropdownButton2`
   (populated from `PolicyCubit.getAllPolicies(moduleId)`, already loaded by
   the parent page) + Control `CustomDropdownButton2` (populated by calling
   `PolicyCubit.getAllControls(moduleId, policyId: row.policyId)` once that
   row's Policy is chosen — Controls are scoped per-Policy, so the Control
   dropdown is disabled/empty until a Policy is picked). "+ Policy" appends
   an empty row; each row past the first gets a remove (×) button.
3. **Discard / Submit** — Submit validates exactly one employee is selected
   and every row has both a Policy and a Control chosen, then calls
   `ChampionCubit.createChampion(moduleId, championEmail: selected.email,
   assigningControls: rows.map(...), modifierEmail: currentUserEmail)` (Owner
   page: same, `controlOwnerPermissions` defaults to `[]` per row). On
   success, pops with `true` so the list tab refreshes — same
   `Navigator.push<bool>` + refresh-on-`true` convention used by
   `_showPolicyCreationMenu`.

### DI (`grc_get_it.dart`)
Register, in the same 4-step order already used in this file:
`ChampionFirebaseDataSource`, `OwnerFirebaseDataSource` (data sources) →
`ChampionRepository`/`OwnerRepository` impls → the Champion/Owner use cases
→ `ChampionCubit`/`OwnerCubit` as factories.

## Out of scope
- Permissions-picker UI for `Control_Owners_Permissions` (field is wired
  through empty; see scope decisions above).
- `Requests`, `Message`, export/upload icon, "Bulk Upload" execution — stay
  stubs.
- Departments tab.
- Any change to how Module Owners (a separate, already-shipped concept)
  work.

## Testing
- Unit tests for `ChampionModel`/`OwnerModel`: `create()`/`copyWithUpdate()`
  keep all lists the same length; `toJson()`/`fromJson()` round-trip
  (including the `Items`-wrapped `Assigning_Controls` and, for Owner, the
  `Items`-wrapped `Control_Owners_Permissions`); status transitions to
  `Removed`/back to `Active`; `copyWithUpdate` preserves per-control
  permissions across an `assigningControls` change by `(policyId, controlId)`
  matching, defaulting new controls to `[]`.
- Manual check: add a Champion and an Owner on a module with existing
  Policies/Controls, confirm both appear in their list tab with the correct
  name/department/job-title, that search filters them, and that Owners'
  Department filter narrows the list correctly.
