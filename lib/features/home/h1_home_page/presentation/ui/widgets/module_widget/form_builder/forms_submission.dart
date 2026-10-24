// [module-file:form_builder] — deleted when the form_builder module is split out
/// Module: home/h1_home_page
/// File Name: forms_submission.dart
/// Description: The Home "Forms Submission" card (Form Builder). Moved out of
///          home_extra_widgets.dart on 17/10/2026 so the shared Home file
///          has no Form Builder code (module split).
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/pages/form_builder_responsive_page.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/forms_submission_summary.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/form_builder/forms_actions.dart';
import 'package:knowticed_plus/features/form_builder/presentation/navigation/form_builder_shortcut.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/helper/date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/widget_settings/home_picker_dialog.dart';

/// Figma: "Forms Submission" — a completion ring plus the two form actions.
///
/// CHANGED 26/9/2026 (form bug report #25): was a static Figma placeholder
/// (75%, "Form Name", buttons with no onTap). It now shows the user's latest
/// published form with its real submitted / sent ratio; "View Submissions"
/// opens that form's Results inside the Form Builder module and "Remind All"
/// sends the reminders exactly like the Pending tab does.
/// The Form Builder glyph (card header, picker header and tiles).
const String kHomeFormIcon =
    'assets/icons_assets/main_icons_assets/ic_module_form_builder.svg';

/// Function Name: [homeFormItems]
///
/// Purpose: The user's published forms, newest first — the choices of the
/// Forms Submission gear.
Future<List<HomePickItem>> homeFormItems() async {
  final List<HomePickItem>? cached = HomePickerCache.forms.fresh;
  if (cached != null) return cached;
  final List<FormEntity> forms = await FormsSubmissionSummary.publishedForms();
  return HomePickerCache.forms.store(<HomePickItem>[
    for (final FormEntity f in forms)
      HomePickItem(
        id: f.id,
        name: f.getTitle,
        placeholderIcon: kHomeFormIcon,
        // Owner 22:02: the created date tells similar titles apart
        // (18 Apr 2021 format).
        subtitle: DateTimeHelper.formatDateDDMMMYYYY(f.createDate),
      ),
  ]);
}

class FormsSubmission extends StatefulWidget {
  final HomeComponentModel model;

  const FormsSubmission({super.key, required this.model});

  @override
  State<FormsSubmission> createState() => _FormsSubmissionState();
}

class _FormsSubmissionState extends State<FormsSubmission>
    with TickerProviderStateMixin {
  final FormsSubmissionSummary _summary = FormsSubmissionSummary();
  bool _loading = true;
  bool _hasForm = false;

  /// The form picked in the gear; '' = the latest published.
  String get _formId {
    final List<String> picked =
        widget.model.widgetSettings.list(HomeSettingKey.form, const <String>[]);
    return picked.isEmpty ? '' : picked.first;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _loading = true;
    _summary.load(formId: _formId).then((ok) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasForm = ok;
      });
    });
  }

  @override
  void didUpdateWidget(covariant FormsSubmission oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The gear picked another form.
    if (oldWidget.model.settings != widget.model.settings) setState(_load);
  }

  @override
  void dispose() {
    _summary.dispose();
    super.dispose();
  }

  void _viewSubmissions() {
    final form = _summary.form;
    if (form == null) {
      // Bug report p.2: with no published form both buttons used to be
      // disabled (onTap: null), which read as "not working". Open the Form
      // Builder on its Publish tab instead.
      openFormBuilderFromHome(context, shortcut: FormBuilderShortcut.publish);
      return;
    }
    FormResponsivePageLayout.pendingResultForm = form;

    if (!kpIsPhoneLayout(context)) {
      final drawer = NotificationRouting.drawerCubit();
      final index = drawer.allowedDrawerModules.indexOf(Modules.formBuilder);
      if (index == -1) {
        FormResponsivePageLayout.pendingResultForm = null;
        return;
      }
      drawer.updateSelectedIndex(index);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => Modules.formBuilder.widget),
      );
    }
  }

  Future<void> _remindAll() async {
    if (_summary.form == null) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: AppAssets.lottieWarning,
        title: Directionality.of(context) == TextDirection.rtl
            ? 'لا توجد نماذج منشورة'
            : 'No Published Forms',
        subtitle: Directionality.of(context) == TextDirection.rtl
            ? 'انشر نموذجًا أولًا لإرسال التذكيرات.'
            : 'Publish a form first to send reminders.',
      );
      return;
    }
    final sent = await _summary.remindAll();
    if (!mounted) return;
    setState(() {});
    if (sent > 0) {
      CustomDialogManager.showSuccess(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
        title: Directionality.of(context) == TextDirection.rtl
            ? 'تم إرسال التذكير بنجاح'
            : 'Reminder Sent Successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final double completion = _summary.completion;
    final String formTitle = _loading
        ? '...'
        : (_hasForm ? (_summary.form?.getTitle ?? l.formName) : l.formName);

    return HomeWidgetCard(
      title: l.formsSubmission,
      // Bug report p.26 ("form icon"): the same form document icon the
      // "Forms" card next to it uses, not the service-request glyph.
      icon: kHomeFormIcon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Owner 21/10/2026 (diagonal cut): the form on top, the buttons on
        // the bottom inset — 16 from the bottom like the sides.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formTitle,
                      style: CardStyles.value(14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_hasForm)
                      Text(
                        '${_summary.submitted}/${_summary.submitted + _summary.pending}',
                        style: CardStyles.label(12),
                      ),
                  ],
                ),
              ),
              // 23/10/2026 (Moataz, twice): the ring was 38, then 50, and "50%"
              // still touched its line — 56 is the most the card body holds
              // above the buttons.
              SizedBox(
                width: 50.r,
                height: 50.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // SizedBox.expand: a Stack hands its child LOOSE limits, so the indicator
                    // stayed at its default 36 whatever size the box was (the ring
                    // never grew — Moataz 23/10/2026).
                    SizedBox.expand(
                        child: CircleProgressMaster.inline(
                      value: _loading ? null : completion,
                      strokeWidth: 3,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.green,
                      ),
                    )),
                    if (!_loading)
                      // 23/10/2026 (Moataz): the figure is as wide as the
                      // ring's inside at 14, so it touched the line. It now
                      // scales DOWN to fit inside the ring (never up).
                      Padding(
                        padding: EdgeInsets.all(8.r),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${(completion * 100).round()}%',
                            style: CardStyles.value(14),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: HomeCardButton(
                  label: l.viewSubmissions,
                  onTap: _loading ? null : _viewSubmissions,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: HomeCardButton(
                  label: l.remindAll,
                  icon: HomeWidgetSvg.bell,
                  onTap: _loading ? null : _remindAll,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
