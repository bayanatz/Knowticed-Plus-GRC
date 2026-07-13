# GRC Previous Module Owners — design

Date: 2026-07-13

## Problem

The GRC module list page (`grc_page.dart`) already has a "Previous Module
Owners" item in each module's popup menu (`_showModuleMenu`, value
`'previousModuleOwners'`), but selecting it does nothing — there's no
`if (selected == 'previousModuleOwners')` branch and no page behind it.

The ask: tapping it should open a page showing everyone who has ever been
removed as an owner of that module — who they were, who assigned them, and
the date range they held the role — one row per removal event.

## Data model

`GRCModuleModel` already carries everything needed as history lists, just
not in table form:

- `moduleOwners`: each element is `jsonEncode(List<String>)` of the owner
  emails in effect as of that revision.
- `modifiers`: the email of whoever saved that revision.
- `modificationDate`: when that revision was saved.

There is no dedicated "assignment" record — "Assigned By" is defined as
whoever saved the revision that introduced a given owner, and "removed" is
defined as an owner email disappearing from `moduleOwners` between one
revision and the next.

### Scope decisions (confirmed)

- **Removed owners only.** Current owners never appear on this page — a row
  is only created once someone is actually removed. This matches the page's
  own name ("Previous" owners) and "every time someone gets removed, it
  gets added to the table."
- **Assigned By = whoever saved the edit that added them.** When an owner
  email appears in revision N's `moduleOwners` but wasn't in revision N-1's,
  `modifiers[N]` is credited as "Assigned By" for that stint.
- **One row per stint, not per person.** If the same person is added,
  removed, added again, and removed again, that's two separate rows with
  their own Start/End Date — not one row collapsed to the latest dates.

### Algorithm: `GRCModuleModel.toOwnerHistory()`

A new method on `GRCModuleModel` (same spirit as `toEntity()` — converts the
raw parallel-list history into something the UI can consume directly):

1. Decode every revision's owner set: `ownerSets[i] = Set<String>.from(jsonDecode(moduleOwners[i]))`.
2. Maintain `openStints: Map<String email, {startDate, assignedBy}>`,
   seeded from `ownerSets[0]` (owners present at creation open a stint
   at `modificationDate[0]` / `modifiers[0]`).
3. For `i` from 1 to the last revision:
   - Any email in `ownerSets[i]` but not `ownerSets[i-1]` → opens a new
     stint: `startDate = modificationDate[i]`, `assignedBy = modifiers[i]`.
   - Any email in `ownerSets[i-1]` but not `ownerSets[i]` → closes that
     email's currently open stint: emit
     `GRCModuleOwnerHistoryEntry(ownerEmail: email, assignedByEmail: <that stint's assignedBy>, startDate: <that stint's startDate>, endDate: modificationDate[i])`,
     then remove the entry from `openStints` (so a later re-add starts a
     genuinely new stint).
4. Return the emitted entries only (open/current stints are never emitted),
   sorted by `endDate` descending (most recently removed first).

This reuses the exact Firestore document fetch `getModule`/`getAll` already
perform (`GRCModuleFirebaseDataSource.get`, which already returns a full
`GRCModuleModel` with every history list) — no new Firestore location, no
new writes, no schema change.

## New/changed pieces

- **`lib/features/grc/domain/entities/grc_module_owner_history_entry.dart`**
  (new): plain entity —
  ```dart
  class GRCModuleOwnerHistoryEntry {
    final String ownerEmail;
    final String assignedByEmail;
    final DateTime startDate;
    final DateTime endDate;
  }
  ```
- **`grc_module_model.dart`** (modify): add `toOwnerHistory()` as described
  above.
- **`grc_module_repository.dart`** (modify): add
  `Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>> getModuleOwnerHistory(String id);`
  to the interface.
- **`grc_module_repository_impl.dart`** (modify): implement it by calling
  `_firebaseDataSource.get(id)` and mapping via `.toOwnerHistory()`
  (`ValidationError` if the module isn't found, `FirebaseFailure` on
  exceptions — same pattern as `getModule`).
- **`lib/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart`**
  (new): thin pass-through to the repository, same shape as
  `GetGRCModuleUseCase`.
- **`lib/features/grc/presentation/controller/grc_previous_owners_cubit.dart`**
  + **`grc_previous_owners_state.dart`** (new): a small dedicated cubit —
  `Initial` / `Loading` / `Loaded(List<GRCModuleOwnerHistoryEntry>)` /
  `Failure(message)` — mirroring how `GrcOwnerCubit` is already its own
  small cubit rather than folding unrelated state into `GRCModuleCubit`.
- **`lib/features/grc/presentation/ui/pages/grc_previous_module_owners_page.dart`**
  (new): the page itself.
- **`grc_get_it.dart`** (modify): register the new use case and cubit.
- **`grc_page.dart`** (modify): add the `if (selected == 'previousModuleOwners')`
  branch in `_showModuleMenu`, pushing the new page with the tapped
  module's `moduleId`.

## The page

- `PaginationAppBar(screensTitles: ['GRC'.tr, 'Previous Module Owner'.tr])`
  — a static breadcrumb, not the module's own name (matches the reference
  mockup's literal title).
- On init, the cubit calls `getModuleOwnerHistory(moduleId)`.
- Table columns: `NO` (sequential row number, not a stored id) |
  `Module Owner` (avatar + localized name) | `Assigned By` (avatar +
  localized name) | `Start Date` | `End Date`. Names/avatars resolved via
  the existing `EmployeeHelper.getEmployeeLocalizedNameWithEmail` /
  `getEmployeeImageWithEmail` (the same by-email lookups already used
  elsewhere in this feature since owners are stored as emails). Dates
  formatted `d MMM yyyy` via `intl`'s `DateFormat`, matching the rest of
  the GRC feature.
- Empty state (no row has ever been removed): a centered message, same
  visual treatment as `GrcOwnerSection`'s "No owners assigned" state.
- No search/filter/pagination — the mockup doesn't show any and it isn't
  requested; a plain scrollable table is enough for a first version.

## Out of scope

- Any change to how owners are added/removed today (Task 7/8 of the prior
  plan already wired that to store emails) — this feature only reads the
  history that already exists.
- A dedicated Firestore log of owner-assignment events. Rejected as a
  second source of truth that could drift from `moduleOwners` — the
  existing revision history is sufficient and is what's already trusted
  everywhere else in this feature.
- Showing current owners on this page (see "Removed owners only" above).

## Testing

- Unit test `GRCModuleModel.toOwnerHistory()` directly (no Firebase/UI
  needed, same style as the existing `grc_module_model_test.dart`):
  - A module whose owners never changed → empty list.
  - One owner added at creation then removed later → one entry with the
    right start/end dates and assignedBy.
  - The same owner added, removed, re-added, removed again → two separate
    entries, not one.
  - A currently-active owner (added, never removed) → does not appear in
    the result.
  - Multiple entries → sorted by `endDate` descending.
- Manual check: on a module with real owner churn, open "Previous Module
  Owners" and confirm the table matches the module's actual edit history
  and that the empty state shows for a module that's never had an owner
  removed.
