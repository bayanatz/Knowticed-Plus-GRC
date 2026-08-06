// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api
import 'package:grc_module/features/settings/se7_app_info/domain/enums/languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/custom_appbar_mobile.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';

import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key});

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Languages? selectedLanguage = Languages.english;
  final box = GetStorage();
  String? localeData;
  final HapticController hapticController = Get.put(HapticController());

  @override
  void initState() {
    super.initState();
    localeData = box.read<String>('LocaleData');
    selectedLanguage = localeData.toString().contains('ar')
        ? Languages.arabic
        : Languages.english;
  }

  void toggleLangSwitch(Languages language) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    setState(() {
      selectedLanguage = language;
    });
    if (language == Languages.arabic) {
      Get.updateLocale(const Locale('ar', 'SA'));
      box.write('LocaleData', 'ar');
      themeController.updateFonts();
    } else {
      Get.updateLocale(const Locale('en', 'US'));
      box.write('LocaleData', 'en');
      themeController.updateFonts();
    }
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return isTablet
        ? _buildTabletView(context, lightMode, isPortrait)
        : _buildMobileView(context, lightMode);
  }

  Widget _buildMobileView(BuildContext context, bool lightMode) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBarMobile(
            title: S.of(context).language,
            showMoreIcon: false,
            showIcon: true,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.04.w),
              child: _languageOptions(context, lightMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletView(
      BuildContext context, bool lightMode, bool isPortrait) {
    return _languageOptions(context, lightMode);
  }

  Widget _languageOptions(BuildContext context, bool lightMode) {
    return Column(
      children: [
        _langTile(
          context,
          Languages.english,
          S.of(context).english,
          lightMode,
        ),
        _langTile(
          context,
          Languages.arabic,
          'عربي',
          lightMode,
        ),
      ],
    );
  }

  Widget _langTile(BuildContext context, Languages lang, String label,
      bool lightMode) {
    final bool selected = selectedLanguage == lang;
    return GestureDetector(
      onTap: () => toggleLangSwitch(lang),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.01.h),
        padding: EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.015.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightPrimary.withOpacity(0.1)
              : Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                selected ? AppColors.lightPrimary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize018.h,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? AppColors.lightPrimary
                    : AppColors.text,
              ),
            ),
            if (selected)
              Icon(Icons.check_circle,
                  color: AppColors.lightPrimary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
