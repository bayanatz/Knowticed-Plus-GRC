/// Module: knowledge_hub/kh6_approvals/presentation/ui/pages
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_screen.sections.dart
/// Description: `_ApprovalsScreenSections` — split out of `approvals_screen.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'approvals_screen.dart';

/// Fields + helper/builder methods for the screen, split out to keep
/// each file under 800 LOC (§7).
mixin _ApprovalsScreenSections on State<ApprovalsScreen> {
  int selectedIndex = 0;

  final TextEditingController searchApprovalsController =
      TextEditingController();

  bool _isInitialized = false;

  String? _currentSelectedDepartment;

  // Animation Controllers
  late AnimationController _gridAnimationController;

  final List<Animation<Offset>> _slideAnimations = [];

  final List<Animation<double>> _fadeAnimations = [];

  bool _animationsCreated = false;

  // Create horizontal staggered animations
  void _createSlideAnimations(int itemCount) {
    _slideAnimations.clear();
    _fadeAnimations.clear();

    for (int i = 0; i < itemCount; i++) {
      // Stagger delay: 40ms between each item
      final delay = i * 0.04;

      // ✅ HORIZONTAL Slide animation from LEFT
      final slideAnimation =
          Tween<Offset>(
            begin: const Offset(-0.3, 0.0), // Horizontal from left
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _gridAnimationController,
              curve: Interval(
                delay.clamp(0.0, 0.6),
                (delay + 0.4).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            ),
          );

      // Fade animation
      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay.clamp(0.0, 0.6),
            (delay + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeIn,
          ),
        ),
      );

      _slideAnimations.add(slideAnimation);
      _fadeAnimations.add(fadeAnimation);
    }

    _animationsCreated = true;
  }

  // Play animation
  void _playGridAnimation() {
    if (_gridAnimationController.isAnimating) return;
    _gridAnimationController.forward(from: 0.0);
  }

  // At the top of your build method or as a helper method:
  String _getLocalizedName(CreateKnowledgeModel knowledge) {
    return KhLocale.pick(
      context,
      en: knowledge.currentNameEnglish,
      ar: knowledge.currentNameArabic,
    );
  }

  void _debugEmployeeData(EmployeeData? employee) {
    if (employee == null) {
      return;
    }
  }

  String _getLocalizedDescription(CreateKnowledgeModel knowledge) {
    // (The old copy of this fell back to the empty ARABIC field.)
    return KhLocale.pick(
      context,
      en: knowledge.currentDescriptionEnglish,
      ar: knowledge.currentDescriptionArabic,
    );
  }

  Future<void> _initializeApprovals() async {
    if (_isInitialized) return;
    final employeeController = context.read<ApprovalsCubit>().people.employees;
    _isInitialized = await context.read<ApprovalsCubit>().initializeQueue(
      resolveUserEmail: () async {
        if (employeeController.employeeEntity == null) {
          await employeeController.getAllNewEmployees();
        }
        return employeeController.employeeEntity?.email;
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(child: CircleProgressMaster()),
    );
  }

  // The approvals grid, with its entry animation
  Widget buildApprovalsGrid(BuildContext conGrtext, bool isMobile) {
    final cubit = context.read<ApprovalsCubit>();
    final approvals = cubit.filteredKnowledge;

    if (approvals.isEmpty) {
      return buildNoFilterResultsState(context);
    }

    // Pre-fetch department names and user data for all submissions
    cubit.fetchDepartmentsForKnowledge(approvals);
    _prefetchUsersForApprovals(cubit, approvals);

    // ✅ CREATE ANIMATIONS IF NOT CREATED
    if (!_animationsCreated || _slideAnimations.length != approvals.length) {
      _createSlideAnimations(approvals.length);
      // Play animation after creation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playGridAnimation();
      });
    }

    final int columns = CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
      context,
    );
    final List<Widget> rows = [];
    for (int start = 0; start < approvals.length; start += columns) {
      final List<Widget> cells = [];
      for (int i = start; i < start + columns; i++) {
        if (i > start) cells.add(SizedBox(width: 15.sp));
        if (i >= approvals.length) {
          cells.add(const Expanded(child: SizedBox()));
          continue;
        }
        final approval = approvals[i];
        cells.add(
          Expanded(
            child: SlideTransition(
              position: _slideAnimations.length > i
                  ? _slideAnimations[i]
                  : AlwaysStoppedAnimation(Offset.zero),
              child: FadeTransition(
                opacity: _fadeAnimations.length > i
                    ? _fadeAnimations[i]
                    : AlwaysStoppedAnimation(1.0),
                child: buildDocumentCard(context, approval, cubit),
              ),
            ),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: 15.sp));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 20.sp),
      child: Column(children: rows),
    );
  }

  /// ✅ Prefetch user data for all creators in the list
  Future<void> _prefetchUsersForApprovals(
    ApprovalsCubit cubit,
    List<CreateKnowledgeModel> approvals,
  ) async {
    // Extract unique creator emails
    final creatorEmails = approvals
        .map((k) => k.currentCreatedByEmail)
        .where((email) => email.isNotEmpty)
        .toSet()
        .toList();

    // Fetch user data for each email (will use cache if already fetched)
    for (final email in creatorEmails) {
      cubit.getUserDataByEmail(email);
    }
  }

  String _getLocalizedEmployeeNameExplicit(EmployeeData? employee) {
    if (employee == null) return '-';

    final employeeController = context.read<ApprovalsCubit>().people.employees;
    String name = employeeController.getEmployeeNameEnglishArabic(
      employee.currentemployeeEmail,
      KhLocale.isEnglish(context),
    );

    return name.isNotEmpty ? name : employee.currentemployeeName;
  }

  String _getLocalizedDepartmentName(String departmentName) =>
      KhLocale.department(context, departmentName);

  String _getLocalizedJobTitle(EmployeeData? employee) {
    if (employee == null) return '-';

    final employeeController = context.read<ApprovalsCubit>().people.employees;

    String jobTitle = employeeController.getEmployeeJobTitle(
      employee.currentemployeeEmail,
    );

    return jobTitle == "no job" ? employee.currentemployeeRole : jobTitle;
  }

  /// Show rejection confirmation dialog
  void _showRejectConfirmationDialog(
    BuildContext context,
    String knowledgeId,
    bool isMobile,
    bool lightMode,
  ) {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: lightMode ? AppColors.white : AppColors.background,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json',
                  height: 70.h,
                  width: 70.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  S.of(context).rejectRequest,
                  style: StyleText.fontSize20Weight500,
                ),
                SizedBox(height: 18.h),
                Text(
                  S.of(context).areYouSureYouWantToRejectRequest,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: customButton(
                        title: S.of(context).no,
                        height: 38.h,
                        width: 135.w,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.onSecondaryAction,
                        ),
                        color: AppColors.secondaryAction,
                        function: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ),
                    SizedBox(width: 45.w),
                    Expanded(
                      child: customButton(
                        height: 38.h,
                        width: 135.w,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(ctx);
                          showAppDialog(
                            barrierDismissible: true,
                            builder: (dialogContext) => BlocProvider.value(
                              value: context.read<ApprovalsCubit>(),
                              child: ResonForApprovalRemovingDialog(
                                knowledgeId: knowledgeId,
                              ),
                            ),
                            context: ctx,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fetch all necessary data for the card
  Future<Map<String, dynamic>> _fetchCardData(
    ApprovalsCubit cubit,
    CreateKnowledgeModel approvals,
  ) => cubit.fetchCardData(approvals); // never throws (Rule Bug 4)

  Widget _buildLoadingCard(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: ScreenUtil().screenWidth,
      // The grid no longer forces a card height (see buildApprovalsGrid), so
      // the placeholder keeps a card-like height while the data loads.
      constraints: BoxConstraints(minHeight: 200.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: lightMode ? AppColors.white : AppColors.background,
      ),
      padding: EdgeInsets.all(10.w),
      child: Center(
        child: CircleProgressMaster.inline(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Build error state for card - shows submission data as fallback
  Widget _buildErrorCard(
    BuildContext context,
    CreateKnowledgeModel submission,
  ) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: lightMode ? AppColors.white : AppColors.background,
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      padding: EdgeInsets.all(10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.orange, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  submission.currentNameEnglish,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            S.of(context).khSomeDetailsLoadFailed,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _getTimestampDate(int? timestamp) {
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Helper function to get color for status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return AppColors.green;
      case 'pending_approval':
        return AppColors.orange;
      case 'scheduled':
        return AppColors.blue;
      case 'rejected':
        return AppColors.red;
      case 'removed':
        return AppColors.colorGrey;
      case 'archived':
        return AppColors.secondaryText;
      default:
        return AppColors.black;
    }
  }

  Widget _buildErrorState(FetchingApprovalsErrorState state) {
    return CustomErrorState(
      title: S.of(context).errorLoadingApprovals,
      message: state.key.text(context, detail: state.error),
      onRetry: _initializeApprovals,
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: const CustomEmptyState(),
    );
  }

  Widget buildNoFilterResultsState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: const CustomEmptyState(),
    );
  }

  void _handleIndexChanges(BuildContext context, ApprovalsStates state) {
    if (state is ChangeIndexSuccessState) {
      setState(() {
        selectedIndex = state.index;
        _currentSelectedDepartment = null;
        _animationsCreated = false;
      });
    }
  }
}
