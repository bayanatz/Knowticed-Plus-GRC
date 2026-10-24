/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: reason_for_justifications_dialog.dart
/// Description: Reason for justifications dialog — Approvals Details (S7) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/widgets/approvals_error_text.dart';
import 'package:flutter/material.dart';
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
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ReasonForJustificationsDialog extends StatefulWidget {
  final String knowledgeId;

  const ReasonForJustificationsDialog({super.key, required this.knowledgeId});

  @override
  State<ReasonForJustificationsDialog> createState() =>
      _ReasonForJustificationsDialogState();
}

class _ReasonForJustificationsDialogState
    extends State<ReasonForJustificationsDialog> {
  final TextEditingController _justificationController =
      TextEditingController();

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext parentContext) {
    final isMobile = ContextExtension(parentContext).isPhone;
    final lightMode = Theme.of(parentContext).brightness == Brightness.light;

    showAppDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Auto-close after 2 seconds using the dialogContext directly
        Future.delayed(Duration(seconds: 2), () {
          if (!dialogContext.mounted) return;
          if (Navigator.of(dialogContext).canPop()) {
            if (!dialogContext.mounted) return;
            Navigator.of(dialogContext).pop();
          }
        });

        return KhLocale.inUiLanguage(
          parentContext,
          () => Center(
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
                      'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                      height: 100.h,
                      width: 100.w,
                      repeat: false,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      S.of(parentContext).khDocumentApproved,
                      style: StyleText.fontSize20Weight500,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      S.of(parentContext).khDocumentApprovedBody,
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
        );
      },
    );
  }

  void _showErrorDialog(BuildContext parentContext, String error) {
    final isMobile = ContextExtension(parentContext).isPhone;
    final lightMode = Theme.of(parentContext).brightness == Brightness.light;

    showAppDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (ctx) => KhLocale.inUiLanguage(
        parentContext,
        () => Center(
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
                  Icon(Icons.error_outline, color: AppColors.red, size: 64.sp),
                  SizedBox(height: 20.h),
                  Text(
                    S.of(parentContext).khApprovalFailed,
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
                  SizedBox(height: 20.h),
                  customButton(
                    title: S.of(parentContext).ok,
                    height: 38.h,
                    function: () {
                      Navigator.of(ctx).pop();
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

  /// Closes this dialog and shows the result (success or error) on the page.
  void _onApprovalsState(BuildContext context, ApprovalsStates state) {
    if (state is ApprovingKnowledgeSuccessState) {
      // Close the justification dialog, then confirm on the page below.
      // The page context is taken BEFORE the pop: this dialog's own
      // context is being torn down by then.
      final NavigatorState navigator = Navigator.of(context);
      final BuildContext pageContext = navigator.context;
      navigator.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog(pageContext);
      });
    } else if (state is ApprovingKnowledgeErrorState) {
      final NavigatorState navigator = Navigator.of(context);
      final BuildContext pageContext = navigator.context;
      final String message = KhLocale.inUiLanguage(
        context,
        () => state.key.text(context, detail: state.error),
      );
      navigator.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(pageContext, message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApprovalsCubit, ApprovalsStates>(
      listener: _onApprovalsState,
      child: Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            ),
            padding: EdgeInsets.all(15.r),
            margin: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                _buildHeader(),

                SizedBox(height: 15.h),

                // Text field
                CustomValidatedTextFieldMaster(
                  label: S.of(context).justifications,
                  hint: S.of(context).textHere,
                  controller: _justificationController,
                  height: 72,
                  showCharCount: true,
                  textDirection: Directionality.of(context),
                  maxLines: 3,
                  showFocusBorder: false,
                  checkLanguage: false,
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: 15.h),

                // Submit button with BlocBuilder for loading state
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Check icon and the dialog title.
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: AppColors.textButton, size: 20.sp),
        ),
        SizedBox(width: 8.w),
        Text(
          S.of(context).approvalJustification,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      ],
    );
  }

  /// Submit button; disabled while saving or while the text is invalid.
  Widget _buildSubmitButton() {
    return BlocBuilder<ApprovalsCubit, ApprovalsStates>(
      builder: (context, state) {
        final isLoading = state is ApprovingKnowledgeLoadingState;
        final bool canSubmit =
            !isLoading &&
            isJustificationValid(
              _justificationController.text,
              Directionality.of(context),
            );

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            customButton(
              title: S.of(context).submit,
              width: 150.w,
              height: 38.h,
              color: canSubmit
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.4),
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: canSubmit
                    ? AppColors.textButton
                    : AppColors.textButton.withValues(alpha: 0.5),
              ),
              function: !canSubmit
                  ? () {}
                  : () {
                      final justification = _justificationController.text
                          .trim();

                      // Call the approve method
                      context.read<ApprovalsCubit>().approveKnowledge(
                        knowledgeId: widget.knowledgeId,
                        approvalJustification: justification,
                      );
                    },
            ),
          ],
        );
      },
    );
  }
}
