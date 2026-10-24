/// Module: services / sv1_home_page_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: home_page_services_part2.dart
/// Purpose: Declares _ServicesScreenTabletState.
/// Author: Amr Mesbah
/// Created At: 02/07/2026
/// Updated: 22/10/2026 by Amr Mesbah — removed the never-shown "request
///          services" view and its filters (rule "Remove dead or unused
///          code"), loads the drafts once instead of on every rebuild (rule
///          "No loading or side effects inside build()"), and uses one search
///          controller.

part of 'home_page_services.dart';

class _ServicesScreenTabletState extends State<ServicesScreenTablet>
    with TickerProviderStateMixin {
  late final HomePageServicesCubit _cubit;

  late AnimationController _gridAnimationController;
  final List<Animation<Offset>> _slideAnimations = [];

  bool _isInitializing = true;
  bool _dataFullyLoaded = false;
  bool _hasInitialized = false; // Track if we've already initialized

  int _lastServicesCount =
      0; // Track the last service count to detect actual changes
  bool isGridViewChoose = true;
  int selectedStatusIndex = 0;

  EmployeeEntityPro? _employeeEntity;

  EmployeeEntityPro get employeeEntity {
    if (_employeeEntity == null) {
      final controller = AppControllers.employee;
      if (controller.employeeEntity != null) {
        _employeeEntity = controller.employeeEntity;
      } else {
        throw Exception('EmployeeEntity is not initialized yet');
      }
    }
    return _employeeEntity!;
  }

  /// The page's only search box (suggestion: one search controller).
  final TextEditingController _searchController = TextEditingController();
  Map<String, Map<String, dynamic>> selectedProviders = {};
  Map<String, int> doneServicesCount = {};

  /// SVC-HOME-05: the drafts error is shown once until a read succeeds.
  bool _draftsErrorShown = false;

  /// Services + drafts, loaded OUTSIDE build() and refreshed only when the
  /// services list really changes (it was re-read from Firestore on every
  /// rebuild, e.g. on each letter typed in the search box).
  Future<List<ServicesHistoryModel>>? _allServicesFuture;

  void _reloadAllServices() {
    _allServicesFuture = _getAllServicesIncludingDrafts();
  }

  void _initializeGridAnimations(int itemCount) {
    _slideAnimations.clear();

    for (int i = 0; i < itemCount; i++) {
      final Animation<Offset> slideAnimation = Tween<Offset>(
        begin: const Offset(-1.0, 0.0), // Slide from left (horizontal)
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            (i * 0.15).clamp(0.0, 1.0),
            ((i * 0.15) + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
      _slideAnimations.add(slideAnimation);
    }

    // Starts once the frame with the new cards is on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _gridAnimationController.forward();
    });
  }

  @override
  void initState() {
    super.initState();

    _cubit = HomePageServicesCubit(
      departmentCubit: context.read<MainCoreDepartmentCubit>(),
      servicesManagerCubit: ServicesManagerCubit.get(context),
    );

    _gridAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Filter starts at "All" (index 0)
    selectedStatusIndex = 0;

    if (!_hasInitialized) {
      _initializeAllData();
    }
  }

  /// Master initialization: loads the employee and the services. Guarded
  /// against duplicate concurrent runs.
  Future<void> _initializeAllData() async {
    if (_hasInitialized) return;

    setState(() {
      _isInitializing = true;
      _dataFullyLoaded = false;
    });

    await _initializeEmployeeAndData();

    if (mounted) {
      // SVC-HOME-01: people who do not manage services only download the
      // services they may see (restricted services of other departments
      // never reach the device).
      final visibleToKeys = HomeServicesVisibilityFilter.managesServices
          ? null
          : serviceVisibilityKeys(
              context.read<MainCoreDepartmentCubit>(),
              _employeeEntity?.departmentId,
            );
      await ServicesManagerCubit.get(context)
          .getAllRequestServices(visibleToKeys: visibleToKeys);
    }

    if (mounted) {
      _lastServicesCount =
          ServicesManagerCubit.get(context).servicesRequest.length;
      setState(() {
        _reloadAllServices();
        _isInitializing = false;
        _dataFullyLoaded = true;
        _hasInitialized = true;
      });
    }
  }

  /// Waits for the employee to load, then runs the one-time bootstrap.
  /// I/O + error handling now live in HomePageServicesCubit.
  Future<void> _initializeEmployeeAndData() async {
    final entity = await _cubit.waitForEmployee();
    if (entity == null) return;

    _employeeEntity = entity;

    await _cubit.bootstrapAfterEmployeeLoaded();

    _searchController.addListener(_onSearchChanged);
    loadSelectedProviders();

    await startApp();
  }

  Future<void> startApp() async {
    await _cubit.persistRequesterProfile(employeeEntity);
  }

  String formatStartDate(dynamic timestampOrDateTime) =>
      HomeServicesDurationUtils.formatStartDate(timestampOrDateTime);

  Future<List<ServicesHistoryModel>> _getAllServicesIncludingDrafts() async {
    final servicesCubit = ServicesManagerCubit.get(context);

    // Use servicesRequest which now has repaired drafts
    final firestoreServices = servicesCubit.servicesRequest;

    final regularServices = firestoreServices.where((s) {
      final state = s.currentState.toLowerCase().trim();
      return state != 'draft';
    }).toList();

    final draftsInFirestore = firestoreServices.where((s) {
      final state = s.currentState.toLowerCase().trim();
      return state == 'draft';
    }).toList();

    // Additional Firebase drafts — I/O + error handling live in the cubit.
    final additionalDrafts = await _cubit.fetchAdditionalFirebaseDrafts();

    // SVC-HOME-05: a failed drafts read is shown (once per failure) instead
    // of looking like "no drafts".
    if (!_cubit.draftsFetchFailed) {
      _draftsErrorShown = false;
    } else if (!_draftsErrorShown && mounted) {
      _draftsErrorShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).svcDraftsLoadFailed),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    final combinedServices = <ServicesHistoryModel>[];
    final Set<String> addedIds = {};

    for (final service in [
      ...regularServices,
      ...draftsInFirestore,
      ...additionalDrafts,
    ]) {
      if (!addedIds.contains(service.currentId)) {
        combinedServices.add(service);
        addedIds.add(service.currentId);
      }
    }

    return combinedServices;
  }

  // SVC-HOME-04: providers come from each service's own provider list, which
  // is already loaded — no Firestore read per service.
  void loadSelectedProviders() {
    if (!mounted) return;
    final services = ServicesManagerCubit.get(context).services;
    final result = <String, Map<String, dynamic>>{};
    for (final service in services) {
      final serviceId = service.currentId;
      final providers = service.currentProviderServices;
      if (serviceId.isEmpty || providers.isEmpty) continue;
      final p = providers.first;
      result[serviceId] = {
        'firstName': p.firstName ?? '',
        'lastName': p.lastName ?? '',
        'email': p.email ?? '',
        'title': p.title ?? '',
        'titleInArabic': p.titleInArabic ?? '',
        'firstNameInArabic': p.firstNameInArabic ?? '',
        'lastNameInArabic': p.lastNameInArabic ?? '',
      };
    }
    setState(() => selectedProviders = result);
  }

  /// Search only re-filters the list already loaded (no Firestore read).
  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  String getLocalizedDurationUnit(
    BuildContext context,
    String? rawUnit, {
    num? quantity,
  }) {
    return HomeServicesDurationUtils.getLocalizedDurationUnit(
      S.of(context),
      rawUnit,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only show loading on FIRST load, not on navigation back
    if (!_hasInitialized && (_isInitializing || !_dataFullyLoaded)) {
      return HomeServicesLoadingView(subtitle: S.of(context).waitUntilDataCome);
    }

    // MAIN CONTENT — show immediately on subsequent visits
    return BlocConsumer<ServicesManagerCubit, ServicesManagerState>(
      listener: (context, state) {
        if (state is GetServiceLoaded) {
          // Reload the services + drafts only when the list really changed.
          if (mounted && _hasInitialized) {
            final newServicesCount =
                ServicesManagerCubit.get(context).servicesRequest.length;
            if (newServicesCount != _lastServicesCount) {
              setState(() {
                _lastServicesCount = newServicesCount;
                _reloadAllServices();
              });
            }
          }
        } else if (state is GetServiceError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context).errorLoadingServices),
                backgroundColor: AppColors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final servicesCubit = ServicesManagerCubit.get(context);

        // Show loading only for initial load (not for navigation back)
        if (state is GetServiceLoading && !_hasInitialized) {
          return const HomeServicesLoadingView();
        }

        // Show error state
        if (state is GetServiceError && !_hasInitialized) {
          return HomeServicesErrorView(
            title: S.of(context).errorLoadingServices,
            message: S.of(context).svcTryAgainLater,
            onRetry: () async {
              setState(() {
                _isInitializing = true;
                _dataFullyLoaded = false;
                _hasInitialized = false;
              });
              await _initializeAllData();
            },
          );
        }

        // MAIN CONTENT with FutureBuilder (the future is created outside
        // build, see _reloadAllServices).
        return FutureBuilder<List<ServicesHistoryModel>>(
          future: _allServicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !_hasInitialized) {
              return HomeServicesLoadingView(
                subtitle: S.of(context).svcLoadingDraftServices,
              );
            }

            final allServices = snapshot.data ?? servicesCubit.services;
            final filteredModel = _getFilteredServices(allServices);

            // FINAL UI — render immediately on subsequent visits
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: SideFrameMasterServices(
                  // ✅ FIX (bug report p20): this is the services *list* page,
                  // so the heading is plural. It read "Service".
                  titleText: S.of(context).services,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: ClampingScrollPhysics(),
                    child: SlideInContent(
                      from: SlideFrom.bottom,
                      child: Column(
                        children: [
                          managementWidget(
                            allServices: allServices,
                            filteredModel: filteredModel,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget managementWidget({
    required List<ServicesHistoryModel> allServices,
    required List<ServicesHistoryModel> filteredModel,
  }) {
    // Initialize animations when filtered model changes
    if (_slideAnimations.isEmpty ||
        _slideAnimations.length != filteredModel.length) {
      _initializeGridAnimations(filteredModel.length);
    }

    return ManagementWidget(
      allServices: allServices,
      filteredModel: filteredModel,
      selectedProviders: selectedProviders,
      doneServicesCount: doneServicesCount,
      searchController: _searchController,
      isGridViewChoose: isGridViewChoose,
      isMobile: ContextExtension(context).isPhone,
      lightMode: Theme.of(context).brightness == Brightness.light,
      employeeEntity: _employeeEntity,
      formatStartDate: formatStartDate,
      getLocalizedDurationUnit: getLocalizedDurationUnit,
      filterWidget: filterWidget,
      approvalAndServicesRequest: approvalAndServicesRequest,
      onToggleGridView: () =>
          setState(() => isGridViewChoose = withLowHaptic(true)),
      onToggleTableView: () =>
          setState(() => isGridViewChoose = withLowHaptic(false)),
    );
  }

  Widget filterWidget(List<ServicesHistoryModel> allServices) {
    return HomeServicesStatusFilter(
      allServices: allServices,
      currentUserEmail: _employeeEntity?.email ?? '',
      selectedStatusIndex: selectedStatusIndex,
      onIndexSelected: (index) => setState(() => selectedStatusIndex = index),
    );
  }

  List<ServicesHistoryModel> _getFilteredServices(
    List<ServicesHistoryModel> allServices,
  ) {
    return HomeServicesVisibilityFilter.getFilteredServices(
      allServices: allServices,
      searchQuery: _searchController.text,
      currentUserEmail: _employeeEntity?.email ?? '',
      selectedStatusIndex: selectedStatusIndex,
    );
  }
}
