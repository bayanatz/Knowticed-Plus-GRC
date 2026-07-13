// Date Created :16/july/2023
// Developer Name : Mazen shabaan
//App Version : Version 1
// Date of Last Edit :1/October/2023
// Objectives:Used to show the on boarding images and texts
// ignore_for_file: unrelated_type_equality_checks, prefer_const_constructors, unused_field
import 'package:demo_app/features/onboarding/authentication/presentation/ui/pages/mobile_sign_in.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/onboarding/authentication/presentation/ui/pages/start_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/onboarding/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/features/onboarding/presentation/ui/pages/page_onBoarding.dart';
// import 'package:demo_app/components/on_boarding_components.dart/page_onboarding.dart';
import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/core/haptic/haptic_controller.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/mobile_sign_in.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/start_sign_in.dart';

import 'package:demo_app/core/nav_bar_package.dart/functions.dart';

class AllinOnboardModel {
  String imgStr;
  String description;
  String titlestr;
  AllinOnboardModel(this.imgStr, this.description, this.titlestr);
}

class WelcomeView extends StatefulWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  State<WelcomeView> createState() => _OnboardScreenState();
}

final ThemeController themeController = Get.find();
final ThemeController themeControllerCheck = Get.put(ThemeController());
final ThemeController mainCoreThemeController =
    Get.put(ThemeController());
double screenWidth =
    WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

class _OnboardScreenState extends State<WelcomeView> {
  int currentIndex = 0;
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  // list of onboarding content that contain image ,details, titles
  List<AllinOnboardModel> allinonboardlist = [
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboard1.svg',
        'Effortless Task Management'.tr,
        'Stay on top of your workload with real-time updates and seamless collaboration. Our task management tools ensure everyone knows what needs to be done and when, fostering accountability and efficiency across your team.'
            .tr),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboard2.svg',
        'Streamlined Requests'.tr,
        'Simplify the process of submitting, tracking, and managing requests within your organization. Our intuitive system ensures that all requests are handled promptly and efficiently, keeping everyone informed and on the same page.'
            .tr),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboard3.svg',
        'Comprehensive Service Management'.tr,
        'Manage inter-departmental service requests effortlessly with our all-in-one platform. Any department can request services from others, with the ability to approve, reject, and track the progress of these requests.'
            .tr),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboard4.svg',
        'Efficient Event Management'.tr,
        'Organize and manage company events seamlessly with the help of our dedicated media team. From sending invitations to gathering feedback, our event management tools ensure every event runs smoothly and successfully.'
            .tr),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboard5.svg',
        'Flexible Role Management'.tr,
        'Assign and manage roles_module within your organization effortlessly. Ensure that every team member has the appropriate access and responsibilities to perform their duties effectively.'
            .tr),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboard6.svg',
        'Personalized To-Do Lists'.tr,
        'Our to-do list feature helps you manage your workload efficiently, ensuring you never miss a task. Keep your day structured and focused with intuitive tools designed for your convenience.'
            .tr),
              AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboard7.svg',
        'Real-Time Team Chat'.tr,
        'Streamline communication with direct messaging and group chats, ensuring everyone stays informed and engaged. Our chat functionality fosters quick decision-making and improves overall team productivity.'
            .tr),
              AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboard8.svg',
        'Clear Organization Chart'.tr,
        'Visualize your company\'s structure effortlessly with our dynamic organization chart. Easily navigate through departments and roles_module to understand reporting lines and team relationships.'
            .tr),
  ];

  @override
  void initState() {
    super.initState();

    screenWidth > 600
        ?
        // Tablet
        SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ])
        : SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp,
          ]);
    pageController = PageController(
      initialPage: currentIndex,
      keepPage: true,
    );
  }

  bool firstLogin = false;
  final HapticController hapticController = Get.put(HapticController());
  @override
  Widget build(BuildContext context) {
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 0.028.w, right: 0.028.w),
        child: ListView(
          children: [
            // the page view slider
            SizedBox(
              height: isTablet && orientation ? 0.78.h : 0.75.h,
              child: Padding(
                padding: EdgeInsets.only(
                  top:orientation?0.06.h :0.07.h,
                ),
                child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      setState(() {
                        currentIndex = value;
                      });
                    },
                    itemCount: allinonboardlist.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                isTablet ? (orientation ? 0.05.w : 0.3.h) : 0),
                        child: CustomPageView(
                            title: allinonboardlist[index].description,
                            description: allinonboardlist[index].titlestr,
                            imgurl: allinonboardlist[index].imgStr),
                      );
                    }),
              ),
            ),
            // the dots inder it
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                allinonboardlist.length,
                (index) => buildDot(index: index),
              ),
            ),
            SizedBox(
              height: 0.028.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      isTablet ? (orientation ? 0.2.w : 0.45.h) : 0.04.w),
              child: MainCustomIconButton(
                onPressed: () async {
                  if (currentIndex == allinonboardlist.length - 1) {
                    storage.write('onboarding', 'true');
                  }
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.lightImpact,
                      hapticFeedback: HapticFeedback.mediumImpact);
                  if (currentIndex < allinonboardlist.length - 1) {
                    currentIndex++;
                    pageController.animateToPage(currentIndex,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  } else {
                    isTablet
                        ? PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: StartSignIn(),
                            withNavBar: false,
                          )
                        : PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: StartSignInMobile(),
                            withNavBar: false,
                          );
                  }
                },
                buttonText: currentIndex != allinonboardlist.length - 1
                    ? 'Next'.tr
                    : 'Get Start'.tr,
                buttonStyle: ElevatedButton.styleFrom(
                  minimumSize: Size(0.035.w, 0.057.h),
                  backgroundColor: AppColors.signOut,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  )),
                ),
           
              ),
            ),
            SizedBox(
              height: 0.016.h
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      isTablet ? (orientation ? 0.2.w : 0.45.h) : 0.04.w),
              child: TextButton(
                onPressed: () async {
                  storage.write('onboarding', 'true');
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.lightImpact,
                      hapticFeedback: HapticFeedback.lightImpact);
                  isTablet
                      ? PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: StartSignIn(),
                          withNavBar: false,
                        )
                      : PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: StartSignInMobile(),
                          withNavBar: false,
                        );
                },
                onLongPress: () {
                  // Clear focus when long-pressed
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Text(
                  'Skip'.tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? FontConstants.fontSize022.h
                        : FontConstants.fontSize020.h,
                    color: AppColors.textdeactivecolor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 0.02.w),
      height: isTablet ? 0.015.h : 0.01.h,
      width: currentIndex == index
          ? isTablet
              ? 0.035.w
              : 0.06.w
          : isTablet
              ? 0.015.h
              : 0.02.w,
      decoration: BoxDecoration(
        color: currentIndex == index
            ? AppColors.signOut
            : themeControllerCheck.currentTheme == AppColors.lightTheme
                ? AppColors.colorBlack.withOpacity(0.2)
                : AppColors.colorWhiteDark,
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}

// Alias so that `Onboarding` can be used wherever `WelcomeView` is needed.
typedef Onboarding = WelcomeView;
