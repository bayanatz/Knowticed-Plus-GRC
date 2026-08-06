
import 'package:grc_module/core/theme/toogle_control.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:grc_module/features/notification/services/flutter_local_notification_handler.dart';
import 'package:grc_module/core/theme/theme_controller.dart';

import 'package:grc_module/features/onboarding/o3_authentication/presentation/controller/login_controller.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/controller/request_controller.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/firebase/dev/firebase_options.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/pages/no_internet_screen.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:grc_module/features/onboarding/o1_splash/splash_screen.dart';
import 'package:grc_module/features/home/main_controller/helper/todo_new_module/todo_stub.dart';
import 'package:grc_module/features/home/main_controller/helper/events/events_stub.dart';
import './generated/l10n.dart';
import 'package:get_it/get_it.dart';
import 'package:grc_module/features/grc/grc_get_it.dart';
import 'package:grc_module/features/grc/module/presentation/controller/cubit/grc_module_cubit.dart';

GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  FlutterLocalNotificationHandler.initialize();
  FlutterLocalNotificationHandler.showNotification(message);
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = FlutterError.presentError;

    // Fonts: use the .ttf files bundled in google_fonts/ instead of fetching
    // from fonts.gstatic.com at runtime. Avoids a network round-trip on every
    // cold start and works offline / inside the macOS sandbox.
    GoogleFonts.config.allowRuntimeFetching = false;

    // test
    // Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Department data. Owned by main() and provided to the tree below via
    // BlocProvider.value. Also registered with Get for the moment because the
    // legacy MainCoreEmployeeController still resolves it that way; that
    // registration goes away with the employee-controller conversion.
    // Must be registered BEFORE MainCoreEmployeeController, which resolves it.
    final departmentCubit = MainCoreDepartmentCubit();
    Get.put(departmentCubit);

    // Core controllers
    Get.put(MainCoreEmployeeController());

    // GRC dependency injection. The module resolves everything through
    // GetIt.instance (data sources, repositories, use cases, cubits), so this
    // must run before the GRC tab is opened — otherwise GrcResponsivePageLayout
    // throws "GRCModuleCubit is not registered inside GetIt".
    // Guarded so a hot restart doesn't re-register the same lazy singletons.
    if (!GetIt.instance.isRegistered<GRCModuleCubit>()) {
      setupGRCDependencies(GetIt.instance);
    }

    // ScreenUtil
    await ScreenUtil.ensureScreenSize();

    // FCM (mobile only)
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS && !Platform.isIOS) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await FlutterLocalNotificationHandler.initialize();
      await FirebaseMessaging.instance.requestPermission();
      FirebaseMessaging.onMessage.listen((msg) {
        FlutterLocalNotificationHandler.showNotification(msg);
      });
    }

    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // Storage
    await GetStorage.init();
    await Future.delayed(const Duration(milliseconds: 150));

    // Locale
    final box = GetStorage();
    String localeData = box.read<String>('LocaleData') ?? Get.deviceLocale?.toString() ?? 'en_US';
    bool isArabic = localeData.contains('ar');
    await S.load(Locale(isArabic ? 'ar' : 'en'));
    Intl.defaultLocale = isArabic ? 'ar' : 'en';

    // Register controllers needed early (before splash screen navigation)
    Get.put(SystemLogsController());
    // RequestController must be registered before LoginController, whose
    // constructor calls Get.find<RequestController>().
    Get.lazyPut(() => RequestController());
    // ScheduleController (home screen) calls Get.find for these stub controllers
    // in its constructor, so register them here before any home screen builds.
    Get.lazyPut(() => TodoController());
    Get.lazyPut(() => EventsEmployeeController());

    // Company branding cubit.
    // Created here rather than by a root BlocProvider because ThemeController
    // is constructed before runApp() and depends on it (and the cubit calls
    // back into themeController.update*). Same pattern as themeCubit below:
    // owned here, exposed to the widget tree via BlocProvider.value in MyApp.
    final companyCubit = Get.put(CompanyCubit());

    Get.lazyPut(() => LoginController(companyCubit));

    // Theme — company cubit injected explicitly so ThemeController never has
    // to reach into the service locator for it.
    final themeController = Get.put(ThemeController(companyCubit: companyCubit));
    // ✅ FIX: ModulesCubit (was ModulesController) was never registered (Knowticed_plus registers
    // it in main.dart). Without it, Get.find<ModulesCubit>() threw in
    // the "Add New Role" page and it showed "No modules available".
    Get.put(ModulesCubit());
    final themeCubit = Get.put(ThemeAndLocalizationsCubit());

    // Mirrors the old CompanyController.onInit(), which loaded the company in
    // an addPostFrameCallback so the first frame isn't blocked on Firestore.
    WidgetsBinding.instance.addPostFrameCallback((_) => companyCubit.bootstrap());

    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();

    runApp(MyApp(themeCubit, themeController, companyCubit, departmentCubit));
  }, (error, stack) {
    print('App error: $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  MyApp(this.themeCubit, this.themeController, this.companyCubit,
      this.departmentCubit,
      {super.key});

  final ThemeAndLocalizationsCubit themeCubit;
  final ThemeController themeController;
  final CompanyCubit companyCubit;

  /// Owned by main() (see comment there); exposed to the tree via
  /// BlocProvider.value in build().
  final MainCoreDepartmentCubit departmentCubit;

  Size _getDesignSize(double w, double h) {
    if (w >= 1920) return const Size(1920, 1080);
    if (w >= 1366) return const Size(1366, 768);
    if (w >= 768) return w > h ? const Size(1024, 768) : const Size(768, 1024);
    return w > h ? const Size(812, 375) : const Size(375, 812);
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final localeData = box.read<String>('LocaleData') ?? Get.deviceLocale.toString();
    final isArabic = localeData.contains('ar');
    final targetLocale = isArabic ? const Locale('ar', 'EG') : const Locale('en', 'US');

    return LayoutBuilder(
      builder: (context, constraints) {
        final mq = MediaQuery.of(context);
        final w = mq.size.width > 0 ? mq.size.width : constraints.maxWidth;
        final h = mq.size.height > 0 ? mq.size.height : constraints.maxHeight;

        return ScreenUtilInit(
          minTextAdapt: true,
          splitScreenMode: true,
          ensureScreenSize: true,
          designSize: _getDesignSize(w, h),
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: themeCubit),
              // Company branding/info. Owned by main() (see comment there),
              // provided by value so the whole widget tree can read it.
              BlocProvider.value(value: companyCubit),
              // Root-level AppHomeCubit — HomeScreenMobile (mobile nav Home tab)
              // reads it via context.read<AppHomeCubit>(), same as Knowticed.
              BlocProvider<AppHomeCubit>(create: (_) => AppHomeCubit()),
              // Department lookups, read across the app via
              // context.read<MainCoreDepartmentCubit>().
              BlocProvider.value(value: departmentCubit),

          // Knowledge Hub dashboard. Provided at the root (same as the
          // master app) so the home-page knowledge widgets and the module's
          // own screens all read one shared instance.




            ],
            child: GetBuilder<ThemeController>(
              builder: (controller) => GetMaterialApp(
                navigatorKey: globalNavigatorKey,
                theme: controller.currentTheme.value,
                defaultTransition: Transition.fadeIn,
                transitionDuration: const Duration(milliseconds: 300),
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: targetLocale,
                fallbackLocale: const Locale('en', 'US'),
                debugShowCheckedModeBanner: false,
                // Connectivity is an OVERLAY, not a gate.
                //
                // Previously this returned `SplashScreen()` or `NoInternetScreen`
                // and ignored `child`, so every connectivity event built a brand
                // new SplashScreen — re-running its initState (Get.find<LoginController>,
                // biometrics check, pushReplacement) and restarting the login flow
                // mid-authentication. It also meant a single spurious
                // `ConnectivityResult.none` at startup (common on macOS, where
                // connectivity_plus reports interface presence rather than real
                // reachability) replaced the whole app with the offline screen.
                //
                // Now `child` is passed straight through — the app subtree is
                // built once and preserved — and being offline only stacks a
                // banner on top.
                home: OfflineBuilder(
                  connectivityBuilder: (ctx, connectivity, child) {
                    final bool connected =
                        connectivity != ConnectivityResult.none;
                    if (connected) return child;
                    return Stack(
                      children: [
                        child,
                        const Align(
                          alignment: Alignment.topCenter,
                          child: NoInternetBanner(),
                        ),
                      ],
                    );
                  },
                  child: SplashScreen(),
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.2),
                    ),
                  ),
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


// ─── Notification tap handlers (stubs) ───────────────────────────────────────
Future<void> onTapOnNotificationMobile(String? payload, context) async {}
Future<void> onTapOnNotificationTablet(String? payload, context) async {}
