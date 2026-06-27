import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';

import 'package:flutter/material.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';

import '../../../../../../generated/l10n.dart';

class CompanyInformationFields extends StatefulWidget {
  const CompanyInformationFields({super.key});

  @override
  State<CompanyInformationFields> createState() => _CompanyInformationFieldsState();
}

class _CompanyInformationFieldsState extends State<CompanyInformationFields> {
  final CompanyController companyController = Get.find();
  bool submitted = false;

  // Controllers for all fields
  late TextEditingController companyNameController;
  late TextEditingController taxNumberController;
  late TextEditingController countryController;
  late TextEditingController provinceController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController industryController;
  late TextEditingController companySizeController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;

  // Text direction states for each field
  TextDirection companyNameDirection = TextDirection.ltr;
  TextDirection countryDirection = TextDirection.ltr;
  TextDirection provinceDirection = TextDirection.ltr;
  TextDirection cityDirection = TextDirection.ltr;
  TextDirection streetDirection = TextDirection.ltr;
  TextDirection industryDirection = TextDirection.ltr;
  TextDirection firstNameDirection = TextDirection.ltr;
  TextDirection lastNameDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    companyNameController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.companyName?.companyName?.lastOrNull ?? '')
    );
    taxNumberController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.taxNumber?.taxNumber?.lastOrNull ?? '')
    );
    countryController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.country?.country?.lastOrNull ?? '')
    );
    provinceController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.province?.province?.lastOrNull ?? '')
    );
    cityController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.city?.city?.lastOrNull ?? '')
    );
    streetController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.companyAddress?.address?.lastOrNull ?? '')
    );
    industryController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.companyIndustry?.companyIndustry?.lastOrNull ?? '')
    );
    companySizeController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.companySize?.companySize?.lastOrNull ?? '')
    );
    firstNameController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.firstName?.firstNames?.lastOrNull ?? '')
    );
    lastNameController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.lastName?.lastNames?.lastOrNull ?? '')
    );
    emailController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.email?.emails?.lastOrNull ?? '')
    );
    phoneNumberController = TextEditingController(
        text: FormatHelper.capitalize(companyController.company?.phone?.phones?.lastOrNull ?? '')
    );

    // Set initial text directions based on content
    companyNameDirection = _detectTextDirection(companyNameController.text);
    countryDirection = _detectTextDirection(countryController.text);
    provinceDirection = _detectTextDirection(provinceController.text);
    cityDirection = _detectTextDirection(cityController.text);
    streetDirection = _detectTextDirection(streetController.text);
    industryDirection = _detectTextDirection(industryController.text);
    firstNameDirection = _detectTextDirection(firstNameController.text);
    lastNameDirection = _detectTextDirection(lastNameController.text);
  }

  @override
  void dispose() {
    companyNameController.dispose();
    taxNumberController.dispose();
    countryController.dispose();
    provinceController.dispose();
    cityController.dispose();
    streetController.dispose();
    industryController.dispose();
    companySizeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  /// Detects if text contains Arabic characters
  bool _containsArabic(String text) {
    if (text.isEmpty) return false;
    // Arabic Unicode range: U+0600 to U+06FF
    return text.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
  }

  /// Detects text direction based on content
  /// Returns RTL if contains Arabic, LTR otherwise
  TextDirection _detectTextDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;
    return _containsArabic(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Container(
      height: isMobile ? null : 470.h,
      color: AppColors.card,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),

        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // Company Section
              Row(
                children: [
                  CustomSvg(assetPath: "assets/icon_drwaer/Comapny_icon.svg",width: 25.w,height: 25.h,fit: BoxFit.fill,),
                  SizedBox(width: 8.w),
                  Text(
                      S.of(context).company,
                      style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text
                      )
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Row 1: Company Name, Tax Number, Country
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Company Name'.tr,
                      hint: S.of(context).textHere,
                      controller: companyNameController,
                      textDirection: companyNameDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          companyNameDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: 'Tax Number'.tr,
                      hint: S.of(context).textHere,
                      controller: taxNumberController,
                      enabled: false,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: 'Country'.tr,
                      hint: S.of(context).textHere,
                      controller: countryController,
                      textDirection: countryDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          countryDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: 'Company Name'.tr,
                    hint: S.of(context).textHere,
                    controller: companyNameController,
                    textDirection: companyNameDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        companyNameDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                  SizedBox(height: 0.h),
                  CustomTextField(
                    label: 'Tax Number'.tr,
                    hint: S.of(context).textHere,
                    controller: taxNumberController,
                    enabled: false,
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 0.h),
                  CustomTextField(
                    label: 'Country'.tr,
                    hint: S.of(context).textHere,
                    controller: countryController,
                    textDirection: countryDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        countryDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 0.h),

              // Row 2: Province, City
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Province'.tr,
                      hint: S.of(context).textHere,
                      controller: provinceController,
                      textDirection: provinceDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          provinceDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: 'City'.tr,
                      hint: S.of(context).textHere,
                      controller: cityController,
                      textDirection: cityDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          cityDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  Expanded(child: SizedBox()),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: 'Province'.tr,
                    hint: S.of(context).textHere,
                    controller: provinceController,
                    textDirection: provinceDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        provinceDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                  SizedBox(height: 0.h),
                  CustomTextField(
                    label: 'City'.tr,
                    hint: S.of(context).textHere,
                    controller: cityController,
                    textDirection: cityDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        cityDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 0.h),

              // Row 3: Street (full width)
              CustomTextField(
                label: S.of(context).street,
                hint: S.of(context).textHere,
                controller: streetController,
                textDirection: streetDirection,
                enabled: false,
                onChanged: (value) {
                  setState(() {
                    streetDirection = _detectTextDirection(value);
                  });
                },
              ),

              SizedBox(height: 10.h),

              // Service Section
              Row(
                children: [
                  CustomSvg(assetPath: "assets/icon_drwaer/services_icon.svg",width: 25.w,height: 25.h,fit: BoxFit.fill,),
                  SizedBox(width: 8.w),
                  Text(
                      'Service'.tr,
                      style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text
                      )
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Row 4: Industry, Company Size
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Industry'.tr,
                      hint: S.of(context).textHere,
                      controller: industryController,
                      textDirection: industryDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          industryDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: 'Company Size'.tr,
                      hint: S.of(context).textHere,
                      controller: companySizeController,
                      enabled: false,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: 'Industry'.tr,
                    hint: S.of(context).textHere,
                    controller: industryController,
                    textDirection: industryDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        industryDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                  SizedBox(height: 0.h),
                  CustomTextField(
                    label: 'Company Size'.tr,
                    hint: S.of(context).textHere,
                    controller: companySizeController,
                    enabled: false,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Contact Section
              Row(
                children: [
                  CustomSvg(assetPath: "assets/icon_drwaer/contact_icon.svg",width: 25.w,height: 25.h,fit: BoxFit.fill,),
                  SizedBox(width: 8.w),
                  Text(
                      'Contact'.tr,
                      style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text
                      )
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Row 5: First Name, Last Name
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'First Name'.tr,
                      hint: S.of(context).textHere,
                      controller: firstNameController,
                      textDirection: firstNameDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          firstNameDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: 'Last Name'.tr,
                      hint: S.of(context).textHere,
                      controller: lastNameController,
                      textDirection: lastNameDirection,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          lastNameDirection = _detectTextDirection(value);
                        });
                      },
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: 'First Name'.tr,
                    hint: S.of(context).textHere,
                    controller: firstNameController,
                    textDirection: firstNameDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        firstNameDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                  SizedBox(height: 0.h),
                  CustomTextField(
                    label: 'Last Name'.tr,
                    hint: S.of(context).textHere,
                    controller: lastNameController,
                    textDirection: lastNameDirection,
                    enabled: false,
                    onChanged: (value) {
                      setState(() {
                        lastNameDirection = _detectTextDirection(value);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 0.h),

              // Row 6: Email, Phone Number
              isTablet
                  ? Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Email'.tr,
                      hint: S.of(context).textHere,
                      controller: emailController,
                      enabled: false,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      label: 'Phone Number'.tr,
                      hint: S.of(context).textHere,
                      controller: phoneNumberController,
                      enabled: false,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  CustomTextField(
                    label: 'Email'.tr,
                    hint: S.of(context).textHere,
                    controller: emailController,
                    enabled: false,
                    onChanged: (value) => setState(() {}),
                  ),
                  SizedBox(height: 0.h),
                  CustomTextField(
                    label: 'Phone Number'.tr,
                    hint: S.of(context).textHere,
                    controller: phoneNumberController,
                    enabled: false,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}