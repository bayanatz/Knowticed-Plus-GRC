/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_template_editor.dart
/// Purpose: The bilingual message card of Notification Control — one widget
///          for the tablet panel and the phone edit page.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner 22/10/2026 (Figma SETTING › Notification Control):
/// - Email shows Subject / عنوان + Body / نص الرسالة (500).
///   Push shows Title / عنوان + Description / الوصف (150).
///   The Email | Notifications switch swaps between the two sets — each
///   channel keeps its own text.
/// - Arabic fields sit on the right with their counter on the left (the
///   shared CustomTextField does that for any RTL field).
/// - Every variable the module can fill is a chip; a tap writes its
///   `{{token}}` where the cursor was.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/inputs/field_sizing.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_model.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_catalog.dart';
import 'package:knowticed_plus/features/notification/domain/enums/template_variable_label.dart';
import 'package:knowticed_plus/features/notification/helpers/services/notification_auto_variables.dart';

/// Character limits of the two channels (Figma: Body 0/500, Description 0/150).
const int kEmailBodyMaxLength = 500;
const int kPushBodyMaxLength = 150;

/// The eight text controllers of one template: Email and Push, EN and AR.
class NotificationTemplateControllers {
  final TextEditingController subjectEn = TextEditingController();
  final TextEditingController subjectAr = TextEditingController();
  final TextEditingController bodyEn = TextEditingController();
  final TextEditingController bodyAr = TextEditingController();
  final TextEditingController pushTitleEn = TextEditingController();
  final TextEditingController pushTitleAr = TextEditingController();
  final TextEditingController pushBodyEn = TextEditingController();
  final TextEditingController pushBodyAr = TextEditingController();

  List<TextEditingController> get all => <TextEditingController>[
        subjectEn,
        subjectAr,
        bodyEn,
        bodyAr,
        pushTitleEn,
        pushTitleAr,
        pushBodyEn,
        pushBodyAr,
      ];

  /// Owner 22/10/2026: Save is offered only when something changed.
  bool differsFrom(NotificationTemplateModel t) =>
      subjectEn.text.trim() != t.subjectEnglish.trim() ||
      subjectAr.text.trim() != t.subjectArabic.trim() ||
      bodyEn.text.trim() != t.bodyEnglish.trim() ||
      bodyAr.text.trim() != t.bodyArabic.trim() ||
      pushTitleEn.text.trim() != t.pushTitleEn.trim() ||
      pushTitleAr.text.trim() != t.pushTitleAr.trim() ||
      pushBodyEn.text.trim() != t.pushBodyEn.trim() ||
      pushBodyAr.text.trim() != t.pushBodyAr.trim();

  /// The channel whose fields block a save — 'email' or 'push' — or null
  /// when all eight texts are filled and within their limits.
  String? invalidChannel() {
    bool bad(TextEditingController c, int? max) =>
        c.text.trim().isEmpty || (max != null && c.text.length > max);
    if (bad(subjectEn, null) ||
        bad(subjectAr, null) ||
        bad(bodyEn, kEmailBodyMaxLength) ||
        bad(bodyAr, kEmailBodyMaxLength)) {
      return 'email';
    }
    if (bad(pushTitleEn, null) ||
        bad(pushTitleAr, null) ||
        bad(pushBodyEn, kPushBodyMaxLength) ||
        bad(pushBodyAr, kPushBodyMaxLength)) {
      return 'push';
    }
    return null;
  }

  void clear() {
    for (final TextEditingController c in all) {
      c.clear();
    }
  }

  void dispose() {
    for (final TextEditingController c in all) {
      c.dispose();
    }
  }
}

class NotificationTemplateEditor extends StatefulWidget {
  const NotificationTemplateEditor({
    super.key,
    required this.controllers,
    required this.isEmail,
    required this.enabled,
    required this.module,
    required this.onChanged,
    this.padded = true,
    this.stackTitles = false,
    this.showVariables = true,
    this.submitted = false,
  });

  final NotificationTemplateControllers controllers;

  /// true → the Email set, false → the Push set.
  final bool isEmail;
  final bool enabled;

  /// Decides which variable chips are offered.
  final AppModule? module;
  final VoidCallback onChanged;

  /// Draws its own card (padding 15 on every side, R-11). The phone page
  /// passes false because its body is already a card.
  final bool padded;

  /// Phone: the EN and AR title fields one under the other.
  final bool stackTitles;

  /// The Preview page shows the text only, without the chips.
  final bool showVariables;

  /// Owner 22/10/2026 (R-6): true once Save was pressed — empty fields then
  /// say "This field is required." Never shown when the page opens.
  final bool submitted;

  @override
  State<NotificationTemplateEditor> createState() =>
      _NotificationTemplateEditorState();
}

class _NotificationTemplateEditorState
    extends State<NotificationTemplateEditor> {
  final List<FocusNode> _focus =
      List<FocusNode>.generate(8, (_) => FocusNode());

  /// The field a chip writes into: the last one that had focus.
  TextEditingController? _target;

  @override
  void initState() {
    super.initState();
    final List<TextEditingController> all = widget.controllers.all;
    for (int i = 0; i < _focus.length; i++) {
      _focus[i].addListener(() {
        if (_focus[i].hasFocus) _target = all[i];
      });
    }
  }

  @override
  void dispose() {
    for (final FocusNode f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  void _insert(TemplateVariable variable) {
    if (!widget.enabled) return;
    HapticController.low();
    final NotificationTemplateControllers c = widget.controllers;
    final TextEditingController target =
        _target ?? (widget.isEmail ? c.bodyEn : c.pushBodyEn);
    final TextEditingValue value = target.value;
    final int start =
        value.selection.isValid ? value.selection.start : value.text.length;
    final int end =
        value.selection.isValid ? value.selection.end : value.text.length;
    final String text = value.text.replaceRange(start, end, variable.token);
    target.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: start + variable.token.length),
    );
    widget.onChanged();
  }

  List<TemplateVariable> get _variables {
    final AppModule? module = widget.module;
    final List<TemplateVariable> list = module == null
        ? <TemplateVariable>[]
        : NotificationCatalog.variablesOf(module);
    for (final TemplateVariable v in NotificationAutoVariables.all) {
      if (!list.contains(v)) list.add(v);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabicUi = Directionality.of(context) == TextDirection.rtl;
    final NotificationTemplateControllers c = widget.controllers;
    final bool email = widget.isEmail;
    // Focus nodes follow NotificationTemplateControllers.all.
    final int o = email ? 0 : 4;
    final int bodyMax = email ? kEmailBodyMaxLength : kPushBodyMaxLength;
    final int bodyLines = email ? 7 : 3;
    // Figma: Body 216, Description 72. On the phone (narrow, stacked) the
    // text wraps more, so the box grows with it instead of cutting the last
    // line off (owner 22/10/2026).
    // 23/10/2026 (Moataz, Mac: "why can I still scroll this"): the email body
    // is 216 in the design, which with the status card above it is taller than
    // a Mac window. It takes what is left of the screen height after the rest
    // of the page (about 880), between 72 and the design's 216, so the whole
    // editor fits a normal window and only a short one scrolls.
    final double screenH = MediaQuery.sizeOf(context).height;
    final double emailBody = ((screenH - 880) / 2).clamp(72.0, 216.0);
    final double? bodyHeight =
        widget.stackTitles ? null : (email ? emailBody : 72);

    final Widget titleEn = CustomTextField(
      key: ValueKey<String>('nc_title_en_$email'),
      label: email ? 'Subject' : 'Title',
      hint: 'Text Here',
      // The field scales FieldSizing.height (36) itself — never pass .h/.sp.
      height: FieldSizing.height,
      textDirection: TextDirection.ltr,
      controller: email ? c.subjectEn : c.pushTitleEn,
      focusNode: _focus[o],
      onChanged: (_) => widget.onChanged(),
      enabled: widget.enabled,
      required: true,
      submitted: widget.submitted,
    );
    final Widget titleAr = CustomTextField(
      key: ValueKey<String>('nc_title_ar_$email'),
      label: 'عنوان',
      hint: 'اكتب هنا',
      // The field scales FieldSizing.height (36) itself — never pass .h/.sp.
      height: FieldSizing.height,
      textDirection: TextDirection.rtl,
      controller: email ? c.subjectAr : c.pushTitleAr,
      focusNode: _focus[o + 1],
      onChanged: (_) => widget.onChanged(),
      enabled: widget.enabled,
      required: true,
      submitted: widget.submitted,
    );

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // R-1: two fields in a row share the width, 16 apart.
        // 22/10/2026 (Moataz): in the Arabic interface the Arabic field comes
        // FIRST (right side / top), English second; in English it is the other
        // way round.
        // Moataz 23/10/2026: each field on its own row (Subject / Title too),
        // like the bodies below — never two side by side.
        if (isArabicUi) ...<Widget>[
          titleAr,
          SizedBox(height: 15.sp),
          titleEn,
        ] else ...<Widget>[
          titleEn,
          SizedBox(height: 15.sp),
          titleAr,
        ],
        if (widget.showVariables) ...<Widget>[
          SizedBox(height: 15.sp),
          _VariableChips(
            variables: _variables,
            isArabic: isArabicUi,
            enabled: widget.enabled,
            onTap: _insert,
          ),
        ],
        SizedBox(height: 15.sp),
        // R-9: long text takes the full width, one per row.
        if (isArabicUi) ...<Widget>[
          CustomTextField(
            key: ValueKey<String>('nc_body_ar_$email'),
            label: email ? 'نص الرسالة' : 'الوصف',
            hint: 'اكتب هنا',
            maxLines: widget.stackTitles ? 12 : bodyLines,
            minLines: bodyLines,
            height: bodyHeight,
            maxLength: bodyMax,
            showCharCount: true,
            textDirection: TextDirection.rtl,
            controller: email ? c.bodyAr : c.pushBodyAr,
            focusNode: _focus[o + 3],
            onChanged: (_) => widget.onChanged(),
            enabled: widget.enabled,
            required: true,
            submitted: widget.submitted,
          ),
          SizedBox(height: 15.sp),
          CustomTextField(
            key: ValueKey<String>('nc_body_en_$email'),
            label: email ? 'Body' : 'Description',
            hint: 'Text Here',
            maxLines: widget.stackTitles ? 12 : bodyLines,
            minLines: bodyLines,
            height: bodyHeight,
            maxLength: bodyMax,
            showCharCount: true,
            textDirection: TextDirection.ltr,
            controller: email ? c.bodyEn : c.pushBodyEn,
            focusNode: _focus[o + 2],
            onChanged: (_) => widget.onChanged(),
            enabled: widget.enabled,
            required: true,
            submitted: widget.submitted,
          ),
        ] else ...<Widget>[
          CustomTextField(
            key: ValueKey<String>('nc_body_en_$email'),
            label: email ? 'Body' : 'Description',
            hint: 'Text Here',
            maxLines: widget.stackTitles ? 12 : bodyLines,
            minLines: bodyLines,
            height: bodyHeight,
            maxLength: bodyMax,
            showCharCount: true,
            textDirection: TextDirection.ltr,
            controller: email ? c.bodyEn : c.pushBodyEn,
            focusNode: _focus[o + 2],
            onChanged: (_) => widget.onChanged(),
            enabled: widget.enabled,
            required: true,
            submitted: widget.submitted,
          ),
          SizedBox(height: 15.sp),
          CustomTextField(
            key: ValueKey<String>('nc_body_ar_$email'),
            label: email ? 'نص الرسالة' : 'الوصف',
            hint: 'اكتب هنا',
            maxLines: widget.stackTitles ? 12 : bodyLines,
            minLines: bodyLines,
            height: bodyHeight,
            maxLength: bodyMax,
            showCharCount: true,
            textDirection: TextDirection.rtl,
            controller: email ? c.bodyAr : c.pushBodyAr,
            focusNode: _focus[o + 3],
            onChanged: (_) => widget.onChanged(),
            enabled: widget.enabled,
            required: true,
            submitted: widget.submitted,
          ),
        ],
      ],
    );

    if (!widget.padded) return content;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: content,
    );
  }
}

class _VariableChips extends StatelessWidget {
  const _VariableChips({
    required this.variables,
    required this.isArabic,
    required this.enabled,
    required this.onTap,
  });

  final List<TemplateVariable> variables;
  final bool isArabic;
  final bool enabled;
  final ValueChanged<TemplateVariable> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          isArabic ? 'المتغيرات' : 'Variables',
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 4.sp),
        Text(
          enabled
              ? (isArabic
                  ? 'اضغط على متغير لإضافته مكان المؤشر'
                  : 'Tap a variable to add it where the cursor is')
              : (isArabic
                  ? 'اضغط تعديل لإضافة المتغيرات'
                  : 'Press Edit to add variables'),
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
        SizedBox(height: 8.sp),
        Opacity(
          // Greyed while read-only, but still readable (was 0.5 — the words
          // washed out on the light theme; Moataz 22/10/2026).
          opacity: enabled ? 1 : 0.85,
          child: Wrap(
            spacing: 8.sp,
            runSpacing: 8.sp,
            children: <Widget>[
              for (final TemplateVariable v in variables)
                GestureDetector(
                  key: ValueKey<String>('nc_var_${v.key}'),
                  onTap: enabled ? () => onTap(v) : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.sp,
                      vertical: 4.sp,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: AppColors.primary,
                      ),
                    ),
                    child: Text(
                      v.label(isArabic: isArabic),
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
