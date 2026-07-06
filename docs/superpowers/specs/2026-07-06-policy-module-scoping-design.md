# Policy scoped under GRC Module — design

Date: 2026-07-06

## Problem

Today `Policies` is a top-level Firestore collection, unrelated to any GRC
Module. Tapping a module card in `grc_page.dart` opens the module's own
view/edit/delete/restore form (`GovernanceRiskAndComplianceDetails`), and
`GrcModuleDetailsPage` (the page with the "Create Policy" button) is entirely
static/hardcoded — it takes no module, shows a fake title, fake status
counts, and no real policy list. Creating a policy never records which
module it belongs to.

## Goal

- Tapping a (non-deleted) module card opens `GrcModuleDetailsPage` for that
  specific module.
- From there, creating a Policy sends the module id along, and the Policy's
  Firestore document lives inside that module's own collection (a true
  parent/child relationship), not a flat top-level collection.
- `GrcModuleDetailsPage` shows the real module name, real policy status
  counts, and a real (searchable) list of the module's policies.

## Out of scope

- A view/edit page for an individual Policy (tapping a policy card is a
  no-op for now).
- Rewiring the module's own edit/view/restore navigation — the user will
  handle that separately.
- The unrelated placeholder UI already on `GrcModuleDetailsPage` (Approved
  Evidence, Approvals, Assignment Controls, My Audits, Policy Weight Issue,
  view-mode icons, the `All/Pending/Approved` tabs).
- The top-of-list "Dashboard" button in `grc_page.dart` — removed, since it
  had no module to attach to and wasn't asked for.

## A. Firestore structure

`PolicyFirebaseDataSource` moves from the top-level `Policies` collection to
a subcollection under the module:

```
GRC Modules/{moduleId}/Policies/{policyId}
```

Every method (`create`, `get`, `getAll`, `update`, `delete`, `restore`)
gains a `required String moduleId` used to build the collection reference,
e.g.:

```dart
CollectionReference<Map<String, dynamic>> _policiesCollection(String moduleId) =>
    _firestore.collection('GRC Modules').doc(moduleId).collection('Policies');
```

`PolicyModel` and `PolicyEntity` gain a plain `moduleId` field (not a
history list — a policy never switches parent module), serialized as
`Module_ID`. This lets any code holding a `PolicyEntity` know its parent
module without extra plumbing.

## B. `moduleId` threading

`moduleId` becomes a required parameter end-to-end, since every Policy
operation needs to know which module's subcollection to hit:

- `PolicyRepository` (interface + impl): `createPolicy`, `getPolicy`,
  `getAllPolicies`, `updatePolicy`, `deletePolicy`, `restorePolicy` all gain
  `required String moduleId`.
- Use cases: `CreatePolicyParams`, `UpdatePolicyParams`,
  `DeletePolicyParams`, `RestorePolicyParams` gain a `moduleId` field;
  `GetPolicyUseCase.call` and `GetAllPoliciesUseCase.call` gain a `moduleId`
  argument.
- `PolicyCubit`: every public method (`getAllPolicies`, `getPolicy`,
  `createPolicy`, `saveAsDraft`, `updatePolicy`, `deletePolicy`,
  `restorePolicy`) gains `required String moduleId`, forwarded down.
- `CreateNewPolicyPage`: gains a `required String moduleId` constructor
  param, forwarded to its `createPolicy`/`saveAsDraft` calls.

## C. Navigation & `GrcModuleDetailsPage` rewiring

- `grc_page.dart`: in `_buildBody`/`cardFor`, non-deleted modules now push
  `GrcModuleDetailsPage(module: moduleAt(index))` directly (not through
  `GovernanceRiskAndComplianceDetails`); deleted modules keep going through
  `_openDetails(context, GrcPageMode.restore, entity: ...)` exactly as
  today.
- The top-of-list "Dashboard" button in `_buildActionBar` is removed.
- `GrcModuleDetailsPage` becomes a page that takes
  `required GRCModuleEntity module`:
  - Title shows the real module name
    (`context.isArabic ? module.grcModuleNameArabic : module.grcModuleNameEnglish`)
    instead of the hardcoded `'GRC Module Name'`.
  - Wraps itself in a `BlocProvider<PolicyCubit>` that calls
    `getAllPolicies(moduleId: module.id, includeDeleted: true)` on creation
    (mirroring the `GrcResponsivePage` pattern used for modules).
  - The fake `status` counts list (`all/Active/Inactive/Expired/Draft` with
    hardcoded numbers) is replaced with counts computed from the fetched
    `List<PolicyEntity>`, grouped by `PolicyStatus`.
  - A real, searchable list/grid of policy cards is rendered below (new
    small `_PolicyCard` widget, modeled on `_GrcModuleCard` in
    `grc_page.dart`) — tapping a card is a no-op for now.
  - Both "Policy" create buttons call
    `CreateNewPolicyPage(moduleId: module.id)` instead of
    `CreateNewPolicyPage()`.
  - Everything else on the page (Approved Evidence, Approvals, Assignment
    Controls, My Audits, Policy Weight Issue, view-mode icons, the
    `CustomTabs(['All','Pending','Approved'])`) is left untouched.

## Testing

- Unit test for `PolicyModel.toJson()`/`fromJson()` round-tripping the new
  `moduleId` field.
- Manual verification: create a policy from a module's details page, confirm
  the Firestore document lands under
  `GRC Modules/{moduleId}/Policies/{policyId}`, and that the module's policy
  list/counts reflect it after creation.
