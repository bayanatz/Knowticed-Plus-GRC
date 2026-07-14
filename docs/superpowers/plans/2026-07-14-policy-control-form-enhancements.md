# Policy/Control Creation Form Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the GRC Policy-creation flow's existing (already-supported-by-the-domain-layer) capability into the UI: EN/AR language validation, real image picking, real EN/AR document upload, new Control Number + Start/End Date fields, and fix the bug where controls/image/documents were never actually sent to `PolicyCubit` on save.

**Architecture:** Pure UI-layer wiring against the existing `PolicyCubit`/`PendingControlInput`/`ControlEntity` API — no domain, use-case, or storage changes. Each task produces a self-contained, manually-verifiable slice of the `CreateNewPolicyPage` flow.

**Tech Stack:** Flutter, `file_picker` (already a dependency, via `showUploadDialog` in `10_custom_upload_document.dart`), `image_picker` (already a dependency, via `CustomImagePicker`), `flutter_bloc`.

## Global Constraints

- No automated widget tests for this feature — this codebase has almost none (3 test files total, none of them UI). Each task's only automated gate is `dart analyze` on the files it touched (compile/lint sanity, not a test). Verification is manual: run the app and walk the described steps.
- English-labeled fields use `'...'.tr` (existing i18n convention). Arabic-labeled fields (fields that are inherently Arabic, e.g. "اسم ضابط") use literal Arabic strings, not `.tr` — this matches the existing convention in `policy_control_item_widget.dart` and `policy_info_form_widget.dart`.
- Language-mismatch validation must show an inline error message and must **never** block typing. Reuse `containsEnglishLetters`/`containsArabicLetters` from `lib/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart` — do not duplicate these functions and do not use `CustomTextField`'s `restrictByDirection` flag (that blocks typing, which is explicitly out of scope).
- Document upload must use `showUploadDialog` from `lib/core/custom/10_custom_upload_document.dart` — this is the canonical implementation (file_picker-backed); `11_custom_confirm_diaolog.dart` has a near-duplicate that is intentionally not used for this.
- No changes to `PolicyCubit`, use cases, repositories, or storage data sources — all required capability already exists there.
- Commit after every task with `git add <files touched by this task>` (never `git add -A`).

---

### Task 1: Policy document upload — real file picking, split into English/Arabic

**Files:**
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart`
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart`
- Modify: `lib/features/grc/presentation/ui/pages/create_new_policy.dart`

**Interfaces:**
- Produces: `PolicyDocumentInfo` gains a `File file` field and a `factory PolicyDocumentInfo.fromPlatformFile(PlatformFile platformFile)`. `PolicyInfoFormWidget` gains `documentEn`/`documentAr` (`PolicyDocumentInfo?`), `onUploadDocumentEn`/`onUploadDocumentAr`/`onRemoveDocumentEn`/`onRemoveDocumentAr` (replacing the old single `document`/`onUploadDocument`/`onRemoveDocument`). `CreateNewPolicyPage` gains `_documentEn`/`_documentAr` state (replacing `_document`).

- [ ] **Step 1: Rewrite `policy_document_info.dart` to carry the actual picked file**

Replace the entire file with:

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
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_document_info.dart
/// Purpose: Contains PolicyDocumentInfo, an immutable model for a picked
///          document's display metadata plus the actual File to upload.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// class name: [PolicyDocumentInfo]
///
/// purpose: immutable value object that carries display metadata (name,
///          formatted size, formatted date) plus the actual [File] to
///          upload for a picked document.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyDocumentInfo {
  final String name;
  final String sizeLabel;
  final String dateLabel;
  final File file;

  const PolicyDocumentInfo({
    required this.name,
    required this.sizeLabel,
    required this.dateLabel,
    required this.file,
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

- [ ] **Step 2: Rewrite `policy_info_form_widget.dart`'s document section to EN/AR**

Replace the entire file with:

```dart
/// Module: GRC Policy Management
/// Description: Multi-field form widget for entering policy information.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, CustomTextField, CustomDropdownCalendar
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split Policy Document into English/Arabic
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_info_form_widget.dart
/// Purpose: Contains PolicyInfoFormWidget, the stateless form for all
///          policy fields — names, numbers, description, dates, weight, document.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'policy_document_preview_widget.dart';

/// class name: [PolicyInfoFormWidget]
///
/// purpose: stateless form that renders all policy data fields.
///          When isArabicEnabled is true, Arabic companion fields appear
///          alongside each English field. The parent page owns all
///          controllers and state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyInfoFormWidget extends StatelessWidget {
  final bool isArabicEnabled;

  /// When true, required fields left empty show an inline red error.
  /// Set by the parent page once the user attempts to submit/advance.
  final bool submitted;

  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;

  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  final PolicyDocumentInfo? documentEn;
  final PolicyDocumentInfo? documentAr;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;

  const PolicyInfoFormWidget({
    super.key,
    required this.isArabicEnabled,
    this.submitted = false,
    required this.nameController,
    required this.nameArController,
    required this.numberController,
    required this.numberArController,
    required this.descriptionController,
    required this.descriptionArController,
    required this.weightController,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    this.documentEn,
    this.documentAr,
  });

  TextStyle get _labelStyle =>
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp);
  TextStyle get _valueStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText);
  TextStyle get _hintStyle => StyleText.fontSize14Weight500
      .copyWith(color: AppColors.secondaryText.withOpacity(.5));

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool rtl = false,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool showCharCount = false,
    bool isMandatory = false,
  }) {
    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      required: true,
      submitted: isMandatory && submitted,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCharCount: showCharCount,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      height: maxLines == null ? 30.h : null,
      valueStyle: _valueStyle,
      hintStyle: _hintStyle,
      labelStyle: _labelStyle,
      onChanged: (_) {},
    );

    if (!rtl) return field;
    return Directionality(textDirection: TextDirection.rtl, child: field);
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
      textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
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

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startBeforeToday =
        startDate != null && startDate!.isBefore(startOfToday);
    final endBeforeStart =
        endDate != null && startDate != null && endDate!.isBefore(startDate!);

    Widget twoColumns(Widget left, Widget right) => isTablet
        ? Row(children: [
            Expanded(child: left),
            SizedBox(width: 10.w),
            Expanded(child: right),
          ])
        : Column(children: [
            left,
            SizedBox(height: 15.h),
            right,
          ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twoColumns(
          _textField(label: 'Policy Name', hint: 'Text here', controller: nameController, isMandatory: true),
          isArabicEnabled
              ? _textField(label: 'اسم السياسة', hint: 'اكتب هنا', controller: nameArController, rtl: true, isMandatory: true)
              : _textField(label: 'Policy Number', hint: 'Text here', controller: numberController, isMandatory: true),
        ),
        SizedBox(height: 15.h),
        if (isArabicEnabled) ...[
          twoColumns(
            _textField(label: 'Policy Number', hint: 'Text here', controller: numberController, isMandatory: true),
            _textField(label: 'رقم السياسة', hint: 'اكتب هنا', controller: numberArController, rtl: true, isMandatory: true),
          ),
          SizedBox(height: 15.h),
        ],
        _textField(
          label: 'Policy Description',
          hint: 'Text here',
          controller: descriptionController,
          maxLines: 3,
          minLines: 3,
          maxLength: 500,
          showCharCount: true,
          isMandatory: true,
        ),
        SizedBox(height: 15.h),
        if (isArabicEnabled) ...[
          _textField(
            label: 'وصف السياسة',
            hint: 'اكتب وصف',
            controller: descriptionArController,
            rtl: true,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
            isMandatory: true,
          ),
          SizedBox(height: 15.h),
        ],
        twoColumns(
          CustomDropdownCalendar(
            borderRadius: BorderRadius.circular(4.r),
            label: 'Start Date',
            hint: 'Select Start Date',
            value: startDate,
            onChanged: onStartDateChanged,
            fillColor: AppColors.background,
            labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
            required: false,
            firstDate: startOfToday,
            errorText: !submitted
                ? null
                : startDate == null
                    ? 'This field is required.'
                    : startBeforeToday
                        ? 'Start date cannot be before today.'
                        : null,
          ),
          CustomDropdownCalendar(
            borderRadius: BorderRadius.circular(4.r),
            label: 'End Date',
            hint: 'Select End Date',
            value: endDate,
            onChanged: onEndDateChanged,
            fillColor: AppColors.background,
            labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
            required: false,
            firstDate: startDate ?? startOfToday,
            errorText: !submitted
                ? null
                : endDate == null
                    ? 'This field is required.'
                    : endBeforeStart
                        ? 'End date cannot be before start date.'
                        : null,
          ),
        ),
        SizedBox(height: 15.h),
        isTablet
            ? Row(children: [
                Expanded(child: _textField(label: 'Policy Weight', hint: 'Text here', controller: weightController, isMandatory: true)),
                SizedBox(width: 10.w),
                const Expanded(child: SizedBox()),
              ])
            : _textField(label: 'Policy Weight', hint: 'Text here', controller: weightController, isMandatory: true),
        SizedBox(height: 15.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Policy Document', style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
            const Spacer(),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  documentEn != null
                      ? PolicyDocumentPreviewWidget(document: documentEn!, onRemove: onRemoveDocumentEn)
                      : _documentButton(onTap: onUploadDocumentEn, title: 'Upload Document (English)'),
                  if (isArabicEnabled) ...[
                    SizedBox(height: 10.h),
                    documentAr != null
                        ? PolicyDocumentPreviewWidget(document: documentAr!, onRemove: onRemoveDocumentAr)
                        : _documentButton(onTap: onUploadDocumentAr, title: 'رفع المستند (عربي)'),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}
```

- [ ] **Step 3: Wire real upload into `create_new_policy.dart`**

Add this import right after the existing `11_custom_confirm_diaolog.dart` import (around line 23):

```dart
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
```

Replace:
```dart
  DateTime? _startDate;
  DateTime? _endDate;
  PolicyDocumentInfo? _document;
```
with:
```dart
  DateTime? _startDate;
  DateTime? _endDate;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;
```

Replace:
```dart
  void _onUploadDocument() {
    setState(() {
      _document = const PolicyDocumentInfo(
        name: 'Submission 1.pdf',
        sizeLabel: '62 KB',
        dateLabel: '28 Dec 2023',
      );
    });
  }
```
with:
```dart
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
```

In `_buildStep0()`, replace:
```dart
              PolicyInfoFormWidget(
                isArabicEnabled: _isArabicEnabled,
                submitted: _step0Submitted,
                nameController: _nameController,
                nameArController: _nameArController,
                numberController: _numberController,
                numberArController: _numberArController,
                descriptionController: _descriptionController,
                descriptionArController: _descriptionArController,
                weightController: _weightController,
                startDate: _startDate,
                endDate: _endDate,
                onStartDateChanged: _onStartDateChanged,
                onEndDateChanged: (d) => setState(() => _endDate = d),
                document: _document,
                onUploadDocument: _onUploadDocument,
                onRemoveDocument: () => setState(() => _document = null),
              ),
```
with:
```dart
              PolicyInfoFormWidget(
                isArabicEnabled: _isArabicEnabled,
                submitted: _step0Submitted,
                nameController: _nameController,
                nameArController: _nameArController,
                numberController: _numberController,
                numberArController: _numberArController,
                descriptionController: _descriptionController,
                descriptionArController: _descriptionArController,
                weightController: _weightController,
                startDate: _startDate,
                endDate: _endDate,
                onStartDateChanged: _onStartDateChanged,
                onEndDateChanged: (d) => setState(() => _endDate = d),
                documentEn: _documentEn,
                documentAr: _documentAr,
                onUploadDocumentEn: _onUploadDocumentEn,
                onUploadDocumentAr: _onUploadDocumentAr,
                onRemoveDocumentEn: () => setState(() => _documentEn = null),
                onRemoveDocumentAr: () => setState(() => _documentAr = null),
              ),
```

In `_buildStep2()`, replace:
```dart
              child: PolicyInfoFormWidget(
                isArabicEnabled: _isArabicEnabled,
                nameController: _nameController,
                nameArController: _nameArController,
                numberController: _numberController,
                numberArController: _numberArController,
                descriptionController: _descriptionController,
                descriptionArController: _descriptionArController,
                weightController: _weightController,
                startDate: _startDate,
                endDate: _endDate,
                onStartDateChanged: (_) {},
                onEndDateChanged: (_) {},
                document: _document,
                onUploadDocument: () {},
                onRemoveDocument: () {},
              ),
```
with:
```dart
              child: PolicyInfoFormWidget(
                isArabicEnabled: _isArabicEnabled,
                nameController: _nameController,
                nameArController: _nameArController,
                numberController: _numberController,
                numberArController: _numberArController,
                descriptionController: _descriptionController,
                descriptionArController: _descriptionArController,
                weightController: _weightController,
                startDate: _startDate,
                endDate: _endDate,
                onStartDateChanged: (_) {},
                onEndDateChanged: (_) {},
                documentEn: _documentEn,
                documentAr: _documentAr,
                onUploadDocumentEn: () {},
                onUploadDocumentAr: () {},
                onRemoveDocumentEn: () {},
                onRemoveDocumentAr: () {},
              ),
```

- [ ] **Step 4: Compile sanity check**

Run: `dart analyze lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart lib/features/grc/presentation/ui/pages/create_new_policy.dart`
Expected: no `error` level issues (pre-existing `info`/`deprecated_member_use` warnings elsewhere in the file are fine).

- [ ] **Step 5: Manual verification**

Run the app, open GRC → Create New Policy. On step 0, tap "Upload Document (English)", pick any file, fill the dialog's title, submit — confirm a preview chip with the file name/size appears in place of the button. Toggle "Create Arabic Version" on — confirm a second "رفع المستند (عربي)" button appears; upload an Arabic-labeled file the same way — confirm both chips are shown independently and each can be removed independently.

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart lib/features/grc/presentation/ui/pages/create_new_policy.dart
git commit -m "feat(grc): real EN/AR document upload for Policy creation"
```

---

### Task 2: Control document upload — real file picking, split into English/Arabic

**Files:**
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart`
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart`
- Modify: `lib/features/grc/presentation/ui/pages/add_policy_controls.dart`

**Interfaces:**
- Consumes: `PolicyDocumentInfo`/`PolicyDocumentInfo.fromPlatformFile` from Task 1.
- Produces: `PolicyControlModel` gains `documentEn`/`documentAr` (`PolicyDocumentInfo?`), replacing `document`. `PolicyControlItemWidget` gains `onUploadDocumentEn`/`onUploadDocumentAr`/`onRemoveDocumentEn`/`onRemoveDocumentAr`, replacing `onUploadDocument`/`onRemoveDocument`.

- [ ] **Step 1: Split `document` into `documentEn`/`documentAr` in `policy_control_model.dart`**

Replace the entire file with:

```dart
/// Module: GRC Policy Management
/// Description: Data model for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split single `document` into `documentEn`/`documentAr`
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_control_model.dart
/// Purpose: Contains PolicyControlModel, the model holding text controllers
///          and state for a single control card in the controls list.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:flutter/material.dart';

import 'policy_document_info.dart';

/// class name: [PolicyControlModel]
///
/// purpose: holds the TextEditingControllers and mutable state for one
///          control card. Each item in AddPolicyControlsPage's list is
///          an independent instance of this model.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyControlModel {
  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;

  String? frequency;
  PolicyDocumentInfo? documentEn;
  PolicyDocumentInfo? documentAr;

  PolicyControlModel({
    TextEditingController? nameController,
    TextEditingController? nameArController,
    TextEditingController? descriptionController,
    TextEditingController? descriptionArController,
    TextEditingController? weightController,
    this.frequency,
    this.documentEn,
    this.documentAr,
  })  : nameController = nameController ?? TextEditingController(),
        nameArController = nameArController ?? TextEditingController(),
        descriptionController =
            descriptionController ?? TextEditingController(),
        descriptionArController =
            descriptionArController ?? TextEditingController(),
        weightController = weightController ?? TextEditingController();

  void dispose() {
    nameController.dispose();
    nameArController.dispose();
    descriptionController.dispose();
    descriptionArController.dispose();
    weightController.dispose();
  }
}
```

- [ ] **Step 2: Update `policy_control_item_widget.dart`'s document section**

Replace the entire file with:

```dart
/// Module: GRC Policy Management
/// Description: Card widget for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyControlModel, PolicyDocumentPreviewWidget
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split Control Document into English/Arabic
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_control_item_widget.dart
/// Purpose: Contains PolicyControlItemWidget, a card widget that renders
///          all fields for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'policy_document_preview_widget.dart';

/// class name: [PolicyControlItemWidget]
///
/// purpose: stateless card that renders all input fields for one
///          PolicyControlModel. The parent list widget owns the state and
///          passes callbacks for document upload, removal, and frequency change.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyControlItemWidget extends StatelessWidget {
  final PolicyControlModel control;
  final bool isArabicEnabled;
  final bool showRemoveButton;
  final VoidCallback? onRemove;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;
  final ValueChanged<String?> onFrequencyChanged;

  const PolicyControlItemWidget({
    super.key,
    required this.control,
    required this.isArabicEnabled,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    required this.onFrequencyChanged,
    this.showRemoveButton = false,
    this.onRemove,
  });

  TextStyle get _labelStyle =>
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp);
  TextStyle get _valueStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText);
  TextStyle get _hintStyle => StyleText.fontSize14Weight500
      .copyWith(color: AppColors.secondaryText.withOpacity(.5));

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool rtl = false,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool showCharCount = false,
  }) {
    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      required: true,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCharCount: showCharCount,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      height: maxLines == null ? 30.h : null,
      valueStyle: _valueStyle,
      hintStyle: _hintStyle,
      labelStyle: _labelStyle,
      onChanged: (_) {},
    );

    if (!rtl) return field;
    return Directionality(textDirection: TextDirection.rtl, child: field);
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
      textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
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

    final frequencyField = CustomDropdown<String>(
      label: 'Frequency',
      hint: 'Choose Here',
      items: const [
        'Weekly',
        'Bi weekly',
        'Monthly',
        'Quarterly',
        'Semi Annual',
        'Annually',
      ].map((d) => DropdownItem<String>(value: d, label: d)).toList(),
      value: control.frequency,
      onChanged: onFrequencyChanged,
      fillColor: AppColors.background,
      labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      itemStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      triggerPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      borderRadius: BorderRadius.circular(4.r),
      required: false,
    );

    final weightField = _textField(
      label: 'Control Weight',
      hint: 'Text Here',
      controller: control.weightController,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showRemoveButton)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onRemove,
                child: Icon(Icons.close,
                    color: AppColors.secondaryText, size: 18.sp),
              ),
            ),
          if (isArabicEnabled && isTablet)
            Row(children: [
              Expanded(
                child: _textField(
                    label: 'Control Name',
                    hint: 'Text here',
                    controller: control.nameController),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _textField(
                    label: 'اسم ضابط',
                    hint: 'اكتب هنا',
                    controller: control.nameArController,
                    rtl: true),
              ),
            ])
          else ...[
            _textField(
                label: 'Control Name',
                hint: 'Text here',
                controller: control.nameController),
            if (isArabicEnabled) ...[
              SizedBox(height: 15.h),
              _textField(
                  label: 'اسم ضابط',
                  hint: 'اكتب هنا',
                  controller: control.nameArController,
                  rtl: true),
            ],
          ],
          SizedBox(height: 15.h),
          _textField(
            label: 'Control Description',
            hint: 'Text here',
            controller: control.descriptionController,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
          ),
          SizedBox(height: 15.h),
          if (isArabicEnabled) ...[
            _textField(
              label: 'وصف ضابط',
              hint: 'اكتب وصف',
              controller: control.descriptionArController,
              rtl: true,
              maxLines: 3,
              minLines: 3,
              maxLength: 500,
              showCharCount: true,
            ),
            SizedBox(height: 15.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Control Document',
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text)),
              const Spacer(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    control.documentEn != null
                        ? PolicyDocumentPreviewWidget(
                            document: control.documentEn!,
                            onRemove: onRemoveDocumentEn,
                          )
                        : _documentButton(
                            onTap: onUploadDocumentEn,
                            title: 'Upload Document (English)',
                          ),
                    if (isArabicEnabled) ...[
                      SizedBox(height: 10.h),
                      control.documentAr != null
                          ? PolicyDocumentPreviewWidget(
                              document: control.documentAr!,
                              onRemove: onRemoveDocumentAr,
                            )
                          : _documentButton(
                              onTap: onUploadDocumentAr,
                              title: 'رفع المستند (عربي)',
                            ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          isTablet
              ? Row(children: [
                  Expanded(child: frequencyField),
                  SizedBox(width: 10.w),
                  Expanded(child: weightField),
                ])
              : Column(children: [
                  frequencyField,
                  SizedBox(height: 15.h),
                  weightField,
                ]),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Wire real upload into `add_policy_controls.dart`**

Add this import after the existing `policy_document_info.dart` import:

```dart
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
```

Replace:
```dart
  void _onUploadDocument(int index) {
    setState(() {
      _controls[index].document = const PolicyDocumentInfo(
        name: 'Control Doc.pdf',
        sizeLabel: '40 KB',
        dateLabel: '28 Dec 2023',
      );
    });
  }
```
with:
```dart
  void _onUploadDocumentEn(int index) {
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
        setState(() =>
            _controls[index].documentEn = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }

  void _onUploadDocumentAr(int index) {
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
        setState(() =>
            _controls[index].documentAr = PolicyDocumentInfo.fromPlatformFile(file));
      },
    );
  }
```

Replace the `PolicyControlItemWidget(...)` instantiation:
```dart
                    PolicyControlItemWidget(
                      key: ValueKey(_controls[i]),
                      control: _controls[i],
                      isArabicEnabled: widget.isArabicEnabled,
                      showRemoveButton: _controls.length > 1,
                      onRemove: () => _removeControl(i),
                      onUploadDocument: () => _onUploadDocument(i),
                      onRemoveDocument: () =>
                          setState(() => _controls[i].document = null),
                      onFrequencyChanged: (value) =>
                          setState(() => _controls[i].frequency = value),
                    ),
```
with:
```dart
                    PolicyControlItemWidget(
                      key: ValueKey(_controls[i]),
                      control: _controls[i],
                      isArabicEnabled: widget.isArabicEnabled,
                      showRemoveButton: _controls.length > 1,
                      onRemove: () => _removeControl(i),
                      onUploadDocumentEn: () => _onUploadDocumentEn(i),
                      onUploadDocumentAr: () => _onUploadDocumentAr(i),
                      onRemoveDocumentEn: () =>
                          setState(() => _controls[i].documentEn = null),
                      onRemoveDocumentAr: () =>
                          setState(() => _controls[i].documentAr = null),
                      onFrequencyChanged: (value) =>
                          setState(() => _controls[i].frequency = value),
                    ),
```

- [ ] **Step 4: Compile sanity check**

Run: `dart analyze lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart lib/features/grc/presentation/ui/pages/add_policy_controls.dart`
Expected: no `error` level issues.

- [ ] **Step 5: Manual verification**

Run the app, open GRC → Create New Policy, advance to step 1 (Controls). On the default control card, tap "Upload Document (English)", pick a file, submit — confirm a preview chip appears. With "Create Arabic Version" toggled on (from step 0), confirm the Arabic upload button also appears on the control card and works independently. Add a second control card and confirm each card's document state is independent (uploading on one doesn't affect the other).

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart lib/features/grc/presentation/ui/pages/add_policy_controls.dart
git commit -m "feat(grc): real EN/AR document upload for Control creation"
```

---

### Task 3: Policy field language validation (Name/Number/Description)

**Files:**
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart`

**Interfaces:**
- Consumes: `containsEnglishLetters`/`containsArabicLetters` from `lib/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart`.
- Produces: `PolicyInfoFormWidget` becomes a `StatefulWidget` (same public constructor signature as after Task 1 — no caller changes needed).

- [ ] **Step 1: Convert to StatefulWidget with live language validation**

Replace the entire file with:

```dart
/// Module: GRC Policy Management
/// Description: Multi-field form widget for entering policy information.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, CustomTextField, CustomDropdownCalendar
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split Policy Document into English/Arabic
///                   2026-07-14 - Converted to StatefulWidget; added
///                                English/Arabic language-mismatch validation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_info_form_widget.dart
/// Purpose: Contains PolicyInfoFormWidget, the form for all policy fields —
///          names, numbers, description, dates, weight, document. Validates
///          that EN fields contain no Arabic letters and vice versa.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'policy_document_preview_widget.dart';

class PolicyInfoFormWidget extends StatefulWidget {
  final bool isArabicEnabled;
  final bool submitted;

  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;

  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  final PolicyDocumentInfo? documentEn;
  final PolicyDocumentInfo? documentAr;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;

  const PolicyInfoFormWidget({
    super.key,
    required this.isArabicEnabled,
    this.submitted = false,
    required this.nameController,
    required this.nameArController,
    required this.numberController,
    required this.numberArController,
    required this.descriptionController,
    required this.descriptionArController,
    required this.weightController,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    this.documentEn,
    this.documentAr,
  });

  @override
  State<PolicyInfoFormWidget> createState() => _PolicyInfoFormWidgetState();
}

class _PolicyInfoFormWidgetState extends State<PolicyInfoFormWidget> {
  List<TextEditingController> get _bilingualControllers => [
        widget.nameController,
        widget.nameArController,
        widget.numberController,
        widget.numberArController,
        widget.descriptionController,
        widget.descriptionArController,
      ];

  @override
  void initState() {
    super.initState();
    for (final c in _bilingualControllers) {
      c.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _bilingualControllers) {
      c.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  TextStyle get _labelStyle =>
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp);
  TextStyle get _valueStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText);
  TextStyle get _hintStyle => StyleText.fontSize14Weight500
      .copyWith(color: AppColors.secondaryText.withOpacity(.5));

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool rtl = false,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool showCharCount = false,
    bool isMandatory = false,
    String? englishOnlyError,
    String? arabicOnlyError,
  }) {
    final languageError = rtl
        ? (containsEnglishLetters(controller.text) ? arabicOnlyError : null)
        : (containsArabicLetters(controller.text) ? englishOnlyError : null);

    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      required: true,
      submitted: isMandatory && widget.submitted,
      errorText: languageError,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCharCount: showCharCount,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      height: maxLines == null ? 30.h : null,
      valueStyle: _valueStyle,
      hintStyle: _hintStyle,
      labelStyle: _labelStyle,
      onChanged: (_) {},
    );

    if (!rtl) return field;
    return Directionality(textDirection: TextDirection.rtl, child: field);
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
      textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
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

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startBeforeToday =
        widget.startDate != null && widget.startDate!.isBefore(startOfToday);
    final endBeforeStart = widget.endDate != null &&
        widget.startDate != null &&
        widget.endDate!.isBefore(widget.startDate!);

    Widget twoColumns(Widget left, Widget right) => isTablet
        ? Row(children: [
            Expanded(child: left),
            SizedBox(width: 10.w),
            Expanded(child: right),
          ])
        : Column(children: [
            left,
            SizedBox(height: 15.h),
            right,
          ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twoColumns(
          _textField(
            label: 'Policy Name',
            hint: 'Text here',
            controller: widget.nameController,
            isMandatory: true,
            englishOnlyError: 'Policy Name must be written in English',
          ),
          widget.isArabicEnabled
              ? _textField(
                  label: 'اسم السياسة',
                  hint: 'اكتب هنا',
                  controller: widget.nameArController,
                  rtl: true,
                  isMandatory: true,
                  arabicOnlyError: 'يجب كتابة اسم السياسة باللغة العربية',
                )
              : _textField(
                  label: 'Policy Number',
                  hint: 'Text here',
                  controller: widget.numberController,
                  isMandatory: true,
                  englishOnlyError: 'Policy Number must be written in English',
                ),
        ),
        SizedBox(height: 15.h),
        if (widget.isArabicEnabled) ...[
          twoColumns(
            _textField(
              label: 'Policy Number',
              hint: 'Text here',
              controller: widget.numberController,
              isMandatory: true,
              englishOnlyError: 'Policy Number must be written in English',
            ),
            _textField(
              label: 'رقم السياسة',
              hint: 'اكتب هنا',
              controller: widget.numberArController,
              rtl: true,
              isMandatory: true,
              arabicOnlyError: 'يجب كتابة رقم السياسة باللغة العربية',
            ),
          ),
          SizedBox(height: 15.h),
        ],
        _textField(
          label: 'Policy Description',
          hint: 'Text here',
          controller: widget.descriptionController,
          maxLines: 3,
          minLines: 3,
          maxLength: 500,
          showCharCount: true,
          isMandatory: true,
          englishOnlyError: 'Policy Description must be written in English',
        ),
        SizedBox(height: 15.h),
        if (widget.isArabicEnabled) ...[
          _textField(
            label: 'وصف السياسة',
            hint: 'اكتب وصف',
            controller: widget.descriptionArController,
            rtl: true,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
            isMandatory: true,
            arabicOnlyError: 'يجب كتابة وصف السياسة باللغة العربية',
          ),
          SizedBox(height: 15.h),
        ],
        twoColumns(
          CustomDropdownCalendar(
            borderRadius: BorderRadius.circular(4.r),
            label: 'Start Date',
            hint: 'Select Start Date',
            value: widget.startDate,
            onChanged: widget.onStartDateChanged,
            fillColor: AppColors.background,
            labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
            required: false,
            firstDate: startOfToday,
            errorText: !widget.submitted
                ? null
                : widget.startDate == null
                    ? 'This field is required.'
                    : startBeforeToday
                        ? 'Start date cannot be before today.'
                        : null,
          ),
          CustomDropdownCalendar(
            borderRadius: BorderRadius.circular(4.r),
            label: 'End Date',
            hint: 'Select End Date',
            value: widget.endDate,
            onChanged: widget.onEndDateChanged,
            fillColor: AppColors.background,
            labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
            required: false,
            firstDate: widget.startDate ?? startOfToday,
            errorText: !widget.submitted
                ? null
                : widget.endDate == null
                    ? 'This field is required.'
                    : endBeforeStart
                        ? 'End date cannot be before start date.'
                        : null,
          ),
        ),
        SizedBox(height: 15.h),
        isTablet
            ? Row(children: [
                Expanded(
                  child: _textField(
                    label: 'Policy Weight',
                    hint: 'Text here',
                    controller: widget.weightController,
                    isMandatory: true,
                  ),
                ),
                SizedBox(width: 10.w),
                const Expanded(child: SizedBox()),
              ])
            : _textField(
                label: 'Policy Weight',
                hint: 'Text here',
                controller: widget.weightController,
                isMandatory: true,
              ),
        SizedBox(height: 15.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Policy Document', style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
            const Spacer(),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget.documentEn != null
                      ? PolicyDocumentPreviewWidget(document: widget.documentEn!, onRemove: widget.onRemoveDocumentEn)
                      : _documentButton(onTap: widget.onUploadDocumentEn, title: 'Upload Document (English)'),
                  if (widget.isArabicEnabled) ...[
                    SizedBox(height: 10.h),
                    widget.documentAr != null
                        ? PolicyDocumentPreviewWidget(document: widget.documentAr!, onRemove: widget.onRemoveDocumentAr)
                        : _documentButton(onTap: widget.onUploadDocumentAr, title: 'رفع المستند (عربي)'),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}
```

- [ ] **Step 2: Compile sanity check**

Run: `dart analyze lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart`
Expected: no `error` level issues.

- [ ] **Step 3: Manual verification**

Run the app, open Create New Policy step 0. Type Arabic characters into "Policy Name" (English field) — confirm a red "Policy Name must be written in English" message appears live as you type, and that typing is never blocked. Clear it and type valid English — error disappears. Toggle Arabic on, type English characters into "اسم السياسة" — confirm the Arabic error message appears. Repeat for Policy Number and Policy Description.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart
git commit -m "feat(grc): English/Arabic language-mismatch validation for Policy fields"
```

---

### Task 4: Control field language validation + Control Number field

**Files:**
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart`
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart`

**Interfaces:**
- Consumes: `containsEnglishLetters`/`containsArabicLetters` from `grc_form_fields.dart` (same as Task 3).
- Produces: `PolicyControlModel` gains `numberController`/`numberArController`. `PolicyControlItemWidget` becomes a `StatefulWidget` (same public constructor signature as after Task 2 — no caller changes needed).

- [ ] **Step 1: Add Control Number controllers to `policy_control_model.dart`**

Replace the entire file with:

```dart
/// Module: GRC Policy Management
/// Description: Data model for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split single `document` into `documentEn`/`documentAr`
///                   2026-07-14 - Added Control Number (EN/AR) controllers
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_control_model.dart
/// Purpose: Contains PolicyControlModel, the model holding text controllers
///          and state for a single control card in the controls list.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:flutter/material.dart';

import 'policy_document_info.dart';

class PolicyControlModel {
  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;

  String? frequency;
  PolicyDocumentInfo? documentEn;
  PolicyDocumentInfo? documentAr;

  PolicyControlModel({
    TextEditingController? nameController,
    TextEditingController? nameArController,
    TextEditingController? numberController,
    TextEditingController? numberArController,
    TextEditingController? descriptionController,
    TextEditingController? descriptionArController,
    TextEditingController? weightController,
    this.frequency,
    this.documentEn,
    this.documentAr,
  })  : nameController = nameController ?? TextEditingController(),
        nameArController = nameArController ?? TextEditingController(),
        numberController = numberController ?? TextEditingController(),
        numberArController = numberArController ?? TextEditingController(),
        descriptionController =
            descriptionController ?? TextEditingController(),
        descriptionArController =
            descriptionArController ?? TextEditingController(),
        weightController = weightController ?? TextEditingController();

  void dispose() {
    nameController.dispose();
    nameArController.dispose();
    numberController.dispose();
    numberArController.dispose();
    descriptionController.dispose();
    descriptionArController.dispose();
    weightController.dispose();
  }
}
```

- [ ] **Step 2: Convert `policy_control_item_widget.dart` to StatefulWidget, add Control Number field and validation**

Replace the entire file with:

```dart
/// Module: GRC Policy Management
/// Description: Card widget for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyControlModel, PolicyDocumentPreviewWidget
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split Control Document into English/Arabic
///                   2026-07-14 - Converted to StatefulWidget; added Control
///                                Number field and English/Arabic
///                                language-mismatch validation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_control_item_widget.dart
/// Purpose: Contains PolicyControlItemWidget, a card widget that renders
///          all fields for a single policy control entry. Validates that EN
///          fields contain no Arabic letters and vice versa.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'policy_document_preview_widget.dart';

class PolicyControlItemWidget extends StatefulWidget {
  final PolicyControlModel control;
  final bool isArabicEnabled;
  final bool showRemoveButton;
  final VoidCallback? onRemove;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;
  final ValueChanged<String?> onFrequencyChanged;

  const PolicyControlItemWidget({
    super.key,
    required this.control,
    required this.isArabicEnabled,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    required this.onFrequencyChanged,
    this.showRemoveButton = false,
    this.onRemove,
  });

  @override
  State<PolicyControlItemWidget> createState() =>
      _PolicyControlItemWidgetState();
}

class _PolicyControlItemWidgetState extends State<PolicyControlItemWidget> {
  List<TextEditingController> get _bilingualControllers => [
        widget.control.nameController,
        widget.control.nameArController,
        widget.control.numberController,
        widget.control.numberArController,
        widget.control.descriptionController,
        widget.control.descriptionArController,
      ];

  @override
  void initState() {
    super.initState();
    for (final c in _bilingualControllers) {
      c.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _bilingualControllers) {
      c.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  TextStyle get _labelStyle =>
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp);
  TextStyle get _valueStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText);
  TextStyle get _hintStyle => StyleText.fontSize14Weight500
      .copyWith(color: AppColors.secondaryText.withOpacity(.5));

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool rtl = false,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool showCharCount = false,
    String? englishOnlyError,
    String? arabicOnlyError,
  }) {
    final languageError = rtl
        ? (containsEnglishLetters(controller.text) ? arabicOnlyError : null)
        : (containsArabicLetters(controller.text) ? englishOnlyError : null);

    final field = CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      required: true,
      errorText: languageError,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      showCharCount: showCharCount,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      height: maxLines == null ? 30.h : null,
      valueStyle: _valueStyle,
      hintStyle: _hintStyle,
      labelStyle: _labelStyle,
      onChanged: (_) {},
    );

    if (!rtl) return field;
    return Directionality(textDirection: TextDirection.rtl, child: field);
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
      textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      image: 'assets/hrAsset/Upload.svg',
      color: AppColors.primary,
      width: 220.w,
      height: 36.h,
      svgColor: AppColors.textButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.control;
    final isArabicEnabled = widget.isArabicEnabled;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final frequencyField = CustomDropdown<String>(
      label: 'Frequency',
      hint: 'Choose Here',
      items: const [
        'Weekly',
        'Bi weekly',
        'Monthly',
        'Quarterly',
        'Semi Annual',
        'Annually',
      ].map((d) => DropdownItem<String>(value: d, label: d)).toList(),
      value: control.frequency,
      onChanged: widget.onFrequencyChanged,
      fillColor: AppColors.background,
      labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      itemStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      triggerPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      borderRadius: BorderRadius.circular(4.r),
      required: false,
    );

    final weightField = _textField(
      label: 'Control Weight',
      hint: 'Text Here',
      controller: control.weightController,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showRemoveButton)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: widget.onRemove,
                child: Icon(Icons.close,
                    color: AppColors.secondaryText, size: 18.sp),
              ),
            ),
          if (isArabicEnabled && isTablet)
            Row(children: [
              Expanded(
                child: _textField(
                  label: 'Control Name',
                  hint: 'Text here',
                  controller: control.nameController,
                  englishOnlyError: 'Control Name must be written in English',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _textField(
                  label: 'اسم ضابط',
                  hint: 'اكتب هنا',
                  controller: control.nameArController,
                  rtl: true,
                  arabicOnlyError: 'يجب كتابة اسم ضابط باللغة العربية',
                ),
              ),
            ])
          else ...[
            _textField(
              label: 'Control Name',
              hint: 'Text here',
              controller: control.nameController,
              englishOnlyError: 'Control Name must be written in English',
            ),
            if (isArabicEnabled) ...[
              SizedBox(height: 15.h),
              _textField(
                label: 'اسم ضابط',
                hint: 'اكتب هنا',
                controller: control.nameArController,
                rtl: true,
                arabicOnlyError: 'يجب كتابة اسم ضابط باللغة العربية',
              ),
            ],
          ],
          SizedBox(height: 15.h),
          if (isArabicEnabled && isTablet)
            Row(children: [
              Expanded(
                child: _textField(
                  label: 'Control Number',
                  hint: 'Text here',
                  controller: control.numberController,
                  englishOnlyError: 'Control Number must be written in English',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _textField(
                  label: 'رقم ضابط',
                  hint: 'اكتب هنا',
                  controller: control.numberArController,
                  rtl: true,
                  arabicOnlyError: 'يجب كتابة رقم ضابط باللغة العربية',
                ),
              ),
            ])
          else ...[
            _textField(
              label: 'Control Number',
              hint: 'Text here',
              controller: control.numberController,
              englishOnlyError: 'Control Number must be written in English',
            ),
            if (isArabicEnabled) ...[
              SizedBox(height: 15.h),
              _textField(
                label: 'رقم ضابط',
                hint: 'اكتب هنا',
                controller: control.numberArController,
                rtl: true,
                arabicOnlyError: 'يجب كتابة رقم ضابط باللغة العربية',
              ),
            ],
          ],
          SizedBox(height: 15.h),
          _textField(
            label: 'Control Description',
            hint: 'Text here',
            controller: control.descriptionController,
            maxLines: 3,
            minLines: 3,
            maxLength: 500,
            showCharCount: true,
            englishOnlyError: 'Control Description must be written in English',
          ),
          SizedBox(height: 15.h),
          if (isArabicEnabled) ...[
            _textField(
              label: 'وصف ضابط',
              hint: 'اكتب وصف',
              controller: control.descriptionArController,
              rtl: true,
              maxLines: 3,
              minLines: 3,
              maxLength: 500,
              showCharCount: true,
              arabicOnlyError: 'يجب كتابة وصف ضابط باللغة العربية',
            ),
            SizedBox(height: 15.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Control Document',
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text)),
              const Spacer(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    control.documentEn != null
                        ? PolicyDocumentPreviewWidget(
                            document: control.documentEn!,
                            onRemove: widget.onRemoveDocumentEn,
                          )
                        : _documentButton(
                            onTap: widget.onUploadDocumentEn,
                            title: 'Upload Document (English)',
                          ),
                    if (isArabicEnabled) ...[
                      SizedBox(height: 10.h),
                      control.documentAr != null
                          ? PolicyDocumentPreviewWidget(
                              document: control.documentAr!,
                              onRemove: widget.onRemoveDocumentAr,
                            )
                          : _documentButton(
                              onTap: widget.onUploadDocumentAr,
                              title: 'رفع المستند (عربي)',
                            ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          isTablet
              ? Row(children: [
                  Expanded(child: frequencyField),
                  SizedBox(width: 10.w),
                  Expanded(child: weightField),
                ])
              : Column(children: [
                  frequencyField,
                  SizedBox(height: 15.h),
                  weightField,
                ]),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Compile sanity check**

Run: `dart analyze lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart`
Expected: no `error` level issues.

- [ ] **Step 4: Manual verification**

Run the app, open Create New Policy, advance to step 1. Confirm a "Control Number" field appears right below "Control Name" on the control card. Type Arabic text into it — confirm the English-only error message appears live. Toggle "Create Arabic Version" on — confirm "رقم ضابط" appears next to/below it, and typing English into it shows the Arabic-only error. Confirm existing Name/Description validation still works the same way (per Task 3's manual check, applied to the Control card this time).

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart
git commit -m "feat(grc): Control Number field and language-mismatch validation for Control fields"
```

---

### Task 5: Control Start/End Date fields, constrained to the Policy's date range

**Files:**
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart`
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart`
- Modify: `lib/features/grc/presentation/ui/pages/add_policy_controls.dart`
- Modify: `lib/features/grc/presentation/ui/pages/create_new_policy.dart`

**Interfaces:**
- Produces: `PolicyControlModel` gains `startDate`/`endDate` (`DateTime?`). `PolicyControlItemWidget` gains `policyStartDate`/`policyEndDate`/`onStartDateChanged`/`onEndDateChanged`. `AddPolicyControlsPage` gains `policyStartDate`/`policyEndDate` (required, nullable `DateTime?`).

- [ ] **Step 1: Add `startDate`/`endDate` to `policy_control_model.dart`**

Replace:
```dart
  String? frequency;
  PolicyDocumentInfo? documentEn;
  PolicyDocumentInfo? documentAr;

  PolicyControlModel({
    TextEditingController? nameController,
    TextEditingController? nameArController,
    TextEditingController? numberController,
    TextEditingController? numberArController,
    TextEditingController? descriptionController,
    TextEditingController? descriptionArController,
    TextEditingController? weightController,
    this.frequency,
    this.documentEn,
    this.documentAr,
  })  : nameController = nameController ?? TextEditingController(),
```
with:
```dart
  String? frequency;
  DateTime? startDate;
  DateTime? endDate;
  PolicyDocumentInfo? documentEn;
  PolicyDocumentInfo? documentAr;

  PolicyControlModel({
    TextEditingController? nameController,
    TextEditingController? nameArController,
    TextEditingController? numberController,
    TextEditingController? numberArController,
    TextEditingController? descriptionController,
    TextEditingController? descriptionArController,
    TextEditingController? weightController,
    this.frequency,
    this.startDate,
    this.endDate,
    this.documentEn,
    this.documentAr,
  })  : nameController = nameController ?? TextEditingController(),
```

(No change to `dispose()` — `startDate`/`endDate` are plain fields, not controllers.)

- [ ] **Step 2: Add date pickers to `policy_control_item_widget.dart`**

Add the calendar import — replace:
```dart
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
```
with:
```dart
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
```

Add the new constructor params — replace:
```dart
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;
  final ValueChanged<String?> onFrequencyChanged;

  const PolicyControlItemWidget({
    super.key,
    required this.control,
    required this.isArabicEnabled,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    required this.onFrequencyChanged,
    this.showRemoveButton = false,
    this.onRemove,
  });
```
with:
```dart
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;
  final ValueChanged<String?> onFrequencyChanged;
  final DateTime? policyStartDate;
  final DateTime? policyEndDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  const PolicyControlItemWidget({
    super.key,
    required this.control,
    required this.isArabicEnabled,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    required this.onFrequencyChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.policyStartDate,
    this.policyEndDate,
    this.showRemoveButton = false,
    this.onRemove,
  });
```

Add a date-range-error helper — replace:
```dart
  Widget _documentButton({required VoidCallback onTap, required String title}) {
```
with:
```dart
  String? _controlDateError(DateTime? date) {
    if (date == null) return null;
    final policyStart = widget.policyStartDate;
    final policyEnd = widget.policyEndDate;
    if (policyStart != null && date.isBefore(policyStart)) {
      return 'Date must be within the policy date range.';
    }
    if (policyEnd != null && date.isAfter(policyEnd)) {
      return 'Date must be within the policy date range.';
    }
    return null;
  }

  Widget _documentButton({required VoidCallback onTap, required String title}) {
```

Define the date fields and render them — replace:
```dart
    final weightField = _textField(
      label: 'Control Weight',
      hint: 'Text Here',
      controller: control.weightController,
    );
```
with:
```dart
    final weightField = _textField(
      label: 'Control Weight',
      hint: 'Text Here',
      controller: control.weightController,
    );

    final startDateField = CustomDropdownCalendar(
      borderRadius: BorderRadius.circular(4.r),
      label: 'Start Date',
      hint: 'Select Start Date',
      value: control.startDate,
      onChanged: widget.onStartDateChanged,
      fillColor: AppColors.background,
      labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      required: false,
      firstDate: widget.policyStartDate,
      lastDate: widget.policyEndDate,
      errorText: _controlDateError(control.startDate),
    );

    final endDateField = CustomDropdownCalendar(
      borderRadius: BorderRadius.circular(4.r),
      label: 'End Date',
      hint: 'Select End Date',
      value: control.endDate,
      onChanged: widget.onEndDateChanged,
      fillColor: AppColors.background,
      labelStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.7)),
      required: false,
      firstDate: control.startDate ?? widget.policyStartDate,
      lastDate: widget.policyEndDate,
      errorText: control.endDate != null &&
              control.startDate != null &&
              control.endDate!.isBefore(control.startDate!)
          ? 'End date cannot be before start date.'
          : _controlDateError(control.endDate),
    );
```

Render the row — replace:
```dart
          SizedBox(height: 15.h),
          isTablet
              ? Row(children: [
                  Expanded(child: frequencyField),
                  SizedBox(width: 10.w),
                  Expanded(child: weightField),
                ])
              : Column(children: [
                  frequencyField,
                  SizedBox(height: 15.h),
                  weightField,
                ]),
        ],
      ),
    );
  }
}
```
with:
```dart
          SizedBox(height: 15.h),
          isTablet
              ? Row(children: [
                  Expanded(child: startDateField),
                  SizedBox(width: 10.w),
                  Expanded(child: endDateField),
                ])
              : Column(children: [
                  startDateField,
                  SizedBox(height: 15.h),
                  endDateField,
                ]),
          SizedBox(height: 15.h),
          isTablet
              ? Row(children: [
                  Expanded(child: frequencyField),
                  SizedBox(width: 10.w),
                  Expanded(child: weightField),
                ])
              : Column(children: [
                  frequencyField,
                  SizedBox(height: 15.h),
                  weightField,
                ]),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Thread the Policy's dates through `add_policy_controls.dart`**

Replace:
```dart
class AddPolicyControlsPage extends StatefulWidget {
  final bool isArabicEnabled;
  final List<PolicyControlModel> controls;

  const AddPolicyControlsPage({
    super.key,
    required this.isArabicEnabled,
    required this.controls,
  });
```
with:
```dart
class AddPolicyControlsPage extends StatefulWidget {
  final bool isArabicEnabled;
  final List<PolicyControlModel> controls;
  final DateTime? policyStartDate;
  final DateTime? policyEndDate;

  const AddPolicyControlsPage({
    super.key,
    required this.isArabicEnabled,
    required this.controls,
    required this.policyStartDate,
    required this.policyEndDate,
  });
```

Add the per-index date handlers — replace:
```dart
  void _onUploadDocumentEn(int index) {
```
with:
```dart
  void _onControlStartDateChanged(int index, DateTime? date) {
    setState(() {
      _controls[index].startDate = date;
      final end = _controls[index].endDate;
      if (end != null && date != null && end.isBefore(date)) {
        _controls[index].endDate = null;
      }
    });
  }

  void _onControlEndDateChanged(int index, DateTime? date) {
    setState(() => _controls[index].endDate = date);
  }

  void _onUploadDocumentEn(int index) {
```

Pass the new params into the widget — replace:
```dart
                      onRemoveDocumentEn: () =>
                          setState(() => _controls[i].documentEn = null),
                      onRemoveDocumentAr: () =>
                          setState(() => _controls[i].documentAr = null),
                      onFrequencyChanged: (value) =>
                          setState(() => _controls[i].frequency = value),
                    ),
```
with:
```dart
                      onRemoveDocumentEn: () =>
                          setState(() => _controls[i].documentEn = null),
                      onRemoveDocumentAr: () =>
                          setState(() => _controls[i].documentAr = null),
                      onFrequencyChanged: (value) =>
                          setState(() => _controls[i].frequency = value),
                      policyStartDate: widget.policyStartDate,
                      policyEndDate: widget.policyEndDate,
                      onStartDateChanged: (date) =>
                          _onControlStartDateChanged(i, date),
                      onEndDateChanged: (date) =>
                          _onControlEndDateChanged(i, date),
                    ),
```

- [ ] **Step 4: Pass the Policy's own dates from `create_new_policy.dart`**

Replace:
```dart
  Widget _buildStep1() {
    return AddPolicyControlsPage(
      isArabicEnabled: _isArabicEnabled,
      controls: _controls,
    );
  }
```
with:
```dart
  Widget _buildStep1() {
    return AddPolicyControlsPage(
      isArabicEnabled: _isArabicEnabled,
      controls: _controls,
      policyStartDate: _startDate,
      policyEndDate: _endDate,
    );
  }
```

- [ ] **Step 5: Compile sanity check**

Run: `dart analyze lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart lib/features/grc/presentation/ui/pages/add_policy_controls.dart lib/features/grc/presentation/ui/pages/create_new_policy.dart`
Expected: no `error` level issues.

- [ ] **Step 6: Manual verification**

Run the app. On step 0, set Policy Start Date and End Date (e.g. a 2-week window). Advance to step 1 — confirm the control card shows Start Date/End Date fields. Open the Start Date picker — confirm dates outside the policy's window are not selectable (or, if selectable via manual entry path, confirm the red range-error message appears). Pick a control start/end date inside the policy's window — confirm no error. Pick a control end date before its own start date — confirm the "End date cannot be before start date" message appears.

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart lib/features/grc/presentation/ui/pages/add_policy_controls.dart lib/features/grc/presentation/ui/pages/create_new_policy.dart
git commit -m "feat(grc): Control Start/End Date fields constrained to the Policy's date range"
```

---

### Task 6: Real Policy image picking

**Files:**
- Modify: `lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_header_widget.dart`
- Modify: `lib/features/grc/presentation/ui/pages/create_new_policy.dart`

**Interfaces:**
- Consumes: `CustomImagePicker` from `lib/core/custom/46_custom_image_picker.dart` (`imageFile: File?`, `onImagePicked: ValueChanged<File>`, `radius`, `badgeRadius`).
- Produces: `PolicyHeaderWidget` gains `imageFile`/`onImagePicked`, drops `onImageTap`. `CreateNewPolicyPage` gains `File? _imageFile`.

- [ ] **Step 1: Replace the placeholder avatar with `CustomImagePicker`**

Replace the entire file with:

```dart
/// Module: GRC Policy Management
/// Description: Header row widget with avatar and Arabic version toggle.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, FlutterSwitch, CustomImagePicker
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Replaced the static avatar placeholder with
///                                CustomImagePicker for real image picking
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_header_widget.dart
/// Purpose: Contains PolicyHeaderWidget, the policy image picker and
///          "Create Arabic Version" toggle row at the top of the policy form.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'dart:io';

import 'package:demo_app/core/custom/46_custom_image_picker.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [PolicyHeaderWidget]
///
/// purpose: row containing the policy image picker (backed by
///          [CustomImagePicker]) and the "Create Arabic Version" toggle. The
///          owning page holds the isArabicEnabled/imageFile state and
///          receives changes via onArabicToggle/onImagePicked.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyHeaderWidget extends StatelessWidget {
  final bool isArabicEnabled;
  final ValueChanged<bool> onArabicToggle;
  final File? imageFile;
  final ValueChanged<File> onImagePicked;

  const PolicyHeaderWidget({
    super.key,
    required this.isArabicEnabled,
    required this.onArabicToggle,
    required this.onImagePicked,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomImagePicker(
          radius: 30.r,
          badgeRadius: 11.r,
          imageFile: imageFile,
          onImagePicked: onImagePicked,
        ),
        Row(
          children: [
            Text('Create Arabic Version'.tr),
            SizedBox(width: 10.w),
            FlutterSwitch(
              width: 38.sp,
              height: 22.sp,
              padding: 3.sp,
              borderRadius: 20.sp,
              toggleSize: 16.sp,
              activeColor: AppColors.secondaryPrimary,
              inactiveColor: Colors.grey.withOpacity(.16),
              value: isArabicEnabled,
              onToggle: onArabicToggle,
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Wire `_imageFile` state in `create_new_policy.dart`**

Add `import 'dart:io';` as the first import line (before the `package:` imports).

Replace:
```dart
  DateTime? _startDate;
  DateTime? _endDate;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;
```
with:
```dart
  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;
```

Replace:
```dart
              PolicyHeaderWidget(
                isArabicEnabled: _isArabicEnabled,
                onArabicToggle: (v) => setState(() => _isArabicEnabled = v),
              ),
```
with:
```dart
              PolicyHeaderWidget(
                isArabicEnabled: _isArabicEnabled,
                onArabicToggle: (v) => setState(() => _isArabicEnabled = v),
                imageFile: _imageFile,
                onImagePicked: (file) => setState(() => _imageFile = file),
              ),
```

- [ ] **Step 3: Compile sanity check**

Run: `dart analyze lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_header_widget.dart lib/features/grc/presentation/ui/pages/create_new_policy.dart`
Expected: no `error` level issues.

- [ ] **Step 4: Manual verification**

Run the app, open Create New Policy step 0. Tap the camera badge on the avatar — confirm the gallery opens, pick an image, confirm the avatar updates to show the picked image (not the placeholder icon).

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/presentation/ui/widgets/grc_policy_widget/policy_header_widget.dart lib/features/grc/presentation/ui/pages/create_new_policy.dart
git commit -m "feat(grc): real image picking for Policy avatar via CustomImagePicker"
```

---

### Task 7: Fix persistence — send controls, image, and documents to PolicyCubit on save

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/create_new_policy.dart`

**Interfaces:**
- Consumes: `PendingControlInput` and `ControlStatus` (from `lib/features/grc/domain/entities/control_status.dart`) — both already exist. `_controls` (`List<PolicyControlModel>`, now with `numberController`/`numberArController`/`startDate`/`endDate`/`documentEn`/`documentAr` from Tasks 2/4/5). `_imageFile`/`_documentEn`/`_documentAr` from Tasks 1/6.

- [ ] **Step 1: Add the `ControlStatus` import**

Add this import alongside the other `package:demo_app/features/grc/domain/...` imports (near the existing `create_control_usecase.dart` import):

```dart
import 'package:demo_app/features/grc/domain/entities/control_status.dart';
```

- [ ] **Step 2: Add `_buildPendingControls` and wire it plus image/document files into both save paths**

Replace:
```dart
  void _onSaveForLater(PolicyCubit cubit) {
    cubit.saveAsDraft(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
    );
  }
```
with:
```dart
  List<PendingControlInput> _buildPendingControls(ControlStatus status) {
    return _controls
        .where((c) => c.nameController.text.trim().isNotEmpty)
        .map((c) => PendingControlInput(
              controlsNameEn: c.nameController.text.trim(),
              controlsNameAr: c.nameArController.text.trim(),
              controlsNumberEn: c.numberController.text.trim(),
              controlsNumberAr: c.numberArController.text.trim(),
              controlsDescriptionEn: c.descriptionController.text.trim(),
              controlsDescriptionAr: c.descriptionArController.text.trim(),
              controlsWeight: double.tryParse(c.weightController.text.trim()) ?? 0,
              frequency: c.frequency ?? '',
              startDate: c.startDate ?? _startDate ?? DateTime.now(),
              endDate: c.endDate ?? _endDate ?? DateTime.now(),
              departments: const [],
              equalWeights: false,
              score: 0,
              status: status,
              controlsDocumentFileEn: c.documentEn?.file,
              controlsDocumentFileAr: c.documentAr?.file,
            ))
        .toList();
  }

  void _onSaveForLater(PolicyCubit cubit) {
    cubit.saveAsDraft(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
      controls: _buildPendingControls(ControlStatus.draft),
      imageFile: _imageFile,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentFileAr: _documentAr?.file,
    );
  }
```

Replace:
```dart
  void _onPublish(PolicyCubit cubit) {
    if (!_isWeightValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total Weight should be 100'.tr),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    cubit.createPolicy(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
    );
  }
```
with:
```dart
  void _onPublish(PolicyCubit cubit) {
    if (!_isWeightValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total Weight should be 100'.tr),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    cubit.createPolicy(
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
      controls: _buildPendingControls(ControlStatus.active),
      imageFile: _imageFile,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentFileAr: _documentAr?.file,
    );
  }
```

- [ ] **Step 3: Compile sanity check**

Run: `dart analyze lib/features/grc/presentation/ui/pages/create_new_policy.dart`
Expected: no `error` level issues.

- [ ] **Step 4: Manual verification**

Run the app, create a policy end to end: fill step 0 (including an image and EN document), add one control in step 1 with a name, number, description, dates, weight 100, and a document, advance to preview, tap Publish. Confirm the success dialog reads "Policy Created" (not a partial-success/failure message). If the app has a policy list/detail screen, open the newly created policy and confirm the control you added actually appears (this is the regression check for the bug this task fixes — previously the control would silently not exist).

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/create_new_policy.dart
git commit -m "fix(grc): send controls, image, and documents to PolicyCubit on Publish/Save For Later"
```
