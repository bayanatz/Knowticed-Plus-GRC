/// *************************** FILE INFO ****************************
/// Purpose: All content of setting personal information in mobile and tablet
/// Author: Amr Mesbah
/// Created At: 10/11/2024
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/responsive_side_frame.dart';
import 'package:grc_module/features/settings/se1_profile/presentation/ui/pages/personal_info_screen.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:grc_module/features/settings/se1_profile/presentation/ui/widgets/sections/contact_information.dart';
import 'package:grc_module/features/settings/se1_profile/presentation/ui/widgets/sections/location_data.dart';
import 'package:grc_module/features/settings/se1_profile/presentation/ui/widgets/sections/personal_data.dart';

class PersonalInformationFields extends StatefulWidget {
  PersonalInformationFields({
    super.key,
  });

  @override
  State<PersonalInformationFields> createState() =>
      _PersonalInformationFieldsState();
}

class _PersonalInformationFieldsState extends State<PersonalInformationFields> {
  SettingsController settingsController = Get.find();
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

      //  SizedBox(height: 200),

        PersonalData(isReadOnly: true,),
    //    SizedBox(height: isTablet ? 0.sp : 0.00.h),
        ContactInformation(isReadOnly: false,),
     //   SizedBox(height: isTablet ? 0.sp : 0.00.h),
        LocationData()
      ],
    );
  }
}
