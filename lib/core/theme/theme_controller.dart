/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: theme_controller.dart
/// Description: Declares `ThemeController`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// // ignore_for_file: sdk_version_since
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
////import 'package:knowticed_plus/core/theme/app_colors.dart';
// import 'package:knowticed_plus/features/onboarding/o2_intro/presentation/ui/services_management_module/onboarding.dart';
// import 'package:knowticed_plus/features/settings/presentation/controller/company_controller.dart';
// import 'app_theme.dart';
//
// class ThemeController extends GetxController {
//   final storage = GetStorage();
//   late Rx<ThemeData> currentTheme;
//   final RxBool isInitialized = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     currentTheme = AppColors.lightTheme.obs;
//
//     // Load theme data synchronously first
//     _loadThemeDataSync();
//
//     // Then initialize theme systems
//     Future.microtask(() {
//       initTheme(withMessage: false);
//       isInitialized.value = true;
//     });
//
//     // Setup listener for system UI updates
//     ever(currentTheme, (_) {
//       if (isInitialized.value) {
//         Future.microtask(() => updateSystemUIOverlayStyle());
//       }
//     });
//   }
//
//   void _loadThemeDataSync() {
//
//     // Load theme mode
//     final savedTheme = storage.read('theme');
//
//     if (savedTheme != null) {
//       if (savedTheme == 'darkMode') {
//         currentTheme.value = AppColors.darkTheme;
//         AppTheme.isDark = true;
//         AppTheme.isDark = true; // ✅ Sync main core
//       } else {
//         currentTheme.value = AppColors.lightTheme;
//         AppTheme.isDark = false;
//         AppTheme.isDark = false; // ✅ Sync main core
//       }
//     } else {
//       currentTheme.value = AppColors.lightTheme;
//       AppTheme.isDark = false;
//       AppTheme.isDark = false; // ✅ Sync main core
//     }
//
//     // Load and apply colors
//     final primaryColor = storage.read('primaryColor');
//     if (primaryColor != null) {
//       AppColors.lightPrimary = Color(int.parse(primaryColor));
//       AppColors.secondaryPrimary = Color(int.parse(primaryColor));
//     }
//
//     final secondaryColor = storage.read('secondaryColor');
//     if (secondaryColor != null) {
//       AppColors.primary = Color(int.parse(secondaryColor));
//       AppColors.primary = Color(int.parse(secondaryColor));
//       AppColors.primary = Color(int.parse(secondaryColor));
//     }
//
//     // ✅ CRITICAL: Synchronize AppTheme with loaded state
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors(); // ✅ Sync main core colors
//
//   }
//
//   void updateSystemUIOverlayStyle() {
//     if (Get.context != null) {
//       bool isTablet = !kpIsPhoneLayout(Get.context!);
//       if (isTablet) {
//         updateSystemUIOverlayStyleTablet();
//       } else {
//         updateSystemUIOverlayStyleMobile();
//       }
//     }
//   }
//
//   void updateSystemUIOverlayStyleMobile() {
//     if (currentTheme.value == AppColors.lightTheme) {
//       SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(
//           statusBarColor: AppColors.lightGrey,
//           statusBarIconBrightness: Brightness.dark,
//           statusBarBrightness: Brightness.light,
//         ),
//       );
//     } else {
//       SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(
//           statusBarColor: AppColors.colorBlack,
//           statusBarIconBrightness: Brightness.light,
//           statusBarBrightness: Brightness.dark,
//         ),
//       );
//     }
//   }
//
//   void updateSystemUIOverlayStyleTablet() {
//     if (currentTheme.value == AppColors.lightTheme) {
//       SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(
//           statusBarColor: AppColors.colorWhite,
//           statusBarIconBrightness: Brightness.dark,
//           statusBarBrightness: Brightness.light,
//         ),
//       );
//     } else {
//       SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(
//           statusBarColor: AppColors.greyDark,
//           statusBarIconBrightness: Brightness.light,
//           statusBarBrightness: Brightness.dark,
//         ),
//       );
//     }
//   }
//
//   void toggleTheme() {
//
//     // Toggle theme mode
//     if (currentTheme.value == AppColors.lightTheme) {
//       currentTheme.value = AppColors.darkTheme;
//       storage.write('theme', 'darkMode');
//       AppTheme.isDark = true;
//       AppTheme.isDark = true; // ✅ Sync main core
//     } else {
//       currentTheme.value = AppColors.lightTheme;
//       storage.write('theme', 'lightMode');
//       AppTheme.isDark = false;
//       AppTheme.isDark = false; // ✅ Sync main core
//     }
//
//     // Log action
//     systemLogsController.systemLogsAction('change theme');
//
//     // ✅ Update color maps
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors();
//
// // Log action
//     systemLogsController.systemLogsAction('change theme');
//
//
//
//
//     // ✅ CRITICAL: Update color maps BEFORE toggling other modules
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors();
//
//     // Synchronize all theme systems
//
//     AppTheme.toggleTheme();
//
//     try {
//             .messagingConfigurations
//             .toggleTheme();
//       }
//     } catch (e) {
//     }
//
//     // Note: This toggles isDark again, but we already set it above
//     // AppTheme.toggleTheme();
//
//     // Update UI in post frame callback
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       updateSystemUIOverlayStyle();
//       Get.forceAppUpdate();
//     });
//   }
//
//   initTheme({bool withMessage = true}) {
//
//     final int primaryColor =
//     int.parse(storage.read('primaryColor') ?? '0xFFFFDE59');
//     final int secondaryColor =
//     int.parse(storage.read('secondaryColor') ?? '0xFFE5B800');
//     Color primary = Color(primaryColor);
//     Color secondary = Color(secondaryColor);
//
//     // ✅ FIX: Use the actual theme state from currentTheme
//     bool isDark = currentTheme.value == AppColors.darkTheme;
//
//
//     // ✅ Ensure all theme systems are in sync
//     AppTheme.isDark = isDark;
//     AppTheme.isDark = isDark;
//
//     // Initialize messaging module if needed
//     if (withMessage) {
//       try {
//               .messagingConfigurations
//               .initTheme(primary, secondary, isDark);
//         }
//       } catch (e) {
//       }
//     }
//
//     // Initialize other theme systems with correct dark mode state
//     AppTheme.initTheme(primary, secondary, isDark);
//     AppTheme.initTheme(primary, secondary, isDark);
//
//     // ✅ CRITICAL: Update color maps after init
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors();
//
//   }
//
//   CompanyController addCompanyController = Get.put(CompanyController());
//
//   void updatePrimaryColor() {
//
//     final String? colorValue =
//     addCompanyController.company!.status! == 'active'
//         ? addCompanyController
//         .company!.primaryColor!.primaryColor?.lastOrNull
//         : null;
//
//
//     storage.write('primaryColor', colorValue);
//
//     AppColors.lightPrimary = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFFFDE59);
//
//     AppColors.secondaryPrimary = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFFFDE59);
//
//
//     // Refresh current theme to apply new color
//     if (currentTheme.value == AppColors.lightTheme) {
//       currentTheme.value = AppColors.lightTheme;
//       AppColors.textButton;
//     } else {
//       currentTheme.value = AppColors.darkTheme;
//       AppColors.textButton;
//     }
//
//     // Update modules AFTER setting the storage values
//     updateModulesBranding();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Get.forceAppUpdate();
//     });
//
//   }
//
//   void updateSecondaryColor() {
//
//     final String? colorValue =
//     addCompanyController.company!.status! == 'active'
//         ? addCompanyController
//         .company!.secondaryColor!.secondaryColor?.lastOrNull
//         : null;
//
//
//     storage.write('secondaryColor', colorValue);
//
//     AppColors.primary = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFE5B800);
//
//     AppColors.primary = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFE5B800);
//
//     AppColors.primary = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFE5B800);
//
//
//     // Refresh current theme to apply new color
//     if (currentTheme.value == AppColors.lightTheme) {
//       currentTheme.value = AppColors.lightTheme;
//     } else {
//       currentTheme.value = AppColors.darkTheme;
//     }
//
//     // Update modules AFTER setting the storage values
//     updateModulesBranding();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Get.forceAppUpdate();
//     });
//
//   }
//
//   updateModulesBranding() {
//
//     final int primaryColor =
//     int.parse(storage.read('primaryColor') ?? '0xFFFFDE59');
//     final int secondaryColor =
//     int.parse(storage.read('secondaryColor') ?? '0xFFE5B800');
//
//     try {
//             .messagingConfigurations
//             .updateBrandingColors(
//             Color(primaryColor), Color(secondaryColor));
//       }
//     } catch (e) {
//     }
//
//     AppTheme.interfaceUpdateBrandingColors(
//         Color(primaryColor), Color(secondaryColor));
//     AppTheme.interfaceUpdateBrandingColors(
//         Color(primaryColor), Color(secondaryColor));
//
//     // ✅ Update color maps after branding changes
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors();
//
//   }
//
//   void updateFonts() {
//
//     String? currentFontInStorage = storage.read('font');
//     String? currentArabicFontInStorage = storage.read('font_arabic');
//
//
//
//     // ✅ FIX: Only update from company data if storage is null or empty
//     // This preserves user's font selection in branding screen
//     if (currentFontInStorage == null || currentFontInStorage.isEmpty) {
//       storage.write(
//           'font',
//           addCompanyController.company!.status! == 'active'
//               ? addCompanyController
//               .company!.englishFont!.englishFont?.lastOrNull?.capitalize
//               : null);
//       currentFontInStorage = storage.read('font');
//     } else {
//     }
//
//     if (currentArabicFontInStorage == null || currentArabicFontInStorage.isEmpty) {
//       storage.write(
//           'font_arabic',
//           addCompanyController.company!.status! == 'active'
//               ? addCompanyController
//               .company!.arabicFont!.arabicFont?.lastOrNull?.capitalize
//               : null);
//       currentArabicFontInStorage = storage.read('font_arabic');
//     } else {
//     }
//
//
//     AppColors.font = Get.locale.toString().contains('ar')
//         ? currentArabicFontInStorage ?? 'Vazirmatn'
//         : currentFontInStorage ?? 'Cairo';
//
//
//     StyleText.fontSize16Weight400 = TextStyle(
//       color: Colors.black,
//       fontFamily: Get.locale.toString().contains('ar')
//           ? currentArabicFontInStorage ?? 'Vazirmatn'
//           : currentFontInStorage ?? 'Cairo',
//       fontWeight: FontWeight.normal,
//       fontSize: 17,
//     );
//
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Get.forceAppUpdate();
//     });
//
//   }
//
//
//     void loadThemeFromStorage() {
//     // This method is now replaced by _loadThemeDataSync() in onInit
//     // Keep it for backward compatibility if called elsewhere
//     _loadThemeDataSync();
//   }
// }

// ignore_for_file: sdk_version_since
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

part 'theme_controller/theme_controller_methods.dart';

class ThemeController extends GetxController {
  /// The company cubit is injected from main(), which owns it. It stays
  /// optional so the handful of bare `Get.put(ThemeController())` call sites
  /// still compile; those resolve the already-registered instance lazily.
  ThemeController({CompanyCubit? companyCubit})
      : _injectedCompanyCubit = companyCubit;

  final CompanyCubit? _injectedCompanyCubit;

  final storage = GetStorage();
  late Rx<ThemeData> currentTheme;
  final RxBool isInitialized = false.obs;

  /// Global "play animations" preference, honoured by SlideAnimation and any
  /// other opt-in animated widget. Previously lived on GRCThemeController in
  /// data_grc_module; that module was removed, so it lives here now.
  final RxBool animationsEnabled = true.obs;

  static const String _kAnimationsEnabled = 'animationsEnabled';

  @override
  void onInit() {
    super.onInit();

    loadAnimationsSetting();

    // ⚠️ AppColors.lightTheme / darkTheme use .sp (ScreenUtil) which requires
    // ScreenUtilInit to be mounted. ThemeController is created in main() before
    // the widget tree, so we can't call AppColors.lightTheme here.
    // Use a plain placeholder; _applyRealTheme() swaps it in post-frame.
    currentTheme = ThemeData.light().obs;

    // Load isDark + brand colors from storage (no .sp calls)
    _loadThemePrefsSync();

    // After ScreenUtilInit mounts, apply the real themed ThemeData.
    // _applyRealTheme() will call initTheme + set isInitialized once it succeeds.
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyRealTheme());

    // Setup listener for system UI updates
    ever(currentTheme, (_) {
      if (isInitialized.value) {
        Future.microtask(() => updateSystemUIOverlayStyle());
      }
    });
  }

  /// Applies the real AppColors.lightTheme / darkTheme once ScreenUtil is ready.
  /// If ScreenUtil hasn't been initialized yet (LateInitializationError from .sp
  /// calls), retries on the next frame. initTheme + isInitialized are only set
  /// after a successful apply so they never run with a half-built theme.
  void _applyRealTheme() {
    try {
      currentTheme.value =
          AppTheme.isDark ? AppColors.darkTheme : AppColors.lightTheme;
      AppTheme.isDark = AppTheme.isDark;
      AppTheme.setCurrentThemeColors();
      AppTheme.setCurrentThemeColors();
      update();
      // Only mark as initialized after the theme is fully applied
      initTheme(withMessage: false);
      isInitialized.value = true;
    } catch (e) {
      // ScreenUtil not initialized yet — retry on the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyRealTheme());
    }
  }

  /// Loads isDark + brand colors from storage. Does NOT access AppColors.lightTheme
  /// or darkTheme — those use .sp and require ScreenUtil to be ready.
  /// Restores the animation preference from storage. Defaults to enabled.
  void loadAnimationsSetting() {
    animationsEnabled.value = storage.read(_kAnimationsEnabled) ?? true;
  }

  /// Enables or disables app-wide opt-in animations and persists the choice.
  /// Widgets read [animationsEnabled] directly, so no restart is required.
  void toggleAnimations(bool isEnabled) {
    animationsEnabled.value = isEnabled;
    storage.write(_kAnimationsEnabled, isEnabled);
    update();
  }

  void updateSystemUIOverlayStyle() {
    if (Get.context != null) {
      bool isTablet = !kpIsPhoneLayout(Get.context!);
      if (isTablet) {
        updateSystemUIOverlayStyleTablet();
      } else {
        updateSystemUIOverlayStyleMobile();
      }
    }
  }

  void updateSystemUIOverlayStyleMobile() {
    // Reads AppTheme.isDark rather than comparing ThemeData identities — see
    // the note in toggleTheme().
    if (!AppTheme.isDark) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.lightGrey,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.colorBlack,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    }
  }

  void updateSystemUIOverlayStyleTablet() {
    if (!AppTheme.isDark) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.colorWhite,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.greyDark,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    }
  }

  void initTheme({bool withMessage = true}) {
    final int primaryColor =
        int.parse(storage.read('primaryColor') ?? '0xFFFFDE59');
    final int secondaryColor =
        int.parse(storage.read('secondaryColor') ?? '0xFFE5B800');
    Color primary = Color(primaryColor);
    Color secondary = Color(secondaryColor);

    // FIXED 22/8/2026: was `currentTheme.value == AppColors.darkTheme`. During
    // the first `_applyRealTheme()` pass `currentTheme` can still hold the
    // plain `ThemeData.light()` placeholder from onInit, so this read reported
    // "light" and clobbered the `isDark` that `_loadThemePrefsSync()` had just
    // restored from storage — which is how a user who had chosen dark mode
    // landed back on the light sign-in/onboarding screens.
    final bool isDark = AppTheme.isDark;

    // Initialize other theme systems with correct dark mode state
    AppTheme.initTheme(primary, secondary, isDark);
    AppTheme.initTheme(primary, secondary, isDark);

    // ✅ CRITICAL: Update color maps after init
    AppTheme.setCurrentThemeColors();
    AppTheme.setCurrentThemeColors();
  }

  // ⚠️ Must NOT re-create the company cubit on every ThemeController
  // construction.
  //
  // ThemeController is created via `Get.put(ThemeController())` inside many
  // widget build() methods, so a new ThemeController is built every frame. The
  // old code had this as a *field* that called Get.put(CompanyController()),
  // which risked init() -> getCompany() -> update*Color() ->
  // Get.forceAppUpdate() -> rebuild -> re-create... an infinite loop.
  //
  // It is now a getter over the single instance main() created, so no
  // construction happens here at all. The name is unchanged so the ~20 read
  // sites below (`addCompanyController.company?...`) keep working — CompanyCubit
  // exposes the same `company` accessor the GetX controller did.
  CompanyCubit get addCompanyController =>
      _injectedCompanyCubit ?? Get.find<CompanyCubit>();

  SystemLogsController get systemLogsController => Get.find();

  void updateModulesBranding() {
    final int primaryColor =
        int.parse(storage.read('primaryColor') ?? '0xFFFFDE59');
    final int secondaryColor =
        int.parse(storage.read('secondaryColor') ?? '0xFFE5B800');

    AppTheme.interfaceUpdateBrandingColors(
        Color(primaryColor), Color(secondaryColor));
    AppTheme.interfaceUpdateBrandingColors(
        Color(primaryColor), Color(secondaryColor));

    // ✅ Update color maps after branding changes
    AppTheme.setCurrentThemeColors();
    AppTheme.setCurrentThemeColors();
  }

  void loadThemeFromStorage() {
    _loadThemePrefsSync();
    _applyRealTheme();
  }
}

/// The app-wide theme controller.
///
/// Moved here 12/8/2026 from `o2_intro/presentation/ui/pages/onboarding.dart`,
/// where it was one of three file-scope `Get.find()` / `Get.put(ThemeController())`
/// globals that ran on import — so simply importing the onboarding *page*
/// registered a controller as a side effect (CR-SKEL-O2-N04). Twenty files
/// imported that page for this one symbol, and `core/theme/theme_controller.dart`
/// imported the page back, making core depend on a feature.
///
/// A lazy getter, not a `final`: it resolves on first read rather than at
/// import time, and registers the controller only if the bindings have not.
ThemeController get themeController => Get.isRegistered<ThemeController>()
    ? Get.find<ThemeController>()
    : Get.put(ThemeController());
