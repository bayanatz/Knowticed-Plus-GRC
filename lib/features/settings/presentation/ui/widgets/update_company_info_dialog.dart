import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart' hide themeController;
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/multiselect.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/company_info_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/company_service_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/contact_info_company_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:demo_app/features/settings/core_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/filters_appbar.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/onboarding/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:multi_dropdown/enum/app_enums.dart';
import 'package:multi_dropdown/models/chip_config.dart';
import 'package:multi_dropdown/models/value_item.dart';

class UpdateCompanyInfoDialog extends StatefulWidget {
  const UpdateCompanyInfoDialog({super.key});

  @override
  State<UpdateCompanyInfoDialog> createState() =>
      _UpdateCompanyInfoDialogState();
}

class _UpdateCompanyInfoDialogState extends State<UpdateCompanyInfoDialog> {
  List<ValueItem<dynamic>> optionsD = [];

  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    ButtonStyle buttonStyle(Color color) {
      return ElevatedButton.styleFrom(
        minimumSize: Size(0.068.w, 0.05.h),
        backgroundColor: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
      );
    }

    TextStyle headersStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isVertical
          ? FontConstants.fontSize018.h
          : FontConstants.fontSize022.h,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.inverseSurface,
    );
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? (isVertical ? 0.12.w : 0.15.w) : 0.06.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          width: isTablet ? 0.8.w : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.02.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0.02.h),
                    child: const FiltersAppBar(
                        imageUrl: "assets/icons_assets/main_icons_assets/reqToChange.svg",
                        title: "Update Information"),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: isVertical ? 0.01.h : 0.02.h, bottom: 0.01.h),
                        child: Text(
                          "Fields".tr,
                          style: headersStyle,
                        ),
                      ),
                      SizedBox(
                        width: isTablet
                            ? (isVertical ? double.infinity : double.infinity)
                            : double.infinity,
                        height: isVertical ? 0.05.h : 0.06.h,
                        child: MultiSelectDropDown(
                          showClearIcon: true,
                          borderRadius: 8,
                          dropdownBorderRadius: 8,
                          selectedOptionIcon: SvgPicture.asset(
                               'assets/icons_assets/main_icons_assets/CheckListOn.svg',
                                              color: AppColors.lightPrimary,
                              ),
                          clearIcon:
                              SvgPicture.asset("assets/icons_assets/main_icons_assets/closefield.svg"),
                          padding: EdgeInsets.only(
                              right: Get.locale.toString().contains('en')
                                  ? isTablet? 0.01.w : 0.04.w
                                  : isTablet? .001.w : 0.0.w,
                              left: Get.locale.toString().contains('en')
                                  ? isTablet? 0.001.w : 0.0.w
                                  : isTablet? 0.01.w :  0.04.w,),
                          borderColor: Colors.transparent,
                          borderWidth: 1.1,
                          hint: "Fields".tr,
                          dropdownHeight:isTablet? 0.18.h : 0.14.h,
                          optionsBackgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          suffixIcon: SvgPicture.asset(
                            'assets/icons_assets/data_grc_assets/NewDropDownIcon.svg',
                            height: isTablet?(isVertical ? 0.025.h : 0.03.h) : 0.02.h,
                            width: isTablet? 0.01.h : 0.02.h,
                          ),
                          hintColor: Theme.of(context).colorScheme.scrim,
                           hintStyle:
                                  AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize:isTablet? (isVertical
                                ? FontConstants.fontSize017.h
                                : FontConstants.fontSize021.h): (FontConstants.fontSize016.h),
                               height: isVertical ? 1.8 : 1.2,
                                color: AppColors.colorGrey,
                              ),
                          // controller: _controller,
                          onOptionSelected: (options) {
                            setState(() {
                              optionsD = options;
                            });
                          },
                          radiusGeometry: BorderRadius.circular(8),
                          fieldBackgroundColor:
                             themeController.currentTheme ==
                                          AppColors.lightTheme
                                      ? AppColors.colorLightGrey
                                      : AppColors.colorBlack,
                          dropdownBackgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          selectedOptionBackgroundColor: Colors.transparent,
                          options: <ValueItem>[
                            ValueItem(
                              label: "Company Information".tr,
                              value: '1',
                            ),
                            ValueItem(label: 'Company Services'.tr, value: '2'),
                            ValueItem(
                                label: 'Contact Information'.tr, value: '3'),
                          ],
                          selectionType: SelectionType.multi,
                          chipConfig: ChipConfig(
                                 deleteIcon: Icon(
                                              Icons.cancel,
                                              size: 0.02.h,
                                              color:
                                                  AppColors.textButton,
                                            ),
                                  labelStyle:
                                      AppFontStyle.cairoRegularStyle.copyWith(
                                    color: AppColors.textButton,
                                    fontSize: FontConstants.fontSize016.h,
                                    height: Get.locale.toString().contains('en') ?   1.5 : 1.2,  
                                  ),
                                  wrapType: WrapType.scroll,
                                  radius: 8),
                          optionTextStyle:
                                  AppFontStyle.cairoRegularStyle.copyWith(
                                color: Theme.of(context).colorScheme.scrim,
                                fontSize:isTablet? isVertical
                                      ? FontConstants.fontSize016.h
                                      : FontConstants.fontSize021.h: FontConstants.fontSize016.h,
                                height:isTablet?   1.2: 1.8,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: (isVertical ? 0.02.h : 0.04.h),
                        bottom: (isVertical ? 0.0.h : 0.02.h)),
                    child: Container(
                      // color: Colors.amber,
                      width: isTablet ? (isVertical ? 0.43.w : 0.37.w) : 0.52.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current".tr,
                            style: headersStyle,
                          ),
                          Text(
                            "New".tr,
                            style: headersStyle,
                          )
                        ],
                      ),
                    ),
                  ),
                  optionsD.isEmpty
                      ? const SizedBox.shrink()
                      : optionsD.indexWhere((item) =>
                                  item.label == "Company Information") !=
                              -1
                          ? Padding(
                              padding: EdgeInsets.only(
                                  bottom: isTablet
                                      ? (isVertical ? 0.0.h : 0.02.h)
                                      : 0.01.h,
                                  top: isTablet ? 0.02.h : 0.03.h),
                              child: SettingsHeader(
                                imagePath: 'assets/icons_assets/settings_assets/companyInfo.svg',
                                text: 'Company Information'.tr,
                                hideDiv: true,
                              ),
                            )
                          : const SizedBox.shrink(),
                  optionsD.isEmpty
                      ? const SizedBox.shrink()
                      : optionsD.indexWhere((item) =>
                                  item.label == "Company Information") !=
                              -1
                          ? const CompanyInfoUpdateConent()
                          : const SizedBox.shrink(),
                  optionsD.isEmpty
                      ? const SizedBox.shrink()
                      : optionsD.indexWhere(
                                  (item) => item.label == "Company Services") !=
                              -1
                          ? Padding(
                              padding: EdgeInsets.only(
                                  bottom: isTablet
                                      ? (isVertical ? 0.0.h : 0.02.h)
                                      : 0.01.h,
                                  top: 0.02.h),
                              child: SettingsHeader(
                                imagePath: 'assets/icons_assets/settings_assets/companyInfo.svg',
                                text: 'Company Services'.tr,
                                hideDiv: true,
                              ),
                            )
                          : const SizedBox.shrink(),
                  optionsD.isEmpty
                      ? const SizedBox.shrink()
                      : optionsD.indexWhere(
                                  (item) => item.label == "Company Services") !=
                              -1
                          ? const CompanyServiceUpdateContent()
                          : const SizedBox.shrink(),
                  optionsD.isEmpty
                      ? const SizedBox.shrink()
                      : optionsD.indexWhere((item) =>
                                  item.label == "Contact Information") !=
                              -1
                          ? Padding(
                              padding: EdgeInsets.only(
                                  bottom: isTablet
                                      ? (isVertical ? 0.0.h : 0.02.h)
                                      : 0.01.h,
                                  top: 0.02.h),
                              child: SettingsHeader(
                                imagePath: 'assets/icons_assets/settings_assets/companyInfo.svg',
                                text: 'Contact Information'.tr,
                                hideDiv: true,
                              ),
                            )
                          : const SizedBox.shrink(),
                  optionsD.isEmpty
                      ? const SizedBox.shrink()
                      : optionsD.indexWhere((item) =>
                                  item.label == "Contact Information") !=
                              -1
                          ? const ContactInfoCompanyUpdate()
                          : const SizedBox.shrink(),
                  if (optionsD.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0.02.h, bottom: 0.01.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          MainCustomIconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const ResponseDialog(
                                    subtitle: "You Successful Send Update",
                                    title: "Successful",
                                    lottieAsset: "assets/images/correct.json",
                                  );
                                },
                              );
                              //setState(() {});
                            },
                            buttonText: "Submit".tr,
                           
                            buttonStyle: buttonStyle(AppColors.signOut),
                          )
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 0.015.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
