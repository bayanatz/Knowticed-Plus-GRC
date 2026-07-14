# Policy/Control repository, use-case, and cubit layer — design

Date: 2026-07-14

## Problem

The Policy/Control data layer (`PolicyModel`, `ControlModel`, their entities,
data sources) was migrated to the new schema on 2026-07-14: Controls are now
their own Firestore subcollection
(`GRC Modules/{Module_ID}/Policies/{Policy_ID}/Controls/{Control_ID}`)
instead of an embedded list on the Policy document. That data layer is
correct and confirmed compiling clean (`dart analyze`).

The layers above it were left targeting the *pre-migration* shape and do not
compile:

- `PolicyRepositoryImpl` has ad-hoc `createControl`/`getControl`/
  `getAllControls`/`updateControl`/`deleteControl` methods and an extra
  `controls` param on `createPolicy` that reference `CreateControlParams` — a
  type that is never defined anywhere in `lib/`. None of these methods are
  declared on the `PolicyRepository` interface (whose own docstrings already
  say Control operations belong in a separate `ControlRepository` that does
  not yet exist).
- `create_policy_usecase.dart`/`update_policy_usecase.dart`'s `Params`
  classes carry a `List<CreateControlParams> controls` field (same undefined
  type) and a single `policyDocumentFile`/`policyDocumentUrl` pair, while the
  repository interface they call into already takes the split
  `policyDocumentFileEn/Ar` + `policyDocumentUrlEn/Ar`.
- `get_policy_usecases.dart`'s `GetAllPoliciesUseCase` forwards
  `includeDeleted` to `PolicyRepository.getAllPolicies`, whose actual param
  is `includeRemoved`.
- `policy_cubit.dart` mirrors all of the above (single document field,
  `controls: List<CreateControlParams>`, `includeDeleted`) and never calls
  any Control-specific operation.
- `grc_get_it.dart` registers `PolicyRepositoryImpl` without the
  `ControlFirebaseDataSource` constructor argument that (the currently
  broken) `PolicyRepositoryImpl` declares as required, and never registers
  `ControlFirebaseDataSource` at all.

This spec brings the repository → use-case → cubit → DI chain back into a
consistent, compiling state, and adds the missing `Control` side of that
chain, following the `GRCModuleRepository`/`GRCModuleCubit` pattern already
established elsewhere in this feature.

## Out of scope

- Any UI file (`create_new_policy.dart`, `add_policy_controls.dart`,
  `policy_control_model.dart`, table/item widgets). The Create-Policy form
  currently builds `List<CreateControlParams>` by hand and calls
  `PolicyCubit.createPolicy(controls: ...)`; wiring the UI to the new Cubit
  API (see section D) is a separate follow-up once this layer is approved
  and working. Until that follow-up lands, the UI files will not compile
  against the new Cubit signatures — that is expected and acceptable for
  this pass.
- Policy/Control view or edit pages — none exist today (confirmed via
  search), so nothing to update there.
- Any change to `PolicyModel`/`ControlModel`/entities/data sources
  (`data_source/*`) — already correct, not touched here except where noted.
- Test-writing (per this user's usual fast-iteration mode for this repo).

## A. New `ControlRepository` (domain) + `ControlRepositoryImpl` (data)

`domain/repository/control_repository.dart` — new interface, same shape as
`PolicyRepository`: `Either<Failure, T>` returns, Entities only.

```dart
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

`data/repository/control_repository_impl.dart` — new file. Implements the
above using `ControlFirebaseDataSource` + `PolicyStorageDataSource` (for
`uploadControlDocument`/`deleteFile`). This is a straight extraction of the
`createControl`/`getControl`/`getAllControls`/`updateControl`/`deleteControl`
bodies and the `_createControlModel`/`_resolveFile` helpers currently sitting
(broken) inside `PolicyRepositoryImpl` — logic doesn't change, only where it
lives, and `_createControlModel` drops its `CreateControlParams params`
parameter in favor of the same flat named params `createControl` takes
(no more `CreateControlParams` type at the repository layer at all).

## B. `PolicyRepositoryImpl` cleanup

Remove: `controlDataSource` constructor param + `_controlDataSource` field,
the `createControl`/`getControl`/`getAllControls`/`updateControl`/
`deleteControl` overrides, `_createControlModel`, the `controls` param and
its creation loop inside `createPolicy`, and the now-unused
`ControlModel`/`ControlEntity`/`ControlStatus` imports.
`PolicyRepositoryImpl` goes back to depending only on
`PolicyFirebaseDataSource` + `PolicyStorageDataSource`, matching what
`PolicyRepository`'s interface already (correctly) declares today — no
interface changes needed in `policy_repository.dart`.

## C. Use-case fixes

- `create_policy_usecase.dart` (`CreatePolicyParams`/`CreatePolicyUseCase`):
  remove the `controls` field; rename `policyDocumentFile`/`policyDocumentUrl`
  to `policyDocumentFileEn`/`policyDocumentUrlEn` +
  `policyDocumentFileAr`/`policyDocumentUrlAr`, forwarded 1:1 to
  `PolicyRepository.createPolicy`.
- `update_policy_usecase.dart` (`UpdatePolicyParams`/`UpdatePolicyUseCase`):
  same two fixes (drop `controls`, split document field).
- `get_policy_usecases.dart` (`GetAllPoliciesUseCase`): rename `includeDeleted`
  → `includeRemoved` in both the `call(...)` signature and the forwarded
  repository call.
- New `create_control_usecase.dart` — `CreateControlParams` (this is a
  *use-case* params object, not the removed repository-layer type from
  section B; it groups `moduleId`/`policyId`/`editorId` + every Control field
  exactly like `CreatePolicyParams` does for Policy) + `CreateControlUseCase`.
- New `update_control_usecase.dart` — `UpdateControlParams` +
  `UpdateControlUseCase`.
- New `get_control_usecases.dart` — `GetControlUseCase`,
  `GetAllControlsUseCase`, `DeleteControlParams` + `DeleteControlUseCase`
  (no `RestoreControlUseCase` — Controls have no Removed state).

## D. `PolicyCubit` — bundled create, decoupled everything else

`PolicyRepository`/use cases stay fully decoupled from Control (per section
A/B). `PolicyCubit` is where the two meet, since this feature keeps a single
cubit for both (per your choice) and the Create-Policy page's UX is "one
submit button, policy + its initial controls together."

New lightweight input type (cubit-facing only, not a use-case or repository
type) so the caller doesn't need a `policyId` before one exists:

```dart
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
  // (const constructor, all required except the four file/url fields)
}
```

`createPolicy`/`saveAsDraft` signatures change:
`List<CreateControlParams> controls` → `List<PendingControlInput> controls`
(default `const []`); `imageFile`/`imageUrl` stay as-is (`Policy_Image` is
not split by language); `policyDocumentFile`/`policyDocumentUrl` become the
En/Ar pairs, matching section C.

Orchestration inside both methods:

1. `emit(PolicyLoading())`.
2. Call `_createUseCase.call(CreatePolicyParams(...))` (no controls inside
   it anymore).
3. On `Left`: `emit(PolicyFailure(...))`, stop — no controls are attempted
   without a persisted Policy.
4. On `Right(policy)`: if `controls` is empty, `emit(PolicyActionSuccess(policy))`,
   done. Otherwise, loop calling `_createControlUseCase.call(CreateControlParams(
   moduleId: moduleId, policyId: policy.id, editorId: _currentUserId, ...))`
   for each `PendingControlInput`, collecting `(input, failureMessage)` pairs
   for any `Left` result.
5. If all controls succeeded: `emit(PolicyActionSuccess(policy))`.
   If some failed: `emit(PolicyActionPartialSuccess(policy, failedControls))`
   — the Policy already exists in Firestore at this point (this is not a
   transaction), so silently reporting full success would hide real data
   loss; a dedicated state lets the UI (in the later follow-up) tell the user
   which specific controls need re-adding.

`updatePolicy` drops the `controls`/`List<CreateControlParams>?` param
entirely — editing controls on an existing policy goes through the new
standalone methods below, always with a real `policyId` already in hand.

New standalone methods (thin wrappers, same `Loading → use case → fold`
shape as every other method in this cubit and in `GRCModuleCubit`):

- `createControl({required moduleId, required policyId, ...control fields})`
  → `PolicyControlActionSuccess(control)` / `PolicyFailure`.
- `updateControl({required id, required moduleId, required policyId, ...})`
  → `PolicyControlActionSuccess(control)` / `PolicyFailure`.
- `deleteControl({required id, required moduleId, required policyId})` →
  `PolicyControlDeleted(id)` / `PolicyFailure`.
- `getAllControls({required moduleId, required policyId})` →
  `PolicyControlsListLoaded(controls)` / `PolicyFailure`.

`policy_state.dart` gains:

```dart
final class PolicyActionPartialSuccess extends PolicyState {
  final PolicyEntity policy;
  final List<({PendingControlInput input, String message})> failedControls;
}
final class PolicyControlActionSuccess extends PolicyState {
  final ControlEntity control;
}
final class PolicyControlsListLoaded extends PolicyState {
  final List<ControlEntity> controls;
}
final class PolicyControlDeleted extends PolicyState {
  final String controlId;
}
```

`PolicyCubit`'s constructor gains four new required use-case params
(`createControlUseCase`, `updateControlUseCase`, `deleteControlUseCase`,
`getAllControlsUseCase`); `getControlUseCase` is registered in DI for
completeness/future use but not wired into the cubit this round since there
is no single-control-fetch UI need yet.

## E. DI (`grc_get_it.dart`)

1. Register `ControlFirebaseDataSource` (data source section).
2. Register `ControlRepository` → `ControlRepositoryImpl` (repository
   section), depending on `ControlFirebaseDataSource` + `PolicyStorageDataSource`.
3. Drop the `controlDataSource:` line from the `PolicyRepositoryImpl`
   registration (no longer a constructor param, per section B).
4. Register the five new Control use cases (use-case section), each built
   from `sl<ControlRepository>()`.
5. Update the `PolicyCubit` registration to also inject
   `createControlUseCase`/`updateControlUseCase`/`deleteControlUseCase`/
   `getAllControlsUseCase` from `sl<...>()`.

## Files touched

- New: `domain/repository/control_repository.dart`,
  `data/repository/control_repository_impl.dart`,
  `domain/use_cases/create_control_usecase.dart`,
  `domain/use_cases/update_control_usecase.dart`,
  `domain/use_cases/get_control_usecases.dart`.
- Modified: `data/repository/policy_repository_impl.dart`,
  `domain/use_cases/create_policy_usecase.dart`,
  `domain/use_cases/update_policy_usecase.dart`,
  `domain/use_cases/get_policy_usecases.dart`,
  `presentation/controller/policy_cubit.dart`,
  `presentation/controller/policy_state.dart`, `grc_get_it.dart`.
- Not touched: anything under `presentation/ui/`, `policy_repository.dart`
  (interface unchanged), all `data_source/*` and `models/*`/`entities/*`
  files (already correct).

## Testing

Per this repo's established fast-iteration mode: no automated tests this
round. Verification is `dart analyze lib/features/grc/` reporting no errors
across the touched + newly-added files (the pre-existing UI compile errors
in `presentation/ui/**` from calling the old Cubit signatures are expected
and out of scope per this spec — they get fixed in the UI follow-up).
