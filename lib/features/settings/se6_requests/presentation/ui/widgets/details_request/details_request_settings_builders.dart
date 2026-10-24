/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: details_request_settings_builders.dart
/// Description: UI builder methods of `_DetailsRequestSettingsState` — split out of `details_request.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/details_request.dart';

// Split from details_request.dart to keep every file under 700 lines.

extension _DetailsRequestSettingsStateBuilders on _DetailsRequestSettingsState {
  Widget _buildContent(bool lightMode, bool isMobile) {
    if (isLoading) {
      // CircleProgressMaster, not a bare CircularProgressIndicator: it is the
      // app's spinner — AppColors.lightPrimary on a 60% white track, sized off
      // the breakpoint.
      //
      // The SizedBox is what actually centres it. This return value is placed
      // inside a SingleChildScrollView (and on phone inside
      // SideFrameMasterServices' scroll view as well), so it is handed
      // UNBOUNDED height — a Center there has nothing to centre against and
      // shrink-wraps to the spinner, parking it at the top of the page. Giving
      // it a viewport-height box first is what puts it in the middle.
      //
      // The height is MEASURED, not guessed. A fraction of the screen (this
      // was 0.7) centres the spinner in the fraction, not in the page — 0.7
      // put it about a third of the way down. What is actually left for the
      // content is the viewport minus the system insets minus the frame's own
      // header, so that is what gets computed.
      final MediaQueryData mq = MediaQuery.of(context);

      // SideFrameMasterServices' breadcrumb on phone: a 16.sp top pad, one
      // line of fontSize24Weight600, and the 20.sp gap it puts above the
      // child.
      final double frameHeader = 16.sp + 34.sp + 20.sp;

      final double available =
          mq.size.height - mq.padding.top - mq.padding.bottom - frameHeader;

      return SizedBox(
        // Guard the subtraction: a short viewport (a split-screen tablet, a
        // large text scale) could drive it to zero or below, and a negative
        // height throws.
        height: available > 0 ? available : mq.size.height * 0.6,
        child: const Center(child: CircleProgressMaster()),
      );
    }

    // An empty request still gets the note card and the comment thread — the
    // reviewer may well be asking the submitter what happened to it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // D-222 (21/10/2026): Cancel sits at the end of the title row on
        // every device; the requested date moved INTO the section.
        // 21/10/2026 (Moataz): no second "Request Details" title — the page
        // title already says it; the row only carries Cancel, and is gone
        // when there is nothing to cancel.
        if (_canCancel) ...<Widget>[
          _buildHeader(lightMode, isMobile),
          SizedBox(height: 16.h),
        ],

        if (changes.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(50.sp),
              child: Text(
                'No changes found in this request',
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          )
        else
          // MOVED 21/9/2026 — Cancel now sits at the end of the status row
          // (see _buildRequestNoteSection), where Settings bug report p.13
          // marked the empty slot.
          const SizedBox.shrink(),

        // One card for the whole request. Every changed field is a row inside
        // it, rather than each change getting its own container with the
        // section header repeated.
        if (_commentsExpanded) ...<Widget>[
          _buildSummaryRow(lightMode),
          SizedBox(height: 16.h),
        ] else ...<Widget>[
          _buildChangesCard(lightMode: lightMode, isMobile: isMobile),
          SizedBox(height: 16.h),
          _buildRequestNoteSection(lightMode),
          SizedBox(height: 16.h),
        ],

        _buildCommentsSection(isMobile),
        SizedBox(height: 16.h),
      ],
    );
  }

  /// X-139: the request as ONE row while the comments are expanded — icon,
  /// title, status and date; Collapse brings the full cards back.
  Widget _buildSummaryRow(bool lightMode) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.card,
      ),
      // 23/10/2026 (Moataz): the requested date sits under the title, and on
      // the PHONE the status button takes the full width below them.
      child: ContextExtension(context).isPhone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildSectionHeader(
                  lightMode,
                  _translateSectionTitle(section),
                  subtitle: _buildRequestedDate(),
                ),
                SizedBox(height: 12.sp),
                _buildStatusButton(),
              ],
            )
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildSectionHeader(
                          lightMode,
                          _translateSectionTitle(section),
                          subtitle: _buildRequestedDate(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.sp),
                  SizedBox(
                    width: ContextExtension(context).isPhone ? 120.sp : 150.sp,
                    child: _buildStatusButton(),
                  ),
                ],
              ),
            ),
    );
  }

  /// The single card holding every change in the request.
  ///
  /// Landscape: two columns — "Current Details" and "New Details" — each
  /// listing all changed fields in the same order, so the two sides line up
  /// row for row. Portrait: the pair is stacked per field, separated by a
  /// divider, because two columns are too narrow to read on a phone.
  Widget _buildChangesCard({required bool lightMode, required bool isMobile}) {
    return Container(
      decoration: BoxDecoration(
        // RADIUS 24/8/2026: containers are 8.r on this page, fields are 4.r.
        // This card was 4.r, which made it read like an oversized input.
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.card,
      ),
      // D-146 / D-222: 16 on every side (diagonal cut).
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section title once for the whole request. 23/10/2026 (Moataz):
          // the title sits at the top beside the icon and the requested date
          // directly under it, on every device.
          _buildSectionHeader(
            lightMode,
            _translateSectionTitle(section),
            subtitle: _buildRequestedDate(),
          ),
          SizedBox(height: 16.h),
          // 21/10/2026 (Moataz): the same Current → New pairs as the
          // Personal / Health preview pages on every device — grey "Current"
          // box, green "New" box, side by side on iPad, stacked on the phone.
          // The "Current Details | New Details" column titles are gone.
          ..._buildStackedChanges(lightMode, stacked: isMobile),
        ],
      ),
    );
  }

  /// Whether "Send Reminder" is offered: only while the request is pending.
  bool get _canRemind =>
      RequestStatus.fromWire(status).isPending && !isProcessing;

  /// 21/10/2026 (Moataz): a read-only value written inside its field box —
  /// the same grey box as the Current value, no counter, not typeable.
  Widget _readOnlyBox(String text,
      {required bool isArabic, bool muted = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        style: StyleText.fontSize14Weight400.copyWith(
          color: muted ? AppColors.secondaryText : AppColors.text,
        ),
      ),
    );
  }

  /// The Services reason row (`request_reason_comments.dart`), by status.
  Widget _buildReasonLine(String reason, {required bool isArabic}) {
    final bool isPhone = ContextExtension(context).isPhone;
    final bool approved =
        RequestStatus.fromWire(status) == RequestStatus.approved;
    final Color accent = approved ? AppColors.green : AppColors.red;
    final TextStyle base = (isPhone
            ? StyleText.fontSize12Weight500
            : StyleText.fontSize14Weight500)
        .copyWith(fontWeight: FontWeight.bold);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CustomSvgImage.natural(
          assetPath: 'assets/icons_assets/main_icons_assets/ic_status.svg',
          width: isPhone ? 12.sp : 16.sp,
          height: isPhone ? 12.sp : 16.sp,
          color: approved ? AppColors.lightGreen : AppColors.red,
        ),
        SizedBox(width: 6.sp),
        Expanded(
          child: RichText(
            textDirection:
                isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: '${_reasonLabel()}: ',
                  style: base.copyWith(color: accent),
                ),
                TextSpan(
                  text: FormatHelper.sentence(reason),
                  style: base.copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The label over the decision reason, by status (21/10/2026).
  String _reasonLabel() {
    switch (RequestStatus.fromWire(status)) {
      case RequestStatus.rejected:
        return S.of(context).ReasonOfRejection;
      case RequestStatus.cancelled:
        return S.of(context).ReasonOfCancelation;
      case RequestStatus.approved:
        return S.of(context).ReasonOfApprove;
      default:
        return S.of(context).reason;
    }
  }

  /// 21/10/2026 (Moataz) "Edit And Resend": offered on a REJECTED request
  /// from a section this app can edit again (Personal Information, Health
  /// Insurance, Emergency Contact).
  bool get _canResend {
    final ChangeRequest? request = _request;
    if (request == null || request.status != RequestStatus.rejected) {
      return false;
    }
    final String s = request.section.toLowerCase();
    return s.contains('personal') ||
        s.contains('health') ||
        s.contains('emergency');
  }

  /// Opens the matching edit page with the rejected values filled in; sending
  /// from there raises a NEW pending request (the rejected one stays as is).
  void _editAndResend() {
    final ChangeRequest? request = _request;
    if (request == null) return;
    final bool isPersonal = request.section.toLowerCase().contains('personal');
    navigateTo(
      context,
      isPersonal
          ? EditPageRequest(resendChanges: request.changes)
          : EditPageRequestHealth(resendChanges: request.changes),
    );
  }

  /// The yellow "Edit And Resend" button, same size as Send Reminder.
  Widget _buildResendButton(bool isMobile, {double? width}) {
    return customButtonWithSvg(
      fixedWidth: width ?? (isMobile ? 170.sp : 200.sp),
      title: S.of(context).editAndResend,
      function: _editAndResend,
      color: AppColors.primary,
      colorBorder: AppColors.transparent,
      // Phone: 14 text / 16 icon so it fits half the row (overflowed 18 px).
      textStyle: (isMobile
              ? StyleText.fontSize14Weight500
              : StyleText.fontSize16Weight500)
          .copyWith(color: AppColors.textButton),
      image: 'assets/icons_assets/main_icons_assets/ic_action_edit.svg',
      svgColor: AppColors.textButton,
      widthImage: isMobile ? 16.sp : 18.sp,
      heightImage: isMobile ? 16.sp : 18.sp,
    );
  }

  /// 21/10/2026 (Moataz): one reminder per 24 hours. False while the last
  /// one (stored on the request) is younger than that.
  bool get _reminderAllowed =>
      _request?.canSendReminderAt(DateTime.now()) ?? true;

  /// Time left until the next reminder, as hh:mm:ss.
  String _reminderCountdown() {
    final DateTime? last = _request?.lastReminderAt;
    if (last == null) return '';
    Duration left =
        last.add(ChangeRequest.reminderInterval).difference(DateTime.now());
    if (left.isNegative) left = Duration.zero;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(left.inHours)}:${two(left.inMinutes % 60)}:'
        '${two(left.inSeconds % 60)}';
  }

  /// The yellow Send Reminder button (the same as Services › My Request).
  /// Disabled (R-3: grey, black text, 50%) for 24 hours after a reminder.
  Widget _buildReminderButton(bool isMobile, {double? width}) {
    final bool enabled = _reminderAllowed && !_sendingReminder;
    final double buttonWidth = width ?? (isMobile ? 125.sp : 185.sp);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: IgnorePointer(
            ignoring: !enabled,
            child: customButtonWithSvg(
              fixedWidth: buttonWidth,
              // 21/10/2026 (Moataz): while waiting, the button itself counts
              // down the 24 hours (hh:mm:ss) — no note under it.
              title: _reminderAllowed
                  ? (isMobile
                      ? S.of(context).reminder
                      : S.of(context).SendReminder)
                  : _reminderCountdown(),
              function: _sendReminder,
              color: enabled ? AppColors.primary : AppColors.grey,
              colorBorder: AppColors.transparent,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
              image:
                  'assets/icons_assets/services_assets/ic_time_reminder_calendar.svg',
              svgColor: AppColors.textButton,
              widthImage: 21.sp,
              heightImage: 21.sp,
            ),
          ),
        ),
        // Moataz 23/10/2026: while the reminder is being sent the button
        // shows it is working and ignores taps.
        if (_sendingReminder)
          SizedBox(
            width: 20.sp,
            height: 20.sp,
            child: CircleProgressMaster.inline(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
            ),
          ),
      ],
    );
  }

  /// Re-sends the "change request waiting" notification to the reviewers.
  Future<void> _sendReminder() async {
    if (_sendingReminder) return;
    rebuild(() => _sendingReminder = true);
    try {
      await _sendReminderOnce();
    } finally {
      if (mounted) rebuild(() => _sendingReminder = false);
    }
  }

  Future<void> _sendReminderOnce() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    int sent = 0;
    try {
      sent = await SettingsNotificationService.changeRequestSubmitted(
        requestId: _request?.id ?? widget.requestId ?? '',
        section: section,
        employeeEmail: createdByEmail,
        employeeName: _request?.employeeName ?? '',
        isArabic: isArabic,
      );
    } catch (_) {
      sent = 0;
    }
    if (!mounted) return;
    if (sent > 0) {
      // 21/10/2026: stamp the request so the next reminder waits 24 hours.
      final ChangeRequest? request = _request;
      if (request != null) {
        // Owner 21/10/2026: only stamp + show success when the write succeeded.
        final bool stamped =
            (await _requestsCubit.repository.markReminderSent(request.id))
                .fold((_) => false, (_) => true);
        if (!mounted) return;
        if (!stamped) {
          await _showReminderError();
          return;
        }
        rebuild(
            () => _request = request.copyWith(lastReminderAt: DateTime.now()));
      }
      if (!mounted) return;
      await CustomDialogManager.showSuccess(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
        title: S.of(context).SendReminder,
        subtitle: S.of(context).reminderSent,
      );
    } else {
      await _showReminderError();
    }
  }

  Future<void> _showReminderError() => CustomDialogManager.showMessage(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json',
        title: S.of(context).warning,
        subtitle: S.of(context).errorOccuredPleaseTryAgain,
      );

  /// Phone layout: Current → New stacked per field (D-224), all inside one
  /// card — the label above, the current value in a grey field marked
  /// "Current", the new value under it with a green border marked "New".
  List<Widget> _buildStackedChanges(bool lightMode, {bool stacked = true}) {
    final List<Widget> widgets = <Widget>[];

    for (int i = 0; i < changes.length; i++) {
      final Map<String, String> change = changes[i];
      final String fieldName = change['fieldName'] ?? '';

      String side(bool isNew) {
        final String value = _displayValue(
          fieldName,
          (isNew ? change['newValue'] : change['oldValue']) ?? '',
        );
        final String? code = change[isNew
            ? _DetailsRequestSettingsState._newCountryCodeKey
            : _DetailsRequestSettingsState._oldCountryCodeKey];
        // The phone shows its code (X-134).
        return (code == null || code.isEmpty || value.isEmpty)
            ? value
            : '$code $value';
      }

      if (i != 0) widgets.add(SizedBox(height: 16.sp));
      widgets.add(CurrentNewValuePair(
        label: _getFieldLabel(fieldName),
        current: side(false),
        next: side(true),
        stacked: stacked,
      ));
    }

    return widgets;
  }

  Widget _buildRequestNoteSection(bool lightMode) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isPhone = ContextExtension(context).isPhone;
    final String note = requestNoteController.text.trim();
    final String reason = _request?.decisionReason.trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.card,
      ),
      child: Padding(
        // D-222: 16 on every side (diagonal cut).
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 21/10/2026 (Moataz): the note is read-only — label + plain
            // text, no input box and no "0 / 500" counter that looked
            // typeable. An empty note reads "No note added." (D-222).
            RichText(
              text: TextSpan(
                text: S.of(context).requestNote,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text, fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 8.sp),
            _readOnlyBox(
              note.isEmpty ? S.of(context).noNoteAdded : note,
              isArabic: isArabic,
              muted: note.isEmpty,
            ),
            if (reason.isNotEmpty) ...<Widget>[
              SizedBox(height: 16.sp),
              // 21/10/2026 (Moataz): the Services module's reason line —
              // status icon + coloured bold label + ": " + the reason, on one
              // line (wraps when long). Red for rejected / cancelled, green
              // for approved.
              _buildReasonLine(reason, isArabic: isArabic),
            ],
            SizedBox(height: 16.sp),

            // D-222: Send Reminder on the LEFT of the status row, the status
            // pill on the right, both 36 high.
            Row(
              children: <Widget>[
                // 21/10/2026 (Moataz): on the phone the action button and
                // the status split the row 50/50, 16 apart.
                if (_canRemind) ...<Widget>[
                  isPhone
                      ? Expanded(
                          child: LayoutBuilder(
                            builder: (_, BoxConstraints c) =>
                                _buildReminderButton(isPhone,
                                    width: c.maxWidth),
                          ),
                        )
                      : _buildReminderButton(isPhone),
                  SizedBox(width: 16.sp),
                ],
                if (_canResend) ...<Widget>[
                  isPhone
                      ? Expanded(
                          child: LayoutBuilder(
                            builder: (_, BoxConstraints c) =>
                                _buildResendButton(isPhone, width: c.maxWidth),
                          ),
                        )
                      : _buildResendButton(isPhone),
                  SizedBox(width: 16.sp),
                ],
                if (isPhone)
                  Expanded(child: _buildStatusButton())
                else ...<Widget>[
                  const Spacer(),
                  // 21/10/2026 (Moataz): as wide as the action button beside
                  // it (Edit And Resend 200 / Send Reminder 185).
                  SizedBox(
                    width: _canResend
                        ? 200.sp
                        : _canRemind
                            ? 185.sp
                            : 150.sp,
                    child: _buildStatusButton(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Cancel, built to match `MyRequestCancelButton` in the services module
  /// (`s6_services_requests/presentation/ui/widgets/my_request_cancel_button.dart`),
  /// so the two "cancel my request" actions look the same wherever the user
  /// meets them.
  ///
  /// CHANGED 8/9/2026 — was `customButtonWithSvg(width: 120.sp, height: 30.sp,
  /// image: '')`, which had two faults the services button had already fixed:
  ///
  ///   • `image: ''` asked for an icon and supplied no asset, so the button
  ///     rendered as a bare label while its services twin shows a minus-circle;
  ///   • 30.sp made it shorter than every other control on this page — the
  ///     status pill in `_buildStatusButton` is 36.sp — so it read as
  ///     undersized beside them. That is the same miss the services button
  ///     records in its own comment, at the same 30.sp.
  ///
  /// The icon goes through `CustomSvgImage` rather than `SvgPicture` directly:
  /// it is what the rest of this file already uses, so no new import.
  Widget _buildCancelButton(bool isMobile) {
    return GestureDetector(
      onTapDown: hapticDown(_cancelRequest, HapticLevel.high),
      onTap: _cancelRequest,
      child: Container(
        // Same pair of widths the services button uses, by form factor.
        width: isMobile ? 135.sp : 150.sp,
        height: 38.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.red,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg',
              width: 20.sp,
              height: 20.sp,
              fit: BoxFit.fill,
              // The asset is drawn red; on a red button it has to be white.
              color: AppColors.white,
            ),
            SizedBox(width: 8.sp),
            Text(
              S.of(context).Cancel,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton({bool fillHeight = false}) {
    // CHANGED 8/9/2026 — the status pill spans the full width of its card
    // instead of a fixed 200.w parked on the trailing edge.
    //
    // The outer `Row(mainAxisAlignment: end)` only existed to push a
    // fixed-width box to one side; with the box full width it had nothing left
    // to align, so it is gone. The INNER Row still centres the icon and label,
    // which is what keeps the pill's contents in the middle now that the box is
    // wider than they are.
    //
    // `double.infinity` is safe here: the caller places this in a Column inside
    // a Padding (_buildRequestNoteSection), so the incoming width is bounded.
    // It would assert if this were ever moved into an unbounded-width parent
    // such as a Row or a horizontal ListView.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.transparent,
        // 21/10/2026 (Moataz): the same 8 corners as Edit And Resend /
        // Send Reminder beside it (was 4).
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _getStatusColor(status)),
      ),
      width: double.infinity,
      // Item 175 (21/10/2026): the SAME height as Send Reminder (the app
      // button, 38.sp) — it was a bare 36. In the summary row it fills the
      // card's height instead.
      height: fillHeight ? null : 38.sp,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvgImage(
            assetPath: _getStatusIcon(status),
            width: 24.w,
            height: 24.h,
            fit: BoxFit.scaleDown,
          ),
          SizedBox(width: 8.w),
          Text(
            _getStatusLabel(status),
            style: StyleText.fontSize16Weight500.copyWith(
              fontSize: 15.sp,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }
}
