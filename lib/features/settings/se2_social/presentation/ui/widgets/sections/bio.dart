///********************** FILE INFO *************************///
/// Purpose: A widget to display the bio field in the settings Social screen
/// Author: Amr Mesbah
/// Created at: 13/11/2024
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import 'package:grc_module/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/text_field.dart';
import 'package:grc_module/core/theme/app_colors.dart';

import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart'; // ✅ ADD THIS
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/settings_header.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class Bio extends StatefulWidget {
  Bio({super.key});

  @override
  State<Bio> createState() => _BioState();
}

class _BioState extends State<Bio> {
  SettingsController settingsController = Get.find();

  @override
  void initState() {
    super.initState();

    // ✅ Rebuild whenever bioController text changes (e.g. after save)
    settingsController.socialController.bioController.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capitalizeExistingData();
    });
  }

  // ✅ Capitalize existing bio data
  void _capitalizeExistingData() {
    if (settingsController.socialController.bioController.text.isNotEmpty) {
      String currentText = settingsController.socialController.bioController.text;
      String capitalizedText = FormatHelper.capitalize(currentText);
      if (currentText != capitalizedText) {
        settingsController.socialController.bioController.text = capitalizedText;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    bool isTablet = MediaQuery.of(context).size.width > 600;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return Container(
      decoration: !isTablet
          ? BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.card
      )
          : null,
      padding: EdgeInsets.only(
          top: 15.sp, right: 15.sp, left: 15.sp, bottom: isMobile ? 15.sp : 0.sp
      ),
      child: Column(
        children: [
          SettingsHeader(
            imagePath: 'assets/icons_assets/settings_assets/bio_person_spotlight.svg',
            text: FormatHelper.capitalize(S.of(context).bio), // ✅ CAPITALIZE
          ),
          SizedBox(height: 10.sp),
          CustomTextField(
            hint: FormatHelper.capitalize(S.of(context).shareSomethingAboutYourself),
            controller: settingsController.socialController.bioController,
            maxLines: 3,
            maxLength: 500,
            enabled: true,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign: TextAlign.start,
            onChanged: (value) {
              setState(() {
                settingsController.socialController.changeBio = true;
                setState(() {});
              });
            },
            label: '',
          ),
        ],
      ),
    );
  }
}