/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets/approvals_screen.sections
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_screen_sections_logic.dart
/// Description: Logic and event handlers of `_ApprovalsScreenSections` — split out of `approvals_screen.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/approvals_screen.dart';

// Split from approvals_screen.sections.dart to keep every file under 700 lines.

extension _ApprovalsScreenSectionsLogic on _ApprovalsScreenSections {
  /// Show approval confirmation dialog
  void _showApproveConfirmationDialog(
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
                  'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                  height: 70.h,
                  width: 70.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  S.of(context).approveRequest,
                  style: StyleText.fontSize20Weight500,
                ),
                SizedBox(height: 18.h),
                Text(
                  S.of(context).areYouSureYouWantToApproveRequest,
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
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.onSecondaryAction,
                        ),
                        width: 135.w,
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
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: 135.w,
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(ctx);
                          showAppDialog(
                            barrierDismissible: true,
                            builder: (dialogContext) => BlocProvider.value(
                              value: context.read<ApprovalsCubit>(),
                              child: ReasonForJustificationsDialog(
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
}
