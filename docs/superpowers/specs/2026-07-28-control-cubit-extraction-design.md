# Control Cubit Extraction — design

Date: 2026-07-28

## Problem

`lib/features/grc/control/` has no Cubit of its own. Every standalone Control
operation — create, update, delete, list-all — is implemented on `PolicyCubit`
(`lib/features/grc/policy/presentation/controller/policy_cubit.dart:648-825`),
alongside two pure Control-status business-rule methods
(`computeDateBasedStatus`, `resolveControlStatus`, lines 770-795). The two
pages that are 100% about a single Control — `ControlDetailsPage` and
`AddEditControlPage` — depend on `PolicyCubit` exclusively for this; neither
page performs a single Policy operation (confirmed by grepping every
`PolicyCubit`/`PolicyState` reference in both files).

This violates the Code Quality Standards' Single Responsibility principle
("Each module/class/function should have one responsibility") and the
Folder Structure convention (each feature owns its own
`presentation/controller`). It also means the Control feature can't be
reasoned about, tested, or reused independently of Policy.

Confirmed only for `control` + `policy` in this pass. `ChampionCubit` and
`OwnerCubit` independently duplicate their own private copies of
`UpdateControlUseCase`/`GetAllControlsUseCase`/`GetAllPoliciesUseCase` as
thin pass-through methods (`champion_cubit.dart:187-204`,
`owner_cubit.dart` similarly) — the same underlying problem, but explicitly
deferred as a follow-up per user decision; not touched in this change.

## Scope decisions (confirmed)

- **New `ControlCubit`** takes over all four standalone Control operations
  currently on `PolicyCubit`: `createControl`, `updateControl`,
  `deleteControl`, `getAllControls`. It is built from the same four
  already-registered use cases (`CreateControlUseCase`, `UpdateControlUseCase`,
  `DeleteControlUseCase`, `GetAllControlsUseCase`) — no domain/data change.
- **`computeDateBasedStatus`/`resolveControlStatus` do NOT move into
  `ControlCubit`.** They are pure functions of `ControlStatus` with no
  dependencies (no use case, no async, no state). They become static methods
  on the `ControlStatus` enum itself
  (`lib/features/grc/control/domain/entities/control_status.dart`), matching
  the standards' Domain-layer/Enums guidance and removing the need for a
  Cubit instance to call them at all.
- **`PolicyCubit` keeps its own dependency on the four Control use cases**
  for `createPolicy`/`saveAsDraft`/`updatePolicyWithControls` (and their
  private helpers `_createPolicyWithControls`, `_buildCreateControlParams`,
  `_upsertControlForUpdate`). This is deliberate, not leftover duplication:
  "save a Policy plus its bundled initial Controls as one wizard action" is
  a Policy-workflow concern, not Control state. `PolicyCubit` calling
  `ControlCubit` directly (Cubit-to-Cubit coupling) is avoided — both
  Cubits independently depending on the same use cases is the existing,
  correct pattern in this codebase (`ChampionCubit`/`OwnerCubit`/
  `ControlWeightIssueCubit` already share `GetAllControlsUseCase` this way).
- **`PolicyActionPartialSuccess`** stays on `PolicyState` — it describes a
  Policy-level outcome ("Policy saved, N of its Controls failed"), not a
  standalone Control action.
- Scope is strictly `lib/features/grc/control/` and
  `lib/features/grc/policy/`. `ChampionCubit`/`OwnerCubit`'s duplicate
  Control/Policy use-case wrappers are a named follow-up, not part of this
  change.

## New/changed pieces

### Domain — `ControlStatus` (modify)
`lib/features/grc/control/domain/entities/control_status.dart`: add two
static methods, moved verbatim (logic unchanged) from `PolicyCubit`:
- `ControlStatus.computeDateBased(DateTime effectiveStartDate)` — replaces
  `PolicyCubit.computeDateBasedStatus`.
- `ControlStatus.resolve({required ControlStatus requested, required bool
  manualInactive, required bool hasAnyAssignee})` — replaces
  `PolicyCubit.resolveControlStatus`.

### Presentation — new `ControlCubit`
- **`lib/features/grc/control/presentation/controller/control_cubit.dart`**
  (new): `ControlCubit extends Cubit<ControlState>`, constructor takes
  `CreateControlUseCase`, `UpdateControlUseCase`, `DeleteControlUseCase`,
  `GetAllControlsUseCase` (same four already registered in `grc_get_it.dart`).
  Methods `createControl`/`updateControl`/`deleteControl`/`getAllControls`
  moved verbatim from `PolicyCubit` (same params, same emit sequence:
  `ControlLoading` → success/failure state).
- **`lib/features/grc/control/presentation/controller/control_state.dart`**
  (new, `part of 'control_cubit.dart'`): `ControlState` sealed class with
  `ControlInitial`, `ControlLoading`, `ControlActionSuccess(ControlEntity)`,
  `ControlsListLoaded(List<ControlEntity>)`, `ControlDeleted(String
  controlId)`, `ControlFailure(String message)` — same shape as the
  Control-side states currently on `PolicyState`
  (`PolicyControlActionSuccess`/`PolicyControlsListLoaded`/
  `PolicyControlDeleted`), renamed into their own namespace.

### `PolicyCubit`/`PolicyState` (modify)
- Remove `createControl`, `updateControl`, `deleteControl`, `getAllControls`,
  `computeDateBasedStatus`, `resolveControlStatus` and the constructor's
  `getAllControlsUseCase` parameter (confirmed unused outside the
  `getAllControls` method being removed — `createControlUseCase`/
  `updateControlUseCase`/`deleteControlUseCase` stay, see below).
- Remove `PolicyControlActionSuccess`, `PolicyControlsListLoaded`,
  `PolicyControlDeleted` from `policy_state.dart`.
- Keep everything else unchanged, including the internal use of
  `CreateControlUseCase`/`UpdateControlUseCase`/`DeleteControlUseCase` inside
  `_createPolicyWithControls`/`updatePolicyWithControls`/
  `_upsertControlForUpdate` (these keep their own constructor params for
  those four use cases where still needed — `Create`/`Update`/`Delete`, not
  `GetAllControls`, which no orchestration method uses).

### Consumers (modify)
- **`control_details_page.dart`**: drop `PolicyCubit` entirely (it wasn't
  used for anything Policy-specific). `BlocProvider<PolicyCubit>` →
  `BlocProvider<ControlCubit>`; `_openEditControl`/`_onDelete`/
  `_onStateChange` signatures and bodies swap `PolicyCubit`/`PolicyState` →
  `ControlCubit`/`ControlState`; `PolicyControlsListLoaded` →
  `ControlsListLoaded`, `PolicyControlDeleted` → `ControlDeleted`,
  `PolicyFailure` → `ControlFailure`. The `BlocProvider<ControlCubit>.value`
  passed down to `AddEditControlPage` replaces the current
  `BlocProvider<PolicyCubit>.value`.
- **`add_edit_control_page.dart`**: same swap throughout (`_onSave`,
  `_buildActionButtons`, the `BlocListener<PolicyCubit, PolicyState>` at the
  bottom). `cubit.resolveControlStatus(requested:
  cubit.computeDateBasedStatus(_effectiveStartDate), ...)` becomes
  `ControlStatus.resolve(requested:
  ControlStatus.computeDateBased(_effectiveStartDate), ...)` — no Cubit
  needed for that call at all.
- **`policy_details_page.dart`** and **`create_new_policy.dart`**: keep
  `PolicyCubit` (still needed for Policy CRUD) and additionally provide
  `ControlCubit` in the same `MultiBlocProvider`/`BlocProvider` tree
  (mirroring how `control_details_page.dart` already stacks Policy+Champion+
  Owner today). Their `getAllControls` calls and the
  `PolicyControlsListLoaded` branch in each page's state listener move to
  `ControlCubit`/`ControlState`; every Policy-specific branch in those same
  listeners (`PolicyActionSuccess`, `PolicyFailure`, etc.) is untouched.
- **Three call sites push `AddEditControlPage` and need different
  treatment** — confirmed by grepping every `AddEditControlPage(` usage:
  - `control_details_page.dart._openEditControl` already does
    `BlocProvider<PolicyCubit>.value(value: cubit)` (shares the page's own
    instance, not a fresh one) — becomes
    `BlocProvider<ControlCubit>.value(value: cubit)` with `cubit` now typed
    `ControlCubit`. No behavior change, just the type/cubit swapped.
  - `policy_details_page.dart._openAddEditControl` (lines 205-250)
    currently creates a **fresh** `PolicyCubit` via
    `GetIt.instance<PolicyCubit>()` even though the page already holds its
    own `PolicyCubit` at the root — this is an existing, already-flagged
    inconsistency (the page's `_openEditPolicy` two methods above it
    correctly uses `.value` instead). Since this method's fresh `PolicyCubit`
    only existed to give `AddEditControlPage` Control operations, and the
    page will now hold its own `ControlCubit` at the root too (previous
    bullet), `_openAddEditControl` should switch to
    `BlocProvider<ControlCubit>.value(value: context.read<ControlCubit>())`
    — sharing the page's instance, not creating a fresh one. This both
    completes the move and fixes the pre-existing anti-pattern as a direct
    side effect, rather than relocating it into new code. The post-return
    refresh call at line 246-248 (`context.read<PolicyCubit>().getAllControls(...)`)
    becomes `context.read<ControlCubit>().getAllControls(...)`.
  - `policy_view_mode_widget.dart` (lines ~390-428) creates a fresh
    `PolicyCubit`/`ChampionCubit`/`OwnerCubit` set with no ancestor Policy/
    Control cubit in scope (per its own comment — this widget has no
    guaranteed provider ancestor). This one stays "fresh" by design; only
    swap the fresh `PolicyCubit` for a fresh `ControlCubit` here, no sharing
    change needed.
- **`grc_get_it.dart`**: add
  `sl.registerFactory<ControlCubit>(() => ControlCubit(createControlUseCase:
  sl(), updateControlUseCase: sl(), deleteControlUseCase: sl(),
  getAllControlsUseCase: sl()))` next to the existing Control use-case
  registrations; remove only the `getAllControlsUseCase` argument from
  `PolicyCubit`'s registration — its `createControlUseCase`/
  `updateControlUseCase`/`deleteControlUseCase` arguments stay, since the
  wizard orchestration methods still depend on them directly.

## Out of scope

- `ChampionCubit`/`OwnerCubit`'s own duplicate Control/Policy use-case
  wrappers (`updateControl`, `getAllControlsForPolicy`, `getAllPolicies`) —
  confirmed follow-up, not touched here.
- Any change to `ControlRepository`, `ControlFirebaseDataSource`,
  `ControlModel`, or any of the five Control use cases — this is a
  presentation-layer move only.
- `PolicyWeightIssueCubit`/`ControlWeightIssueCubit`/
  `ControlWeightHistoryCubit` — already their own independent, correctly-
  scoped Cubits; unaffected.

## Testing

`ControlCubit` is new code, so it gets unit tests at the same level of
coverage the six model fixes just received: for each of
`createControl`/`updateControl`/`deleteControl`/`getAllControls`, one test
asserting the success emit sequence (`ControlLoading` → the matching
success state) with a fake/stub use case returning `Right(...)`, and one
asserting `ControlLoading` → `ControlFailure` when the use case returns
`Left(...)`. No existing Cubit in this codebase (`PolicyCubit`,
`ChampionCubit`, etc.) has unit tests, so this is proportionate new coverage,
not a new precedent being invented.

`ControlStatus.computeDateBased`/`.resolve` get direct unit tests too (pure
functions, cheap to cover completely: date-before/after-today boundary for
`computeDateBased`; each of the draft/manualInactive/no-assignee/has-assignee
branches for `resolve`).

No behavior change is intended anywhere — this is a structural move. After
implementation, `flutter analyze` must be clean on every touched file, and a
manual walkthrough (once a Flutter environment is available) should cover:
open a Policy, view its Controls list, open a Control's details, edit it,
delete it, and create a new Policy with initial Controls — confirming all
still work identically to before the move.
