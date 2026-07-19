# Control Champions/Owners Picker on Add/Edit Control Page — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a user pick a Control's Champions and Owner directly from the Add/Edit Control page (edit mode only), department-filtered, with changes only persisted when the Control's own Save succeeds.

**Architecture:** Extend the existing `GrcOwnerSection`/`GrcOwnerCubit` (already used for Module Owner picking) with multi-department filtering, a red-remove-icon visual for already-selected people, and a configurable section title — then render it twice inside `AddEditControlPage` (once per role), tracking the live selection in local state and diffing it against each person's current `Assigning_Controls` when the Control save succeeds.

**Tech Stack:** Flutter, `flutter_bloc` (Cubit), existing `ChampionCubit`/`OwnerCubit` (already built), `PolicyCubit` (existing Control save flow).

## Global Constraints

- Sections render **only when `widget.existingControl != null`** (edit mode) — a new Control has no id to assign against.
- Removing someone's last Control leaves their status `Active` with an empty `Assigning_Controls` — never auto-set to `Removed`.
- The Module Owner picker's existing behavior/look must not change: every new `GrcOwnerSection`/`GrcOwnerCubit` param is additive with a default that reproduces today's behavior exactly.
- Assignee changes apply **after** the Control itself saves successfully (`PolicyControlActionSuccess`), never before, and never block that save.
- This sandbox has no `flutter` binary — verification is `dart analyze <path>` (no `flutter test`); this widget family has no existing unit tests, so none are added here (matches current coverage).

---

### Task 1: `GrcOwnerCubit` multi-department filtering

**Files:**
- Modify: `lib/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart`

**Interfaces:**
- Produces: `GrcOwnerCubit.loadOwners(context, {initialOwnerEmails, selectedDepartmentName, selectedDepartmentNames})`; `GrcOwnerCubit.filterByDepartments(List<String>? departmentNames)`; `filterByDepartment(String? departmentName)` (existing signature, now a thin wrapper). Task 2 depends on `filterByDepartments`.

- [ ] **Step 1: Replace the single-department field and `loadOwners`**

Replace:
```dart
  List<OwnerData> _allOwners = [];
  List<OwnerData> filteredOwners = [];
  String _searchQuery = '';
  String? _selectedDepartmentName;

  void loadOwners(
    BuildContext context, {
    List<String> initialOwnerEmails = const [],
    String? selectedDepartmentName,
  }) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return;
    final ctrl = Get.find<MainCoreEmployeeController>();
    final employees = ctrl.allEmployeesEntities ?? [];
    _allOwners = employees.map((e) {
      return OwnerData(
        id: e.id ?? '',
        name: EmployeeHelper.getEmployeeLocalizedName(employee: e, context: context),
        email: e.email ?? '',
        department: EmployeeHelper.getEmployeeLocalizeDepartment(employee: e, context: context),
        jobTitle: EmployeeHelper.getEmployeeLocalizedTitle(employee: e, context: context)?.toString() ?? '',
        photo: EmployeeHelper.getEmployeeImage(employee: e),
        isSelected: initialOwnerEmails.contains(e.email ?? ''),
      );
    }).toList();
    _selectedDepartmentName = selectedDepartmentName;
    _applyFilters();
  }
```

with:
```dart
  List<OwnerData> _allOwners = [];
  List<OwnerData> filteredOwners = [];
  String _searchQuery = '';
  List<String>? _selectedDepartmentNames;

  void loadOwners(
    BuildContext context, {
    List<String> initialOwnerEmails = const [],
    String? selectedDepartmentName,
    List<String>? selectedDepartmentNames,
  }) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return;
    final ctrl = Get.find<MainCoreEmployeeController>();
    final employees = ctrl.allEmployeesEntities ?? [];
    _allOwners = employees.map((e) {
      return OwnerData(
        id: e.id ?? '',
        name: EmployeeHelper.getEmployeeLocalizedName(employee: e, context: context),
        email: e.email ?? '',
        department: EmployeeHelper.getEmployeeLocalizeDepartment(employee: e, context: context),
        jobTitle: EmployeeHelper.getEmployeeLocalizedTitle(employee: e, context: context)?.toString() ?? '',
        photo: EmployeeHelper.getEmployeeImage(employee: e),
        isSelected: initialOwnerEmails.contains(e.email ?? ''),
      );
    }).toList();
    _selectedDepartmentNames = selectedDepartmentNames ??
        (selectedDepartmentName == null ? null : [selectedDepartmentName]);
    _applyFilters();
  }
```

- [ ] **Step 2: Replace `filterByDepartment` and `_applyFilters`'s department check**

Replace:
```dart
  /// Restricts the visible owners to those belonging to [departmentName].
  /// Pass null to clear the department filter and show everyone again.
  void filterByDepartment(String? departmentName) {
    if (_selectedDepartmentName == departmentName) return;
    _selectedDepartmentName = departmentName;
    _applyFilters();
  }

  void _applyFilters() {
    filteredOwners = _allOwners.where((o) {
      final matchesDepartment = _selectedDepartmentName == null ||
          _selectedDepartmentName!.isEmpty ||
          o.department == _selectedDepartmentName;
```

with:
```dart
  /// Restricts the visible owners to those belonging to [departmentName].
  /// Pass null to clear the department filter and show everyone again.
  void filterByDepartment(String? departmentName) {
    filterByDepartments(departmentName == null ? null : [departmentName]);
  }

  /// Restricts the visible owners to those belonging to any department in
  /// [departmentNames]. Pass null (or empty) to clear the filter and show
  /// everyone again. A Control can be scoped to several departments at
  /// once, unlike a Module (single department), hence the list form.
  void filterByDepartments(List<String>? departmentNames) {
    if (_listEquals(_selectedDepartmentNames, departmentNames)) return;
    _selectedDepartmentNames = departmentNames;
    _applyFilters();
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _applyFilters() {
    filteredOwners = _allOwners.where((o) {
      final matchesDepartment = _selectedDepartmentNames == null ||
          _selectedDepartmentNames!.isEmpty ||
          _selectedDepartmentNames!.contains(o.department);
```

- [ ] **Step 3: Verify**

Run: `dart analyze lib/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart`
Expected: no errors (pre-existing style-lint infos, if any, are fine).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart
git commit -m "feat(grc): add multi-department filtering to GrcOwnerCubit"
```

---

### Task 2: `GrcOwnerSection` red-remove-icon mode + configurable title

**Files:**
- Modify: `lib/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart`

**Interfaces:**
- Consumes: `GrcOwnerCubit.filterByDepartments` (Task 1).
- Produces: `GrcOwnerSection(..., selectedDepartmentNames: List<String>?, showRemoveIconWhenSelected: bool = false, sectionTitle: String = 'Module Owner')`. Task 3 depends on these three new params existing with these exact names/defaults.

- [ ] **Step 1: Add the three new fields and constructor params**

Replace:
```dart
  /// The department currently selected on the form. When set, only
  /// employees belonging to this department are shown as owner candidates.
  final String? selectedDepartmentName;

  final void Function(List<OwnerData> selected)? onOwnersChanged;

  /// When true, selecting one person clears any previous selection so at
  /// most one [OwnerData] is selected at a time (used by the Add
  /// Champion/Add Owner pages, where exactly one person is being assigned).
  final bool singleSelect;

  const GrcOwnerSection({
    super.key,
    this.isViewMode = false,
    this.initialOwnerEmails = const [],
    this.selectedDepartmentName,
    this.onOwnersChanged,
    this.singleSelect = false,
  });
```

with:
```dart
  /// The department currently selected on the form. When set, only
  /// employees belonging to this department are shown as owner candidates.
  final String? selectedDepartmentName;

  /// Same idea as [selectedDepartmentName] but for callers that can be
  /// scoped to several departments at once (e.g. a Control). When set,
  /// takes precedence over [selectedDepartmentName].
  final List<String>? selectedDepartmentNames;

  final void Function(List<OwnerData> selected)? onOwnersChanged;

  /// When true, selecting one person clears any previous selection so at
  /// most one [OwnerData] is selected at a time (used by the Add
  /// Champion/Add Owner pages, where exactly one person is being assigned).
  final bool singleSelect;

  /// When true, an already-selected person shows a red remove icon instead
  /// of a checked checkbox (used by the Control assignee pickers, where
  /// picking someone reads as "assign" and un-picking reads as "remove").
  /// Tapping the card still toggles selection either way.
  final bool showRemoveIconWhenSelected;

  /// The label shown above the picker. Defaults to the Module Owner
  /// picker's original hardcoded text so existing callers are unaffected.
  final String sectionTitle;

  const GrcOwnerSection({
    super.key,
    this.isViewMode = false,
    this.initialOwnerEmails = const [],
    this.selectedDepartmentName,
    this.selectedDepartmentNames,
    this.onOwnersChanged,
    this.singleSelect = false,
    this.showRemoveIconWhenSelected = false,
    this.sectionTitle = 'Module Owner',
  });
```

- [ ] **Step 2: Thread the department lists through `initState` and `didUpdateWidget`**

Replace:
```dart
  @override
  void initState() {
    super.initState();
    _cubit = GrcOwnerCubit();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cubit.loadOwners(
        context,
        initialOwnerEmails: widget.initialOwnerEmails,
        selectedDepartmentName: widget.selectedDepartmentName,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant GrcOwnerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDepartmentName != widget.selectedDepartmentName) {
      _cubit.filterByDepartment(widget.selectedDepartmentName);
    }
  }
```

with:
```dart
  @override
  void initState() {
    super.initState();
    _cubit = GrcOwnerCubit();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cubit.loadOwners(
        context,
        initialOwnerEmails: widget.initialOwnerEmails,
        selectedDepartmentName: widget.selectedDepartmentName,
        selectedDepartmentNames: widget.selectedDepartmentNames,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant GrcOwnerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDepartmentName != widget.selectedDepartmentName ||
        !_listEquals(
            oldWidget.selectedDepartmentNames, widget.selectedDepartmentNames)) {
      _cubit.filterByDepartments(
        widget.selectedDepartmentNames ??
            (widget.selectedDepartmentName == null
                ? null
                : [widget.selectedDepartmentName!]),
      );
    }
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
```

- [ ] **Step 3: Add the red-remove-icon trailing to all three `PersonChipCard` call sites**

In `_buildOwnerGrid`, the tablet 2-column branch has two `PersonChipCard`s (`left` and `owners[rightIdx]`) and the mobile branch has one (`owner`). Add a `trailing:` line to each, right after its `showCheckBox:` line.

Left card — replace:
```dart
                  child: PersonChipCard(
                    name: left.name,
                    subtitle1: left.department,
                    subtitle2: left.jobTitle,
                    avatar: _buildAvatar(left.photo),
                    isSelected: left.isSelected,
                    showCheckBox: !widget.isViewMode,
                    width: double.infinity,
                    backgroundColor: AppColors.background,
                    onTap: widget.isViewMode ? null : () => _onToggle(i * 2),
                  ),
```
with:
```dart
                  child: PersonChipCard(
                    name: left.name,
                    subtitle1: left.department,
                    subtitle2: left.jobTitle,
                    avatar: _buildAvatar(left.photo),
                    isSelected: left.isSelected,
                    showCheckBox: !widget.isViewMode,
                    trailing: (widget.showRemoveIconWhenSelected && left.isSelected)
                        ? Icon(Icons.remove_circle, color: AppColors.red, size: 20.sp)
                        : null,
                    width: double.infinity,
                    backgroundColor: AppColors.background,
                    onTap: widget.isViewMode ? null : () => _onToggle(i * 2),
                  ),
```

Right card — replace:
```dart
                    child: PersonChipCard(
                      name: owners[rightIdx].name,
                      subtitle1: owners[rightIdx].department,
                      subtitle2: owners[rightIdx].jobTitle,
                      avatar: _buildAvatar(owners[rightIdx].photo),
                      isSelected: owners[rightIdx].isSelected,
                      showCheckBox: !widget.isViewMode,
                      width: double.infinity,
                      backgroundColor: AppColors.background,
                      onTap:
                          widget.isViewMode ? null : () => _onToggle(rightIdx),
                    ),
```
with:
```dart
                    child: PersonChipCard(
                      name: owners[rightIdx].name,
                      subtitle1: owners[rightIdx].department,
                      subtitle2: owners[rightIdx].jobTitle,
                      avatar: _buildAvatar(owners[rightIdx].photo),
                      isSelected: owners[rightIdx].isSelected,
                      showCheckBox: !widget.isViewMode,
                      trailing: (widget.showRemoveIconWhenSelected &&
                              owners[rightIdx].isSelected)
                          ? Icon(Icons.remove_circle, color: AppColors.red, size: 20.sp)
                          : null,
                      width: double.infinity,
                      backgroundColor: AppColors.background,
                      onTap:
                          widget.isViewMode ? null : () => _onToggle(rightIdx),
                    ),
```

Mobile card — replace:
```dart
          child: PersonChipCard(
            name: owner.name,
            subtitle1: owner.department,
            subtitle2: owner.jobTitle,
            avatar: _buildAvatar(owner.photo),
            isSelected: owner.isSelected,
            showCheckBox: !widget.isViewMode,
            width: double.infinity,
            backgroundColor: AppColors.background,
            onTap: widget.isViewMode ? null : () => _onToggle(i),
          ),
```
with:
```dart
          child: PersonChipCard(
            name: owner.name,
            subtitle1: owner.department,
            subtitle2: owner.jobTitle,
            avatar: _buildAvatar(owner.photo),
            isSelected: owner.isSelected,
            showCheckBox: !widget.isViewMode,
            trailing: (widget.showRemoveIconWhenSelected && owner.isSelected)
                ? Icon(Icons.remove_circle, color: AppColors.red, size: 20.sp)
                : null,
            width: double.infinity,
            backgroundColor: AppColors.background,
            onTap: widget.isViewMode ? null : () => _onToggle(i),
          ),
```

- [ ] **Step 4: Use the configurable title**

Replace:
```dart
              Text(
                'Module Owner'.tr,
                style: AppTextStyles.font16BlackRegularCairo
                    .copyWith(fontSize: 14.sp),
              ),
```
with:
```dart
              Text(
                widget.sectionTitle.tr,
                style: AppTextStyles.font16BlackRegularCairo
                    .copyWith(fontSize: 14.sp),
              ),
```

- [ ] **Step 5: Verify**

Run: `dart analyze lib/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart`
Expected: no errors.

- [ ] **Step 6: Manual check**

Skipped — no Flutter binary in this sandbox. Note in the report that the Module Owner create/edit form should be spot-checked once Flutter is available, to confirm its look/behavior is unchanged (none of the new params are set there, so all new branches should be no-ops).

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart
git commit -m "feat(grc): add showRemoveIconWhenSelected, sectionTitle, multi-department filter to GrcOwnerSection"
```

---

### Task 3: `AddEditControlPage` — providers, state, and rendering the two sections

**Files:**
- Modify: `lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart`

**Interfaces:**
- Consumes: `GrcOwnerSection` (Task 2, `sectionTitle`/`showRemoveIconWhenSelected`/`selectedDepartmentNames`/`initialOwnerEmails`/`onOwnersChanged` params); `ChampionCubit`/`ChampionState`/`ChampionListLoaded`/`ChampionEntity` (already built: `lib/features/grc/control_champion/...`); `OwnerCubit`/`OwnerState`/`OwnerListLoaded`/`OwnerEntity` (already built: `lib/features/grc/control_owner/...`).
- Produces: `_currentChampionEmails`/`_currentOwnerEmails` state fields and `_alreadyAssignedChampionEmails`/`_alreadyAssignedOwnerEmails` helpers. Task 4 depends on these exact names.

- [ ] **Step 1: Add the new imports**

Add to the existing import block (alongside the other `grc/...` imports):
```dart
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
```

- [ ] **Step 2: Add the two selection-tracking state fields**

Right after the existing `bool _submitted = false;` field, add:
```dart
  List<String>? _currentChampionEmails;
  List<String>? _currentOwnerEmails;
```

- [ ] **Step 3: Add the "already assigned" and section-building helpers**

Add these methods to `_AddEditControlPageState` (e.g. right after `_buildDepartmentWeightRow`):
```dart
  /// Every Champion email whose Assigning_Controls already includes this
  /// exact {Policy, Control} pair. Only meaningful in edit mode.
  List<String> _alreadyAssignedChampionEmails(List<ChampionEntity> champions) {
    final controlId = widget.existingControl!.id;
    return champions
        .where((c) => c.assigningControls.any((a) =>
            a.policyId == widget.policyId && a.controlId == controlId))
        .map((c) => c.championEmail)
        .toList();
  }

  /// Every Owner email whose Assigning_Controls already includes this
  /// exact {Policy, Control} pair. Only meaningful in edit mode.
  List<String> _alreadyAssignedOwnerEmails(List<OwnerEntity> owners) {
    final controlId = widget.existingControl!.id;
    return owners
        .where((o) => o.assigningControls.any((a) =>
            a.policyId == widget.policyId && a.controlId == controlId))
        .map((o) => o.ownerEmail)
        .toList();
  }

  /// function name: [_buildAssigneesSections]
  ///
  /// purpose: render the "Control Champions" and "Control Owner" pickers
  ///          below the Departments section. Edit mode only — a new
  ///          Control has no id to assign against yet. Each picker starts
  ///          pre-selected with whoever is already assigned to this exact
  ///          {Policy, Control} pair, filtered live by the Control's
  ///          currently-selected departments, and reports every toggle back
  ///          via [_currentChampionEmails]/[_currentOwnerEmails] — nothing
  ///          is persisted here; see [_applyAssigneeChanges] (Task 4) for
  ///          that, which runs after the Control itself saves.
  Widget _buildAssigneesSections() {
    if (!_isEdit) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        BlocBuilder<ChampionCubit, ChampionState>(
          builder: (context, state) {
            if (state is! ChampionListLoaded) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return GrcOwnerSection(
              sectionTitle: 'Control Champions',
              initialOwnerEmails: _alreadyAssignedChampionEmails(state.champions),
              selectedDepartmentNames: _realSelectedDepartments,
              showRemoveIconWhenSelected: true,
              onOwnersChanged: (selected) => setState(() =>
                  _currentChampionEmails = selected.map((o) => o.email).toList()),
            );
          },
        ),
        SizedBox(height: 15.h),
        BlocBuilder<OwnerCubit, OwnerState>(
          builder: (context, state) {
            if (state is! OwnerListLoaded) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return GrcOwnerSection(
              sectionTitle: 'Control Owner',
              initialOwnerEmails: _alreadyAssignedOwnerEmails(state.owners),
              selectedDepartmentNames: _realSelectedDepartments,
              showRemoveIconWhenSelected: true,
              onOwnersChanged: (selected) => setState(() =>
                  _currentOwnerEmails = selected.map((o) => o.email).toList()),
            );
          },
        ),
      ],
    );
  }
```

- [ ] **Step 4: Provide `ChampionCubit`/`OwnerCubit` alongside `PolicyCubit`**

Replace:
```dart
    return BlocProvider(
      create: (_) => GetIt.instance<PolicyCubit>(),
      child: Builder(
```
with:
```dart
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(create: (_) => GetIt.instance<PolicyCubit>()),
        BlocProvider<ChampionCubit>(
          create: (_) => GetIt.instance<ChampionCubit>()
            ..getAllChampions(moduleId: widget.moduleId),
        ),
        BlocProvider<OwnerCubit>(
          create: (_) => GetIt.instance<OwnerCubit>()
            ..getAllOwners(moduleId: widget.moduleId),
        ),
      ],
      child: Builder(
```

- [ ] **Step 5: Render the sections after Departments**

Replace:
```dart
                                  SizedBox(height: 15.h),
                                  _buildDepartmentsSection(),
                                ],
                              ),
```
with:
```dart
                                  SizedBox(height: 15.h),
                                  _buildDepartmentsSection(),
                                  _buildAssigneesSections(),
                                ],
                              ),
```

- [ ] **Step 6: Verify**

Run: `dart analyze lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart`
Expected: no errors (pre-existing `unused_element` warnings for `_siblingsWeight`/`_validate` are fine — they predate this change).

- [ ] **Step 7: Manual check**

Skipped — no Flutter binary in this sandbox.

- [ ] **Step 8: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart
git commit -m "feat(grc): render Control Champions/Owner pickers on the edit-Control form"
```

---

### Task 4: `AddEditControlPage` — apply assignee changes on save

**Files:**
- Modify: `lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart`

**Interfaces:**
- Consumes: `_currentChampionEmails`/`_currentOwnerEmails`/`_alreadyAssignedChampionEmails`/`_alreadyAssignedOwnerEmails` (Task 3); `ChampionCubit.createChampion({required moduleId, required championEmail, required assigningControls})`, `ChampionCubit.updateChampion({required championEmail, required moduleId, assigningControls})`, `ChampionCubit.state` (`ChampionListLoaded`/`ChampionFailure`) — all already built in `lib/features/grc/control_champion/presentation/controller/champion_cubit.dart`. Same shape for `OwnerCubit`/`createOwner`/`updateOwner` in `lib/features/grc/control_owner/presentation/controller/owner_cubit.dart`. `AssigningControlEntity(policyId, controlId)` (already built, Task 1 of the original plan).

- [ ] **Step 1: Add the lookup helpers and diff-and-apply methods**

Add these methods to `_AddEditControlPageState` (e.g. right after `_alreadyAssignedOwnerEmails` from Task 3):
```dart
  ChampionEntity? _findChampion(List<ChampionEntity> all, String email) {
    for (final c in all) {
      if (c.championEmail == email) return c;
    }
    return null;
  }

  OwnerEntity? _findOwner(List<OwnerEntity> all, String email) {
    for (final o in all) {
      if (o.ownerEmail == email) return o;
    }
    return null;
  }

  /// function name: [_applyChampionDiff]
  ///
  /// purpose: reconcile [selected] (the picker's current selection) against
  ///          [alreadyAssigned] (what was true when the page opened) by
  ///          appending/removing this {Policy, Control} pair on exactly the
  ///          people whose selection state actually changed. Every call is
  ///          awaited sequentially — at most a handful of people per save,
  ///          simplicity over throughput.
  ///
  /// return type: [Future<bool>] - false if any individual update/create failed
  Future<bool> _applyChampionDiff({
    required ChampionCubit cubit,
    required List<ChampionEntity> allChampions,
    required List<String> alreadyAssigned,
    required List<String> selected,
    required String controlId,
  }) async {
    var success = true;
    final added = selected.where((e) => !alreadyAssigned.contains(e));
    final removed = alreadyAssigned.where((e) => !selected.contains(e));

    for (final email in added) {
      final existing = _findChampion(allChampions, email);
      if (existing != null) {
        await cubit.updateChampion(
          championEmail: email,
          moduleId: widget.moduleId,
          assigningControls: [
            ...existing.assigningControls,
            AssigningControlEntity(policyId: widget.policyId, controlId: controlId),
          ],
        );
      } else {
        await cubit.createChampion(
          moduleId: widget.moduleId,
          championEmail: email,
          assigningControls: [
            AssigningControlEntity(policyId: widget.policyId, controlId: controlId),
          ],
        );
      }
      if (cubit.state is ChampionFailure) success = false;
    }

    for (final email in removed) {
      final existing = _findChampion(allChampions, email);
      if (existing == null) continue;
      await cubit.updateChampion(
        championEmail: email,
        moduleId: widget.moduleId,
        assigningControls: existing.assigningControls
            .where((a) => !(a.policyId == widget.policyId && a.controlId == controlId))
            .toList(),
      );
      if (cubit.state is ChampionFailure) success = false;
    }

    return success;
  }

  /// Mirrors [_applyChampionDiff] for Control Owners.
  Future<bool> _applyOwnerDiff({
    required OwnerCubit cubit,
    required List<OwnerEntity> allOwners,
    required List<String> alreadyAssigned,
    required List<String> selected,
    required String controlId,
  }) async {
    var success = true;
    final added = selected.where((e) => !alreadyAssigned.contains(e));
    final removed = alreadyAssigned.where((e) => !selected.contains(e));

    for (final email in added) {
      final existing = _findOwner(allOwners, email);
      if (existing != null) {
        await cubit.updateOwner(
          ownerEmail: email,
          moduleId: widget.moduleId,
          assigningControls: [
            ...existing.assigningControls,
            AssigningControlEntity(policyId: widget.policyId, controlId: controlId),
          ],
        );
      } else {
        await cubit.createOwner(
          moduleId: widget.moduleId,
          ownerEmail: email,
          assigningControls: [
            AssigningControlEntity(policyId: widget.policyId, controlId: controlId),
          ],
        );
      }
      if (cubit.state is OwnerFailure) success = false;
    }

    for (final email in removed) {
      final existing = _findOwner(allOwners, email);
      if (existing == null) continue;
      await cubit.updateOwner(
        ownerEmail: email,
        moduleId: widget.moduleId,
        assigningControls: existing.assigningControls
            .where((a) => !(a.policyId == widget.policyId && a.controlId == controlId))
            .toList(),
      );
      if (cubit.state is OwnerFailure) success = false;
    }

    return success;
  }

  /// function name: [_applyAssigneeChanges]
  ///
  /// purpose: called once the Control itself has already saved
  ///          successfully. Reads each Cubit's already-loaded state
  ///          directly (no re-fetch — the page loaded it once on open and
  ///          never refreshes it), recomputes "already assigned" the same
  ///          way [_buildAssigneesSections] did, and diffs it against
  ///          whatever the user last toggled. If a Cubit never finished
  ///          loading, that side is skipped entirely rather than guessed at.
  Future<void> _applyAssigneeChanges(BuildContext context) async {
    final controlId = widget.existingControl!.id;
    final championCubit = context.read<ChampionCubit>();
    final ownerCubit = context.read<OwnerCubit>();
    var hadFailure = false;

    final championState = championCubit.state;
    if (championState is ChampionListLoaded) {
      final alreadyAssigned = _alreadyAssignedChampionEmails(championState.champions);
      final selected = _currentChampionEmails ?? alreadyAssigned;
      final ok = await _applyChampionDiff(
        cubit: championCubit,
        allChampions: championState.champions,
        alreadyAssigned: alreadyAssigned,
        selected: selected,
        controlId: controlId,
      );
      if (!ok) hadFailure = true;
    }

    final ownerState = ownerCubit.state;
    if (ownerState is OwnerListLoaded) {
      final alreadyAssigned = _alreadyAssignedOwnerEmails(ownerState.owners);
      final selected = _currentOwnerEmails ?? alreadyAssigned;
      final ok = await _applyOwnerDiff(
        cubit: ownerCubit,
        allOwners: ownerState.owners,
        alreadyAssigned: alreadyAssigned,
        selected: selected,
        controlId: controlId,
      );
      if (!ok) hadFailure = true;
    }

    if (hadFailure && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Some champion/owner assignments couldn't be saved.".tr),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }
```

- [ ] **Step 2: Wire it into `_onStateChange`, before the success dialog/pop**

Replace:
```dart
  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyControlActionSuccess) {
      showSuccessDialog(
        context: context,
        title: _isEdit ? 'Control Updated'.tr : 'Control Created'.tr,
        subtitle: _isEdit
            ? 'You successfully updated this control.'.tr
            : 'You successfully created this control.'.tr,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
      );
    }
  }
```
with:
```dart
  Future<void> _onStateChange(BuildContext context, PolicyState state) async {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyControlActionSuccess) {
      if (_isEdit) {
        await _applyAssigneeChanges(context);
      }
      if (!context.mounted) return;
      showSuccessDialog(
        context: context,
        title: _isEdit ? 'Control Updated'.tr : 'Control Created'.tr,
        subtitle: _isEdit
            ? 'You successfully updated this control.'.tr
            : 'You successfully created this control.'.tr,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
      );
    }
  }
```

(`BlocListener<PolicyCubit, PolicyState>(listener: _onStateChange, ...)` accepts an `async` function here without any signature change at the call site — `flutter_bloc`'s listener type is `void Function(BuildContext, S)`, and Dart allows a `Future<void>`-returning function to satisfy that, same as `onPressed: () async { ... }` elsewhere in Flutter.)

- [ ] **Step 3: Verify**

Run: `dart analyze lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart`
Expected: no errors.

- [ ] **Step 4: Manual check**

Skipped — no Flutter binary in this sandbox. Note in the report: once Flutter is available, open an existing Control that already has a Champion and an Owner, confirm both show with the red remove icon; toggle one removal and one new addition in each section; change the Control's Departments and confirm the candidate list re-filters live; Save; reopen the same Control and confirm the new assignment persisted; separately open the Module's Control Champions/Owners tab and confirm the same change shows there.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/add_edit_control_page.dart
git commit -m "feat(grc): apply Control Champion/Owner assignee changes on Control save"
```

---

## Self-Review Notes

- **Spec coverage:** Extension 1 (multi-department filtering) → Task 1. Extension 2 (red-remove-icon + configurable title) → Task 2. `AddEditControlPage` integration (providers, computing "already assigned", tracking live selection, rendering, edit-mode-only gating, department-live-refiltering) → Task 3. "Applying on save" (diff algorithm, sequential awaits, failure snackbar, skip-if-not-loaded) → Task 4. Out-of-scope items (create-mode, Module-level tabs, `Control_Owners_Permissions`, extra confirmation) are untouched by every task above.
- **Type consistency checked:** Task 3's `_buildAssigneesSections` reads `ChampionListLoaded`/`OwnerListLoaded` and calls `_alreadyAssignedChampionEmails`/`_alreadyAssignedOwnerEmails`, both defined in the same task with matching signatures; Task 4's `_applyAssigneeChanges` calls `_applyChampionDiff`/`_applyOwnerDiff` with named params matching their own definitions exactly, and reads `_currentChampionEmails`/`_currentOwnerEmails` exactly as named in Task 3. `ChampionCubit.updateChampion`/`createChampion` and `OwnerCubit.updateOwner`/`createOwner` param names (`championEmail`/`ownerEmail`, `moduleId`, `assigningControls`) match their existing definitions in `champion_cubit.dart`/`owner_cubit.dart` from the earlier Control Champions & Owners plan.
- **Placeholder scan:** no TBD/TODO; every step shows the exact before/after code (this plan only modifies existing files, so every step is a precise replace, not a fresh-file write).
