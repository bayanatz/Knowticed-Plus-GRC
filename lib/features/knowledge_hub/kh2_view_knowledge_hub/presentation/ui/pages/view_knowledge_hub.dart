/// Module: knowledge_hub / presentation / s2_view_knowledge_hub / view_knowledge_hub.dart
/// ************************* FILE INFO *************************** ///
/// File Name: view_knowledge_hub.dart
/// Description: Contains different sizes of displaying data of app.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/layout/responsive_card_grid.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_state.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/ui/pages/view_knowledge_details.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/approvals_button.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/dashboard_button.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/departments_list_view.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/file_card.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/submissions_button.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh2_view_knowledge_hub/presentation/ui/widgets/build_search_section.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh2_view_knowledge_hub/presentation/ui/widgets/inner_list_view.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part 'view_knowledge_hub.sections.dart';

class ViewKnowledgeHub extends StatefulWidget {
  const ViewKnowledgeHub({super.key});

  @override
  State<ViewKnowledgeHub> createState() => _ViewKnowledgeHubState();
}

class _ViewKnowledgeHubState extends State<ViewKnowledgeHub>
    with TickerProviderStateMixin, _ViewKnowledgeHubSections {
  @override
  void initState() {
    super.initState();

    // ✅ Initialize animation controller - 1 SECOND DURATION
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize employee controller first
    _initializeEmployeeController();

    // IMPORTANT: Delay data initialization to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  Widget _buildHeaderButtons() {
    final bool canApprove = KnowledgeHubAccess.has(
      section: KnowledgeHubPermissionsSections.approval,
      permission: null,
    );
    final bool canDashboard = KnowledgeHubAccess.has(
      section: KnowledgeHubPermissionsSections.dashboard,
      permission: null,
    );
    final bool canSubmissions = KnowledgeHubAccess.has(
      section: KnowledgeHubPermissionsSections.submissions,
      permission: null,
    );
    // Owner 21/10/2026: the two demo-data buttons (Seed sample knowledge / Backfill visibility) are removed from the header; their services stay.
    final Widget rightGroup = Wrap(
      alignment: WrapAlignment.end,
      runSpacing: 8.sp,
      children: [if (canSubmissions) submissionsButton(context)],
    );
    final bool hasRightGroup = canSubmissions;

    if (!canDashboard) {
      if (!canApprove && !hasRightGroup) return const SizedBox.shrink();
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (canApprove) approvalsButton(context),
          const Spacer(),
          if (hasRightGroup) Flexible(child: rightGroup),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (canApprove) approvalsButton(context) else const SizedBox(),
            dashboardButton(context),
          ],
        ),
        if (hasRightGroup) ...[
          SizedBox(height: 5.h),
          Align(alignment: AlignmentDirectional.centerEnd, child: rightGroup),
        ],
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _gridAnimationController.dispose(); // ✅ DISPOSE CONTROLLER
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    var isHasPermission = KnowledgeHubAccess.has(
      section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
      permission: null,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // top: false — the app shell header already sits under the status bar;
      // the extra inset pushed the page title down (KH vertical report p.1/3/5/12/21).
      body: SafeArea(
        top: false,
        child: _buildEmployeeDataWrapper(
          child: SideFrameMasterServices(
            titleText: S.of(context).knowledge_hub,
            child: BlocListener<CreateKnowledgeCubit, CreateKnowledgeState>(
              listener: _handleStateChanges,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // KH large-screen report p.31: with
                    // no Dashboard button, Approvals sat alone on one line
                    // and Submissions alone on the next, leaving an empty
                    // band. The header is now built once from what the user
                    // may see: Dashboard present → Approvals|Dashboard, then
                    // Submissions under Dashboard (unchanged); no Dashboard →
                    // Approvals and Submissions on ONE line.
                    _buildHeaderButtons(),
                    SizedBox(height: 20.h),
                    isHasPermission == false
                        ? SizedBox(
                            width: 400,
                            height: 400,
                            child: Center(
                              child: CustomEmptyState(
                                lottiePath:
                                    'assets/lottie_assets/main_lottie_assets/lot_empty_no_data.json',
                                size: 400,
                                verticalPadding: 0,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              _buildDepartmentsWithCache(),
                              SizedBox(height: 20.h),
                              _buildSearchRow(),
                              SizedBox(height: 10.h),
                              Builder(
                                builder: (context) {
                                  return innerListView(
                                    context,
                                    isMobile: isMobile,
                                    isLightMode: isLightMode,
                                    innerIndex: innerIndex,
                                  );
                                },
                              ),
                              SizedBox(height: 10.sp),

                              // KH-CREATE-21: say how many documents could not be
                              // read, instead of dropping them silently.
                              _buildUnreadableNotice(),
                              // ✅ ANIMATED KNOWLEDGE ITEMS GRID
                              _buildKnowledgeGrid(),
                              SizedBox(height: 20.h),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Search field and the filter button.
  Widget _buildSearchRow() {
    return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
      builder: (context, state) {
        final departments = state is FetchingDepartmentSuccessState
            ? state.departmentList
            : _cachedDepartments;

        return Row(
          children: [
            AppSearchTextField(
              controller: searchController,
              onChanged: (query) {
                context.read<CreateKnowledgeCubit>().searchKnowledge(query);
              },
              fillColor: AppColors.card,
            ),
            SizedBox(width: ButtonSizing.toolbarGap(context)),
            filterSection(
              context,
              searchController: searchController,
              departments: departments,
            ),
          ],
        );
      },
    );
  }

  /// KH-CREATE-21: how many documents could not be read, instead of dropping them silently.
  Widget _buildUnreadableNotice() {
    return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
      builder: (context, _) {
        final int unreadable =
            context.read<CreateKnowledgeCubit>().unreadableDocuments;
        if (unreadable == 0) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 8.sp),
          child: Text(
            '${S.of(context).unreadableDocuments} $unreadable',
            style: StyleText.fontSize12Weight500.copyWith(
              color: AppColors.orange,
            ),
          ),
        );
      },
    );
  }

  /// The documents grid with its loading, error and empty states.
  Widget _buildKnowledgeGrid() {
    return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
      buildWhen: (previous, current) =>
          current is FetchingKnowledgeLoadingState ||
          current is FetchingKnowledgeErrorState ||
          current is FetchingKnowledgeEmptyState ||
          current is FetchingKnowledgeSuccessState ||
          current is ChangedIndexSuccessState ||
          current is ChangedInnerIndexSuccessState,
      builder: (context, state) {
        khLog('📊 Current State: $state', name: 'VIEW_KNOWLEDGE_HUB');

        final cubit = context.read<CreateKnowledgeCubit>();

        bool hasCompletedFetch = state is FetchingKnowledgeSuccessState ||
            state is FetchingKnowledgeEmptyState ||
            state is FetchingKnowledgeErrorState;
        if (hasCompletedFetch) _hubFetchedOnce = true;

        if (state is FetchingKnowledgeLoadingState) {
          return _buildHubLoader();
        }

        if (state is FetchingKnowledgeErrorState) {
          khLog('❌ Error State: ${state.error}', name: 'VIEW_KNOWLEDGE_HUB');
          return _buildHubError();
        }

        if (state is FetchingKnowledgeEmptyState ||
            (hasCompletedFetch && cubit.filteredKnowledge.isEmpty)) {
          khLog(
            '📭 Empty State - No approved documents found',
            name: 'VIEW_KNOWLEDGE_HUB',
          );
          return _buildHubEmpty();
        }

        // ✅ BUILD ANIMATED GRID
        if (state is FetchingKnowledgeSuccessState ||
            cubit.filteredKnowledge.isNotEmpty) {
          final knowledgeList = state is FetchingKnowledgeSuccessState
              ? state.knowledgeList
              : cubit.filteredKnowledge;

          khLog(
            '✅ Success State: ${knowledgeList.length} items',
            name: 'VIEW_KNOWLEDGE_HUB',
          );

          if (knowledgeList.isEmpty) {
            return _buildHubNoData();
          }

          return _buildAnimatedGrid(knowledgeList);
        }

        // 14/10/2026 — KH mobile report p.1 "why the svg
        // show first then the cards appear after it": this
        // fallback runs BEFORE the first fetch has answered
        // (initial / tab-change states with no data yet), so
        // "empty" flashed up and was then replaced by the
        // cards. Until a fetch has completed it is a loader.
        if (!hasCompletedFetch && !_hubFetchedOnce) {
          return _buildHubLoader();
        }

        khLog(
          '📭 No state match and no data - showing empty',
          name: 'VIEW_KNOWLEDGE_HUB',
        );
        return _buildHubFallbackEmpty();
      },
    );
  }

  /// One animated card of the grid; opens the document on tap.
  Widget _buildGridItem(CreateKnowledgeModel knowledge, int index) {
    final fileUrl = knowledge.currentDocumentUrl;
    final fileType = knowledge.currentDocumentExtension;

    final DateTime? publishedAt = knowledge.publishedAt;
    final String publishDate = publishedAt == null
        ? '-'
        : KhLocale.formatDate(context, publishedAt, 'dd MMM yyyy');
    // (department name resolved on the card)
    //

    // ✅ WRAP WITH ANIMATED TRANSITIONS
    return SlideTransition(
      position: _slideAnimations.length > index
          ? _slideAnimations[index]
          : AlwaysStoppedAnimation(Offset.zero),
      child: FadeTransition(
        opacity: _fadeAnimations.length > index
            ? _fadeAnimations[index]
            : AlwaysStoppedAnimation(1.0),
        child: GestureDetector(
          onTap: () {
            HapticController.low(); // list row: on the tap (X-117)
            khLog(
              '👆 Tapped on: ${knowledge.currentNameEnglish}',
              name: 'NAVIGATION',
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                // The file picker the comment box uses is injected here.
                builder: (context) =>
                    RepositoryProvider<MediaPickerService>.value(
                  value: KnowledgeHubDI.mediaPicker,
                  child: ViewKnowledgeDetails(
                    emailUser: knowledge.createdByEmail.lastOrNull!,
                    knowledgeId: knowledge.currentKnowledgeId,
                    documentName: knowledge.currentNameEnglish,
                    documentNameAr: knowledge.currentNameArabic,
                    publishDate: publishDate,
                    documentType: knowledge.currentKnowledgeDocumentType,
                    owningDepartment: knowledge.currentOwningDepartment,
                    documentEnglishDescription:
                        knowledge.currentDescriptionEnglish,
                    documentEnglishDescriptionAr:
                        knowledge.currentDescriptionArabic,
                    fileType: fileType,
                    fileUrl: fileUrl,
                    documentExtension: knowledge.currentDocumentExtension,
                  ),
                ),
              ),
            ).then((Object? removed) {
              // The details page pops
              // `true` after a removal; refetch
              // so the removed card leaves the
              // grid now, not after a re-login.
              if (removed == true && mounted) {
                if (!context.mounted) return;
                context.read<CreateKnowledgeCubit>().fetchAllKnowledge();
              }
            });
          },
          child: fileCard(
            context,
            knowledge: knowledge,
            currentUserEmail:
                context.read<CreateKnowledgeCubit>().people.signedInEmail,
          ),
        ),
      ),
    );
  }

  /// Load failed: a translated message and Retry (KH-CREATE-21).
  Widget _buildHubError() {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.r, color: AppColors.red),
            SizedBox(height: 16.h),
            Text(
              S.of(context).errorLoadingData,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16.h),
            customButton(
              function: () {
                khLog('🔄 Retrying fetch...', name: 'VIEW_KNOWLEDGE_HUB');
                context.read<CreateKnowledgeCubit>().fetchAllKnowledge();
              },
              title: S.of(context).retry,
            ),
          ],
        ),
      ),
    );
  }

  /// No document to show.
  Widget _buildHubEmpty() {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomEmptyState(
              lottiePath:
                  'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
              size: 200,
              verticalPadding: 0,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  /// The list came back empty.
  Widget _buildHubNoData() {
    return SizedBox(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomEmptyState(
              lottiePath:
                  'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
              size: 200,
              verticalPadding: 0,
            ),
            SizedBox(height: 16.h),
            Text(
              S.of(context).noDataAvailable,
              style: StyleText.fontSize16Weight400.copyWith(
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The animated grid of document cards.
  Widget _buildAnimatedGrid(List<CreateKnowledgeModel> knowledgeList) {
    // Create the animations once per list size.
    if (!_animationsCreated ||
        _slideAnimations.length != knowledgeList.length) {
      _createSlideAnimations(knowledgeList.length);
      // Play animation after creation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playGridAnimation();
      });
    }

    final int crossAxisCount =
        CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);
    final double crossAxisSpacing = 10.sp;
    final double mainAxisSpacing = 10.sp;

    // Cell height comes from what the card's content
    // actually needs (its text rows, gaps, padding and
    // thumbnail) — not from the cell width — so the
    // card stays compact on desktop and on mobile.
    final double cardHeight = ResponsiveCardHeight.forListCard(
      context,
      thumbnailHeight: 45.h,
    );

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: ResponsiveCardHeight.delegate(
        crossAxisCount: crossAxisCount,
        cardHeight: cardHeight,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      shrinkWrap: true,
      itemCount: knowledgeList.length,
      itemBuilder: (context, index) =>
          _buildGridItem(knowledgeList[index], index),
    );
  }

  /// Spinner while the documents load.
  Widget _buildHubLoader() {
    return SizedBox(
      height: 200.h,
      child: Center(child: CircleProgressMaster()),
    );
  }

  /// Shown when no state applies and there is no data.
  Widget _buildHubFallbackEmpty() {
    return SizedBox(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomEmptyState(
              lottiePath:
                  'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
              verticalPadding: 0,
            ),
          ],
        ),
      ),
    );
  }
}
