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
  Widget _buildView(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return !isMobile
        ? SizedBox(
            // No fixed height — this page is rendered inside an Expanded in
            // settings_layout.dart, so it inherits the exact height available.
            // The old 550.h resolved ~6px taller than that space and overflowed.
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      filterSection(),
                    ],
                  ),
                  // //space
                  // SizedBox(height: 20.h),
                  // // search and sort
                  // Row(
                  //   children: [
                  //     AppSearchTextField(
                  //       controller: searchController,
                  //       onChanged: (val) {
                  //         // Search is handled by listener
                  //       },
                  //     ),
                  //   ],
                  // ),

                  SizedBox(height: 20.h),

                  // While the first load is still in flight neither the grid nor
                  // the "no requests" animation is the truth yet — an empty list at
                  // that point only means the fetch has not returned. Show the
                  // spinner until it does, then decide between empty and grid.
                  isLoading
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
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isMobile
                                      ? 1
                                      : !ContextExtension(context)
                                              .isTabletLandscape
                                          ? 2
                                          : 2,
                                  mainAxisSpacing: 10.sp,
                                  crossAxisSpacing: 10.sp,
                                  // 160.sp overflowed by ~4px once a request title wrapped to
                                  // its second line.
                                  mainAxisExtent: 145.sp,
                                ),
                                itemCount: filteredRequests.length,
                                itemBuilder: (context, index) {
                                  final request = filteredRequests[index];
                                  final status = request['status'] ?? 'pending';
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
                                              'oldValue':
                                                  request['oldValue'], // ✅ Add
                                              'newValue':
                                                  request['newValue'], // ✅ Add
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
                                          padding: EdgeInsets.all(15.sp),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 50.sp,
                                                        height: 50.sp,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.r),
                                                            color: lightMode
                                                                ? AppColors
                                                                    .background
                                                                : AppColors
                                                                    .background),
                                                        child: Center(
                                                          child: CustomSvgImage(
                                                            assetPath:
                                                                _sectionIconPath(
                                                                    request[
                                                                        'section']),
                                                            width: 28.sp,
                                                            height: 28.sp,
                                                            fit: BoxFit.fill,
                                                            color: lightMode
                                                                ? AppColors
                                                                    .blackButton
                                                                : AppColors
                                                                    .white,
                                                          ),
                                                        )),
                                                    SizedBox(width: 5.w),
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

                                                // space
                                                SizedBox(height: 12.h),
                                                // Date Requested
                                                Row(
                                                  children: [
                                                    // Bug report (Settings mobile p.7):
                                                    // the date and status icons used
                                                    // different boxes (14.w×14.h vs
                                                    // 12.w×12.h, stretched), so they
                                                    // did not line up. One square box.
                                                    CustomSvgImage(
                                                      assetPath:
                                                          "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                                                      width: 14.sp,
                                                      height: 14.sp,
                                                      fit: BoxFit.contain,
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
                                                // space
                                                SizedBox(height: 12.h),
                                                // Status
                                                Row(
                                                  children: [
                                                    CustomSvgImage(
                                                      assetPath:
                                                          "assets/icons_assets/main_icons_assets/ic_status.svg",
                                                      width: 14.sp,
                                                      height: 14.sp,
                                                      fit: BoxFit.contain,
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
                ],
              ),
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
                    SizedBox(width: 15.w),
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

                SizedBox(height: 20.h),

                // Same as the wide layout: spinner first, empty state only once
                // the fetch has actually finished.
                isLoading
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
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile
                                    ? 1
                                    : !ContextExtension(context)
                                            .isTabletLandscape
                                        ? 2
                                        : 2,
                                mainAxisSpacing: 15.sp,
                                crossAxisSpacing: 15.sp,
                                mainAxisExtent: 139.sp,
                              ),
                              itemCount: filteredRequests.length,
                              itemBuilder: (context, index) {
                                final request = filteredRequests[index];
                                final status = request['status'] ?? 'pending';
                                final statusColor = _getStatusColor(status);

                                return GestureDetector(
                                    onTap: () async {
// ✅ Check status here

                                      await navigateTo(
                                        context,
                                        DetailsRequestSettings(
                                          requestId: request['id'],
                                          requestData: {
                                            'employeeId': request['employeeId'],
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
                                            'oldValue': request['oldValue'],
                                            'newValue': request['newValue'],
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
                                        padding: EdgeInsets.all(15.sp),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    width: 50.w,
                                                    height: 50.h,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.r),
                                                      color:
                                                          AppColors.background,
                                                    ),
                                                    child: Center(
                                                      child: CustomSvgImage(
                                                          assetPath:
                                                              _sectionIconPath(
                                                                  request[
                                                                      'section']),
                                                          width: 28.w,
                                                          height: 28.h,
                                                          fit: BoxFit.scaleDown,
                                                          color:
                                                              AppColors.text),
                                                    )),
                                                SizedBox(width: 5.w),
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
                                                                AppColors.text),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                )
                                              ],
                                            ),

                                            // space
                                            SizedBox(height: 12.h),
                                            // Date Requested
                                            Row(
                                              children: [
                                                CustomSvgImage(
                                                  assetPath:
                                                      "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                                                  width: 14.w,
                                                  height: 14.h,
                                                  fit: BoxFit.scaleDown,
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
                                                  _formatDate(
                                                      request['dateRequested']),
                                                  style: StyleText
                                                      .fontSize12Weight400
                                                      .copyWith(
                                                          color:
                                                              AppColors.text),
                                                ),
                                              ],
                                            ),
                                            // space
                                            SizedBox(height: 12.h),
                                            // Status
                                            Row(
                                              children: [
                                                CustomSvgImage(
                                                  assetPath:
                                                      "assets/icons_assets/main_icons_assets/ic_status.svg",
                                                  width: 12.w,
                                                  height: 12.h,
                                                  fit: BoxFit.fill,
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
                                                          color: statusColor,
                                                          fontWeight:
                                                              FontWeight.w600),
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
              ],
            ),
          );
  }

  Widget filterSection() {
    final s = S.of(context);

    return Expanded(
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
            }, labelColor: AppColors.darkRed),
          ],
        ),
      ),
    );
  }
}
