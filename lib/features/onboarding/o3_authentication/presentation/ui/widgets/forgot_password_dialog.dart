/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: forgot_password_dialog.dart
/// Description: The "forgot password" prompt.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N24: the `try/finally` is gone — even try/finally is forbidden in
///          presentation/ui/ (§11.2).
library;

/// Objectives: "Forgot Password?" dialog shown from the sign-in screen.
///
/// Visual port of Knowticed's ForgotPassDialog (rounded 8px card, title, single
/// email field, Cancel / Send row) without the Firestore employee lookup — the
/// submit handler validates the address and reports back through
/// [ResponseDialog].

import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:grc_module/core/custom/dialogs/custom_response_dialog.dart';
import 'package:grc_module/core/helper/validation/validator.dart';
// Brings in ScreenSizeExtension, so `0.15.w` means 15% of the screen (as in
// Knowticed) rather than screenutil's design-size scale factor.
import 'package:grc_module/core/extensions/screen_fraction_extension.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_animations.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key, this.onSubmit});

  /// Optional hook so the caller can drive the actual reset request.
  /// Receives the normalised (trimmed, lower-cased) email address.
  final Future<void> Function(String email)? onSubmit;

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final HapticController _hapticController = Get.put(HapticController());

  String? _emailError;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String email = _emailController.text.trim().toLowerCase();
    final String? error = Validator.emailTitle(email);

    if (error != null) {
      setState(() => _emailError = error);
      return;
    }

    setState(() {
      _emailError = null;
      _submitting = true;
    });

    _hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    // Held onto before the pop: this dialog's own context is defunct once it
    // closes, so the confirmation is shown from the parent navigator instead.
    final NavigatorState navigator = Navigator.of(context);

    // Was `try { await onSubmit } finally { … }`. Even try/finally is
    // forbidden in presentation/ui/ (§11.2, CR-SKEL-O3-N24). The callback is
    // the caller's to make safe — it is a cubit/controller method, which is
    // where the catch belongs — so this simply awaits and then clears the
    // in-flight flag.
    await widget.onSubmit?.call(email);
    if (mounted) setState(() => _submitting = false);

    if (!mounted) return;
    navigator.pop();
    showAppDialog(
      context: navigator.context,
      builder: (dialogContext) => ResponseDialog(
        title: S.of(dialogContext).resetPassword,
        subtitle: S.of(dialogContext).passwordResetLinkSent,
        lottieAsset:
            'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = !kpIsPhoneLayout(context);
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? (isPortrait ? 0.22.w : 0.33.w) : 0.15.w,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.card,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).forgotPassword2,
                style: StyleText.fontSize18Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 15.sp),
              CustomTextField(
                label: S.of(context).email,
                hint: S.of(context).textHere,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                errorText: _emailError,
                fillColor: AppColors.card,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              SizedBox(height: 15.sp),
              Row(
                // X-73: Cancel at the left edge, Send at the right edge, same
                // size, in both languages.
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Half the row each: two fixed 135 buttons overflowed the
                  // phone dialog by 44 px.
                  Expanded(
                    child: customButton(
                      title: S.of(context).cancel,
                      function: () {
                        if (!_submitting) Navigator.of(context).pop();
                      },
                      width: double.infinity,
                      color: AppColors.darkGrey,
                      textColor: AppColors.text,
                      haptic: HapticController.high,
                    ),
                  ),
                  SizedBox(width: 15.sp),
                  Expanded(
                    child: customButton(
                      title: S.of(context).send,
                      function: _submit,
                      width: double.infinity,
                      isLoading: _submitting,
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
