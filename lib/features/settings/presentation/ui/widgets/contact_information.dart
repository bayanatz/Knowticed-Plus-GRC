///*************************** FILE INFO ****************************///
/// Purpose: A widget that displays the contact information of the user in the setting personal information screen.
/// Author: Mohamed Elrashidy
/// Created At: 10/11/2024


import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/country_picker_dialog.dart';


import 'package:demo_app/features/settings/core_widgets/main_widget/intl_phone_field.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';

import 'package:demo_app/features/settings/widgets/countries.dart';
// REMOVED: import '../../../../authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../pages/settings_screen.dart';
import 'settings_header.dart';

class ContactInformation extends StatefulWidget {
  final bool isReadOnly;
  const ContactInformation({super.key, required this.isReadOnly});

  @override
  State<ContactInformation> createState() => _ContactInformationState();
}

class _ContactInformationState extends State<ContactInformation> {
  late TextEditingController _emailController;
  late TextEditingController _countryCodeController;
  late TextEditingController _phoneController;

  @override
  @override
  void initState() {
    super.initState();
    final isArabic = Get.locale?.languageCode == 'ar';

    // Get the first MobilePhone object from the list (or handle multiple)
    final mobilePhoneList = employee!.mobilePhone;
    final mobilePhone = mobilePhoneList?.isNotEmpty == true ? mobilePhoneList!.first : null;

    // Get the phone data from the MobilePhone object
    final phoneNumber = mobilePhone?.phones?.lastOrNull ?? "";
    final countryCode = mobilePhone?.countryCode?.lastOrNull ?? "EG";
    final countryApp = mobilePhone?.countryApp?.lastOrNull ?? "EG";
    final email = employee!.email!.last;

    final flag = _getCountryFlag(countryCode);
    final dialCode = _getDialCode(countryCode);

    // Convert to Arabic digits if Arabic locale
    final displayDialCode = isArabic ? _convertToArabicDigits(dialCode) : dialCode;
    final displayPhoneNumber = isArabic ? _convertToArabicDigits(phoneNumber) : phoneNumber;
    final flagAndCode = '$flag $displayDialCode';

    _emailController = TextEditingController(text: email);
    _countryCodeController = TextEditingController(text: flagAndCode);
    _phoneController = TextEditingController(text: displayPhoneNumber);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _getCountryFlag(String countryDialCode) {
    try {
      final country = countries.firstWhere(
            (country) => country.dialCode == countryDialCode,
        orElse: () => countries.firstWhere((c) => c.code == 'EG'),
      );
      return country.flag;
    } catch (e) {
      return '🇪🇬';
    }
  }

  String _getDialCode(String countryDialCode) {
    try {
      final country = countries.firstWhere(
            (country) => country.dialCode == countryDialCode,
        orElse: () => countries.firstWhere((c) => c.code == 'EG'),
      );
      return '+${country.dialCode}';
    } catch (e) {
      return '+20';
    }
  }

  /// Converts English digits (0-9) to Arabic-Indic digits (٠-٩)
  String _convertToArabicDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    var isPhone = context.isPhone;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: isPhone
          ? BoxDecoration(
          color: AppColors.card
      )
          : BoxDecoration(
        color:  AppColors.card
      ),
      child: Column(

        children: [




          Container(
            decoration: !isTablet
                ? BoxDecoration(
              color:  AppColors.card
            )
                : null,
            child: Padding(
              padding:  EdgeInsets.only(right: 15.sp,left: 15.sp,top: 15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsHeader(
                      imagePath: 'assets/icons_assets/settings_assets/phone_contact.svg',
                      text: S.of(context).contact),

                  SizedBox(height: 15.h),

                  // Email and Phone Number Row
                  isPortrait
                      ? Column(
                    children: [
                      // Email Field (Portrait)
                      CustomTextField(
                        label: S.of(context).email,
                        textDirection: TextDirection.ltr,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        hint: 'Enter Your Email'.tr,
                        controller: _emailController,
                        enabled: !widget.isReadOnly,
                      ),
                      isPhone ? SizedBox() : SizedBox(height: 16.h),

                      // Phone Number Section (Portrait)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).phoneNumber,
                            style: StyleText.fontSize14Weight400.copyWith(
                                color: lightMode
                                    ? AppColors.blackButton
                                    : AppColors.white),
                          ),
                          SizedBox(height: 6.h),

                          // Phone Fields Row
                          Row(
                            children: [
                              // Country Code Field
                              SizedBox(
                                width: 0.25.w,
                                child: CustomTextField(
                                  hint: '',
                                  textDirection: isArabic ?TextDirection.rtl : TextDirection.ltr,
                                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                  controller: _countryCodeController,
                                  enabled: false,
                                ),
                              ),
                              SizedBox(width: 0.02.w),
                              // Phone Number Field
                              Expanded(
                                child: CustomTextField(
                                  hint: 'Enter The Phone Number'.tr,
                                  controller: _phoneController,
                                  enabled: false,
                                  textDirection: isArabic ?TextDirection.rtl : TextDirection.ltr,
                                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field (Landscape)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: Get.locale.toString().contains('en')
                                ? 0.02.h
                                : 0,
                            left: Get.locale.toString().contains('ar')
                                ? 0.02.h
                                : 0,
                          ),
                          child: CustomTextField(
                            label: S.of(context).email,
                            textDirection: TextDirection.ltr,
                            textAlign: isArabic ? TextAlign.right : TextAlign.left,
                            hint: 'Enter Your Email'.tr,
                            controller: _emailController,
                            enabled: false,
                          ),
                        ),
                      ),

                      // Phone Number Section (Landscape)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).phoneNumber,
                              style: StyleText.fontSize14Weight400
                                  .copyWith(
                                  color: lightMode
                                      ? AppColors.blackButton
                                      : AppColors.white),
                            ),
                            SizedBox(height: 6.h),
                            // Phone Fields Row
                            Row(
                              children: [
                                // Country Code Field
                                SizedBox(
                                  width: 0.08.w,
                                  child: CustomTextField(
                                    hint: '',
                                    controller: _countryCodeController,
                                    textDirection: isArabic ?TextDirection.rtl : TextDirection.ltr,
                                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                    enabled: false,
                                  ),
                                ),
                                SizedBox(width: 0.01.w),
                                // Phone Number Field
                                Expanded(
                                  child: CustomTextField(
                                    hint: 'Enter The Phone Number'.tr,
                                    controller: _phoneController,
                                    textDirection: isArabic ?TextDirection.rtl : TextDirection.ltr,
                                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                    enabled: false,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  isPhone ? SizedBox() : SizedBox(height: 16.h),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}