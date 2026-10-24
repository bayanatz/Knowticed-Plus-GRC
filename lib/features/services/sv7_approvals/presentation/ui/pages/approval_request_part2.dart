/// Module: services / sv7_approvals / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_part2.dart
/// Purpose: State of the approvals list: the filter inputs and the card
///          grid. The counts, filter and sort are done by
///          ApprovalRequestCubit (Requests R1).
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'approval_request.dart';

class _ApprovalServicesState extends State<ApprovalServices> {
  late final ApprovalRequestCubit _approvalRequestCubit;
  bool isGridViewChoose = true;
  TextEditingController searchController = TextEditingController();
  String? selectedStatus;
  List<String> selectedDepartmentKeys = [];
  List<ServicesHistoryModel> visibleApprovals = [];

  /// The signed-in approver's e-mail.
  String get _myEmail => (CurrentUserContext.email ?? '').toLowerCase();

  String _statusKey = 'all';

  /// Requests R1: the counting lives in [ApprovalRequestCubit]; the page
  /// only asks for it and redraws.
  void _recountMyActionCounts() {
    _approvalRequestCubit.recount(
      ServicesManagerCubit.get(context).myApproval,
      _myEmail,
    );
    setState(() {});
  }

  /// Requests R1: filtering and sorting live in [ApprovalRequestCubit].
  void _filterServices() {
    setState(() {
      visibleApprovals = _approvalRequestCubit.visibleApprovals(
        approvals: ServicesManagerCubit.get(context).myApproval,
        approverEmail: _myEmail,
        statusKey: _statusKey,
        departmentIds: selectedDepartmentKeys.toSet(),
        query: searchController.text,
        sort: selectedSortOption,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _approvalRequestCubit = ApprovalRequestCubit(
      decisions: context.read<ApprovalDecisionService>(),
      lookup: context.read<RequestDetailsLookup>(),
    );
    // Initialize controllers

    searchController.addListener(() {
      _filterServices();
    });

    _loadApprovals();
  }

  // remembers a failed load so the page shows an error with
  // Retry instead of the "no approvals" animation.
  bool _approvalsLoadFailed = false;

  void _loadApprovals() {
    final managerCubit = ServicesManagerCubit.get(context);
    managerCubit.getMyApprovalServices(_myEmail).then((_) {
      if (!mounted) return;
      setState(() {
        _approvalsLoadFailed = managerCubit.state is GetMyApprovalServicesError;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _recountMyActionCounts();
        _filterServices();
      });
    });
  }

  /// Re-sorts (and re-filters) the cards after the sort option changed.
  void sortServices() => _filterServices();

  String? idSelect;
  String? selectServicesName;
  bool isApproved = false;
  bool isRejected = false;
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  RequestSort selectedSortOption = RequestSort.dateRequested;
  String userEmail = '';
  String userDepartment = '';
  List<ServicesHistoryModel> filteredServices = [];
  bool isFilterDialogOpen = false;
  String selectDepartment = "";
  final Map<String, String> approvalStateMap = {};
  String? selectedDepartmentKey;
  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isMobile = ContextExtension(context).isPhone;
    final isLandscape = ContextExtension(context).isLandscape;

    return SlideInContent(
      from: SlideFrom.bottom,
      child: Scaffold(
        body: SafeArea(
          child: SideFrameMasterServices(
            titleText: S.of(context).services,
            onFirstTap: () {
              navigateTo(context, LayoutScreenServices());
            },
            secondTitle: S.of(context).approvals,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isMobile
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildStatusChips(context),
                        )
                      : _buildStatusChips(context),
                  SizedBox(height: 15.h),
                  SizedBox(
                    child: Row(
                      children: [
                        AppSearchTextField(
                          controller: searchController,
                          onChanged: (text) {
                            _filterServices();
                          },
                        ),

                        SizedBox(width: 9.sp),

                        // The department multi-select stays wide-screen only —
                        // there is no room for it beside the search box on a phone.
                        if (!isMobile) ...[
                          DepartmentMultiSelectPage(
                            selectedKeys: selectedDepartmentKeys,
                            onChanged: (keys) {
                              setState(() => selectedDepartmentKeys = keys);
                              _filterServices();
                            },
                          ),
                          SizedBox(width: 9.sp),
                        ],
                        // the phone had no department
                        // filter. Icon button → department dialog, writing the
                        // same selectedDepartmentKeys as the dropdown above.
                        if (isMobile) ...[
                          ApprovalsDepartmentFilterButton(
                            selectedKeys: selectedDepartmentKeys,
                            onChanged: (keys) {
                              setState(() => selectedDepartmentKeys = keys);
                              _filterServices();
                            },
                          ),
                          SizedBox(width: 9.sp),
                        ],

                        // The same sort menu on every screen size.
                        ServicesSortButton(
                          selectedOption: selectedSortOption,
                          onSortSelected: (value) {
                            setState(() => selectedSortOption = value);
                            sortServices();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  _approvalsLoadFailed
                      ? ServicesLoadError(
                          message: S.of(context).errorLoadingApprovals,
                          onRetry: () {
                            setState(() => _approvalsLoadFailed = false);
                            _loadApprovals();
                          },
                        )
                      : visibleApprovals.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomEmptyState(
                                    lottiePath: ServicesLottie.emptyState,
                                    size: 260,
                                    verticalPadding: 0,
                                  ),
                                ],
                              ),
                            )
                          : AnimatedCustomGridView(
                              itemCount: visibleApprovals.length,
                              crossAxisCount: CrossAxisCountHelperResponsive
                                  .getCrossAxisCountForDefaultTabletResponsive(
                                context,
                              ),
                              mainAxisExtent: approvalCardExtent(context),
                              mainAxisSpacing: 15.sp,
                              crossAxisSpacing: 15.sp,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              margin: EdgeInsets.only(bottom: 16.sp),
                              animationDuration:
                                  const Duration(milliseconds: 800),
                              staggerDelay: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              itemBuilder: (context, index) {
                                final service = visibleApprovals[index];

                                return ApprovalRequestCard(
                                  key: ValueKey(service.currentId),
                                  service: service,
                                  cubit: _approvalRequestCubit,
                                  onRefresh: () async {
                                    await ServicesManagerCubit.get(context)
                                        .getMyApprovalServices(_myEmail);

                                    _filterServices();

                                    _recountMyActionCounts();
                                  },
                                  isMobile: isMobile,
                                  isTablet: isTablet,
                                  isLandscape: isLandscape,
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChips(BuildContext context) {
    StatusChipItem chip(String key, int count) => StatusChipItem(
          key: key,
          label: FormatHelper.capitalize(context.svcStatus(key)),
          count: count,
          labelColor: _chipColor(key),
        );
    final counts = _approvalRequestCubit.state;
    return StatusChipFilter(
      selectedKey: _statusKey,
      onSelected: (status) {
        setState(() => _statusKey = status);
        _filterServices();
        _recountMyActionCounts();
      },
      items: [
        StatusChipItem(
          key: 'all',
          label: FormatHelper.capitalize(S.of(context).all),
          count: counts.total,
        ),
        chip(RequestStatus.approved, counts.approved),
        chip(RequestStatus.pending, counts.pending),
        chip(RequestStatus.rejected, counts.rejected),
        chip(RequestStatus.cancel, counts.cancel),
      ],
    );
  }

  Color _chipColor(String status) {
    switch (status) {
      case RequestStatus.approved:
        return AppColors.lightGreen;
      case RequestStatus.pending:
        return AppColors.orange;
      case RequestStatus.rejected:
        return AppColors.red;
      default:
        return AppColors.darkRed;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _approvalRequestCubit.close();
    super.dispose();
  }
}
