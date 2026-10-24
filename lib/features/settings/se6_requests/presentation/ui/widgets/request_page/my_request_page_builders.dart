/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_page_builders.dart
/// Description: UI builder methods of `_MyRequestPageState` — split out of `request_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/request_page.dart';

// Split from request_page.dart to keep every file under 700 lines.

extension _MyRequestPageStateBuilders on _MyRequestPageState {
  /// 21/10/2026 (Moataz): cards per row — phone 1, iPad portrait 1 (the
  /// pane beside the menu is narrow; 2 cut the titles), iPad landscape 3.
  // Owner 21/10/2026: large screen (macOS / iPad landscape) is exactly 3 per row — a fixed count, never width-based, so a wider window never gives 4+.
  int _requestColumns(BuildContext context, bool isMobile) {
    if (isMobile) return 1;
    return MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 3;
  }

  Widget _buildView(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return !isMobile
        ? SizedBox(
            // No fixed height — this page is rendered inside an Expanded in
            // settings_layout.dart, so it inherits the exact height available.
            // The old 550.h resolved ~6px taller than that space and overflowed.
            // R-10 (21/10/2026): counters + search/sort stay fixed; only the
            // list below scrolls.
            child: Column(
              children: [
                // filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    filterSection(),
                  ],
                ),
                SizedBox(height: 20.h),
                // D-221 (21/10/2026): the search bar and the Sort / Filter
                // button sit above the list on every device.
                Row(
                  children: [
                    AppSearchTextField(
                      controller: searchController,
                      onChanged: (val) {
                        // Search is handled by listener
                      },
                    ),
                    SizedBox(width: ButtonSizing.toolbarGap(context)),
                    CustomSortButton<RequestDateSort>(
                      value: _sortOrder,
                      items: RequestDateSort.values,
                      labelBuilder: (RequestDateSort order) =>
                          _sortLabel(context, order),
                      title: S.of(context).sort,
                      showTitle: MediaQuery.of(context).orientation ==
                          Orientation.landscape,
                      onChanged: (RequestDateSort? order) {
                        _sortOrder = order;
                        _filterRequests();
                      },
                    )
                  ],
                ),
// 21/10/2026 (Moataz): no Load / Remove Demo Data buttons.
                SizedBox(height: 20.h),

                // While the first load is still in flight neither the grid nor
                // the "no requests" animation is the truth yet — an empty list at
                // that point only means the fetch has not returned. Show the
                // spinner until it does, then decide between empty and grid.
                Expanded(
                  child: SingleChildScrollView(
                    child: isLoading
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 150.h),
                              const CircleProgressMaster(),
                            ],
                          )
                        : filteredRequests.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 150.h),
                                  Lottie.asset(
                                      "assets/lottie_assets/main_lottie_assets/lot_empty_state.json",
                                      width: 250.w,
                                      height: 250.h,
                                      repeat: true),
                                ],
                              )
                            : SizedBox(
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  // 21/10/2026 (Moataz): the list does not scroll by itself —
                                  // only the area under the fixed header scrolls (R-10).
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    // D-221 (21/10/2026): ONE per row on the phone AND on iPad
                                    // portrait, full width; 3 per row on landscape (_requestColumns).
                                    crossAxisCount:
                                        _requestColumns(context, isMobile),
                                    mainAxisSpacing: 16.sp, // R-4
                                    crossAxisSpacing: 16.sp, // R-4
                                    // 160.sp overflowed by ~4px once a request title wrapped to
                                    // its second line.
                                    // R-11 (21/10/2026): measured — 16 inside on every side
                                    // (was 145: the bottom had 28 px extra).
                                    mainAxisExtent: 131.5.sp,
                                  ),
                                  itemCount: filteredRequests.length,
                                  itemBuilder: (context, index) {
                                    final request = filteredRequests[index];
                                    final status =
                                        request['status'] ?? 'pending';
                                    final statusColor = _getStatusColor(status);

                                    return GestureDetector(
                                        onTap: () async {
                                          await navigateTo(
                                            context,
                                            DetailsRequestSettings(
                                              requestId: request[
                                                  'id'], // ✅ Add requestId
                                              requestData: {
                                                'employeeId':
                                                    request['employeeId'],
                                                'employeeEmail': request[
                                                    'employeeEmail'], // ✅ Add
                                                'status': request['status'],
                                                'requestDate': request[
                                                    'dateRequested'], // ✅ Fix field name
                                                'requestNote':
                                                    request['requestNote'],
                                                'section':
                                                    request['section'], // ✅ Add
                                                'changes': request[
                                                    'changes'], // full change set
                                                'whatChanged': request[
                                                    'whatChanged'], // ✅ Add
                                                'oldValue': request[
                                                    'oldValue'], // ✅ Add
                                                'newValue': request[
                                                    'newValue'], // ✅ Add
                                              },
                                            ),
                                          );

                                          if (!mounted) return;
                                          await _fetchRequests();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              color: lightMode
                                                  ? AppColors.white
                                                  : AppColors.chatBackground),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.sp),
                                            // 21/10/2026 (Moataz): the card never
                                            // scrolls inside itself.
                                            child: SingleChildScrollView(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              child: Column(
                                                // Item 168 (21/10/2026): the card's
                                                // rows start at the LEFT edge.
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                          width: 50.sp,
                                                          height: 50.sp,
                                                          decoration:
                                                              BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(4
                                                                              .r),
                                                                  // D-263 (Moataz 21/10/2026 08:34): dark tile, white icon.
                                                                  color: AppTheme.isDark
                                                                      ? AppColors
                                                                          .header
                                                                      : AppColors
                                                                          .background),
                                                          child: Center(
                                                            child:
                                                                CustomSvgImage(
                                                              assetPath:
                                                                  _sectionIconPath(
                                                                      request[
                                                                          'section']),
                                                              width: 24.sp,
                                                              height: 24.sp,
                                                              fit: BoxFit
                                                                  .contain,
                                                              color: AppTheme
                                                                      .isDark
                                                                  ? AppColors
                                                                      .colorWhite
                                                                  : AppColors
                                                                      .infoIcon,
                                                            ),
                                                          )),
                                                      SizedBox(width: 8.sp),
                                                      Expanded(
                                                        child: Text(
                                                          // ✅ FIXED: Translate title based on locale
                                                          _translateTitle(
                                                              request['title'] ??
                                                                  'Request'),
                                                          style: StyleText
                                                              .fontSize14Weight500
                                                              .copyWith(
                                                                  color: lightMode
                                                                      ? AppColors
                                                                          .blackButton
                                                                      : AppColors
                                                                          .white),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                        ),
                                                      )
                                                    ],
                                                  ),

                                                  // 21/10/2026 (Moataz): the same 8 above the date row as
                                                  // between date and status.
                                                  SizedBox(height: 8.sp),
                                                  // Date Requested
                                                  // Wrap, not Row (21/10/2026): the value drops under the label
                                                  // when the card is too narrow (iPad portrait, 2 per row)
                                                  // instead of overflowing the card by 71 px.
                                                  Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      // Bug report (Settings mobile p.7):
                                                      // the date and status icons used
                                                      // different boxes (14.w×14.h vs
                                                      // 12.w×12.h, stretched), so they
                                                      // did not line up. One square box.
                                                      CustomSvgImage(
                                                        assetPath:
                                                            "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                                                        // 21/10/2026 (Moataz): the calendar is drawn inside a
                                                        // 24 box with a margin, the status icon edge to edge —
                                                        // 16 vs 13 makes both the same visible size, and both
                                                        // take the label colour.
                                                        width: 16.sp,
                                                        height: 16.sp,
                                                        fit: BoxFit.contain,
                                                        color: lightMode
                                                            ? AppColors
                                                                .secondaryText
                                                            : AppColors.grey,
                                                      ),
                                                      SizedBox(width: 4.sp),
                                                      Text(
                                                        "${S.of(context).dateRequested}: ",
                                                        style: StyleText
                                                            .fontSize12Weight400
                                                            .copyWith(
                                                                color: lightMode
                                                                    ? AppColors
                                                                        .secondaryText
                                                                    : AppColors
                                                                        .grey),
                                                      ),
                                                      Text(
                                                        _formatDate(request[
                                                            'dateRequested']),
                                                        style: StyleText
                                                            .fontSize12Weight400
                                                            .copyWith(
                                                                color: lightMode
                                                                    ? AppColors
                                                                        .blackButton
                                                                    : AppColors
                                                                        .white),
                                                      ),
                                                    ],
                                                  ),
                                                  // 21/10/2026 (Moataz): 8 between date and status — with
                                                  // 12 the status line ("Pending") was cut at the bottom.
                                                  SizedBox(height: 8.sp),
                                                  // Status
                                                  Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      // In the calendar's 16 box, so both labels start on one line.
                                                      SizedBox(
                                                        width: 16.sp,
                                                        height: 16.sp,
                                                        child: Center(
                                                            child:
                                                                CustomSvgImage(
                                                          assetPath:
                                                              "assets/icons_assets/main_icons_assets/ic_status.svg",
                                                          // Measured 21/10/2026: at 13 it drew 39×33 px against the
                                                          // calendar's 29×29; sized by measuring the drawn pixels.
                                                          width: 12.sp,
                                                          height: 12.sp,
                                                          fit: BoxFit.contain,
                                                          color: lightMode
                                                              ? AppColors
                                                                  .secondaryText
                                                              : AppColors.grey,
                                                        )),
                                                      ),
                                                      SizedBox(width: 4.sp),
                                                      Text(
                                                        "${S.of(context).status}: ",
                                                        style: StyleText
                                                            .fontSize12Weight400
                                                            .copyWith(
                                                                color: lightMode
                                                                    ? AppColors
                                                                        .secondaryText
                                                                    : AppColors
                                                                        .grey),
                                                      ),
                                                      Text(
                                                        _getStatusLabel(status),
                                                        style: StyleText
                                                            .fontSize12Weight400
                                                            .copyWith(
                                                                color:
                                                                    statusColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ));
                                  },
                                ),
                              ),
                  ),
                ),
              ],
            ),
          )
        : SideFrameMasterServices(
            titleText: S.of(context).settings,
            secondTitle: S.of(context).requests,
            onFirstTap: () {
              Navigator.pop(context);
            },
            onSecondTap: () {
              Navigator.pop(context);
            },
            // R-10: counters + search/sort fixed, the list scrolls. Bounded
            // so the Expanded below works inside the phone frame.
            child: SideFrameBoundedBody(
              child: Column(
                children: [
                  // filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      filterSection(),
                    ],
                  ),
                  //space
                  SizedBox(height: 20.h),
                  // search and sort
                  Row(
                    children: [
                      AppSearchTextField(
                        controller: searchController,
                        onChanged: (val) {
                          // Search is handled by listener
                        },
                      ),
                      SizedBox(width: ButtonSizing.toolbarGap(context)),
                      // WAS a decorative Container: an icon, the word "Sort",
                      // and no gesture detector or menu anywhere — the control
                      // looked live but sorted nothing. CustomSortButton is the
                      // app's real sort control; it owns the dropdown, paints
                      // itself primary while a sort is active, and toggles the
                      // active option off when it is tapped again.
                      CustomSortButton<RequestDateSort>(
                        value: _sortOrder,
                        items: RequestDateSort.values,
                        labelBuilder: (RequestDateSort order) =>
                            _sortLabel(context, order),
                        title: S.of(context).sort,
                        // Icon-only in the 38.w square on phone, icon + label on
                        // wider screens — the same split the old Container made.
                        showTitle: !isMobile,
                        onChanged: (RequestDateSort? order) {
                          _sortOrder = order;
                          // _filterRequests calls setState itself.
                          _filterRequests();
                        },
                      )
                    ],
                  ),
// 21/10/2026 (Moataz): no Load / Remove Demo Data buttons.
                  SizedBox(height: 20.h),

                  // Same as the wide layout: spinner first, empty state only once
                  // the fetch has actually finished.
                  Expanded(
                    child: SingleChildScrollView(
                      child: isLoading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 150.h),
                                const CircleProgressMaster(),
                              ],
                            )
                          : filteredRequests.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 150.h),
                                    Lottie.asset(
                                        "assets/lottie_assets/main_lottie_assets/lot_empty_state.json",
                                        width: 250.w,
                                        height: 250.h,
                                        repeat: true),
                                  ],
                                )
                              : SizedBox(
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    // 21/10/2026 (Moataz): the list does not scroll by itself —
                                    // only the area under the fixed header scrolls (R-10).
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      // D-221 (21/10/2026): ONE per row on the phone AND on iPad
                                      // portrait, full width; 3 per row on landscape (_requestColumns).
                                      crossAxisCount:
                                          _requestColumns(context, isMobile),
                                      mainAxisSpacing: 16.sp,
                                      crossAxisSpacing: 16.sp,
                                      // Item 184 (21/10/2026): 139 overflowed by 1 px.
                                      // R-11: measured, same inside space on every side (was 145).
                                      mainAxisExtent: 132.sp,
                                    ),
                                    itemCount: filteredRequests.length,
                                    itemBuilder: (context, index) {
                                      final request = filteredRequests[index];
                                      final status =
                                          request['status'] ?? 'pending';
                                      final statusColor =
                                          _getStatusColor(status);

                                      return GestureDetector(
                                          onTap: () async {
// ✅ Check status here

                                            await navigateTo(
                                              context,
                                              DetailsRequestSettings(
                                                requestId: request['id'],
                                                requestData: {
                                                  'employeeId':
                                                      request['employeeId'],
                                                  'employeeEmail':
                                                      request['employeeEmail'],
                                                  'status': request[
                                                      'status'], // ✅ Make sure this is passed
                                                  'requestDate':
                                                      request['dateRequested'],
                                                  'requestNote':
                                                      request['requestNote'],
                                                  'section': request['section'],
                                                  'changes': request[
                                                      'changes'], // full change set
                                                  'whatChanged':
                                                      request['whatChanged'],
                                                  'oldValue':
                                                      request['oldValue'],
                                                  'newValue':
                                                      request['newValue'],
                                                },
                                              ),
                                            );

                                            if (!mounted) return;
                                            await _fetchRequests();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                color: AppColors.card),
                                            child: Padding(
                                              padding: EdgeInsets.all(16.sp),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                          // Square (was 50.w × 50.h).
                                                          width: 50.sp,
                                                          height: 50.sp,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.r),
                                                            // D-263 (Moataz 21/10/2026 08:34): dark tile, white icon.
                                                            color: AppTheme.isDark
                                                                ? AppColors
                                                                    .header
                                                                : AppColors
                                                                    .background,
                                                          ),
                                                          child: Center(
                                                            child: CustomSvgImage(
                                                                assetPath: _sectionIconPath(
                                                                    request[
                                                                        'section']),
                                                                width: 24.sp,
                                                                height: 24.sp,
                                                                fit: BoxFit
                                                                    .contain,
                                                                color: AppTheme
                                                                        .isDark
                                                                    ? AppColors
                                                                        .colorWhite
                                                                    : AppColors
                                                                        .infoIcon),
                                                          )),
                                                      SizedBox(width: 8.sp),
                                                      Expanded(
                                                        child: Text(
                                                          // ✅ FIXED: Translate title based on locale
                                                          _translateTitle(
                                                              request['title'] ??
                                                                  'Request'),
                                                          style: StyleText
                                                              .fontSize14Weight500
                                                              .copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .text),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                        ),
                                                      )
                                                    ],
                                                  ),

                                                  // 21/10/2026 (Moataz): the same 8 above the date row as
                                                  // between date and status.
                                                  SizedBox(height: 8.sp),
                                                  // Date Requested
                                                  Row(
                                                    children: [
                                                      CustomSvgImage(
                                                        assetPath:
                                                            "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                                                        width: 16.sp,
                                                        height: 16.sp,
                                                        fit: BoxFit.contain,
                                                        color: lightMode
                                                            ? AppColors
                                                                .secondaryText
                                                            : AppColors.grey,
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Text(
                                                        "${S.of(context).dateRequested}: ",
                                                        style: StyleText
                                                            .fontSize12Weight400
                                                            .copyWith(
                                                                color: AppColors
                                                                    .secondaryText),
                                                      ),
                                                      Text(
                                                        _formatDate(request[
                                                            'dateRequested']),
                                                        style: StyleText
                                                            .fontSize12Weight400
                                                            .copyWith(
                                                                color: AppColors
                                                                    .text),
                                                      ),
                                                    ],
                                                  ),
                                                  // 21/10/2026 (Moataz): 8 between date and status — with
                                                  // 12 the status line ("Pending") was cut at the bottom.
                                                  SizedBox(height: 8.sp),
                                                  // Status
                                                  Row(
                                                    children: [
                                                      // In the calendar's 16 box, so both labels start on one line.
                                                      SizedBox(
                                                        width: 16.sp,
                                                        height: 16.sp,
                                                        child: Center(
                                                            child:
                                                                CustomSvgImage(
                                                          assetPath:
                                                              "assets/icons_assets/main_icons_assets/ic_status.svg",
                                                          // Measured 21/10/2026: at 13 it drew 39×33 px against the
                                                          // calendar's 29×29; sized by measuring the drawn pixels.
                                                          width: 12.sp,
                                                          height: 12.sp,
                                                          fit: BoxFit.contain,
                                                          color: lightMode
                                                              ? AppColors
                                                                  .secondaryText
                                                              : AppColors.grey,
                                                        )),
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Text(
                                                        "${S.of(context).status}: ",
                                                        style: StyleText
                                                            .fontSize12Weight400
                                                            .copyWith(
                                                                color: AppColors
                                                                    .secondaryText),
                                                      ),
                                                      Text(
                                                        _getStatusLabel(status),
                                                        style: StyleText
                                                            .fontSize12Weight400
                                                            .copyWith(
                                                                color:
                                                                    statusColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget filterSection() {
    final s = S.of(context);

    return Expanded(
      // D-266 (Moataz, 21/10/2026 08:34): the counters are ONE row that
      // scrolls sideways when the panel is narrow — never wrapped.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _statusChip("$totalRequests", s.all,
                isSelected: selectStatus == _MyRequestPageState.kAll,
                onTap: () {
              rebuild(() {
                selectStatus = _MyRequestPageState.kAll;
                _filterRequests();
              });
            },
                labelColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.secondaryText
                    : AppColors.grey),
            _statusChip("$approvedCount", s.Approved,
                isSelected: selectStatus == _MyRequestPageState.kApproved,
                onTap: () {
              rebuild(() {
                selectStatus = _MyRequestPageState.kApproved;
                _filterRequests();
              });
            }, labelColor: AppColors.lightGreen),
            _statusChip("$pendingCount", s.pending,
                isSelected: selectStatus == _MyRequestPageState.kPending,
                onTap: () {
              rebuild(() {
                selectStatus = _MyRequestPageState.kPending;
                _filterRequests();
              });
            }, labelColor: AppColors.statusPending),
            _statusChip("$rejectedCount", s.rejected,
                isSelected: selectStatus == _MyRequestPageState.kRejected,
                onTap: () {
              rebuild(() {
                selectStatus = _MyRequestPageState.kRejected;
                _filterRequests();
              });
            }, labelColor: AppColors.red),
            _statusChip("$cancelledCount", s.canceled,
                isSelected: selectStatus == _MyRequestPageState.kCancelled,
                onTap: () {
              rebuild(() {
                selectStatus = _MyRequestPageState.kCancelled;
                _filterRequests();
              });
            }, labelColor: AppColors.secondaryText),
          ],
        ),
      ),
    );
  }
}
