/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: comments_and_feedback_screen.dart
/// Description: "Comments and Feedbacks" — the employee's own submissions above,
///          and the form that adds another below.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 2/9/2026 - Rebuilt against Figma (MESBAH, node 4717:8596). Three
///          changes:
///
///   1. THE TWO HALVES ARE NOW TABS. The list and the form used to be stacked,
///      so reaching Submit meant scrolling past every request already filed.
///      [CustomSegmentedTabs] switches between "New Request" and "Requested
///      Feedback", and the Submit button only exists under the first.
///   2. EXPAND / HIDE PER BOX. Ticking a box opens its form; the link on the
///      right of the row folds it away again while keeping the tick. Three
///      open forms at once was most of the screen's height.
///   3. THE "MORE OPTIONS" PANEL. Seven triage dropdowns and a "Steps to
///      reproduce" box, collapsed by default, in
///      [FeedbackMoreOptionsPanel]. All of it optional and none of it gates
///      Submit — see [hasAnyData], which still only wants a ticked box with
///      text in it.
///
/// Updated: 1/9/2026 - Rebuilt against Figma (MESBAH, nodes 7628:8180 and
///          7628:7681). Four changes, in rough order of size:
///
///   1. THE LIST IS NEW. The screen was write-only: you submitted and never
///      saw it again. "Request Details" now sits above the form — All / Open /
///      Fixed / Closed chips, a search box, a sort menu and a card per
///      submission — fed by [CommentsFeedbackCubit].
///   2. MANY ATTACHMENTS PER BOX. Picking a second file used to REPLACE the
///      first. Files are now a growing 2-column grid with the "Attach
///      Document" button as its last cell, which is what the design draws.
///   3. A PRIORITY PER BOX. New field, written to the submission document.
///   4. The middle box is labelled "Improvements To Existing Feature", not
///      "Comments And Feedback". Presentation only — the stored `type` is
///      still `'comment'`, so existing documents keep counting.
///
/// FIXED in the same pass: the tablet branch used to `return Expanded(...)`
/// while `settings_layout.dart` ALREADY wraps this screen in an `Expanded`.
/// Two ParentDataWidgets writing the same Flex slot is an "Incorrect use of
/// ParentDataWidget" error, not a layout preference. The branch now returns a
/// plain Column and lets the caller own the Expanded.
///
/// ALSO FIXED: a successful submit called `Get.back()` unconditionally. On
/// tablet this screen is an embedded pane, not a pushed route, so that popped
/// the settings shell out from under the user. It now pops only on the phone
/// layout, where the screen really is a route.
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_confirm_dialog.dart'
    show showConfirmDialog;
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_request_details_view.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:knowticed_plus/features/settings/se7_app_info/data/data_source/remote_data_source/feedback_attachment_remote_data_source.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_tab_with_container.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/controller/comments_feedback_cubit.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/controller/comments_feedback_state.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_attachments_grid.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_display.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_more_options_panel.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_priority_dropdown.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_request_card.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_sort_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

part '../widgets/comments_and_feedback_screen/comments_and_feedback_view_builders.dart';
part '../widgets/comments_and_feedback_screen/comments_and_feedback_view_logic.dart';

/// Chip keys. Strings because [StatusChipFilter] is keyed by string; the enum
/// is the source of truth and [_filterFromKey] is the only place they meet.
const String _kChipAll = 'All';

class CommentsAndFeedbackScreen extends StatelessWidget {
  const CommentsAndFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentsFeedbackCubit>(
      create: (_) => CommentsFeedbackCubit()..load(),
      child: const CommentsAndFeedbackView(),
    );
  }
}

class CommentsAndFeedbackView extends StatefulWidget {
  const CommentsAndFeedbackView({super.key});

  @override
  State<CommentsAndFeedbackView> createState() =>
      _CommentsAndFeedbackViewState();
}

class _CommentsAndFeedbackViewState extends State<CommentsAndFeedbackView> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  /// One controller per box, keyed by kind so the three boxes stop being three
  /// near-identical blocks of copy-pasted code.
  final Map<FeedbackKind, TextEditingController> _controllers =
      <FeedbackKind, TextEditingController>{
    for (final FeedbackKind kind in FeedbackKind.values)
      kind: TextEditingController(),
  };

  /// One "Steps to reproduce" controller per box, same reasoning as
  /// [_controllers] — owned here so each is created and disposed exactly once.
  ///
  /// No listener on these. The Submit button's enabled state does not depend
  /// on the steps text (it is optional), so a keystroke here has nothing to
  /// rebuild — unlike [_controllers], which does drive [hasAnyData].
  final Map<FeedbackKind, TextEditingController> _stepsControllers =
      <FeedbackKind, TextEditingController>{
    for (final FeedbackKind kind in FeedbackKind.values)
      kind: TextEditingController(),
  };

  /// Which boxes are ticked. All start unticked.
  final Set<FeedbackKind> _selectedKinds = <FeedbackKind>{};

  /// Which ticked boxes are showing their form.
  ///
  /// SEPARATE from [_selectedKinds] on purpose: the design's "Hide" link folds
  /// a box away WITHOUT unticking it, so the text and files the user already
  /// entered survive. Ticking a box adds it to both sets; unticking removes it
  /// from both and discards its content.
  final Set<FeedbackKind> _expandedKinds = <FeedbackKind>{};

  /// Which boxes have their "More Options" panel open. Independent of
  /// [_expandedKinds] so folding a box away and reopening it does not also
  /// reset the panel the user had deliberately opened.
  final Set<FeedbackKind> _moreOptionsKinds = <FeedbackKind>{};

  /// The "More Options" answers per box. A box gets an entry the moment it is
  /// ticked, so [FeedbackMoreOptionsPanel] never has to handle a null.
  final Map<FeedbackKind, FeedbackDetails> _details =
      <FeedbackKind, FeedbackDetails>{};

  /// Which tab is showing: 0 = the form, 1 = the list of past submissions.
  ///
  /// Starts on the form. This screen is reached from a settings row called
  /// "Comments and Feedbacks", and the reason someone opens it is almost
  /// always to file something rather than to review what they already filed.
  int _tabIndex = 0;

  /// ADDED 21/9/2026 — a card opens Request Details as its OWN page with
  /// the "Settings › Comments And Feedbacks › Request Details" breadcrumb,
  /// the same way the Watermark row opens its page (a push on the settings
  /// pane's navigator), rather than swapping content under the tabs.
  void _openRequest(BuildContext context, FeedbackRequest request) =>
      openFeedbackRequestDetailsPage(context, request);

  /// Files already uploaded for each box, in the order they were added.
  ///
  /// CHANGED 1/9/2026 — was one attachment per kind, replaced on every pick.
  final Map<FeedbackKind, List<FeedbackAttachment>> _attachments =
      <FeedbackKind, List<FeedbackAttachment>>{};

  final Map<FeedbackKind, FeedbackPriority> _priorities =
      <FeedbackKind, FeedbackPriority>{};

  /// Which upload is in flight, or null. Only one at a time — Submit is
  /// blocked meanwhile so a document cannot be written without the file that
  /// was meant to be on it.
  FeedbackKind? _uploadingKind;

  @override
  void initState() {
    super.initState();
    for (final TextEditingController controller in _controllers.values) {
      controller.addListener(_onBodyChanged);
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.removeListener(_onBodyChanged);
      controller.dispose();
    }
    for (final TextEditingController controller in _stepsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// The Submit button's enabled state depends on the text, so every keystroke
  /// has to rebuild. Guarded against a rebuild after dispose.
  void _onBodyChanged() {
    if (mounted) setState(() {});
  }

  // ── Submit gating ─────────────────────────────────────────────────────────

  /// A box counts only when it is ticked AND has non-whitespace text — the
  /// same rule [AppFeedback.bodies] applies on the way to Firestore.
  bool _hasBody(FeedbackKind kind) =>
      _selectedKinds.contains(kind) &&
      (_controllers[kind]?.text.trim().isNotEmpty ?? false);

  bool get hasAnyData {
    // An upload in flight blocks submit: the write must not go out before the
    // file that belongs on it has a URL.
    if (_uploadingKind != null) return false;
    return FeedbackKind.values.any(_hasBody);
  }

  String _bodyFor(FeedbackKind kind) =>
      _hasBody(kind) ? _controllers[kind]!.text : '';

  /// Function Name: [_detailsForSubmit]
  ///
  /// Purpose: Fold each box's live "Steps to reproduce" text into its
  ///          [FeedbackDetails] on the way out.
  ///
  /// The steps controllers are NOT mirrored into [_details] on every
  /// keystroke — see the note on [FeedbackMoreOptionsPanel.stepsController].
  /// This is the one place the two are joined, which is why it runs at submit
  /// time rather than in a listener.
  ///
  /// Returns: an entry per ticked box. [AppFeedback.detailsByKind] then drops
  ///          the ones whose body is empty or whose panel is untouched, so
  ///          nothing here needs to filter.
  Map<FeedbackKind, FeedbackDetails> _detailsForSubmit() {
    return <FeedbackKind, FeedbackDetails>{
      for (final MapEntry<FeedbackKind, FeedbackDetails> entry
          in _details.entries)
        entry.key: entry.value.copyWith(
          stepsToReproduce: _stepsControllers[entry.key]?.text ?? '',
        ),
    };
  }

  /// Drops one file from a box.
  ///
  /// Clears the local reference only. The uploaded object is left in the
  /// bucket: deleting it here would need a Storage delete the user may not be
  /// permitted, and an unreferenced file is harmless.
  void _removeAttachment(FeedbackKind kind, int index) {
    final List<FeedbackAttachment>? files = _attachments[kind];
    if (files == null || index < 0 || index >= files.length) return;
    setState(() {
      files.removeAt(index);
      if (files.isEmpty) _attachments.remove(kind);
    });
  }

  /// A best-effort MIME type from the picked extension. Storage defaults to
  /// `application/octet-stream` without one, which makes an image download
  /// instead of previewing.
  String? _contentTypeOf(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
      case 'log':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return null;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    // Kept as the original screen had it: the settings shell embeds this pane
    // on anything wider than a phone, and pushes it as a route on a phone.
    final bool isEmbedded = !kpIsPhoneLayout(context);

    return BlocBuilder<CommentsFeedbackCubit, CommentsFeedbackState>(
      builder: (BuildContext context, CommentsFeedbackState state) {
        final CommentsFeedbackCubit cubit =
            context.read<CommentsFeedbackCubit>();
        final CommentsFeedbackLoaded? loaded =
            state is CommentsFeedbackLoaded ? state : null;
        final bool isSubmitting = loaded?.isSubmitting ?? false;

        final Widget submitButton = _buildSubmitButton(
          context,
          cubit: cubit,
          isSubmitting: isSubmitting,
          popOnSuccess: !isEmbedded,
          isMobile: isMobile,
        );

        final bool isNewRequestTab = _tabIndex == 0;

        final Widget body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTabs(context),
            SizedBox(height: 16.h),
            // Only one of the two is built. An IndexedStack would keep the
            // hidden half alive, which sounds like it would preserve the
            // form — but the form's state already lives in this State object
            // and survives either way, while the list would go on holding a
            // GridView of cards nobody is looking at.
            if (isNewRequestTab)
              _buildNewRequestSection(context, cubit: cubit, isMobile: isMobile)
            else
              _buildRequestDetailsSection(
                context,
                cubit: cubit,
                state: state,
                isMobile: isMobile,
              ),
          ],
        );

        if (isEmbedded) {
          // NO Expanded here — settings_layout.dart already wraps this widget
          // in one. See the FILE INFO note.
          return Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: body,
                ),
              ),
              // Submit belongs to the form, so it goes away with it. Leaving
              // it pinned under the request list would offer to send a form
              // the user cannot currently see.
              if (isNewRequestTab) ...<Widget>[
                SizedBox(height: 16.h),
                submitButton,
                SizedBox(height: 16.h),
              ],
            ],
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: S.of(context).settings,
            secondTitle: S.of(context).commentsAndFeedbacks,
            onFirstTap: () => Navigator.pop(context),
            onSecondTap: () => Navigator.pop(context),
            // D-202 (21/10/2026): Submit is PINNED at the bottom on the phone
            // too — the form scrolls above it, the button never moves.
            child: SideFrameBoundedBody(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: body,
                    ),
                  ),
                  if (isNewRequestTab) ...<Widget>[
                    SizedBox(height: 16.h),
                    submitButton,
                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────

  /// The "New Request / Requested Feedback" switch above both halves.
  ///
  /// [CustomSegmentedTabs] with `equalWidth: false`, so the pill hugs its two
  /// labels instead of stretching the width of the settings pane — the design
  /// draws it left-aligned and only as wide as its content.
  Widget _buildTabs(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: CustomSegmentedTabs(
        tabs: <String>[
          S.of(context).newRequest,
          S.of(context).requestedFeedback,
        ],
        selectedIndex: _tabIndex,
        onTabSelected: (int index) {
          if (index == _tabIndex) return;
          // lightImpact, not mediumImpact: [VibrateType] has no selection
          // tier, and switching a tab should not feel as consequential as
          // pressing Submit, which is what medium is used for below.
          AppControllers.haptic.triggerHapticFeedback(
            vibration: VibrateType.lightImpact,
            hapticFeedback: HapticFeedback.selectionClick,
          );
          setState(() => _tabIndex = index);
        },
        containerColor: AppColors.card,
        unselectedColor: AppColors.transparent,
      ),
    );
  }

  // ── Request Details ───────────────────────────────────────────────────────

  Widget _buildRequestDetailsSection(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required CommentsFeedbackState state,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
          child: _buildRequestDetailsBody(
            context,
            cubit: cubit,
            state: state,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Center(
        child: CustomEmptyState(
          lottiePath:
              'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
          size: 180,
          verticalPadding: 0,
        ),
      ),
    );
  }

  static String _chipKey(FeedbackStatusFilter filter) {
    switch (filter) {
      case FeedbackStatusFilter.all:
        return _kChipAll;
      case FeedbackStatusFilter.open:
        return FeedbackStatus.open.wireValue;
      case FeedbackStatusFilter.fixed:
        return FeedbackStatus.fixed.wireValue;
      case FeedbackStatusFilter.closed:
        return FeedbackStatus.closed.wireValue;
    }
  }

  static FeedbackStatusFilter _filterFromKey(String key) {
    if (key == FeedbackStatus.open.wireValue) return FeedbackStatusFilter.open;
    if (key == FeedbackStatus.fixed.wireValue) {
      return FeedbackStatusFilter.fixed;
    }
    if (key == FeedbackStatus.closed.wireValue) {
      return FeedbackStatusFilter.closed;
    }
    return FeedbackStatusFilter.all;
  }

  // ── New Request ───────────────────────────────────────────────────────────

  Widget _buildNewRequestSection(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required bool isMobile,
  }) {
    // No "New Request" caption here any more — the tab above the section
    // already says it, and the design does not draw it twice.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CustomSvgImage(
                    assetPath:
                        'assets/icons_assets/settings_assets/ic_page_feedback.svg',
                    width: 25.w,
                    height: 25.h,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      S.of(context).commentsAndFeedbacks,
                      style: StyleText.fontSize20Weight600.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              for (final FeedbackKind kind in FeedbackKind.values)
                _buildKindBox(
                  context,
                  cubit: cubit,
                  kind: kind,
                  isMobile: isMobile,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Function Name: [_setExpanded]
  ///
  /// Purpose: Fold a ticked box's form away, or bring it back.
  ///
  /// Keeps the tick, the text, the files, the priority and the More Options
  /// answers — this is a display toggle, not a reset. Only unticking discards
  /// anything, which is the one place a user has clearly said they no longer
  /// want that box.
  void _setExpanded(FeedbackKind kind, bool expanded) {
    setState(() {
      if (expanded) {
        _expandedKinds.add(kind);
      } else {
        _expandedKinds.remove(kind);
      }
    });
  }

  // ── Submit button ─────────────────────────────────────────────────────────

  Widget _buildSubmitButton(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required bool isSubmitting,
    required bool popOnSuccess,
    required bool isMobile,
  }) {
    final bool enabled = hasAnyData && !isSubmitting;

    // CHANGED 8/9/2026 — Submit spans the full width of the form.
    //
    // It used to be `wrapContent: true` inside a centring Row, so the button
    // hugged its label and sat as a short pill under a full-width form.
    //
    // The Row is gone rather than kept: a Row hands its non-flex children
    // UNBOUNDED width, so a `width: double.infinity` inside one resolves to
    // infinity and throws. Both call sites drop this straight into a Column
    // (see the isEmbedded branch and the Scaffold branch above), which does
    // pass a bounded width down, so the button can simply take it.
    //
    // `width:` and not `fullWidth:` — customButton honours the former directly
    // and discards the latter; its own SCOPE note in 5-custom_button.dart says
    // so. Passing `fullWidth` here would silently leave the fixed width in
    // place.
    // Owner 21/10/2026 (R-3): disabled = grey, black text, faded to 50%,
    // and untappable.
    return Center(
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: IgnorePointer(
          ignoring: !enabled,
          child: customButton(
            title: S.of(context).submit,
            function: enabled
                ? () => _submit(
                      cubit: cubit,
                      isSubmitting: isSubmitting,
                      popOnSuccess: popOnSuccess,
                    )
                : () {}, // Empty function instead of null
            // CHANGED 21/9/2026 — Settings bug report p.17/p.18: the full-width bar
            // is narrowed to a centred button (see the Center wrapper below).
            width: isMobile ? double.infinity : 300.sp,
            // Owner 21/10/2026: 38.sp like the Attach Document / Priority boxes.
            height: 38.sp,
            radius: 4.r,
            color: enabled ? AppColors.primary : AppColors.grey,
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: enabled ? AppColors.textButton : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
