// Date Created :16/july/2023
// Developer Name : Mazen shabaan
//App Version : Version 1
// Date of Last Edit :1/October/2023
// Objectives:Used to show the on boarding images and texts
// ignore_for_file: unrelated_type_equality_checks, prefer_const_constructors, unused_field
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/page_onBoarding.dart';
// import 'package:grc_module/components/on_boarding_components.dart/page_onboarding.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';

import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/theme_controller.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/mobile_sign_in.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/start_sign_in.dart';

import 'package:grc_module/features/home/h2_nav_bar/utils/functions.dart';

import 'package:grc_module/generated/l10n.dart';
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
        'assets/icons_assets/onboarding_assets/onboarding_checklist.svg',
        S.current.effortlessTaskManagement,
        'Stay on top of your workload with real-time updates and seamless collaboration. Our task management tools ensure everyone knows what needs to be done and when, fostering accountability and efficiency across your team.'
            ),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboarding_calendar_planning.svg',
        S.current.streamlinedRequests,
        'Simplify the process of submitting, tracking, and managing requests within your organization. Our intuitive system ensures that all requests are handled promptly and efficiently, keeping everyone informed and on the same page.'
            ),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboarding_chat_conversation.svg',
        S.current.comprehensiveServiceManagement,
        'Manage inter-departmental service requests effortlessly with our all-in-one platform. Any department can request services from others, with the ability to approve, reject, and track the progress of these requests.'
            ),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboarding_analytics_presentation.svg',
        S.current.efficientEventManagement,
        'Organize and manage company events seamlessly with the help of our dedicated media team. From sending invitations to gathering feedback, our event management tools ensure every event runs smoothly and successfully.'
            ),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboarding_profile_accept.svg',
        S.current.flexibleRoleManagement,
        'Assign and manage roles_module within your organization effortlessly. Ensure that every team member has the appropriate access and responsibilities to perform their duties effectively.'
            ),
    AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboarding_customer_loyalty_handshake.svg',
        S.current.personalizedToDoLists,
        'Our to-do list feature helps you manage your workload efficiently, ensuring you never miss a task. Keep your day structured and focused with intuitive tools designed for your convenience.'
            ),
              AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboarding_secure_login.svg',
        S.current.realTimeTeamChat,
        'Streamline communication with direct messaging and group chats, ensuring everyone stays informed and engaged. Our chat functionality fosters quick decision-making and improves overall team productivity.'
            ),
              AllinOnboardModel(
        'assets/icons_assets/onboarding_assets/onboarding_checklist.svg',
        S.current.clearOrganizationChart,
        'Visualize your company\'s structure effortlessly with our dynamic organization chart. Easily navigate through departments and roles_module to understand reporting lines and team relationships.'
            ),
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
              // Full-bleed primary action, matching Knowticed. The shared
              // `customButton` was deliberately not used here: ButtonSizing
              // clamps it to a 38.sp/135.sp pill, which reads as a small chip
              // on the onboarding page instead of the wide CTA in Knowticed.
              child: ElevatedButton(
                onPressed: () async {
                  if (currentIndex == allinonboardlist.length - 1) {
                    storage.write('onboarding', 'true');
                  }
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.heavyImpact,
                      hapticFeedback: HapticFeedback.heavyImpact);
                  if (currentIndex < allinonboardlist.length - 1) {
                    currentIndex++;
                    pageController.animateToPage(currentIndex,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn);
                  } else {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const SignInScreen(),
                      withNavBar: false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize: Size(0.035.w, 0.057.h),
                  backgroundColor: AppColors.signOut,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                child: Text(
                  currentIndex != allinonboardlist.length - 1
                      ? S.of(context).next
                      : S.of(context).getStart,
                  style: StyleText.fontSize16Weight400
                      .copyWith(color: AppColors.textButton),
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
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const SignInScreen(),
                    withNavBar: false,
                  );
                },
                onLongPress: () {
                  // Clear focus when long-pressed
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Text(
                  S.of(context).skip,
                  style: StyleText.fontSize20Weight500.copyWith(
                    fontSize: isTablet
                        ? FontConstants.fontSize022.h
                        : FontConstants.fontSize020.h,
                    color: AppColors.textdeactivecolor,
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
        // Theme-aware: AppColors.onboardingDotInactive resolves per palette,
        // replacing the manual currentTheme == lightTheme comparison.
        color: currentIndex == index
            ? AppColors.signOut
            : AppColors.onboardingDotInactive,
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}

// Alias so that `Onboarding` can be used wherever `WelcomeView` is needed.
typedef Onboarding = WelcomeView;
