/// Module: knowledge_hub/kh6_approvals/presentation/ui/pages
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_screen.dart
/// Description: Approvals screen — Approvals (S6) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_error_state.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/approvals_document_card.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/search_approvals.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/status_list.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/approvals_error_text.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/pages/approvals_details_screen.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/reason_for_justifications_dialog.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/reason_for_approval_removing_dialog.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part 'approvals_screen.sections.dart';
part '../widgets/approvals_screen.sections/approvals_screen_sections_builders.dart';
part '../widgets/approvals_screen.sections/approvals_screen_sections_logic.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen>
    with TickerProviderStateMixin, _ApprovalsScreenSections {
  // ---- fields & helpers moved to _ApprovalsScreenSections (approvals_screen.sections.dart) ----

  @override
  void initState() {
    super.initState();

    // Initialize animation controller - 1 SECOND DURATION
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // 1 second
      vsync: this,
    );

    // Use Future.microtask to ensure context is available
    Future.microtask(() {
      _initializeApprovals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SideFrameMasterServices(
          titleText: S.of(context).knowledge_hub,
          secondTitle: S.of(context).approvals,
          onFirstTap: () => Navigator.of(context).pop(),
          child: BlocListener<ApprovalsCubit, ApprovalsStates>(
            listener: (context, state) {
              _handleIndexChanges(context, state);

              if (state is ApprovalsInitial && !_isInitialized) {
                Future.microtask(() => _initializeApprovals());
              }
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Status List
                  BlocBuilder<ApprovalsCubit, ApprovalsStates>(
                    builder: (context, state) {
                      return statusList(
                        context,
                        isMobile: isMobile,
                        selectedIndex: selectedIndex,
                      );
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Search
                  SearchApprovals(
                    key: ValueKey(_currentSelectedDepartment ?? 'all'),
                    searchApprovalsController: searchApprovalsController,
                  ),

                  SizedBox(height: 15),

                  // Documents View with loading state
                  _buildDocumentsView(isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Queue grid with its loading, error, empty and unreadable-count states.
  Widget _buildDocumentsView(bool isMobile) {
    return BlocBuilder<ApprovalsCubit, ApprovalsStates>(
      builder: (context, state) {
        if (state is FetchingApprovalsLoadingState ||
            state is ApprovingKnowledgeLoadingState ||
            state is RejectingKnowledgeLoadingState ||
            state is FetchingCommentsLoadingState ||
            state is AddingCommentLoadingState ||
            state is RecordFileActionLoading) {
          return _buildLoadingState();
        }

        if (state is FetchingApprovalsErrorState) {
          return _buildErrorState(state);
        }

        if (state is FetchingApprovalsEmptyState) {
          return _buildEmptyState();
        }

        if (state is FetchingApprovalsSuccessState) {
          if (state.approvals.isEmpty) {
            return _buildEmptyState();
          }
          final int unreadable = context
              .read<ApprovalsCubit>()
              .unreadableDocuments;
          if (unreadable == 0) {
            return buildApprovalsGrid(context, isMobile);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.sp),
                child: Text(
                  '${S.of(context).approvalsUnreadableDocs} $unreadable',
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.orange,
                  ),
                ),
              ),
              buildApprovalsGrid(context, isMobile),
            ],
          );
        }

        if (!_isInitialized) {
          return _buildLoadingState();
        }

        return _buildLoadingState();
      },
    );
  }

  @override
  void dispose() {
    searchApprovalsController.dispose();
    _gridAnimationController.dispose();
    super.dispose();
  }
}
