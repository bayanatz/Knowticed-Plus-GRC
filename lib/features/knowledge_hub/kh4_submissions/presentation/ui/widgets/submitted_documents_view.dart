/// Module: knowledge_hub/kh4_submissions/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: submitted_documents_view.dart
/// Description: Submitted documents view — Submissions (S4) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_error_state.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/shared_functions/get_file_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';

import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/pages/submission_details_screen.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part 'submitted_documents_view/get_date_info_by_status.dart';
part 'submitted_documents_view/get_status_display.dart';
part 'submitted_documents_view/submitted_documents_view_builders.dart';

// CONVERT TO STATEFUL WIDGET
class SubmittedDocumentsView extends StatefulWidget {
  final bool isMobile;

  const SubmittedDocumentsView({super.key, required this.isMobile});

  @override
  State<SubmittedDocumentsView> createState() => _SubmittedDocumentsViewState();
}

class _SubmittedDocumentsViewState extends State<SubmittedDocumentsView>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _gridAnimationController;
  final List<Animation<Offset>> _slideAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];
  bool _animationsCreated = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller - 1 SECOND DURATION
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // 1 second
      vsync: this,
    );
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    super.dispose();
  }

  // CREATE HORIZONTAL STAGGERED ANIMATIONS
  void _createSlideAnimations(int itemCount) {
    _slideAnimations.clear();
    _fadeAnimations.clear();

    for (int i = 0; i < itemCount; i++) {
      // Stagger delay: 40ms between each item
      final delay = i * 0.04;

      // HORIZONTAL Slide animation from LEFT
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

  // PLAY ANIMATION
  void _playGridAnimation() {
    if (_gridAnimationController.isAnimating) return;
    _gridAnimationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubmissionsCubit, SubmissionsStates>(
      builder: (context, state) {
        if (state is FetchingSubmissionsLoadingState) {
          return _buildLoadingState();
        } else if (state is FetchingSubmissionsEmptyState) {
          return _buildEmptyState(context);
        } else if (state is FetchingSubmissionsErrorState) {
          return _buildErrorState(context, state);
        } else {
          return _buildSubmissionsGrid(context, widget.isMobile);
        }
      },
    );
  }

  /// 14/10/2026 — KH large-screen report p.12 & p.24: the loader and the
  /// empty animation sat at the TOP of the area, and the animation was a
  /// different size from every other empty screen. This view lives inside the
  /// page's scroll view (unbounded height), so `Center` alone only centred
  /// horizontally. Every state now gets the same half-screen box the Approvals
  /// page uses, and the empty states use the app's one [CustomEmptyState].
  Widget _centeredBox(Widget child) => SizedBox(
    height: MediaQuery.of(context).size.height * 0.5,
    child: Center(child: child),
  );

  Widget _buildLoadingState() {
    return _centeredBox(CircleProgressMaster());
  }

  Widget _buildEmptyState(BuildContext context) {
    return _centeredBox(const CustomEmptyState());
  }

  /// A failed load shows an error with Retry, never "no documents"
  /// (KH-CREATE-21).
  Widget _buildErrorState(
    BuildContext context,
    FetchingSubmissionsErrorState state,
  ) {
    return _centeredBox(
      CustomErrorState(
        title: S.of(context).errorLoadingSubmissions,
        onRetry: () => context.read<SubmissionsCubit>().fetchMySubmissions(),
      ),
    );
  }

  Widget _buildNoFilterResultsState(BuildContext context) {
    return _centeredBox(const CustomEmptyState());
  }
}

// HELPER FUNCTIONS (keep all existing helper functions)

DateTime? _getTimestampDate(int? timestamp) {
  return timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(timestamp)
      : null;
}
