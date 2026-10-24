/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/submission_details_contents
///
///*************************** FILE INFO ****************************///
/// File Name: published_content.dialog.dart
/// Description: `ReasonForRemovingDialog` widget, state and UI of the `ReasonForRemovingDialog` widget — split out of `published_content.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'published_content.dart';

/// Reason-for-removing dialog (split from published_content.dart, §7).

class ReasonForRemovingDialog extends StatefulWidget {
  final String documentId;
  final String currentUserEmail;

  const ReasonForRemovingDialog({
    super.key,
    required this.documentId,
    required this.currentUserEmail,
  });

  @override
  State<ReasonForRemovingDialog> createState() =>
      _ReasonForRemovingDialogState();
}

class _ReasonForRemovingDialogState extends State<ReasonForRemovingDialog> {
  final TextEditingController _justificationController =
      TextEditingController();

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  void _showFailure(BuildContext context, KnowledgeRemovalError error) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      title: S.of(context).errorOccurred,
      subtitle: error == KnowledgeRemovalError.notFound
          ? S.of(context).khDocumentNotFound
          : S.of(context).khRemoveDocumentFailed,
      closeAfter: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<KnowledgeRemovalCubit>(
      create: (_) => KnowledgeHubDI.knowledgeRemovalCubit(),
      child: BlocConsumer<KnowledgeRemovalCubit, KnowledgeRemovalState>(
        listener: (context, state) {
          if (state is KnowledgeRemovalSuccess) {
            // The parent refreshes when the dialog returns true.
            Navigator.of(context).pop(true);
          } else if (state is KnowledgeRemovalFailure) {
            _showFailure(context, state.error);
          }
        },
        builder: (context, state) =>
            _buildDialog(context, state is KnowledgeRemovalLoading),
      ),
    );
  }

  Widget _buildDialog(BuildContext context, bool isLoading) {
    final isMobile = ContextExtension(context).isPhone;

    return Center(
      child: Material(
        color: AppColors.transparent,
        child: Container(
          width: isMobile ? double.infinity : 539,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.card,
          ),
          padding: EdgeInsets.all(20.r),
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomSvgImage(
                        assetPath: "assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg",
                        color: AppColors.textButton,
                        width: 18.w,
                        height: 18.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    S.of(context).reasonOfRemoving,
                    style: StyleText.fontSize18Weight600,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).justifications,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  CustomValidatedTextField(
                    label: '',
                    hint: S.of(context).textHere,
                    controller: _justificationController,
                    textDirection: Directionality.of(context),
                    fillColor: AppColors.background,
                    height: 72.sp,
                    showCharCount: true,
                    maxLines: 3,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  isLoading
                      ? SizedBox(
                          width: 150.w,
                          height: 38.h,
                          child: Center(child: CircleProgressMaster()),
                        )
                      : customButton(
                          title: S.of(context).submit,
                          width: 150.w,
                          height: 38.h,
                          function: () =>
                              context.read<KnowledgeRemovalCubit>().remove(
                                documentId: widget.documentId,
                                currentUserEmail: widget.currentUserEmail,
                                justification: _justificationController.text,
                              ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
