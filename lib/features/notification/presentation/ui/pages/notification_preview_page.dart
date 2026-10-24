/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_preview_page.dart
/// Purpose: Notification Control › Preview Notification — the message on the
///          left, a phone showing how it arrives on the right.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner 22/10/2026 ("the preview is bad, it's not like this"), per Figma
/// SETTING › Notification Control › Preview Notification:
/// - Breadcrumb Home › Notification Control › Preview Notification.
/// - The Email | Notifications switch changes BOTH sides: the fields and the
///   phone (Push → the real inbox card; Email → the email).
/// - Variables show as their names ("Document Name"), so the reader sees
///   where each value will go.
/// - Back returns to the editor with the text untouched; Save saves.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_segmented_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/domain/enums/template_variable_label.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_card.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_edit_layout.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_template_editor.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class NotificationPreviewPage extends StatefulWidget {
  const NotificationPreviewPage({
    super.key,
    required this.controllers,
    required this.module,
    required this.isEmail,
    this.onSave,
  });

  /// The editor's own controllers — read here, never changed.
  final NotificationTemplateControllers controllers;
  final AppModule? module;
  final bool isEmail;

  /// Saves the template; null hides Save (no right to save).
  final Future<void> Function()? onSave;

  @override
  State<NotificationPreviewPage> createState() =>
      _NotificationPreviewPageState();
}

class _NotificationPreviewPageState extends State<NotificationPreviewPage> {
  late bool _isEmail = widget.isEmail;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving || widget.onSave == null) return;
    setState(() => _saving = true);
    await widget.onSave!();
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;
    final bool isPhone = ContextExtension(context).isPhone;
    final S s = S.of(context);

    final Widget toggle = Align(
      alignment: AlignmentDirectional.centerEnd,
      child: CustomSegmentedToggle(
        compact: true,
        tabs: [s.email, s.notifications],
        selectedIndex: _isEmail ? 0 : 1,
        onChanged: (int i) => setState(() => _isEmail = i == 0),
      ),
    );

    final Widget actions = NotificationEditActions(
      start: <NotificationEditAction>[
        NotificationEditAction(
          key: const ValueKey<String>('notificationPreviewBack'),
          title: s.back,
          textStyle:
              StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
          onTap: () => Navigator.pop(context),
          color: AppColors.darkGrey,
        ),
      ],
      end: widget.onSave == null
          ? null
          : NotificationEditAction(
              key: const ValueKey<String>('notificationPreviewSave'),
              title: _saving ? (isRTL ? 'جاري الحفظ...' : 'Saving...') : s.save,
              textStyle: StyleText.fontSize18Weight500
                  .copyWith(color: AppColors.textButton),
              onTap: _save,
              color: AppColors.primary,
            ),
    );

    final Widget phone = _PhonePreview(
      // 23/10/2026 (Moataz: "the preview is so bad"): on a phone there is no
      // device frame at all — just the preview in a clean card, full width, so
      // the title fits and nothing needs scrolling. Tablets keep the mockup.
      compact: isPhone,
      height: 560.sp,
      controllers: widget.controllers,
      module: widget.module,
      isEmail: _isEmail,
      isArabic: isRTL,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      // Phone: Back · Save pinned under the scrolling page, on the same 15
      // inset as the frame's content.
      bottomNavigationBar: isPhone
          ? Padding(
              padding: EdgeInsets.fromLTRB(15.sp, 8.sp, 15.sp, 12.sp),
              child: actions,
            )
          : null,
      // Owner 22/10/2026: a pushed page draws the watermark itself (like
      // every pushed settings page in get_pages.dart).
      body: WatermarkLayer(
        module: Modules.notification,
        child: SafeArea(
          child: SideFrameMasterServices(
            titleText: s.notificationControl,
            secondTitle: isRTL ? 'معاينة الإشعار' : 'Preview Notification',
            onFirstTap: () => Navigator.pop(context),
            // Owner 22/10/2026: no padding or scroll view of our own — the
            // frame already insets 15 and scrolls on the phone — so the
            // content lines up with the title, and Back · Save stay pinned.
            child: isPhone
                ? Column(
                    children: <Widget>[
                      toggle,
                      SizedBox(height: 16.sp),
                      Center(child: phone),
                      SizedBox(height: 16.sp),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  children: <Widget>[
                                    toggle,
                                    SizedBox(height: 16.sp),
                                    NotificationTemplateEditor(
                                      controllers: widget.controllers,
                                      isEmail: _isEmail,
                                      enabled: false,
                                      module: widget.module,
                                      onChanged: () {},
                                      showVariables: false,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16.sp),
                            actions,
                            SizedBox(height: 16.sp),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.sp),
                      phone,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// The phone on the right: the push as the real inbox card, or the email.
class _PhonePreview extends StatelessWidget {
  const _PhonePreview({
    required this.compact,
    required this.height,
    required this.controllers,
    required this.module,
    required this.isEmail,
    required this.isArabic,
  });

  final bool compact;
  final double height;
  final NotificationTemplateControllers controllers;
  final AppModule? module;
  final bool isEmail;
  final bool isArabic;

  /// `{{documentName}}` → "Document Name" in the given language.
  static String sample(String text, {required bool isArabic}) {
    var out = text;
    for (final TemplateVariable v in TemplateVariable.values) {
      out = out.replaceAll(v.token, v.label(isArabic: isArabic));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final NotificationTemplateControllers c = controllers;
    final MainCoreEmployeeController employees =
        Get.find<MainCoreEmployeeController>();

    final Widget content = isEmail
        ? _EmailPreview(
            subject: sample(
              isArabic ? c.subjectAr.text : c.subjectEn.text,
              isArabic: isArabic,
            ),
            body: sample(
              isArabic ? c.bodyAr.text : c.bodyEn.text,
              isArabic: isArabic,
            ),
            isArabic: isArabic,
          )
        // The real inbox card — the push looks exactly like this when it lands.
        : NotificationCard(
            notification: NotificationModelSystem(
              title: sample(c.pushTitleEn.text, isArabic: false),
              body: sample(c.pushBodyEn.text, isArabic: false),
              titleAr: sample(c.pushTitleAr.text, isArabic: true),
              bodyAr: sample(c.pushBodyAr.text, isArabic: true),
              nameOfModule: module?.key ?? '',
              senderEmail: employees.employeeEntity?.email ?? '',
              receiverEmail: employees.employeeEntity?.email ?? '',
              nameOfPage: '',
            ),
            employeeController: employees,
            isMobile: true,
            onTap: () {},
            leadingAction: NotificationCardAction(
              title: S.of(context).pin,
              iconPath:
                  "assets/icons_assets/main_icons_assets/ic_action_pin.svg",
              onTap: () {},
            ),
            trailingAction: NotificationCardAction(
              title: S.of(context).view,
              iconPath:
                  "assets/icons_assets/notification_assets/ic_action_view_document.svg",
              onTap: () {},
            ),
          );

    if (compact) {
      return Container(
        key: const ValueKey<String>('notificationPreviewPhone'),
        width: double.infinity,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              isEmail
                  ? (isArabic ? 'معاينة البريد الإلكتروني' : 'Email preview')
                  : (isArabic ? 'معاينة الإشعار' : 'Notification preview'),
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
            SizedBox(height: 10.sp),
            content,
          ],
        ),
      );
    }

    return Container(
      key: const ValueKey<String>('notificationPreviewPhone'),
      width: 280.sp,
      height: height,
      padding: EdgeInsets.all(8.sp),
      // The bezel is outlined so the phone stands out on the dark theme too.
      decoration: BoxDecoration(
        color: AppColors.colorBlack,
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: AppColors.secondaryText, width: 2.sp),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: ColoredBox(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Status bar + notch.
              SizedBox(
                height: 32.sp,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    PositionedDirectional(
                      start: 20.sp,
                      child: Text(
                        '9:41',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ),
                    Container(
                      width: 90.sp,
                      height: 22.sp,
                      decoration: BoxDecoration(
                        color: AppColors.colorBlack,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.sp, 8.sp, 12.sp, 8.sp),
                child: Text(
                  isEmail
                      ? (isArabic ? 'البريد الإلكتروني' : 'Email')
                      : (isArabic ? 'الإشعارات' : 'Notification'),
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailPreview extends StatelessWidget {
  const _EmailPreview({
    required this.subject,
    required this.body,
    required this.isArabic,
  });

  final String subject;
  final String body;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.darkGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isArabic ? 'الموضوع' : 'Subject',
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 4.sp),
          Text(
            subject,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          Divider(height: 24.sp, color: AppColors.darkGrey),
          Text(
            body,
            style:
                StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }
}
