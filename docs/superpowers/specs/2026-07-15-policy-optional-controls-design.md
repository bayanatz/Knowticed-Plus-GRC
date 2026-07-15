# Optional Controls in Create New Policy — Design

## Context

`CreateNewPolicyPage` (3 steps: info → controls → preview) always seeds step 1
with one empty `PolicyControlModel`. Today:

- If the user leaves that control untouched and taps Preview, nothing blocks
  them — but `PolicyControlsTableWidget` on step 2 then renders that empty
  row as a nonsense line (`-` / `-` / `0` / `-`).
- If the user fills in *some* control field (e.g. only Weight) but not the
  Name, that data is silently dropped: `_buildPendingControls` filters
  controls by `nameController.text.trim().isNotEmpty`, so a touched-but-partial
  control never reaches `PolicyCubit.createPolicy`/`saveAsDraft` at all — no
  error, no warning, just gone.
- Publish always requires total control weight == 100, even when there are
  zero controls, which makes "no controls" an unreachable state for a
  published policy even though the domain layer has no such constraint.

This is a validation/UX fix confined to the Policy-creation flow — no domain,
cubit, or storage-layer changes are needed.

## Goals

1. A policy with zero controls is a fully valid path: Preview and Publish
   both succeed without requiring any control data.
2. Once a control has *any* data in it, it must be completed (required
   fields filled) before the user can advance to Preview.
3. The Preview page never renders an empty/junk control row, and offers a
   way back to add a control if the user changes their mind.
4. Partially-filled controls are no longer silently discarded on save.

## A — "Touched" vs "complete" per control

Add two pure helper predicates on `_CreateNewPolicyPageState`, operating on
a `PolicyControlModel`:

- **Touched**: any of the following is non-empty/non-null — `nameController`,
  `nameArController`, `numberController`, `numberArController`,
  `descriptionController`, `descriptionArController`, `weightController`,
  `frequency`, `startDate`, `endDate`, `documentEn`, `documentAr`.
- **Complete**: Name, Number, Description (EN, plus AR too when
  `_isArabicEnabled`), and Weight are all non-empty. Start Date, End Date,
  and Frequency stay optional even once touched — this matches how those
  three fields are already marked `required: false` in
  `PolicyControlItemWidget`, unlike the text fields which are `required: true`.

Add `_touchedControls` (`_controls.where(touched).toList()`) and
`_hasIncompleteTouchedControl` (`_touchedControls.any((c) => !complete(c))`)
as derived getters.

## B — Preview gating (step 1 → step 2)

In `_buildStep1Buttons`'s "Preview" `customButton`, after the existing
language/date-error check, add: if `_hasIncompleteTouchedControl`, show the
existing red-snackbar pattern with the message "Please complete all required
Control fields before continuing." and return — do not advance `_step`.
When there are zero touched controls, this check is always false, so Preview
proceeds exactly as it does today.

## C — Preview page (step 2)

In `_buildStep2`, replace the unconditional `PolicyControlsTableWidget` with:

- If `_touchedControls` is empty: render an "Add Controller" button in its
  place (same `customButtonWithSvg` styling as the existing "+ Control"
  button in `add_policy_controls.dart`), which does `setState(() => _step =
  1)` to send the user back to the Controls step.
- Otherwise: render `PolicyControlsTableWidget(controls: _touchedControls,
  ...)` — scoped to touched controls only, so an abandoned empty extra row
  (added via "+ Control" and never filled in) doesn't show up as a junk
  table row alongside real ones.

## D — Publish weight check

Change `_isWeightValid` from `_totalControlWeight == 100` to
`_touchedControls.isEmpty || _totalControlWeight == 100`. This is the single
definition used by both the Publish button's pre-check and `_onPublish`, so
both sites are fixed by this one change: Publish succeeds with zero controls
regardless of the (irrelevant) 0 total, and still enforces the 100 rule the
moment any control is touched.

## E — Save For Later stays permissive; fix the silent-drop bug

Save For Later's existing validation (language/date-range errors only) is
unchanged — a touched-but-incomplete control can still be saved as a draft.

What does change: `_buildPendingControls`'s filter moves from "name
non-empty" to "touched" (reusing the section-A predicate), so a control
saved with, say, only a Weight value is included in the draft instead of
being silently dropped. This affects both `_onSaveForLater` and `_onPublish`
— for Publish this is a no-op in practice since by the time Publish is
reachable, every touched control has already passed the section-B
completeness gate.

## Out of scope

- Any change to `PolicyCubit`, use cases, repositories, or Firestore/Storage
  data sources.
- Editing an existing Policy/Control (no edit UI exists for either yet).
- An "Add Controller" affordance for the case where controls already exist on
  the Preview page (today's only path back to step 1 in that case remains
  none — unchanged, not requested).
