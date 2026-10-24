/// Module: core/helper/form_builder
///
/// FILE INFO
/// File Name   : app_dialogs.dart
/// Description: `AppDialogs`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Objective   : Public entry point for the form-builder dialogs. Holds the
///               small confirm/success dialogs directly and delegates the
///               large summary/share/filter dialogs to their own files
///               (one file per dialog, §7). Contains NO try/catch — error
///               handling lives in the cubits the dialogs render (§11.2).
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:knowticed_plus/core/helper/csv_helper.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/default_dialog.dart';
import 'package:knowticed_plus/features/form_builder/helpers/share_access_dialog.dart';
import 'package:knowticed_plus/features/form_builder/helpers/summary_open_access_dialog.dart';
import 'package:knowticed_plus/features/form_builder/helpers/summary_restricted_access_dialog.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_filter_dialog.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class AppDialogs {
  // Private constructor to prevent instantiation
  AppDialogs._();

  /// Method to show a dialog for creating a form
  static void creatingForm(
      BuildContext context, dynamic Function() onYesClicked) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).creatingForm,
        subTitle: S.of(context).areYouSureCreateForm,
        autoClose: false,
        // Bug report #10: approved lottie instead of the static check svg.
        lottieAsset:
            'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
        showButtons: true,
        onConfirm: onYesClicked,
      ),
    );
  }

  static void duplicateFormDialog(
    BuildContext context,
    String originalFormName,
    String originalArabicFormName,
    int duplicateVersion,
    dynamic Function(String newName, String newArabicName) onDuplicateClicked,
  ) {
    TextEditingController englishNameController = TextEditingController(
      text: '$originalFormName _$duplicateVersion',
    );

    TextEditingController arabicNameController = TextEditingController(
      text: '$originalArabicFormName _$duplicateVersion',
    );

    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        width: 615,
        customWidget: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15 row.
              CustomDialogHeader(
                  title: S.of(context).duplicateForm, icon: AppAssets.add),
              verticalSpace(20),
              Text(
                S.of(context).formName,
                style: StyleText.fontSize14Weight600,
              ),
              verticalSpace(8),
              CustomTextField(
                controller: englishNameController,
                label: S.of(context).englishName,
              ),
              verticalSpace(15),
              CustomTextField(
                controller: arabicNameController,
                label: S.of(context).arabicName,
              ),
              verticalSpace(25),
              // CHANGED: both buttons were `AppTextButton`. They are
              // `customButton` (core/custom/5) now, the same component every
              // other primary action in the app is built from, so this dialog
              // picks up ButtonSizing's height and radius and the app's own
              // haptic feedback instead of carrying its own 38/150/8.
              //
              // `width: 150` is kept — customButton honours an explicit width,
              // and the two buttons need to match each other across the row.
              // The text colour is NOT passed: customButton defaults to
              // AppColors.textButton, which is the contrast colour for the
              // theme, where the old `AppColors.black` was fixed and vanished
              // against a dark surface.
              Row(
                textDirection: TextDirection
                    .ltr, // X-73: Cancel left, action right in both languages

                children: [
                  customButton(
                    textColor: AppColors.text,
                    title: S.of(context).cancel,
                    width: 150,
                    color: AppColors.darkGrey,
                    function: () {
                      Get.back();
                    },
                  ),
                  const Spacer(),
                  customButton(
                    title: S.of(context).menuDuplicate,
                    width: 150,
                    color: AppColors.primary,
                    function: () {
                      String newEnglishName = englishNameController.text.trim();
                      String newArabicName = arabicNameController.text.trim();

                      if (newEnglishName.isEmpty) {
                        return;
                      }

                      Get.back();
                      onDuplicateClicked(newEnglishName, newArabicName);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        autoClose: false,
      ),
    );
  }

  static void creatingFormSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).formCreated,
      subtitle: S.of(context).youSuccessfullyCreatedThisForm,
    );
  }

  static Future<void> grantFormAccessSuccessfully(BuildContext context) async {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).grantAccessSuccessfully,
      subtitle: S.of(context).youGrantAccessSuccessfully,
    );
  }

  static Future<void> groupCreatedSuccessfully(BuildContext context) async {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).groupCreatedSuccessfully,
      subtitle: S.of(context).youSuccessfullyCreatedGroup,
    );
  }

  /// Submit confirmation AND the success dialog, in one flow — the same shape
  /// as [deleteForm].
  ///
  /// [submittingForm] + [submittingFormSuccessfully] left the
  /// caller to pop the confirm dialog by hand and to decide for itself when the
  /// success dialog was due, which is how a submission that failed at the
  /// repository could still report success.
  /// `CustomDialogManager.showDialogFlow` owns both steps: it closes the
  /// confirm dialog, awaits [onConfirm], and shows the success dialog ONLY when
  /// that returns true. [onConfirm] must NOT pop anything itself — the confirm
  /// dialog is already gone by the time it runs. [onSuccessComplete] runs after
  /// the success dialog has auto-closed, which is where navigation belongs.
  static Future<void> submitForm(
    BuildContext context,
    Future<bool> Function() onConfirm, {
    VoidCallback? onSuccessComplete,
  }) {
    return CustomDialogManager.showDialogFlow(
      context: context,
      // Bug report #17/#26: narrower submission dialog.
      confirmWidth: 411,
      confirmLottie: AppAssets.lottieConfirmation,
      confirmTitle: S.of(context).submissionForm,
      confirmSubtitle: S.of(context).areYouSureSubmitForm,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: onConfirm,
      successLottie: AppAssets.successful,
      successTitle: S.of(context).submitForm,
      successSubtitle: S.of(context).youSuccessfullySubmittedThisForm,
      onSuccessComplete: onSuccessComplete,
    );
  }

  /// Failure counterpart of [submitForm]. Persistent (not auto-closing), so the
  /// reason the submission was rejected stays on screen until dismissed.
  /// Generic failure message (FB-HOME-04 / FB-SHARE-04 / FB-RESULT-03):
  /// shown whenever a save, publish, share or download did not work, so a
  /// failure is never silent and never reported as a success.
  static Future<void> showError(BuildContext context, String message) {
    return CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.lottieWarning,
      title: S.of(context).errorOccurred,
      subtitle: message,
    );
  }

  static Future<void> submitFormFailed(BuildContext context, String message) {
    return CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.lottieWarning,
      title: S.of(context).errorOccurred,
      subtitle: message,
    );
  }

  /// DEPRECATED in favour of [submitForm], which pairs the confirm and success
  /// steps so they cannot disagree. Left in place for any caller still on it.
  static void submittingForm(
      BuildContext context, dynamic Function() onYesClicked) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).submissionForm,
        subTitle: S.of(context).areYouSureSubmitForm,
        autoClose: false,
        svgAsset: AppAssets.success,
        showButtons: true,
        onConfirm: onYesClicked,
      ),
    );
  }

  static void submittingFormSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).submitForm,
      subtitle: S.of(context).youSuccessfullySubmittedThisForm,
    );
  }

  static void draftForm(BuildContext context, dynamic Function() onYesClicked) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).draftForm,
        subTitle: S.of(context).areYouSureDraftForm,
        autoClose: false,
        svgAsset: AppAssets.save,
        showButtons: true,
        onConfirm: onYesClicked,
      ),
    );
  }

  static Future<void> draftingFormSuccessfully(BuildContext context) async {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).draftForm,
      subtitle: S.of(context).youSuccessfullyDraftedThisForm,
    );
  }

  /// Delete confirmation, and the success dialog that follows it.
  ///
  /// CHANGED: this was a `DefaultDialog` behind `GetDialogHelper.generalDialog`
  /// with five hardcoded English strings, and the success step was a SEPARATE
  /// method (`deletingFormSuccessfully`) that the cubit had to remember to call
  /// from inside its own success branch.
  ///
  /// `CustomDialogManager.showDialogFlow` owns both steps: it closes the
  /// confirm dialog, awaits [onConfirm], and shows the success dialog ONLY when
  /// that returns true — so a delete that fails at the repository can no longer
  /// report success. [onConfirm] must therefore return whether the delete
  /// actually happened, and must NOT pop anything itself; the flow has already
  /// closed the confirm dialog by the time it runs.
  ///
  /// Every string now comes from `S.of(context)`, so the dialog follows the app
  /// language instead of always being English.
  static Future<void> deleteForm(
    BuildContext context,
    Future<bool> Function() onConfirm,
  ) {
    return CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: AppAssets.trash,
      confirmTitle: S.of(context).deleteForm,
      confirmSubtitle: S.of(context).areYouSureDeleteForm,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: onConfirm,
      successLottie: AppAssets.successful,
      successTitle: S.of(context).deletingForm,
      successSubtitle: S.of(context).youSuccessfullyDeletedThisForm,
    );
  }

  /// Same dialog as Delete / Restore
  /// (CustomDialogManager.showDialogFlow): same 500 width and the same 24
  /// padding top and bottom (DefaultDialog left a tall gap under the
  /// buttons). Behaviour is unchanged: Yes closes this dialog, then runs
  /// [onYesClicked] — exactly what DefaultDialog's Yes did — so both callers
  /// keep their own save / success handling.
  static Future<void> editForm(
      BuildContext context, dynamic Function() onYesClicked) {
    return CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
      confirmTitle: S.of(context).editingForm,
      confirmSubtitle: S.of(context).areYouSureEditForm,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async => true,
      showSuccessDialog: false, // the callers show their own success
      onSuccessComplete: () => onYesClicked(),
      successLottie: AppAssets.successful,
      successTitle: S.of(context).editingForm,
      successSubtitle: S.of(context).youSuccessfullyEditedThisForm,
    );
  }

  static Future<void> editingFormSuccessfully(BuildContext context) async {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).editingForm,
      subtitle: S.of(context).youSuccessfullyEditedThisForm,
    );
  }

  static void editingFormNotAllowed(BuildContext context) {
    CustomDialogManager.showMessage(
      context: context,
      // Was the green success Lottie, which made a
      // refused save look like it had worked.
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_warning_red.json',
      title: S.of(context).editingForm,
      subtitle: S.of(context).cantEditFormBecauseSubmitted,
    );
  }

  static Future<void> editingGroupSuccessfully(BuildContext context) async {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).editedGroup,
      subtitle: S.of(context).youSuccessfullyEditedGroup,
    );
  }

  /// Same dialog as Delete (CustomDialogManager
  /// .showDialogFlow): same 500 width, the same 24 padding top AND bottom
  /// (the old DefaultDialog left a much taller gap above the title than
  /// under the buttons), and the attention Lottie instead of the static
  /// edit SVG. The flow closes the confirm, runs [onConfirm] and shows the
  /// success step only when it returns true; [onSuccessComplete] runs after.
  static Future<void> restoreForm(
    BuildContext context,
    Future<bool> Function() onConfirm, {
    VoidCallback? onSuccessComplete,
  }) {
    return CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_restore.json',
      confirmTitle: S.of(context).restoreForm,
      confirmSubtitle: S.of(context).areYouSureRestoreForm,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: onConfirm,
      successLottie: AppAssets.successful,
      successTitle: S.of(context).restoreForm,
      successSubtitle: S.of(context).youSuccessfullyRestoredThisForm,
      onSuccessComplete: onSuccessComplete,
    );
  }

  static void restoringFormSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).restoreForm,
      subtitle: S.of(context).youSuccessfullyRestoredThisForm,
    );
  }

  static void duplicateFormSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).duplicatingForm,
      subtitle: S.of(context).youSuccessfullyDuplicatedThisForm,
    );
  }

  /// Filename prompt for the "download as PDF/Excel" flow.
  ///
  /// Delegates to [CustomDialogManager.showInput] (core/custom) rather than
  /// hand-rolling the field and button. The leading circular download icon is
  /// preserved and passed through as [leadingIcon].
  static void downloadFile(
    TextEditingController controller,
    BuildContext context,
    dynamic Function() onDownloadClicked,
  ) {
    CustomDialogManager.showInput(
      context: context,
      controller: controller,
      // 360 rather than showInput's 500 default: a single filename field does
      // not need half the screen. Raw design number — showInput scales it in
      // .sp, so do not pass 360.sp here.
      width: 360,
      title: S.of(context).downloadForm,
      fieldLabel: S.of(context).fileName,
      confirmText: S.of(context).download,
      onConfirm: () => onDownloadClicked(),
      leadingIcon: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: CustomSvgImage.natural(
          assetPath: AppAssets.downloadPdf,
          color: AppColors.textButton,
        ),
      ),
    );
  }

  /// Form bug report #39: confirm before the PDF is written, then report the
  /// real outcome.
  ///
  /// (bug report p.34 / p.37 / p.64 — "Download must work
  /// as it works in Role Management"). [onConfirm] now returns the export's
  /// `Either` instead of a bare bool, and this dialog reports it the way the
  /// roles export does:
  /// - failure: a message dialog naming the error (it used to close silently,
  ///   so the button looked dead);
  /// - save sheet dismissed on a phone: nothing — the user cancelled;
  /// - success: the success dialog, naming the written file on desktop so the
  ///   user knows where it went.
  static Future<void> confirmDownloadPdf(
    BuildContext context, {
    required String fileName,
    required Future<Either<String, String>> Function() onConfirm,
  }) async {
    if (fileName.trim().isEmpty) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: AppAssets.lottieWarning,
        title: S.of(context).error,
        subtitle: S.of(context).pleaseEnterAFileName,
      );
      return;
    }

    // Resolved up front: by the time the export returns, the confirm dialog
    // is gone and `context` may be the only live element left to read from.
    final String successTitle = S.of(context).formDownloadAsPdf;
    final String successSubtitle =
        S.of(context).youSuccessfullyDownloadedThisFormAsPdf;
    final String failedTitle = S.of(context).downloadFailed;
    final bool isPhone = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    String? error;
    String? savedPath;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      confirmLottie: AppAssets.lottieConfirmation,
      confirmTitle: S.of(context).downloadForm,
      confirmSubtitle: S.of(context).fbDownloadFormPdfConfirm,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        final Either<String, String> result = await onConfirm();
        result.fold(
          (String message) => error = message,
          (String path) => savedPath = path,
        );
        return error == null;
      },
      // The success step is shown below instead, so it can name the file.
      showSuccessDialog: false,
      successLottie: AppAssets.successful,
      successTitle: successTitle,
      successSubtitle: successSubtitle,
    );

    if (!context.mounted) return;

    if (error != null) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: AppAssets.lottieWarning,
        title: failedTitle,
        subtitle: error!,
      );
      return;
    }

    final String? path = savedPath;
    // Null = the user said No; empty = the phone save sheet was dismissed.
    if (path == null || path == CSVHelper.exportCancelled) return;

    await CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: successTitle,
      subtitle: isPhone ? successSubtitle : '$successSubtitle\n$path',
      // Long enough to read the path.
      closeAfter: Duration(milliseconds: isPhone ? 1500 : 3000),
    );
  }

  static void downloadingPdfSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).formDownloadAsPdf,
      subtitle: S.of(context).youSuccessfullyDownloadedThisFormAsPdf,
    );
  }

  static void downloadingExcelSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).downloadAsExcel,
      subtitle: S.of(context).youSuccessfullyDownloadedThisFormAsExcel,
    );
  }

  // ===== Large dialogs: one file per dialog (see widgets/dialog/*) =====

  /// Home-list filter dialog (Access Management + Published Date).
  /// Bug report #11: this used to be an empty stub, so Filter did nothing.
  static void filterDialog(BuildContext context) {
    FormFilterDialog.show(context, context.read<HomeCubit>());
  }

  /// Open-access publish summary. See summary_open_access_dialog.dart.
  static void summaryOpenAccessDialog(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    CreateFormHeadCubit? headCubit,
    CreateFormDataCubit? dataCubit,
  }) =>
      SummaryOpenAccessDialog.show(
        context,
        onPublishClicked,
        headCubit: headCubit,
        dataCubit: dataCubit,
      );

  /// Restricted-access publish summary. See summary_restricted_access_dialog.dart.
  static void summaryRestrictedAccessDialog(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    CreateFormHeadCubit? headCubit,
    CreateFormDataCubit? dataCubit,
  }) =>
      SummaryRestrictedAccessDialog.show(
        context,
        onPublishClicked,
        headCubit: headCubit,
        dataCubit: dataCubit,
      );

  /// Share-access summary. See share_access_dialog.dart.
  static void shareAccessDialog(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    ShareCubit? shareCubit,
  }) =>
      ShareAccessDialog.show(
        context,
        onPublishClicked,
        shareCubit: shareCubit,
      );

  static void editGroupWarningDialog(
    BuildContext context,
    Function() onYesClicked,
  ) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).editingGroupDetails,
        subTitle: S.of(context).areYouSureEditGroup,
        autoClose: false,
        // Bug report p.58 ("use the default SVG"): the same edit animation
        // the Editing Form dialog uses, instead of the large grey edit icon.
        lottieAsset:
            "assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json",
        showButtons: true,
        onConfirm: () {
          onYesClicked();
          Get.back();
        },
        padding: EdgeInsets.all(24.r),
      ),
    );
  }
}
