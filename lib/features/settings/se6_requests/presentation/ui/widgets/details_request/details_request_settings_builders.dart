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

      // SideFrameMasterServices' breadcrumb on phone: a 15.sp top pad, one
      // line of fontSize24Weight600, and the 20.sp gap it puts above the
      // child.
      final double frameHeader = 15.sp + 34.sp + 20.sp;

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
        _buildHeader(lightMode),
        SizedBox(height: 8.h),

        // 21/9/2026 — review follow-up to report p.13: on tablet/desktop
        // Cancel sits on its own row under the header, aligned under the
        // requested date. Phones keep it in the status row at the bottom (see
        // _buildRequestNoteSection).
        if (_canCancel && !isMobile) ...[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _buildCancelButton(false),
          ),
          SizedBox(height: 8.h),
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
        _buildChangesCard(lightMode: lightMode, isMobile: isMobile),
        SizedBox(height: 16.h),

        _buildRequestNoteSection(lightMode),
        SizedBox(height: 16.h),

        _buildCommentsSection(isMobile),
        SizedBox(height: 16.h),
      ],
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
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drawn once for the whole request, not once per change. Cancel sits
          // at the end of this row rather than beside the status badge at the
          // bottom — it acts on the request as a whole, so it belongs with the
          // request's title.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildSectionHeader(
                  lightMode,
                  _translateSectionTitle(section),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (isMobile)
            ..._buildStackedChanges(lightMode)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildValueColumn(
                    lightMode: lightMode,
                    title: S.of(context).current_details,
                    titleColor: AppColors.blackButton,
                    isNew: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildValueColumn(
                    lightMode: lightMode,
                    title: S.of(context).new_details,
                    titleColor: AppColors.statusApproved,
                    isNew: true,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Phone layout: current/new stacked per field, all still inside one card.
  List<Widget> _buildStackedChanges(bool lightMode) {
    final widgets = <Widget>[];

    for (int i = 0; i < changes.length; i++) {
      final change = changes[i];

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).current_details,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 8.h),
            _buildFieldCell(lightMode: lightMode, change: change, isNew: false),
            SizedBox(height: 12.h),
            Text(
              S.of(context).new_details,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.statusApproved,
              ),
            ),
            SizedBox(height: 8.h),
            _buildFieldCell(lightMode: lightMode, change: change, isNew: true),
          ],
        ),
      );

      if (i != changes.length - 1) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            // Bug report (Settings mobile p.9): at 8% opacity this line was
            // invisible, so two changed fields ran together. Same visible
            // divider as the Social Information card.
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.background,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  /// Function Name: [_buildPhoneFieldCell]
  ///
  /// Purpose: A phone change as the reviewer edits it — a narrow read-only
  ///          country-code box beside a wide number box, under one label.
  ///
  /// Mirrors `_buildPhoneField` on the edit screen (same [_dialCodeWidth], same
  /// label-above-the-row layout), so the request reads the way the employee
  /// filled it in. The `Row` is direction-aware: under an Arabic UI the code
  /// box lands on the right, which is the leading edge there.
  ///
  /// The dial code is NOT put through `_displayValue`: it is a prefix to dial,
  /// not a quantity to read, so it stays in Latin digits like the email does.
  ///
  /// Parameters:
  /// - [fieldName]: The change's field key, used for the label.
  /// - [countryCode]: The dial code for this side of the comparison.
  /// - [number]: The phone number for this side.
  /// - [isNew]: Which side is being drawn; the current side is greyed.
  ///
  /// Returns: [Widget] the label plus the two boxes.
  Widget _buildPhoneFieldCell({
    required String fieldName,
    required String countryCode,
    required String number,
    required bool isNew,
  }) {
    final String label = _getFieldLabel(fieldName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Same style and gap CustomTextField draws its own label with (14.sp,
        // 6.sp below it), so this row's boxes line up with the boxes of every
        // other field in the column.
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 6.sp),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: _dialCodeWidth,
              child: CustomTextField(
                key: ValueKey('$fieldName-code-$isNew-$countryCode'),
                initialValue: countryCode.isEmpty ? '-' : countryCode,
                textDirection: ui.TextDirection.ltr,
                textAlign: TextAlign.center,
                enabled: false,
                fillColor: isNew ? null : AppColors.background,
              ),
            ),
            SizedBox(width: 12.sp),
            // Expanded, not a second fixed width: the number is the long half
            // and takes whatever the column has left.
            Expanded(
              child: _buildValueBox(
                fieldName: fieldName,
                value: number,
                isNew: isNew,
                // The label is drawn once above the row, so neither box
                // repeats it.
                showLabel: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestNoteSection(bool lightMode) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        // Container -> 8.r. The note INPUT inside it keeps 4.r, which is
        // CustomTextField's own default, so it needs nothing passed here.
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.card,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 10.sp, right: 10.sp, bottom: 10.sp),
        child: Column(
          children: [
            CustomTextField(
              hint: S.of(context).requestNote,
              controller: requestNoteController,
              enabled: false,
              label: S.of(context).requestNote,
              maxLines: 3,
              // ADDED 8/9/2026 — the n/500 counter was missing here.
              // CustomTextField only draws one when a limit is asked for
              // (`maxLength`, or `showCharCount` which implies 500); this call
              // passed neither. 500 matches the cap the note is written under
              // on the preview page, so the count reads against the same limit.
              maxLength: 500,
              textDirection:
                  isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            ),
            SizedBox(height: 20.h),

            // CHANGED 21/9/2026 — Settings bug report p.13: the status pill no
            // longer runs the full width with an empty slot at its end; while
            // the request can still be withdrawn, Cancel fills that slot.
            // Tablet/desktop: the status pill is a fixed 150.sp on the trailing
            // edge (Cancel moved to the header). Phone: the pill fills the row
            // and Cancel sits at its end.
            if (ContextExtension(context).isPhone)
              Row(
                children: [
                  Expanded(child: _buildStatusButton()),
                  if (_canCancel) ...[
                    SizedBox(width: 12.w),
                    _buildCancelButton(true),
                  ],
                ],
              )
            else
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SizedBox(width: 150.sp, child: _buildStatusButton()),
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
        height: 36.sp,
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

  Widget _buildStatusButton() {
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
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _getStatusColor(status)),
      ),
      width: double.infinity,
      height: 36,
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
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }
}
