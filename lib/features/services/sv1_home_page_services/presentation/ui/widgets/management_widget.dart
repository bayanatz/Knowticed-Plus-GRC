/// Module: services / sv1_home_page_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: management_widget.dart
/// Purpose: Management widget — declares ManagementWidget,
///          _ManagementWidgetState.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/layout/custom_gridview_with_animation.dart';
import 'package:knowticed_plus/core/custom/layout/custom_grid_view.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/table_widget.dart';
import 'package:knowticed_plus/features/services/sv3_create_master_services/presentation/ui/pages/master_upload_toggle.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/pages/employee_services.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/pages/admin_dashboard_page.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/request_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/pages/approval_request_toggle.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/pages/department_dashboard_page.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/export_file.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/service_grid_card.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/management_action_buttons.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/widgets/home_services_action_button_metrics.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';

class ManagementWidget extends StatefulWidget {
  final List<ServicesHistoryModel> allServices;
  final List<ServicesHistoryModel> filteredModel;
  final Map<String, Map<String, dynamic>> selectedProviders;
  final Map<String, int> doneServicesCount;
  final TextEditingController searchController;
  final bool isGridViewChoose;
  final bool isMobile;
  final bool lightMode;
  final EmployeeEntityPro? employeeEntity;
  final String Function(dynamic) formatStartDate;
  final Function(BuildContext, String?) getLocalizedDurationUnit;
  final Widget Function(List<ServicesHistoryModel>) filterWidget;
  final Widget Function(BuildContext) approvalAndServicesRequest;
  final VoidCallback onToggleGridView;
  final VoidCallback onToggleTableView;

  const ManagementWidget({
    super.key,
    required this.allServices,
    required this.filteredModel,
    required this.selectedProviders,
    required this.doneServicesCount,
    required this.searchController,
    required this.isGridViewChoose,
    required this.isMobile,
    required this.lightMode,
    required this.employeeEntity,
    required this.formatStartDate,
    required this.getLocalizedDurationUnit,
    required this.filterWidget,
    required this.approvalAndServicesRequest,
    required this.onToggleGridView,
    required this.onToggleTableView,
  });

  @override
  State<ManagementWidget> createState() => _ManagementWidgetState();
}

class _ManagementWidgetState extends State<ManagementWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;

  // Local state to store loaded providers
  Map<String, Map<String, dynamic>> _loadedProviders = {};
  Map<String, int> _loadedDoneServicesCount = {};

  @override
  void initState() {
    super.initState();

    // Initialize animation controller starting from 0
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      value: 0.0, // Start from invisible
    );

    // Load providers for all services
    _loadProviders(); // ← existing line
    _loadDoneServicesCount(); // ← ADD THIS LINE

    // Trigger initial animation after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _flipController.forward();
      }
    });
  }

  /// Resolves a provider map for [services] using, in order: the service's own
  /// provider data, the in-memory/parent caches, then the repository.
  /// W04: no try/catch — each access is guarded and the repo owns its errors.
  Future<Map<String, Map<String, dynamic>>> _resolveProviders(
    List<ServicesHistoryModel> services,
  ) async {
    final Map<String, Map<String, dynamic>> result = {};

    for (final service in services) {
      final serviceId = service.currentId;
      if (serviceId.isEmpty || serviceId.startsWith('draft_')) continue;

      // METHOD 1: from the service object (fastest)
      if (service.currentProviderServices.isNotEmpty) {
        // ✅ Respect the assigned provider rather than always taking [0].
        final assignedEmail =
            service.currentAssignedProviderEmail.toLowerCase().trim();

        final provider = assignedEmail.isEmpty
            ? service.currentProviderServices.first
            : service.currentProviderServices.firstWhere(
                (p) => (p.email?.toLowerCase().trim() ?? '') == assignedEmail,
                orElse: () => service.currentProviderServices.first,
              );
        result[serviceId] = {
          'firstName': provider.firstName ?? '',
          'lastName': provider.lastName ?? '',
          'email': provider.email ?? '',
          'gender': provider.gender ?? '',
          'role': provider.role ?? '',
          'title': provider.title ?? '',
          'phone': provider.mobilePhone?.phone ?? '',
          'firstNameInArabic': provider.firstNameInArabic ?? '',
          'lastNameInArabic': provider.lastNameInArabic ?? '',
        };
        continue;
      }

      // METHOD 2: from caches (local state, then parent-provided)
      final cached =
          _loadedProviders[serviceId] ?? widget.selectedProviders[serviceId];
      if (cached != null && cached.isNotEmpty) {
        result[serviceId] = Map<String, dynamic>.from(cached);
        continue;
      }

      // METHOD 3: via the repository
      final fetched = await selectServiceProvider(serviceId);
      if (fetched != null) {
        result[serviceId] = fetched;
      }
    }
    return result;
  }

  /// Load providers for all services into local state.
  Future<void> _loadProviders() async {
    final loaded = await _resolveProviders(widget.allServices);
    if (mounted) {
      setState(() {
        _loadedProviders = loaded;
      });
    }
  }

  Future<void> _loadDoneServicesCount() async {
    // W02/W04: no Firestore or try/catch in the widget — delegate to the repo.
    final doneCounts = await ServicesManagerCubit.get(context)
        .repository
        .getDoneServicesCountByParent();

    if (mounted) {
      setState(() {
        _loadedDoneServicesCount = doneCounts;
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleToggleView(bool isGrid) {
    // Reset animation first
    _flipController.reset();

    // Change the view
    if (isGrid) {
      widget.onToggleGridView();
    } else {
      widget.onToggleTableView();
    }

    // Trigger animation after a short delay to ensure rebuild
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _flipController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(ManagementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If data changed and animation is complete, restart it
    if (oldWidget.filteredModel.length != widget.filteredModel.length) {
      _flipController.reset();
      // Reload providers when services change
      _loadProviders();
      _loadDoneServicesCount();
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _flipController.forward();
        }
      });
    }
  }

  /// FIXED 16/10/2026 (merge check): on phones the five action buttons came
  /// from three rows whose widths customButton ignores, so every button had a
  /// different width. Phones now get one even 2-column grid, with the same
  /// permission checks as the rows it replaces.
  Widget _phoneActionGrid(BuildContext context) {
    Widget button(String title, Widget page) => customButton(
          title: title,
          function: () => navigateTo(context, page),
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          fullWidth: true,
          height: 38.h,
          radius: 8.r,
          color: AppColors.primary,
        );
    final List<Widget> buttons = [
      if (ServicesModuleAccess.canViewRequestedServices)
        button(S.of(context).requestedServices, const EmployeeServicesScreen()),
      if (ServicesModuleAccess.canViewAdminDashboard)
        button(S.of(context).adminDashboard, AdminDashboardPage()),
      if (ServicesModuleAccess.canRequestService)
        button(S.of(context).serviceRequests, RequestServicesToggle()),
      if (ServicesModuleAccess.canViewDepartmentDashboard)
        button(S.of(context).dashboard, DepartmentDashboardScreen()),
      if (ServicesModuleAccess.canApproveAndReject)
        button(S.of(context).approvals, ApprovalToggle()),
    ];
    final List<Widget> rows = [];
    for (int i = 0; i < buttons.length; i += 2) {
      rows.add(
        Row(
          spacing: 8.sp,
          children: [
            Expanded(child: buttons[i]),
            Expanded(
              child: i + 1 < buttons.length
                  ? buttons[i + 1]
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return Column(spacing: 8.sp, children: rows);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isMobile) _phoneActionGrid(context),
        if (!widget.isMobile) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.isMobile
                  ? (ServicesModuleAccess.canViewRequestedServices
                      ? customButton(
                          title: S.of(context).requestedServices,
                          function: () {
                            navigateTo(
                              context,
                              const EmployeeServicesScreen(),
                            );
                          },
                          textStyle: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.textButton,
                            letterSpacing: .23213123,
                          ),
                          width: widget.isMobile ? 160.w : 180.w,
                          height: 38.h,
                          radius: 8.r,
                          color: AppColors.primary,
                        )
                      : const SizedBox.shrink())
                  : Expanded(child: widget.filterWidget(widget.allServices)),
              widget.isMobile ? Spacer() : SizedBox(width: 10.w),

              // ✅ FIX: this row and the Dashboard/Approvals row below it form a
              // 2x2 grid, but each used its own widths and gutter (135/170 with
              // a 20.w gap here, 134/135 with a 15.sp gap there), so the columns
              // did not line up. Both now read from HomeServicesActionButtons.
              widget.isMobile || !ServicesModuleAccess.canMasterBulkUpload
                  ? const SizedBox.shrink()
                  : customButton(
                      title: S.of(context).masterUpload,
                      function: () {
                        navigateTo(context, const MasterUploadToggle());
                      },
                      textStyle: HomeServicesActionButtons.labelStyle(context),
                      // exactWidth, not width — customButton discards `width`.
                      //
                      // Bug report p.37: without Admin Dashboard beside it this
                      // button kept the LEADING column's width plus the gutter
                      // after it, so it stopped short of the Approvals / Create
                      // Service edge below. Alone, it takes the trailing column.
                      exactWidth: ServicesModuleAccess.canViewAdminDashboard
                          ? HomeServicesActionButtons.leadingWidth(context)
                          : HomeServicesActionButtons.trailingWidth(context),
                    ),

              // Gutter only exists BETWEEN two buttons — otherwise the lone
              // button was pushed off the trailing edge by a phantom gap.
              widget.isMobile ||
                      !ServicesModuleAccess.canMasterBulkUpload ||
                      !ServicesModuleAccess.canViewAdminDashboard
                  ? const SizedBox.shrink()
                  : SizedBox(width: HomeServicesActionButtons.columnGap),

              if (ServicesModuleAccess.canViewAdminDashboard)
                customButton(
                  title: S.of(context).adminDashboard,
                  function: () {
                    navigateTo(context, AdminDashboardPage());
                  },
                  textStyle: widget.isMobile
                      ? StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.textButton,
                        )
                      : HomeServicesActionButtons.labelStyle(context),
                  // On phones the grid collapses, so let ButtonSizing decide.
                  exactWidth: widget.isMobile
                      ? null
                      : HomeServicesActionButtons.trailingWidth(context),
                  color: AppColors.primary,
                ),
            ],
          ),
          SizedBox(height: 15.sp),
          widget.approvalAndServicesRequest(context),
          SizedBox(height: 15.sp),
          Row(
            children: [
              // Approval
              widget.isMobile && ServicesModuleAccess.canApproveAndReject
                  ? customButton(
                      title: S.of(context).approvals,
                      function: () {
                        navigateTo(context, ApprovalToggle());
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: widget.isMobile ? 160.w : 135.w,
                      height: 38.h,
                      radius: 8.r,
                      color: AppColors.primary,
                    )
                  : SizedBox(),
            ],
          ),
        ],
        widget.isMobile ? SizedBox(height: 15.sp) : SizedBox(),
        widget.isMobile
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: widget.filterWidget(widget.allServices),
              )
            : SizedBox(),
        widget.isMobile ? SizedBox(height: 15.sp) : SizedBox(),
        ManagementActionButtons(
          isMobile: widget.isMobile,
          searchController: widget.searchController,
        ),
        SizedBox(height: 10.sp),
        _buildViewToggleRow(context),
        SizedBox(height: 10.sp),
        _buildContentView(context),
        SizedBox(height: 10.sp),
      ],
    );
  }

  // W03: presentation never calls Firestore — delegate to the repository.
  Future<Map<String, dynamic>?> selectServiceProvider(String serviceId) {
    return ServicesManagerCubit.get(context)
        .repository
        .selectServiceProvider(serviceId);
  }

  var selectedIndex = 1;
  Widget _buildViewToggleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (ServicesModuleAccess.canExportService) _buildExportButton(context),
        widget.isMobile ? SizedBox() : _buildViewToggleButtons(context),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // W04: no try/catch in the widget — _resolveProviders is guarded and the
        // repository owns its own error handling.
        final exportProviders = await _resolveProviders(widget.filteredModel);
        if (!context.mounted) return;

        // Open export dialog with populated data
        await showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: '',
          barrierColor: AppColors.black.withValues(alpha: 0.54),
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return ExportDialog(
              filteredModel: widget.filteredModel,
              selectedProviders: exportProviders,
              formatStartDate: widget.formatStartDate,
            );
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 0 : 8.sp),
        child: Container(
          width: widget.isMobile ? 38.sp : 100.sp,
          height: 38.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: widget.isMobile
              ? Center(
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                    fit: BoxFit.scaleDown,
                    width: 20.sp,
                    height: 20.sp,
                    color: AppColors.textButton,
                    semanticsLabel: 'Export',
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSvgImage.natural(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                      fit: BoxFit.scaleDown,
                      width: 20.sp,
                      height: 20.sp,
                      color: AppColors.textButton,
                      semanticsLabel: 'Export',
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).export,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildViewToggleButtons(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () => _handleToggleView(false),
          child: Container(
            width: 38.sp,
            height: 38.sp,
            decoration: BoxDecoration(
              color:
                  !widget.isGridViewChoose ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: CustomSvgImage.natural(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_action_list_bulleted.svg",
                width: 20.sp,
                height: 20.sp,
                fit: BoxFit.scaleDown,
                semanticsLabel: 'Table View',
                color: !widget.isGridViewChoose
                    ? AppColors.textButton
                    : AppColors.text,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.sp),
        GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () => _handleToggleView(true),
          child: Container(
            width: 38.sp,
            height: 38.sp,
            decoration: BoxDecoration(
              color:
                  widget.isGridViewChoose ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: CustomSvgImage.natural(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_nav_grid.svg",
                width: 20.sp,
                height: 20.sp,
                fit: BoxFit.scaleDown,
                semanticsLabel: 'Grid View',
                color: widget.isGridViewChoose
                    ? AppColors.textButton
                    : AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentView(BuildContext context) {
    if (widget.filteredModel.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomEmptyState(
              lottiePath: ServicesLottie.emptyState,
              size: 300,
              verticalPadding: 0,
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _flipController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_flipController.value * 0.2), // Scale from 0.8 to 1.0
          child: Opacity(
            opacity: _flipController.value,
            child: BounceSwitcher(
              triggerValue: widget.isGridViewChoose,
              child: _buildView(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildView(BuildContext context) {
    if (widget.isGridViewChoose) {
      return _buildGridView(context);
    } else {
      // 🔥 FIXED: Use _loadedProviders instead of widget.selectedProviders
      return ServiceTableWidget(
        filteredModel: widget.filteredModel,
        selectedProviders: _loadedProviders,
      );
    }
  }

  Widget _buildGridView(BuildContext context) {
    // Local Firestore counts take precedence over the parent-provided map.
    final mergedDoneCounts = <String, int>{
      ...widget.doneServicesCount,
      ..._loadedDoneServicesCount,
    };

    return AnimatedCustomGridView(
      itemCount: widget.filteredModel.length,
      crossAxisCount: CrossAxisCountHelperResponsive
          .getCrossAxisCountForDefaultTabletResponsive(
        context,
      ),
      mainAxisExtent: 85.sp,
      mainAxisSpacing: 15.sp,
      crossAxisSpacing: 15.sp,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      animationDuration: const Duration(
        milliseconds: 800,
      ), // Duration for each card
      staggerDelay: const Duration(milliseconds: 100), // Delay between cards
      curve: Curves.easeOutCubic,
      itemBuilder: (context, index) {
        final service = widget.filteredModel[index];
        final duration = service.currentDurationOfServices;
        final unit = widget.getLocalizedDurationUnit(
          context,
          service.currentSelectedDurationUnit,
        );

        return ServiceGridCard(
          service: service,
          duration: duration,
          unit: unit,
          formatStartDate: widget.formatStartDate,
          doneServicesCount: mergedDoneCounts,
        );
      },
    );
  }
}
