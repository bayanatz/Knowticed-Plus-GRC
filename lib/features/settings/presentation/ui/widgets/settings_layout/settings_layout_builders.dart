/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_layout_builders.dart
/// Description: UI builder methods of `_SettingsLayoutState` — split out of `settings_layout.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/settings_layout.dart';

// Split from settings_layout.dart to keep every file under 700 lines.

extension _SettingsLayoutStateBuilders on _SettingsLayoutState {
  Widget _buildContent(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    SettingsController settingsController = Get.find();
    final HapticController hapticController = Get.put(HapticController());
    final BiometricController biometricController = Get.put(
      BiometricController(),
    );
    // Reuse the instance main() registered at boot. Get.put here would build
    // a fresh controller on every rebuild, replacing the registered one and
    // leaking its screen-capture listener.
    final DevicePolicyController devicePolicyController =
        Get.isRegistered<DevicePolicyController>()
            ? Get.find<DevicePolicyController>()
            : Get.put(DevicePolicyController());
    // Same reuse rule as DevicePolicyController above: find the registered
    // instance if there is one, so the stored flag is not re-read into a fresh
    // controller on every rebuild.
    final NotificationController notificationController =
        Get.isRegistered<NotificationController>()
            ? Get.find<NotificationController>()
            : Get.put(NotificationController());
    final MainCoreEmployeeController mainCoreEmployeeController = Get.find();

    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Check permissions for each item
    bool hasPersonalInfo = true; // Usually always visible
    // CHANGED 9/10/2026 — Health Insurance and Social Information are back
    // (owner request; the Settings schema of 9 Oct keeps both as LIVE
    // sections). They had been hard-coded `false` on 28/9/2026, which hid the
    // two rows AND their right-hand panels on phone and on iPad portrait /
    // landscape alike.
    //
    //  * Health Insurance has no Settings permission of its own, so — like
    //    Personal Information and Requests — it is always listed. Viewing is
    //    harmless (it is the employee's own record); every edit goes through
    //    a change request that only a `Users_Requests` holder can approve.
    //  * Social Information is gated by Social Permissions →
    //    Share_Social_Information: the same master switch SocialScreen reads
    //    to decide whether it has anything to show or save. Without it the
    //    page would open empty, so the row is hidden instead.
    bool hasHealthInsurance = true;
    bool hasSocialInfo = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.socialPermissions,
      permission: SocialPermissions.shareSocialInformation,
    );
    bool hasRequests = true; // Usually always visible

    // Permission-based visibility checks
    bool hasBrandingTheme = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.branding,
    );

    bool hasHomeLayout = true; // Usually always visible

    // ADDED 31/8/2026 — Watermark now has its own permission instead of
    // riding on `hasHomeLayout` (hardcoded true), which left the row
    // permanently visible whatever the role said.
    bool hasWatermark = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.watermark,
    );

    bool hasCompanyInfo = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.companyInformation,
    );

    bool hasLanguage = true; // Usually always visible

    bool hasCommentsAndFeedbacks = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.commentAndFeedback,
    );

    bool hasAboutApp = true; // Usually always visible
    bool hasTermsConditions = true; // Usually always visible
    bool hasPrivacyStatement = true; // Usually always visible

    bool hasAnimation = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.animation,
    );

    bool hasBiometrics = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.biometricsForLogin,
    );

    // ADDED 31/8/2026 — Haptic Feedback and Notification. Both rows used to be
    // ungated: Haptic rendered unconditionally, and Notification did not exist
    // in this list at all.
    bool hasHaptic = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.haptic,
    );

    bool hasNotification = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.notification,
    );

    // Restricted Location. Unlike the gated menu entries above this does not
    // hide an existing menu entry — it gates a device behaviour, so it gets
    // its own switch tile in System Preferences below and the permission
    // decides whether the employee may see and change it.
    //
    // REMOVED 31/8/2026 — the `hasScreenShot` / `hasScreenShare` permission
    // lookups. Their tiles are gone from System Preferences (see below), so
    // the lookups had no reader left. SettingsPermissions.takeScreenShot and
    // .screenShare still exist on the role side; re-add the lookups here if
    // the tiles ever come back.
    // CHANGED 28/9/2026 — Restricted Location is no longer an employee
    // setting. The switch and its country picker moved to the role editor's
    // third page (Edit Role Settings Permissions, `settings_switches_page.dart`)
    // and are enforced for everyone holding that role by
    // `RestrictedLocationGuard`. The tile below is therefore never shown; the
    // branch is left in place only so this change stays a one-line revert.
    const bool hasRestrictedLocation = false;

    // NOTE: every hasX in this method that is hardcoded `true` is NOT
    // permission-gated. The gated ones are Company Information, Branding,
    // Notification, Haptic, Animation, Biometrics, Restricted Location,
    // Watermark and Comments and Feedbacks — nine of the eleven
    // SettingsPermissions, in the order the role page lists them. The other
    // two, Screen Share and Take Screen Shot, no longer have a row here (their
    // tiles were removed on 31/8/2026); they gate the device policy instead.
    // ADDED 9/10/2026: Social Information is also gated, but by a Social
    // Permissions switch (Share_Social_Information), not a SettingsPermission.
    // If one of these items goes missing, the cause is the role: no 'settings'
    // module access, or that flag turned off on the Edit Role Settings
    // Permissions screen.

    final lightMode =
        this.themeController.currentTheme.value.brightness == Brightness.light;
    var isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // **FIXED: Use theme controller instead of context for theme**
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile ? SizedBox(height: 50.sp) : SizedBox(height: 20.h),

          // ADDED 8/9/2026 — the page title, mobile only.
          //
          // Every other mobile page in the app gets its name from
          // SideFrameMasterServices, which draws a breadcrumb row above its
          // content. This page does not use that frame — it is pushed straight
          // as SettingsScreen -> SettingsLayout — so it opened with the profile
          // card at the top and nothing naming the screen.
          //
          // Tablet is unaffected: there the settings menu sits in the left
          // column of a two-pane layout whose right pane already carries the
          // page title, so a second "Settings" heading would just repeat it.
          //
          // Same style as the frame's own title (fontSize24Weight600) so the
          // heading matches the pages this list pushes to.
          //
          // BACK CHEVRON ADDED 8/9/2026 — same asset, rotation and pop as
          // SideFrameMasterServices uses, so this row reads as the frame's
          // breadcrumb even though the page does not use the frame. It renders
          // only when there is something to pop: reached from the app-bar gear
          // this page sits on the tab's navigator and can go back, but if it
          // ever becomes a tab root the chevron would be dead, and a back
          // button that does nothing is worse than none.
          if (isMobile) ...<Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              child: Row(
                children: <Widget>[
                  if (Navigator.of(context).canPop()) ...<Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticController.low(); // top-of-page navigation
                        Navigator.of(context).maybePop();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.sp),
                        child: Transform.rotate(
                          // The asset points right; in LTR "back" is left.
                          angle: isArabic ? 0 : 3.1416,
                          child: CustomSvgImage.natural(
                            assetPath:
                                'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg',
                            width: 24.sp,
                            height: 24.sp,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.sp),
                  ],
                  Expanded(
                    child: Text(
                      FormatHelper.capitalize(S.of(context).settings),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize24Weight600.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.sp),
          ],

          SettingsAppBar(
            startDate: settingsController.employee?.firstLogin,
            superVisor: settingsController.employee?.supervisor.lastOrNull,
            image: settingsController.employee?.photo.lastOrNull,
            name: _getEmployeeName(),
            role:
                settingsController.employee?.role.lastOrNull?.capitalize ?? '',
          ),
          isMobile
              ? SizedBox(height: 10.sp)
              : SizedBox(height: orientation ? 0.05.h : 0.02.h),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: isArabic
                              ? isMobile
                                  ? 10.sp
                                  : 0.sp
                              : 10.w,
                          right: isArabic
                              ? 10.w
                              : isMobile
                                  ? 10.sp
                                  : 0.w,
                        ),
                        child: Column(
                          children: [
                            // First Section (Figma order): Personal
                            // Information, Health Insurance, Social
                            // Information, Requests.
                            _buildAccountCard(
                              hasPersonalInfo,
                              settingsController,
                              lightMode,
                              context,
                              isMobile,
                              hasHealthInsurance,
                              hasSocialInfo,
                              hasRequests,
                            ),

                            SizedBox(height: 7.h),

                            // Second Section (Figma order): Company
                            // Information, Home Layout, Branding and Theme,
                            // WaterMark.
                            //
                            // RESTORED 2/9/2026 — these four rows had been
                            // folded into the First Section on 31/8/2026 as a
                            // single flat eight-row card. The Figma settings
                            // frame draws them as their own group, separate
                            // from the profile rows above and the support
                            // rows below, so the card boundary is back and
                            // the row order now follows the design exactly:
                            // Home Layout BEFORE Branding and Theme, with
                            // Watermark last.
                            _buildCompanyCard(
                              hasCompanyInfo,
                              settingsController,
                              lightMode,
                              context,
                              isMobile,
                              hasHomeLayout,
                              hasBrandingTheme,
                              hasWatermark,
                            ),

                            // Third Section (Figma order): Language, Comments
                            // and Feedbacks, About This App, Privacy
                            // Statement, Terms and Conditions.
                            //
                            // CHANGED 2/9/2026 — Privacy Statement now sits
                            // ABOVE Terms and Conditions, which is the order
                            // the Figma settings frame lists them in. The
                            // code had them the other way round.
                            //
                            // FIXED 23/8/2026: the five rows below took the
                            // dark-mode selected background from
                            // `AppColors.background` while the First and
                            // Second sections both use
                            // `AppColors.primary.withOpacity(.08)`. That made
                            // a selected row here read as a plain page-coloured
                            // block instead of the tinted highlight the rest of
                            // the list uses — and in dark mode `background` is
                            // close enough to `card` that the selection was
                            // barely visible at all. All five now match.
                            SizedBox(height: 7.h),
                            _buildGeneralCard(
                              hasLanguage,
                              settingsController,
                              lightMode,
                              context,
                              isMobile,
                              hasCommentsAndFeedbacks,
                              hasAboutApp,
                              hasPrivacyStatement,
                              hasTermsConditions,
                            ),

                            // Fourth Section: System Preferences (Haptic Feedback, Biometrics, Dark Mode, Animation)
                            SizedBox(height: 0),
                            _buildSystemPreferencesCard(
                              hasHaptic,
                              context,
                              hapticController,
                              hasBiometrics,
                              biometricController,
                              hasAnimation,
                              hasNotification,
                              notificationController,
                              hasRestrictedLocation,
                              devicePolicyController,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // CHANGED 17/10/2026 (Moataz: on a large screen "the
                // containers, my profile, the health — where did they go"):
                // the panel takes the remaining width (menu 2 : panel 3)
                // instead of a fixed 0.58.w that resolved to ~1 px.
                isMobile
                    ? const SizedBox()
                    : Expanded(
                        flex: 3,
                        child: _buildSelectedPanel(
                          orientation,
                          settingsController,
                          hasPersonalInfo,
                          hasLanguage,
                          hasCommentsAndFeedbacks,
                          hasAboutApp,
                          hasTermsConditions,
                          hasCompanyInfo,
                          hasHealthInsurance,
                          hasSocialInfo,
                          hasRequests,
                          hasBrandingTheme,
                          hasPrivacyStatement,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
