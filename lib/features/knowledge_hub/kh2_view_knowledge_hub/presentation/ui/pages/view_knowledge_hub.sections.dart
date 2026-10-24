/// Module: knowledge_hub/kh2_view_knowledge_hub/presentation/ui/pages
///
///*************************** FILE INFO ****************************///
/// File Name: view_knowledge_hub.sections.dart
/// Description: `_ViewKnowledgeHubSections` — split out of `view_knowledge_hub.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'view_knowledge_hub.dart';

/// Module: knowledge_hub / presentation / s2_view_knowledge_hub/view_knowledge_hub.sections.dart

/// View state + builder/init helpers for [ViewKnowledgeHub], split out of
/// the page to keep each file under the 800-LOC limit (§7).
mixin _ViewKnowledgeHubSections on State<ViewKnowledgeHub> {
  int selectedIndex = 0;
  int innerIndex = 0;
  final TextEditingController searchController = TextEditingController();
  bool _isEmployeeDataLoaded = false;

  /// KH-CREATE-01 — true while we are asking the employee controller to load
  /// the SIGNED-IN employee; false once it answered (found or not).
  bool _employeeLoading = false;
  List<DepartmentModelPro> _cachedDepartments = [];

  // Animation controllers
  late AnimationController _gridAnimationController;

  /// True once the hub's first document fetch has answered (KH mobile p.1):
  /// before that, "no documents" means "not loaded yet" and shows a loader.
  bool _hubFetchedOnce = false;
  final List<Animation<Offset>> _slideAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];
  bool _animationsCreated = false;

  // ✅ CREATE HORIZONTAL STAGGERED ANIMATIONS
  void _createSlideAnimations(int itemCount) {
    _slideAnimations.clear();
    _fadeAnimations.clear();

    for (int i = 0; i < itemCount; i++) {
      // Stagger delay: 40ms between each item (adjusted for 1 second total)
      final delay = i * 0.04;

      // ✅ HORIZONTAL Slide animation from LEFT
      final slideAnimation =
          Tween<Offset>(
            begin: const Offset(
              -0.3,
              0.0,
            ), // ✅ Changed to horizontal (left to right)
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _gridAnimationController,
              curve: Interval(
                delay.clamp(0.0, 0.6), // Start delay
                (delay + 0.4).clamp(0.0, 1.0), // End delay
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

  // ✅ PLAY ANIMATION
  void _playGridAnimation() {
    if (_gridAnimationController.isAnimating) return;
    _gridAnimationController.forward(from: 0.0);
  }

  String getFileIcon(String extension) {
    final ext = extension.toLowerCase().trim();

    switch (ext) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
      case 'doc':
        return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
      case 'docx':
        return 'assets/icons_assets/knowledge_hub_assets/ic_file_word.svg';
      case 'xls':
      case 'csv':
      case 'xlsx':
        return 'assets/icons_assets/main_icons_assets/ic_file_excel.svg';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
      default:
        return 'assets/icons_assets/knowledge_hub_assets/ic_action_view.svg';
    }
  }

  /// Loads the departments, sets the signed-in user on the cubit, then
  /// loads the documents that user may see.
  Future<void> _initializeData() async {
    final CreateKnowledgeCubit cubit = context.read<CreateKnowledgeCubit>();
    await cubit.fetchAllDepartments();
    if (!mounted) return;
    setState(() => _cachedDepartments = cubit.allDepartments);

    final employee = context
        .read<CreateKnowledgeCubit>()
        .people
        .employees
        .employeeEntity;
    if (employee != null) {
      String? userDepartmentName;
      for (final DepartmentModelPro dept in cubit.allDepartments) {
        if (dept.departmentID == employee.departmentId) {
          userDepartmentName = dept.departmentName;
          break;
        }
      }
      cubit.setCurrentUser(
        department: userDepartmentName,
        email: employee.email,
      );
    }
    cubit.chooseIndex(0);
    await cubit.fetchAllKnowledge();
  }

  // KH-CREATE-01 (critical).
  // This used to "find" a user when the signed-in employee was not loaded yet:
  // it took the FIRST employee in the map, or one of five staff e-mails typed
  // into the code, and made that person the current user (their department,
  // role and ID). Everything the real user then did was recorded under someone
  // else. Now the page only ever uses the employee the controller resolved
  // from the login (getAllNewEmployees matches it against EmployeeController),
  // and waits — or shows an error with Retry — until that is available.
  void _initializeEmployeeController() {
    final employeeController = context
        .read<CreateKnowledgeCubit>()
        .people
        .employees;
    _isEmployeeDataLoaded = employeeController.employeeEntity != null;
    if (!_isEmployeeDataLoaded) {
      _employeeLoading = true; // shows the loader on the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _employeeLoading = false;
        _loadSignedInEmployee();
      });
    }
  }

  /// Asks the controller to load the employee list and resolve the SIGNED-IN
  /// employee from it. Never picks anyone on the device's behalf.
  Future<void> _loadSignedInEmployee() async {
    if (_employeeLoading) return;
    final employeeController = context
        .read<CreateKnowledgeCubit>()
        .people
        .employees;
    _setStateIfMounted(() => _employeeLoading = true);
    await employeeController.getAllNewEmployees();
    _setStateIfMounted(() {
      _employeeLoading = false;
      _isEmployeeDataLoaded = employeeController.employeeEntity != null;
    });
  }

  void _setStateIfMounted(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  /// Shows the page only once the SIGNED-IN employee is known (KH-CREATE-01).
  /// Until then: a loader while loading, or an error with Retry if the
  /// employee could not be resolved. It never substitutes another employee.
  Widget _buildEmployeeDataWrapper({required Widget child}) {
    return GetBuilder<MainCoreEmployeeController>(
      id: 'employee_data',
      builder: (employeeController) {
        final employee = employeeController.employeeEntity;

        if (employee != null) {
          return child; // KH-CREATE-07: no global ConstantVar copy any more
        }

        if (_employeeLoading) {
          return Center(child: CircleProgressMaster());
        }

        // Not loading and still no employee: say so, and let the user retry.
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppColors.red, size: 40.sp),
                SizedBox(height: 12.sp),
                Text(
                  S.of(context).accountDataLoadError,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 12.sp),
                customButton(
                  title: S.of(context).retry,
                  function: _loadSignedInEmployee,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepartmentsWithCache() {
    return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
      builder: (context, state) {
        if (state is FetchingDepartmentLoadingState &&
            _cachedDepartments.isEmpty) {
          // This is the spinner that shows where the
          // department counters belong while they load, on the Knowledge Hub
          // home page. It was Material's bare default, unstyled and a
          // different shape from every other loader on the same screen.
          //
          // (Knowledge Hub bug report p.15 — the spinner is
          // struck out): nothing is drawn here while the counters load. The
          // documents grid below already shows its own loader, and a second
          // spinner floating between the header buttons and the search bar
          // read as the page being stuck.
          return const SizedBox.shrink();
        }

        if (state is FetchingDepartmentErrorState &&
            _cachedDepartments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60.sp, color: AppColors.red),
                SizedBox(height: 16.h),
                Text(
                  S.of(context).errorOccurred,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
                customButton(
                  title: S.of(context).retry,
                  function: _initializeData,
                  wrapContent: true,
                ),
              ],
            ),
          );
        }

        List<DepartmentModelPro> departments = _cachedDepartments;
        if (state is FetchingDepartmentSuccessState) {
          departments = state.departmentList;
          _cachedDepartments = departments;
        }

        if (departments.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: Text(
                S.of(context).no_data_available,
                style: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          );
        }

        return departmentsListView(
          context,
          selectedIndex: selectedIndex,
          cubit: context.read<CreateKnowledgeCubit>(),
          departmentNames: departments,
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, CreateKnowledgeState state) {
    if (state is ChangedIndexSuccessState) {
      setState(() {
        selectedIndex = state.index;
        // ✅ REPLAY ANIMATION WHEN INDEX CHANGES
        _animationsCreated = false;
        khLog(
          '📍 Selected department index: $selectedIndex',
          name: 'STATE_CHANGE',
        );
      });
    } else if (state is ChangedInnerIndexSuccessState) {
      setState(() {
        innerIndex = state.index;
        // ✅ REPLAY ANIMATION WHEN INNER INDEX CHANGES
        _animationsCreated = false;
        khLog('📍 Selected inner index: $innerIndex', name: 'STATE_CHANGE');
      });
    }
  }
}
