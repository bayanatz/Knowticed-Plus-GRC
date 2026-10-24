/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_layout_sections.dart
/// Description: UI sections of `_SettingsLayoutState` — split out of `settings_layout.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/settings_layout.dart';

// Split from settings_layout_builders.dart to keep every file under 700 lines.

extension _SettingsLayoutSections on _SettingsLayoutState {
  Padding _buildAccountCard(
    bool hasPersonalInfo,
    SettingsController settingsController,
    bool lightMode,
    BuildContext context,
    bool isMobile,
    bool hasHealthInsurance,
    bool hasSocialInfo,
    bool hasRequests,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r), // Owner 24/10/2026: same curve as the right-side cards
        child: Container(
          // card, not background: rows have fractional heights, and the
          // darker background showed through as lines between them (Moataz 18/10).
          color: AppColors.card,
          child: Column(
            children: [
              if (hasPersonalInfo)
                Container(
                  color: settingsController.selectedContainerIndex == 0
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    name: S.of(context).personalInformation,
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_hr_employee_request.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: settingsController.selectedContainerIndex == 0
                          ? AppColors.secondaryPrimary
                          : AppColors.secondaryPrimary,
                    ),
                    index: 0,
                    selectIndex: settingsController.selectedContainerIndex,
                    isSelected: settingsController.selectedContainerIndex == 0,
                    onTap: isMobile
                        ? () {
                            _open(context, Routes.settingsPersonalInfo);
                          }
                        : null, // Null for tablet - will use default selection behavior
                  ),
                ),
              if (hasHealthInsurance)
                Container(
                  color: settingsController.selectedContainerIndex == 10
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    name: S.of(context).healthInsurance,
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_hr_health_insurance.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: settingsController.selectedContainerIndex == 10
                          ? AppColors.secondaryPrimary
                          : AppColors.secondaryPrimary,
                    ),
                    index: 10,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () => _open(context, Routes.settingsHealthInsurance)
                        : null,
                  ),
                ),
              if (hasSocialInfo)
                Container(
                  color: settingsController.selectedContainerIndex == 12
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    name: S.of(context).socialInformation,
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          // 24/10/2026 (Moataz: "not like the others, as thickness"):
                          // the old glyph was tiny filled shapes, and the plain
                          // two-person line icon was not wanted. Three people
                          // joined by lines — outlined and stroke-drawn, so it
                          // takes the same thickness as the rows around it.
                          'assets/icons_assets/main_icons_assets/ic_org_people_network.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: settingsController.selectedContainerIndex == 12
                          ? AppColors.secondaryPrimary
                          : AppColors.secondaryPrimary,
                    ),
                    index: 12,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () => _open(context, Routes.settingsSocial)
                        : null,
                  ),
                ),
              if (hasRequests)
                Container(
                  color: settingsController.selectedContainerIndex == 13
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    name: S.of(context).requests,
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_module_requests.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: settingsController.selectedContainerIndex == 13
                          ? AppColors.secondaryPrimary
                          : AppColors.secondaryPrimary,
                    ),
                    index: 13,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () => _open(context, Routes.settingsRequests)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildCompanyCard(
    bool hasCompanyInfo,
    SettingsController settingsController,
    bool lightMode,
    BuildContext context,
    bool isMobile,
    bool hasHomeLayout,
    bool hasBrandingTheme,
    bool hasWatermark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r), // Owner 24/10/2026: same curve as the right-side cards
        child: Container(
          // card, not background: rows have fractional heights, and the
          // darker background showed through as lines between them (Moataz 18/10).
          color: AppColors.card,
          child: Column(
            children: [
              if (hasCompanyInfo)
                Container(
                  color: settingsController.selectedContainerIndex == 8
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    name: S.of(context).companyInformation,
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_org_company_information.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: settingsController.selectedContainerIndex == 8
                          ? AppColors.secondaryPrimary
                          : AppColors.secondaryPrimary,
                    ),
                    index: 8,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () => _open(context, Routes.settingsCompanyInfo)
                        : null,
                  ),
                ),
              if (hasHomeLayout)
                Container(
                  color: settingsController.selectedContainerIndex == 15
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    onTap: () {
                      _open(context, Routes.settingsHomeLayout);
                    },
                    name: S.of(context).homeLayout,
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_module_home_layout.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                    index: 15,
                    selectIndex: settingsController.selectedContainerIndex,
                  ),
                ),
              if (hasBrandingTheme)
                Container(
                  color: settingsController.selectedContainerIndex == 14
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    name: S.of(context).brandingAndTheme,
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_module_branding_theme.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: settingsController.selectedContainerIndex == 14
                          ? AppColors.secondaryPrimary
                          : AppColors.secondaryPrimary,
                    ),
                    index: 14,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () => _open(context, Routes.settingsBrandingAndTheme)
                        : null,
                  ),
                ),
              // ADDED 25/8/2026 — Settings > Home
              // Layout > Watermark (Figma
              // 7524:14303). Sits directly under
              // Home Layout because it configures
              // what is drawn OVER the layout.
              //
              // CHANGED 31/8/2026 — always pushes a
              // full route, exactly like Home Layout
              // (index 15) directly above it. The
              // Figma frame (4717:8596) is a full
              // 1024-wide page — a 280 controls
              // column PLUS a preview pane wide
              // enough to read a tiled stamp.
              // Squeezed into the settings right-hand
              // panel the preview collapsed and the
              // design stopped being legible. A
              // watermark you cannot see is a
              // watermark you cannot tune.
              //
              // CHANGED 31/8/2026 — gated by its own
              // `hasWatermark` permission. It used to
              // ride on `hasHomeLayout`, which is
              // hardcoded true, so the row was
              // unhideable.
              //
              // `onTap` is unconditional, so `index`
              // is now only used for the pressed
              // highlight — nothing renders against
              // selectedContainerIndex == 18 any more.
              if (hasWatermark)
                Container(
                  color: settingsController.selectedContainerIndex == 18
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    onTap: () {
                      _open(context, Routes.settingsWatermark);
                    },
                    name: S.of(context).watermark,
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_group.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                    index: 18,
                    selectIndex: settingsController.selectedContainerIndex,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildGeneralCard(
    bool hasLanguage,
    SettingsController settingsController,
    bool lightMode,
    BuildContext context,
    bool isMobile,
    bool hasCommentsAndFeedbacks,
    bool hasAboutApp,
    bool hasPrivacyStatement,
    bool hasTermsConditions,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r), // Owner 24/10/2026: same curve as the right-side cards
        child: Container(
          color: AppColors.card,
          child: Column(
            children: [
              if (hasLanguage)
                Container(
                  color: settingsController.selectedContainerIndex == 2
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_module_language_settings.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                    name: S.of(context).language,
                    index: 2,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () => _open(context, Routes.settingsLanguage)
                        : null,
                  ),
                ),
              if (hasCommentsAndFeedbacks)
                Container(
                  color: settingsController.selectedContainerIndex == 4
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_module_feedback.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                    name: S.of(context).commentsAndFeedbacks,
                    index: 4,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () =>
                            _open(context, Routes.settingsCommentsAndFeedback)
                        : null,
                  ),
                ),
              if (hasAboutApp)
                Container(
                  color: settingsController.selectedContainerIndex == 5
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_module_about_app.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                    name: FormatHelper.capitalize(
                      S.of(context).aboutThisPlatform,
                    ),
                    index: 5,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () => _open(context, Routes.settingsAboutThisApp)
                        : null,
                  ),
                ),
              if (hasPrivacyStatement)
                Container(
                  color: settingsController.selectedContainerIndex == 16
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_module_privacy_statement.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: settingsController.selectedContainerIndex == 16
                          ? AppColors.secondaryPrimary
                          : AppColors.secondaryPrimary,
                    ),
                    name: S.of(context).privacyStatement,
                    index: 16,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () => _open(context, Routes.settingsPrivacyStatement)
                        : null,
                  ),
                ),
              if (hasTermsConditions)
                Container(
                  color: settingsController.selectedContainerIndex == 6
                      ? lightMode
                          ? AppColors.primary.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08)
                      : AppColors.card,
                  child: CustomCard(
                    icon: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_module_terms_conditions.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                    name: S.of(context).termsAndConditions2,
                    index: 6,
                    selectIndex: settingsController.selectedContainerIndex,
                    onTap: isMobile
                        ? () =>
                            _open(context, Routes.settingsTermsAndConditions)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildSystemPreferencesCard(
    bool hasHaptic,
    BuildContext context,
    HapticController hapticController,
    bool hasBiometrics,
    BiometricController biometricController,
    bool hasAnimation,
    bool hasNotification,
    NotificationController notificationController,
    bool hasRestrictedLocation,
    DevicePolicyController devicePolicyController,
  ) {
    return Padding(
      // Item 182 (21/10/2026): the SAME 16 between every group — this one
      // had 7 extra above and below.
      padding: EdgeInsets.symmetric(vertical: 0.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r), // Owner 24/10/2026: same curve as the right-side cards
        child: Container(
          color: AppColors.card,
          child: Column(
            children: [
              if (hasHaptic)
                CustomCard(
                  icon: Center(
                    child: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_module_haptic_feedback.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                  ),
                  name: S.of(context).hapticFeedback,
                  isSwitchTile: true,
                  currentValue: hapticController.isHapticEnabled.value == true,
                  onSwitchChanged: (value) {
                    hapticController.toggleHapticFeedback(value);
                    RestartWidget.restartApp(context);
                  },
                ),
              if (hasBiometrics)
                CustomCard(
                  icon: Center(
                    child: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_security_biometrics.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                  ),
                  name: S.of(context).biometrics,
                  isSwitchTile: true,
                  currentValue:
                      biometricController.isBiometricEnabled.value == true,
                  onSwitchChanged: (value) {
                    hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact,
                    );
                    biometricController.toggleBiometricFeedback(value);
                    RestartWidget.restartApp(context);
                  },
                ),
              CustomCard(
                icon: Center(
                  child: NormalizedStrokeSvg(
                    assetPath:
                        'assets/icons_assets/main_icons_assets/ic_module_dark_mode_toggle.svg',
                    width: 20.sp,
                    height: 20.sp,
                    fit: BoxFit.contain,
                    color: AppColors.secondaryPrimary,
                  ),
                ),
                name: S.of(context).darkMode,
                isSwitchTile: true,
                currentValue: this.themeController.currentTheme.value ==
                    AppColors.darkTheme,
                onSwitchChanged: (value) {
                  if (!mounted) return; // ✅ Add mounted check

                  hapticController.triggerHapticFeedback(
                    vibration: VibrateType.mediumImpact,
                    hapticFeedback: HapticFeedback.mediumImpact,
                  );
                  // Only toggle if the value actually changed
                  bool isDarkMode = this.themeController.currentTheme.value ==
                      AppColors.darkTheme;
                  if (value != isDarkMode) {
                    this.themeController.toggleTheme();
                    // Consider removing RestartWidget if not necessary
                    // RestartWidget.restartApp(context);
                  }
                },
              ),
              if (hasAnimation)
                CustomCard(
                  icon: Center(
                    child: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_module_animation.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                  ),
                  name: S.of(context).animation,
                  isSwitchTile: true,
                  currentValue: false,
                  onSwitchChanged: (value) {
                    hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact,
                    );
                  },
                ),
              // ADDED 31/8/2026 — Notification. Last
              // row of this card in the Figma frame,
              // directly under Animation. It stores a
              // preference and nothing more: see the
              // SCOPE note in NotificationController.
              if (hasNotification)
                CustomCard(
                  icon: Center(
                    child: NormalizedStrokeSvg(
                      assetPath:
                          'assets/icons_assets/settings_assets/ic_module_notification_settings.svg',
                      width: 26.sp,
                      height: 26.sp,
                      fit: BoxFit.contain,
                      color: AppColors.secondaryPrimary,
                    ),
                  ),
                  name: S.of(context).notification,
                  isSwitchTile: true,
                  currentValue:
                      notificationController.isNotificationEnabled.value,
                  onSwitchChanged: (value) {
                    hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact,
                    );
                    notificationController.toggleNotification(value);
                  },
                ),
              // REMOVED 31/8/2026 — the "Take Screen
              // Shot" switch tile. The device policy
              // itself (devicePolicyController
              // .toggleScreenShot / isScreenShotEnabled)
              // is untouched and still applied; only
              // the user-facing tile is gone.
              //
              // Restricted Location is not in the
              // Figma frame either, so it keeps its
              // place at the end of this card, after
              // Notification.
              //
              // Obx, unlike the switches above it:
              // the country picker has to appear and
              // disappear with the toggle, and the
              // tile's own internal state does not
              // rebuild this Column.
              if (hasRestrictedLocation)
                Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomCard(
                        icon: Center(
                          child: NormalizedStrokeSvg(
                            assetPath:
                                'assets/icons_assets/settings_assets/ic_place_city.svg',
                            width: 20.sp,
                            height: 20.sp,
                            fit: BoxFit.contain,
                            color: AppColors.secondaryPrimary,
                          ),
                        ),
                        name: S.of(context).restrictedLocation,
                        isSwitchTile: true,
                        currentValue: devicePolicyController
                            .isRestrictedLocationEnabled.value,
                        onSwitchChanged: (value) {
                          hapticController.triggerHapticFeedback(
                            vibration: VibrateType.mediumImpact,
                            hapticFeedback: HapticFeedback.mediumImpact,
                          );
                          devicePolicyController.toggleRestrictedLocation(
                            value,
                          );
                        },
                      ),
                      // Which countries the app may be
                      // opened from. Only meaningful
                      // while the restriction is on.
                      if (devicePolicyController
                          .isRestrictedLocationEnabled.value)
                        RestrictedLocationCountries(
                          controller: devicePolicyController,
                        ),
                    ],
                  ),
                ),
              // REMOVED 31/8/2026 — the "Screen Share"
              // switch tile, same as Take Screen Shot
              // above: the policy still runs, the
              // tile is no longer shown.
            ],
          ),
        ),
      ),
    );
  }

  Container _buildSelectedPanel(
    bool orientation,
    SettingsController settingsController,
    bool hasPersonalInfo,
    bool hasLanguage,
    bool hasCommentsAndFeedbacks,
    bool hasAboutApp,
    bool hasTermsConditions,
    bool hasCompanyInfo,
    bool hasHealthInsurance,
    bool hasSocialInfo,
    bool hasRequests,
    bool hasBrandingTheme,
    bool hasPrivacyStatement,
  ) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        // CHANGED 17/10/2026 (Moataz: panel not aligned with the menu, gaps
        // not equal): the panel's top lines up with the menu (0), and the gap
        // to the menu and to the window edge is the same 15.
        // Moataz 23/10/2026: iPad portrait 50/50 — 8 + 8 around the 16 gap,
        // so the menu card and the panel card are the same width.
        padding: EdgeInsetsDirectional.only(
            start: orientation ? 8.sp : 16.sp, end: 16.sp),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (settingsController.selectedContainerIndex == 0 &&
                hasPersonalInfo)
              const Expanded(child: PersonalInfoScreen()),
            if (settingsController.selectedContainerIndex == 2 && hasLanguage)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  width: double.infinity,
                  child: const LanguageScreen(),
                ),
              ),
            if (settingsController.selectedContainerIndex == 4 &&
                hasCommentsAndFeedbacks)
              const Expanded(child: CommentsAndFeedbackScreen()),
            if (settingsController.selectedContainerIndex == 5 && hasAboutApp)
              const Expanded(child: AboutThisAppScreen()),
            if (settingsController.selectedContainerIndex == 6 &&
                hasTermsConditions)
              const Expanded(child: TermsConditions()),
            if (settingsController.selectedContainerIndex == 8 &&
                hasCompanyInfo)
              Expanded(child: CompanyScreenInfo()),
            if (settingsController.selectedContainerIndex == 9)
              Expanded(child: Container()),
            if (settingsController.selectedContainerIndex == 10 &&
                hasHealthInsurance)
              Expanded(child: SettingsHealthInsurance()),
            if (settingsController.selectedContainerIndex == 12 &&
                hasSocialInfo)
              Expanded(child: SocialScreen()),
            if (settingsController.selectedContainerIndex == 13 && hasRequests)
              Expanded(child: MyRequestPage()),
            if (settingsController.selectedContainerIndex == 14 &&
                hasBrandingTheme)
              Expanded(child: CompanyInfoScreen()),
            if (settingsController.selectedContainerIndex == 16 &&
                hasPrivacyStatement)
              const Expanded(child: PrivacyStatementPage()),

            // ✅ FIXED: Wrapped with Expanded and SingleChildScrollView
            if (settingsController.selectedContainerIndex == 17)
              Expanded(
                child: SingleChildScrollView(
                  child: const EmployeeBrandingScreen(),
                ),
              ),

            // REMOVED 31/8/2026 — the Watermark right-hand panel.
            //
            // Watermark is a pushed page now (Routes.settingsWatermark),
            // the same as Home Layout above it. Leaving this branch in
            // would give the screen two homes: tapping the card would
            // push the route AND arm this panel behind it, so popping
            // back landed on a second copy of the screen instead of the
            // settings list. The `const Expanded(child: WatermarkScreen())`
            // that lived here is gone; the route in get_pages.dart is the
            // single entry point.
          ],
        ),
      ),
    );
  }
}
