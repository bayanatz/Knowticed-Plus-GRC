/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: create_form_flow_dialog.dart
/// Description: `CreateFormFlowDialog` — ONE dialog for publishing a form
///          after Grant Access: "Are you sure?" → (Yes) the Yes / No buttons
///          turn into a loading circle in the same dialog → success message
///          → closes itself after 3 seconds and goes back to Home.
/// Author: Amr Mesbah
/// Created at: 13/10/2026
///
/// Replaces the old chain (confirm dialog → separate loading overlay →
/// separate success dialog). That chain closed the loader through the
/// caller's BuildContext; when that context was gone by the time the save
/// finished, the loader was never popped and the screen stayed frozen on a
/// spinner. Here every step lives inside one dialog that owns its own
/// context, and the save has a timeout, so it can always finish.

library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum _FlowStep { confirm, loading, success, error }

class CreateFormFlowDialog {
  CreateFormFlowDialog._();

  static const String _confirmLottie =
      'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json';
  static const String _errorLottie =
      'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json';

  /// How long the success message stays before going Home.
  static const Duration successDelay = Duration(seconds: 3);

  /// Longest the save may take before it is reported as failed instead of
  /// spinning forever (e.g. no connection).
  static const Duration saveTimeout = Duration(seconds: 45);

  /// [save] does the work and returns null on success, or the message to
  /// show on failure. [onFinished] runs after the success message closes —
  /// navigate Home there.
  static Future<void> show(
    BuildContext context, {
    required Future<String?> Function() save,
    required VoidCallback onFinished,
  }) async {
    final bool? succeeded = await showAppDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => _CreateFormFlowView(save: save),
    );
    if (succeeded == true) onFinished();
  }
}

class _CreateFormFlowView extends StatefulWidget {
  const _CreateFormFlowView({required this.save});

  final Future<String?> Function() save;

  @override
  State<_CreateFormFlowView> createState() => _CreateFormFlowViewState();
}

class _CreateFormFlowViewState extends State<_CreateFormFlowView> {
  _FlowStep _step = _FlowStep.confirm;
  String _error = '';
  Timer? _closeTimer;

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  void _close(bool succeeded) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(succeeded);
  }

  Future<void> _onYes() async {
    setState(() => _step = _FlowStep.loading);

    String? error;
    try {
      error = await widget.save().timeout(CreateFormFlowDialog.saveTimeout);
    } on TimeoutException {
      error = S.current.formSaveFailed;
    } catch (_) {
      error = S.current.formSaveFailed;
    }
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _step = _FlowStep.error;
        _error = error!;
      });
      return;
    }

    setState(() => _step = _FlowStep.success);
    _closeTimer = Timer(CreateFormFlowDialog.successDelay, () => _close(true));
  }

  bool get _isLight => Theme.of(context).brightness == Brightness.light;

  @override
  Widget build(BuildContext context) {
    final String lottie = switch (_step) {
      _FlowStep.success => AppAssets.successful,
      _FlowStep.error => CreateFormFlowDialog._errorLottie,
      _ => CreateFormFlowDialog._confirmLottie,
    };
    final String title = switch (_step) {
      _FlowStep.success => S.of(context).formCreated,
      _FlowStep.error => S.of(context).warning,
      _ => S.of(context).creatingForm,
    };
    final String subtitle = switch (_step) {
      _FlowStep.success => S.of(context).youSuccessfullyCreatedThisForm,
      _FlowStep.error => _error,
      _ => S.of(context).areYouSureCreateForm,
    };

    return PopScope(
      // No back / Esc while saving.
      canPop: _step != _FlowStep.loading,
      child: Dialog(
        backgroundColor: _isLight ? AppColors.white : AppColors.chatBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: SizedBox(
            width: 500.sp,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottie,
                    key: ValueKey(lottie),
                    width: 70.sp,
                    height: 70.sp,
                    fit: BoxFit.scaleDown,
                    repeat: _step != _FlowStep.success,
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: _isLight ? AppColors.blackButton : AppColors.white,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color:
                          _isLight ? AppColors.secondaryText : AppColors.grey,
                    ),
                  ),
                  if (_step != _FlowStep.success) ...[
                    SizedBox(height: 15.sp),
                    SizedBox(height: 38.sp, child: _buildBottom()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    switch (_step) {
      case _FlowStep.loading:
        // Same spot as the buttons, so the dialog does not jump.
        return Center(
          child: SizedBox(
            width: 32.sp,
            height: 32.sp,
            child: CircleProgressMaster.inline(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
        );
      case _FlowStep.error:
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 135.sp),
            child: customButton(
              fullWidth: true,
              title: S.of(context).ok,
              function: () => _close(false),
              textStyle: StyleText.fontSize15Weight400
                  .copyWith(color: AppColors.textButton),
              height: 38.sp,
              color: AppColors.primary,
            ),
          ),
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 135.sp),
                child: customButton(
                  fullWidth: true,
                  title: S.of(context).no,
                  function: () => _close(false),
                  textStyle: StyleText.fontSize15Weight400
                      .copyWith(color: AppColors.text),
                  height: 38.sp,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            SizedBox(width: 15.sp),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 135.sp),
                child: customButton(
                  fullWidth: true,
                  title: S.of(context).yes,
                  function: _onYes,
                  textStyle: StyleText.fontSize15Weight400
                      .copyWith(color: AppColors.textButton),
                  height: 38.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
    }
  }
}
