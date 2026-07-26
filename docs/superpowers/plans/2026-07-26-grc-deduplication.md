# GRC Cross-Feature Deduplication — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate every cross-file duplication identified in the 2026-07-26 GRC code quality audit (`docs/superpowers/plans/` sibling report) by extracting one shared, well-documented home for each duplicated helper, model, widget, enum, and constant — before any other audit findings are addressed.

**Architecture:** Cross-feature helpers that only `control_champion`/`control_owner` need go in a new `lib/features/grc/shared/` layer (mirrors the existing `lib/core/` "shared components" convention from `Code Quality Standards.md`, but scoped to GRC because the code depends on GRC-only entities like `ControlEntity`/`AssigningControlEntity`). Firestore key constants stay on each model (private, `static const`) except the handful of keys reused verbatim by 2+ models, which move to one shared `GrcFirestoreKeys` class. Enums follow the exact `value`/`fromString` shape already used by `ChampionStatus`/`OwnerStatus`/`ControlStatus`/`PolicyStatus` in this codebase.

**Tech Stack:** Flutter, GetX (DI + navigation extensions), flutter_bloc (Cubit), Firestore, `flutter_screenutil` (`.w`/`.h`/`.r`/`.sp`), GetX `.tr` localization.

## Global Constraints

- Package name is `demo_app` — every new file's imports use `package:demo_app/...`.
- This repo has no unit/widget test suite for `lib/features/grc/` (only the Flutter-generated `test/widget_test.dart` boilerplate exists). There is therefore no "write a failing test" step in this plan. Each task's verification step is **`flutter analyze`** on the changed files (must report the same or fewer issues than before the change) plus an explicit description of what to manually click through in the running app to confirm behavior didn't change. Do not skip the manual check — `flutter analyze` only proves the code compiles and type-checks, not that behavior was preserved.
- These are refactors, not behavior changes. If a step's manual check reveals a behavior difference, stop and fix it before moving to the next step — do not "fix it later."
- Every new file gets a one-line library-level doc comment stating its purpose (per `Code Quality Standards.md` → Commenting Standards), and every extracted public function/class gets a short `///` doc comment explaining *why* it exists (what it deduplicates), not what it does line-by-line.
- Do not reformat or touch code outside the exact lines called out in each step. Small, reviewable diffs — resist the urge to "clean up while you're in there"; that's later plans' job.
- Run `git status` before starting each task and commit only the files that task lists.

---

## File Structure

New files this plan creates:

```
lib/features/grc/shared/
  helpers/
    grc_assignment_lookup.dart       # Task 1
  models/
    pending_assignment_row.dart      # Task 2
  widgets/
    grc_assignment_chip.dart         # Task 2
    grc_policy_control_picker_row.dart  # Task 3
  constants/
    grc_firestore_keys.dart          # Task 5
```

Files modified (grouped by task, exact line ranges given inside each task):

```
Task 1: champion_cubit.dart, add_champion_page.dart, control_champion_details_page.dart,
        edit_champion_controls_page.dart, reassign_champion_page.dart, owner_cubit.dart,
        add_owner_page.dart, control_owner_details_page.dart, edit_owner_controls_page.dart,
        reassign_owner_page.dart
Task 2: edit_champion_controls_page.dart, reassign_champion_page.dart,
        control_champion_details_page.dart, edit_owner_controls_page.dart,
        reassign_owner_page.dart, control_owner_details_page.dart
Task 3: add_champion_page.dart, edit_champion_controls_page.dart, reassign_champion_page.dart,
        add_owner_page.dart, edit_owner_controls_page.dart, reassign_owner_page.dart
Task 4: app_assets.dart, control_champion_details_page.dart, reassign_champion_page.dart,
        control_owner_details_page.dart, reassign_owner_page.dart, grc_request_details_page.dart
Task 5: control_model.dart, assigning_control_model.dart, control_department_weight.dart,
        champion_model.dart, owner_model.dart, grc_module_model.dart, grc_request_model.dart,
        policy_model.dart
Task 6: control_entity.dart, control_weight_issue_row.dart, control_weight_issue_page.dart,
        control_weight_history_tab.dart, add_edit_control_page.dart, control_bulk_row_form.dart
Task 7: approval_status.dart, grc_requests_list_page.dart, grc_request_details_page.dart
Task 8: grc_request_model.dart, grc_request_repository_impl.dart
Task 9: create_policy_step1_buttons.dart (deleted), create_policy_step2_buttons.dart (deleted),
        create_policy_buttons.dart (new), create_new_policy.dart
Task 10: control_frequency.dart (new), add_edit_control_page.dart, control_bulk_row_form.dart
Task 11: grc_module_status.dart (new), grc_module_model.dart, grc_module_entity.dart,
         grc_module_firebase_data_source.dart, grc_details_page.dart, grc_page.dart
Task 12: grc_module_entity.dart, grc_page.dart, grc_details_page.dart, grc_module_details_page.dart
```

---

### Task 1: Shared employee/control lookup helpers (control_champion + control_owner)

Removes 4 identically-duplicated helpers from 8 files down to one shared module.

**Files:**
- Create: `lib/features/grc/shared/helpers/grc_assignment_lookup.dart`
- Modify: `lib/features/grc/control_champion/presentation/controller/champion_cubit.dart:46-54`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/add_champion_page.dart:141-149`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/control_champion_details_page.dart:105-137`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/edit_champion_controls_page.dart:60-68,127-136`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/reassign_champion_page.dart:75-101,102-111`
- Modify: `lib/features/grc/control_owner/presentation/controller/owner_cubit.dart:47-55`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/add_owner_page.dart:143-151`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/control_owner_details_page.dart:104-136`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/edit_owner_controls_page.dart:59-67,126-135`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/reassign_owner_page.dart:76-90,103-112`

**Interfaces:**
- Produces: `String currentGrcUserEmail()`, `EmployeeEntityPro? findEmployeeByEmail(String email)`, `String employeeDisplayName(BuildContext context, String email)`, `ControlEntity? findControlInPolicy(Map<String, List<ControlEntity>> policyControls, String policyId, String controlId)` — all top-level functions in `grc_assignment_lookup.dart`, used by Tasks 2 and 3 too.

- [ ] **Step 1: Create the shared helpers file**

Create `lib/features/grc/shared/helpers/grc_assignment_lookup.dart`:

```dart
/// Shared lookups used by every GRC champion/owner assignment page —
/// resolving the current user's email, finding a cached employee by email,
/// and finding a control inside an already-loaded policy->controls map.
/// Extracted because control_champion and control_owner each duplicated
/// these four functions verbatim across their cubit + 3 page files.
library;

import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Resolves the signed-in user's email for GRC assignment flows, falling
/// back from [Constant.emailUser] to the cached employee controller when
/// the constant hasn't been populated yet. Returns '' if neither is set.
String currentGrcUserEmail() {
  final fromConstant = Constant.emailUser;
  if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
  if (Get.isRegistered<MainCoreEmployeeController>()) {
    final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    if (email != null && email.isNotEmpty) return email;
  }
  return '';
}

/// Looks up an employee by email from the globally cached employee list.
/// Returns null if the controller isn't registered or no match exists.
EmployeeEntityPro? findEmployeeByEmail(String email) {
  if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
  final employees =
      Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
  for (final e in employees) {
    if (e.email == email) return e;
  }
  return null;
}

/// Localized display name for [email], falling back to the raw email when
/// no matching employee is cached.
String employeeDisplayName(BuildContext context, String email) {
  final employee = findEmployeeByEmail(email);
  if (employee == null) return email;
  return EmployeeHelper.getEmployeeLocalizedName(
      employee: employee, context: context);
}

/// Finds the [ControlEntity] for [controlId] under [policyId] inside
/// [policyControls] — the policy-id -> controls map every champion/owner
/// assignment page already loads via GetAllControlsUseCase.
ControlEntity? findControlInPolicy(
  Map<String, List<ControlEntity>> policyControls,
  String policyId,
  String controlId,
) {
  final list = policyControls[policyId];
  if (list == null) return null;
  for (final c in list) {
    if (c.id == controlId) return c;
  }
  return null;
}
```

- [ ] **Step 2: Verify the new file analyzes cleanly**

Run: `flutter analyze lib/features/grc/shared/helpers/grc_assignment_lookup.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 3: Commit the new shared file**

```bash
git add lib/features/grc/shared/helpers/grc_assignment_lookup.dart
git commit -m "feat(grc): add shared employee/control lookup helpers"
```

- [ ] **Step 4: Replace `_currentUserEmail` in champion_cubit.dart**

In `lib/features/grc/control_champion/presentation/controller/champion_cubit.dart`, delete the getter at lines 46-54:

```dart
String get _currentUserEmail {
  final fromConstant = Constant.emailUser;
  if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
  if (Get.isRegistered<MainCoreEmployeeController>()) {
    final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    if (email != null && email.isNotEmpty) return email;
  }
  return '';
}
```

Add the import:
```dart
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
```

Replace every call site `_currentUserEmail` (no parens, it was a getter) with `currentGrcUserEmail()` throughout the file.

- [ ] **Step 5: Repeat Step 4's pattern in the remaining 7 files**

For each of the following, delete the local `_currentUserEmail` getter (same body as above, at the line ranges listed in Files), add the same import, and replace every `_currentUserEmail` call site with `currentGrcUserEmail()`:
- `add_champion_page.dart:141-149`
- `edit_champion_controls_page.dart:127-136`
- `reassign_champion_page.dart:102-111`
- `owner_cubit.dart:47-55`
- `add_owner_page.dart:143-151`
- `edit_owner_controls_page.dart:126-135`
- `reassign_owner_page.dart:103-112`

- [ ] **Step 6: Replace `_findEmployee` in the 4 files that have it**

In `control_champion_details_page.dart:105-113`, `reassign_champion_page.dart:75-83`, `control_owner_details_page.dart:104-112`, `reassign_owner_page.dart:76-84`, delete:

```dart
EmployeeEntityPro? _findEmployee(String email) {
  if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
  final employees =
      Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
  for (final e in employees) {
    if (e.email == email) return e;
  }
  return null;
}
```

Add the shared-helpers import (skip if already added in Step 4/5 for that file), and replace every `_findEmployee(...)` call with `findEmployeeByEmail(...)`.

- [ ] **Step 7: Replace `_employeeDisplayName` in the same 4 files**

Delete:
```dart
String _employeeDisplayName(BuildContext context, String email) {
  final employee = _findEmployee(email);
  if (employee == null) return email;
  return EmployeeHelper.getEmployeeLocalizedName(
      employee: employee, context: context);
}
```
from `control_champion_details_page.dart:115-120`, `reassign_champion_page.dart:85-90`, `control_owner_details_page.dart:114-119`, `reassign_owner_page.dart:86-91`. Replace every `_employeeDisplayName(...)` call with `employeeDisplayName(...)`.

- [ ] **Step 8: Replace `_getControlEntity` in all 6 files that have it**

Delete this method from `control_champion_details_page.dart:129-137`, `edit_champion_controls_page.dart:60-68`, `reassign_champion_page.dart:92-100`, `control_owner_details_page.dart:128-136`, `edit_owner_controls_page.dart:59-67`, `reassign_owner_page.dart:93-101`:

```dart
ControlEntity? _getControlEntity(String policyId, String controlId) {
  final list = widget.policyControls[policyId]; // or _policyControls[policyId] in details pages
  if (list != null) {
    for (final c in list) {
      if (c.id == controlId) return c;
    }
  }
  return null;
}
```

Replace every call site:
- In the 2 details pages, `_getControlEntity(policyId, controlId)` → `findControlInPolicy(_policyControls, policyId, controlId)`
- In the 4 edit/reassign pages, `_getControlEntity(policyId, controlId)` → `findControlInPolicy(widget.policyControls, policyId, controlId)`

- [ ] **Step 9: Verify all 10 modified files analyze cleanly**

Run: `flutter analyze lib/features/grc/control_champion/ lib/features/grc/control_owner/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 10: Manual smoke check**

Run the app, sign in, open a Control's Champion (or Owner) details page. Confirm the employee name/photo still render, open Edit and Reassign from that page, confirm the policy/control pickers still populate and submitting still works. This exercises every function this task touched.

- [ ] **Step 11: Commit**

```bash
git add lib/features/grc/control_champion/ lib/features/grc/control_owner/
git commit -m "refactor(grc): use shared lookup helpers in champion/owner pages"
```

---

### Task 2: Shared `PendingAssignmentRow` model + `GrcAssignmentChip` widget

**Files:**
- Create: `lib/features/grc/shared/models/pending_assignment_row.dart`
- Create: `lib/features/grc/shared/widgets/grc_assignment_chip.dart`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/edit_champion_controls_page.dart:82-96,111,295-321,433-436`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/reassign_champion_page.dart:119-133,143,392-419,549-552`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/control_champion_details_page.dart:404-419,446-460`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/edit_owner_controls_page.dart:81-95,110,295-321,433-436`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/reassign_owner_page.dart:120-134,144,393-420,550-553`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/control_owner_details_page.dart:401-416,443-457`

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: `class PendingAssignmentRow { String? policyId; List<String> controlIds; }`, `void commitPendingAssignmentRows({required List<PendingAssignmentRow> pendingRows, required List<AssigningControlEntity> target})`, `class GrcAssignmentChip extends StatelessWidget` with constructor `GrcAssignmentChip({Key? key, required String label, VoidCallback? onRemove})`.

- [ ] **Step 1: Create the shared row model + commit function**

Create `lib/features/grc/shared/models/pending_assignment_row.dart`:

```dart
/// A staged Policy + Controls picker row on a GRC champion/owner
/// edit/reassign page. Selections here are local UI state only until
/// [commitPendingAssignmentRows] copies them into the page's real
/// assignment list. Extracted because both control_champion and
/// control_owner declared this class, byte-for-byte, in two files each.
library;

import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';

class PendingAssignmentRow {
  String? policyId;
  List<String> controlIds = [];
}

/// Copies staged [pendingRows] into [target], skipping rows with no policy
/// or no selected controls, and skipping any policy+control pair already
/// present in [target] so committing twice never creates a duplicate.
void commitPendingAssignmentRows({
  required List<PendingAssignmentRow> pendingRows,
  required List<AssigningControlEntity> target,
}) {
  for (final row in pendingRows) {
    if (row.policyId == null || row.controlIds.isEmpty) continue;
    for (final cid in row.controlIds) {
      final exists = target
          .any((ac) => ac.policyId == row.policyId && ac.controlId == cid);
      if (!exists) {
        target.add(AssigningControlEntity(
          policyId: row.policyId!,
          controlId: cid,
        ));
      }
    }
  }
}
```

- [ ] **Step 2: Create the shared chip widget**

Create `lib/features/grc/shared/widgets/grc_assignment_chip.dart`:

```dart
/// A single Policy/Control assignment pill used across GRC champion/owner
/// pages. Read-only when [onRemove] is null (details pages); shows a
/// remove icon when [onRemove] is provided (edit/reassign pages).
/// Extracted because both variants were copy-pasted 3x each on the
/// champion side and 3x each on the owner side.
library;

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrcAssignmentChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;

  const GrcAssignmentChip({super.key, required this.label, this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (onRemove == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.remove_circle, color: Colors.red, size: 18),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Verify both new files analyze cleanly**

Run: `flutter analyze lib/features/grc/shared/models/pending_assignment_row.dart lib/features/grc/shared/widgets/grc_assignment_chip.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 4: Commit the new shared files**

```bash
git add lib/features/grc/shared/models/pending_assignment_row.dart lib/features/grc/shared/widgets/grc_assignment_chip.dart
git commit -m "feat(grc): add shared PendingAssignmentRow model and assignment chip widget"
```

- [ ] **Step 5: Replace the private `_PendingAssignmentRow` class in all 4 files**

In `edit_champion_controls_page.dart:433-436`, `reassign_champion_page.dart:549-552`, `edit_owner_controls_page.dart:433-436`, `reassign_owner_page.dart:550-553`, delete:

```dart
class _PendingAssignmentRow {
  String? policyId;
  List<String> controlIds = [];
}
```

Add import `package:demo_app/features/grc/shared/models/pending_assignment_row.dart`. Replace every type reference `_PendingAssignmentRow` with `PendingAssignmentRow` (e.g. `List<_PendingAssignmentRow> _pendingRows = []` → `List<PendingAssignmentRow> _pendingRows = []`) and every `_PendingAssignmentRow()` constructor call with `PendingAssignmentRow()`.

- [ ] **Step 6: Replace `_commitPendingRows` with the shared function in all 4 files**

In `edit_champion_controls_page.dart:82-96`, delete:
```dart
void _commitPendingRows() {
  for (final row in _pendingRows) {
    if (row.policyId == null || row.controlIds.isEmpty) continue;
    for (final cid in row.controlIds) {
      final exists = _tempControls
          .any((ac) => ac.policyId == row.policyId && ac.controlId == cid);
      if (!exists) {
        _tempControls.add(AssigningControlEntity(
          policyId: row.policyId!,
          controlId: cid,
        ));
      }
    }
  }
}
```
At the call site (line 111, inside `_save`), replace `_commitPendingRows();` with `commitPendingAssignmentRows(pendingRows: _pendingRows, target: _tempControls);`.

Repeat for `reassign_champion_page.dart:119-133` (call site line 143, target `_reassignedControls`), `edit_owner_controls_page.dart:81-95` (call site line 110, target `_tempControls`), `reassign_owner_page.dart:120-134` (call site line 144, target `_reassignedControls`) — same deletion, same shared-function call with each file's own target list name.

- [ ] **Step 7: Replace the 6 chip-rendering blocks with `GrcAssignmentChip`**

In `edit_champion_controls_page.dart:295-321` and `edit_owner_controls_page.dart:295-321`, replace the `Container(...)` block (padding 14.w/8.h, `borderRadius: BorderRadius.circular(24.r)`, `Text(cName, ...)` + remove `GestureDetector`) with:
```dart
return GrcAssignmentChip(
  label: cName,
  onRemove: () => _removeControl(index),
);
```

In `reassign_champion_page.dart:392-419` and `reassign_owner_page.dart:393-420`, replace the equivalent block with the same:
```dart
return GrcAssignmentChip(
  label: cName,
  onRemove: () => _removeControl(index),
);
```

In `control_champion_details_page.dart:404-419` (Policies section) and `control_owner_details_page.dart:401-416`, replace the read-only `Container(...)` block with:
```dart
return GrcAssignmentChip(label: pName);
```

In `control_champion_details_page.dart:446-460` (Controls section) and `control_owner_details_page.dart:443-457`, replace with:
```dart
return GrcAssignmentChip(label: cName);
```

Add the import `package:demo_app/features/grc/shared/widgets/grc_assignment_chip.dart` to all 6 files.

- [ ] **Step 8: Verify all 6 modified files analyze cleanly**

Run: `flutter analyze lib/features/grc/control_champion/ lib/features/grc/control_owner/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 9: Manual smoke check**

Open a Control Champion details page — confirm the Policy and Control pills still render identically (background color, border, text). Open Edit Champion Controls, add a policy/controls row, save — confirm the row is committed and the chip shows with a working remove (×) icon. Repeat for Reassign Champion, then repeat both checks on the Owner side.

- [ ] **Step 10: Commit**

```bash
git add lib/features/grc/control_champion/ lib/features/grc/control_owner/
git commit -m "refactor(grc): use shared PendingAssignmentRow and GrcAssignmentChip"
```

---

### Task 3: Shared Policy+Controls picker row widget

Unifies the ~50-60 line "pick a Policy, then pick Controls for it" row block that appears in the Add, Edit, and Reassign pages on both the champion and owner side (6 call sites total).

**Files:**
- Create: `lib/features/grc/shared/widgets/grc_policy_control_picker_row.dart`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/add_champion_page.dart:296-354`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/edit_champion_controls_page.dart:330-391`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/reassign_champion_page.dart:432-492`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/add_owner_page.dart:298-356`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/edit_owner_controls_page.dart:330-391`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/reassign_owner_page.dart:433-493`

**Interfaces:**
- Consumes: nothing new.
- Produces: `class GrcPolicyControlPickerRow extends StatelessWidget` — see full constructor in Step 1.

- [ ] **Step 1: Create the shared picker row widget**

Create `lib/features/grc/shared/widgets/grc_policy_control_picker_row.dart`:

```dart
/// A "pick a Policy, then pick Controls for it" row used on every GRC
/// champion/owner Add/Edit/Reassign page. Extracted because the same
/// ~55-line Row (CustomDropdown + CustomMultiSelectDropdown) was
/// copy-pasted across 6 files (3 pages x champion/owner), differing only
/// in labels, spacing, and whether a remove-row button is shown.
library;

import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GrcPolicyControlPickerRow extends StatelessWidget {
  final List<PolicyEntity> policies;
  final bool policiesEnabled;
  final String? policyId;
  final ValueChanged<String?> onPolicyChanged;
  final String? policyErrorText;

  final List<ControlEntity> availableControls;
  final bool controlsEnabled;
  final List<String> controlIds;
  final ValueChanged<List<String>> onControlsChanged;
  final String? controlsErrorText;
  final String controlsLabel;
  final String controlsHint;

  /// Horizontal gap between the two dropdowns, pre-scaled by the caller
  /// (e.g. `10.w`, `12.w`, `16.w`) — the three call sites disagreed on
  /// this value and none of them treated it as meaningful, so it stays a
  /// parameter rather than being hardcoded.
  final double spacing;

  /// When set, renders a trailing close (×) button that calls this — used
  /// by Add pages, which let the user remove an entire row.
  final VoidCallback? onRemoveRow;

  const GrcPolicyControlPickerRow({
    super.key,
    required this.policies,
    required this.policyId,
    required this.onPolicyChanged,
    required this.availableControls,
    required this.controlIds,
    required this.onControlsChanged,
    this.policiesEnabled = true,
    this.controlsEnabled = true,
    this.policyErrorText,
    this.controlsErrorText,
    this.controlsLabel = 'Control',
    this.controlsHint = 'Choose Control',
    this.spacing = 12,
    this.onRemoveRow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomDropdown<String>(
            label: 'Add Policy'.tr,
            hint: 'Choose Policy'.tr,
            enabled: policiesEnabled,
            items: policies
                .map((p) => DropdownItem<String>(
                      value: p.id,
                      label: context.isArabic ? p.policyNameAr : p.policyNameEn,
                    ))
                .toList(),
            value: policyId,
            onChanged: onPolicyChanged,
            fillColor: AppColors.background,
            required: false,
            errorText: policyErrorText,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: CustomMultiSelectDropdown<String>(
            label: controlsLabel.tr,
            hint: controlsHint.tr,
            enabled: controlsEnabled,
            items: availableControls
                .map((c) => MultiSelectDropdownItem<String>(
                      value: c.id,
                      label: context.isArabic ? c.controlsNameAr : c.controlsNameEn,
                    ))
                .toList(),
            values: controlIds,
            onChanged: onControlsChanged,
            fillColor: AppColors.background,
            required: false,
            errorText: controlsErrorText,
          ),
        ),
        if (onRemoveRow != null) ...[
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsets.only(top: 24.h),
            child: IconButton(
              icon: const Icon(Icons.close),
              color: AppColors.red,
              onPressed: onRemoveRow,
            ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: Verify the new widget analyzes cleanly**

Run: `flutter analyze lib/features/grc/shared/widgets/grc_policy_control_picker_row.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 3: Commit the new widget**

```bash
git add lib/features/grc/shared/widgets/grc_policy_control_picker_row.dart
git commit -m "feat(grc): add shared GrcPolicyControlPickerRow widget"
```

- [ ] **Step 4: Replace `_buildRow` in `add_champion_page.dart`**

Delete the `_buildRow(BuildContext context, _AssigningControlRow row, int index)` method (lines 296-354). At its single call site (inside the `List.generate` that builds `_rows`), replace with:

```dart
GrcPolicyControlPickerRow(
  policies: _policies,
  policiesEnabled: !_loadingPolicies,
  policyId: row.policyId,
  onPolicyChanged: (v) => _onPolicyChanged(row, v),
  policyErrorText:
      _submitted && row.policyId == null ? 'Required'.tr : null,
  availableControls: row.availableControls,
  controlsEnabled: row.policyId != null && !row.isLoadingControls,
  controlIds: row.controlIds,
  onControlsChanged: (v) => setState(() => row.controlIds = v),
  controlsErrorText:
      _submitted && row.controlIds.isEmpty ? 'Required'.tr : null,
  spacing: 10.w,
  onRemoveRow: _rows.length > 1 ? () => _removeRow(index) : null,
)
```

Add import `package:demo_app/features/grc/shared/widgets/grc_policy_control_picker_row.dart`. Since `controlsLabel`/`controlsHint` default to `'Control'`/`'Choose Control'` in the shared widget and add_champion_page's original used `'Control'.tr`/`'Choose Control'.tr`, leave those two params unset (defaults match).

- [ ] **Step 5: Replace `_buildRow` in `add_owner_page.dart`**

Same as Step 4, at lines 298-356, same replacement code (identical file, same field/method names per the research — confirmed byte-identical to add_champion_page.dart).

- [ ] **Step 6: Replace the inline row in `edit_champion_controls_page.dart`**

Delete the `List.generate(_pendingRows.length, ...)` body at lines 330-391 (the `Padding` > `Row` > two `Expanded` dropdowns). Replace with:

```dart
...List.generate(_pendingRows.length, (i) {
  final row = _pendingRows[i];
  final availableControlsForPolicy = row.policyId != null
      ? (widget.policyControls[row.policyId] ?? [])
      : <ControlEntity>[];

  return Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: GrcPolicyControlPickerRow(
      policies: widget.allPolicies,
      policyId: row.policyId,
      onPolicyChanged: (v) {
        setState(() {
          row.policyId = v;
          row.controlIds = [];
        });
      },
      availableControls: availableControlsForPolicy,
      controlsEnabled: row.policyId != null,
      controlIds: row.controlIds,
      onControlsChanged: (v) => setState(() => row.controlIds = v),
      controlsLabel: 'Add Controls',
      controlsHint: 'Choose Controls',
      spacing: 12.w,
    ),
  );
}),
```

Add the shared-widget import (skip if `grc_assignment_chip.dart`'s import was already added in Task 2 — this is a separate file, add it too).

- [ ] **Step 7: Replace the inline row in `edit_owner_controls_page.dart`**

Same as Step 6, at lines 330-391, identical replacement code.

- [ ] **Step 8: Replace the inline row in `reassign_champion_page.dart`**

Delete the `List.generate(_pendingRows.length, ...)` body at lines 432-492. Replace with:

```dart
...List.generate(_pendingRows.length, (i) {
  final row = _pendingRows[i];
  final availableControlsForPolicy = row.policyId != null
      ? (widget.policyControls[row.policyId] ?? [])
      : <ControlEntity>[];

  return Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: GrcPolicyControlPickerRow(
      policies: widget.allPolicies,
      policyId: row.policyId,
      onPolicyChanged: (v) {
        setState(() {
          row.policyId = v;
          row.controlIds = [];
        });
      },
      availableControls: availableControlsForPolicy,
      controlsEnabled: row.policyId != null,
      controlIds: row.controlIds,
      onControlsChanged: (v) => setState(() => row.controlIds = v),
      spacing: 16.w,
    ),
  );
}),
```

(`controlsLabel`/`controlsHint` left at their `'Control'`/`'Choose Control'` defaults, matching the original.)

- [ ] **Step 9: Replace the inline row in `reassign_owner_page.dart`**

Same as Step 8, at lines 433-493, identical replacement code.

- [ ] **Step 10: Verify all 6 modified files analyze cleanly**

Run: `flutter analyze lib/features/grc/control_champion/ lib/features/grc/control_owner/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 11: Manual smoke check**

On each of the 6 pages (Add/Edit/Reassign × Champion/Owner): pick a policy, confirm the control dropdown populates and filters to that policy's controls, pick 1+ controls, and (Add pages only) confirm the remove-row (×) button still removes that row. Submit once end-to-end on the Add Champion flow to confirm nothing broke.

- [ ] **Step 12: Commit**

```bash
git add lib/features/grc/control_champion/ lib/features/grc/control_owner/
git commit -m "refactor(grc): use shared GrcPolicyControlPickerRow across add/edit/reassign pages"
```

---

### Task 4: Default avatar constant + mock phone placeholder constant

**Files:**
- Modify: `lib/core/constants/app_assets.dart`
- Modify: `lib/features/grc/shared/helpers/grc_assignment_lookup.dart` (adds the mock-phone constant from Task 1's file)
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/control_champion_details_page.dart:174,176`
- Modify: `lib/features/grc/control_champion/presentation/ui/pages/reassign_champion_page.dart:231,244`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/control_owner_details_page.dart:173,175`
- Modify: `lib/features/grc/control_owner/presentation/ui/pages/reassign_owner_page.dart:232,245`
- Modify: `lib/features/grc/grc_request/presentation/ui/pages/grc_request_details_page.dart:149,161-165`

**Interfaces:**
- Produces: `AppAssets.defaultEmployeeAvatar` (String constant), `grcMockPhoneFallback` (top-level String constant in `grc_assignment_lookup.dart`).

- [ ] **Step 1: Add the avatar constant to `AppAssets`**

In `lib/core/constants/app_assets.dart`, inside `abstract class AppAssets { ... }`, add (near the existing `female`/`male` PNG constants at lines 104-105, but do not touch those — they're a different asset used elsewhere):

```dart
  /// Placeholder shown for an employee with no profile photo across GRC
  /// champion/owner/request detail pages. Was duplicated as a raw string
  /// literal in 5 files before this constant existed.
  static const String defaultEmployeeAvatar =
      'assets/icons_assets/main_icons_assets/assets_male.svg';
```

- [ ] **Step 2: Add the mock-phone constant to the shared helpers file**

In `lib/features/grc/shared/helpers/grc_assignment_lookup.dart` (created in Task 1), add at the top level, below the imports:

```dart
/// Placeholder phone number shown when an employee record has none set.
/// TODO(product): replace with a real empty-state (e.g. "No phone on file")
/// instead of fake digits — kept as a literal constant for now so there is
/// exactly one place to fix instead of four.
const String grcMockPhoneFallback = '2010258963';
```

- [ ] **Step 3: Verify both files analyze cleanly**

Run: `flutter analyze lib/core/constants/app_assets.dart lib/features/grc/shared/helpers/grc_assignment_lookup.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 4: Commit the two new constants**

```bash
git add lib/core/constants/app_assets.dart lib/features/grc/shared/helpers/grc_assignment_lookup.dart
git commit -m "feat(grc): add shared default-avatar and mock-phone constants"
```

- [ ] **Step 5: Replace the 4 champion/owner literal usages**

In `control_champion_details_page.dart`, line 174, replace:
```dart
: 'assets/icons_assets/main_icons_assets/assets_male.svg';
```
with:
```dart
: AppAssets.defaultEmployeeAvatar;
```
Line 176, replace:
```dart
final phone = employee?.mobilePhone?.phone ?? '2010258963'; // Mock placeholder if empty
```
with:
```dart
final phone = employee?.mobilePhone?.phone ?? grcMockPhoneFallback;
```

Repeat identically in `reassign_champion_page.dart:231,244`, `control_owner_details_page.dart:173,175`, `reassign_owner_page.dart:232,245`.

Add imports to all 4 files: `package:demo_app/core/constants/app_assets.dart` and `package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart` (the latter is likely already imported from Task 1 — skip if so).

- [ ] **Step 6: Replace the grc_request usages**

In `grc_request_details_page.dart`, line 149, replace the same avatar literal with `AppAssets.defaultEmployeeAvatar`, and at lines 161-165 replace the phone fallback (`?? '2010258963'`) with `?? grcMockPhoneFallback`. Add both imports (`app_assets.dart` and `grc_assignment_lookup.dart`) to this file.

- [ ] **Step 7: Verify all 5 modified files analyze cleanly**

Run: `flutter analyze lib/features/grc/control_champion/ lib/features/grc/control_owner/ lib/features/grc/grc_request/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 8: Manual smoke check**

Open an employee with no photo/phone on a Champion details page, a Reassign page, an Owner details page, and the GRC request details page — confirm the same fallback avatar and phone number render as before on all four.

- [ ] **Step 9: Commit**

```bash
git add lib/features/grc/control_champion/ lib/features/grc/control_owner/ lib/features/grc/grc_request/
git commit -m "refactor(grc): use shared avatar/phone-fallback constants instead of duplicated literals"
```

---

### Task 5: Firestore field-key static constants (8 models)

Replaces every hardcoded Firestore key literal in `toJson`/`fromJson` with a `static const`. Keys reused by 2+ models move to one shared class; keys unique to one model stay as private (`_`-prefixed) static consts on that model.

**Files:**
- Create: `lib/features/grc/shared/constants/grc_firestore_keys.dart`
- Modify: `lib/features/grc/control/data/models/control_model.dart`
- Modify: `lib/features/grc/control/data/models/assigning_control_model.dart`
- Modify: `lib/features/grc/control_champion/data/models/champion_model.dart`
- Modify: `lib/features/grc/control_owner/data/models/owner_model.dart`
- Modify: `lib/features/grc/module/data/models/grc_module_model.dart`
- Modify: `lib/features/grc/grc_request/data/models/grc_request_model.dart`
- Modify: `lib/features/grc/policy/data/models/policy_model.dart`

Note: `control_department_weight.dart`'s `DepartmentWeight.toJson`/`fromJson` (`'Department'`/`'Weight'`) is excluded — the research step confirmed those two keys are used nowhere else in the codebase as Firestore keys, and it's a small, self-contained 2-key file already at low risk; folding it in here would touch a domain-entity file for no shared-constant benefit. Leave it for the per-feature control cleanup plan.

**Interfaces:**
- Produces: `GrcFirestoreKeys` class with `policyId`, `moduleId`, `modifiers`, `modificationDate`, `assigningControls` static const String fields.

- [ ] **Step 1: Create the shared cross-model keys file**

Create `lib/features/grc/shared/constants/grc_firestore_keys.dart`:

```dart
/// Firestore document field keys reused verbatim by 2 or more GRC models.
/// Keys used by only one model stay as private static consts on that
/// model instead of here — see Code Quality Standards.md's Model Class
/// rule ("static constants for database keys, not hardcoded literals").
library;

abstract class GrcFirestoreKeys {
  /// Used by ControlModel, AssigningControlModel, PolicyModel.
  static const String policyId = 'Policy_ID';

  /// Used by GRCModuleModel, GrcRequestModel, PolicyModel.
  static const String moduleId = 'Module_ID';

  /// Used by ControlModel, ChampionModel, OwnerModel, GRCModuleModel,
  /// PolicyModel — every model with a change-history list of editors.
  static const String modifiers = 'Modifiers';

  /// Used by the same 5 models as [modifiers], always alongside it.
  static const String modificationDate = 'Modification_Date';

  /// Used by ChampionModel and OwnerModel for their assigning-controls
  /// history list.
  static const String assigningControls = 'Assigning_Controls';
}
```

- [ ] **Step 2: Verify the new file analyzes cleanly**

Run: `flutter analyze lib/features/grc/shared/constants/grc_firestore_keys.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/shared/constants/grc_firestore_keys.dart
git commit -m "feat(grc): add shared Firestore key constants for keys reused across models"
```

- [ ] **Step 4: Apply constants to `control_model.dart`**

Add the import `package:demo_app/features/grc/shared/constants/grc_firestore_keys.dart`. Inside `class ControlModel`, add these private static consts (near the top of the class, above the constructor):

```dart
  static const String _keyControlsId = 'Controls_ID';
  static const String _keyControlsNameEn = 'Controls_Name_En';
  static const String _keyControlsNameAr = 'Controls_Name_Ar';
  static const String _keyControlsNumberEn = 'Controls_Number_En';
  static const String _keyControlsNumberAr = 'Controls_Number_Ar';
  static const String _keyControlsDescriptionEn = 'Controls_Description_En';
  static const String _keyControlsDescriptionAr = 'Controls_Description_Ar';
  static const String _keyControlsDocumentEn = 'Controls_Document_En';
  static const String _keyControlsDocumentAr = 'Controls_Document_Ar';
  static const String _keyControlsWeight = 'Controls_Weight';
  static const String _keyControlsFrequency = 'Controls_Frequency';
  static const String _keyControlsStartDate = 'Controls_Start_Date';
  static const String _keyControlsEndDate = 'Controls_End_Date';
  static const String _keyControlsDepartments = 'Controls_Departments';
  static const String _keyControlsEqualWeights = 'Controls_Equal_Weights';
  static const String _keyControlsScore = 'Controls_Score';
  static const String _keyControlsStatus = 'Controls_Status';
```

Replace `toJson()` (lines 406-441) with:
```dart
  Map<String, dynamic> toJson() {
    return {
      GrcFirestoreKeys.policyId: policyId,
      _keyControlsId: id,
      _keyControlsNameEn: controlsNameEn,
      _keyControlsNameAr: controlsNameAr,
      _keyControlsNumberEn: controlsNumberEn,
      _keyControlsNumberAr: controlsNumberAr,
      _keyControlsDescriptionEn: controlsDescriptionEn,
      _keyControlsDescriptionAr: controlsDescriptionAr,
      _keyControlsDocumentEn: controlsDocumentEn,
      _keyControlsDocumentAr: controlsDocumentAr,
      _keyControlsWeight: controlsWeight,
      _keyControlsFrequency: frequency,
      _keyControlsStartDate:
          startDate.map((d) => _storageDateFormat.format(d)).toList(),
      _keyControlsEndDate:
          endDate.map((d) => _storageDateFormat.format(d)).toList(),
      // Firestore rejects arrays that directly contain other arrays, so each
      // revision's department list is wrapped in a map (List<List<...>>
      // would otherwise serialize as a nested array and the write would
      // throw). Each item is itself a {Department, Weight} map.
      _keyControlsDepartments: departments
          .map((rev) => {'Items': rev.map((d) => d.toJson()).toList()})
          .toList(),
      _keyControlsEqualWeights: equalWeights,
      _keyControlsScore: score,
      _keyControlsStatus: status,
      GrcFirestoreKeys.modificationDate:
          lastModifiedDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: editors,
    };
  }
```

Replace `fromJson()` (lines 452-494) with:
```dart
  factory ControlModel.fromJson(Map<String, dynamic> json) {
    final editorsRaw =
        List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []);
    return ControlModel(
      id: json[_keyControlsId] as String,
      policyId: json[GrcFirestoreKeys.policyId] as String,
      controlsNameEn: List<String>.from(json[_keyControlsNameEn] ?? []),
      controlsNameAr: List<String>.from(json[_keyControlsNameAr] ?? []),
      controlsNumberEn: List<String>.from(json[_keyControlsNumberEn] ?? []),
      controlsNumberAr: List<String>.from(json[_keyControlsNumberAr] ?? []),
      controlsDescriptionEn:
          List<String>.from(json[_keyControlsDescriptionEn] ?? []),
      controlsDescriptionAr:
          List<String>.from(json[_keyControlsDescriptionAr] ?? []),
      controlsDocumentEn:
          List<String?>.from(json[_keyControlsDocumentEn] ?? []),
      controlsDocumentAr:
          List<String?>.from(json[_keyControlsDocumentAr] ?? []),
      controlsWeight: (json[_keyControlsWeight] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      frequency: List<String>.from(json[_keyControlsFrequency] ?? []),
      startDate: (json[_keyControlsStartDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      endDate: (json[_keyControlsEndDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      departments: (json[_keyControlsDepartments] as List? ?? [])
          .map((rev) => ((rev as Map<String, dynamic>)['Items'] as List? ?? [])
              .map((item) =>
                  DepartmentWeight.fromJson(item as Map<String, dynamic>))
              .toList())
          .toList(),
      equalWeights: List<bool>.from(json[_keyControlsEqualWeights] ?? []),
      score: List<int>.from(json[_keyControlsScore] ?? []),
      status: json[_keyControlsStatus] != null
          ? List<String>.from(json[_keyControlsStatus])
          : List<String>.filled(
              editorsRaw.length, ControlStatus.unassigned.value),
      lastModifiedDate: (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      editors: editorsRaw,
    );
  }
```

- [ ] **Step 5: Verify and commit `control_model.dart`**

Run: `flutter analyze lib/features/grc/control/data/models/control_model.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/control/data/models/control_model.dart
git commit -m "refactor(grc): static Firestore key constants in ControlModel"
```

- [ ] **Step 6: Apply constants to `assigning_control_model.dart`**

Add the shared-keys import. Inside `class AssigningControlModel`, add:
```dart
  static const String _keyControlId = 'Control_ID';
  static const String _keyExpiresOn = 'Expires_On';
```

Replace `toJson()` (lines 17-24):
```dart
  Map<String, dynamic> toJson() {
    return {
      GrcFirestoreKeys.policyId: policyId,
      _keyControlId: controlId,
      _keyExpiresOn:
          expiresOn != null ? _assigningControlDateFormat.format(expiresOn!) : null,
    };
  }
```

Replace `fromJson()` (lines 26-34):
```dart
  factory AssigningControlModel.fromJson(Map<String, dynamic> json) {
    final expiresOnRaw = json[_keyExpiresOn] as String?;
    return AssigningControlModel(
      policyId: json[GrcFirestoreKeys.policyId] as String,
      controlId: json[_keyControlId] as String,
      expiresOn:
          expiresOnRaw != null ? _assigningControlDateFormat.parse(expiresOnRaw) : null,
    );
  }
```

- [ ] **Step 7: Verify and commit `assigning_control_model.dart`**

Run: `flutter analyze lib/features/grc/control/data/models/assigning_control_model.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/control/data/models/assigning_control_model.dart
git commit -m "refactor(grc): static Firestore key constants in AssigningControlModel"
```

- [ ] **Step 8: Apply constants to `champion_model.dart`**

Add the shared-keys import. Inside `class ChampionModel`, add:
```dart
  static const String _keyChampionEmail = 'Champion_Email';
  static const String _keyChampionStatus = 'Champion_Status';
```

Replace `toJson()` (lines 93-104):
```dart
  Map<String, dynamic> toJson() {
    return {
      _keyChampionEmail: championEmail,
      GrcFirestoreKeys.assigningControls: assigningControls
          .map((rev) => {'Items': rev.map((a) => a.toJson()).toList()})
          .toList(),
      _keyChampionStatus: status,
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: modifiers,
    };
  }
```

Replace `fromJson()` (lines 106-122):
```dart
  factory ChampionModel.fromJson(Map<String, dynamic> json) {
    return ChampionModel(
      championEmail: json[_keyChampionEmail] as String,
      assigningControls:
          (json[GrcFirestoreKeys.assigningControls] as List? ?? [])
              .map((rev) =>
                  ((rev as Map<String, dynamic>)['Items'] as List? ?? [])
                      .map((item) => AssigningControlModel.fromJson(
                          item as Map<String, dynamic>))
                      .toList())
              .toList(),
      status: List<String>.from(json[_keyChampionStatus] ?? []),
      modificationDate:
          (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
              .map((d) => _storageDateFormat.parse(d as String))
              .toList(),
      modifiers: List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []),
    );
  }
```

- [ ] **Step 9: Verify and commit `champion_model.dart`**

Run: `flutter analyze lib/features/grc/control_champion/data/models/champion_model.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/control_champion/data/models/champion_model.dart
git commit -m "refactor(grc): static Firestore key constants in ChampionModel"
```

- [ ] **Step 10: Apply constants to `owner_model.dart`**

Add the shared-keys import. Inside `class OwnerModel`, add:
```dart
  static const String _keyOwnerEmail = 'Owner_Email';
  static const String _keyOwnersStatus = 'Owners_Status';
  static const String _keyControlOwnersPermissions = 'Control_Owners_Permissions';
```

Replace `toJson()` (lines 137-150):
```dart
  Map<String, dynamic> toJson() {
    return {
      _keyOwnerEmail: ownerEmail,
      GrcFirestoreKeys.assigningControls: assigningControls
          .map((rev) => {'Items': rev.map((a) => a.toJson()).toList()})
          .toList(),
      _keyOwnersStatus: status,
      _keyControlOwnersPermissions:
          controlOwnerPermissions.map((perms) => {'Items': perms}).toList(),
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: modifiers,
    };
  }
```

Replace `fromJson()` (lines 152-172):
```dart
  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      ownerEmail: json[_keyOwnerEmail] as String,
      assigningControls:
          (json[GrcFirestoreKeys.assigningControls] as List? ?? [])
              .map((rev) =>
                  ((rev as Map<String, dynamic>)['Items'] as List? ?? [])
                      .map((item) => AssigningControlModel.fromJson(
                          item as Map<String, dynamic>))
                      .toList())
              .toList(),
      status: List<String>.from(json[_keyOwnersStatus] ?? []),
      controlOwnerPermissions:
          (json[_keyControlOwnersPermissions] as List? ?? [])
              .map((entry) => List<String>.from(
                  (entry as Map<String, dynamic>)['Items'] ?? []))
              .toList(),
      modificationDate:
          (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
              .map((d) => _storageDateFormat.parse(d as String))
              .toList(),
      modifiers: List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []),
    );
  }
```

- [ ] **Step 11: Verify and commit `owner_model.dart`**

Run: `flutter analyze lib/features/grc/control_owner/data/models/owner_model.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/control_owner/data/models/owner_model.dart
git commit -m "refactor(grc): static Firestore key constants in OwnerModel"
```

- [ ] **Step 12: Apply constants to `grc_module_model.dart`**

Add the shared-keys import. Inside `class GRCModuleModel`, add (this model's own id key is the literal `'Module_ID'`, the exact value `GrcFirestoreKeys.moduleId` already holds, so use that shared constant directly instead of adding a second, private one for the same string):
```dart
  static const String _keyModuleImage = 'Module_Image';
  static const String _keyModuleNameEn = 'Module_Name_En';
  static const String _keyModuleNameAr = 'Module_Name_Ar';
  static const String _keyModuleDescriptionEn = 'Module_Description_En';
  static const String _keyModuleDescriptionAr = 'Module_Description_Ar';
  static const String _keyModuleOwningDepartment = 'Module_Owning_Department';
  static const String _keyModuleActivationDate = 'Module_Activation_Date';
  static const String _keyModuleOwners = 'Module_Owners';
  static const String _keyStatus = 'Status';
```

Replace `toJson()` (lines 304-323):
```dart
  Map<String, dynamic> toJson() {
    return {
      GrcFirestoreKeys.moduleId: moduleId,
      _keyModuleImage: moduleImage,
      _keyModuleNameEn: moduleNameEn,
      _keyModuleNameAr: moduleNameAr,
      _keyModuleDescriptionEn: moduleDescriptionEn,
      _keyModuleDescriptionAr: moduleDescriptionAr,
      _keyModuleOwningDepartment: moduleOwningDepartment,
      _keyModuleActivationDate: moduleActivationDate
          .map((d) => _storageDateFormat.format(d))
          .toList(),
      // Already JSON-encoded strings — stored as List<String> in Firestore.
      _keyModuleOwners: moduleOwners,
      _keyStatus: status,
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: modifiers,
    };
  }
```

Replace `fromJson()` (lines 334-363):
```dart
  factory GRCModuleModel.fromJson(Map<String, dynamic> json) {
    final modifiersRaw =
        List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []);
    return GRCModuleModel(
      moduleId: json[GrcFirestoreKeys.moduleId] as String,
      moduleImage: List<String?>.from(json[_keyModuleImage] ?? []),
      moduleNameEn: List<String>.from(json[_keyModuleNameEn] ?? []),
      moduleNameAr: List<String>.from(json[_keyModuleNameAr] ?? []),
      moduleDescriptionEn:
          List<String>.from(json[_keyModuleDescriptionEn] ?? []),
      moduleDescriptionAr:
          List<String>.from(json[_keyModuleDescriptionAr] ?? []),
      moduleOwningDepartment:
          List<String>.from(json[_keyModuleOwningDepartment] ?? []),
      moduleActivationDate: (json[_keyModuleActivationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      // Stored as List<String> of JSON-encoded owner lists — keep as-is;
      // decoding happens in toEntity() when the latest value is needed.
      moduleOwners: List<String>.from(json[_keyModuleOwners] ?? []),
      status: json[_keyStatus] != null
          ? List<String>.from(json[_keyStatus])
          // Backwards-compat: documents written before the Status field was
          // added default to "Active".
          : List<String>.filled(modifiersRaw.length, 'Active'),
      modificationDate:
          (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
              .map((d) => _storageDateFormat.parse(d as String))
              .toList(),
      modifiers: modifiersRaw,
    );
  }
```

(The `'Active'` default-status literal stays for this task — Task 11 replaces it with an enum reference.)

- [ ] **Step 13: Verify and commit `grc_module_model.dart`**

Run: `flutter analyze lib/features/grc/module/data/models/grc_module_model.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/module/data/models/grc_module_model.dart
git commit -m "refactor(grc): static Firestore key constants in GRCModuleModel"
```

- [ ] **Step 14: Apply constants to `grc_request_model.dart`**

Add the shared-keys import. Inside `class GrcRequestModel`, add:
```dart
  static const String _keyRequestId = 'Request_ID';
  static const String _keyType = 'Type';
  static const String _keyStatus = 'Status';
  static const String _keyRequestedBy = 'Requested_By';
  static const String _keyRequestDate = 'Request_Date';
  static const String _keyNote = 'Note';
  static const String _keyRejectionReason = 'Rejection_Reason';
  static const String _keyDecidedBy = 'Decided_By';
  static const String _keyDecisionDate = 'Decision_Date';
  static const String _keyCurrentChampionEmail = 'Current_Champion_Email';
  static const String _keyNewChampionEmail = 'New_Champion_Email';
  static const String _keyCurrentOwnerEmail = 'Current_Owner_Email';
  static const String _keyNewOwnerEmail = 'New_Owner_Email';
  static const String _keyControls = 'Controls';
  static const String _keyStartDate = 'Start_Date';
  static const String _keyEndDate = 'End_Date';
  static const String _keyAppliedAt = 'Applied_At';
```

Replace `toJson()` (lines 64-86):
```dart
  Map<String, dynamic> toJson() {
    return {
      _keyRequestId: id,
      GrcFirestoreKeys.moduleId: moduleId,
      _keyType: type,
      _keyStatus: status,
      _keyRequestedBy: requestedBy,
      _keyRequestDate: _requestDateFormat.format(requestDate),
      _keyNote: note,
      _keyRejectionReason: rejectionReason,
      _keyDecidedBy: decidedBy,
      _keyDecisionDate:
          decisionDate != null ? _requestDateFormat.format(decisionDate!) : null,
      _keyCurrentChampionEmail: currentChampionEmail,
      _keyNewChampionEmail: newChampionEmail,
      _keyCurrentOwnerEmail: currentOwnerEmail,
      _keyNewOwnerEmail: newOwnerEmail,
      _keyControls: controls?.map((c) => c.toJson()).toList(),
      _keyStartDate: startDate != null ? _requestDateFormat.format(startDate!) : null,
      _keyEndDate: endDate != null ? _requestDateFormat.format(endDate!) : null,
      _keyAppliedAt: appliedAt != null ? _requestDateFormat.format(appliedAt!) : null,
    };
  }
```

Replace `fromJson()` (lines 88-116):
```dart
  factory GrcRequestModel.fromJson(Map<String, dynamic> json) {
    final decisionDateRaw = json[_keyDecisionDate] as String?;
    final startDateRaw = json[_keyStartDate] as String?;
    final endDateRaw = json[_keyEndDate] as String?;
    final appliedAtRaw = json[_keyAppliedAt] as String?;
    return GrcRequestModel(
      id: json[_keyRequestId] as String,
      moduleId: json[GrcFirestoreKeys.moduleId] as String,
      type: json[_keyType] as String,
      status: json[_keyStatus] as String,
      requestedBy: json[_keyRequestedBy] as String,
      requestDate: _requestDateFormat.parse(json[_keyRequestDate] as String),
      note: json[_keyNote] as String? ?? '',
      rejectionReason: json[_keyRejectionReason] as String?,
      decidedBy: json[_keyDecidedBy] as String?,
      decisionDate:
          decisionDateRaw != null ? _requestDateFormat.parse(decisionDateRaw) : null,
      currentChampionEmail: json[_keyCurrentChampionEmail] as String?,
      newChampionEmail: json[_keyNewChampionEmail] as String?,
      currentOwnerEmail: json[_keyCurrentOwnerEmail] as String?,
      newOwnerEmail: json[_keyNewOwnerEmail] as String?,
      controls: (json[_keyControls] as List?)
          ?.map((c) => AssigningControlModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      startDate: startDateRaw != null ? _requestDateFormat.parse(startDateRaw) : null,
      endDate: endDateRaw != null ? _requestDateFormat.parse(endDateRaw) : null,
      appliedAt: appliedAtRaw != null ? _requestDateFormat.parse(appliedAtRaw) : null,
    );
  }
```

- [ ] **Step 15: Verify and commit `grc_request_model.dart`**

Run: `flutter analyze lib/features/grc/grc_request/data/models/grc_request_model.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/grc_request/data/models/grc_request_model.dart
git commit -m "refactor(grc): static Firestore key constants in GrcRequestModel"
```

- [ ] **Step 16: Apply constants to `policy_model.dart`**

Add the shared-keys import. Inside `class PolicyModel`, add:
```dart
  static const String _keyPolicyId = 'Policy_ID';
  static const String _keyPolicyImage = 'Policy_Image';
  static const String _keyPolicyNameEn = 'Policy_Name_En';
  static const String _keyPolicyNameAr = 'Policy_Name_Ar';
  static const String _keyPolicyNumberEn = 'Policy_Number_En';
  static const String _keyPolicyNumberAr = 'Policy_Number_Ar';
  static const String _keyPolicyDescriptionEn = 'Policy_Description_En';
  static const String _keyPolicyDescriptionAr = 'Policy_Description_Ar';
  static const String _keyPolicyStartDate = 'Policy_Start_Date';
  static const String _keyPolicyEndDate = 'Policy_End_Date';
  static const String _keyPolicyWeight = 'Policy_Weight';
  static const String _keyPolicyDocumentEn = 'Policy_Document_En';
  static const String _keyPolicyDocumentAr = 'Policy_Document_Ar';
  static const String _keyPolicyStatus = 'Policy_Status';
```

Replace `toJson()` (lines 323-349):
```dart
  Map<String, dynamic> toJson() {
    return {
      GrcFirestoreKeys.moduleId: moduleId,
      _keyPolicyId: id,
      _keyPolicyImage: policyImage,
      _keyPolicyNameEn: policyNameEn,
      _keyPolicyNameAr: policyNameAr,
      _keyPolicyNumberEn: policyNumberEn,
      _keyPolicyNumberAr: policyNumberAr,
      _keyPolicyDescriptionEn: policyDescriptionEn,
      _keyPolicyDescriptionAr: policyDescriptionAr,
      _keyPolicyStartDate:
          startDate.map((d) => _storageDateFormat.format(d)).toList(),
      _keyPolicyEndDate:
          endDate.map((d) => _storageDateFormat.format(d)).toList(),
      _keyPolicyWeight: policyWeight,
      _keyPolicyDocumentEn: policyDocumentEn,
      _keyPolicyDocumentAr: policyDocumentAr,
      _keyPolicyStatus: status,
      GrcFirestoreKeys.modificationDate:
          lastModifiedDate.map((d) => _storageDateFormat.format(d)).toList(),
      GrcFirestoreKeys.modifiers: editors,
    };
  }
```

Replace `fromJson()` (lines 359-392):
```dart
  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    final editorsRaw =
        List<String>.from(json[GrcFirestoreKeys.modifiers] ?? []);
    return PolicyModel(
      id: json[_keyPolicyId] as String,
      moduleId: json[GrcFirestoreKeys.moduleId] as String,
      policyImage: List<String?>.from(json[_keyPolicyImage] ?? []),
      policyNameEn: List<String>.from(json[_keyPolicyNameEn] ?? []),
      policyNameAr: List<String>.from(json[_keyPolicyNameAr] ?? []),
      policyNumberEn: List<String>.from(json[_keyPolicyNumberEn] ?? []),
      policyNumberAr: List<String>.from(json[_keyPolicyNumberAr] ?? []),
      policyDescriptionEn:
          List<String>.from(json[_keyPolicyDescriptionEn] ?? []),
      policyDescriptionAr:
          List<String>.from(json[_keyPolicyDescriptionAr] ?? []),
      startDate: (json[_keyPolicyStartDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      endDate: (json[_keyPolicyEndDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      policyWeight: (json[_keyPolicyWeight] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      policyDocumentEn: List<String?>.from(json[_keyPolicyDocumentEn] ?? []),
      policyDocumentAr: List<String?>.from(json[_keyPolicyDocumentAr] ?? []),
      status: json[_keyPolicyStatus] != null
          ? List<String>.from(json[_keyPolicyStatus])
          : List<String>.filled(editorsRaw.length, PolicyStatus.draft.value),
      lastModifiedDate:
          (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
              .map((d) => _storageDateFormat.parse(d as String))
              .toList(),
      editors: editorsRaw,
    );
  }
```

- [ ] **Step 17: Verify and commit `policy_model.dart`**

Run: `flutter analyze lib/features/grc/policy/data/models/policy_model.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/policy/data/models/policy_model.dart
git commit -m "refactor(grc): static Firestore key constants in PolicyModel"
```

- [ ] **Step 18: Full-feature analyze + manual smoke check**

Run: `flutter analyze lib/features/grc/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

Manual check — **this task rewrites how every GRC document is read/written, so verify against live Firestore data, not just the analyzer**: open a Control, a Policy, a Champion, an Owner, a Module, and a GRC Request that already exist in the database (created before this change) and confirm each still loads correctly (no blank fields). Then create one new record of each of the 6 types and confirm it saves and reloads correctly. This confirms the new constants produce byte-identical keys to the old literals in both directions.

- [ ] **Step 19: Final commit for this task (if the smoke check needed any fixes)**

```bash
git add lib/features/grc/
git commit -m "fix(grc): correct any key mismatches found during Firestore smoke check"
```
(Skip this commit if Step 18 found no issues — nothing to commit.)

---

### Task 6: Shared weight-formatter for `control`

**Files:**
- Modify: `lib/features/grc/control/domain/entities/control_entity.dart`
- Modify: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart:82-86`
- Modify: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart:83-87`
- Modify: `lib/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_tab.dart:42-46`
- Modify: `lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart:310-316`
- Modify: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart:248-254`

**Interfaces:**
- Produces: top-level function `String formatControlWeight(double value)` in `control_entity.dart`.

- [ ] **Step 1: Add the shared formatter next to `ControlEntity`**

In `lib/features/grc/control/domain/entities/control_entity.dart`, add near the top of the file (outside the class, after the imports):

```dart
/// Renders a control weight without a trailing ".00" for whole numbers,
/// while still showing the decimals an equal split can produce (e.g.
/// 100/3 -> "33.33"). Extracted because 5 files in this feature each
/// reimplemented this exact formatting rule under 4 different names.
String formatControlWeight(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}
```

- [ ] **Step 2: Verify and commit the entity file**

Run: `flutter analyze lib/features/grc/control/domain/entities/control_entity.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/control/domain/entities/control_entity.dart
git commit -m "feat(grc): add shared formatControlWeight function"
```

- [ ] **Step 3: Replace `_format` in `control_weight_issue_row.dart`**

Delete (lines 82-86):
```dart
static String _format(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}
```
Add import `package:demo_app/features/grc/control/domain/entities/control_entity.dart` (skip if already imported). Replace every `_format(...)` call with `formatControlWeight(...)`.

- [ ] **Step 4: Replace `_formatWeight` in `control_weight_issue_page.dart`**

Delete (lines 83-87), same body as Step 3 under the name `_formatWeight`. Add the import if missing. Replace every `_formatWeight(...)` call with `formatControlWeight(...)`.

- [ ] **Step 5: Replace `_formatWeight` in `control_weight_history_tab.dart`**

Delete (lines 42-46), same body. Add the import if missing. Replace every `_formatWeight(...)` call with `formatControlWeight(...)`.

- [ ] **Step 6: Replace `_formatWeight` in `add_edit_control_page.dart`**

Delete (lines 310-316):
```dart
/// function name: [_formatWeight]
///
/// purpose: render a weight value without a trailing ".00" for whole
///          numbers, while still showing the decimals an equal split can
///          produce (e.g. 100/3 -> 33.33).
String _formatWeight(double value) =>
    value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
```
Add the import if missing. Replace every `_formatWeight(...)` call with `formatControlWeight(...)`.

- [ ] **Step 7: Replace `_formatEqualShare` in `control_bulk_row_form.dart`**

Delete (lines 248-254):
```dart
String _formatEqualShare(double share) =>
    share == share.roundToDouble() ? share.toStringAsFixed(0) : share.toStringAsFixed(2);
```
Add the import if missing. Replace the single `_formatEqualShare(...)` call with `formatControlWeight(...)`.

- [ ] **Step 8: Verify all 5 modified files analyze cleanly**

Run: `flutter analyze lib/features/grc/control/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 9: Manual smoke check**

Open a Control's Weight Issue page and its History tab, and the Add/Edit Control page's department-weight section, and the bulk-upload preview for a control whose departments don't split evenly (e.g. 3 departments, 100% total). Confirm every displayed weight still shows without a trailing `.00` for whole numbers and with 2 decimals otherwise (e.g. "33.33" for a 3-way equal split).

- [ ] **Step 10: Commit**

```bash
git add lib/features/grc/control/
git commit -m "refactor(grc): use shared formatControlWeight instead of 5 duplicated formatters"
```

---

### Task 7: `ApprovalStatus.color` extension

**Files:**
- Modify: `lib/core/enums/approval_status.dart`
- Modify: `lib/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart:145-169,222-244`
- Modify: `lib/features/grc/grc_request/presentation/ui/pages/grc_request_details_page.dart:467-484`

**Interfaces:**
- Produces: `Color get color` getter on the existing `GetApprovalStatusName` extension (or a new extension) on `ApprovalStatus`.

- [ ] **Step 1: Add the color getter to the existing extension**

In `lib/core/enums/approval_status.dart`, add the import `package:demo_app/core/theme/app_colors.dart` and `package:flutter/material.dart`, then add a `color` getter to the existing `GetApprovalStatusName` extension, alongside `getName`/`getOrderName`:

```dart
  /// Single source of truth for status->color across every GRC request
  /// screen — was previously re-derived independently in 3 places.
  Color get color {
    switch (this) {
      case ApprovalStatus.approved:
        return AppColors.green;
      case ApprovalStatus.rejected:
        return AppColors.red;
      case ApprovalStatus.canceled:
        return AppColors.colorGrey;
      case ApprovalStatus.pending:
      case ApprovalStatus.all:
        return AppColors.orange;
    }
  }
```

- [ ] **Step 2: Verify and commit**

Run: `flutter analyze lib/core/enums/approval_status.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/core/enums/approval_status.dart
git commit -m "feat(grc): add ApprovalStatus.color extension"
```

- [ ] **Step 3: Use it in `_statusPill`**

In `grc_requests_list_page.dart`, replace the `_statusPill` method (lines 145-169):
```dart
Widget _statusPill(ApprovalStatus status) {
  final color = status.color;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(status.getName,
        style: StyleText.fontSize12Weight500.copyWith(color: color)),
  );
}
```

- [ ] **Step 4: Use it in the `StatusChipItem` construction**

In the same file, lines 222-244, replace the hardcoded `labelColor: AppColors.green` / `AppColors.orange` / `AppColors.red` with `labelColor: ApprovalStatus.approved.color`, `labelColor: ApprovalStatus.pending.color`, `labelColor: ApprovalStatus.rejected.color` respectively (the `ApprovalStatus.all` item has no `labelColor` today — leave it unset).

- [ ] **Step 5: Use it in `grc_request_details_page.dart`**

Replace lines 467-484:
```dart
Container(
  padding: EdgeInsets.all(12.r),
  decoration: BoxDecoration(
    color: _request.status.color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8.r),
  ),
  child: Text(
    _request.status == ApprovalStatus.approved
        ? 'Approved'.tr
        : '${'Rejected'.tr}: ${_request.rejectionReason ?? ''}',
    style: StyleText.fontSize14Weight500.copyWith(
      color: _request.status.color,
    ),
  ),
),
```

- [ ] **Step 6: Verify all 3 modified files analyze cleanly**

Run: `flutter analyze lib/core/enums/approval_status.dart lib/features/grc/grc_request/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 7: Manual smoke check**

Open the GRC Requests list — confirm the status pills and filter chips show the same colors as before (green/orange/red/grey). Open an approved and a rejected request's details page — confirm the same background/text color as before.

- [ ] **Step 8: Commit**

```bash
git add lib/features/grc/grc_request/
git commit -m "refactor(grc): use ApprovalStatus.color instead of 3 duplicated color mappings"
```

---

### Task 8: `GrcRequestModel.copyWith` + repository simplification

**Files:**
- Modify: `lib/features/grc/grc_request/data/models/grc_request_model.dart`
- Modify: `lib/features/grc/grc_request/data/repository/grc_request_repository_impl.dart:126-284`

**Interfaces:**
- Produces: `GrcRequestModel copyWith({String? status, String? rejectionReason, String? decidedBy, DateTime? decisionDate, DateTime? appliedAt})` on `GrcRequestModel`.

- [ ] **Step 1: Add `copyWith` to `GrcRequestModel`**

In `grc_request_model.dart`, add after the constructor:

```dart
  /// Only the fields the request-decision flow ever changes are
  /// parameterized — every other field always passes through unchanged.
  /// Extracted because the repository previously re-typed all 17 fields
  /// by hand in 4 near-identical methods to change just 1-2 of them.
  GrcRequestModel copyWith({
    String? status,
    String? rejectionReason,
    String? decidedBy,
    DateTime? decisionDate,
    DateTime? appliedAt,
  }) {
    return GrcRequestModel(
      id: id,
      moduleId: moduleId,
      type: type,
      status: status ?? this.status,
      requestedBy: requestedBy,
      requestDate: requestDate,
      note: note,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      decidedBy: decidedBy ?? this.decidedBy,
      decisionDate: decisionDate ?? this.decisionDate,
      currentChampionEmail: currentChampionEmail,
      newChampionEmail: newChampionEmail,
      currentOwnerEmail: currentOwnerEmail,
      newOwnerEmail: newOwnerEmail,
      controls: controls,
      startDate: startDate,
      endDate: endDate,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
```

- [ ] **Step 2: Verify and commit**

Run: `flutter analyze lib/features/grc/grc_request/data/models/grc_request_model.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/grc_request/data/models/grc_request_model.dart
git commit -m "feat(grc): add GrcRequestModel.copyWith"
```

- [ ] **Step 3: Simplify `approveRequest`**

In `grc_request_repository_impl.dart`, replace `approveRequest` (lines 126-164):

```dart
  @override
  Future<Either<Failure, GrcRequestEntity>> approveRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = current.copyWith(
            status: ApprovalStatus.approved.name,
            decidedBy: decidedBy,
            decisionDate: DateTime.now(),
          );
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

- [ ] **Step 4: Simplify `rejectRequest`**

Replace `rejectRequest` (lines 166-205):
```dart
  @override
  Future<Either<Failure, GrcRequestEntity>> rejectRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
    required String reason,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = current.copyWith(
            status: ApprovalStatus.rejected.name,
            rejectionReason: reason,
            decidedBy: decidedBy,
            decisionDate: DateTime.now(),
          );
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

- [ ] **Step 5: Simplify `cancelRequest`**

Replace `cancelRequest` (lines 207-245):
```dart
  @override
  Future<Either<Failure, GrcRequestEntity>> cancelRequest({
    required String moduleId,
    required String requestId,
    required String canceledBy,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = current.copyWith(
            status: ApprovalStatus.canceled.name,
            decidedBy: canceledBy,
            decisionDate: DateTime.now(),
          );
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

Note: this drops the old code's redundant `rejectionReason: current.rejectionReason` passthrough — `copyWith` already keeps it unchanged when not passed, so the behavior is identical.

- [ ] **Step 6: Simplify `markApplied`**

Replace `markApplied` (lines 247-284):
```dart
  @override
  Future<Either<Failure, GrcRequestEntity>> markApplied({
    required String moduleId,
    required String requestId,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = current.copyWith(appliedAt: DateTime.now());
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

- [ ] **Step 7: Verify and manual smoke check**

Run: `flutter analyze lib/features/grc/grc_request/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

Manual check: on an existing pending request, Approve one, Reject another (with a reason), Cancel a third, and (if there's an "apply" action in the UI) mark one Applied. Confirm the status pill updates correctly each time and the decision fields (decided by, decision date, rejection reason) persist and reload correctly.

- [ ] **Step 8: Commit**

```bash
git add lib/features/grc/grc_request/
git commit -m "refactor(grc): use GrcRequestModel.copyWith in repository decision methods"
```

---

### Task 9: Merge `CreatePolicyStep1Buttons`/`CreatePolicyStep2Buttons`

**Files:**
- Create: `lib/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_buttons.dart`
- Delete: `lib/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step1_buttons.dart`
- Delete: `lib/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step2_buttons.dart`
- Modify: `lib/features/grc/policy/presentation/ui/pages/create_new_policy.dart:896-908`

**Interfaces:**
- Produces: `class CreatePolicyBackSaveButtons extends StatelessWidget` with constructor params `onBack`, `onSaveForLater` (required), plus one of `onPreview`+`previewEnabled` OR `onPublish` via a single `trailing` parameter — see Step 1 for the exact shape chosen.

- [ ] **Step 1: Create the merged widget**

Create `lib/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_buttons.dart`. The two widgets shared the entire left-hand Back+SaveForLater column byte-for-byte and differed only in the right-hand button (Preview, which can be disabled, vs. Publish, which can't) — so the merged widget takes the right-hand button as an explicit `trailingButton` slot instead of re-deriving two near-identical branches internally:

```dart
/// The Back + Save-For-Later button column shared by every step of the
/// Create Policy flow, plus a caller-supplied trailing action button.
/// Replaces CreatePolicyStep1Buttons and CreatePolicyStep2Buttons, which
/// were the same widget with a different trailing button hardcoded in.
library;

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreatePolicyBackSaveButtons extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSaveForLater;
  final Widget trailingButton;

  const CreatePolicyBackSaveButtons({
    super.key,
    required this.onBack,
    required this.onSaveForLater,
    required this.trailingButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            customButton(
              title: 'Back'.tr,
              function: onBack,
              height: 38.h,
              width: 150.w,
              color: AppColors.grey,
              textStyle:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            ),
            SizedBox(height: 10.h),
            customButton(
              title: 'Save For Later'.tr,
              function: onSaveForLater,
              height: 38.h,
              width: 150.w,
              color: AppColors.grey,
              textStyle:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            ),
          ],
        ),
        trailingButton,
      ],
    );
  }
}
```

- [ ] **Step 2: Verify and commit the new widget**

Run: `flutter analyze lib/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_buttons.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_buttons.dart
git commit -m "feat(grc): add merged CreatePolicyBackSaveButtons widget"
```

- [ ] **Step 3: Update the call site in `create_new_policy.dart`**

Replace the `case 1:` and `case 2:` branches inside `_buildButtons` (currently lines ~896-908):

```dart
    case 1:
      return CreatePolicyBackSaveButtons(
        onBack: () => setState(() => _step = 0),
        onSaveForLater: () => _handleSaveForLaterPressed(cubit),
        trailingButton: customButton(
          title: 'Preview'.tr,
          function: _canPreview ? _handlePreviewPressed : () {},
          height: 38.h,
          width: 150.w,
          color: _canPreview ? AppColors.primary : AppColors.colorGrey,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      );
    case 2:
      return CreatePolicyBackSaveButtons(
        onBack: () => setState(() => _step = 1),
        onSaveForLater: () => _handleSaveForLaterPressed(cubit),
        trailingButton: customButton(
          title: 'Publish'.tr,
          function: () => _handlePublishPressed(cubit),
          height: 38.h,
          width: 150.w,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      );
```

Replace the two old imports:
```dart
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step1_buttons.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step2_buttons.dart';
```
with:
```dart
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_buttons.dart';
```

- [ ] **Step 4: Delete the two old widget files**

```bash
git rm lib/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step1_buttons.dart
git rm lib/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step2_buttons.dart
```

- [ ] **Step 5: Verify and manual smoke check**

Run: `flutter analyze lib/features/grc/policy/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

Manual check: walk through Create Policy step 1 (Preview button — try it both disabled and enabled) and step 2 (Publish). Confirm both buttons look and behave exactly as before.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/create_new_policy.dart
git commit -m "refactor(grc): replace CreatePolicyStep1/2Buttons with merged CreatePolicyBackSaveButtons"
```

---

### Task 10: `ControlFrequency` enum

**Files:**
- Create: `lib/features/grc/control/domain/entities/control_frequency.dart`
- Modify: `lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart:1456-1479,1494-1517`
- Modify: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart:20-29,214-227`

**Interfaces:**
- Produces: `enum ControlFrequency { weekly, biWeekly, monthly, quarterly, semiAnnual, annually }` with `String get value` and `static ControlFrequency? fromString(String value)`.

Note: `ControlEntity.frequency` and `ControlModel.frequency` stay `String`/`List<String>` — this task only replaces the 3 duplicated *option lists* with one enum-derived source; it does not change the storage type, which is a larger, riskier change better left to the per-feature `control` cleanup plan.

- [ ] **Step 1: Create the enum**

Create `lib/features/grc/control/domain/entities/control_frequency.dart`:

```dart
/// The fixed set of Control review frequencies. Extracted because the
/// option list ('Weekly', 'Bi weekly', ...) was declared 3 times across
/// 2 files with no enum backing it, despite matching the pattern this
/// codebase already uses for ControlStatus/ChampionStatus/etc.
library;

enum ControlFrequency {
  weekly,
  biWeekly,
  monthly,
  quarterly,
  semiAnnual,
  annually;

  String get value {
    switch (this) {
      case ControlFrequency.weekly:
        return 'Weekly';
      case ControlFrequency.biWeekly:
        return 'Bi weekly';
      case ControlFrequency.monthly:
        return 'Monthly';
      case ControlFrequency.quarterly:
        return 'Quarterly';
      case ControlFrequency.semiAnnual:
        return 'Semi Annual';
      case ControlFrequency.annually:
        return 'Annually';
    }
  }

  /// Case-insensitive match against [value]; returns null (not a default)
  /// because, unlike a status, there is no sensible fallback frequency —
  /// callers must treat "no match" as a validation error.
  static ControlFrequency? fromString(String value) {
    for (final f in ControlFrequency.values) {
      if (f.value.toLowerCase() == value.toLowerCase()) return f;
    }
    return null;
  }

  static List<String> get allValues =>
      ControlFrequency.values.map((f) => f.value).toList();
}
```

- [ ] **Step 2: Verify and commit**

Run: `flutter analyze lib/features/grc/control/domain/entities/control_frequency.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/control/domain/entities/control_frequency.dart
git commit -m "feat(grc): add ControlFrequency enum"
```

- [ ] **Step 3: Replace both option lists in `add_edit_control_page.dart`**

At lines 1456-1479 (tablet layout), replace:
```dart
items: const [
  'Weekly',
  'Bi weekly',
  'Monthly',
  'Quarterly',
  'Semi Annual',
  'Annually',
]
    .map((d) => DropdownItem<String>(value: d, label: d))
    .toList(),
```
with:
```dart
items: ControlFrequency.allValues
    .map((d) => DropdownItem<String>(value: d, label: d))
    .toList(),
```

Apply the identical replacement at lines 1494-1517 (non-tablet layout).

Add the import `package:demo_app/features/grc/control/domain/entities/control_frequency.dart`.

- [ ] **Step 4: Replace the option list in `control_bulk_row_form.dart`**

Replace lines 20-29:
```dart
/// The Frequency sheet cell must case-insensitively match one of these;
/// the matching entry (canonical casing) is what gets persisted.
const List<String> controlBulkUploadFrequencyOptions = ControlFrequency.allValues;
```

Update the validation loop at lines 214-227 to use `ControlFrequency.fromString`:
```dart
    resolvedFrequency = null;
    if (!next.containsKey('frequency')) {
      final typed = frequencyController.text.trim();
      final matched = ControlFrequency.fromString(typed);
      if (matched != null) {
        resolvedFrequency = matched.value;
      } else {
        next['frequency'] =
            'Must be one of: ${controlBulkUploadFrequencyOptions.join(', ')}';
      }
    }
```

Add the import.

- [ ] **Step 5: Verify all modified files analyze cleanly**

Run: `flutter analyze lib/features/grc/control/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 6: Manual smoke check**

Open Add/Edit Control on both tablet and mobile widths — confirm the Frequency dropdown still shows all 6 options in the same order and text. Run a bulk upload with a frequency cell typed in a different case (e.g. "weekly") and confirm it still resolves and validates the same as before; try an invalid value and confirm the same validation error text appears.

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/control/
git commit -m "refactor(grc): use ControlFrequency enum instead of 3 duplicated option lists"
```

---

### Task 11: `GrcModuleStatus` enum

**Files:**
- Create: `lib/features/grc/module/domain/entities/grc_module_status.dart`
- Modify: `lib/features/grc/module/data/models/grc_module_model.dart` (the `_deriveStatus` function and its 4 call sites/literals from Tasks 5's edits)
- Modify: `lib/features/grc/module/domain/entities/grc_module_entity.dart:47,73`
- Modify: `lib/features/grc/module/data/data_source/grc_module_firebase_data_source.dart:97,150`
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_details_page.dart:113,164,179`
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_page.dart:115-126,153-164`

**Interfaces:**
- Consumes: `_keyStatus` constant pattern from Task 5 (this task only changes literal values, not the key names).
- Produces: `enum GrcModuleStatus { active, inactive, scheduled, removed }` with `String get value`, `static GrcModuleStatus fromString(String value)`.

- [ ] **Step 1: Create the enum**

Create `lib/features/grc/module/domain/entities/grc_module_status.dart`, matching the exact shape of `ChampionStatus`/`OwnerStatus`/`ControlStatus` already in this codebase:

```dart
/// The fixed set of GRC Module lifecycle states. Extracted because
/// 'Active'/'Inactive'/'Scheduled'/'Removed' were hardcoded string
/// literals across 5 files, unlike every sibling GRC feature (Champion,
/// Owner, Control, Policy), which already has an equivalent enum.
library;

enum GrcModuleStatus {
  active,
  inactive,
  scheduled,
  removed;

  String get value {
    switch (this) {
      case GrcModuleStatus.active:
        return 'Active';
      case GrcModuleStatus.inactive:
        return 'Inactive';
      case GrcModuleStatus.scheduled:
        return 'Scheduled';
      case GrcModuleStatus.removed:
        return 'Removed';
    }
  }

  static GrcModuleStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'inactive':
        return GrcModuleStatus.inactive;
      case 'scheduled':
        return GrcModuleStatus.scheduled;
      case 'removed':
        return GrcModuleStatus.removed;
      case 'active':
      default:
        return GrcModuleStatus.active;
    }
  }
}
```

- [ ] **Step 2: Verify and commit**

Run: `flutter analyze lib/features/grc/module/domain/entities/grc_module_status.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/module/domain/entities/grc_module_status.dart
git commit -m "feat(grc): add GrcModuleStatus enum"
```

- [ ] **Step 3: Use it in `grc_module_model.dart`**

Replace `_deriveStatus` (lines 44-54):
```dart
String _deriveStatus({
  required String requestedStatus,
  required DateTime activationDate,
}) {
  final requested = GrcModuleStatus.fromString(requestedStatus);
  if (requested == GrcModuleStatus.inactive ||
      requested == GrcModuleStatus.removed) {
    return requested.value;
  }
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return activationDate.isAfter(startOfToday)
      ? GrcModuleStatus.scheduled.value
      : GrcModuleStatus.active.value;
}
```

In `fromJson` (touched by Task 5 — locate the `status:` line that reads `_keyStatus`), replace the backwards-compat default:
```dart
      status: json[_keyStatus] != null
          ? List<String>.from(json[_keyStatus])
          : List<String>.filled(modifiersRaw.length, GrcModuleStatus.active.value),
```

In the `delete` call inside `grc_module_firebase_data_source.dart` (Step 5 below handles that file), the literal `'Removed'` passed to `copyWithUpdate(status: 'Removed', ...)` becomes `GrcModuleStatus.removed.value`.

Add the import `package:demo_app/features/grc/module/domain/entities/grc_module_status.dart` to `grc_module_model.dart`.

- [ ] **Step 4: Add an `isRemoved`-style typed getter to `grc_module_entity.dart`**

In `grc_module_entity.dart`, keep the `status` field as `final String status;` (line 47) — changing its type would ripple into every constructor call across the feature, which is out of scope for a dedup-only pass. Instead replace the existing `isRemoved` getter (line 73):
```dart
  bool get isRemoved => status == 'Removed';
```
with:
```dart
  bool get isRemoved => status == GrcModuleStatus.removed.value;
```

Add the import `package:demo_app/features/grc/module/domain/entities/grc_module_status.dart`.

- [ ] **Step 5: Use it in `grc_module_firebase_data_source.dart`**

Line 97:
```dart
      return models.where((m) => m.status.last != GrcModuleStatus.removed.value).toList();
```
Line 150 (inside `delete`):
```dart
      final deletedModel = current.copyWithUpdate(
        status: GrcModuleStatus.removed.value,
        modifierEmail: editorId,
      );
```
Add the import.

- [ ] **Step 6: Use it in `grc_details_page.dart`**

Line 113:
```dart
    _statusValue = entity.status == GrcModuleStatus.active.value;
```
Lines 164 and 179 (both currently `status: _statusValue ? 'Active' : 'Inactive',`):
```dart
      status: _statusValue
          ? GrcModuleStatus.active.value
          : GrcModuleStatus.inactive.value,
```
Add the import.

- [ ] **Step 7: Use it in `grc_page.dart`**

Replace the `_applyFilters` block (lines 115-126):
```dart
    if (_selectedStatus == GrcModuleStatus.active.value) {
      result = result
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.active.value)
          .toList();
    } else if (_selectedStatus == GrcModuleStatus.inactive.value) {
      result = result
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.inactive.value)
          .toList();
    } else if (_selectedStatus == GrcModuleStatus.scheduled.value) {
      result = result
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.scheduled.value)
          .toList();
    } else if (_selectedStatus == GrcModuleStatus.removed.value) {
      result = result.where((m) => m.isRemoved).toList();
    }
```
Replace `_countByStatus` (lines 153-164):
```dart
  Map<String, int> _countByStatus(List<GRCModuleEntity> modules) {
    return {
      'all': modules.length,
      GrcModuleStatus.active.value: modules
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.active.value)
          .length,
      GrcModuleStatus.inactive.value: modules
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.inactive.value)
          .length,
      GrcModuleStatus.scheduled.value: modules
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.scheduled.value)
          .length,
      GrcModuleStatus.removed.value:
          modules.where((m) => m.isRemoved).length,
    };
  }
```
Add the import. (`_selectedStatus` itself stays a plain `String` field driven by the filter-chip keys, which are these same `.value` strings — no type change needed there.)

- [ ] **Step 8: Verify all modified files analyze cleanly**

Run: `flutter analyze lib/features/grc/module/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 9: Manual smoke check**

On the GRC Module list, filter by each status chip (Active/Inactive/Scheduled/Removed) and confirm counts and filtered results are unchanged. Create a module with a future activation date and confirm it shows "Scheduled"; edit a module's status toggle and confirm Active/Inactive still saves and displays correctly; delete a module and confirm it moves to "Removed".

- [ ] **Step 10: Commit**

```bash
git add lib/features/grc/module/
git commit -m "refactor(grc): use GrcModuleStatus enum instead of hardcoded status strings"
```

---

### Task 12: `GRCModuleEntity` localized-name getter

**Files:**
- Modify: `lib/features/grc/module/domain/entities/grc_module_entity.dart`
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_page.dart:530-532`
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_details_page.dart:120-127`
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart:292-296`

**Interfaces:**
- Produces: `String localizedName({required bool isArabic})` on `GRCModuleEntity`.

- [ ] **Step 1: Add the getter to `GRCModuleEntity`**

In `grc_module_entity.dart`, add a method next to `isRemoved`:

```dart
  /// The module name in the caller's language. Extracted because
  /// `context.isArabic ? moduleNameAr : moduleNameEn` was repeated in 3
  /// presentation files instead of living once on the entity.
  String localizedName({required bool isArabic}) =>
      isArabic ? moduleNameAr : moduleNameEn;
```

- [ ] **Step 2: Verify and commit**

Run: `flutter analyze lib/features/grc/module/domain/entities/grc_module_entity.dart`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).
```bash
git add lib/features/grc/module/domain/entities/grc_module_entity.dart
git commit -m "feat(grc): add GRCModuleEntity.localizedName"
```

- [ ] **Step 3: Use it in `grc_page.dart`**

Replace lines 530-532:
```dart
      title: _capitalizeFirst(
        module.localizedName(isArabic: context.isArabic),
      ),
```

- [ ] **Step 4: Use it in `grc_details_page.dart`**

Replace the `_moduleDisplayName` method (lines 120-127):
```dart
  String _moduleDisplayName(BuildContext context) {
    if (widget.entity == null) return '';
    final name = widget.entity!.localizedName(isArabic: context.isArabic);
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }
```

- [ ] **Step 5: Use it in `grc_module_details_page.dart`**

Replace lines 292-296:
```dart
                    screensTitles: [
                      'GRC'.tr,
                      widget.module.localizedName(isArabic: context.isArabic),
                    ],
```

- [ ] **Step 6: Verify all modified files analyze cleanly**

Run: `flutter analyze lib/features/grc/module/`
Expected: no new issues at the lines you touched (per Global Constraints — this codebase already has pre-existing analyzer issues unrelated to this task; compare against a pre-task run of the same command if unsure).

- [ ] **Step 7: Manual smoke check**

Switch the app to Arabic, confirm module names on the list page, the details page title, and the module-details app bar all show the Arabic name; switch back to English and confirm they show the English name.

- [ ] **Step 8: Commit**

```bash
git add lib/features/grc/module/
git commit -m "refactor(grc): use GRCModuleEntity.localizedName instead of 3 duplicated ternaries"
```

---

## Self-Review Notes

- **Spec coverage:** All 9 cross-cutting duplication patterns from the audit that are safely scoped to "deduplicate without changing behavior" are covered: employee/control lookups (Task 1), pending-row model + chip widget (Task 2), policy/control picker row (Task 3), placeholder literals (Task 4), Firestore keys — all 6 features (Task 5), weight formatting (Task 6), status→color (Task 7), copyWith (Task 8), button widget merge (Task 9), Frequency enum (Task 10), Module status enum (Task 11), localized-name getter (Task 12).
- **Explicitly deferred, not forgotten:** `DepartmentWeight`'s 2 Firestore keys (low-value, single-file), the `add_champion_page`/`add_owner_page` per-row `isLoadingControls`/`availableControls` fields (kept as page-local state feeding the now-shared `GrcPolicyControlPickerRow` — merging that state itself would change more than the widget), and changing `ControlEntity.frequency`/`GRCModuleEntity.status` from `String` to their new enums (deferred because it ripples into every constructor call site — a good candidate for the later per-feature `control`/`module` plans once dedup is stable). These are noted so the next plan doesn't rediscover them as "new" findings.
- **Placeholder scan:** no TBD/TODO-as-filler, no "similar to Task N" shortcuts — every step embeds the literal code to delete and the literal code to add. The one intentional `TODO(product)` in Task 4 is a real, scoped product question (what to show for a missing phone number), not a plan gap.
- **Type consistency:** `PendingAssignmentRow`, `GrcAssignmentChip`, `GrcPolicyControlPickerRow`, `formatControlWeight`, `ApprovalStatus.color`, `GrcRequestModel.copyWith`, `ControlFrequency`, `GrcModuleStatus`, and `GRCModuleEntity.localizedName` are each defined exactly once (in the task that introduces them) and referenced by the identical name/signature in every later task and step that consumes them.

---

**Next plan:** once this is merged, follow up with one plan per feature (starting with `control_owner`, which had the most Critical findings) to work through the remaining architecture, function-size, error-handling, and localization findings from the audit — those are unaffected by this plan and can proceed independently against the now-deduplicated codebase.
