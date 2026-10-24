/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_info_screen.dart
/// Purpose: Responsive company information / branding screen (phone + tablet in
///          one page).
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N14: the file-scope
///          `Get.put(HapticController())` — which registered a global singleton
///          as a side effect of importing this page — replaced with the lazy
///          `hapticController` accessor from core/custom/misc/custom_haptic.dart.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/widgets/sections/company_branding_section.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_haptic.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/restart_widget.dart';

class CompanyInfoScreen extends StatefulWidget {
  final bool? isBranding;

  const CompanyInfoScreen({super.key, this.isBranding = false});

  @override
  // ignore: library_private_types_in_public_api
  _CompanyInfoScreenState createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  bool isEnglish = Get.locale.toString().contains('en');
  CompanyCubit get companyController => context.read<CompanyCubit>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Owner 21/10/2026: consume `restartRequested` here too (as the branding screen does) so it is never left true.
    return BlocListener<CompanyCubit, CompanyState>(
      listenWhen: (CompanyState previous, CompanyState current) =>
          current.restartRequested && !previous.restartRequested,
      listener: _onRestartRequested,
      child: ContextExtension(context).isPhone
          ? _buildPhone(context)
          : _buildTablet(context),
    );
  }

  /// Remounts the app (fonts are resolved at build time), then clears the
  /// one-shot flag. Skipped when another page is on top of this one — that
  /// page's own listener handles it, so the app is not remounted twice.
  void _onRestartRequested(BuildContext context, CompanyState state) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    final CompanyCubit cubit = companyController;
    RestartWidget.restartApp(context);
    cubit.clearMessages();
  }

  /// Apply = confirm dialog -> save -> success dialog.
  ///
  /// Both the phone and the tablet Apply buttons route through here so the two
  /// layouts can't drift apart. CustomDialogManager only shows the success step
  /// when [onConfirm] returns true, so a failed save no longer reports success:
  /// CompanyCubit.updateCompanyModel() doesn't throw, it emits
  /// CompanyStatus.failure, which is what the return value is read from.
  Future<void> _applyChanges(BuildContext context) async {
    await CustomDialogManager.showDialogFlow(
      context: context,
      // CHANGED 8/9/2026 — was `lottie_warning.json`, the red exclamation mark.
      //
      // This is the branding page's other action, sitting right beside Reset,
      // and Reset's dialog uses `reset_brand.json`
      // (company_branding_section.dart, _resetBranding). The two now match, so
      // the page does not alarm the user with a red warning for saving their
      // own edits while the genuinely destructive action gets the calmer icon.
      confirmLottie:
          'assets/lottie_assets/settings_lottie_assets/lot_action_reset_branding.json',
      confirmTitle: S.of(context).applyChanges,
      confirmSubtitle: S.of(context).areYouSureYouWantToSaveTheseChanges,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        hapticController.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );

        await companyController.updateCompanyModel();

        return companyController.state.status != CompanyStatus.failure;
      },
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: S.of(context).Successful,
      successSubtitle: S.of(context).dataHasBeenSavedSuccessfully,
      onSuccessComplete: () {
        if (mounted) setState(() {});
      },
    );
  }

  /// Owner 21/10/2026: Reset restored (removed in D-247). Same flow it had in
  /// company_branding_section.dart before 21/10/2026 — the write lives in
  /// `CompanyCubit.resetCompanyBranding()`; this only drives the dialogs.
  Future<void> _resetBranding(BuildContext context) async {
    final S l = S.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/settings_lottie_assets/lot_action_reset_branding.json',
      confirmTitle: l.resetBranding,
      confirmSubtitle: l.areYouSureYouWantToResetTheCompanyBranding,
      confirmYesText: l.yes,
      confirmNoText: l.no,
      onConfirm: () async {
        hapticController.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );
        final bool reset = await companyController.resetCompanyBranding();
        if (!reset) {
          if (!context.mounted) return false;
          await CustomDialogManager.showMessage(
            context: context,
            lottiePath:
                'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
            title: l.unsuccessful,
            subtitle: l.errorOccurred,
          );
          return false;
        }
        // Reload so the theme repaints with the defaults behind the success
        // dialog (no Apply needed after a reset).
        await companyController.getCompany(shouldRestart: false);
        if (mounted) setState(() {});
        return true;
      },
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: l.Successful,
      successSubtitle: l.dataHasBeenSavedSuccessfully,
    );
  }

  /// Owner 21/10/2026: grey Reset at the start edge, same size as Apply.
  Widget _buildResetButton(
    BuildContext context,
    CompanyState state, {
    double? width,
  }) {
    final bool busy = state.status == CompanyStatus.loading;
    return IgnorePointer(
      ignoring: busy,
      child: customButton(
        title: S.of(context).Reset,
        fullWidth: true,
        width: width,
        function: () async {
          await _resetBranding(context);
        },
        color: AppColors.darkGrey,
        textStyle:
            StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
      ),
    );
  }

  /// Apply, greyed out and untappable until [CompanyState.hasBrandingChanges].
  ///
  /// Opacity + IgnorePointer + a grey fill — the same disabled treatment used
  /// by the request preview pages, the health edit page and the social screen,
  /// so a dead action looks the same everywhere in Settings.
  ///
  /// Also disabled mid-save: `updateCompanyModel()` emits
  /// `CompanyStatus.loading` first, and a second tap during the write would
  /// stack a second confirm dialog on top of the first.
  Widget _buildApplyButton(
    BuildContext context,
    CompanyState state, {
    double? width,
  }) {
    final bool enabled =
        state.hasBrandingChanges && state.status != CompanyStatus.loading;

    // FIXED 8/9/2026 — the disabled label was unreadable, same as Submit on the
    // health request preview page. `AppColors.textButton` is
    // `AppTheme.readableOn(AppColors.primary)`, so in light mode it resolves to (near) black
    // on the grey disabled fill, and the `Opacity(0.5)` wrapper washed out what
    // was left of it. The label is pinned to white while disabled and the
    // opacity layer is gone, since it faded the white back to grey. The FILL is
    // unchanged: primary when enabled, AppColors.grey when not.
    // Owner 21/10/2026 (R-3): disabled = grey, black text, faded to 50%.
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: customButton(
          title: S.of(context).Apply,
          fullWidth: true,
          width: width,
          function: () async {
            await _applyChanges(context);
          },
          color: enabled ? AppColors.primary : AppColors.grey,
          textStyle: StyleText.fontSize16Weight500.copyWith(
              color: enabled ? AppColors.textButton : AppColors.black),
        ),
      ),
    );
  }

  /// Phone design.
  ///
  /// CHANGED: this used to open on a `CustomTabs` pair — "Company Information"
  /// and "Branding" — so tapping Settings > Branding and Theme on a phone
  /// landed on the COMPANY INFO tab, showing a different screen from the one
  /// the same menu entry opens on desktop. It was also a duplicate route in:
  /// Settings > Company Information already opens CompanyScreenInfo, and only
  /// the Branding tab here had a working action (the info tab's "Update"
  /// opened a dialog whose form widgets were deleted).
  ///
  /// The phone now shows exactly what _buildTablet shows — the branding
  /// editor and Apply — wrapped in the breadcrumb frame every other pushed
  /// settings page uses, since this one is reached with Navigator.push.
  Widget _buildPhone(BuildContext context) {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) => SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () => Navigator.of(context).maybePop(),
        secondTitle: S.of(context).brandingAndTheme,
        // Own review 21/10/2026 (D-202): Apply is PINNED above the
        // navigation bar; the card scrolls above it.
        child: SideFrameBoundedBody(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: CompanyBrandingScreen(
                      onChangedImageUrl: (value) {},
                      onChangedPrimaryColor: (Color value) {},
                      onChangedSecondaryColor: (Color value) {},
                      onChangedFontArabic: (String value) {},
                      onChangedFontEnglish: (String value) {},
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.sp),
              // Routes through _applyChanges, exactly like the tablet button.
              //
              // `width` is passed explicitly because customButton IGNORES its
              // `fullWidth` flag (see the SCOPE note in 5-custom_button.dart) and
              // falls back to the fixed 135.sp phone width — which is why Apply
              // was a small button floating under a full-width card. `width` is
              // the one lever that widget still honours.
              // Owner 21/10/2026: Reset | Apply in one row, equal halves.
              Row(
                children: [
                  Expanded(
                    child: _buildResetButton(context, state,
                        width: double.infinity),
                  ),
                  SizedBox(width: 16.sp),
                  Expanded(
                    child: _buildApplyButton(context, state,
                        width: double.infinity),
                  ),
                ],
              ),
              SizedBox(height: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  /// Tablet design (formerly tablet_company_info_screen.dart)
  Widget _buildTablet(BuildContext context) {
    // CHANGED 18/10/2026: no Expanded here. The settings shell already wraps
    // this page in an Expanded, so a second one nested inside it was a
    // ParentData misuse; the scroll view fills the pane on its own.
    // Own review 21/10/2026 (D-202): the card keeps its own height and
    // scrolls if longer; Apply is PINNED at the bottom of the pane like
    // Request Change on Personal Information.
    // Moataz 23/10/2026: Reset | Apply are 150 wide (not 250) and sit just
    // under the card (16 below it), not pinned to the bottom of the page.
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) => SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: CompanyBrandingScreen(
                onChangedImageUrl: (value) {},
                onChangedPrimaryColor: (Color value) {},
                onChangedSecondaryColor: (Color value) {},
                onChangedFontArabic: (String value) {},
                onChangedFontEnglish: (String value) {},
              ),
            ),
            SizedBox(height: 16.sp),
            Row(
              children: [
                SizedBox(
                  width: 150.sp,
                  child: _buildResetButton(context, state, width: 150.sp),
                ),
                const Spacer(),
                SizedBox(
                  width: 150.sp,
                  child: _buildApplyButton(context, state, width: 150.sp),
                ),
              ],
            ),
            SizedBox(height: 16.sp),
          ],
        ),
      ),
    );
  }
}
