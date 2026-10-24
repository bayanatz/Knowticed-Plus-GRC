/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_test_screen_builders.dart
/// Description: UI builder methods of `_CalendarTestScreenState` — split out of `calendar_screen.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/calendar_screen.dart';

// Split from calendar_screen.dart to keep every file under 700 lines.

extension _CalendarTestScreenStateBuilders on _CalendarTestScreenState {
  Widget _statusChip(String count, String status, BuildContext context) {
    // 23/10/2026: compared by the English name. The screen starts on 'All', the
    // Arabic chip is 'الكل', so a plain == never matched in Arabic and the
    // All counter was never yellow.
    bool isSelected =
        _getEnglishStatusName(selectedStatus) == _getEnglishStatusName(status);

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        rebuild(() {
          selectedStatus = status;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: context.isPhone ? 35.sp : 45.sp,
            height: context.isPhone ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: context.isPhone
                    // 22/10/2026 — Owner (phone): count chips match Notifications — box 35, number 14/400, label 14/600.
                    ? StyleText.fontSize14Weight400.copyWith(
                        color: isSelected
                            ? AppColors.textButton
                            : AppColors.secondaryText,
                      )
                    : StyleText.fontSize20Weight500.copyWith(
                        color: isSelected
                            ? AppColors.textButton
                            : AppColors.secondaryText,
                      ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            status,
            // REVERTED 21/9/2026 — Settings bug report p.8 ("why the selected
            // disappear?"). The 13/9/2026 change used `AppColors.textButton`
            // here to match the count box, but that colour is for text ON a
            // primary (yellow) fill. This label sits beside the box, on the
            // page background, so in dark mode the selected label was drawn
            // dark-on-dark and vanished. Selected = full-strength text.
            style: context.isPhone
                ? StyleText.fontSize14Weight600.copyWith(
                    color:
                        isSelected ? AppColors.text : AppColors.secondaryText,
                  )
                : StyleText.fontSize16Weight600.copyWith(
                    color:
                        isSelected ? AppColors.text : AppColors.secondaryText,
                  ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final statusCounts = getStatusCounts();
    final totalEvents = eventDetails.length;
    final isArabic = _currentLocale?.languageCode == 'ar';

    // Same test `SideFrameMasterServices` uses to pick its own branch. It
    // matters here because that branch decides whether this page is handed a
    // bounded height — see the note on the view switch at the end of this
    // method.
    final bool isMobile = kpIsPhoneLayout(context);

    // FIXED 7/10/2026: this used to be a local copy of the [statusTypes]
    // getter WITHOUT 'Frequency', shadowing it — so the recurring To-Do
    // entries (statusCode 'Frequency') had no status chip and showed only
    // under "All". The getter is the single list now.
    // 22/10/2026 (Moataz): a chip with no events is not shown until it has
    // some (Renewal, Billing Cycles, ...). "All" always stays, and "SLA" is
    // always shown on purpose — the owner wants to see it even when empty.
    final String allLabel = isArabic ? 'الكل' : 'All';
    final List<String> statusTypes = this
        .statusTypes
        .where((status) =>
            status == allLabel ||
            status == 'SLA' ||
            (statusCounts[status] ?? 0) > 0 ||
            _getEnglishStatusName(status) ==
                _getEnglishStatusName(selectedStatus))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          // Owner 21/10/2026 13:40: the title keeps the frame's own inset,
          // the same as every other module (no page-specific number).
          titleText: S.of(context).home,
          // Owner item 219 (21/10/2026): the status counters and the module
          // chips are PINNED above the scrolling content, tablet and phone.
          pinnedTop: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 22/10/2026 (Moataz: the gaps between the filter rows are not
              // equal): each row is exactly as tall as its chips, so the three
              // gaps (status → modules → month bar) are all the same 16. The
              // rows were 55 / 38 high around 35 / 28 chips and added 20 and 10
              // of invisible space.
              SizedBox(
                height: context.isPhone ? 35.sp : 45.sp,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statusTypes.map((status) {
                      final count = status == (isArabic ? 'الكل' : 'All')
                          ? _toArabicNumber(totalEvents)
                          : _toArabicNumber(statusCounts[status] ?? 0);

                      return _statusChip(count, status, context);
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 28.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: getUniqueModulesWithMapping().map((
                      moduleMap,
                    ) {
                      final displayName = moduleMap['display']!;
                      final englishName = moduleMap['english']!;

                      final isSelected = selectedModule == displayName ||
                          selectedModule == englishName;
                      // Owner item 210 (21/10/2026): "All" is not a
                      // module and a chosen filter never gets a yellow
                      // fill (X-41) — it takes the grey button colour.
                      // Owner 21/10/2026 14:22: "All" takes the BRAND colour (follows
                      // the branding); Settings is grey; the other modules
                      // keep their own colour.
                      final bool isAll = englishName == 'All';
                      final Color moduleColor = isAll
                          ? AppColors.primary
                          : getModuleColor(englishName);

                      return Padding(
                        // 23/10/2026 (Moataz, Arabic): the gap was a PHYSICAL
                        // right, so in right-to-left it sat on the outer edge
                        // and the chip row ended 8 short of the counters and
                        // the month bar. `end` follows the reading direction.
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticController
                                  .low(); // list row: on the tap (X-117)
                              rebuild(() {
                                selectedModule = displayName;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              height: 28.h,
                              decoration: BoxDecoration(
                                color: moduleColor,
                                borderRadius: BorderRadius.circular(4.r),
                                // ADDED 13/9/2026 — selection was signalled by
                                // the LABEL going bold, which reflows the chip
                                // (bold is wider), so picking a filter nudged
                                // every chip after it sideways. The border is
                                // always present and always the same width; it
                                // only changes colour, so nothing moves.
                                //
                                // Unselected it is the chip's own fill, so it
                                // is invisible and the chip looks exactly as
                                // it does today. Selected it is
                                // AppColors.secondaryText, which reads against
                                // every colour in CalendarModulePalette.
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.secondaryText
                                      : moduleColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  displayName,
                                  // 22/10/2026 (Moataz: "the buttons are
                                  // bigger than the first row"): a bare
                                  // TextStyle skips the app font, so these
                                  // drew in the system font and looked bigger
                                  // than the status labels. Same shared 14 as
                                  // the row above; the weight no longer changes
                                  // with selection (the border shows it).
                                  style: StyleText.fontSize14Weight500.copyWith(
                                    color: isAll
                                        ? AppTheme.readableOn(AppColors.primary)
                                        : AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).calendar,
          // FIXED 12/9/2026 — the spinner sat at the TOP of the page while
          // the calendar loaded, instead of in the middle of it.
          //
          // `Center` only centres inside the space it is given, and on mobile
          // `SideFrameMasterServices` puts its child in a
          // `SingleChildScrollView` (see the note on the view switch below).
          // That hands the child an infinite height, so the Center shrink-
          // wrapped to the spinner and landed wherever the content started —
          // the top. Nothing was wrong with the Center; it simply had no
          // height to centre within.
          //
          // The bounded box is what gives it one. 70% of the screen is very
          // close to the frame's actual scroll viewport once its fixed
          // breadcrumb header and the bottom nav bar are taken out, so the
          // spinner reads as centred without this file having to measure a
          // viewport it cannot see from in here.
          //
          // Tablet and desktop get a bounded height from the frame already,
          // so they keep the plain Center. The Column wrapper is gone either
          // way — one child, and `Center` was already doing its job.
          //
          // 22/10/2026 — Owner (phone): "why it's not centered in the page?"
          // The 70% box starts BELOW the title and the filter chips, so its
          // centre sat about two thirds down the screen. The phone now uses
          // [_ScreenCentredLoader], which puts the spinner on the centre of
          // the SCREEN.
          child: _isLoading
              ? (isMobile
                  ? const _ScreenCentredLoader()
                  : Center(child: CircleProgressMaster()))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

// Owner 21/10/2026 13:58: the month box and the Day / Month toggle
                    // share ONE height (stretched in an IntrinsicHeight row) —
                    // the same rule as the Home calendar header.
                    IntrinsicHeight(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Padding(
                              // Owner 22/10/2026 11:10: the space after the
                              // last arrow = the space above / below the
                              // arrows, measured to the drawn chevron (the
                              // 24-unit SVG has 4.375 blank above the stroke
                              // and 8.375 beside it). Box height = the 40.h
                              // toggle, arrow 20.r.
                              padding: EdgeInsetsDirectional.only(
                                start: 15.sp,
                                end: ((ButtonSizing.height - 20.r) / 2 -
                                        20.r * 4 / 24)
                                    .clamp(0, double.infinity)
                                    .toDouble(),
                              ),
                              // FIXED 12/9/2026 — "RenderFlex overflowed by 114
                              // pixels on the right".
                              //
                              // The month name was a bare `Text` — no flex, no
                              // ellipsis — so this Row's minimum width was the full
                              // "September 2026" plus both chevrons, whatever the
                              // Expanded above could actually spare. On a phone that
                              // share is about 200pt and the content wanted ~315.
                              //
                              // `Expanded` on the Text does the job the `Spacer` was
                              // doing (push the chevrons to the trailing edge) AND
                              // makes the label the part that yields, so a long
                              // month in either language ellipsises rather than
                              // pushing the arrows off-screen. `mainAxisSize.min`
                              // went with the Spacer — it never applied, since a
                              // flex child makes the Row take all the width anyway.
                              child: Row(
                                children: [
                                  Expanded(
                                    // Owner 21/10/2026 13:37: the month name
                                    // shrinks to fit, never "…" (C-01).
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        DateFormat(
                                          'MMMM yyyy',
                                          _currentLocale?.languageCode,
                                        ).format(displayedMonth),
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 13:58: half the gap between the arrows.
                                  SizedBox(width: 4.sp),
                                  GestureDetector(
                                    onTapDown: hapticDown(
                                        _navigateToPreviousMonth,
                                        HapticLevel.low),
                                    onTap: _navigateToPreviousMonth,
                                    child: SizedBox(
                                      child: Transform.flip(
                                        // Owner item 211 (21/10/2026): ONE
                                        // chevron glyph, mirrored.
                                        flipX: !isArabic,
                                        child: CustomSvgImage(
                                          assetPath:
                                              "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                                          // Owner item 213 (21/10/2026): bigger arrows on the page header.
                                          width: 20.r,
                                          height: 20.r,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Owner 22/10/2026 11:10: half the visible
                                  // gap between the chevrons. Visible gap was
                                  // 15.w + 2 × 8.375/24 of the arrow (the SVG's
                                  // side blank); this is that halved, minus
                                  // the same blank.
                                  SizedBox(
                                    width: (15.w / 2 - 20.r * 8.375 / 24)
                                        .clamp(0, double.infinity)
                                        .toDouble(),
                                  ),
                                  GestureDetector(
                                    onTapDown: hapticDown(
                                        _navigateToNextMonth, HapticLevel.low),
                                    onTap: _navigateToNextMonth,
                                    child: SizedBox(
                                      child: Transform.flip(
                                        flipX: isArabic,
                                        child: CustomSvgImage(
                                          assetPath:
                                              "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                                          // Owner item 213 (21/10/2026): bigger arrows on the page header.
                                          width: 20.r,
                                          height: 20.r,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: isMobile ? 8.sp : 15.sp),

                        // CHANGED 24/8/2026: was the bespoke `CalendarViewToggle`.
                        // The shared `CustomSegmentedTabs` does the same job and is
                        // what the rest of the app uses, so the switch here now
                        // matches every other tab strip in the product.
                        //
                        // Index 0 is Day and index 1 is Month, in that order. The
                        // Row inside CustomSegmentedTabs is direction-aware, so in
                        // Arabic the framework mirrors it — no manual RTL flip like
                        // the old widget carried.
                        SizedBox(
                          // 240 is a desktop measurement: on a 402pt phone it is
                          // ~257pt of the ~372 this row has, leaving the month label
                          // beside it too little to render. "Day" and "Month" are
                          // short enough to stay legible at 150.
                          width: isMobile ? 150.w : 240.w,
                          // R-27: the standard button height, not a share of the
                          // screen height — 40.h made the switch (and the month
                          // box that stretches to it) far taller on the iPad in
                          // landscape than on the Mac.
                          height: ButtonSizing.height,
                          child: CustomSegmentedTabs(
                            textStyle: StyleText.fontSize14Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            tabs: [
                              isArabic ? 'يوم' : 'Day',
                              isArabic ? 'شهر' : 'Month',
                            ],
                            selectedIndex:
                                currentViewMode == CalendarViewMode.month
                                    ? 1
                                    : 0,
                            onTabSelected: (index) {
                              rebuild(() {
                                currentViewMode = index == 1
                                    ? CalendarViewMode.month
                                    : CalendarViewMode.day;
                              });
                            },
                            equalWidth: true,
                            containerColor: AppColors.card,
                            unselectedColor: AppColors.card,
                            selectedColor: AppColors.primary,
                            selectedTextColor: AppColors.textButton,
                            unselectedTextColor: AppColors.secondaryText,
                            borderRadius: 8.r,
                            // ADDED 13/9/2026 — "Day" / "Month" rendered smaller
                            // than the 14.sp asked for above, on mobile only.
                            //
                            // CustomSegmentedTabs wraps each label in a FittedBox,
                            // which SHRINKS the text to whatever the tab box allows.
                            // The binding constraint was vertical, not horizontal:
                            // 40.h minus the container padding top and bottom minus
                            // the tab's own default 6.sp pair left about 12pt of
                            // line box, and 14.sp needs 14 — so the FittedBox scaled
                            // it down by roughly 15%.
                            //
                            // Trimming the TAB's own padding on mobile gives the
                            // line the room it needs and the FittedBox then leaves
                            // the size alone. Null on desktop keeps the widget's
                            // 6.sp default; containerPadding below is untouched.
                            // 21/10/2026 (Moataz): on the Mac the labels were cut at
                            // the top — the same 40.h box with the default 6.sp
                            // tab padding leaves ~12pt for a 14sp line there too,
                            // so the compact padding applies on every device.
                            tabVerticalPadding: 2.sp,
                            // 22/10/2026 — owner: box 8, gap 4, pill 4.
                            containerPadding: EdgeInsets.all(4.r),
                            spacing: 4.sp,
                          ),
                        ),
                      ],
                    )),

                    const SizedBox(height: 16),

                    // FIXED 12/9/2026 — "RenderFlex children have non-zero flex
                    // but incoming height constraints are unbounded", thrown the
                    // moment this screen opened on a phone.
                    //
                    // `SideFrameMasterServices` lays its child out differently by
                    // form factor: on tablet and desktop the child sits in a
                    // bounded box, but its MOBILE branch puts it inside a
                    // `SingleChildScrollView` (50-custom_side_frame_master.dart),
                    // which hands its child an INFINITE height. `Expanded` means
                    // "fill the space left over", and there is no such thing inside
                    // a scroll view — so the whole page failed to lay out, which is
                    // why the second assertion ("RenderBox was not laid out") came
                    // straight after.
                    //
                    // The two layouts below are therefore genuinely different, not
                    // just narrower: the desktop pair fill a bounded parent, the
                    // mobile pair size themselves so the frame's scroll view has
                    // something finite to scroll.
                    if (isMobile)
                      currentViewMode == CalendarViewMode.month
                          ? _buildMonthViewMobile()
                          : _buildDayViewMobile()
                    else
                      Expanded(
                        child: currentViewMode == CalendarViewMode.month
                            ? _buildMonthView()
                            : _buildDayView(),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// The standard loader on the centre of the SCREEN, wherever this widget
/// starts (phone: the page content begins under the title and the filter
/// chips, inside a scroll view, so a plain `Center` has no height to use).
/// After the first frame it reads its own position and pads itself so the
/// spinner lands on the screen's middle.
class _ScreenCentredLoader extends StatefulWidget {
  const _ScreenCentredLoader();

  @override
  State<_ScreenCentredLoader> createState() => _ScreenCentredLoaderState();
}

class _ScreenCentredLoaderState extends State<_ScreenCentredLoader> {
  double? _top;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final double startY = box.localToGlobal(Offset.zero).dy;
    final double screenCentre = MediaQuery.sizeOf(context).height / 2;
    setState(() => _top = screenCentre - startY);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    // Until measured: invisible, same height, so nothing jumps.
    final double top = _top ?? screenHeight * 0.35;
    // CircleProgressMaster centres itself in its box; a box twice [top] tall
    // puts its middle exactly [top] below where this widget starts.
    return Opacity(
      opacity: _top == null ? 0 : 1,
      child: SizedBox(
        height: (top * 2).clamp(0, screenHeight).toDouble(),
        child: const CircleProgressMaster(),
      ),
    );
  }
}
