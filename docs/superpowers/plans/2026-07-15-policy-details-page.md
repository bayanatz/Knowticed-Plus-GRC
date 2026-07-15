# Policy Details Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Policy Details page (view / in-place edit / delete for the Policy, plus a Controls list with a status filter and a full-page Add/Edit Control form), reachable by tapping a policy card on the GRC Module details page.

**Architecture:** Flutter + flutter_bloc. Everything needed in the domain/data layers already exists and is DI-wired (`PolicyCubit.getPolicy/updatePolicy/deletePolicy/getAllControls/createControl/updateControl`, factory-registered in `grc_get_it.dart`) — this plan is UI-only. Two pages are added (`PolicyDetailsPage`, `AddEditControlPage`), each owning its own `PolicyCubit` instance via `BlocProvider(create: (_) => GetIt.instance<PolicyCubit>())`, matching the existing `GrcModuleDetailsPage`/`CreateNewPolicyPage` pattern. `AddEditControlPage` reports success back to `PolicyDetailsPage` via a `Navigator.push<bool>` return value (not a shared cubit), so the two pages' state stays fully independent.

**Tech Stack:** Flutter, flutter_bloc, get_it, dartz (Either, already wrapped by use cases), flutter_screenutil, intl.

## Global Constraints

- No automated tests are part of this task (explicit user instruction) — verification is `flutter analyze` (static/compile correctness) plus the existing repo's own conventions. Do not add `_test.dart` files for this feature.
- Do not modify the domain/data layers (`ControlRepository`, `PolicyRepository`, use cases, `grc_get_it.dart` DI registrations) — everything this plan needs is already implemented and registered.
- Follow existing patterns exactly: `navigateTo`/fade `PageRouteBuilder` for navigation, `showConfirmDialog`/`showSuccessDialog`/`showLoadingIndicator`/`hideLoadingIndicator` for dialogs and loading, `context.isArabic` for localization, `.tr` on every user-facing string.
- `departments`, `equalWeights`, and `score` stay hardcoded (`[]` / `false` / `0`) on Control create — matches `create_new_policy.dart`'s existing `_buildPendingControls`, not a regression.
- Commit after each task with `git add <files>` + a descriptive message (no `--no-verify`).

---

### Task 1: Read-only document preview support

**Files:**
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart`
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart`

**Interfaces:**
- Produces: `PolicyDocumentInfo.fromUrl(String url)` factory (in addition to the existing `fromPlatformFile`); `PolicyDocumentInfo.file` and `.url` are now both nullable (`File?`, `String?`); `PolicyDocumentPreviewWidget` gains `bool readOnly = false` and `onRemove` becomes optional (`VoidCallback?`).
- Consumes: nothing new (both files are currently leaf widgets/models with no dependency on anything built later in this plan).

- [ ] **Step 1: Rewrite `policy_document_info.dart` to add `fromUrl` and make `file` nullable**

Replace the full file contents with:

```dart
/// Module: GRC Policy Management
/// Description: Data model for uploaded policy/control document metadata.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: file_picker
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Added `file` + fromPlatformFile factory so
///                                the picked file can be uploaded, not just
///                                displayed.
///                   2026-07-15 - Added `url` + fromUrl factory for
///                                already-uploaded, read-only documents
///                                (Policy Details page)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_document_info.dart
/// Purpose: Contains PolicyDocumentInfo, an immutable model for a picked
///          document's display metadata plus the actual File to upload, or
///          the remote URL for an already-uploaded, read-only document.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// class name: [PolicyDocumentInfo]
///
/// purpose: immutable value object that carries display metadata (name,
///          formatted size, formatted date) plus either the local [file] to
///          upload for a freshly picked document, or the remote [url] of an
///          already-uploaded document shown read-only.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyDocumentInfo {
  final String name;
  final String sizeLabel;
  final String dateLabel;
  final File? file;
  final String? url;

  const PolicyDocumentInfo({
    required this.name,
    required this.sizeLabel,
    required this.dateLabel,
    this.file,
    this.url,
  });

  /// function name: [fromPlatformFile]
  ///
  /// purpose: build a [PolicyDocumentInfo] straight from the [PlatformFile]
  ///          returned by `showUploadDialog`'s onSubmit callback.
  ///
  /// parameters:
  ///            [PlatformFile] platformFile: the file picked via file_picker
  ///
  /// return type: [PolicyDocumentInfo]
  factory PolicyDocumentInfo.fromPlatformFile(PlatformFile platformFile) {
    return PolicyDocumentInfo(
      name: platformFile.name,
      sizeLabel: _formatBytes(platformFile.size),
      dateLabel: _formatToday(),
      file: File(platformFile.path!),
    );
  }

  /// function name: [fromUrl]
  ///
  /// purpose: build a read-only [PolicyDocumentInfo] for a document that is
  ///          already uploaded — only its download [url] is known, no local
  ///          [File] or byte size is available.
  ///
  /// parameters:
  ///            [String] url: the document's download URL
  ///
  /// return type: [PolicyDocumentInfo]
  factory PolicyDocumentInfo.fromUrl(String url) {
    final withoutQuery = url.split('?').first;
    final segments = withoutQuery.split('/');
    final rawName = segments.isNotEmpty ? segments.last : withoutQuery;
    String name;
    try {
      name = Uri.decodeFull(rawName);
    } catch (_) {
      name = rawName;
    }
    return PolicyDocumentInfo(
      name: name.isEmpty ? url : name,
      sizeLabel: '',
      dateLabel: '',
      url: url,
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String _formatToday() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
```

- [ ] **Step 2: Rewrite `policy_document_preview_widget.dart` to add `readOnly` mode**

Replace the full file contents with:

```dart
/// Module: GRC Policy Management
/// Description: Compact preview card for an uploaded policy document.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyDocumentInfo
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-15 - Added `readOnly` mode (hides the remove
///                                button) for already-uploaded documents
///                                shown on the Policy Details page
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_document_preview_widget.dart
/// Purpose: Contains PolicyDocumentPreviewWidget, a compact card that
///          displays document metadata and, unless read-only, a remove
///          button.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// class name: [PolicyDocumentPreviewWidget]
///
/// purpose: stateless card that shows a PDF icon, document name, size (if
///          known), date (if known), and — unless [readOnly] — a red remove
///          button. Used in the policy info form, each control card, and
///          the read-only Policy Details page.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyDocumentPreviewWidget extends StatelessWidget {
  final PolicyDocumentInfo document;
  final VoidCallback? onRemove;
  final bool readOnly;

  const PolicyDocumentPreviewWidget({
    super.key,
    required this.document,
    this.onRemove,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withOpacity(.4)),
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.background,
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red, size: 26.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  document.name,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis,
                ),
                if (document.sizeLabel.isNotEmpty)
                  Text(
                    document.sizeLabel,
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.secondaryText),
                  ),
              ],
            ),
          ),
          if (document.dateLabel.isNotEmpty) ...[
            SizedBox(width: 8.w),
            Text(
              'Date: ${document.dateLabel}',
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
          ],
          if (!readOnly) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onRemove,
              child: CircleAvatar(
                radius: 10.r,
                backgroundColor: Colors.red,
                child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Verify no regressions in existing callers**

Run: `flutter analyze lib/features/grc`
Expected: no new errors. (`onRemove` becoming optional and `file` becoming nullable are both widening changes — every existing call site in `policy_info_form_widget.dart` and `policy_control_item_widget.dart` still passes a non-null `onRemove`, and every existing read of `.file` in `create_new_policy.dart` already used `?.file` on a nullable-context, so no call site should break.)

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart
git commit -m "feat(grc): support read-only, URL-based document previews"
```

---

### Task 2: Read-only Control card widget

**Files:**
- Create: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/control_card_widget.dart`

**Interfaces:**
- Consumes: `ControlEntity`, `ControlStatus` (both already exist, unchanged).
- Produces: `ControlCardWidget({required ControlEntity control, required VoidCallback onTap})` — used by Task 5's Controls list.

- [ ] **Step 1: Create the widget**

```dart
/// Module: GRC Policy Management
/// Description: Read-only card widget for a single Control, shown in the
///              Controls list on the Policy Details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: Flutter SDK, AppColors, AppTheme, ControlEntity, ControlStatus
/// Revision History: 2026-07-15 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_card_widget.dart
/// Purpose: Contains ControlCardWidget, a read-only list-item card that
///          displays a single ControlEntity's status, score, weight,
///          frequency dates, and last edit. Tapping opens it for editing.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

/// class name: [ControlCardWidget]
///
/// purpose: read-only list-item card for a single [ControlEntity]. Used by
///          the Controls section of the Policy Details page.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class ControlCardWidget extends StatelessWidget {
  final ControlEntity control;
  final VoidCallback onTap;

  const ControlCardWidget({
    super.key,
    required this.control,
    required this.onTap,
  });

  Color _statusColor(ControlStatus status) {
    switch (status) {
      case ControlStatus.active:
        return AppColors.green;
      case ControlStatus.inactive:
        return AppColors.orange;
      case ControlStatus.expired:
        return AppColors.red;
      case ControlStatus.unassigned:
        return AppColors.blue;
      case ControlStatus.draft:
        return AppColors.colorGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final dateFormat = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: CardStyles.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text: '${'Control Status'.tr}: ',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: control.status.value.tr,
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: _statusColor(control.status)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '${'Score'.tr}: ${control.score}',
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.text),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              isArabic ? control.controlsNameAr : control.controlsNameEn,
              style:
                  StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'Start Date'.tr}: ${dateFormat.format(control.startDate)}',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
                Text(
                  '${'End Date'.tr}: ${dateFormat.format(control.endDate)}',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'Control Weight'.tr}: ${control.controlsWeight.toStringAsFixed(0)}',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
                Text(
                  '${'Last Edit'.tr}: ${dateFormat.format(control.lastModifiedDate)}',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/features/grc/presentation/ui/widgets/grc_policy_widget/control_card_widget.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/presentation/ui/widgets/grc_policy_widget/control_card_widget.dart
git commit -m "feat(grc): add read-only ControlCardWidget for the Controls list"
```

---

### Task 3: PolicyDetailsPage — Policy view / edit / delete, wired from the module list

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/policy_details_page.dart`
- Modify: `lib/features/grc/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart`
- Modify: `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart`

**Interfaces:**
- Consumes: `PolicyCubit` (`getPolicy`, `updatePolicy`, `deletePolicy` — all existing), `PolicyInfoFormWidget`, `GrcOwnerSection`, `PolicyDocumentInfo`/`PolicyDocumentPreviewWidget` (Task 1), `containsEnglishLetters`/`containsArabicLetters` (`grc_form_fields.dart`), `GrcActionButtons` (this task widens it).
- Produces: `PolicyDetailsPage({required String policyId, required String moduleId, required GRCModuleEntity module})` — Task 5 extends this same file to add the Controls section.

- [ ] **Step 1: Widen `GrcActionButtons` so its delete-confirm dialog text is overridable**

Replace the full file contents of `grc_action_buttons.dart` with:

```dart
/// Module: GRC Module Management
/// Description: Provides the Edit and Delete action buttons shown at the top
///              of the GRC Module details page (and, since 2026-07-15, the
///              Policy Details page) in view mode.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, AppTheme, customButtonWithSvg, showConfirmDialog
/// Revision History: 2026-06-29 - Initial creation
///                    2026-06-30 - Added onDeleteTap callback (Mohamed Magdy Abdelkhalek)
///                    2026-07-15 - Made the delete confirm dialog's title/
///                                 subtitle/icon overridable so other GRC
///                                 pages (e.g. Policy Details) can reuse this
///                                 widget with their own wording
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_action_buttons.dart
/// Purpose: Contains GrcActionButtons, a row of Edit and Delete buttons
///          reused across GRC detail pages.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class GrcActionButtons extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final String deleteDialogTitle;
  final String deleteDialogSubtitle;
  final String deleteDialogIconAsset;

  const GrcActionButtons({
    super.key,
    required this.onEditTap,
    required this.onDeleteTap,
    this.deleteDialogTitle = "Deleting GRC Module",
    this.deleteDialogSubtitle =
        "Are You Sure You Want To Delete This GRC Module ?",
    this.deleteDialogIconAsset =
        "assets/icons_assets/data_grc_assets/delete-module.svg",
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            customButtonWithSvg(
              colorBorder: AppColors.primary,
              space: 10.w,
              radius: 8.r,
              widthImage: 16.w,
              heightImage: 16.h,
              image: "assets/icons_assets/data_grc_assets/edit_pen.svg",
              title: isTablet ? "Edit".tr : "",
              function: onEditTap,
              width: isTablet ? 135.w : 40.w,
              color: AppColors.primary,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
            ),
            SizedBox(width: 10.w),
            customButtonWithSvg(
              colorBorder: AppColors.red,
              space: 10.w,
              radius: 8.r,
              widthImage: 16.w,
              heightImage: 16.h,
              image: "assets/icons_assets/organization_chart_assets/trashd.svg",
              title: isTablet ? "Delete".tr : "",
              function: () {
                showConfirmDialog(
                  context: context,
                  title: deleteDialogTitle.tr,
                  cancelLabel: "No".tr,
                  confirmLabel: "Yes".tr,
                  iconWidget: SvgPicture.asset(deleteDialogIconAsset),
                  subtitle: deleteDialogSubtitle.tr,
                  onConfirm: onDeleteTap,
                );
              },
              width: isTablet ? 135.w : 40.w,
              color: AppColors.red,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.white),
            ),
          ],
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
```

This is backward compatible: the three new fields default to the exact strings/asset the widget already hardcoded, so the existing GRC Module details page caller (which passes none of them) renders identically.

- [ ] **Step 2: Create `policy_details_page.dart`**

```dart
/// Module: GRC Policy Management
/// Description: Details page for a single Policy — view its fields, edit
///              them in place, and delete the Policy (soft-delete). Task 5
///              extends this file to add the Controls section.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter_bloc, PolicyCubit, PolicyEntity, GRCModuleEntity,
///               get_it
/// Revision History: 2026-07-15 - Initial creation (Policy view/edit/delete)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_details_page.dart
/// Purpose: Contains PolicyDetailsPage, the read/edit/delete details screen
///          for a single Policy, opened by tapping a policy card on the GRC
///          Module details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

enum _PolicyPageMode { view, edit }

/// class name: [PolicyDetailsPage]
///
/// purpose: entry-point widget for the Policy Details screen. Provides a
///          [PolicyCubit] and fetches [policyId] fresh from Firestore so the
///          page always reflects the latest saved state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class PolicyDetailsPage extends StatelessWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const PolicyDetailsPage({
    super.key,
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<PolicyCubit>()..getPolicy(policyId, moduleId: moduleId),
      child: _PolicyDetailsBody(moduleId: moduleId, module: module),
    );
  }
}

class _PolicyDetailsBody extends StatefulWidget {
  final String moduleId;
  final GRCModuleEntity module;

  const _PolicyDetailsBody({required this.moduleId, required this.module});

  @override
  State<_PolicyDetailsBody> createState() => _PolicyDetailsBodyState();
}

class _PolicyDetailsBodyState extends State<_PolicyDetailsBody> {
  PolicyEntity? _policy;
  _PolicyPageMode _mode = _PolicyPageMode.view;
  bool _submitted = false;
  bool _pendingDelete = false;

  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _numberController.dispose();
    _numberArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _prefillControllers(PolicyEntity policy) {
    _nameController.text = policy.policyNameEn;
    _nameArController.text = policy.policyNameAr;
    _numberController.text = policy.policyNumberEn;
    _numberArController.text = policy.policyNumberAr;
    _descriptionController.text = policy.policyDescriptionEn;
    _descriptionArController.text = policy.policyDescriptionAr;
    _weightController.text = policy.policyWeight.toStringAsFixed(0);
    _startDate = policy.startDate;
    _endDate = policy.endDate;
    _documentEn = policy.policyDocumentEn != null
        ? PolicyDocumentInfo.fromUrl(policy.policyDocumentEn!)
        : null;
    _documentAr = policy.policyDocumentAr != null
        ? PolicyDocumentInfo.fromUrl(policy.policyDocumentAr!)
        : null;
  }

  bool _validate() {
    setState(() => _submitted = true);
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final endBeforeStart = _endDate != null &&
        _startDate != null &&
        _endDate!.isBefore(_startDate!);
    return _nameController.text.trim().isNotEmpty &&
        _nameArController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _numberArController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _descriptionArController.text.trim().isNotEmpty &&
        !containsArabicLetters(_nameController.text) &&
        !containsEnglishLetters(_nameArController.text) &&
        !containsArabicLetters(_numberController.text) &&
        !containsEnglishLetters(_numberArController.text) &&
        !containsArabicLetters(_descriptionController.text) &&
        !containsEnglishLetters(_descriptionArController.text) &&
        _startDate != null &&
        !_startDate!.isBefore(startOfToday) &&
        _endDate != null &&
        !endBeforeStart &&
        double.tryParse(_weightController.text.trim()) != null;
  }

  void _onUploadDocumentEn() {
    showUploadDialog(
      context: context,
      dialogTitle: 'Upload Policy Document (English)'.tr,
      titleFieldLabel: 'Document Title'.tr,
      titleFieldHint: 'Text here'.tr,
      browseLabel: 'Browse Files'.tr,
      submitLabel: 'Submit'.tr,
      discardLabel: 'Discard'.tr,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _documentEn = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  void _onUploadDocumentAr() {
    showUploadDialog(
      context: context,
      dialogTitle: 'رفع مستند السياسة (عربي)',
      titleFieldLabel: 'عنوان المستند',
      titleFieldHint: 'اكتب هنا',
      browseLabel: 'تصفح الملفات',
      submitLabel: 'إرسال',
      discardLabel: 'إلغاء',
      textDirection: TextDirection.rtl,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _documentAr = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  // Removing only clears the pending replacement shown on screen — the
  // update API has no explicit "clear stored document" signal, so if the
  // user removes without picking a replacement, Save keeps the original.
  void _onRemoveDocumentEn() => setState(() => _documentEn = null);
  void _onRemoveDocumentAr() => setState(() => _documentAr = null);

  void _onSave(PolicyCubit cubit) {
    cubit.updatePolicy(
      id: _policy!.id,
      moduleId: widget.moduleId,
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      policyWeight: double.tryParse(_weightController.text.trim()),
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentUrlEn: _documentEn?.file == null ? _documentEn?.url : null,
      policyDocumentFileAr: _documentAr?.file,
      policyDocumentUrlAr: _documentAr?.file == null ? _documentAr?.url : null,
    );
  }

  void _onDelete(PolicyCubit cubit) {
    _pendingDelete = true;
    cubit.deletePolicy(id: _policy!.id, moduleId: widget.moduleId);
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      if (_policy != null) showLoadingIndicator();
      return;
    }
    if (_policy != null) hideLoadingIndicator();

    if (state is PolicySingleLoaded) {
      setState(() => _policy = state.policy);
      return;
    }

    if (state is PolicyActionSuccess) {
      if (_pendingDelete) {
        showSuccessDialog(
          context: context,
          title: 'Policy Deleted'.tr,
          subtitle: 'You successfully deleted this policy.'.tr,
        );
        Navigator.of(context).pop(true);
        return;
      }
      showSuccessDialog(
        context: context,
        title: 'Policy Updated'.tr,
        subtitle: 'You successfully updated this policy.'.tr,
      );
      setState(() {
        _policy = state.policy;
        _mode = _PolicyPageMode.view;
        _submitted = false;
      });
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

  Widget _buildBottomButtons(PolicyCubit cubit) {
    if (_mode != _PolicyPageMode.edit) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: 'Discard Changes'.tr,
          function: () => setState(() => _mode = _PolicyPageMode.view),
          height: 38.h,
          width: 150.w,
          color: AppColors.grey,
          textColor: AppColors.text,
          borderColor: AppColors.border,
        ),
        customButton(
          title: 'Save'.tr,
          function: () {
            if (!_validate()) return;
            showConfirmDialog(
              context: context,
              title: 'Editing Policy'.tr,
              cancelLabel: 'No'.tr,
              confirmLabel: 'Yes'.tr,
              subtitle: 'Are You Sure You Want To Edit This Policy ?'.tr,
              onConfirm: () => _onSave(cubit),
            );
          },
          height: 38.h,
          width: 150.w,
          color: AppColors.primary,
          textColor: AppColors.textButton,
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
            child: _policy == null
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(
                        screensTitles: [
                          'GRC'.tr,
                          isArabic
                              ? widget.module.moduleNameAr
                              : widget.module.moduleNameEn,
                          isArabic ? _policy!.policyNameAr : _policy!.policyNameEn,
                        ],
                      ),
                      if (_mode == _PolicyPageMode.view)
                        GrcActionButtons(
                          onEditTap: () {
                            _prefillControllers(_policy!);
                            setState(() => _mode = _PolicyPageMode.edit);
                          },
                          onDeleteTap: () => _onDelete(cubit),
                          deleteDialogTitle: 'Deleting Policy',
                          deleteDialogSubtitle:
                              'Are You Sure You Want To Delete This Policy ?',
                        ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15.sp),
                          decoration: BoxDecoration(
                            color: AppColors.field,
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_mode == _PolicyPageMode.view) ...[
                                    Text(
                                      'Policy Details'.tr,
                                      style: StyleText.fontSize16Weight600
                                          .copyWith(color: AppColors.text),
                                    ),
                                    SizedBox(height: 12.h),
                                    _infoRow(
                                        'Policy Number:'.tr,
                                        isArabic
                                            ? _policy!.policyNumberAr
                                            : _policy!.policyNumberEn),
                                    Text(
                                      'Policy Description'.tr,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(color: AppColors.text),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      isArabic
                                          ? _policy!.policyDescriptionAr
                                          : _policy!.policyDescriptionEn,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(
                                              color: AppColors.secondaryText),
                                    ),
                                    SizedBox(height: 12.h),
                                    _infoRow('Policy Weight:'.tr,
                                        _policy!.policyWeight.toStringAsFixed(0)),
                                    _infoRow('Start Date:'.tr,
                                        dateFormat.format(_policy!.startDate)),
                                    _infoRow('End Date:'.tr,
                                        dateFormat.format(_policy!.endDate)),
                                    _infoRow(
                                        'Last Edit:'.tr,
                                        dateFormat
                                            .format(_policy!.lastModifiedDate)),
                                    SizedBox(height: 12.h),
                                    if (_policy!.policyDocumentEn != null)
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8.h),
                                        child: PolicyDocumentPreviewWidget(
                                          document: PolicyDocumentInfo.fromUrl(
                                              _policy!.policyDocumentEn!),
                                          readOnly: true,
                                        ),
                                      ),
                                    if (_policy!.policyDocumentAr != null)
                                      PolicyDocumentPreviewWidget(
                                        document: PolicyDocumentInfo.fromUrl(
                                            _policy!.policyDocumentAr!),
                                        readOnly: true,
                                      ),
                                    SizedBox(height: 20.h),
                                    GrcOwnerSection(
                                      isViewMode: true,
                                      initialOwnerEmails:
                                          widget.module.moduleOwners,
                                    ),
                                  ] else ...[
                                    PolicyInfoFormWidget(
                                      isArabicEnabled: true,
                                      submitted: _submitted,
                                      nameController: _nameController,
                                      nameArController: _nameArController,
                                      numberController: _numberController,
                                      numberArController: _numberArController,
                                      descriptionController:
                                          _descriptionController,
                                      descriptionArController:
                                          _descriptionArController,
                                      weightController: _weightController,
                                      startDate: _startDate,
                                      endDate: _endDate,
                                      onStartDateChanged: (d) =>
                                          setState(() => _startDate = d),
                                      onEndDateChanged: (d) =>
                                          setState(() => _endDate = d),
                                      documentEn: _documentEn,
                                      documentAr: _documentAr,
                                      onUploadDocumentEn: _onUploadDocumentEn,
                                      onUploadDocumentAr: _onUploadDocumentAr,
                                      onRemoveDocumentEn: _onRemoveDocumentEn,
                                      onRemoveDocumentAr: _onRemoveDocumentAr,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildBottomButtons(cubit),
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

- [ ] **Step 3: Wire navigation from the module's policy list**

In `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart`, add the import:

```dart
import 'package:demo_app/features/grc/presentation/ui/pages/policy_details_page.dart';
```

Then replace the `_PolicyCard` class (and its call site) with:

```dart
        itemBuilder: (_, index) =>
            _PolicyCard(policy: policies[index], module: widget.module),
```

```dart
/// class name: [_PolicyCard]
///
/// purpose: private list-item card that displays a single [PolicyEntity]
///          with its name, number, status, and last-update date. Tapping
///          opens [PolicyDetailsPage] for that policy.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 6/7/2026
class _PolicyCard extends StatelessWidget {
  final PolicyEntity policy;
  final GRCModuleEntity module;

  const _PolicyCard({required this.policy, required this.module});

  @override
  Widget build(BuildContext context) {
    return ModuleInfoCard(
      width: double.infinity,
      onTap: () => navigateTo(
        context,
        PolicyDetailsPage(
          policyId: policy.id,
          moduleId: module.moduleId,
          module: module,
        ),
      ),
      title: context.isArabic ? policy.policyNameAr : policy.policyNameEn,
      infoRows: [
        CardInfo(
          label: context.isArabic ? 'الرقم :' : 'Number :',
          value:
              context.isArabic ? policy.policyNumberAr : policy.policyNumberEn,
        ),
      ],
      complianceLabel: context.isArabic ? 'الحالة:' : 'Status:',
      complianceScore: policy.status.value.tr,
      footerLabel: context.isArabic ? 'آخر تحديث:' : 'Last Update:',
      footerValue: DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
          .format(policy.lastModifiedDate),
    );
  }
}
```

(Only the `_PolicyCard` class body and its single call site in `_buildPolicyList` change; the rest of `grc_module_details_page.dart` is untouched.)

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/features/grc`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart lib/features/grc/presentation/ui/pages/policy_details_page.dart lib/features/grc/presentation/ui/pages/grc_module_details_page.dart
git commit -m "feat(grc): add Policy Details page (view/edit/delete) and wire navigation from the policy list"
```

---

### Task 4: AddEditControlPage — create/edit a standalone Control

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/add_edit_control_page.dart`

**Interfaces:**
- Consumes: `PolicyCubit.createControl`/`updateControl` (existing), `ControlEntity`, `ControlStatus`, `PolicyDocumentInfo`/`PolicyDocumentPreviewWidget` (Task 1), `containsEnglishLetters`/`containsArabicLetters`.
- Produces: `AddEditControlPage({required String moduleId, required String policyId, required List<ControlEntity> siblingControls, ControlEntity? existingControl})`. Pops with `true` on success — Task 5's Policy Details page awaits this to know when to refresh its Controls list.

- [ ] **Step 1: Create the page**

```dart
/// Module: GRC Policy Management
/// Description: Full-page form for creating or editing a single standalone
///              Control under an existing Policy, opened from the Policy
///              Details page's Controls section.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter_bloc, PolicyCubit, ControlEntity, ControlStatus, get_it
/// Revision History: 2026-07-15 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: add_edit_control_page.dart
/// Purpose: Contains AddEditControlPage, the create/edit form for a single
///          Control. Enforces that this control's weight plus every sibling
///          control's weight sums to 100.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';

/// class name: [AddEditControlPage]
///
/// purpose: full-page form to create a new Control or edit an existing one,
///          scoped to one Policy. Validates that this control's weight plus
///          every entry in [siblingControls] sums to exactly 100.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class AddEditControlPage extends StatefulWidget {
  final String moduleId;
  final String policyId;
  final List<ControlEntity> siblingControls;
  final ControlEntity? existingControl;

  const AddEditControlPage({
    super.key,
    required this.moduleId,
    required this.policyId,
    required this.siblingControls,
    this.existingControl,
  });

  @override
  State<AddEditControlPage> createState() => _AddEditControlPageState();
}

class _AddEditControlPageState extends State<AddEditControlPage> {
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();

  String? _frequency;
  DateTime? _startDate;
  DateTime? _endDate;
  ControlStatus _status = ControlStatus.draft;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;
  bool _submitted = false;

  bool get _isEdit => widget.existingControl != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingControl;
    if (existing == null) return;
    _nameController.text = existing.controlsNameEn;
    _nameArController.text = existing.controlsNameAr;
    _numberController.text = existing.controlsNumberEn;
    _numberArController.text = existing.controlsNumberAr;
    _descriptionController.text = existing.controlsDescriptionEn;
    _descriptionArController.text = existing.controlsDescriptionAr;
    _weightController.text = existing.controlsWeight.toStringAsFixed(0);
    _frequency = existing.frequency.isEmpty ? null : existing.frequency;
    _startDate = existing.startDate;
    _endDate = existing.endDate;
    _status = existing.status;
    _documentEn = existing.controlsDocumentEn != null
        ? PolicyDocumentInfo.fromUrl(existing.controlsDocumentEn!)
        : null;
    _documentAr = existing.controlsDocumentAr != null
        ? PolicyDocumentInfo.fromUrl(existing.controlsDocumentAr!)
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _numberController.dispose();
    _numberArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double get _siblingsWeight => widget.siblingControls
      .where((c) => c.id != widget.existingControl?.id)
      .fold<double>(0, (sum, c) => sum + c.controlsWeight);

  double get _thisWeight => double.tryParse(_weightController.text.trim()) ?? 0;

  bool get _isWeightValid => (_thisWeight + _siblingsWeight) == 100;

  bool _validate() {
    setState(() => _submitted = true);
    final endBeforeStart = _endDate != null &&
        _startDate != null &&
        _endDate!.isBefore(_startDate!);
    return _nameController.text.trim().isNotEmpty &&
        _nameArController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _numberArController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _descriptionArController.text.trim().isNotEmpty &&
        !containsArabicLetters(_nameController.text) &&
        !containsEnglishLetters(_nameArController.text) &&
        !containsArabicLetters(_numberController.text) &&
        !containsEnglishLetters(_numberArController.text) &&
        !containsArabicLetters(_descriptionController.text) &&
        !containsEnglishLetters(_descriptionArController.text) &&
        _frequency != null &&
        _startDate != null &&
        _endDate != null &&
        !endBeforeStart &&
        double.tryParse(_weightController.text.trim()) != null &&
        _isWeightValid;
  }

  void _onUploadDocumentEn() {
    showUploadDialog(
      context: context,
      dialogTitle: 'Upload Control Document (English)'.tr,
      titleFieldLabel: 'Document Title'.tr,
      titleFieldHint: 'Text here'.tr,
      browseLabel: 'Browse Files'.tr,
      submitLabel: 'Submit'.tr,
      discardLabel: 'Discard'.tr,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _documentEn = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  void _onUploadDocumentAr() {
    showUploadDialog(
      context: context,
      dialogTitle: 'رفع مستند الضابط (عربي)',
      titleFieldLabel: 'عنوان المستند',
      titleFieldHint: 'اكتب هنا',
      browseLabel: 'تصفح الملفات',
      submitLabel: 'إرسال',
      discardLabel: 'إلغاء',
      textDirection: TextDirection.rtl,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      onSubmit: (file, title) {
        setState(() => _documentAr = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  void _onRemoveDocumentEn() => setState(() => _documentEn = null);
  void _onRemoveDocumentAr() => setState(() => _documentAr = null);

  void _onSave(PolicyCubit cubit) {
    if (_isEdit) {
      cubit.updateControl(
        id: widget.existingControl!.id,
        moduleId: widget.moduleId,
        policyId: widget.policyId,
        controlsNameEn: _nameController.text.trim(),
        controlsNameAr: _nameArController.text.trim(),
        controlsNumberEn: _numberController.text.trim(),
        controlsNumberAr: _numberArController.text.trim(),
        controlsDescriptionEn: _descriptionController.text.trim(),
        controlsDescriptionAr: _descriptionArController.text.trim(),
        controlsWeight: _thisWeight,
        frequency: _frequency,
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
        controlsDocumentFileEn: _documentEn?.file,
        controlsDocumentUrlEn: _documentEn?.file == null ? _documentEn?.url : null,
        controlsDocumentFileAr: _documentAr?.file,
        controlsDocumentUrlAr: _documentAr?.file == null ? _documentAr?.url : null,
      );
    } else {
      cubit.createControl(
        moduleId: widget.moduleId,
        policyId: widget.policyId,
        controlsNameEn: _nameController.text.trim(),
        controlsNameAr: _nameArController.text.trim(),
        controlsNumberEn: _numberController.text.trim(),
        controlsNumberAr: _numberArController.text.trim(),
        controlsDescriptionEn: _descriptionController.text.trim(),
        controlsDescriptionAr: _descriptionArController.text.trim(),
        controlsWeight: _thisWeight,
        frequency: _frequency!,
        startDate: _startDate!,
        endDate: _endDate!,
        departments: const [],
        equalWeights: false,
        score: 0,
        status: _status,
        controlsDocumentFileEn: _documentEn?.file,
        controlsDocumentFileAr: _documentAr?.file,
      );
    }
  }

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

  Widget _documentButton({required VoidCallback onTap, required String title}) {
    return customButtonWithSvg(
      colorBorder: AppColors.primary,
      space: 10.w,
      radius: 8.r,
      widthImage: 16.w,
      heightImage: 16.h,
      function: onTap,
      title: title,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      image: 'assets/hrAsset/Upload.svg',
      color: AppColors.primary,
      width: 220.w,
      height: 36.h,
      svgColor: AppColors.textButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return BlocProvider(
      create: (_) => GetIt.instance<PolicyCubit>(),
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<PolicyCubit>();
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
                          _isEdit ? 'Edit Control'.tr : 'Add Control'.tr,
                        ],
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15.sp),
                          decoration: BoxDecoration(
                            color: AppColors.field,
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: CustomTextField(
                                              label: 'Control Name'.tr,
                                              hint: 'Text here'.tr,
                                              controller: _nameController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: CustomTextField(
                                                label: 'اسم ضابط',
                                                hint: 'اكتب هنا',
                                                controller: _nameArController,
                                                required: true,
                                                submitted: _submitted,
                                                fillColor: AppColors.background,
                                                onChanged: (_) => setState(() {}),
                                              ),
                                            ),
                                          ),
                                        ])
                                      : Column(children: [
                                          CustomTextField(
                                            label: 'Control Name'.tr,
                                            hint: 'Text here'.tr,
                                            controller: _nameController,
                                            required: true,
                                            submitted: _submitted,
                                            fillColor: AppColors.background,
                                            onChanged: (_) => setState(() {}),
                                          ),
                                          SizedBox(height: 15.h),
                                          Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: CustomTextField(
                                              label: 'اسم ضابط',
                                              hint: 'اكتب هنا',
                                              controller: _nameArController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: CustomTextField(
                                              label: 'Control Number'.tr,
                                              hint: 'Text here'.tr,
                                              controller: _numberController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: CustomTextField(
                                                label: 'رقم ضابط',
                                                hint: 'اكتب هنا',
                                                controller: _numberArController,
                                                required: true,
                                                submitted: _submitted,
                                                fillColor: AppColors.background,
                                                onChanged: (_) => setState(() {}),
                                              ),
                                            ),
                                          ),
                                        ])
                                      : Column(children: [
                                          CustomTextField(
                                            label: 'Control Number'.tr,
                                            hint: 'Text here'.tr,
                                            controller: _numberController,
                                            required: true,
                                            submitted: _submitted,
                                            fillColor: AppColors.background,
                                            onChanged: (_) => setState(() {}),
                                          ),
                                          SizedBox(height: 15.h),
                                          Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: CustomTextField(
                                              label: 'رقم ضابط',
                                              hint: 'اكتب هنا',
                                              controller: _numberArController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  CustomTextField(
                                    label: 'Control Description'.tr,
                                    hint: 'Text here'.tr,
                                    controller: _descriptionController,
                                    required: true,
                                    submitted: _submitted,
                                    maxLines: 3,
                                    minLines: 3,
                                    maxLength: 500,
                                    showCharCount: true,
                                    fillColor: AppColors.background,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  SizedBox(height: 15.h),
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: CustomTextField(
                                      label: 'وصف ضابط',
                                      hint: 'اكتب وصف',
                                      controller: _descriptionArController,
                                      required: true,
                                      submitted: _submitted,
                                      maxLines: 3,
                                      minLines: 3,
                                      maxLength: 500,
                                      showCharCount: true,
                                      fillColor: AppColors.background,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: CustomDropdownCalendar(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              label: 'Start Date'.tr,
                                              hint: 'Select Start Date'.tr,
                                              value: _startDate,
                                              onChanged: (d) =>
                                                  setState(() => _startDate = d),
                                              fillColor: AppColors.background,
                                              errorText: _submitted &&
                                                      _startDate == null
                                                  ? 'This field is required.'.tr
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: CustomDropdownCalendar(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              label: 'End Date'.tr,
                                              hint: 'Select End Date'.tr,
                                              value: _endDate,
                                              onChanged: (d) =>
                                                  setState(() => _endDate = d),
                                              fillColor: AppColors.background,
                                              firstDate: _startDate,
                                              errorText: _submitted &&
                                                      _endDate == null
                                                  ? 'This field is required.'.tr
                                                  : (_endDate != null &&
                                                          _startDate != null &&
                                                          _endDate!.isBefore(
                                                              _startDate!)
                                                      ? 'End date cannot be before start date.'
                                                          .tr
                                                      : null),
                                            ),
                                          ),
                                        ])
                                      : Column(children: [
                                          CustomDropdownCalendar(
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                            label: 'Start Date'.tr,
                                            hint: 'Select Start Date'.tr,
                                            value: _startDate,
                                            onChanged: (d) =>
                                                setState(() => _startDate = d),
                                            fillColor: AppColors.background,
                                            errorText:
                                                _submitted && _startDate == null
                                                    ? 'This field is required.'
                                                        .tr
                                                    : null,
                                          ),
                                          SizedBox(height: 15.h),
                                          CustomDropdownCalendar(
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                            label: 'End Date'.tr,
                                            hint: 'Select End Date'.tr,
                                            value: _endDate,
                                            onChanged: (d) =>
                                                setState(() => _endDate = d),
                                            fillColor: AppColors.background,
                                            firstDate: _startDate,
                                            errorText: _submitted &&
                                                    _endDate == null
                                                ? 'This field is required.'.tr
                                                : (_endDate != null &&
                                                        _startDate != null &&
                                                        _endDate!
                                                            .isBefore(_startDate!)
                                                    ? 'End date cannot be before start date.'
                                                        .tr
                                                    : null),
                                          ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  isTablet
                                      ? Row(children: [
                                          Expanded(
                                            child: CustomDropdown<String>(
                                              label: 'Frequency'.tr,
                                              hint: 'Choose Here'.tr,
                                              items: const [
                                                'Weekly',
                                                'Bi weekly',
                                                'Monthly',
                                                'Quarterly',
                                                'Semi Annual',
                                                'Annually',
                                              ]
                                                  .map((d) => DropdownItem<String>(
                                                      value: d, label: d))
                                                  .toList(),
                                              value: _frequency,
                                              onChanged: (v) =>
                                                  setState(() => _frequency = v),
                                              fillColor: AppColors.background,
                                              errorText: _submitted &&
                                                      _frequency == null
                                                  ? 'This field is required.'.tr
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: CustomTextField(
                                              label: 'Control Weight'.tr,
                                              hint: 'Text Here'.tr,
                                              controller: _weightController,
                                              required: true,
                                              submitted: _submitted,
                                              fillColor: AppColors.background,
                                              errorText: _submitted &&
                                                      double.tryParse(
                                                              _weightController
                                                                  .text
                                                                  .trim()) !=
                                                          null &&
                                                      !_isWeightValid
                                                  ? '${'All controls under this policy must add up to 100 (currently'.tr} ${(_thisWeight + _siblingsWeight).toStringAsFixed(0)}).'
                                                  : null,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ])
                                      : Column(children: [
                                          CustomDropdown<String>(
                                            label: 'Frequency'.tr,
                                            hint: 'Choose Here'.tr,
                                            items: const [
                                              'Weekly',
                                              'Bi weekly',
                                              'Monthly',
                                              'Quarterly',
                                              'Semi Annual',
                                              'Annually',
                                            ]
                                                .map((d) => DropdownItem<String>(
                                                    value: d, label: d))
                                                .toList(),
                                            value: _frequency,
                                            onChanged: (v) =>
                                                setState(() => _frequency = v),
                                            fillColor: AppColors.background,
                                            errorText:
                                                _submitted && _frequency == null
                                                    ? 'This field is required.'
                                                        .tr
                                                    : null,
                                          ),
                                          SizedBox(height: 15.h),
                                          CustomTextField(
                                            label: 'Control Weight'.tr,
                                            hint: 'Text Here'.tr,
                                            controller: _weightController,
                                            required: true,
                                            submitted: _submitted,
                                            fillColor: AppColors.background,
                                            errorText: _submitted &&
                                                    double.tryParse(
                                                            _weightController
                                                                .text
                                                                .trim()) !=
                                                        null &&
                                                    !_isWeightValid
                                                ? '${'All controls under this policy must add up to 100 (currently'.tr} ${(_thisWeight + _siblingsWeight).toStringAsFixed(0)}).'
                                                : null,
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ]),
                                  SizedBox(height: 15.h),
                                  CustomDropdown<ControlStatus>(
                                    label: 'Control Status'.tr,
                                    hint: 'Choose Here'.tr,
                                    items: ControlStatus.values
                                        .map((s) => DropdownItem<ControlStatus>(
                                            value: s, label: s.value.tr))
                                        .toList(),
                                    value: _status,
                                    onChanged: (v) => setState(() => _status = v),
                                    fillColor: AppColors.background,
                                  ),
                                  SizedBox(height: 15.h),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Control Document'.tr,
                                          style: StyleText.fontSize16Weight500
                                              .copyWith(color: AppColors.text)),
                                      const Spacer(),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            _documentEn != null
                                                ? PolicyDocumentPreviewWidget(
                                                    document: _documentEn!,
                                                    onRemove:
                                                        _onRemoveDocumentEn)
                                                : _documentButton(
                                                    onTap: _onUploadDocumentEn,
                                                    title:
                                                        'Upload Document (English)'
                                                            .tr),
                                            SizedBox(height: 10.h),
                                            _documentAr != null
                                                ? PolicyDocumentPreviewWidget(
                                                    document: _documentAr!,
                                                    onRemove:
                                                        _onRemoveDocumentAr)
                                                : _documentButton(
                                                    onTap: _onUploadDocumentAr,
                                                    title: 'رفع المستند (عربي)'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customButton(
                            title: 'Discard'.tr,
                            function: () => Navigator.of(context).pop(),
                            height: 38.h,
                            width: 150.w,
                            color: AppColors.grey,
                            textColor: AppColors.text,
                            borderColor: AppColors.border,
                          ),
                          customButton(
                            title: _isEdit ? 'Save'.tr : 'Add'.tr,
                            function: () {
                              if (!_validate()) return;
                              showConfirmDialog(
                                context: context,
                                title: _isEdit
                                    ? 'Editing Control'.tr
                                    : 'Creating Control'.tr,
                                cancelLabel: 'No'.tr,
                                confirmLabel: 'Yes'.tr,
                                subtitle: _isEdit
                                    ? 'Are You Sure You Want To Edit This Control ?'
                                        .tr
                                    : 'Are You Sure You Want To Create This Control ?'
                                        .tr,
                                onConfirm: () => _onSave(cubit),
                              );
                            },
                            height: 38.h,
                            width: 150.w,
                            color: AppColors.primary,
                            textColor: AppColors.textButton,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/features/grc/presentation/ui/pages/add_edit_control_page.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/add_edit_control_page.dart
git commit -m "feat(grc): add AddEditControlPage with sibling weight-sum validation"
```

---

### Task 5: Wire the Controls list + status filter into Policy Details

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/policy_details_page.dart`

**Interfaces:**
- Consumes: `ControlCardWidget` (Task 2), `AddEditControlPage` (Task 4), `FilterBarItem` (existing, `lib/features/roles/widgets/filter_bar_item.dart`), `PolicyCubit.getAllControls` (existing).

- [ ] **Step 1: Add the new imports**

In `policy_details_page.dart`, add:

```dart
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/features/grc/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/add_edit_control_page.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/control_card_widget.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';
```

(`customButtonWithSvg` is used by the new "+ Control" button in Step 6 — `policy_details_page.dart` didn't need it directly before this task, since it only used `GrcActionButtons`, which imports it internally.)

- [ ] **Step 2: Stop fetching the policy in the `create:` callback; fetch policy then controls sequentially in `initState`**

Replace:

```dart
class PolicyDetailsPage extends StatelessWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const PolicyDetailsPage({
    super.key,
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<PolicyCubit>()..getPolicy(policyId, moduleId: moduleId),
      child: _PolicyDetailsBody(moduleId: moduleId, module: module),
    );
  }
}

class _PolicyDetailsBody extends StatefulWidget {
  final String moduleId;
  final GRCModuleEntity module;

  const _PolicyDetailsBody({required this.moduleId, required this.module});

  @override
  State<_PolicyDetailsBody> createState() => _PolicyDetailsBodyState();
}
```

with:

```dart
class PolicyDetailsPage extends StatelessWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const PolicyDetailsPage({
    super.key,
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<PolicyCubit>(),
      child: _PolicyDetailsBody(
        policyId: policyId,
        moduleId: moduleId,
        module: module,
      ),
    );
  }
}

class _PolicyDetailsBody extends StatefulWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const _PolicyDetailsBody({
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  State<_PolicyDetailsBody> createState() => _PolicyDetailsBodyState();
}
```

- [ ] **Step 3: Add Controls state and the sequential initial load**

In `_PolicyDetailsBodyState`, add these fields alongside the existing ones:

```dart
  List<ControlEntity> _controls = [];
  String _selectedControlStatusFilter = 'all';
```

Add an `initState` (this class did not have one before):

```dart
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final cubit = context.read<PolicyCubit>();
    await cubit.getPolicy(widget.policyId, moduleId: widget.moduleId);
    await cubit.getAllControls(
      moduleId: widget.moduleId,
      policyId: widget.policyId,
    );
  }
```

- [ ] **Step 4: Handle `PolicyControlsListLoaded` in the state listener**

In `_onStateChange`, add this branch right after the `PolicySingleLoaded` branch:

```dart
    if (state is PolicyControlsListLoaded) {
      setState(() => _controls = state.controls);
      return;
    }
```

- [ ] **Step 5: Add the status-filter helper methods**

Add these methods to `_PolicyDetailsBodyState` (near `_infoRow`):

```dart
  ControlStatus? _statusForControlKey(String key) {
    switch (key) {
      case 'Active':
        return ControlStatus.active;
      case 'Inactive':
        return ControlStatus.inactive;
      case 'Expired':
        return ControlStatus.expired;
      case 'Unassigned':
        return ControlStatus.unassigned;
      case 'Draft':
        return ControlStatus.draft;
      default:
        return null;
    }
  }

  List<ControlEntity> _applyControlStatusFilter(List<ControlEntity> controls) {
    final status = _statusForControlKey(_selectedControlStatusFilter);
    if (status == null) return controls;
    return controls.where((c) => c.status == status).toList();
  }

  Map<String, int> _countControlsByStatus(List<ControlEntity> controls) {
    return {
      'all': controls.length,
      'Active': controls.where((c) => c.status == ControlStatus.active).length,
      'Inactive':
          controls.where((c) => c.status == ControlStatus.inactive).length,
      'Expired':
          controls.where((c) => c.status == ControlStatus.expired).length,
      'Unassigned':
          controls.where((c) => c.status == ControlStatus.unassigned).length,
      'Draft': controls.where((c) => c.status == ControlStatus.draft).length,
    };
  }

  List<MapEntry<String, Map<String, dynamic>>> _controlStatusEntries(
      List<ControlEntity> controls) {
    final counts = _countControlsByStatus(controls);
    return [
      MapEntry('all', {'num': counts['all'] ?? 0, 'color': AppColors.text}),
      MapEntry(
          'Active', {'num': counts['Active'] ?? 0, 'color': AppColors.green}),
      MapEntry('Inactive',
          {'num': counts['Inactive'] ?? 0, 'color': AppColors.orange}),
      MapEntry(
          'Expired', {'num': counts['Expired'] ?? 0, 'color': AppColors.red}),
      MapEntry('Unassigned',
          {'num': counts['Unassigned'] ?? 0, 'color': AppColors.blue}),
      MapEntry(
          'Draft', {'num': counts['Draft'] ?? 0, 'color': AppColors.colorGrey}),
    ];
  }

  Future<void> _openAddEditControl({ControlEntity? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddEditControlPage(
          moduleId: widget.moduleId,
          policyId: widget.policyId,
          existingControl: existing,
          siblingControls: _controls,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      context
          .read<PolicyCubit>()
          .getAllControls(moduleId: widget.moduleId, policyId: widget.policyId);
    }
  }
```

- [ ] **Step 6: Append the Controls section to the view-mode body**

Immediately after the `GrcOwnerSection(...)` widget (still inside the `if (_mode == _PolicyPageMode.view) ...[` list, as its last entry before the closing `]`), add:

```dart
                                    SizedBox(height: 20.h),
                                    Text(
                                      'Controls'.tr,
                                      style: StyleText.fontSize16Weight600
                                          .copyWith(color: AppColors.text),
                                    ),
                                    SizedBox(height: 12.h),
                                    ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(scrollbars: false),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          spacing: 24.sp,
                                          children: [
                                            for (final entry
                                                in _controlStatusEntries(
                                                    _controls))
                                              FilterBarItem(
                                                title: entry.key,
                                                numberOfItems:
                                                    entry.value['num'],
                                                color: entry.value['color'],
                                                isSelected: entry.key ==
                                                    _selectedControlStatusFilter,
                                                onTap: () => setState(() =>
                                                    _selectedControlStatusFilter =
                                                        entry.key),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: customButtonWithSvg(
                                        colorBorder: AppColors.primary,
                                        space: 10.w,
                                        radius: 8.r,
                                        widthImage: 16.w,
                                        heightImage: 16.h,
                                        function: () => _openAddEditControl(),
                                        title: 'Control'.tr,
                                        textStyle: StyleText.fontSize14Weight500
                                            .copyWith(
                                                color: AppColors.textButton),
                                        image:
                                            'assets/icons_assets/database_builder_assets/plus_head.svg',
                                        color: AppColors.primary,
                                        svgColor: AppColors.textButton,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    if (_applyControlStatusFilter(_controls)
                                        .isEmpty)
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16.h),
                                        child: Center(
                                          child: Text(
                                            'No Controls found'.tr,
                                            style: StyleText.fontSize14Weight500
                                                .copyWith(
                                                    color:
                                                        AppColors.secondaryText),
                                          ),
                                        ),
                                      )
                                    else
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            _applyControlStatusFilter(_controls)
                                                .length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: 10.h),
                                        itemBuilder: (_, index) =>
                                            ControlCardWidget(
                                          control: _applyControlStatusFilter(
                                              _controls)[index],
                                          onTap: () => _openAddEditControl(
                                            existing: _applyControlStatusFilter(
                                                _controls)[index],
                                          ),
                                        ),
                                      ),
```

- [ ] **Step 7: Verify the whole feature compiles**

Run: `flutter analyze lib/features/grc`
Expected: `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/policy_details_page.dart
git commit -m "feat(grc): add Controls list with status filter to Policy Details, wired to Add/Edit Control"
```
