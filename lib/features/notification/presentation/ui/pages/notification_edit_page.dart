/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_edit_page.dart
/// Description: Edits one notification template.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N13: the two dead private methods are deleted.
/// Updated: 2/9/2026 - This screen is where the five Notification Control role
///          permissions land (Figma: ROLE MANAGEMENT → Adding New Role →
///          Notification Control). Nothing here is hidden behind a permission
///          except the two write ACTIONS (Save, Reset Default); the status
///          switch, the channel checkboxes and the copy fields are shown to
///          everyone and made inert without the matching right, because
///          reading a notification's configuration and changing it are
///          different things and only the second is gated.
/// Updated: 9/10/2026 - Time Tracker QA KP-TT-018 (shared module → Amr's
///          handover): the status row and the Preview / Save row always fit
///          (`NotificationStatusHeader` / `NotificationEditActions`) — Reset
///          Default (190.w) overflowed the status row on a phone.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/inputs/field_sizing.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_segmented_toggle.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_template_editor.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_preview_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/default_switch_button.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/svg_custom.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';

import 'package:knowticed_plus/generated/l10n.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/qiyas/core/widgets/multi_select_dropdown_widget.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/grc/core/widgets/custom_botton.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/todo_module/core/components/other_components/flutter_switch.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_model.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_control.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
// ADDED 2/9/2026 — the Notification Control role permissions. This screen is
// where all five of them actually bite; see the header note above.
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/notification/notification_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/notification/notification_sections_enum.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class NotificationEditPage extends StatefulWidget {
  final NotificationItem notificationItem;
  final String moduleName;
  final NotificationTab currentTab;

  const NotificationEditPage({
    super.key,
    required this.notificationItem,
    required this.moduleName,
    required this.currentTab,
  });

  @override
  State<NotificationEditPage> createState() => _NotificationEditPageState();
}

class _NotificationEditPageState extends State<NotificationEditPage> {
  bool isSaving = false;
  bool isLoadingTemplate = true;
  bool isNotificationEnabled = true;

  List<String> selectedNotificationTypes = [];

  /// Email (Subject + Body) and Push (Title + Description), EN and AR.
  final NotificationTemplateControllers templateText =
      NotificationTemplateControllers();

  /// Owner 22/10/2026: the Email | Notifications switch picks which set of
  /// fields is shown — each channel keeps its own text.
  bool isEmailView = true;

  /// Owner 22/10/2026 (Figma iPhone): the page opens read-only with an edit
  /// button; edit turns it into "Editing …" + the name.
  bool isEditMode = false;

  NotificationTemplateModel? currentTemplate;
  final NotificationTemplateService _templateService =
      NotificationTemplateService();

  // ADDED 2/9/2026 — Notification Control role permissions.
  //
  // Read ONCE in initState, not per build. `isHasPermission` walks the role
  // document, and this screen rebuilds on every keystroke in four text fields
  // (each one calls `setState` from `onChanged`). A role cannot change while
  // one template is open, so re-reading it 500 times while someone types a
  // body is pure waste.
  bool _canEditNotification = false;
  bool _canEditPushMessages = false;
  bool _canEditEmailMessages = false;
  bool _canChangeStatus = false;
  bool _canChangeChannel = false;

  /// May the member rewrite the subject and body of THIS notification?
  ///
  /// The template holds one subject/body pair, and the checkboxes below decide
  /// which channels it is sent on — so "may edit the copy" is not a single
  /// right, it depends on which channels this notification currently uses. A
  /// role with push copy rights only may edit a push-only notification and
  /// must not edit an email-only one.
  ///
  /// [NotificationPermissions.editNotification] is the umbrella: without it
  /// the copy is read-only whatever the two channel rights say. When no
  /// channel is selected yet there is nothing to protect, so either channel
  /// right is enough.
  ///
  /// CHANGED 22/10/2026: Email and Push now keep their own text, so each right
  /// guards its own fields — the email copy needs the email right, the push
  /// copy the push right.
  bool get _canEditEmailCopy => _canEditNotification && _canEditEmailMessages;
  bool get _canEditPushCopy => _canEditNotification && _canEditPushMessages;
  bool get _canEditMessages => _canEditEmailCopy || _canEditPushCopy;

  /// Save writes status, channels and copy in one go, so it is offered when
  /// the member may change ANY of the three — not only the copy.
  bool get _canSave =>
      _canEditMessages || _canChangeStatus || _canChangeChannel;

  @override
  void initState() {
    super.initState();
    _readPermissions();
    _loadTemplate();
  }

  /// Function Name: [_readPermissions]
  ///
  /// Purpose: Resolve the five Notification Control permissions for the signed
  ///          in employee, once, when the screen opens.
  ///
  /// Returns: [void] — the five `_can…` fields are set directly.
  void _readPermissions() {
    final MainCoreEmployeeController controller = Get.find();

    bool has(NotificationPermissions permission) {
      return controller.isHasPermission(
        module: Modules.notification,
        section: NotificationPermissionsSections.notificationControl,
        permission: permission,
      );
    }

    _canEditNotification = has(NotificationPermissions.editNotification);
    _canEditPushMessages = has(
      NotificationPermissions.editPushNotificationMessages,
    );
    _canEditEmailMessages = has(
      NotificationPermissions.editEmailNotificationMessages,
    );
    _canChangeStatus = has(NotificationPermissions.changeNotificationStatus);
    _canChangeChannel = has(NotificationPermissions.changeNotificationChannel);
  }

  @override
  void dispose() {
    templateText.dispose();
    super.dispose();
  }

  // ✅ Load template from Firebase
  Future<void> _loadTemplate() async {
    setState(() {
      isLoadingTemplate = true;
    });

    NotificationTemplateModel? template = await _templateService.getTemplate(
      module: widget.moduleName,
      eventType: widget.notificationItem.eventType,
    );

    if (template != null) {
      setState(() {
        _submitted = false;
        currentTemplate = template;
        isNotificationEnabled = template.isEnabled;
        selectedNotificationTypes = List.from(
          template.selectedNotificationTypes,
        );

        templateText.subjectEn.text = template.subjectEnglish;
        templateText.subjectAr.text = template.subjectArabic;
        templateText.bodyEn.text = template.bodyEnglish;
        templateText.bodyAr.text = template.bodyArabic;
        templateText.pushTitleEn.text = template.pushTitleEn;
        templateText.pushTitleAr.text = template.pushTitleAr;
        templateText.pushBodyEn.text = template.pushBodyEn;
        templateText.pushBodyAr.text = template.pushBodyAr;

        isLoadingTemplate = false;
      });
    } else {
      setState(() {
        isNotificationEnabled = widget.notificationItem.isEnabled;
        if (widget.notificationItem.hasEmail) {
          selectedNotificationTypes.add('email');
        }
        if (widget.notificationItem.hasPush) {
          selectedNotificationTypes.add('push');
        }
        isLoadingTemplate = false;
      });
    }
  }

  // ✅ Save template to Firestore
  Future<bool> _saveTemplate() async {
    // Every one of the eight texts is needed (Email and Push, EN and AR).
    if (templateText.invalidChannel() != null) return false;

    setState(() {
      isSaving = true;
    });

    final templateToSave = currentTemplate?.copyWith(
          subjectEnglish: templateText.subjectEn.text.trim(),
          subjectArabic: templateText.subjectAr.text.trim(),
          bodyEnglish: templateText.bodyEn.text.trim(),
          bodyArabic: templateText.bodyAr.text.trim(),
          pushTitleEnglish: templateText.pushTitleEn.text.trim(),
          pushTitleArabic: templateText.pushTitleAr.text.trim(),
          pushBodyEnglish: templateText.pushBodyEn.text.trim(),
          pushBodyArabic: templateText.pushBodyAr.text.trim(),
          isEnabled: isNotificationEnabled,
          selectedNotificationTypes: selectedNotificationTypes,
          updatedAt: DateTime.now(),
        ) ??
        NotificationTemplateModel(
          id: '${widget.moduleName}_${widget.notificationItem.eventType}',
          module: widget.moduleName,
          eventType: widget.notificationItem.eventType,
          subjectEnglish: templateText.subjectEn.text.trim(),
          subjectArabic: templateText.subjectAr.text.trim(),
          bodyEnglish: templateText.bodyEn.text.trim(),
          bodyArabic: templateText.bodyAr.text.trim(),
          pushTitleEnglish: templateText.pushTitleEn.text.trim(),
          pushTitleArabic: templateText.pushTitleAr.text.trim(),
          pushBodyEnglish: templateText.pushBodyEn.text.trim(),
          pushBodyArabic: templateText.pushBodyAr.text.trim(),
          isEnabled: isNotificationEnabled,
          selectedNotificationTypes: selectedNotificationTypes,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    final success = await _templateService.saveTemplate(templateToSave);

    setState(() {
      isSaving = false;
    });

    // Snackbars removed. On success the page closes, which is the feedback;
    // a failure now leaves the user on the editor with their input intact.
    // CHANGED 22/10/2026 (Figma phone flow): Save returns to the view page
    // of this notification instead of closing it.
    if (success && mounted) {
      setState(() {
        currentTemplate = templateToSave;
        isEditMode = false;
        _submitted = false;
      });
    }
    return success;
  }

  /// Owner 22/10/2026: true once Save was pressed — the fields then show
  /// their errors (R-6). Reset whenever the template is loaded.
  bool _submitted = false;

  /// Save is offered only when something differs from the stored template.
  bool get _hasChanges {
    final NotificationTemplateModel? t = currentTemplate;
    if (t == null) return false;
    final Set<String> now = selectedNotificationTypes.toSet();
    final Set<String> was = t.selectedNotificationTypes.toSet();
    return templateText.differsFrom(t) ||
        isNotificationEnabled != t.isEnabled ||
        now.length != was.length ||
        !now.containsAll(was);
  }

  /// Save: show the errors (and the channel that has them) if anything is
  /// missing; otherwise confirm → save → success, the app's standard flow.
  Future<void> _onSavePressed() async {
    if (!_hasChanges || isSaving) return;
    setState(() => _submitted = true);
    final String? bad = templateText.invalidChannel();
    if (bad != null) {
      setState(() => isEmailView = bad == 'email');
      return;
    }
    final bool isAr = Directionality.of(context) == TextDirection.rtl;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
      confirmTitle: S.of(context).saveChanges,
      confirmSubtitle: isAr
          ? 'هل تريد حفظ التغييرات على هذا الإشعار؟'
          : 'Do you want to save the changes to this notification?',
      confirmYesText: S.of(context).confirm,
      confirmNoText: S.of(context).cancel,
      onConfirm: _saveTemplate,
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: S.of(context).Successful,
      successSubtitle:
          isAr ? 'تم حفظ الإشعار بنجاح' : 'The notification was saved.',
    );
  }

  // ✅ Reset to default
  //
  // 23/10/2026 (Moataz): Reset overwrites the whole template, so it asks first
  // ("Are you sure?") like Save does, then resets and says it worked. It used
  // to reset the moment the button was tapped.
  Future<void> _resetToDefault() async {
    final bool isAr = Directionality.of(context) == TextDirection.rtl;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_restore.json',
      confirmTitle: isAr ? 'استعادة الرسائل الافتراضية' : 'Reset to default',
      confirmSubtitle: isAr
          ? 'هل أنت متأكد أنك تريد استعادة الرسائل الافتراضية لهذا الإشعار؟ ستُستبدل رسائلك الحالية.'
          : 'Are you sure you want to reset this notification to its default messages? Your current messages will be replaced.',
      confirmYesText: S.of(context).confirm,
      confirmNoText: S.of(context).cancel,
      confirmWidth: 411,
      successWidth: 411,
      onConfirm: () async {
        final bool success = await _templateService.resetToDefault(
          module: widget.moduleName,
          eventType: widget.notificationItem.eventType,
        );
        // A successful reset repaints the fields from the reloaded template.
        if (success) await _loadTemplate();
        return success;
      },
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: S.of(context).Successful,
      successSubtitle: isAr
          ? 'تمت استعادة الرسائل الافتراضية.'
          : 'The default messages were restored.',
    );
  }

  /// Owner 22/10/2026: Preview is its own page (Figma › Preview
  /// Notification) — the message beside a phone showing how it arrives.
  void _showPreviewDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => NotificationPreviewPage(
          controllers: templateText,
          module: widget.currentTab.module,
          isEmail: isEmailView,
          onSave: _canSave && _hasChanges ? _onSavePressed : null,
        ),
      ),
    );
  }

  // ✅ Helper method to get display text for selected items

  // ✅ Helper to convert display name to key

  /// Throw away unsaved edits: reload the stored template, back to view.
  Future<void> _discardChanges() async {
    await _loadTemplate();
    if (!mounted) return;
    setState(() => isEditMode = false);
  }

  String _channelLabel(String key, bool isRTL) => key == 'email'
      ? (isRTL ? 'البريد الإلكتروني' : 'Email')
      : (isRTL ? 'إشعار الهاتف' : 'Push Notification');

  Widget _toggle(BuildContext context) => CustomSegmentedToggle(
        compact: true,
        height: ButtonSizing.height,
        tabs: [S.of(context).email, S.of(context).notifications],
        selectedIndex: isEmailView ? 0 : 1,
        onChanged: (int index) => setState(() => isEmailView = index == 0),
      );

  Widget _card(Widget child) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: child,
      );

  /// Figma "Editing …": status + channel + Reset Default Messages.
  Widget _statusCard(bool isRTL) {
    final List<String> labels = <String>['email', 'push']
        .map((String k) => _channelLabel(k, isRTL))
        .toList();
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GATED 2/9/2026 — Reset overwrites the whole template, so it
          // needs every right Save needs. Hidden rather than disabled.
          // 23/10/2026 (Moataz): first in the card, then the status, then the
          // channel — the same order as the iPad in portrait.
          if (_canSave) ...[
            SizedBox(
              width: double.infinity,
              child: customButton(
                title: isRTL
                    ? "استعادة الرسائل الافتراضية"
                    : "Reset Default Messages",
                function: _resetToDefault,
                color: AppColors.darkGrey,
                radius: 4.r,
                height: 30.h,
                textStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
              ),
            ),
            SizedBox(height: 15.sp),
          ],
          Row(
            children: [
              CustomSvgImage(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_status.svg",
                width: 16.sp,
                height: 16.sp,
                color: AppColors.secondaryText,
              ),
              SizedBox(width: 8.sp),
              Text(
                isRTL ? "حالة الإشعار" : "Notification Status",
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
              ),
              // Figma: the switch sits at the far end of the row.
              const Spacer(),
              // GATED 2/9/2026 — changeNotificationStatus: shown, inert
              // without the right.
              AbsorbPointer(
                absorbing: !_canChangeStatus,
                child: Opacity(
                  opacity: _canChangeStatus ? 1.0 : 0.5,
                  child: DefaultSwitchButton(
                    value: isNotificationEnabled,
                    onChanged: (bool v) =>
                        setState(() => isNotificationEnabled = v),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.sp),
          Text(
            isRTL ? "قناة الإشعار" : "Notification Channel",
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 8.sp),
          // GATED 2/9/2026 — changeNotificationChannel.
          AbsorbPointer(
            absorbing: !_canChangeChannel,
            child: Opacity(
              opacity: _canChangeChannel ? 1.0 : 0.5,
              child: CustomMultiSelectFilter<String>(
                values: selectedNotificationTypes
                    .map((String k) => _channelLabel(k, isRTL))
                    .toList(),
                items: labels
                    .map((String e) =>
                        MultiSelectDropdownItem<String>(value: e, label: e))
                    .toList(),
                selectedTextBuilder: (_) => selectedNotificationTypes.isEmpty
                    ? (isRTL ? "اختر القناة" : "Select Channel")
                    : selectedNotificationTypes
                        .map((String k) => _channelLabel(k, isRTL))
                        .join(", "),
                hint: isRTL ? "اختر القناة" : "Select Channel",
                onChanged: (List<String> selected) => setState(() {
                  selectedNotificationTypes
                    ..clear()
                    ..addAll(selected
                        .map((String l) => l == labels[0] ? 'email' : 'push'));
                }),
                fillColor: AppColors.background,
                // Owner 22/10/2026: as tall as the 36 text fields.
                height: FieldSizing.height,
                heightSizesWholeTrigger: true,
                valueStyle: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, bool isRTL) {
    Widget button(String key, String title, VoidCallback onTap, Color color,
            Color textColor) =>
        KeyedSubtree(
          key: ValueKey<String>(key),
          child: customButton(
            title: title,
            function: onTap,
            color: color,
            radius: 8.r,
            textStyle: StyleText.fontSize16Weight500.copyWith(color: textColor),
          ),
        );
    // Figma iPhone: Preview | Save, Discard under Preview.
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: button(
                  'notificationEditPagePreview',
                  S.of(context).preview,
                  () => _showPreviewDialog(context),
                  AppColors.primary,
                  AppColors.textButton),
            ),
            SizedBox(width: 16.sp),
            Expanded(
              child: _canSave
                  // R-3: grey, 50%, not tappable until something changed.
                  ? Opacity(
                      opacity: _hasChanges ? 1 : 0.5,
                      child: AbsorbPointer(
                        absorbing: !_hasChanges,
                        child: button(
                          'notificationEditPageSave',
                          S.of(context).save,
                          _onSavePressed,
                          _hasChanges ? AppColors.primary : AppColors.grey,
                          AppColors.textButton,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        Row(
          children: [
            Expanded(
              child: button(
                  'notificationEditPageDiscard',
                  S.of(context).discard,
                  _discardChanges,
                  AppColors.darkGrey,
                  AppColors.text),
            ),
            SizedBox(width: 16.sp),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Owner 22/10/2026: a pushed page draws the watermark itself (like
      // every pushed settings page in get_pages.dart).
      body: WatermarkLayer(
        module: Modules.notification,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 23/10/2026 (Moataz: "do it exactly like Calendar"): the same
              // header as SideFrameMasterServices' phone branch — a 24 chevron,
              // 12 / 3 either side of it, then the title at 24 semibold, 15
              // down. The cards below use the frame's 15 inset.
              Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => HapticController.low(),
                    onTap: () {
                      if (isEditMode) {
                        _discardChanges();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 3.sp,
                        top: 15.sp,
                        left: 12.sp,
                      ),
                      child: Transform.rotate(
                        angle: isRTL ? 0 : 3.1416,
                        child: CustomSvgImage.natural(
                          assetPath:
                              'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg',
                          width: 24.sp,
                          height: 24.sp,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 15.sp),
                      child: Text(
                        // Owner 22/10/2026: a fixed page title — a long
                        // notification name wrapped and clashed with the row.
                        isEditMode
                            ? (isRTL ? "تعديل التفاصيل" : "Edit Details")
                            : (isRTL
                                ? "تفاصيل الإشعار"
                                : "Notification Details"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize24Weight600
                            .copyWith(color: AppColors.text),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.sp),
              // 23/10/2026 (Moataz): the Edit button and the Email | Notifications
              // switch stay pinned while the page scrolls under them.
              if (!isEditMode && !isLoadingTemplate)
                Padding(
                  padding: EdgeInsets.fromLTRB(15.sp, 0, 15.sp, 10.sp),
                  child: Row(
                    children: [
                      if (_canSave)
                        customButtonWithSvg(
                          title: "",
                          function: () => setState(() => isEditMode = true),
                          width: 38,
                          color: AppColors.primary,
                          textStyle: StyleText.fontSize16Weight500,
                          radius: 8.r,
                          heightImage: 20,
                          widthImage: 20,
                          svgColor: AppColors.textButton,
                          image:
                              "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                          space: 0,
                          colorBorder: AppColors.transparent,
                        ),
                      const Spacer(),
                      _toggle(context),
                    ],
                  ),
                ),
              Expanded(
                child: isLoadingTemplate
                    ? Center(child: CircleProgressMaster())
                    : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(15.sp, 0, 15.sp, 16.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isEditMode) ...[
                              _statusCard(isRTL),
                              SizedBox(height: 10.sp),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: _toggle(context),
                              ),
                            ],
                            SizedBox(height: 10.sp),
                            NotificationTemplateEditor(
                              controllers: templateText,
                              isEmail: isEmailView,
                              enabled: isEditMode &&
                                  (isEmailView
                                      ? _canEditEmailCopy
                                      : _canEditPushCopy),
                              module: widget.currentTab.module,
                              onChanged: () => setState(() {}),
                              stackTitles: true,
                              showVariables: isEditMode,
                              submitted: _submitted,
                            ),
                            if (isEditMode) ...[
                              SizedBox(height: 16.sp),
                              _footer(context, isRTL),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
