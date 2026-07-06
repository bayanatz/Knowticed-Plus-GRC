/// ******************* FILE INFO *******************
/// File Name: custom_dialog.dart
/// Description: this is custom success or comment or select dialog for reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/inventory_module/core/svg_custom.dart';
import 'package:lottie/lottie.dart';

import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/helper/inventory_module/core/text_field.dart';
import 'package:demo_app/core/helper/knowledge_hub_module/knowledge_hub/presentation/ui/widgets/customed_text_field.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/local_widgets/services_management/custom_botton.dart';
import 'package:demo_app/core/local_widgets/services_management/custom_textformfield.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class CustomDialogManager {
  static Future<void> showDialogFlow({
    required BuildContext context,
    required String confirmLottie,
    required String confirmTitle,
    required String confirmSubtitle,
    required String confirmYesText,
    required String confirmNoText,
    required VoidCallback onConfirm,
    VoidCallback? onNoPressed,
    bool commentRequired = false,
    required String successLottie,
    required String successTitle,
    required String successSubtitle,
    bool comment = false,
    TextEditingController? commentController,
    String commentSubmitText = '',
    String commentDiscardText = '',
    String customReasonTitle = '',
    Future<void> Function()? onCommentSubmit,
    VoidCallback? onCommentDiscard,
    VoidCallback? onSuccessDismissed,
    VoidCallback? onSuccessComplete, // ✅ ADD THIS PARAMETER
  }) async {
    debugPrint('[CDM] showDialogFlow: START '
        '(comment=$comment, required=$commentRequired, '
        'confirm="$confirmTitle", success="$successTitle")');
    final outerContext = context;

    // ✅ CREATE A COMPLETER TO TRACK WHEN EVERYTHING IS DONE
    final completer = Completer<void>();

    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dlgCtx) {
        final isMobile = dlgCtx.isPhone;
        debugPrint('[CDM] Confirm dialog BUILDER');
        return Dialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 500.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    confirmLottie,
                    width: 70.sp,
                    height: 70.sp,
                    fit: BoxFit.scaleDown,
                    repeat: true,
                    animate: true,
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    confirmTitle,
                    style: AppTextStyles.font20BlackCairoMedium.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    confirmSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font14BlackCairoMedium.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customButtonAnimation(
                        title: confirmNoText,
                        function: () {
                          debugPrint('[CDM] Confirm NO pressed');
                          Navigator.of(context, rootNavigator: true).pop();
                          onNoPressed?.call();
                          debugPrint('[CDM] Confirm dialog closed via NO');
                          // ✅ COMPLETE THE FLOW WHEN USER SAYS NO
                          if (!completer.isCompleted) {
                            completer.complete();
                          }
                        },
                        textStyle: AppTextStyles.font15BlackCairoRegular.copyWith(
                          color: const Color(0xff2D2D2D),
                        ),
                        width: isMobile ? 115.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.secondaryButton,
                      ),
                      SizedBox(height: 0, width: 15.sp),
                      customButtonAnimation(
                        title: confirmYesText,
                        function: () async {
                          debugPrint('[CDM] Confirm YES pressed');

                          // 1) Close the confirm dialog FIRST
                          final nav = Navigator.of(dlgCtx, rootNavigator: true);
                          if (nav.canPop()) {
                            nav.pop();
                            debugPrint('[CDM] Confirm dialog closed via YES');
                          }

                          // 2) Brief delay
                          await Future.delayed(const Duration(milliseconds: 120));

                          // 3) If comment required, show comment dialog
                          bool proceed = true;
                          if (comment && commentController != null) {
                            debugPrint('[CDM] Opening COMMENT dialog (required=$commentRequired)');
                            proceed = await _showCommentDialog(
                              context: outerContext,
                              controller: commentController,
                              submitText: commentSubmitText,
                              discardText: commentDiscardText,
                              reasonTitle: customReasonTitle,
                              onSubmit: onCommentSubmit,
                              onDiscard: onCommentDiscard,
                              isRequired: commentRequired,
                            );
                            debugPrint('[CDM] COMMENT dialog result: proceed=$proceed');

                            if (!proceed) {
                              debugPrint('[CDM] Aborting after comment dialog (not submitted)');
                              // ✅ COMPLETE THE FLOW WHEN COMMENT IS DISCARDED
                              if (!completer.isCompleted) {
                                completer.complete();
                              }
                              return;
                            }
                          }

                          // 4) Run the confirm logic
                          try {
                            debugPrint('[CDM] Calling onConfirm()');
                            onConfirm();
                            debugPrint('[CDM] onConfirm() DONE');
                          } catch (e, st) {
                            debugPrint('[CDM][ERROR] onConfirm threw: $e\n$st');
                          }

                          // 5) Show success dialog
                          await _showSuccessDialog(
                            context: outerContext,
                            lottiePath: successLottie,
                            title: successTitle,
                            subtitle: successSubtitle,
                          );

                          debugPrint('[CDM] Success dialog dismissed');
                          onSuccessDismissed?.call();

                          // ✅ COMPLETE THE FLOW AFTER SUCCESS DIALOG
                          if (!completer.isCompleted) {
                            completer.complete();
                          }

                          // ✅ CALL onSuccessComplete AFTER EVERYTHING IS DONE
                          onSuccessComplete?.call();
                        },
                        textStyle: AppTextStyles.font15BlackCairoRegular.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isMobile ? 115.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.primary,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // ✅ WAIT FOR THE ENTIRE FLOW TO COMPLETE
    await completer.future;

    debugPrint('[CDM] showDialogFlow: END');
  }

  static Future<bool> _showCommentDialog({
    required BuildContext context,
    required TextEditingController controller,
    required String submitText,
    required String discardText,
    required String reasonTitle,
    Future<void> Function()? onSubmit,
    VoidCallback? onDiscard,
    bool isRequired = false,
  }) async {
    final isArabic = Localizations
        .localeOf(context)
        .languageCode == 'ar';
    // 1) add this helper near the top of the file (outside the widget/class)
    String _toWesternDigits(String s) {
      const east = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
      const west = ['0','1','2','3','4','5','6','7','8','9'];
      for (var i = 0; i < east.length; i++) {
        s = s.replaceAll(east[i], west[i]);
      }
      return s;
    }

    String _toEasternDigits(String s) {
      const east = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
      const west = ['0','1','2','3','4','5','6','7','8','9'];
      for (var i = 0; i < west.length; i++) {
        s = s.replaceAll(west[i], east[i]);
      }
      return s;
    }



    debugPrint('[CDM] _showCommentDialog: OPEN (required=$isRequired)');
    final isMobile = context.isPhone;
    String? errorText;

    final result = await showDialog<bool>(

      context: context,
      barrierDismissible: !isRequired,
      useRootNavigator: true,
      builder: (context) {
        var lightMode = Theme.of(context).brightness == Brightness.light;
        debugPrint('[CDM] Comment dialog BUILDER');
        return Dialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: SizedBox(
              width: 500.sp,
              child: StatefulBuilder(
                builder: (context, setState) {
                  void validate() {
                    if (isRequired && controller.text.trim().isEmpty) {
                      setState(() => errorText = S.of(context).pleaseEnterCancelReason);
                      debugPrint('[CDM] Comment validate: EMPTY (required)');
                    } else {
                      setState(() => errorText = null);
                      debugPrint('[CDM] Comment validate: OK');
                    }
                  }
                  const int kMaxChars = 500;
                  final int len = controller.text.characters.length;
                  final String counterText = isArabic
                      ? '${_toEasternDigits(kMaxChars.toString())}/${_toEasternDigits(len.toString())}' // AR: ٥٠٠/٠
                      : '${_toWesternDigits(len.toString())}/${_toWesternDigits(kMaxChars.toString())}'; // EN: 0/500

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          reasonTitle == S.of(context).reasonOfApproval ?    Container(
                              width: 30.sp, height: 30.sp,
                              decoration:  BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                              child: SizedBox(
                                child: Icon(Icons.check,color: AppColors.textButton,)
                              )
                          ) : Container(
                              width: 30.sp, height: 30.sp,
                              decoration:  BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                              child: SizedBox(
                                child: CustomSvg(assetPath: "assets/icons_assets/main_icons_assets/services_module_reson_reject.svg",color: AppColors.textButton,width: 16.w,height: 16.h,fit: BoxFit.scaleDown,),
                              )
                          ),
                          SizedBox(width: 5.sp),
                          Text(
                            reasonTitle,
                            style: AppTextStyles.font16BlackMediumCairo.copyWith(
                              color: AppColors.text
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.sp),

                      CustomValidatedTextFieldMaster(
                        label: S.of(context).Justifications,
                        hint: S.of(context).Texthere,

                        controller: controller,
                        height: 72.sp,
                        maxLines: 3,
                        showCharCount: true,
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                        onChanged: (value) {
                          debugPrint('[CDM] ✏️ TextField changed: "$value" (trimmed length: ${value.trim().length})');
                          setState(() {});
                        },
                        textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),


                      SizedBox(height: 15.sp),
                      Row(
                        children: [
                          customButtonAnimation(
                            title: discardText,
                            function: () {
                              debugPrint('[CDM] Comment DISCARD pressed');
                              Navigator.of(context, rootNavigator: true).pop(false);
                              onDiscard?.call();
                              debugPrint('[CDM] Comment dialog closed via DISCARD');
                            },
                            textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(color: lightMode ? Colors.black : Colors.white),
                            width: isMobile ? 120.sp : 150.sp,
                            height: 38.sp,
                            radius: 8.r,
                            color: lightMode ? Colors.grey[400] : Colors.grey[700]
                          ),
                          const Spacer(),
                          // ✅ DISABLE BUTTON when field is empty and required
                          Builder(
                            builder: (btnContext) {
                              final textValue = controller.text;
                              final trimmedValue = textValue.trim();
                              final isEmpty = trimmedValue.isEmpty;
                              final shouldDisable = isRequired && isEmpty;

                              debugPrint('[CDM] 🔘 Button Builder called:');
                              debugPrint('    isRequired: $isRequired');
                              debugPrint('    textValue: "$textValue"');
                              debugPrint('    trimmedValue: "$trimmedValue"');
                              debugPrint('    isEmpty: $isEmpty');
                              debugPrint('    shouldDisable: $shouldDisable');

                              return Opacity(
                                opacity: shouldDisable ? 0.5 : 1.0,
                                child: IgnorePointer(
                                  ignoring: shouldDisable,
                                  child: customButtonAnimation(
                                    title: submitText,
                                    function: () async {
                                      debugPrint('[CDM] Comment SUBMIT pressed');
                                      try {
                                        debugPrint('[CDM] Calling onSubmit()');
                                        await onSubmit?.call();
                                        debugPrint('[CDM] onSubmit() DONE');
                                      } catch (e, st) {
                                        debugPrint('[CDM][ERROR] onSubmit threw: $e\n$st');
                                      }
                                      if (Navigator.of(btnContext, rootNavigator: true).canPop()) {
                                        Navigator.of(btnContext, rootNavigator: true).pop(true);
                                        debugPrint('[CDM] Comment dialog closed via SUBMIT');
                                      }
                                    },
                                    textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
                                      color: AppColors.textButton,
                                    ),
                                    width: isMobile ? 120.sp : 150.sp,
                                    height: 38.sp,
                                    radius: 8.r,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    debugPrint('[CDM] _showCommentDialog: CLOSE result=${result ?? false}');
    return result ?? false;
  }

  // REPLACE the whole method with this:
  static Future<void> _showSuccessDialog({
    required BuildContext context,
    required String lottiePath,
    required String title,
    required String subtitle,
  }) async {
    debugPrint('[CDM] _showSuccessDialog: OPEN');

    BuildContext? dialogCtx; // capture the dialog's own context

    // IMPORTANT: barrierDismissible=false so users can't dismiss before auto-close
    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
        dialogCtx = ctx; // <-- capture
        debugPrint('[CDM] Success dialog BUILDER');
        return Dialog(
          backgroundColor: Theme.of(ctx).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 500.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottiePath,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    title,
                    style: AppTextStyles.font23BlackRegularCairo.copyWith(
                      color: Theme.of(ctx).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font18BlackMediumCairo.copyWith(
                      color: Theme.of(ctx).brightness == Brightness.light
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    // Schedule the auto-close tied to the captured dialog context
    await Future.delayed(const Duration(milliseconds: 1500));

    if (dialogCtx != null) {
      final nav = Navigator.of(dialogCtx!, rootNavigator: true);
      // Only pop if this dialog is still on top:
      if (nav.canPop()) {
        debugPrint('[CDM] _showSuccessDialog: CLOSE (auto after delay)');
        nav.pop();
      } else {
        debugPrint('[CDM][INFO] Dialog already closed; skipping pop');
      }
    } else {
      debugPrint('[CDM][WARN] dialogCtx was null; nothing to pop');
    }
  }

}
