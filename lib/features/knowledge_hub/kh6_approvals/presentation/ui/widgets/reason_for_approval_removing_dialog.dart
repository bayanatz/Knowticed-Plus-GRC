/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: reason_for_approval_removing_dialog.dart
/// Description: Reason for approval removing dialog — Approvals Details (S7) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/approvals_error_text.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/justification_validity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/custom_validated_text_field.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class ResonForApprovalRemovingDialog extends StatefulWidget {
  final String knowledgeId;
  const ResonForApprovalRemovingDialog({super.key, required this.knowledgeId});

  @override
  State<ResonForApprovalRemovingDialog> createState() =>
      _ResonForApprovalRemovingDialogState();
}

class _ResonForApprovalRemovingDialogState
    extends State<ResonForApprovalRemovingDialog> {
  final TextEditingController _justificationController =
      TextEditingController();

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  /// Closes this dialog on success, or shows the error over it.
  void _onApprovalsState(BuildContext context, ApprovalsStates state) {
    if (state is RejectingKnowledgeSuccessState) {
      final NavigatorState navigator = Navigator.of(context);
      final BuildContext pageContext = navigator.context;
      navigator.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog(pageContext);
      });
    } else if (state is RejectingKnowledgeErrorState) {
      _showErrorDialog(
        context,
        KhLocale.inUiLanguage(
          context,
          () => state.key.text(context, detail: state.error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    return BlocListener<ApprovalsCubit, ApprovalsStates>(
      listener: _onApprovalsState,
      child: Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            ),
            padding: EdgeInsets.all(15.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title).
                CustomDialogHeader(
                  title: S.of(context).reasonOfRejection,
                  icon:
                      "assets/icons_assets/main_icons_assets/ic_reason_reject.svg",
                ),

                SizedBox(height: 20.h),

                // Text field
                CustomValidatedTextField(
                  label: S.of(context).Justifications,
                  hint: S.of(context).textHere,
                  controller: _justificationController,
                  height: 72,
                  showCharCount: true,
                  maxLines: 3,
                  showFocusBorder: false,
                  checkLanguage: false,
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: 20.h),

                // Submit button with BlocBuilder for loading state
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Submit button; disabled while saving or while the reason is invalid.
  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: BlocBuilder<ApprovalsCubit, ApprovalsStates>(
        builder: (context, state) {
          final isLoading = state is RejectingKnowledgeLoadingState;
          final bool canSubmit = !isLoading &&
              isJustificationValid(
                _justificationController.text,
                ui.TextDirection.ltr,
              );

          return customButton(
            title: S.of(context).submit,
            width: 150.w,
            color: canSubmit
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.4),
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: canSubmit
                  ? AppColors.textButton
                  : AppColors.textButton.withValues(alpha: 0.5),
            ),
            height: 38.h,
            function: !canSubmit
                ? () {}
                : () {
                    final reason = _justificationController.text.trim();

                    // Call the reject method
                    context.read<ApprovalsCubit>().rejectKnowledge(
                          knowledgeId: widget.knowledgeId,
                          rejectionReason: reason,
                        );
                  },
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => KhLocale.inUiLanguage(
        context,
        () => Center(
          child: Material(
            color: AppColors.transparent,
            child: Container(
              width: isMobile ? double.infinity : 411.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.card,
              ),
              padding: EdgeInsets.all(20.r),
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                    height: 100.h,
                    width: 100.w,
                    repeat: true,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    S.of(context).documentFileRejected,
                    style: StyleText.fontSize20Weight500,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    S.of(context).documentRemoveSuccess,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    final isMobile = ContextExtension(context).isPhone;

    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => KhLocale.inUiLanguage(
        context,
        () => Center(
          child: Material(
            color: AppColors.transparent,
            child: Container(
              width: isMobile ? double.infinity : 411.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.card,
              ),
              padding: EdgeInsets.all(20.r),
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.red, size: 64.sp),
                  SizedBox(height: 20.h),
                  Text(
                    S.of(context).khRejectionFailed,
                    style: StyleText.fontSize20Weight500,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    error,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
