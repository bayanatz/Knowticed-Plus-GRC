/// ************************ FILe INFO ********************************///
/// File Name: tablet_company_info_screen.dart
/// Author: Amr Mesbah
/// refactored at:11/12/2024
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:grc_module/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/responsive_side_frame.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:grc_module/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
// REMOVED: import '../../../../settings_screen/views/owner_screens/company_info_update_dialog/update_company_info_dialog.dart';
import 'package:grc_module/core/custom/33-custom_haptic.dart';
import 'package:grc_module/generated/l10n.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/settings/se3_company/presentation/ui/widgets/fields/company_information_fields.dart';
import 'package:flutter/services.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
class CompanyScreenInfo extends StatefulWidget {
  const CompanyScreenInfo({super.key});

  @override
  State<CompanyScreenInfo> createState() =>
      _CompanyScreenInfoState();
}

class _CompanyScreenInfoState extends State<CompanyScreenInfo> {
  CompanyCubit get companyController => context.read<CompanyCubit>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('📱 ===== COMPANY SCREEN INFO INIT START =====');
    _loadCompanyData();
  }

  // ✅ NEW METHOD: Load company data on screen init
  Future<void> _loadCompanyData() async {
    print('📱 Loading company data...');
    print('📱 Current company is null: ${companyController.state.company == null}');

    if (companyController.state.company == null) {
      print('📱 Company is null, calling getCompany()...');
      await companyController.getCompany(shouldRestart: false);
      print('📱 After getCompany(), company is null: ${companyController.state.company == null}');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    print('📱 Company name: ${companyController.state.company?.companyName}');
    print('📱 Company status: ${companyController.state.company?.status}');
    print('📱 ===== COMPANY SCREEN INFO INIT END =====');
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // ✅ Show loading indicator while data is loading
    if (_isLoading) {
      return const CircleProgress();
    }

    // ✅ Show error message if company data failed to load
    if (context.watch<CompanyCubit>().state.company == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load company data',
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadCompanyData();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return !isMobile ? Column(
      children: [
        // isMobile ? SizedBox(height: 35.h) : SizedBox() ,
        Container(
          height: isMobile ? null: 490.h,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding:
            EdgeInsets.only(right: 15.sp,left: 15.sp,top: 15.sp),
            child: Column(
              children: [

                const CompanyInformationFields(),
              ],
            ),
          ),
        ),


        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButton(
              title: S.of(context).update,
              function: () async {
                print('📝 ===== UPDATE BUTTON PRESSED =====');

                hapticController.triggerHapticFeedback(
                    vibration: VibrateType.mediumImpact,
                    hapticFeedback: HapticFeedback.mediumImpact
                );

                // ✅ Add your update logic here
                // For example:
                // await companyController.updateCompanyInfo();

                print('📝 ===== UPDATE COMPLETE =====');
              },
              radius: 4.r,
              color: AppColors.primary,
              width: 300.w,
              height: 36.h,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.textButton
              ),
            ),
          ],
        ),
      ],
    ) : SideFrameMasterServices(
      titleText: S.of(context).settings,
      secondTitle: S.of(context).company,
      onSecondTap: (){
        Navigator.pop(context);
      },
      onFirstTap: (){
        Navigator.pop(context);
      },
      child: Column(
        children: [
          // isMobile ? SizedBox(height: 35.h) : SizedBox() ,
          Container(
            height: isMobile ? null: 490.h,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding:
              EdgeInsets.only(right: 15.sp,left: 15.sp,top: 15.sp),
              child: Column(
                children: [

                  const CompanyInformationFields(),
                ],
              ),
            ),
          ),


          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customButton(
                title: S.of(context).update,
                function: () async {
                  print('📝 ===== UPDATE BUTTON PRESSED (MOBILE) =====');

                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact
                  );

                  // ✅ Add your update logic here

                  print('📝 ===== UPDATE COMPLETE (MOBILE) =====');
                },
                radius: 4.r,
                color: AppColors.primary,
                width: isMobile ? 340.w : 300.w,
                height: 36.h,
                textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton
                ),
              ),

            ],
          ),

          SizedBox(height: 15.h),
        ],
      ),
    );
  }
}