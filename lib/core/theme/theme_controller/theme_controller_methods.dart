/// Module: core/theme
///
///*************************** FILE INFO ****************************///
/// File Name: theme_controller_methods.dart
/// Description: Methods of `ThemeController` — split out of `theme_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../theme_controller.dart';

// Split from theme_controller.dart to keep every file under 700 lines.

extension ThemeControllerMethods on ThemeController {
  void _loadThemePrefsSync() {
    // Load theme mode (sets isDark flags only — ThemeData set post-frame)
    final savedTheme = storage.read('theme');
    if (savedTheme == 'darkMode') {
      AppTheme.isDark = true;
      AppTheme.isDark = true;
    } else {
      AppTheme.isDark = false;
      AppTheme.isDark = false;
    }

    // Load and apply brand colors
    final primaryColor = storage.read('primaryColor');
    if (primaryColor != null) {
      final primary = Color(int.parse(primaryColor));
      AppTheme.lightThemeColors['primary'] = primary;
      AppTheme.lightThemeColors['lightPrimary'] = primary;
      AppTheme.darkThemeColors['primary'] = primary;
      AppTheme.darkThemeColors['lightPrimary'] = primary;
      AppColors.currentThemeColors['primary'] = primary;
      AppColors.currentThemeColors['lightPrimary'] = primary;
    }

    final secondaryColor = storage.read('secondaryColor');
    if (secondaryColor != null) {
      final secondary = Color(int.parse(secondaryColor));
      AppTheme.lightThemeColors['secondaryPrimary'] = secondary;
      AppTheme.darkThemeColors['secondaryPrimary'] = secondary;
      AppColors.currentThemeColors['secondaryPrimary'] = secondary;
    }

    // Sync color maps (no .sp calls here)
    AppTheme.setCurrentThemeColors();
    AppTheme.setCurrentThemeColors();
  }

  void toggleTheme() {
    // Toggle theme mode.
    //
    // FIXED 22/8/2026: the branch used to be
    // `if (currentTheme.value == AppColors.lightTheme)`, i.e. it asked the
    // *ThemeData* which mode we were in. That is a fragile source of truth —
    // `updatePrimaryColor` / `updateSecondaryColor` reassign `currentTheme`,
    // and any path that leaves it holding something that is neither the
    // `lightTheme` nor the `darkTheme` singleton (the plain
    // `ThemeData.light()` placeholder set in onInit, for one) falls into the
    // else branch and forces light. `AppTheme.isDark` is the flag that is
    // actually persisted to storage and restored on launch, so it is the one
    // piece of state every read below now agrees on.
    final bool goingDark = !AppTheme.isDark;

    AppTheme.isDark = goingDark;
    currentTheme.value = goingDark ? AppColors.darkTheme : AppColors.lightTheme;
    storage.write('theme', goingDark ? 'darkMode' : 'lightMode');

    // Log action
    systemLogsController.systemLogsAction('change theme');

    // Rebuild the active colour map from the isDark flag set above.
    //
    // ⚠️ Do NOT call AppTheme.toggleTheme() here. That method is
    // `isDark = !isDark; setCurrentThemeColors();` — it flips the flag a
    // *second* time and immediately undoes the branch above, so the theme
    // always snapped back to its previous value. Assign isDark explicitly
    // (done above) and only refresh the colour map here.
    AppTheme.setCurrentThemeColors();

    // main.dart wraps GetMaterialApp in GetBuilder<ThemeController>, which
    // rebuilds on update() — not on currentTheme's Rx stream. Without this the
    // new ThemeData only reaches MaterialApp via Get.forceAppUpdate().
    update();

    // Update UI in post frame callback
    //
    // 24/10/2026 (Moataz: the dark mode switch lags): the third full rebuild
    // (`Get.forceAppUpdate()` here) is gone — `setCurrentThemeColors()` above
    // and `update()` already rebuild the app, so the same rebuild ran 3 times.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateSystemUIOverlayStyle();
    });
  }

  // ✅ FIXED: Check GetStorage FIRST for employee branding, fallback to company branding
  void updatePrimaryColor() {
    // Step 1: Check if there's already a value in GetStorage (employee branding)
    String? existingColorInStorage = storage.read('primaryColor');

    String? colorValue;

    // Step 2: If storage is empty, load from company branding
    if (existingColorInStorage == null || existingColorInStorage.isEmpty) {
      colorValue = addCompanyController.company?.status == 'active'
          ? addCompanyController.company?.primaryColor?.primaryColor?.lastOrNull
          : null;

      if (colorValue != null && colorValue.isNotEmpty) {
        storage.write('primaryColor', colorValue);
      }
    } else {
      // Use existing storage value (employee branding)
      colorValue = existingColorInStorage;
    }

    final primaryColor = colorValue != null && colorValue.isNotEmpty
        ? Color(int.parse(colorValue))
        : const Color(0xFFFFDE59);
    AppTheme.lightThemeColors['primary'] = primaryColor;
    AppTheme.lightThemeColors['lightPrimary'] = primaryColor;
    AppTheme.darkThemeColors['primary'] = primaryColor;
    AppTheme.darkThemeColors['lightPrimary'] = primaryColor;
    AppColors.currentThemeColors['primary'] = primaryColor;
    AppColors.currentThemeColors['lightPrimary'] = primaryColor;

    // Step 4: Refresh current theme to apply new color.
    //
    // FIXED 22/8/2026: this used to decide light-vs-dark by comparing
    // `currentTheme.value` against the `AppColors.lightTheme` singleton. This
    // method runs when company branding arrives — which is *before*
    // `_applyRealTheme()` has swapped the `ThemeData.light()` placeholder set
    // in onInit for the real theme. The placeholder is not identical to
    // `AppColors.lightTheme`, so the comparison fell through to the else
    // branch and the app's mode was decided by whichever ThemeData instance
    // happened to be in the Rx at that moment rather than by the user's saved
    // preference. `AppTheme.isDark` is what `_loadThemePrefsSync()` restores
    // from storage, so it is the source of truth here.
    currentTheme.value =
        AppTheme.isDark ? AppColors.darkTheme : AppColors.lightTheme;

    // Step 5: Update modules AFTER setting the storage values
    updateModulesBranding();

    // Step 6: Force UI update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.forceAppUpdate();
    });
  }

  // ✅ FIXED: Check GetStorage FIRST for employee branding, fallback to company branding
  void updateSecondaryColor() {
    // Step 1: Check if there's already a value in GetStorage (employee branding)
    String? existingColorInStorage = storage.read('secondaryColor');

    String? colorValue;

    // Step 2: If storage is empty, load from company branding
    if (existingColorInStorage == null || existingColorInStorage.isEmpty) {
      colorValue = addCompanyController.company?.status == 'active'
          ? addCompanyController
              .company?.secondaryColor?.secondaryColor?.lastOrNull
          : null;

      if (colorValue != null && colorValue.isNotEmpty) {
        storage.write('secondaryColor', colorValue);
      }
    } else {
      // Use existing storage value (employee branding)
      colorValue = existingColorInStorage;
    }

    // Step 3: Apply the color to theme

    final secondaryColor = colorValue != null && colorValue.isNotEmpty
        ? Color(int.parse(colorValue))
        : const Color(0xFFE5B800);
    AppTheme.lightThemeColors['secondaryPrimary'] = secondaryColor;
    AppTheme.darkThemeColors['secondaryPrimary'] = secondaryColor;
    AppColors.currentThemeColors['secondaryPrimary'] = secondaryColor;

    // Step 4: Refresh current theme to apply new color.
    //
    // FIXED 22/8/2026: this used to decide light-vs-dark by comparing
    // `currentTheme.value` against the `AppColors.lightTheme` singleton. This
    // method runs when company branding arrives — which is *before*
    // `_applyRealTheme()` has swapped the `ThemeData.light()` placeholder set
    // in onInit for the real theme. The placeholder is not identical to
    // `AppColors.lightTheme`, so the comparison fell through to the else
    // branch and the app's mode was decided by whichever ThemeData instance
    // happened to be in the Rx at that moment rather than by the user's saved
    // preference. `AppTheme.isDark` is what `_loadThemePrefsSync()` restores
    // from storage, so it is the source of truth here.
    currentTheme.value =
        AppTheme.isDark ? AppColors.darkTheme : AppColors.lightTheme;

    // Step 5: Update modules AFTER setting the storage values
    updateModulesBranding();

    // Step 6: Force UI update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.forceAppUpdate();
    });
  }

  void updateFonts() {
    String? currentFontInStorage = storage.read('font');
    String? currentArabicFontInStorage = storage.read('font_arabic');

    // ✅ FIX: Only update from company data if storage is null or empty
    // This preserves user's font selection in branding screen
    // `company?.status`, not `company!.status!` (23/8/2026). This method is now
    // also called when the company is inactive — the reset path — where the
    // two `!`s would throw if the cubit had no company loaded. The colour
    // methods above have always used `?.`; this matches them.
    final bool companyIsActive =
        addCompanyController.company?.status == 'active';

    if (currentFontInStorage == null || currentFontInStorage.isEmpty) {
      storage.write(
          'font',
          companyIsActive
              ? addCompanyController
                  .company?.englishFont?.englishFont?.lastOrNull?.capitalize
              : null);
      currentFontInStorage = storage.read('font');
    }

    if (currentArabicFontInStorage == null ||
        currentArabicFontInStorage.isEmpty) {
      storage.write(
          'font_arabic',
          companyIsActive
              ? addCompanyController
                  .company?.arabicFont?.arabicFont?.lastOrNull?.capitalize
              : null);
      currentArabicFontInStorage = storage.read('font_arabic');
    }

    // Font is read directly from storage by StyleText.englishFontFamily / arabicFontFamily
    // No assignment needed — storage was already written above.

    // StyleText.fontSize16Weight400 is a live getter now (17/10/2026);
    // nothing to re-assign here.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.forceAppUpdate();
    });
  }
}
