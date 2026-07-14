# Policy/Control Creation Form Enhancements — Design

## Context

The GRC Policy creation flow (`CreateNewPolicyPage`, 3 steps: info → controls → preview)
already has a `PolicyCubit`/domain/storage layer that fully supports bilingual
(EN/AR) fields, an image upload, split EN/AR documents, and rich Control fields
(`controlsNumberEn/Ar`, `startDate`, `endDate`, etc.). None of that capability is
wired into the UI yet:

- Policy/Control EN/AR text fields have no language-mismatch validation.
- `PolicyHeaderWidget`'s avatar is a static placeholder icon — no real image
  picking.
- Policy/Control document upload is a hardcoded stub (`'Submission 1.pdf'` /
  `'Control Doc.pdf'`) — no real file picker, no EN/AR split.
- The Control card UI has no Control Number, Start Date, or End Date fields,
  even though the domain layer already accepts them.
- **Bug**: `_onPublish`/`_onSaveForLater` in `create_new_policy.dart` never
  pass `controls:`, `imageFile:`, or the document files to
  `PolicyCubit.createPolicy`/`saveAsDraft` — so today, everything entered in
  step 1 (controls) is silently dropped on save, and no image/document is ever
  persisted despite the buttons appearing to work.

This is one cohesive fix to the Policy-creation flow, not several independent
subsystems — all pieces below live in the same handful of files and only make
sense together (new Control fields are pointless if controls are never sent to
the cubit).

## Goals

1. Language-mismatch validation on all EN/AR field pairs (Policy: Name,
   Number, Description; Control: Name, Description, and the new Number) —
   inline error message, typing is never blocked.
2. Real image picking for the Policy avatar, wired to `PolicyCubit`.
3. Real document upload, split into separate optional English/Arabic files,
   for both the Policy and each Control card.
4. New Control fields: Control Number (EN/AR) and Start Date/End Date,
   constrained to fall within the parent Policy's own date range.
5. Fix the wiring bug so controls, image, and documents actually reach
   `PolicyCubit.createPolicy`/`saveAsDraft` on Publish/Save For Later.

No domain, cubit, use-case, or storage-layer changes are needed — everything
below is UI wiring against the existing `PolicyCubit`/`ControlEntity`/
`PendingControlInput` API.

## A — Language-mismatch validation

Reuse the existing `containsEnglishLetters(String)` /
`containsArabicLetters(String)` top-level functions already defined in
`grc_form_fields.dart` (import them; do not duplicate). Do **not** use
`CustomTextField`'s `restrictByDirection` flag — that blocks typing the wrong
script outright, which is explicitly not what's wanted here. Instead, mirror
`GrcFormFields`'s existing pattern exactly:

- Convert `PolicyInfoFormWidget` and `PolicyControlItemWidget` from
  `StatelessWidget` to `StatefulWidget`, each registering a listener on every
  relevant `TextEditingController` that calls `setState(() {})`, so the error
  text re-evaluates live as the user types (same as
  `_GrcFormFieldsState._onTextChanged`).
- For each EN field, pass `errorText:` computed as: required-but-empty check
  first (existing behavior), else `containsArabicLetters(controller.text) ?
  '<Field> must be written in English' : null`.
- For each AR field, the mirror: `containsEnglishLetters(controller.text) ?
  'يجب كتابة <الحقل> باللغة العربية' : null`.
- Applies to: Policy Name/Number/Description (EN+AR), Control
  Name/Description/**Number** (EN+AR — Number is new, see section D).
- Does **not** apply to Policy Weight / Control Weight (numeric, not a
  language field).

## B — Policy image wiring

Replace the static `CircleAvatar` + `Icons.image_outlined` placeholder inside
`PolicyHeaderWidget` with `CustomImagePicker`
(`lib/core/custom/46_custom_image_picker.dart`) — the same widget already used
for the GRC Module's image in `grc_details_page.dart`. `PolicyHeaderWidget`
keeps its existing `onImageTap` param removed (no longer needed —
`CustomImagePicker` owns its own tap-to-pick gesture) and gains
`imageFile`/`onImagePicked` passthrough params instead.

`CreateNewPolicyPage` gains `File? _imageFile` state, set via
`onImagePicked`, and passes it as `imageFile:` into both
`cubit.createPolicy(...)` and `cubit.saveAsDraft(...)`.

## C — Document upload (EN/AR split)

`PolicyDocumentInfo` gains a new required `File file` field alongside its
existing `name`/`sizeLabel`/`dateLabel` display fields, so one object carries
both the picked file and its display metadata (no separate `File` variable to
keep in sync).

Replace the hardcoded `_onUploadDocument` stubs (in `create_new_policy.dart`
for the Policy document, and `add_policy_controls.dart` for each Control's
document) with real calls to `showUploadDialog` from
`lib/core/custom/10_custom_upload_document.dart` — this is the canonical
implementation (file_picker-backed, Figma-matched); `11_custom_confirm_diaolog.dart`
has a near-duplicate that other call sites already `hide` on import, so this
work follows that same convention.

UI behavior (both Policy step-0 and each Control card in step 1):

- By default (Arabic version off) show a single **"Upload Document
  (English)"** button.
- When "Create Arabic Version" is toggled on, a second **"Upload Document
  (Arabic)"** button appears alongside it (`textDirection: TextDirection.rtl`,
  Arabic dialog copy).
- Each button is independent — English and Arabic documents are optional and
  tracked separately (`documentEn`/`documentAr`), each with its own preview
  chip + remove button via the existing `PolicyDocumentPreviewWidget`.

State changes:
- `CreateNewPolicyPage`: `PolicyDocumentInfo? _document` →
  `_documentEn`/`_documentAr`, feeding `policyDocumentFileEn`/`policyDocumentFileAr`
  into `createPolicy`/`saveAsDraft`.
- `PolicyControlModel`: `PolicyDocumentInfo? document` →
  `documentEn`/`documentAr`, feeding `controlsDocumentFileEn`/`controlsDocumentFileAr`
  on the `PendingControlInput` built for that control (see section E).

## D — Control: Control Number + Start/End Date

`PolicyControlModel` gains:
- `TextEditingController numberController` / `numberArController` — same
  pattern as Policy Number (label "Control Number" / "رقم ضابط").
- `DateTime? startDate` / `DateTime? endDate` — plain mutable fields (not
  controllers), same as `frequency`.

`PolicyControlItemWidget` renders:
- The Control Number field pair (EN always visible; AR appears when
  `isArabicEnabled`, same placement pattern as Control Name), with the
  language validation from section A.
- Start Date / End Date pickers (`CustomDropdownCalendar`, same widget/layout
  as Policy's), positioned near Frequency/Weight. Validation:
  - `End Date >= Start Date`.
  - **Both must fall within the parent Policy's own `startDate`/`endDate`**
    (per user decision — controls are scoped inside their policy's active
    window). `firstDate`/`lastDate` on the calendar pickers are bounded by the
    policy's dates; `errorText` shown if a previously-picked value now falls
    outside range (e.g., user changed the policy's dates after picking
    control dates).

To support the range check, the policy's `startDate`/`endDate` must flow down:
`CreateNewPolicyPage` → `AddPolicyControlsPage` (new
`policyStartDate`/`policyEndDate` params) → `PolicyControlItemWidget` (same).

## E — Persistence wiring fix

`CreateNewPolicyPage._onPublish`/`_onSaveForLater` currently call
`cubit.createPolicy`/`saveAsDraft` with only the Policy's own fields — `controls`,
`imageFile`, and the document files are never passed, so today's UI silently
drops all of that on save. Fix:

- Build `List<PendingControlInput>` from `_controls`, one entry per
  `PolicyControlModel`, mapping: `nameController`/`nameArController` →
  `controlsNameEn/Ar`, `numberController`/`numberArController` →
  `controlsNumberEn/Ar`, `descriptionController`/`descriptionArController` →
  `controlsDescriptionEn/Ar`, `weightController` → `controlsWeight`,
  `frequency` → `frequency`, `startDate`/`endDate` → `startDate`/`endDate`,
  `documentEn?.file`/`documentAr?.file` → `controlsDocumentFileEn/Ar`.
  `departments`/`equalWeights`/`score` are out of scope for this change — pass
  `[]`, `false`, `0` since the UI doesn't collect them yet. `status` mirrors
  the Policy's own status for this save action: `ControlStatus.draft` when
  called from `saveAsDraft`, `ControlStatus.active` when called from
  `createPolicy` (Publish) — consistent with how the Policy's own `status` is
  already chosen by `_createPolicyWithControls`.
- Pass that list as `controls:` to both `cubit.createPolicy(...)` and
  `cubit.saveAsDraft(...)`.
- Pass `imageFile: _imageFile` and `policyDocumentFileEn: _documentEn?.file`,
  `policyDocumentFileAr: _documentAr?.file` to both calls as well.

## Out of scope

- Editing an existing Policy/Control (no edit UI currently exists for either;
  this change only touches the create flow).
- Control fields `departments`, `equalWeights`, `score`, `status` — not
  requested, domain already supports them for a future change.
- Any change to `PolicyCubit`, use cases, repositories, or Firestore/Storage
  data sources — all required capability already exists there.
