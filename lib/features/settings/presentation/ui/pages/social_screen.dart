// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, use_build_context_synchronously
///*************************** FILE INFO **********************************///
/// Purpose: Responsive social / general information screen (phone + tablet in
/// one page).
/// Author: Mohamed Elrashidy
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_appbar_mobile.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/settings/presentation/controller/settings_controller.dart';
import 'package:demo_app/features/settings/presentation/controller/social_controller.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/social/academic_history.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/social/bio.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/social/certificates.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/social/hobbies.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/social/skills.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/social/update_information_button.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  late final SettingsController settingsController;
  late final SocialController socialController;

  @override
  void initState() {
    super.initState();
    settingsController = Get.find<SettingsController>();
    socialController = settingsController.socialController;
    socialController.restartController();

    if (settingsController.employee == null) {
      settingsController.getEmployee().then((_) {
        socialController.restartController();
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _onUpdatePressed() async {
    await socialController.updateAllSocialInformation();

    // ✅ Force Bio widget to show updated text
    if (mounted) setState(() {});

    final mainCoreEmployeeController = Get.find<MainCoreEmployeeController>();
    await mainCoreEmployeeController.getAllNewEmployees();
    mainCoreEmployeeController.update(['employee_profile']);
  }

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isPhone
        ? _buildPhone(context)
        : _buildTablet(context);
  }

  /// Phone design (formerly social_screen_mobile.dart)
  Widget _buildPhone(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBarMobile(
            showIcon: true,
            showMoreIcon: false,
            title: "Social",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.0.w),
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bio(),
                        SizedBox(height: 0.02.h),
                        AcademicHistory(),
                        SizedBox(height: 0.02.h),
                        Certificates(),
                        SizedBox(height: 0.02.h),
                        Skills(),
                        SizedBox(height: 0.02.h),
                        Hobbies(),
                        SizedBox(height: 0.02.h),
                        UpdateInformationButton(),
                        SizedBox(height: 15.h),
                      ],
                    ),
                    SizedBox(height: 0.02.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tablet design (formerly general_information.dart -> SocialScreen)
  Widget _buildTablet(BuildContext context) {
    return GetBuilder<EmployeeController>(
      init: Get.find<EmployeeController>(),
      builder: (addEmployeeController) {
        return Column(
          children: [
            SizedBox(
              height: 490.h,
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Bio(),
                            SizedBox(height: 15.sp),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.sp),
                              child: AcademicHistory(),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15.sp),
                              child: Skills(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Hobbies(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customButton(
                  title: 'Update Social Information'.tr,
                  function: _onUpdatePressed,
                  radius: 4.r,
                  color: AppColors.primary,
                  width: 300.w,
                  height: 36.h,
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
