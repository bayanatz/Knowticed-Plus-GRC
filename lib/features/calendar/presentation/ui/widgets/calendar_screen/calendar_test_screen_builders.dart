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
    bool isSelected = selectedStatus == status;

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
                    ? StyleText.fontSize16Weight500.copyWith(
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
                ? StyleText.fontSize14Weight500.copyWith(
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
    final List<String> statusTypes = this.statusTypes;

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).home,
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
          child: _isLoading
              ? (isMobile
                  ? SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.7,
                      child: Center(child: CircleProgressMaster()),
                    )
                  : Center(child: CircleProgressMaster()))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 55.h,
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
                      height: 38.h,
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
                            final moduleColor = getModuleColor(englishName);

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
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
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 14.sp,
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

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 38.h,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.sp),
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
                                    child: Text(
                                      DateFormat(
                                        'MMMM yyyy',
                                        _currentLocale?.languageCode,
                                      ).format(displayedMonth),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.sp),
                                  GestureDetector(
                                    onTapDown: hapticDown(
                                        _navigateToPreviousMonth,
                                        HapticLevel.low),
                                    onTap: _navigateToPreviousMonth,
                                    child: SizedBox(
                                      child: CustomSvgImage(
                                        assetPath: isArabic
                                            ? "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg"
                                            : "assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg",
                                        width: 16.w,
                                        height: 16.h,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15.w),
                                  GestureDetector(
                                    onTapDown: hapticDown(
                                        _navigateToNextMonth, HapticLevel.low),
                                    onTap: _navigateToNextMonth,
                                    child: SizedBox(
                                      child: CustomSvgImage(
                                        assetPath: isArabic
                                            ? "assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg"
                                            : "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                                        width: 16.w,
                                        height: 16.h,
                                        fit: BoxFit.fill,
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
                          height: 40.h,
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
                            tabVerticalPadding: isMobile ? 2.sp : null,
                            containerPadding: EdgeInsets.symmetric(
                              horizontal: 8.sp,
                              vertical: 8.sp,
                            ),
                            spacing: 4.sp,
                          ),
                        ),
                      ],
                    ),

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
