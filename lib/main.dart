// ignore_for_file: sdk_version_since

import 'package:demo_app/core/utils/toogle_control.dart';
import 'package:demo_app/firebase/dev/firebase_options.dart';
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:demo_app/core/services/notifications/flutter_local_notification_handler.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/features/onboarding/authentication/presentation/controller/login_controller.dart';
import 'package:demo_app/features/settings/presentation/controller/request_controller.dart';
import 'package:demo_app/core/helper/todo_new_module/todo_stub.dart';
import 'package:demo_app/core/helper/events/events_stub.dart';
import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/home/presentation/ui/pages/no_internet_screen.dart';
import 'package:demo_app/features/onboarding/splash_screen.dart';

import 'core/constants/translation.dart';
import 'generated/l10n.dart';

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

    // test
    // Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Core controllers
    Get.put(MainCoreEmployeeController());
    Get.put(MainCoreDepartmentController());

    // ScreenUtil
    await ScreenUtil.ensureScreenSize();

    // FCM (mobile only)
    if (!Platform.isWindows &&
        !Platform.isLinux &&
        !Platform.isMacOS &&
        !Platform.isIOS) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
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
    String localeData = box.read<String>('LocaleData') ??
        Get.deviceLocale?.toString() ??
        'en_US';
    bool isArabic = localeData.contains('ar');
    await S.load(Locale(isArabic ? 'ar' : 'en'));
    Intl.defaultLocale = isArabic ? 'ar' : 'en';

    // Register controllers needed early (before splash screen navigation)
    Get.put(SystemLogsController());
    // RequestController must be registered before LoginController, whose
    // constructor calls Get.find<RequestController>().
    Get.lazyPut(() => RequestController());
    // ScheduleController (home screen) calls Get.find for these stub controllers.
    Get.lazyPut(() => TodoController());
    Get.lazyPut(() => EventsEmployeeController());
    Get.lazyPut(() => LoginController());

    // Theme
    final themeController = Get.put(ThemeController());
    final themeCubit = Get.put(ThemeAndLocalizationsCubit());

    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();

    runApp(MyApp(themeCubit, themeController));
  }, (error, stack) {
    print('App error: $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp(this.themeCubit, this.themeController, {super.key});

  final ThemeAndLocalizationsCubit themeCubit;
  final ThemeController themeController;

  Size _getDesignSize(double w, double h) {
    if (w >= 1920) return const Size(1920, 1080);
    if (w >= 1366) return const Size(1366, 768);
    if (w >= 768) return w > h ? const Size(1024, 768) : const Size(768, 1024);
    return w > h ? const Size(812, 375) : const Size(375, 812);
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final localeData =
        box.read<String>('LocaleData') ?? Get.deviceLocale.toString();
    final isArabic = localeData.contains('ar');
    final targetLocale =
        isArabic ? const Locale('ar', 'EG') : const Locale('en', 'US');

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
            ],
            child: GetBuilder<ThemeController>(
              builder: (controller) => GetMaterialApp(
                navigatorKey: globalNavigatorKey,
                theme: controller.currentTheme.value,
                translations: AppTranslation(),
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
                home: OfflineBuilder(
                  connectivityBuilder: (ctx, connectivity, child) {
                    final connected = connectivity != ConnectivityResult.none;
                    return connected
                        ? SplashScreen()
                        : const NoInternetScreen();
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
