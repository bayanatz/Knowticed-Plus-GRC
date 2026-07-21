# Control Details Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a read-only `ControlDetailsPage` (breadcrumb, Edit/Delete, Score badge, placeholder "Previous Control Owners" button, description/owner/documents/frequency-weight-dates/department-weight-chips card), opened by tapping a Control card on the Policy Details page — replacing today's behavior of jumping straight into `AddEditControlPage`.

**Architecture:** Flutter + flutter_bloc. Everything this plan needs already exists and is DI-wired (`PolicyCubit.deleteControl/getAllControls`, `OwnerCubit.getAllOwners`, both factory-registered in `grc_get_it.dart`) — this is a UI-only plan: one new page, one small widget generalization, and one navigation wiring change. `ControlDetailsPage` owns its own `PolicyCubit`/`OwnerCubit` instances via `BlocProvider(create: (_) => GetIt.instance<...>())`, matching `PolicyDetailsPage`'s/`AddEditControlPage`'s existing pattern. There is no single-Control fetch use case, so after an edit the page re-runs `getAllControls` and picks its own entity back out by `id` — the same refresh shape the Policy Details page already uses.

**Tech Stack:** Flutter, flutter_bloc, get_it, flutter_screenutil, intl.

## Global Constraints

- No new automated tests: this plan is pure UI composition and wiring over already-tested cubit methods (no new business logic to unit-test), matching the design spec's own Testing section. Verification is `dart analyze <file>` (no Flutter binary in this sandbox — same signal) after each task, plus a manual walkthrough once a Flutter environment is available.
- Follow existing patterns exactly: `PageRouteBuilder` + `FadeTransition` (300ms) for navigation, `showConfirmDialog`/`showSuccessDialog`/`showLoadingIndicator`/`hideLoadingIndicator` for dialogs/loading, `context.isArabic` for localization, `.tr` on every user-facing string, `CardStyles.label`/`CardStyles.value` for label/value text pairs.
- Do not modify the domain/data layers, `grc_get_it.dart`, or `AddEditControlPage` itself — everything needed is already implemented and registered.
- The "Previous Control Owners" button is a placeholder only (`function: () {}`) — no history feature is built in this plan.
- Commit after each task with `git add <files>` + a descriptive message (no `--no-verify`).

---

### Task 1: Generalize `GrcOwnerBadge`'s label

**Files:**
- Modify: `lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart`

**Interfaces:**
- Produces: `GrcOwnerBadge({List<String> ownerEmails, String label = 'Module Owner:', void Function(OwnerData owner)? onMessageTap})` — existing call sites (which don't pass `label`) render identically to before.
- Consumes: nothing new.

- [ ] **Step 1: Add the `label` field and constructor parameter**

In `grc_owner_badge.dart`, replace:

```dart
class GrcOwnerBadge extends StatefulWidget {
  /// Emails of owners already assigned to the module. Only the first
  /// matched owner is displayed.
  final List<String> ownerEmails;

  /// Called with the displayed owner when the "Message" button is tapped.
  final void Function(OwnerData owner)? onMessageTap;

  const GrcOwnerBadge({
    super.key,
    this.ownerEmails = const [],
    this.onMessageTap,
  });
```

with:

```dart
class GrcOwnerBadge extends StatefulWidget {
  /// Emails of owners already assigned to the module (or Control — see
  /// [label]). Only the first matched owner is displayed.
  final List<String> ownerEmails;

  /// Leading label text, e.g. "Module Owner:" or "Control Owner:".
  final String label;

  /// Called with the displayed owner when the "Message" button is tapped.
  final void Function(OwnerData owner)? onMessageTap;

  const GrcOwnerBadge({
    super.key,
    this.ownerEmails = const [],
    this.label = 'Module Owner:',
    this.onMessageTap,
  });
```

- [ ] **Step 2: Use the new field instead of the hardcoded string**

Replace:

```dart
              Text(
                'Module Owner:'.tr,
                style: AppTextStyles.font16BlackRegularCairo.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText,
                ),
              ),
```

with:

```dart
              Text(
                widget.label.tr,
                style: AppTextStyles.font16BlackRegularCairo.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText,
                ),
              ),
```

- [ ] **Step 3: Verify with `dart analyze`**

Run: `dart analyze lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart`
Expected: no new errors (pre-existing warnings elsewhere in the repo are unrelated and fine).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart
git commit -m "feat(grc): generalize GrcOwnerBadge's label for reuse by Control Owner"
```

---

### Task 2: Create `ControlDetailsPage`

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_details_page.dart`

**Interfaces:**
- Consumes: `PolicyCubit` (`deleteControl({id, moduleId, policyId})`, `getAllControls({moduleId, policyId})` emitting `PolicyControlsListLoaded(controls)`/`PolicyControlDeleted(id)`/`PolicyLoading`/`PolicyFailure`, all already defined in `policy_cubit.dart`); `OwnerCubit` (`getAllOwners({required moduleId})` emitting `OwnerListLoaded(owners)`, already defined in `owner_cubit.dart`); `OwnerEntity` (`ownerEmail`, `assigningControls: List<AssigningControlEntity>`, from `owner_entity.dart`); `AddEditControlPage({required moduleId, required policyId, required siblingControls, ControlEntity? existingControl})` (existing, unchanged); `GrcActionButtons({onEditTap, onDeleteTap, deleteDialogTitle, deleteDialogSubtitle})` (existing, unchanged); `GrcOwnerBadge({ownerEmails, label, onMessageTap})` (from Task 1); `ControlEntity` fields `id, policyId, controlsNameEn/Ar, controlsNumberEn/Ar, controlsDescriptionEn/Ar, controlsDocumentEn/Ar, controlsWeight, frequency, startDate, endDate, departments: List<DepartmentWeight>, score, lastModifiedDate` (existing, unchanged); `DepartmentWeight` fields `department: String, weight: double` (existing, unchanged); `GRCModuleEntity.moduleId/moduleNameEn/moduleNameAr`, `PolicyEntity.id/policyNameEn/policyNameAr` (existing, unchanged).
- Produces: `ControlDetailsPage({required GRCModuleEntity module, required PolicyEntity policy, required ControlEntity control, required List<ControlEntity> siblingControls})` — a `StatelessWidget`. Pops with `true` when the Control was deleted (nothing otherwise); Task 3 relies on this constructor shape and on "always refresh on return" rather than checking the popped value.

- [ ] **Step 1: Write the new page file**

Create `lib/features/grc/control/presentation/ui/pages/control_details_page.dart`:

```dart
/// Module: GRC Policy Management
/// Description: Read-only details page for a single Control — view its
///              fields, open it for editing, or delete it. Editing is a
///              separate full-page route, AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter_bloc, PolicyCubit, OwnerCubit, ControlEntity,
///               GRCModuleEntity, PolicyEntity, get_it
/// Revision History: 2026-07-21 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_details_page.dart
/// Purpose: Contains ControlDetailsPage, the read/delete details screen for
///          a single Control, opened by tapping a Control card on the
///          Policy Details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 21/7/2026

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    show showSuccessDialog;
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/add_edit_control_page.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// class name: [ControlDetailsPage]
///
/// purpose: entry-point widget for the Control Details screen. Provides its
///          own [PolicyCubit] (delete + post-edit refresh) and [OwnerCubit]
///          (owner lookup).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class ControlDetailsPage extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity control;
  final List<ControlEntity> siblingControls;

  const ControlDetailsPage({
    super.key,
    required this.module,
    required this.policy,
    required this.control,
    required this.siblingControls,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(
          create: (_) => GetIt.instance<PolicyCubit>(),
        ),
        BlocProvider<OwnerCubit>(
          create: (_) => GetIt.instance<OwnerCubit>()
            ..getAllOwners(moduleId: module.moduleId),
        ),
      ],
      child: _ControlDetailsBody(
        module: module,
        policy: policy,
        initialControl: control,
        siblingControls: siblingControls,
      ),
    );
  }
}

class _ControlDetailsBody extends StatefulWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity initialControl;
  final List<ControlEntity> siblingControls;

  const _ControlDetailsBody({
    required this.module,
    required this.policy,
    required this.initialControl,
    required this.siblingControls,
  });

  @override
  State<_ControlDetailsBody> createState() => _ControlDetailsBodyState();
}

class _ControlDetailsBodyState extends State<_ControlDetailsBody> {
  late ControlEntity _control;

  @override
  void initState() {
    super.initState();
    _control = widget.initialControl;
  }

  Future<void> _openEditControl(PolicyCubit cubit) async {
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddEditControlPage(
          moduleId: widget.module.moduleId,
          policyId: widget.policy.id,
          existingControl: _control,
          siblingControls: widget.siblingControls,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (mounted) {
      cubit.getAllControls(
        moduleId: widget.module.moduleId,
        policyId: widget.policy.id,
      );
    }
  }

  void _onDelete(PolicyCubit cubit) {
    cubit.deleteControl(
      id: _control.id,
      moduleId: widget.module.moduleId,
      policyId: widget.policy.id,
    );
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyControlsListLoaded) {
      final updated = state.controls.where((c) => c.id == _control.id);
      if (updated.isNotEmpty) setState(() => _control = updated.first);
      return;
    }

    if (state is PolicyControlDeleted) {
      showSuccessDialog(
        context: context,
        title: 'Control Deleted'.tr,
        subtitle: 'You successfully deleted this control.'.tr,
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text.rich(
        TextSpan(
          text: '$label ',
          style: CardStyles.label(14),
          children: [TextSpan(text: value, style: CardStyles.value(14))],
        ),
      ),
    );
  }

  /// Every owner email assigned to this exact {Policy, Control} pair, in
  /// [owners]' original order. Mirrors AddEditControlPage's
  /// `_alreadyAssignedOwnerEmails`.
  List<String> _ownerEmailsForControl(List<OwnerEntity> owners) {
    return owners
        .where((o) => o.assigningControls.any((a) =>
            a.policyId == widget.policy.id && a.controlId == _control.id))
        .map((o) => o.ownerEmail)
        .toList();
  }

  Widget _buildDescriptionHeaderRow(DateFormat dateFormat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Control Description'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
        Text(
          '${'Last Update'.tr}: ${dateFormat.format(_control.lastModifiedDate)}',
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
      ],
    );
  }

  Widget _buildDocumentsRow(DateFormat dateFormat) {
    final hasEn = _control.controlsDocumentEn != null;
    final hasAr = _control.controlsDocumentAr != null;
    if (!hasEn && !hasAr) return const SizedBox.shrink();

    Widget documentCard(String url) => Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: ProductWarrantyCard(
              fileName: url.split('/').last,
              date: dateFormat.format(_control.lastModifiedDate),
            ),
          ),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasEn) documentCard(_control.controlsDocumentEn!),
          if (hasEn && hasAr) SizedBox(width: 12.w),
          if (hasAr) documentCard(_control.controlsDocumentAr!),
        ],
      ),
    );
  }

  Widget _buildFrequencyWeightDatesRow(DateFormat dateFormat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _infoRow('Frequency:'.tr, _control.frequency)),
        Expanded(
          child: _infoRow(
            'Control Weight:'.tr,
            _control.controlsWeight.toStringAsFixed(0),
          ),
        ),
        Expanded(
          child: _infoRow(
            'Start Date:'.tr,
            dateFormat.format(_control.startDate),
          ),
        ),
        Expanded(
          child: _infoRow('End Date:'.tr, dateFormat.format(_control.endDate)),
        ),
      ],
    );
  }

  Widget _departmentChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
      ),
    );
  }

  Widget _buildDepartmentsWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Departments Weight'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
        SizedBox(height: 8.h),
        _control.departments.isEmpty
            ? _departmentChip('Not Assigned'.tr)
            : Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _control.departments
                    .map((d) => _departmentChip(
                        '${d.department} | ${d.weight.toStringAsFixed(0)}'))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildScoreAndPreviousOwnersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text.rich(
            TextSpan(
              text: '${'Score'.tr}: ',
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
              children: [
                TextSpan(
                  text: '${_control.score}',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: AppColors.green),
                ),
              ],
            ),
          ),
        ),
        customButton(
          title: 'Previous Control Owners'.tr,
          function: () {},
          height: 38.h,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PolicyCubit>();
    final isArabic = context.isArabic;
    final dateFormat = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');

    return BlocListener<PolicyCubit, PolicyState>(
      listener: _onStateChange,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(
                  screensTitles: [
                    'GRC'.tr,
                    isArabic
                        ? widget.module.moduleNameAr
                        : widget.module.moduleNameEn,
                    isArabic
                        ? widget.policy.policyNameAr
                        : widget.policy.policyNameEn,
                    isArabic ? _control.controlsNameAr : _control.controlsNameEn,
                  ],
                ),
                GrcActionButtons(
                  onEditTap: () => _openEditControl(cubit),
                  onDeleteTap: () => _onDelete(cubit),
                  deleteDialogTitle: 'Deleting Control',
                  deleteDialogSubtitle:
                      'Are You Sure You Want To Delete This Control ?',
                ),
                SizedBox(height: 12.h),
                _buildScoreAndPreviousOwnersRow(),
                SizedBox(height: 12.h),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15.sp),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDescriptionHeaderRow(dateFormat),
                            Text(
                              isArabic
                                  ? _control.controlsDescriptionAr
                                  : _control.controlsDescriptionEn,
                              style: StyleText.fontSize12Weight500
                                  .copyWith(color: AppColors.secondaryText),
                            ),
                            SizedBox(height: 10.h),
                            BlocBuilder<OwnerCubit, OwnerState>(
                              builder: (context, state) {
                                final owners = state is OwnerListLoaded
                                    ? state.owners
                                    : const <OwnerEntity>[];
                                return GrcOwnerBadge(
                                  label: 'Control Owner:',
                                  ownerEmails: _ownerEmailsForControl(owners),
                                  onMessageTap: (owner) {},
                                );
                              },
                            ),
                            SizedBox(height: 10.h),
                            _buildDocumentsRow(dateFormat),
                            _buildFrequencyWeightDatesRow(dateFormat),
                            SizedBox(height: 10.h),
                            _buildDepartmentsWeightSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify with `dart analyze`**

Run: `dart analyze lib/features/grc/control/presentation/ui/pages/control_details_page.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_details_page.dart
git commit -m "feat(grc): add read-only ControlDetailsPage"
```

---

### Task 3: Wire the Controls list to open `ControlDetailsPage`

**Files:**
- Modify: `lib/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_view_mode_widget.dart`
- Modify: `lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart`

**Interfaces:**
- Consumes: `ControlDetailsPage({required module, required policy, required control, required siblingControls})` (Task 2).
- Produces: `PolicyViewModeWidget` gains a new required `onControlsChanged: VoidCallback` parameter, called every time the user returns from `ControlDetailsPage` (edit, delete, or neither) so the parent's Controls list is always fresh.

- [ ] **Step 1: Add the `onControlsChanged` field and import in `policy_view_mode_widget.dart`**

Add this import alongside the existing ones near the top of the file:

```dart
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_details_page.dart';
```

Then replace:

```dart
class PolicyViewModeWidget extends StatefulWidget {
  final PolicyEntity policy;
  final GRCModuleEntity module;
  final List<ControlEntity> controls;
  final bool isArabic;
  final DateFormat dateFormat;
  final ValueChanged<ControlEntity?> onControlTap;
  final VoidCallback onBulkUpload;

  const PolicyViewModeWidget({
    super.key,
    required this.policy,
    required this.module,
    required this.controls,
    required this.isArabic,
    required this.dateFormat,
    required this.onControlTap,
    required this.onBulkUpload,
  });
```

with:

```dart
class PolicyViewModeWidget extends StatefulWidget {
  final PolicyEntity policy;
  final GRCModuleEntity module;
  final List<ControlEntity> controls;
  final bool isArabic;
  final DateFormat dateFormat;
  final ValueChanged<ControlEntity?> onControlTap;
  final VoidCallback onBulkUpload;
  final VoidCallback onControlsChanged;

  const PolicyViewModeWidget({
    super.key,
    required this.policy,
    required this.module,
    required this.controls,
    required this.isArabic,
    required this.dateFormat,
    required this.onControlTap,
    required this.onBulkUpload,
    required this.onControlsChanged,
  });
```

- [ ] **Step 2: Add the `_openControlDetails` helper**

Add this method to `_PolicyViewModeWidgetState`, right above `_buildControlsList`:

```dart
  Future<void> _openControlDetails(ControlEntity control) async {
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ControlDetailsPage(
          module: widget.module,
          policy: widget.policy,
          control: control,
          siblingControls: widget.controls,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    widget.onControlsChanged();
  }
```

- [ ] **Step 3: Point the Control card taps at it**

In `_buildControlsList`, replace:

```dart
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controls.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) => ControlCardWidget(
          control: controls[index],
          onTap: () => widget.onControlTap(controls[index]),
        ),
      );
```

with:

```dart
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controls.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) => ControlCardWidget(
          control: controls[index],
          onTap: () => _openControlDetails(controls[index]),
        ),
      );
```

and replace:

```dart
              children: [
                Expanded(
                  child: ControlCardWidget(
                    control: controls[i],
                    onTap: () => widget.onControlTap(controls[i]),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: i + 1 < controls.length
                      ? ControlCardWidget(
                          control: controls[i + 1],
                          onTap: () => widget.onControlTap(controls[i + 1]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
```

with:

```dart
              children: [
                Expanded(
                  child: ControlCardWidget(
                    control: controls[i],
                    onTap: () => _openControlDetails(controls[i]),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: i + 1 < controls.length
                      ? ControlCardWidget(
                          control: controls[i + 1],
                          onTap: () => _openControlDetails(controls[i + 1]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
```

Note: `widget.onControlTap` keeps being used exactly as before for the "Add Control" toolbar menu item (`widget.onControlTap(null)`, `_buildControlAddButton`) — that one still goes straight to `AddEditControlPage` since there's nothing to view yet for a Control that doesn't exist.

- [ ] **Step 4: Pass `onControlsChanged` from `policy_details_page.dart`**

Replace:

```dart
                            child: PolicyViewModeWidget(
                              policy: _policy!,
                              module: widget.module,
                              controls: _controls,
                              isArabic: isArabic,
                              dateFormat: dateFormat,
                              onControlTap: (existing) =>
                                  _openAddEditControl(existing: existing),
                              onBulkUpload: _onBulkUploadControls,
                            ),
```

with:

```dart
                            child: PolicyViewModeWidget(
                              policy: _policy!,
                              module: widget.module,
                              controls: _controls,
                              isArabic: isArabic,
                              dateFormat: dateFormat,
                              onControlTap: (existing) =>
                                  _openAddEditControl(existing: existing),
                              onBulkUpload: _onBulkUploadControls,
                              onControlsChanged: () => context
                                  .read<PolicyCubit>()
                                  .getAllControls(
                                    moduleId: widget.moduleId,
                                    policyId: widget.policyId,
                                  ),
                            ),
```

- [ ] **Step 5: Verify with `dart analyze`**

Run: `dart analyze lib/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_view_mode_widget.dart lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart`
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_view_mode_widget.dart lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart
git commit -m "feat(grc): open ControlDetailsPage when a Control card is tapped"
```

---

## Final check

- [ ] **Run a full analyze pass**

Run: `dart analyze lib/features/grc`
Expected: no new errors introduced by this plan (pre-existing warnings unrelated to these files are fine).
