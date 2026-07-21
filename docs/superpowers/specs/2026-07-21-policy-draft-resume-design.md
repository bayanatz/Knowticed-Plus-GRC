# Resume Draft Policy + Reliable List Reload Design

**Goal:** Fix two gaps in the Policy "Save For Later" flow:

1. Tapping a **Draft**-status policy card currently opens the read-only
   `PolicyDetailsPage`, the same as any other policy. It should instead
   reopen the `CreateNewPolicyPage` wizard, prefilled with everything the
   user already entered (including any Controls already saved with it), so
   the user can keep going from where they left off — through Controls and
   Preview — until they press Publish (or Save For Later again).
2. After creating/editing a Policy (or its Controls) and returning to the
   GRC Module details page, the policy list doesn't reliably refresh — the
   existing `if (result == true)` reload guard depends on every intermediate
   page popping with the right boolean, which several paths (the AppBar back
   arrow, the tablet breadcrumb) don't do.

**Architecture:** No new pages, no schema changes. `CreateNewPolicyPage`
gains an optional `existingPolicy` parameter; when present, it prefills its
existing step 0/1 state instead of starting blank, fetches the policy's
already-saved Controls once, and — on Save For Later / Publish — updates the
same Policy/Control documents in place instead of creating new ones. The
list-reload fix is a small, independent simplification: stop trying to
thread a "did anything change" result through nested navigation, and just
always refetch when returning to the list.

**Tech Stack:** Flutter, `flutter_bloc` (Cubit), existing `PolicyRepository`/
`ControlRepository` use cases — no new dependencies.

## Global Constraints

- No changes to `PolicyEntity`, `ControlEntity`, `PolicyModel`, `ControlModel`,
  Firestore schema, or `PolicyStatus`/`ControlStatus` enums.
- No changes to `PolicyDetailsPage`, `PolicyEditPage`, `CustomAppBar`,
  `PaginationAppBar`, or the tablet breadcrumb — the list-reload fix makes
  those unnecessary to touch (see Part 3).
- The wizard always reopens a resumed draft at Step 0 — there is no stored
  "which step was the user on" concept, and adding one is out of scope.
- Departments/equal-weights/score on an existing Control are left untouched
  when resuming — the Create wizard's `PolicyControlModel` has never
  captured those fields (they're only editable later via
  `AddEditControlPage`), so `updateControl` calls simply omit them (nullable
  params → unchanged).
- This repo has no mocking library and no existing Cubit/widget tests (see
  the Policy Bulk Upload plan's Global Constraints for precedent) — new
  Cubit logic here is verified via `flutter analyze`/`dart analyze` plus a
  manual click-through, matching the rest of this feature area.

---

## Part 1: Draft cards open the wizard

**File:** `lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart`

`_PolicyCard.onTap` currently always pushes `PolicyDetailsPage`. It will
branch:

```dart
onTap: () async {
  if (policy.status == PolicyStatus.draft) {
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CreateNewPolicyPage(
          moduleId: module.moduleId,
          moduleNameEn: module.moduleNameEn,
          moduleNameAr: module.moduleNameAr,
          existingPolicy: policy,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  } else {
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PolicyDetailsPage(
          policyId: policy.id,
          moduleId: module.moduleId,
          module: module,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  if (context.mounted) {
    context.read<PolicyCubit>().getAllPolicies(moduleId: module.moduleId);
  }
},
```

(The unconditional reload at the end is Part 3 — folded in here since it's
the same call site.)

Only `PolicyStatus.draft` routes to the wizard. Every other status
(`active`, `inactive`, `scheduled`, `expired`) keeps today's
`PolicyDetailsPage` behavior unchanged.

---

## Part 2: Resuming a draft in `CreateNewPolicyPage`

**Files:**
- `lib/features/grc/policy/presentation/ui/pages/create_new_policy.dart`
- `lib/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart`
- `lib/features/grc/policy/presentation/controller/policy_cubit.dart`
- `lib/features/grc/policy/presentation/controller/policy_state.dart` (no new state classes needed — reuses `PolicyActionSuccess`/`PolicyActionPartialSuccess`/`PolicyFailure`)

### 2.1 `PolicyControlModel` gains an identity field

```dart
class PolicyControlModel {
  // ...existing fields...
  final String? existingControlId;

  PolicyControlModel({
    // ...existing params...
    this.existingControlId,
  });
}
```

`null` means "not persisted yet — create it." Non-null means "this came
from a saved Control — update it in place." This is the only structural
change to the model; everything else about how the wizard edits a control
card is unchanged.

### 2.2 `CreateNewPolicyPage` accepts and prefills from `existingPolicy`

```dart
class CreateNewPolicyPage extends StatefulWidget {
  final String moduleId;
  final String moduleNameEn;
  final String moduleNameAr;
  final PolicyEntity? existingPolicy; // new, defaults to null

  const CreateNewPolicyPage({
    super.key,
    required this.moduleId,
    required this.moduleNameEn,
    required this.moduleNameAr,
    this.existingPolicy,
  });
  ...
}
```

In `initState`, when `widget.existingPolicy != null`, prefill:

- `_nameController`/`_nameArController`/`_numberController`/`_numberArController`/
  `_descriptionController`/`_descriptionArController`/`_weightController` from
  the matching entity fields.
- `_startDate`/`_endDate` from `existingPolicy.startDate`/`.endDate`.
- `_documentEn`/`_documentAr` via `PolicyDocumentInfo.fromUrl(...)` (same
  helper `PolicyEditPage` already uses) when `policyDocumentEn`/`Ar` is set.
- A new `_imageUrl` field (mirrors the document pattern) from
  `existingPolicy.policyImage`, carried through to `imageUrl:` on save
  whenever the user hasn't picked a new `_imageFile`.
- `_isArabicEnabled = existingPolicy.policyNameAr.trim().isNotEmpty || existingPolicy.policyNumberAr.trim().isNotEmpty || existingPolicy.policyDescriptionAr.trim().isNotEmpty`
  (there's no stored toggle — this infers it the same way the fields
  themselves imply it).

Controls are fetched, not passed in directly, since `CreateNewPolicyPage`
today only receives IDs/names for the module — not a pre-loaded control
list. The page's `BlocProvider.create` kicks this off:

```dart
create: (_) {
  final cubit = GetIt.instance<PolicyCubit>();
  if (widget.existingPolicy != null) {
    cubit.getAllControls(
      moduleId: widget.moduleId,
      policyId: widget.existingPolicy!.id,
    );
  }
  return cubit;
},
```

`_onStateChange` gains one more branch:

```dart
if (state is PolicyControlsListLoaded) {
  if (widget.existingPolicy == null) return; // only relevant when resuming
  _originalControlIds = state.controls.map((c) => c.id).toSet();
  setState(() {
    for (final c in _controls) c.dispose();
    _controls = state.controls.isEmpty
        ? [PolicyControlModel()]
        : state.controls.map(_controlModelFromEntity).toList();
  });
  return;
}
```

with a small mapper:

```dart
PolicyControlModel _controlModelFromEntity(ControlEntity c) => PolicyControlModel(
      existingControlId: c.id,
      nameController: TextEditingController(text: c.controlsNameEn),
      nameArController: TextEditingController(text: c.controlsNameAr),
      numberController: TextEditingController(text: c.controlsNumberEn),
      numberArController: TextEditingController(text: c.controlsNumberAr),
      descriptionController: TextEditingController(text: c.controlsDescriptionEn),
      descriptionArController: TextEditingController(text: c.controlsDescriptionAr),
      weightController: TextEditingController(text: c.controlsWeight.toStringAsFixed(0)),
      frequency: c.frequency,
      startDate: c.startDate,
      endDate: c.endDate,
      documentEn: c.controlsDocumentEn != null ? PolicyDocumentInfo.fromUrl(c.controlsDocumentEn!) : null,
      documentAr: c.controlsDocumentAr != null ? PolicyDocumentInfo.fromUrl(c.controlsDocumentAr!) : null,
    );
```

`_originalControlIds` (a `Set<String>`, empty by default) is a new field on
`_CreateNewPolicyPageState`, snapshotting which control ids existed when the
page opened — used below to detect removals.

The loading indicator already shown for `PolicyLoading` covers this initial
fetch, so the user sees a brief spinner rather than an empty Step 0 before
their data appears — consistent with how every other async load in this
app already behaves.

### 2.3 Save For Later / Publish branch on `existingPolicy`

`_buildPendingControls` adds one field to the constructed
`PendingControlInput`:

```dart
controlsDocumentFileEn: c.documentEn?.file,
controlsDocumentFileAr: c.documentAr?.file,
existingControlId: c.existingControlId, // new
```

(Harmless for the normal create path — always `null` there.)

`_onSaveForLater`/`_onPublish` branch:

```dart
void _onSaveForLater(PolicyCubit cubit) {
  if (widget.existingPolicy != null) {
    _updateExisting(cubit, status: PolicyStatus.draft);
    return;
  }
  cubit.saveAsDraft(/* unchanged */);
}

void _onPublish(PolicyCubit cubit) {
  if (widget.existingPolicy != null) {
    _updateExisting(cubit, status: PolicyStatus.active);
    return;
  }
  cubit.createPolicy(/* unchanged */);
}

void _updateExisting(PolicyCubit cubit, {required PolicyStatus status}) {
  final currentIds = _touchedControls
      .map((c) => c.existingControlId)
      .whereType<String>()
      .toSet();
  cubit.updatePolicyWithControls(
    id: widget.existingPolicy!.id,
    moduleId: widget.moduleId,
    status: status,
    policyNameEn: _nameController.text.trim(),
    policyNameAr: _nameArController.text.trim(),
    policyNumberEn: _numberController.text.trim(),
    policyNumberAr: _numberArController.text.trim(),
    policyDescriptionEn: _descriptionController.text.trim(),
    policyDescriptionAr: _descriptionArController.text.trim(),
    startDate: _startDate ?? DateTime.now(),
    endDate: _endDate ?? DateTime.now(),
    policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
    controls: _buildPendingControls(
      status == PolicyStatus.active ? ControlStatus.active : ControlStatus.draft,
    ),
    removedControlIds: _originalControlIds.difference(currentIds).toList(),
    imageFile: _imageFile,
    imageUrl: _imageFile == null ? _imageUrl : null,
    policyDocumentFileEn: _documentEn?.file,
    policyDocumentUrlEn: _documentEn?.file == null ? _documentEn?.url : null,
    policyDocumentFileAr: _documentAr?.file,
    policyDocumentUrlAr: _documentAr?.file == null ? _documentAr?.url : null,
  );
}
```

`removedControlIds` catches both a deleted control card and a card the user
cleared back to empty (`controlIsTouched` false → excluded from
`_touchedControls` → its id, if it had one, falls out of `currentIds` and
is treated as removed).

`_onStateChange`'s existing `PolicyActionSuccess` handling (show the
Draft/Created dialog, `Navigator.pop(true)`) already reads
`state.policy.status.value` to pick the dialog title, so Publish vs. Save
For Later on a resumed draft shows the right dialog with no extra branching
needed there.

### 2.4 `PolicyCubit.updatePolicyWithControls`

New method, same orchestration shape as the existing
`_createPolicyWithControls`:

```dart
Future<void> updatePolicyWithControls({
  required String id,
  required String moduleId,
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
  required List<PendingControlInput> controls,
  required List<String> removedControlIds,
  File? imageFile,
  String? imageUrl,
  File? policyDocumentFileEn,
  String? policyDocumentUrlEn,
  File? policyDocumentFileAr,
  String? policyDocumentUrlAr,
}) async {
  emit(PolicyLoading());
  final editorId = _currentUserEmail;

  final result = await _updateUseCase.call(UpdatePolicyParams(
    id: id,
    editorId: editorId,
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
  ));

  await result.fold(
    (failure) async => emit(PolicyFailure(failure.message)),
    (policy) async {
      for (final controlId in removedControlIds) {
        final r = await _deleteControlUseCase.call(
          DeleteControlParams(id: controlId, moduleId: moduleId, policyId: id),
        );
        if (r.isLeft()) {
          // The Policy itself already saved successfully at this point;
          // a delete failure still needs to surface, so it short-circuits
          // as a plain failure rather than forcing its way into
          // PolicyActionPartialSuccess's PendingControlInput-shaped list.
          emit(PolicyFailure(r.fold((f) => f.message, (_) => '')));
          return;
        }
      }

      final failedControls = <({PendingControlInput input, String message})>[];
      for (final input in controls) {
        final controlResult = input.existingControlId != null
            ? await _updateControlUseCase.call(UpdateControlParams(
                id: input.existingControlId!,
                moduleId: moduleId,
                policyId: id,
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
                status: input.status,
                controlsDocumentFileEn: input.controlsDocumentFileEn,
                controlsDocumentFileAr: input.controlsDocumentFileAr,
              ))
            : await _createControlUseCase.call(CreateControlParams(
                moduleId: moduleId,
                policyId: id,
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
                controlsDocumentFileAr: input.controlsDocumentFileAr,
              ));
        controlResult.fold(
          (failure) => failedControls.add((input: input, message: failure.message)),
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
```

`PendingControlInput` gains one field:

```dart
class PendingControlInput {
  // ...existing fields...
  final String? existingControlId;

  const PendingControlInput({
    // ...existing params...
    this.existingControlId,
  });
}
```

---

## Part 3: Always reload the list on return

**File:** `grc_module_details_page.dart`

Both call sites that push into a Policy-mutating page — `_PolicyCard.onTap`
(shown in full in Part 1) and `_showPolicyCreationMenu` (Add Policy / Bulk
Upload) — drop their `if (result == true)` guard and unconditionally call
`context.read<PolicyCubit>().getAllPolicies(moduleId: ...)` once the pushed
page returns, guarded only by `context.mounted`. This replaces trying to
thread a reliable "did anything change" boolean through
`PolicyDetailsPage` → `PolicyEditPage`/`AddEditControlPage`/
`ControlBulkUploadPage` and back out again (which today misses real edits
whenever the user leaves via the AppBar back arrow or a tablet breadcrumb
jump — both call `Navigator.pop()` with no result, confirmed by reading
`CustomAppBar`/`PaginationAppBar`).

This is intentionally the smallest possible fix: one extra Firestore list
read on an already-infrequent navigation event, in exchange for removing an
entire class of "reload silently didn't happen" bugs across every current
and future way of leaving these pages.

---

## Error Handling

- If `updatePolicyWithControls`'s Policy update itself fails, nothing else
  runs — same fail-fast contract as `_createPolicyWithControls`.
- If the Policy update succeeds but a Control *delete* fails, that's
  surfaced immediately as `PolicyFailure` (see note in 2.4) rather than a
  partial success — the Policy and any already-applied control changes
  still stand at that point.
- If the Policy update succeeds but a Control *create/update* fails,
  `PolicyActionPartialSuccess` is emitted (Policy already changed in
  Firestore, same as the existing create-with-controls path). Confirmed by
  reading `create_new_policy.dart`'s current `_onStateChange`: it has no
  case for `PolicyActionPartialSuccess` today (only `PolicyLoading`/
  `PolicyActionSuccess`/`PolicyFailure`), so it silently falls through —
  a pre-existing gap in the *create* path this feature reuses as-is rather
  than fixing, to stay in scope.

## Out of Scope

- Persisting "which wizard step the user was on" for a draft — always
  reopens at Step 0.
- Fixing the tablet breadcrumb's multi-level `Navigator.pop()` loop or
  `CustomAppBar`'s back arrow to carry a result — made unnecessary by Part 3.
- Any change to Control departments/equal-weights/score handling.
