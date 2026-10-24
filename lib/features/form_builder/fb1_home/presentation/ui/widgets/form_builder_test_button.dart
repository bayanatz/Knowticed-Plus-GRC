/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_test_button.dart
/// Description: "Test notifications & calendar" card on the Form Builder home
///          screen. One tap sends EVERY Form Builder notification (section 2.3,
///          14 events) and places EVERY Form Builder calendar entry (section 2,
///          5 types) on the signed-in user's own account.
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// Runs `DemoAccountsSeeder.applyModule(AppModule.formBuilder)`, so it uses
/// the real pipeline: each notification goes through AppNotificationSender
/// with the live template (admin text from Notification Control if it exists,
/// the enum default otherwise) and sample values for its placeholders; each
/// calendar type is written to the seeded-events collection the calendar
/// already reads, spread over the next days.
///
/// Visible only in Moataz's owner debug run (kDebugMode && kOwnerTools), so
/// developers and real tenants never see it.
/// Confirm → run → success / error dialog through CustomDialogManager.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_catalog.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/demo_accounts_seeder.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart'
    show kOwnerTools;
import 'package:knowticed_plus/features/notification/domain/enums/notification_catalog.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/form_builder/form_builder_get_it.dart';

class FormBuilderTestButton extends StatefulWidget {
  const FormBuilderTestButton({super.key});

  /// Owner-only (18/10/2026, Moataz: "a developer test tool"): debug builds
  /// run with `--dart-define=KP_OWNER_TOOLS=true` only, the same rule as the
  /// Knowledge Hub seed button. Developers' debug runs and release builds do
  /// not show it. Was ApplyAllModulesButton.isVisible (every debug run).
  static bool get isVisible => kDebugMode && kOwnerTools;

  @override
  State<FormBuilderTestButton> createState() => _FormBuilderTestButtonState();
}

class _FormBuilderTestButtonState extends State<FormBuilderTestButton> {
  bool _running = false;

  static const String _confirmLottie =
      'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json';
  static const String _successLottie =
      'assets/lottie_assets/main_lottie_assets/lot_status_approved.json';
  static const String _errorLottie =
      'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json';

  static const AppModule _module = AppModule.formBuilder;

  int get _notificationCount => NotificationCatalog.eventsOf(_module).length;
  int get _calendarCount => CalendarCatalog.eventsOf(_module).length;

  String get _myEmail =>
      formBuilderLocator<MainCoreEmployeeController>()
          .employeeEntity
          ?.email
          ?.trim() ??
      '';

  Future<void> _onTap() async {
    if (_running) return;
    final bool en = context.isEnglish;
    final String me = _myEmail;

    if (me.isEmpty) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: _errorLottie,
        title: S.of(context).warning,
        subtitle: S.of(context).errorOccuredPleaseTryAgain,
      );
      return;
    }

    DemoSeedResult? result;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: _confirmLottie,
      confirmTitle: S.of(context).fbTestNotificationsTitle,
      confirmSubtitle: S
          .of(context)
          .fbTestNotificationsConfirm(_notificationCount, _calendarCount, me),
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        setState(() => _running = true);
        result = await DemoAccountsSeeder.applyModuleOrNull(
          module: _module,
          to: <String>[me],
          senderEmail: me,
          isArabic: !en,
        );
        if (mounted) setState(() => _running = false);
        final DemoSeedResult? r = result;
        if (r == null || r.isTotalFailure) {
          if (mounted) {
            await CustomDialogManager.showMessage(
              context: context,
              lottiePath: _errorLottie,
              title: S.of(context).warning,
              subtitle: S.of(context).errorOccuredPleaseTryAgain,
            );
          }
          return false;
        }
        return true;
      },
      successLottie: _successLottie,
      successTitle: S.of(context).fbSent,
      successSubtitle: S.of(context).fbTestNotificationsDone,
    );

    // Partial run: say what did not go through instead of pretending.
    final DemoSeedResult? r = result;
    if (mounted && r != null && !r.isFullSuccess && !r.isTotalFailure) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: _errorLottie,
        title: S.of(context).warning,
        subtitle: S.of(context).fbTestNotificationsPartial(
              r.notificationsSent,
              r.notificationsAttempted,
              r.calendarEventsWritten,
              r.calendarEventsAttempted,
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: hapticDown(_onTap, HapticLevel.low),
      onTap: _onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25.sp,
              backgroundColor: AppColors.primary,
              child: _running
                  ? SizedBox(
                      width: 22.sp,
                      height: 22.sp,
                      child: CircleProgressMaster.inline(
                        strokeWidth: 2.5,
                        color: AppColors.textButton,
                      ),
                    )
                  : CustomSvgImage.natural(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_comms_notification_bell.svg',
                      width: 24.sp,
                      height: 24.sp,
                      colorFilter: ColorFilter.mode(
                        AppColors.textButton,
                        BlendMode.srcIn,
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).fbTestNotificationsButton,
                    style: StyleText.fontSize16Weight500,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _running
                        ? S.of(context).fbSending
                        : S.of(context).fbTestNotificationsSubtitle(
                              _notificationCount,
                              _calendarCount,
                            ),
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.icon,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
