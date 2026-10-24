/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_screen.dart
/// Description: `FormSubmissionsScreen` page, state and UI of the `FormSubmissionsScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_log_service.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder/helpers/submitted_page_viewer.dart'
    show SubmittedPageViewer;
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/presentation/controller/form_submissions_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/presentation/controller/submission_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/main_helper/messaging_interface_implementation.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/form_builder_test_button.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller_mapper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/utils/pdf_page_keys.dart';

/// A form opened to be filled out, or a submitted answer opened to be read or edited.
class FormSubmissionsScreen extends StatefulWidget {
  const FormSubmissionsScreen({
    super.key,
    required this.model,
    this.isFillMode = false,
  });

  final FormEntity model;

  /// True when opened from Form Details to fill the form out: the upper
  /// section (editable label / submission date) is hidden.
  final bool isFillMode;

  @override
  State<FormSubmissionsScreen> createState() => _FormSubmissionsScreenState();
}

class _FormSubmissionsScreenState extends State<FormSubmissionsScreen> {
  // Form validation state lives in the page, not the cubit (§16).
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const double a4PortraitWidth = 794.0;
  static const double a4LandscapeWidth = 1123.0;

  /// Bug report #16/#22: Submit stays locked until every required field is
  /// answered. Answers live on the field controllers (several fields write
  /// them without telling anyone), so the page re-checks on every change it
  /// hears about AND on a light 400ms tick.
  bool _canSubmit = false;
  Timer? _canSubmitTicker;

  /// Bumped by "Fill demo data": the viewer is rebuilt under a new key so
  /// every field re-reads its (now filled) answer — text fields only read
  /// their answer once, when they are first built.
  int _demoFillVersion = 0;

  /// Test-only, same visibility as the other demo buttons.
  bool _showFillDemo(SubmissionsLoaded state) =>
      FormBuilderTestButton.isVisible &&
      !state.isReadOnly &&
      !state.isSubmitted;

  /// The field controllers of this form. Owned by the page (created here,
  /// disposed in [dispose]); the cubit only reads them when asked.
  late final List<PageControllerModel> _pages;

  void _fillDemo() {
    final int n = context.read<FormSubmissionsCubit>().fillDemoAnswers(_pages);
    setState(() => _demoFillVersion++);
    _recheckCanSubmit();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(S.of(context).fbDemoAnswersFilled(n)),
      ),
    );
  }

  void _recheckCanSubmit() {
    if (!mounted) return;
    final bool now = context.read<FormSubmissionsCubit>().allRequiredAnswered(
      _pages,
    );
    if (now != _canSubmit) setState(() => _canSubmit = now);
  }

  @override
  void dispose() {
    _canSubmitTicker?.cancel();
    for (final page in _pages) {
      for (final row in page.rows) {
        row.numOfColumn?.dispose();
        for (final controller in row.controllers) {
          controller.dispose();
        }
      }
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // System Logs: the form was opened to be filled out (from Fill Out Form,
    // Requested Forms or Submissions).
    FormBuilderLogService.log(FormBuilderLogService.actionFillOutForm);
    _canSubmitTicker = Timer.periodic(
      const Duration(milliseconds: 400),
      (_) => _recheckCanSubmit(),
    );
    _pages = widget.model.pages
        .map(
          (page) => page.toController(
            isSetData: widget.model.status == FormStatus.submissions,
          ),
        )
        .toList();
    context.read<FormSubmissionsCubit>().init(model: widget.model);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        preparePdfPages(context, widget.model.pages.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // One header for both form factors, drawn by
    // SideFrameMasterServices, replacing the CustomAppBar / PaginationAppBar
    // pair. The crumbs also move OUT of the SubmissionsLoaded branch, so the
    // header is present while the submission is still loading.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        // Bug report #18: Form Builder > Submissions > <form name>.
        secondTitle: S.of(context).submissions,
        thirdTitle: widget.model.getTitle,
        onFirstTap: breadcrumbPop(context, 1),
        onSecondTap: breadcrumbPop(context, 1),
        // EXACTLY LIKE ConvertPdfScreen - SingleChildScrollView with Container margin
        child: SingleChildScrollView(
          child: Container(
            // Margin, like ConvertPdfScreen (not padding).
            // On tablet the frame
            // already insets the content to line up with the breadcrumb title,
            // so the extra 15.w start margin pushed the Edit button / page in
            // from the title's edge. Tablet start is now 0 — the Edit button
            // and the page line up with the title. Phone keeps its 15.w.
            margin: EdgeInsetsDirectional.only(
              start: ContextExtension(context).isPhone ? 15.w : 0,
              end: ContextExtension(context).isPhone
                  ? 15.w
                  : 121.w, // Same as ConvertPdfScreen
            ),
            child: BlocConsumer<FormSubmissionsCubit, SubmissionsState>(
              // A failed submission is shown here, by the page (the cubit
              // only emits the translated message).
              listenWhen: (previous, current) =>
                  current is SubmissionsLoaded &&
                  current.errorMessage != null &&
                  (previous is! SubmissionsLoaded ||
                      previous.errorId != current.errorId),
              listener: (context, state) {
                final String? message =
                    (state as SubmissionsLoaded).errorMessage;
                if (message != null) {
                  AppDialogs.submitFormFailed(context, message);
                }
              },
              builder: (context, submissionsState) {
                if (submissionsState is! SubmissionsLoaded) {
                  return const CircleProgressMaster();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 0 on a vertical tablet — see formBuilderTopGap.
                    verticalSpace(formBuilderTopGap(context, 30)),

                    // Form content - NO Center, NO width constraints on outer container
                    _buildForm(context, submissionsState),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// The form: header, demo button, the pages and the actions.
  Widget _buildForm(BuildContext context, SubmissionsLoaded submissionsState) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Upper section
          if (!widget.isFillMode) _upperSection(context, submissionsState),

          const SizedBox(height: 10),

          if (_showFillDemo(submissionsState)) ...[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: customButtonWithSvg(
                title: S.of(context).fbFillDemoData,
                function: _fillDemo,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.primary,
                ),
                color: AppColors.card,
                colorBorder: AppColors.primary,
                image: '',
                widthImage: 0,
                heightImage: 0,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // SubmittedPageViewer with proper A4 width based on orientation
          SubmittedPageViewer(
            key: ValueKey('viewer_$_demoFillVersion'),
            model: widget.model,
            pages: _pages,
            isReadOnly: submissionsState.isReadOnly,
            isSubmitted: submissionsState.isSubmitted,
            // Pass A4 width based on orientation
            width: _getA4Width(),
            onAnyChanged: _recheckCanSubmit,
          ),

          verticalSpace(15),

          // Action buttons
          if (_showActionsButtons(submissionsState))
            Row(
              children: [
                if (_showDiscardButton(submissionsState))
                  _buildDiscardButton(context, submissionsState),
                const Spacer(),
                _buildSubmitButton(context, submissionsState),
              ],
            ),
          verticalSpace(15),
        ],
      ),
    );
  }

  // NEW: Get A4 width based on form orientation
  double _getA4Width() {
    final orientation = widget.model.formHeadModel.orientation.toLowerCase();
    final isLandscape = orientation.contains('landscape');
    return isLandscape ? a4LandscapeWidth : a4PortraitWidth;
  }

  Widget _buildDiscardButton(BuildContext context, SubmissionsLoaded state) {
    return customButtonWithSvg(
      title: S.of(context).discard,
      function: state.isSubmitting ? () {} : () => context.pop(),
      // Bug report p.31: the app's standard secondary button (light grey,
      // white text in dark mode) instead of darkerGrey with black text.
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      color: AppColors.darkGrey,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  Widget _buildSubmitButton(BuildContext context, SubmissionsLoaded state) {
    // Locked (dimmed, not tappable) until every required field is answered.
    return Opacity(
      opacity: _canSubmit ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !_canSubmit,
        child: _submitButtonCore(context, state),
      ),
    );
  }

  Widget _submitButtonCore(BuildContext context, SubmissionsLoaded state) {
    return customButtonWithSvg(
      title: state.isSubmitting
          ? S.of(context).submitting
          : S.of(context).submit,
      function: state.isSubmitting
          ? () {}
          : () {
              final cubit = context.read<FormSubmissionsCubit>();

              // Custom (non-Form) validation lives in the cubit; the Form
              // widget's own validation stays here in the page (§16).
              final bool isCustomValid = cubit.prepareSubmit(_pages);
              if (_formKey.currentState!.validate() && isCustomValid) {
                _submit(state);
              }
            },
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.blackButton,
      ),
      color: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  /// Method Name: [_submit]
  ///
  /// Purpose: confirm dialog, save, success dialog, back to the list. The
  /// dialog flow closes the confirm dialog itself, awaits the save and shows
  /// the success dialog only when it worked. On success the page refreshes
  /// the home list (the cubit no longer receives HomeCubit).
  ///
  /// Parameters:
  /// - [state]: the current state.
  Future<void> _submit(SubmissionsLoaded state) async {
    final FormSubmissionsCubit cubit = context.read<FormSubmissionsCubit>();
    final HomeCubit homeCubit = context.read<HomeCubit>();
    // An existing submission being re-sent is an edit; anything else is a
    // first response.
    final bool isEdit = widget.model.status == FormStatus.submissions;
    // FB-RESULT-08: an edit is not saved after the form has closed.
    if (isEdit && !state.canEdit) {
      await AppDialogs.submitFormFailed(
        context,
        S.of(context).formEditingClosed,
      );
      return;
    }
    await AppDialogs.submitForm(
      context,
      () async {
        final bool saved = await cubit.submit(
          model: widget.model,
          pages: _pages,
          isEdit: isEdit,
        );
        if (saved) homeCubit.getForms();
        return saved;
      },
      onSuccessComplete: () {
        cubit.submitFinished();
        if (mounted) context.popToFirst();
      },
    );
  }

  bool _showDiscardButton(SubmissionsLoaded state) {
    if (widget.model.status == FormStatus.submissions && !state.isReadOnly) {
      return true;
    }
    return false;
  }

  Widget _upperSection(BuildContext context, SubmissionsLoaded state) {
    if (widget.model.status != FormStatus.submissions) {
      return Row(
        children: [
          if (widget.model.isEdit)
            // A plain label: "Editable" is information, not an action.
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                S.of(context).editable,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryBlack,
                ),
              ),
            ),
          const Spacer(),
          if (!_isOwnForm) _messageFormOwnerButton(),
        ],
      );
    } else if (widget.model.status == FormStatus.submissions) {
      return Row(
        children: [
          // FB-RESULT-08: no Edit button after the form's access end date.
          if (state.isReadOnly && state.canEdit) _editButton(context, state),
          const Spacer(),
          Row(
            children: [
              Text(
                '${S.of(context).submissionDate}:',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.spanText,
                ),
              ),
              Text(
                ' ${FormDateTimeHelper.formatDate(widget.model.submissionDate ?? DateTime.now())}',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.fullBlack,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  /// True when the signed-in employee IS the form's owner.
  ///
  /// Messaging yourself is not a thing, and the messaging
  /// module agrees — its connection list is built from every OTHER app user,
  /// so your own email is never in it. Without this the button was shown and
  /// then failed with "Could not open the chat", which reads as a bug rather
  /// than as "that is you".
  bool get _isOwnForm {
    final String owner = (widget.model.requestedBy ?? '').trim().toLowerCase();
    final String me = (AppControllers.employee.employeeEntity?.email ?? '')
        .trim()
        .toLowerCase();
    return owner.isNotEmpty && owner == me;
  }

  Widget _messageFormOwnerButton() {
    return customButtonWithSvg(
      title: S.of(context).messageFormOwner,
      function: () => _openOwnerChat(context),
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      image: AppAssets.chat,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }

  /// Opens the one-to-one chat with the form's owner.
  ///
  /// The button was wired to an empty `() {}`, so it drew
  /// itself and did nothing. The flow it needs already exists:
  /// `MessagingInterfaceImplementation.openChatWithUser` was added for exactly
  /// this case, a Message button on a screen OUTSIDE the messaging subtree.
  /// The obvious call, `ConnectionsCubit.selectConnection`, cannot be used
  /// from here — it does `context.read<SingleChatCubit>()`, and nothing above
  /// the form-builder module provides that cubit — so `openChatWithUser`
  /// resolves the messaging cubits from GetX (where `Dependency().init()`
  /// registered them at login) and pushes the chat on the ROOT navigator,
  /// clear of the module's own nested one.
  ///
  /// `model.requestedBy` is the owner's email, and email IS the messaging user
  /// id, so it goes straight in. `openChatWithUser` returns false when
  /// messaging never initialised this session or no employee record matches
  /// that email; the dialog is there so the tap says something instead of
  /// dead-ending.
  Future<void> _openOwnerChat(BuildContext context) async {
    final String ownerEmail = widget.model.requestedBy ?? '';
    // Rule fix (No print / log): the log() calls that printed the owner's
    // email and the form id in release builds were removed.
    if (ownerEmail.isEmpty) {
      return;
    }

    // Bug report #19: on the desktop / tablet shell, go to the Messages
    // module (sidebar kept) with the owner's chat selected — the same route
    // the notification Message button takes. If the chat cannot be selected
    // (e.g. "no messaging profile"), still land on Messages rather than
    // stopping on an error dialog.
    final MessagingInterfaceImplementation messaging =
        MessagingInterfaceImplementation();
    final int messagesIndex = !kpIsPhoneLayout(context)
        ? NotificationRouting.drawerCubit().allowedDrawerModules.indexOf(
            Modules.messages,
          )
        : -1;
    if (messagesIndex != -1) {
      await messaging.selectChatWithUser(userEmail: ownerEmail);
      NotificationRouting.drawerCubit().updateSelectedIndex(messagesIndex);
      return;
    }

    // Phone: push the chat. says WHY (e.g. you are the
    // form owner), localized, and closes itself after 3 s.
    final OpenChatResult result = await messaging.tryOpenChatWithUser(
      context: context,
      userEmail: ownerEmail,
    );
    if (context.mounted) await showOpenChatFailure(context, result);
  }

  Widget _editButton(BuildContext context, SubmissionsLoaded state) {
    return customButtonWithSvg(
      title: S.of(context).edit,
      // Use empty function when submitting instead of null
      function: state.isSubmitting
          ? () {}
          : () {
              context.read<FormSubmissionsCubit>().editClicked();
            },
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      image: AppAssets.edit,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }

  bool _showActionsButtons(SubmissionsLoaded state) {
    if (widget.model.status != FormStatus.submissions ||
        (widget.model.status == FormStatus.submissions && !state.isReadOnly)) {
      return true;
    }
    return false;
  }
}
