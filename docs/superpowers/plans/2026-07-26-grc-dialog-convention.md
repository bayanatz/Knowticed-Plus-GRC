# GRC Dialog Convention Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove every SnackBar from `lib/features/grc/`, make every data-affecting button (Submit/Create/Update/Delete/Approve/Reject/Cancel/Remove-type actions only) show a confirmation dialog before it runs and a success dialog after it succeeds, and add a matching error dialog for backend/Cubit failures — using the dialog helpers that already exist and are already partially adopted in GRC.

**Architecture:** No new dialog *system* is introduced. `showConfirmDialog` and `showSuccessDialog` already exist as top-level functions in `lib/core/custom/11_custom_confirm_diaolog.dart` and are already used by several GRC pages. This plan (a) adds one sibling function, `showErrorDialog`, to that same file, and (b) brings every GRC page up to full, consistent use of all three. Local form-validation errors (empty field, invalid range) become inline text next to the field — never a dialog or SnackBar; only real backend/Cubit failures get `showErrorDialog`.

**Tech Stack:** Flutter, GetX, flutter_bloc (Cubit), `flutter_screenutil`, GetX `.tr`.

## Global Constraints

- Scope is exactly `lib/features/grc/` — no other feature is touched by this plan (confirmed via research: no other feature currently uses `showConfirmDialog`/`showSuccessDialog`, and they have their own different patterns that are out of scope here).
- "Data-affecting button" = a button whose handler calls a Cubit/use-case method that persists something (create/update/delete a Firestore document, approve/reject/cancel a request). Buttons that only mutate in-memory/not-yet-persisted state (Add Row, Duplicate Row, Equal-Weight redistribution, Discard local edits, Back, tab/step navigation) are explicitly OUT of scope for the confirm-dialog requirement — confirmed with the user via AskUserQuestion.
- Local form-validation (required field, invalid range, "select a row first") → inline text next to the relevant field/control. Never a dialog, never a SnackBar. Where there's no single field to attach text to (e.g. "select at least one row" for a bulk-upload toolbar action), render a small `Text` under/near the button row instead — never a SnackBar.
- Real Cubit/backend failure states (`XFailure`, caught exceptions from an actual async call) → `showErrorDialog` (new function this plan adds, Task 1).
- Every action that already calls `showConfirmDialog`/`showSuccessDialog` correctly is left as-is — this plan closes gaps, it does not redesign working code.
- No test suite exists for `lib/features/grc/`. Verification is `flutter analyze` (via Puro: `/Users/bstar/.puro/bin/puro flutter analyze <path>` — plain `flutter` is not on PATH on this machine) with a "no new issues vs. the pre-existing per-scope baseline" bar, plus a manual smoke-check description per task (execute if a device/emulator is available in your environment; if not, say so explicitly rather than claiming it was done).
- Every new function gets a `///` doc comment explaining why it exists, not what it does line by line. Do not reformat or touch code outside the exact lines each task calls out.
- `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_weight_dialog.dart` is explicitly OUT OF SCOPE — it's a Yes/No *question* dialog whose boolean answer drives subsequent logic (`Future<bool>`, awaited by the caller), not a fire-and-forget action confirmation (`Future<void>` + `onConfirm`). Forcing it into `showConfirmDialog`'s shape would be a worse fit, not a cleanup. Leave it exactly as-is.

## File Structure

```
lib/core/custom/11_custom_confirm_diaolog.dart   # Task 1 adds showErrorDialog here

lib/features/grc/control_champion/presentation/ui/pages/
  add_champion_page.dart                          # Task 2
  reassign_champion_page.dart                      # Task 3
  edit_champion_controls_page.dart                 # Task 4
  control_champion_details_page.dart               # Task 5

lib/features/grc/control_owner/presentation/ui/pages/
  add_owner_page.dart                              # Task 6
  reassign_owner_page.dart                          # Task 7
  edit_owner_controls_page.dart                     # Task 8
  control_owner_details_page.dart                   # Task 9

lib/features/grc/control/presentation/ui/pages/
  control_details_page.dart                         # Task 10 (with policy_details_page.dart)
  add_edit_control_page.dart                        # Task 11 (with policy_edit_page.dart)
  assignee_bulk_upload/assignee_bulk_upload_preview_page.dart   # Task 12
  control_bulk_upload/control_bulk_upload_preview_page.dart     # Task 13
  control_weight_issue/control_weight_issue_page.dart            # Task 14 (with policy_weight_issue_page.dart)

lib/features/grc/policy/presentation/ui/pages/
  policy_details_page.dart                          # Task 10
  policy_edit_page.dart                             # Task 11
  create_new_policy.dart                            # Task 15
  policy_bulk_upload/policy_bulk_upload_preview_page.dart        # Task 16
  policy_weight_issue/policy_weight_issue_page.dart               # Task 14

lib/features/grc/module/presentation/ui/pages/
  grc_details_page.dart                              # Task 17

lib/features/grc/grc_request/presentation/ui/pages/
  grc_request_details_page.dart                       # Task 18
```

---

### Task 1: Add `showErrorDialog`

**Files:**
- Modify: `lib/core/custom/11_custom_confirm_diaolog.dart`

**Interfaces:**
- Produces: `Future<void> showErrorDialog({required BuildContext context, String title, String subtitle, String closeLabel, VoidCallback? onClose, String? lottieAsset, bool repeat})`, used by every later task.

- [ ] **Step 1: Check for an existing error-themed Lottie asset**

Run: `find assets/lottie_assets -iname "*error*" -o -iname "*reject*" -o -iname "*fail*"` (from repo root). The existing `showSuccessDialog` defaults to `assets/lottie_assets/main_lottie_assets/lottie_approved.json`. If this search finds a sibling error/reject/fail animation in the same `main_lottie_assets` folder, use its path as `showErrorDialog`'s default `lottieAsset`. If nothing is found, do not guess a path — use a plain `Icon` fallback instead (Step 2 already handles this).

- [ ] **Step 2: Add `showErrorDialog` next to `showSuccessDialog`**

In `lib/core/custom/11_custom_confirm_diaolog.dart`, add this immediately after the `showSuccessDialog` function and its `_SuccessDialog` class (the function/class pair currently ends around line 363 — verify by finding the end of `_SuccessDialog.build`'s closing braces):

```dart
/// Error feedback for a failed backend/Cubit action, matching
/// showSuccessDialog's visual family. Added because GRC previously showed
/// every failure via a SnackBar; this closes that gap without inventing a
/// new dialog shape.
Future<void> showErrorDialog({
  required BuildContext context,
  String title = 'Error',
  String subtitle = 'Something went wrong. Please try again.',
  String closeLabel = 'Close',
  VoidCallback? onClose,
  String? lottieAsset,
  bool repeat = false,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (_) => _ErrorDialog(
      title: title,
      subtitle: subtitle,
      closeLabel: closeLabel,
      onClose: onClose,
      lottieAsset: lottieAsset,
      repeat: repeat,
    ),
  );
}

class _ErrorDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String closeLabel;
  final VoidCallback? onClose;
  final String? lottieAsset;
  final bool repeat;

  const _ErrorDialog({
    required this.title,
    required this.subtitle,
    required this.closeLabel,
    this.onClose,
    this.lottieAsset,
    this.repeat = false,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 410.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h),
          _buildIcon(),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style:
                StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (lottieAsset != null) {
      return Lottie.asset(lottieAsset!, width: 90.r, height: 90.r, repeat: repeat);
    }
    // No dedicated error/failure Lottie animation exists in this codebase
    // (only lottie_approved.json for success) — a plain icon in the same
    // 90.r slot is more honest than pointing at an asset that may not exist.
    return Icon(Icons.error_outline, color: AppColors.red, size: 64.r);
  }
}
```

If Step 1 found a real error-themed Lottie asset, change the `_buildIcon()` body to default to it (mirroring `_SuccessDialog._buildIcon()`'s exact shape: `return Lottie.asset(lottieAsset ?? '<found-path>', width: 90.r, height: 90.r, repeat: repeat);`) instead of the `Icon` fallback above.

- [ ] **Step 3: Verify**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/core/custom/11_custom_confirm_diaolog.dart`
Expected: no new issues vs. this file's pre-existing baseline (record the baseline count first if starting fresh).

- [ ] **Step 4: Commit**

```bash
git add lib/core/custom/11_custom_confirm_diaolog.dart
git commit -m "feat(grc): add showErrorDialog matching showSuccessDialog's visual family"
```

---

### Task 2: `add_champion_page.dart`

**Files:**
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/add_champion_page.dart`

**Interfaces:**
- Consumes: `showConfirmDialog`, `showSuccessDialog`, `showErrorDialog` (Task 1).

- [ ] **Step 1: Add the import**

Add `import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';` to the imports (this file currently has none of these three dialog helpers wired in).

- [ ] **Step 2: Wrap `_submit`'s Cubit call in a confirm dialog**

Current `_submit` (lines 127-147):
```dart
void _submit(BuildContext context) {
  setState(() => _submitted = true);
  if (_selectedEmployees.length != 1 || !_rowsValid) return;

  // Fire-and-forget: touches each affected Control document directly, not
  // the Champion doc this page's own submit/loading state tracks.
  _recomputeControlStatuses();
  context.read<ChampionCubit>().createChampion(
        moduleId: widget.moduleId,
        championEmail: _selectedEmployees.first.email,
        assigningControls: _rows
            .expand((r) => r.controlIds.map((controlId) =>
                AssigningControlEntity(
                  policyId: r.policyId!,
                  controlId: controlId,
                )))
            .toList(),
      );
}
```
Replace with:
```dart
void _submit(BuildContext context) {
  setState(() => _submitted = true);
  if (_selectedEmployees.length != 1 || !_rowsValid) return;

  showConfirmDialog(
    context: context,
    title: 'Add Control Champion'.tr,
    subtitle: 'Are you sure you want to add this Control Champion?'.tr,
    confirmLabel: 'Add'.tr,
    cancelLabel: 'Cancel'.tr,
    onConfirm: () {
      // Fire-and-forget: touches each affected Control document directly,
      // not the Champion doc this page's own submit/loading state tracks.
      _recomputeControlStatuses();
      context.read<ChampionCubit>().createChampion(
            moduleId: widget.moduleId,
            championEmail: _selectedEmployees.first.email,
            assigningControls: _rows
                .expand((r) => r.controlIds.map((controlId) =>
                    AssigningControlEntity(
                      policyId: r.policyId!,
                      controlId: controlId,
                    )))
                .toList(),
          );
    },
  );
}
```

- [ ] **Step 3: Add a success dialog and convert the failure SnackBar**

Find the `BlocConsumer` listener that currently pops silently on success (around lines 194-200):
```dart
listener: (context, state) {
  if (state is ChampionActionSuccess) {
    Navigator.pop(context, true);
  } else if (state is ChampionFailure) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message)));
  }
},
```
Replace with:
```dart
listener: (context, state) {
  if (state is ChampionActionSuccess) {
    showSuccessDialog(
      context: context,
      title: 'Control Champion Added'.tr,
      subtitle: 'You successfully added this Control Champion.'.tr,
    );
    Navigator.pop(context, true);
  } else if (state is ChampionFailure) {
    showErrorDialog(context: context, subtitle: state.message);
  }
},
```

- [ ] **Step 4: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control_champion/`
Expected: no new issues vs. this feature's pre-existing baseline.

Manual check (if you have device/emulator access — otherwise state explicitly that this could not be verified): open Add Champion, pick an employee and controls, tap Submit — confirm the "Add Control Champion" confirm dialog appears, tapping Add proceeds, and a success dialog shows before the page closes. Trigger a Cubit failure (if reachable) and confirm the error dialog shows the failure message instead of a SnackBar.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control_champion/presentation/ui/pages/add_champion_page.dart
git commit -m "feat(grc): add confirm/success/error dialogs to Add Champion submit"
```

---

### Task 3: `reassign_champion_page.dart`

**Files:**
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/reassign_champion_page.dart`

**Interfaces:**
- Consumes: `showConfirmDialog`, `showErrorDialog` (Task 1). `showSuccessDialog` is already imported/used here — no change needed to that part.

- [ ] **Step 1: Wrap the actual submission in a confirm dialog**

Current `_submit` (full body, lines 93-171) validates inline, then goes straight into the `try`/`await requestCubit.createRequest(...)` block. Insert a confirm dialog between the validation block and the `try`:

Find:
```dart
  if (championError != null ||
      controlsError != null ||
      startDateError != null) {
    return;
  }

  setState(() => _submitting = true);

  try {
    final requestCubit = context.read<GrcRequestCubit>();
    await requestCubit.createRequest(
```
Replace with:
```dart
  if (championError != null ||
      controlsError != null ||
      startDateError != null) {
    return;
  }

  final confirmed = await _confirmReassign(context);
  if (!confirmed) return;

  setState(() => _submitting = true);

  try {
    final requestCubit = context.read<GrcRequestCubit>();
    await requestCubit.createRequest(
```

Add this helper method near `_submit`:
```dart
Future<bool> _confirmReassign(BuildContext context) async {
  final completer = Completer<bool>();
  await showConfirmDialog(
    context: context,
    title: 'Reassign Champion'.tr,
    subtitle: 'Are you sure you want to submit this reassignment request?'.tr,
    confirmLabel: 'Submit'.tr,
    cancelLabel: 'Cancel'.tr,
    onConfirm: () => completer.complete(true),
    onCancel: () => completer.complete(false),
  );
  return completer.future;
}
```
Add `import 'dart:async';` to the imports if not already present (needed for `Completer`).

- [ ] **Step 2: Convert the two error SnackBars to `showErrorDialog`**

Find (lines 157-160):
```dart
    } else if (state is GrcRequestFailure) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: ${state.message}')),
      );
    }
```
Replace with:
```dart
    } else if (state is GrcRequestFailure) {
      if (!context.mounted) return;
      showErrorDialog(
        context: context,
        subtitle: 'Failed to submit request: ${state.message}',
      );
    }
```

Find (lines 163-165):
```dart
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
```
Replace with:
```dart
  } catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context: context, subtitle: 'An error occurred: $e');
```

Add the import: `import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';` if it isn't already present (check first — Task 1's research found this file already imports it for `showSuccessDialog`).

- [ ] **Step 3: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control_champion/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): fill in a valid reassignment, tap Submit — confirm the new "Reassign Champion" confirm dialog appears before the request is created, and that Cancel aborts without submitting. Force a failure path if reachable and confirm the error dialog shows instead of a SnackBar.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control_champion/presentation/ui/pages/reassign_champion_page.dart
git commit -m "feat(grc): add confirm dialog to reassign-champion submit, error dialog for failures"
```

---

### Task 4: `edit_champion_controls_page.dart`

**Files:**
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/edit_champion_controls_page.dart`

**Interfaces:**
- Consumes: `showSuccessDialog`, `showErrorDialog` (Task 1). `showConfirmDialog` is already used here (`_confirmAndSave`) — no change needed to that part.

- [ ] **Step 1: Convert the success/failure SnackBars**

Find (lines 182-190):
```dart
if (state is ChampionActionSuccess) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Controls updated successfully'.tr)),
  );
  Navigator.pop(context, state.champion);
} else if (state is ChampionFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
}
```
Replace with:
```dart
if (state is ChampionActionSuccess) {
  showSuccessDialog(
    context: context,
    title: 'Controls Updated'.tr,
    subtitle: 'Controls updated successfully'.tr,
  );
  Navigator.pop(context, state.champion);
} else if (state is ChampionFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```

- [ ] **Step 2: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control_champion/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): save an edit — confirm a success dialog shows instead of a SnackBar.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/control_champion/presentation/ui/pages/edit_champion_controls_page.dart
git commit -m "feat(grc): use showSuccessDialog/showErrorDialog for edit-champion-controls outcomes"
```

---

### Task 5: `control_champion_details_page.dart`

**Files:**
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/control_champion_details_page.dart`

**Interfaces:**
- Consumes: `showSuccessDialog`, `showErrorDialog` (Task 1). `showConfirmDialog` is already used here (`_showDeleteConfirmation`) — no change needed.

- [ ] **Step 1: Convert the success/failure SnackBars**

Find (lines 163-177):
```dart
if (state is ChampionActionSuccess) {
  if (state.champion.status == ChampionStatus.removed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Control Champion removed successfully'.tr)),
    );
    Navigator.pop(context, true);
  } else {
    setState(() {
      _currentChampion = state.champion;
    });
  }
} else if (state is ChampionFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
}
```
Replace with:
```dart
if (state is ChampionActionSuccess) {
  if (state.champion.status == ChampionStatus.removed) {
    showSuccessDialog(
      context: context,
      title: 'Control Champion Removed'.tr,
      subtitle: 'Control Champion removed successfully'.tr,
    );
    Navigator.pop(context, true);
  } else {
    setState(() {
      _currentChampion = state.champion;
    });
  }
} else if (state is ChampionFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```

- [ ] **Step 2: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control_champion/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): remove a Control Champion — confirm a success dialog shows before the page closes.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/control_champion/presentation/ui/pages/control_champion_details_page.dart
git commit -m "feat(grc): use showSuccessDialog/showErrorDialog for champion-removal outcomes"
```

---

### Task 6: `add_owner_page.dart`

**Files:**
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/add_owner_page.dart`

**Interfaces:**
- Consumes: `showConfirmDialog`, `showSuccessDialog`, `showErrorDialog` (Task 1).

Identical shape to Task 2 (`add_champion_page.dart`), Owner naming.

- [ ] **Step 1: Add the import**

Add `import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';`.

- [ ] **Step 2: Wrap `_submit`'s Cubit call in a confirm dialog**

Current `_submit` (lines 129-149):
```dart
void _submit(BuildContext context) {
  setState(() => _submitted = true);
  if (_selectedEmployees.length != 1 || !_rowsValid) return;

  // Fire-and-forget: touches each affected Control document directly, not
  // the Owner doc this page's own submit/loading state tracks.
  _recomputeControlStatuses();
  context.read<OwnerCubit>().createOwner(
        moduleId: widget.moduleId,
        ownerEmail: _selectedEmployees.first.email,
        assigningControls: _rows
            .expand((r) => r.controlIds.map((controlId) =>
                AssigningControlEntity(
                  policyId: r.policyId!,
                  controlId: controlId,
                )))
            .toList(),
      );
}
```
Replace with:
```dart
void _submit(BuildContext context) {
  setState(() => _submitted = true);
  if (_selectedEmployees.length != 1 || !_rowsValid) return;

  showConfirmDialog(
    context: context,
    title: 'Add Control Owner'.tr,
    subtitle: 'Are you sure you want to add this Control Owner?'.tr,
    confirmLabel: 'Add'.tr,
    cancelLabel: 'Cancel'.tr,
    onConfirm: () {
      // Fire-and-forget: touches each affected Control document directly,
      // not the Owner doc this page's own submit/loading state tracks.
      _recomputeControlStatuses();
      context.read<OwnerCubit>().createOwner(
            moduleId: widget.moduleId,
            ownerEmail: _selectedEmployees.first.email,
            assigningControls: _rows
                .expand((r) => r.controlIds.map((controlId) =>
                    AssigningControlEntity(
                      policyId: r.policyId!,
                      controlId: controlId,
                    )))
                .toList(),
          );
    },
  );
}
```

- [ ] **Step 3: Add a success dialog and convert the failure SnackBar**

Find (lines 196-202):
```dart
listener: (context, state) {
  if (state is OwnerActionSuccess) {
    Navigator.pop(context, true);
  } else if (state is OwnerFailure) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message)));
  }
},
```
Replace with:
```dart
listener: (context, state) {
  if (state is OwnerActionSuccess) {
    showSuccessDialog(
      context: context,
      title: 'Control Owner Added'.tr,
      subtitle: 'You successfully added this Control Owner.'.tr,
    );
    Navigator.pop(context, true);
  } else if (state is OwnerFailure) {
    showErrorDialog(context: context, subtitle: state.message);
  }
},
```

- [ ] **Step 4: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control_owner/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): same as Task 2's, Owner side.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control_owner/presentation/ui/pages/add_owner_page.dart
git commit -m "feat(grc): add confirm/success/error dialogs to Add Owner submit"
```

---

### Task 7: `reassign_owner_page.dart`

**Files:**
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/reassign_owner_page.dart`

**Interfaces:**
- Consumes: `showConfirmDialog`, `showSuccessDialog`, `showErrorDialog` (Task 1).

This file is the least-converted of the pair — unlike `reassign_champion_page.dart`, it has zero dialog-helper usage today and does all four local validations via SnackBar instead of inline text. Bring it fully in line with its sibling.

- [ ] **Step 1: Add the import**

Add `import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';` and `import 'dart:async';` (for `Completer`, used in Step 3).

- [ ] **Step 2: Add three nullable error fields, matching `reassign_champion_page.dart`'s pattern**

Near the top of `_ReassignOwnerPageState`, alongside the existing state fields, add:
```dart
  String? _ownerError;
  String? _controlsError;
  String? _startDateError;
```

- [ ] **Step 3: Replace the four validation SnackBars with inline-error assignment, and add the confirm dialog**

Current `_submit` (full body, lines 89-166):
```dart
Future<void> _submit(BuildContext context) async {
  setState(() {
    commitPendingAssignmentRows(
        pendingRows: _pendingRows, target: _reassignedControls);
    _pendingRows
      ..clear()
      ..add(PendingAssignmentRow());
  });

  if (_newSelectedEmployees.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a new Control Owner'.tr)),
    );
    return;
  }
  if (_reassignedControls.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please assign at least one Control'.tr)),
    );
    return;
  }
  if (_startDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please choose a start date'.tr)),
    );
    return;
  }

  final newOwnerEmail = _newSelectedEmployees.first.email;
  if (newOwnerEmail == widget.owner.ownerEmail) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('New owner cannot be the current owner'.tr)),
    );
    return;
  }

  setState(() => _submitting = true);

  try {
    final requestCubit = context.read<GrcRequestCubit>();
    await requestCubit.createRequest(
      CreateGrcRequestParams(
        type: GrcRequestType.reassignOwner,
        moduleId: widget.module.moduleId,
        requestedBy: currentGrcUserEmail(),
        note: _noteController.text,
        currentOwnerEmail: widget.owner.ownerEmail,
        newOwnerEmail: newOwnerEmail,
        controls: _reassignedControls,
        startDate: _startDate!,
        endDate: _endDate,
      ),
    );

    final state = requestCubit.state;
    if (state is GrcRequestActionSuccess) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request submitted'.tr)),
      );
      Navigator.pop(context, true);
    } else if (state is GrcRequestFailure) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: ${state.message}')),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => _submitting = false);
    }
  }
}
```
Replace in full with:
```dart
Future<void> _submit(BuildContext context) async {
  setState(() {
    commitPendingAssignmentRows(
        pendingRows: _pendingRows, target: _reassignedControls);
    _pendingRows
      ..clear()
      ..add(PendingAssignmentRow());
  });

  final newOwnerEmail = _newSelectedEmployees.isNotEmpty
      ? _newSelectedEmployees.first.email
      : null;

  final ownerError = _newSelectedEmployees.isEmpty
      ? 'Please select a new Control Owner'.tr
      : newOwnerEmail == widget.owner.ownerEmail
          ? 'New owner cannot be the current owner'.tr
          : null;
  final controlsError = _reassignedControls.isEmpty
      ? 'Please assign at least one Control'.tr
      : null;
  final startDateError =
      _startDate == null ? 'Please choose a start date'.tr : null;

  setState(() {
    _ownerError = ownerError;
    _controlsError = controlsError;
    _startDateError = startDateError;
  });

  if (ownerError != null || controlsError != null || startDateError != null) {
    return;
  }

  final confirmed = await _confirmReassign(context);
  if (!confirmed) return;

  setState(() => _submitting = true);

  try {
    final requestCubit = context.read<GrcRequestCubit>();
    await requestCubit.createRequest(
      CreateGrcRequestParams(
        type: GrcRequestType.reassignOwner,
        moduleId: widget.module.moduleId,
        requestedBy: currentGrcUserEmail(),
        note: _noteController.text,
        currentOwnerEmail: widget.owner.ownerEmail,
        newOwnerEmail: newOwnerEmail!,
        controls: _reassignedControls,
        startDate: _startDate!,
        endDate: _endDate,
      ),
    );

    final state = requestCubit.state;
    if (state is GrcRequestActionSuccess) {
      if (!context.mounted) return;
      showSuccessDialog(
        context: context,
        title: 'Request Submitted'.tr,
        subtitle: 'Your reassign owner request has been submitted.'.tr,
      );
      Navigator.pop(context, true);
    } else if (state is GrcRequestFailure) {
      if (!context.mounted) return;
      showErrorDialog(
        context: context,
        subtitle: 'Failed to submit request: ${state.message}',
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context: context, subtitle: 'An error occurred: $e');
  } finally {
    if (mounted) {
      setState(() => _submitting = false);
    }
  }
}

Future<bool> _confirmReassign(BuildContext context) async {
  final completer = Completer<bool>();
  await showConfirmDialog(
    context: context,
    title: 'Reassign Owner'.tr,
    subtitle: 'Are you sure you want to submit this reassignment request?'.tr,
    confirmLabel: 'Submit'.tr,
    cancelLabel: 'Cancel'.tr,
    onConfirm: () => completer.complete(true),
    onCancel: () => completer.complete(false),
  );
  return completer.future;
}
```

- [ ] **Step 4: Wire the three new error fields into the UI, matching `reassign_champion_page.dart`'s exact call sites**

Find the owner picker (`GrcOwnerSection` or equivalent single-select widget for the new owner) and add `errorText: _ownerError`, clearing it in `onOwnersChanged`:
```dart
child: GrcOwnerSection(
  singleSelect: true,
  errorText: _ownerError,
  onOwnersChanged: (selected) => setState(() {
    _newSelectedEmployees = selected;
    _ownerError = null;
  }),
),
```
Find the start-date `CustomDropdownCalendar` and add `errorText: _startDateError`, clearing it in `onChanged`:
```dart
child: CustomDropdownCalendar(
  label: 'Start Date'.tr,
  hint: 'Choose The Date'.tr,
  value: _startDate,
  errorText: _startDateError,
  onChanged: (d) => setState(() {
    _startDate = d;
    _startDateError = null;
  }),
  ...
),
```
Find where the assigned-controls chips render and add a manual error `Text` below them, matching `reassign_champion_page.dart:360-367`:
```dart
if (_controlsError != null) ...[
  SizedBox(height: 6.h),
  Text(
    _controlsError!,
    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
  ),
],
```
(Read the actual current widget tree around the owner picker/date picker/controls-chips section first — the exact surrounding code wasn't captured in research beyond the button/snackbar handlers, so match into the real structure rather than assuming line numbers.)

- [ ] **Step 5: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control_owner/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): try submitting with each field empty in turn — confirm inline errors appear next to the right field/section, not a SnackBar. Fill everything in and submit — confirm the "Reassign Owner" dialog appears, and a success dialog shows after.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/control_owner/presentation/ui/pages/reassign_owner_page.dart
git commit -m "feat(grc): bring reassign-owner submit up to the confirm/inline-error/success/error convention"
```

---

### Task 8: `edit_owner_controls_page.dart`

**Files:**
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/edit_owner_controls_page.dart`

**Interfaces:**
- Consumes: `showSuccessDialog`, `showErrorDialog` (Task 1). `showConfirmDialog` already used (`_confirmAndSave`).

- [ ] **Step 1: Convert the success/failure SnackBars**

Find (lines 181-188):
```dart
if (state is OwnerActionSuccess) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Controls updated successfully'.tr)),
  );
  Navigator.pop(context, state.owner);
} else if (state is OwnerFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
}
```
Replace with:
```dart
if (state is OwnerActionSuccess) {
  showSuccessDialog(
    context: context,
    title: 'Controls Updated'.tr,
    subtitle: 'Controls updated successfully'.tr,
  );
  Navigator.pop(context, state.owner);
} else if (state is OwnerFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```

- [ ] **Step 2: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control_owner/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): save an edit — confirm a success dialog shows instead of a SnackBar.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/control_owner/presentation/ui/pages/edit_owner_controls_page.dart
git commit -m "feat(grc): use showSuccessDialog/showErrorDialog for edit-owner-controls outcomes"
```

---

### Task 9: `control_owner_details_page.dart`

**Files:**
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/control_owner_details_page.dart`

**Interfaces:**
- Consumes: `showSuccessDialog`, `showErrorDialog` (Task 1). `showConfirmDialog` already used (`_showDeleteConfirmation`).

- [ ] **Step 1: Convert the success/failure SnackBars**

Find (lines 161-173):
```dart
if (state is OwnerActionSuccess) {
  if (state.owner.status == OwnerStatus.removed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Control Owner removed successfully'.tr)),
    );
    Navigator.pop(context, true);
  } else {
    setState(() {
      _currentOwner = state.owner;
    });
  }
} else if (state is OwnerFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
}
```
Replace with:
```dart
if (state is OwnerActionSuccess) {
  if (state.owner.status == OwnerStatus.removed) {
    showSuccessDialog(
      context: context,
      title: 'Control Owner Removed'.tr,
      subtitle: 'Control Owner removed successfully'.tr,
    );
    Navigator.pop(context, true);
  } else {
    setState(() {
      _currentOwner = state.owner;
    });
  }
} else if (state is OwnerFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```

- [ ] **Step 2: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control_owner/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): remove a Control Owner — confirm a success dialog shows before the page closes.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/control_owner/presentation/ui/pages/control_owner_details_page.dart
git commit -m "feat(grc): use showSuccessDialog/showErrorDialog for owner-removal outcomes"
```

---

### Task 10: `control_details_page.dart` + `policy_details_page.dart`

Both files are already fully converted (Delete goes through `GrcActionButtons`'s built-in `showConfirmDialog`, success already uses `showSuccessDialog`) — the only gap in each is a single `PolicyFailure` SnackBar.

**Files:**
- Modify: `lib/features/grc/control/presentation/ui/pages/control_details_page.dart`
- Modify: `lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart`

**Interfaces:**
- Consumes: `showErrorDialog` (Task 1).

- [ ] **Step 1: Convert the SnackBar in `control_details_page.dart`**

Find (lines 178-182):
```dart
if (state is PolicyFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
  );
}
```
Replace with:
```dart
if (state is PolicyFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```
Add the import `package:demo_app/core/custom/11_custom_confirm_diaolog.dart` if this file's existing import is scoped with `show showSuccessDialog` — widen it to also bring in `showErrorDialog` (e.g. `show showSuccessDialog, showErrorDialog;`), rather than adding a second import line for the same file.

- [ ] **Step 2: Convert the SnackBar in `policy_details_page.dart`**

Find (lines 166-170):
```dart
if (state is PolicyFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
  );
}
```
Replace with:
```dart
if (state is PolicyFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```
Same import-widening note as Step 1 (`show showSuccessDialog` → `show showSuccessDialog, showErrorDialog`).

- [ ] **Step 3: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control/ lib/features/grc/policy/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): trigger a Cubit failure on each page if reachable, confirm an error dialog appears instead of a SnackBar.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_details_page.dart lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart
git commit -m "feat(grc): use showErrorDialog for control/policy details-page failures"
```

---

### Task 11: `add_edit_control_page.dart` + `policy_edit_page.dart`

Both files already have confirm dialogs on every Save action and `showSuccessDialog` on success — only the failure SnackBars remain.

**Files:**
- Modify: `lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart`
- Modify: `lib/features/grc/policy/presentation/ui/pages/policy_edit_page.dart`

**Interfaces:**
- Consumes: `showErrorDialog` (Task 1).

- [ ] **Step 1: Convert both SnackBars in `add_edit_control_page.dart`**

Find (lines 639-643):
```dart
if (state is PolicyFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
  );
}
```
Replace with:
```dart
if (state is PolicyFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```

Find (lines 1064-1072):
```dart
if (hadFailure && context.mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content:
          Text("Some champion/owner assignments couldn't be saved.".tr),
      backgroundColor: AppColors.red,
    ),
  );
}
```
Replace with:
```dart
if (hadFailure && context.mounted) {
  showErrorDialog(
    context: context,
    subtitle: "Some champion/owner assignments couldn't be saved.".tr,
  );
}
```
This file's import is `hide showUploadDialog` (i.e. imports everything else including the new `showErrorDialog` automatically) — no import change needed.

- [ ] **Step 2: Convert the SnackBar in `policy_edit_page.dart`**

Find (lines 264-268):
```dart
if (state is PolicyFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
  );
}
```
Replace with:
```dart
if (state is PolicyFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```
This file's import is also `hide showUploadDialog` — no import change needed.

- [ ] **Step 3: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control/ lib/features/grc/policy/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): trigger a Cubit failure on each page if reachable, confirm an error dialog appears.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart lib/features/grc/policy/presentation/ui/pages/policy_edit_page.dart
git commit -m "feat(grc): use showErrorDialog for add/edit-control and policy-edit failures"
```

---

### Task 12: `assignee_bulk_upload_preview_page.dart`

**Files:**
- Modify: `lib/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_preview_page.dart`

**Interfaces:**
- Consumes: `showSuccessDialog`, `showConfirmDialog` (Task 1; `showConfirmDialog` already imported/used for Activate — no change to that call).

This file already confirms before Activate. Gaps: success is a SnackBar (should be `showSuccessDialog`); the "Add at least one row" / "Select at least one row" / "Select exactly one row to duplicate" SnackBars are local validation (should become inline text, not a dialog); "Remove Selection" has no confirm dialog despite being a Remove-type action.

- [ ] **Step 1: Convert the success SnackBar to `showSuccessDialog`**

Find (lines 117-125):
```dart
if (state.succeededCount > 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${state.succeededCount} ${widget.assigneeLabel}(s) created'
            .tr,
      ),
    ),
  );
}
```
Replace with:
```dart
if (state.succeededCount > 0) {
  showSuccessDialog(
    context: context,
    title: 'Activated'.tr,
    subtitle:
        '${state.succeededCount} ${widget.assigneeLabel}(s) created'.tr,
  );
}
```

- [ ] **Step 2: Convert the three local-validation SnackBars to inline text**

Add a state field near the other row-table state: `String? _selectionError;`

Find (lines 92-94, inside `_onActivate`):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Add at least one row'.tr)),
);
```
Replace with:
```dart
setState(() => _selectionError = 'Add at least one row'.tr);
```

Find (lines 246-249, "Remove Selection" handler):
```dart
if (rowsData.selectedRows.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Select at least one row'.tr)),
  );
  return;
}
```
Replace with:
```dart
if (rowsData.selectedRows.isEmpty) {
  setState(() => _selectionError = 'Select at least one row'.tr);
  return;
}
```
Wrap the actual removal in a confirm dialog (this is the "Remove"-type action per the plan's scope):
```dart
showConfirmDialog(
  context: context,
  title: 'Remove Selected Rows'.tr,
  subtitle: 'Are you sure you want to remove the selected rows?'.tr,
  confirmLabel: 'Remove'.tr,
  cancelLabel: 'Cancel'.tr,
  onConfirm: () {
    setState(() => _selectionError = null);
    cubit.removeSelectedRows();
  },
);
```
(This replaces the direct `cubit.removeSelectedRows();` call that previously followed the validation check.)

Find (lines 263-266, "Duplication" handler):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Select exactly one row to duplicate'.tr)),
);
```
Replace with:
```dart
setState(() => _selectionError = 'Select exactly one row to duplicate'.tr);
```
(Duplication itself is not wrapped in a confirm dialog — it doesn't match the Submit/Create/Update/Delete/Approve/Reject/Cancel/Remove list, it only duplicates an in-memory row.)

Render `_selectionError` as inline text near the toolbar buttons (find the `Row` containing "Activate"/"Remove Selection"/"Duplication" and add, immediately after that `Row`):
```dart
if (_selectionError != null) ...[
  SizedBox(height: 6.h),
  Text(
    _selectionError!,
    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
  ),
],
```
Clear `_selectionError` whenever the selection changes (find wherever row selection toggles happen and add `_selectionError = null;` inside that `setState`) — read the actual selection-toggle code first since it wasn't in the research dump; match into it rather than guessing its exact shape.

- [ ] **Step 3: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): try Activate/Remove Selection/Duplication with no rows selected — confirm inline red text appears near the toolbar instead of a SnackBar. Select rows and remove them — confirm a "Remove Selected Rows" dialog appears first. Successfully activate rows — confirm a success dialog shows the created count.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_preview_page.dart
git commit -m "feat(grc): inline validation text, remove-confirm, and success dialog for assignee bulk upload"
```

---

### Task 13: `control_bulk_upload_preview_page.dart`

**Files:**
- Modify: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart`

**Interfaces:**
- Consumes: `showConfirmDialog`, `showSuccessDialog` (Task 1).

Unlike its sibling `assignee_bulk_upload_preview_page.dart` (Task 12), this file has zero dialog-helper adoption — needs the full treatment: confirm before Activate, success dialog after, inline text for validations, confirm before Remove Selection.

- [ ] **Step 1: Add the import**

Add `import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';`.

- [ ] **Step 2: Add a confirm dialog to Activate**

Current `_onActivate` (lines 92-105):
```dart
Future<void> _onActivate(ControlBulkUploadCubit cubit) async {
  final rowsData = cubit.rowsData;
  if (!rowsData.isValid) {
    if (rowsData.errorLocations.isNotEmpty) {
      _jumpToError(true, rowsData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add at least one row'.tr)),
      );
    }
    return;
  }
  await cubit.submit(moduleId: widget.moduleId, policyId: widget.policyId);
}
```
Replace with:
```dart
Future<void> _onActivate(ControlBulkUploadCubit cubit) async {
  final rowsData = cubit.rowsData;
  if (!rowsData.isValid) {
    if (rowsData.errorLocations.isNotEmpty) {
      _jumpToError(true, rowsData);
    } else {
      setState(() => _selectionError = 'Add at least one row'.tr);
    }
    return;
  }
  await showConfirmDialog(
    context: context,
    title: 'Activate Controls'.tr,
    subtitle: 'Are you sure you want to activate these controls?'.tr,
    confirmLabel: 'Activate'.tr,
    cancelLabel: 'Cancel'.tr,
    onConfirm: () =>
        cubit.submit(moduleId: widget.moduleId, policyId: widget.policyId),
  );
}
```
Add the state field `String? _selectionError;` near the other row-table state fields.

- [ ] **Step 3: Convert the success SnackBar**

Find (lines 114-121):
```dart
if (state.succeededCount > 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${state.succeededCount} ${'control(s) created'.tr}',
      ),
    ),
  );
}
```
Replace with:
```dart
if (state.succeededCount > 0) {
  showSuccessDialog(
    context: context,
    title: 'Activated'.tr,
    subtitle: '${state.succeededCount} ${'control(s) created'.tr}',
  );
}
```

- [ ] **Step 4: Convert "Remove Selection" and "Duplication" validation SnackBars, add confirm to Remove**

Find (lines 237-249):
```dart
customButton(
  title: 'Remove Selection'.tr,
  function: () {
    if (rowsData.selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select at least one row'.tr)),
      );
      return;
    }
    cubit.removeSelectedRows();
  },
  width: 150.w,
  height: 30.h,
  color: AppColors.black,
  textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
),
```
Replace with:
```dart
customButton(
  title: 'Remove Selection'.tr,
  function: () {
    if (rowsData.selectedRows.isEmpty) {
      setState(() => _selectionError = 'Select at least one row'.tr);
      return;
    }
    showConfirmDialog(
      context: context,
      title: 'Remove Selected Rows'.tr,
      subtitle: 'Are you sure you want to remove the selected rows?'.tr,
      confirmLabel: 'Remove'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () {
        setState(() => _selectionError = null);
        cubit.removeSelectedRows();
      },
    );
  },
  width: 150.w,
  height: 30.h,
  color: AppColors.black,
  textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
),
```

Find (lines 254-257, "Duplication"):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Select exactly one row to duplicate'.tr)),
);
```
Replace with:
```dart
setState(() => _selectionError = 'Select exactly one row to duplicate'.tr);
```
(No confirm dialog for Duplication — same reasoning as Task 12.)

Render `_selectionError` under the toolbar, and clear it on selection change, matching Task 12's Step 2 pattern (find this file's own selection-toggle code and match into it).

- [ ] **Step 5: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): same as Task 12's, control side.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart
git commit -m "feat(grc): full dialog-convention adoption for control bulk upload preview"
```

---

### Task 14: `control_weight_issue_page.dart` + `policy_weight_issue_page.dart`

**Files:**
- Modify: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart`
- Modify: `lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart`

**Interfaces:**
- Consumes: `showConfirmDialog`, `showSuccessDialog`, `showErrorDialog` (Task 1).

Both files are near-identical and both fully unconverted: "Apply Changes" (the one action that actually persists data — "Equal Weight"/"Discard Changes" only touch in-memory rows and stay out of scope) has no confirm dialog, and success/failure both go through SnackBars.

- [ ] **Step 1: Add the import to both files**

Add `import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';` to both `control_weight_issue_page.dart` and `policy_weight_issue_page.dart`.

- [ ] **Step 2: Wrap "Apply Changes" in a confirm dialog — `control_weight_issue_page.dart`**

Find (lines 239-247):
```dart
customButton(
  title: 'Apply Changes'.tr,
  function: rowsData.totalWeightValid
      ? () => cubit.applyChanges(widget.module.moduleId, widget.policy.id)
      : () {},
  width: 150.w,
  height: 38.h,
  color: rowsData.totalWeightValid ? AppColors.primary : AppColors.secondaryText,
),
```
Replace with:
```dart
customButton(
  title: 'Apply Changes'.tr,
  function: rowsData.totalWeightValid
      ? () => showConfirmDialog(
            context: context,
            title: 'Apply Weight Changes'.tr,
            subtitle:
                'Are you sure you want to apply these weight changes?'.tr,
            confirmLabel: 'Apply'.tr,
            cancelLabel: 'Cancel'.tr,
            onConfirm: () =>
                cubit.applyChanges(widget.module.moduleId, widget.policy.id),
          )
      : () {},
  width: 150.w,
  height: 38.h,
  color: rowsData.totalWeightValid ? AppColors.primary : AppColors.secondaryText,
),
```

- [ ] **Step 3: Convert the success/failure SnackBars — `control_weight_issue_page.dart`**

Find (lines 150-160):
```dart
listener: (context, state) {
  if (state is ControlWeightIssueApplySuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You Have Successfully Edited Controls Weights'.tr)),
    );
  }
  if (state is ControlWeightIssueFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message)),
    );
  }
},
```
Replace with:
```dart
listener: (context, state) {
  if (state is ControlWeightIssueApplySuccess) {
    showSuccessDialog(
      context: context,
      title: 'Weights Updated'.tr,
      subtitle: 'You Have Successfully Edited Controls Weights'.tr,
    );
  }
  if (state is ControlWeightIssueFailure) {
    showErrorDialog(context: context, subtitle: state.message);
  }
},
```

- [ ] **Step 4: Repeat Steps 2-3 for `policy_weight_issue_page.dart`**

Find (lines 235-243):
```dart
customButton(
  title: 'Apply Changes'.tr,
  function: rowsData.totalWeightValid
      ? () => cubit.applyChanges(widget.module.moduleId)
      : () {},
  width: 150.w,
  height: 38.h,
  color: rowsData.totalWeightValid ? AppColors.primary : AppColors.secondaryText,
),
```
Replace with:
```dart
customButton(
  title: 'Apply Changes'.tr,
  function: rowsData.totalWeightValid
      ? () => showConfirmDialog(
            context: context,
            title: 'Apply Weight Changes'.tr,
            subtitle:
                'Are you sure you want to apply these weight changes?'.tr,
            confirmLabel: 'Apply'.tr,
            cancelLabel: 'Cancel'.tr,
            onConfirm: () => cubit.applyChanges(widget.module.moduleId),
          )
      : () {},
  width: 150.w,
  height: 38.h,
  color: rowsData.totalWeightValid ? AppColors.primary : AppColors.secondaryText,
),
```
Find (lines 145-157):
```dart
listener: (context, state) {
  if (state is PolicyWeightIssueApplySuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You Have Successfully Edited Policies Weights'.tr)),
    );
  }
  if (state is PolicyWeightIssueFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message)),
    );
  }
},
```
Replace with:
```dart
listener: (context, state) {
  if (state is PolicyWeightIssueApplySuccess) {
    showSuccessDialog(
      context: context,
      title: 'Weights Updated'.tr,
      subtitle: 'You Have Successfully Edited Policies Weights'.tr,
    );
  }
  if (state is PolicyWeightIssueFailure) {
    showErrorDialog(context: context, subtitle: state.message);
  }
},
```

- [ ] **Step 5: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/control/ lib/features/grc/policy/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): on each page, edit weights until valid, tap Apply Changes — confirm the new confirm dialog appears, and a success dialog shows after applying.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart lib/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart
git commit -m "feat(grc): confirm/success/error dialogs for control and policy weight-issue apply"
```

---

### Task 15: `create_new_policy.dart`

**Files:**
- Modify: `lib/features/grc/policy/presentation/ui/pages/create_new_policy.dart`

**Interfaces:**
- Consumes: `showErrorDialog` (Task 1). Confirm dialogs already exist on Discard/Save For Later/Publish and `showSuccessDialog` on success — this task only closes the remaining validation/failure gaps.

- [ ] **Step 1: Convert `_showBlockingErrorsSnackbar` to render inline instead**

Current shared helper (lines 380-388):
```dart
void _showBlockingErrorsSnackbar() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content:
          Text('Please fix the highlighted errors before continuing.'.tr),
      backgroundColor: AppColors.red,
    ),
  );
}
```
This message is generic ("fix the highlighted errors") because the actual per-field errors are already rendered inline by `PolicyInfoFormWidget`/`AddPolicyControlsPage` via their own `errorText`/`submitted` wiring (per research, this file already passes `submitted: _step0Submitted` / `controlsSubmitted: _controlsSubmitted` into those child widgets). The SnackBar here is redundant on top of that inline wiring — replace both call sites of `_showBlockingErrorsSnackbar()` with just setting the relevant `submitted` flag (which is likely already set before this is called; verify by reading the two call sites — inside `_handleSaveForLaterPressed` and `_handlePublishPressed`/`_handlePreviewPressed`) and delete the helper function entirely once no call sites remain. If the `submitted` flag is NOT already set at the point this is called, add `setState(() => _controlsSubmitted = true);` (or the correct flag for that call site) immediately before returning, so the child widgets' existing inline-error rendering activates.

- [ ] **Step 2: Convert the two "Total Weight should be 100" SnackBars to inline text**

Find both occurrences (lines 504-513 in `_onPublish`/similar, and lines 644-652 in `_handlePublishPressed` — research found this message duplicated at two call sites; verify both are still present and read their exact surrounding code before editing):
```dart
if (!_isWeightValid) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Total Weight should be 100'.tr),
      backgroundColor: AppColors.red,
    ),
  );
  return;
}
```
Replace each with:
```dart
if (!_isWeightValid) {
  setState(() => _weightSubmitted = true);
  return;
}
```
Add the field `bool _weightSubmitted = false;` near the other `_xSubmitted` flags. Find wherever the total-weight box is rendered (likely inside the controls section, similar to `control_weight_issue_page.dart`'s `_buildTotalWeight`) and make its "Total Weight Should be 100" red text conditional on `_weightSubmitted && !_isWeightValid` instead of always-visible-when-invalid — matching the rest of this file's `_submitted`-gated inline-error convention (only show the error after the user has tried to proceed, not immediately on page load). If no such gating currently exists for this specific box, it's acceptable to leave the box's existing always-visible-when-invalid behavior as-is and only remove the SnackBar — do not invent new gating logic beyond what's needed to remove the SnackBar; note which choice you made in your task report.

- [ ] **Step 3: Convert the step-0 "fill all required fields" SnackBar**

Find (lines 603-613):
```dart
void _handleNextPressed() {
  setState(() => _step0Submitted = true);
  if (!_validateStep0()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill all required fields'.tr),
        backgroundColor: AppColors.red,
      ),
    );
    return;
  }
  setState(() => _step = 1);
}
```
Replace with:
```dart
void _handleNextPressed() {
  setState(() => _step0Submitted = true);
  if (!_validateStep0()) return;
  setState(() => _step = 1);
}
```
`_step0Submitted` is already set to `true` before the check, which (per research) is already wired into `CreatePolicyStep0`'s `submitted:` param — the SnackBar was purely redundant confirmation on top of already-working inline errors.

- [ ] **Step 4: Convert the `PolicyActionPartialSuccess` and `PolicyFailure` SnackBars to `showErrorDialog`**

Find (lines 717-733):
```dart
if (state is PolicyActionPartialSuccess) {
  final reasons =
      state.failedControls.map((f) => f.message).toSet().join('; ');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${'Policy saved, but one or more Controls failed to save:'.tr} $reasons',
      ),
      backgroundColor: AppColors.red,
    ),
  );
  Navigator.of(context).pop(true);
  return;
}
```
Replace with:
```dart
if (state is PolicyActionPartialSuccess) {
  final reasons =
      state.failedControls.map((f) => f.message).toSet().join('; ');
  showErrorDialog(
    context: context,
    title: 'Policy Saved With Errors'.tr,
    subtitle:
        '${'Policy saved, but one or more Controls failed to save:'.tr} $reasons',
  );
  Navigator.of(context).pop(true);
  return;
}
```
Find (lines 736-742):
```dart
if (state is PolicyFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(state.message),
      backgroundColor: AppColors.red,
    ),
  );
}
```
Replace with:
```dart
if (state is PolicyFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```

- [ ] **Step 5: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/policy/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): leave step-0 fields empty and tap Next — confirm inline errors appear with no SnackBar. Make the weight invalid and try to Publish — confirm no SnackBar appears (inline weight box still shows the problem). Trigger a partial/full failure if reachable — confirm error dialogs appear.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/create_new_policy.dart
git commit -m "feat(grc): remove redundant validation SnackBars, use showErrorDialog for create-policy failures"
```

---

### Task 16: `policy_bulk_upload_preview_page.dart`

**Files:**
- Modify: `lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_preview_page.dart`

**Interfaces:**
- Consumes: `showConfirmDialog` (already used for Activate), `showSuccessDialog`, `showErrorDialog` (Task 1).

Mirror of Task 12 (`assignee_bulk_upload_preview_page.dart`), plus one gap the others don't have: `PolicyBulkUploadSubmitResult.failed` is currently never surfaced to the user at all when non-empty.

- [ ] **Step 1: Convert the success SnackBar and surface failures**

Find (lines 126-135):
```dart
listener: (context, state) {
  if (state is PolicyBulkUploadSubmitResult) {
    if (state.succeededCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${state.succeededCount} ${'polic(y/ies) created'.tr}',
          ),
        ),
      );
    }
    if (state.failed.isEmpty) {
      Navigator.pop(context, true);
    }
  }
},
```
Replace with:
```dart
listener: (context, state) {
  if (state is PolicyBulkUploadSubmitResult) {
    if (state.succeededCount > 0) {
      showSuccessDialog(
        context: context,
        title: 'Activated'.tr,
        subtitle: '${state.succeededCount} ${'polic(y/ies) created'.tr}',
      );
    }
    if (state.failed.isNotEmpty) {
      final reasons = state.failed.map((f) => f.message).toSet().join('; ');
      showErrorDialog(
        context: context,
        title: 'Some Policies Failed'.tr,
        subtitle: reasons,
      );
    }
    if (state.failed.isEmpty) {
      Navigator.pop(context, true);
    }
  }
},
```
(Adjust `f.message` to whatever field `PolicyBulkUploadSubmitResult.failed`'s element type actually exposes — read `PolicyBulkUploadSubmitResult`'s definition first; the shape is inferred from `create_new_policy.dart`'s analogous `failedControls`/`f.message` pattern in Task 15 Step 4, but verify against this state class specifically before assuming it matches exactly.)

- [ ] **Step 2: Convert the three local-validation SnackBars to inline text and add a Remove-Selection confirm dialog**

Add `String? _selectionError;` near the other row-table state.

Find (lines 104-106, inside `_onActivate`):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Add at least one row'.tr)),
);
```
Replace with:
```dart
setState(() => _selectionError = 'Add at least one row'.tr);
```

Find (lines 252-267, "Remove Selection"):
```dart
customButton(
  title: 'Remove Selection'.tr,
  function: () {
    if (rowsData.selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select at least one row'.tr)),
      );
      return;
    }
    cubit.removeSelectedRows();
  },
  width: 150.w,
  height: 30.h,
  color: AppColors.black,
  textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
),
```
Replace with:
```dart
customButton(
  title: 'Remove Selection'.tr,
  function: () {
    if (rowsData.selectedRows.isEmpty) {
      setState(() => _selectionError = 'Select at least one row'.tr);
      return;
    }
    showConfirmDialog(
      context: context,
      title: 'Remove Selected Rows'.tr,
      subtitle: 'Are you sure you want to remove the selected rows?'.tr,
      confirmLabel: 'Remove'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () {
        setState(() => _selectionError = null);
        cubit.removeSelectedRows();
      },
    );
  },
  width: 150.w,
  height: 30.h,
  color: AppColors.black,
  textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
),
```

Find (lines 269-284, "Duplication"):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Select exactly one row to duplicate'.tr)),
);
```
Replace with:
```dart
setState(() => _selectionError = 'Select exactly one row to duplicate'.tr);
```

Render `_selectionError` under the toolbar and clear it on selection change, matching Task 12's pattern (read this file's own selection-toggle code and match into it).

- [ ] **Step 3: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/policy/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): same shape as Task 12's, policy side, plus confirm a partial-failure bulk upload now shows an error dialog listing the failure reasons instead of silently doing nothing.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_preview_page.dart
git commit -m "feat(grc): inline validation text, remove-confirm, success/error dialogs for policy bulk upload"
```

---

### Task 17: `grc_details_page.dart`

**Files:**
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_details_page.dart`

**Interfaces:**
- Consumes: `showConfirmDialog` (already imported/used), `showErrorDialog` (Task 1).

This file has the clearest existing inconsistency in the whole plan: the *auto-delete* path (`_scheduleAutoDelete`) already wraps deletion in `showConfirmDialog`, but the *manual* Delete button in view mode calls `_onDelete(cubit)` directly with no confirmation at all. Create/Update/Restore (via `GrcBottomButtons.onAction`) also have zero confirmation today.

- [ ] **Step 1: Add a confirm dialog to the manual Delete button**

Find the view-mode delete wiring (around lines 326-329):
```dart
onDeleteTap: () {
  _pendingAction = _PendingAction.delete;
  _onDelete(cubit);
},
```
Replace with:
```dart
onDeleteTap: () {
  showConfirmDialog(
    context: context,
    title: 'Deleting GRC Module'.tr,
    cancelLabel: 'No'.tr,
    confirmLabel: 'Yes'.tr,
    iconWidget: SvgPicture.asset('assets/icons/delete_icon.svg'),
    subtitle: 'Are You Sure You Want To Delete This GRC Module ?'.tr,
    onConfirm: () {
      _pendingAction = _PendingAction.delete;
      _onDelete(cubit);
    },
  );
},
```
(This is the exact same dialog `_scheduleAutoDelete` already builds — both paths now go through an equivalent confirmation instead of only one of them.)

- [ ] **Step 2: Add confirm dialogs to Create/Update/Restore**

Find the `GrcBottomButtons.onAction` wiring (around lines 409-431):
```dart
onAction: () {
  if (_currentMode == GrcPageMode.create) {
    _pendingAction = _PendingAction.create;
    _onCreate(cubit);
  } else if (_currentMode == GrcPageMode.edit) {
    _pendingAction = _PendingAction.update;
    _onUpdate(cubit);
  } else if (_currentMode == GrcPageMode.restore) {
    _pendingAction = _PendingAction.restore;
    _onRestore(cubit);
  }
},
```
Replace with:
```dart
onAction: () {
  if (_currentMode == GrcPageMode.create) {
    showConfirmDialog(
      context: context,
      title: 'Creating GRC Module'.tr,
      cancelLabel: 'No'.tr,
      confirmLabel: 'Yes'.tr,
      subtitle: 'Are You Sure You Want To Create This GRC Module ?'.tr,
      onConfirm: () {
        _pendingAction = _PendingAction.create;
        _onCreate(cubit);
      },
    );
  } else if (_currentMode == GrcPageMode.edit) {
    showConfirmDialog(
      context: context,
      title: 'Updating GRC Module'.tr,
      cancelLabel: 'No'.tr,
      confirmLabel: 'Yes'.tr,
      subtitle: 'Are You Sure You Want To Update This GRC Module ?'.tr,
      onConfirm: () {
        _pendingAction = _PendingAction.update;
        _onUpdate(cubit);
      },
    );
  } else if (_currentMode == GrcPageMode.restore) {
    showConfirmDialog(
      context: context,
      title: 'Restoring GRC Module'.tr,
      cancelLabel: 'No'.tr,
      confirmLabel: 'Yes'.tr,
      subtitle: 'Are You Sure You Want To Restore This GRC Module ?'.tr,
      onConfirm: () {
        _pendingAction = _PendingAction.restore;
        _onRestore(cubit);
      },
    );
  }
},
```
Note: `_validate` (the field-validation gate) already runs before `onAction` is reachable (per `GrcBottomButtons`' own `validate:` param wiring, passed a few lines above) — the confirm dialog added here only gates the actual persistence, it doesn't change when field errors surface.

- [ ] **Step 3: Convert the failure SnackBar**

Find (lines 255-262):
```dart
if (state is GRCModuleFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(state.message),
      backgroundColor: AppColors.red,
    ),
  );
}
```
Replace with:
```dart
if (state is GRCModuleFailure) {
  showErrorDialog(context: context, subtitle: state.message);
}
```

- [ ] **Step 4: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/module/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): tap the manual Delete button in view mode — confirm it now asks for confirmation (previously it didn't). Create, edit, and restore a module — confirm each now asks for confirmation before persisting, and that the existing success dialogs still show correctly afterward (unchanged in this task).

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/module/presentation/ui/pages/grc_details_page.dart
git commit -m "fix(grc): add missing confirm dialogs to module delete/create/update/restore, use showErrorDialog for failures"
```

---

### Task 18: `grc_request_details_page.dart`

**Files:**
- Modify: `lib/features/grc/grc_request/presentation/ui/pages/grc_request_details_page.dart`

**Interfaces:**
- Consumes: `showSuccessDialog`, `showErrorDialog` (Task 1). `showConfirmDialog` (Approve) and `showCommentDialog` (Reject) already used — no change to those calls themselves.

Both Approve and Reject already gate on a confirmation step, but neither shows a success dialog when the action actually succeeds — success is currently silent apart from a local `setState`.

- [ ] **Step 1: Add a success dialog to the success branch, convert the failure SnackBar**

Find (lines 243-252):
```dart
listener: (context, state) {
  if (state is GrcRequestActionSuccess &&
      state.request.id == _request.id) {
    setState(() => _request = state.request);
  } else if (state is GrcRequestFailure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action failed: ${state.message}')),
    );
  }
},
```
Replace with:
```dart
listener: (context, state) {
  if (state is GrcRequestActionSuccess &&
      state.request.id == _request.id) {
    final isApproved = state.request.status == ApprovalStatus.approved;
    setState(() => _request = state.request);
    showSuccessDialog(
      context: context,
      title: isApproved ? 'Request Approved'.tr : 'Request Rejected'.tr,
      subtitle: isApproved
          ? 'You successfully approved this request.'.tr
          : 'You successfully rejected this request.'.tr,
    );
  } else if (state is GrcRequestFailure) {
    showErrorDialog(
      context: context,
      subtitle: 'Action failed: ${state.message}',
    );
  }
},
```
(This assumes `GrcRequestActionSuccess` fires for both Approve and Reject outcomes with the updated request's new status, per the Cubit's `approveRequest`/`rejectRequest` methods established in the deduplication plan's Task 8 — verify this against the actual `GrcRequestCubit` if unsure, since this file's own state-handling code is the only thing being read here, not the Cubit's.)

- [ ] **Step 2: Verify and manual smoke check**

Run: `/Users/bstar/.puro/bin/puro flutter analyze lib/features/grc/grc_request/`
Expected: no new issues vs. baseline.

Manual check (state explicitly if not performable): approve a pending request — confirm a success dialog now shows (previously silent). Reject one with a reason — confirm the same. Trigger a failure if reachable — confirm an error dialog shows instead of a SnackBar.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/grc_request/presentation/ui/pages/grc_request_details_page.dart
git commit -m "feat(grc): add success dialog after approve/reject, use showErrorDialog for failures"
```

---

## Self-Review Notes

- **Spec coverage:** every SnackBar found in the 2026-07-26 research (~52 across the files list) is addressed: success→`showSuccessDialog`, Cubit-failure→`showErrorDialog`, local-validation→inline text. Every already-existing `showConfirmDialog`/`showSuccessDialog` call was left untouched. The two real "missing confirmation" gaps found (module's manual Delete button, module's Create/Update/Restore, and the "Remove Selection" actions in three bulk-upload preview pages) are explicitly added.
- **Explicitly out of scope, documented so it isn't rediscovered as "new":** `control_bulk_weight_dialog.dart` (structurally a different kind of dialog — a Yes/No question, not an action confirmation); "Add Row"/"Duplicate Row"/"Equal Weight"/"Discard Changes (local)"/"Back"/step-navigation buttons (none persist data by themselves); `showCommentDialog`'s own internal validation (unrelated to this plan, that dialog already exists and works).
- **Placeholder scan:** every step embeds the literal before/after code from the research reports above; the handful of steps that say "read the actual current widget tree first" (Task 7 Step 4, Task 12/13/16's selection-toggle clearing) are flagged as such because the research explicitly did not capture that surrounding code — this is an honest gap in available research, not a placeholder for something that could have been written but wasn't.
- **Type consistency:** `showErrorDialog`'s signature (Task 1) is used identically across all 17 consuming tasks — always `showErrorDialog(context: context, subtitle: <message>)`, sometimes with an explicit `title:`. `showConfirmDialog`'s `onConfirm`/`onCancel` shape is used consistently, including the `Completer`-based wrapper (Tasks 3 and 7) for the two call sites that need to `await` a yes/no answer inline rather than fire-and-forget.
