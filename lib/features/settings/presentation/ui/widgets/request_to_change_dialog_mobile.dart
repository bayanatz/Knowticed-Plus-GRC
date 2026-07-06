// ignore_for_file: prefer_const_constructors
/// File: request_to_change_dialog_mobile.dart
/// Migrated from demo_app_plus — themeController replaced with Theme.of(context)

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/enum/app_enums.dart';
import 'package:multi_dropdown/models/chip_config.dart';
import 'package:multi_dropdown/models/value_item.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';



import 'package:demo_app/features/settings/core_widgets/main_widget/filters_appbar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/column_request_data.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/additional_info_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/contact_info_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/emergency_contact_info_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/health_insurance_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/personal_data_update.dart';
import 'package:demo_app/features/settings/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/settings_header.dart';

// LocationInfoUpdate may or may not exist — import conditionally:
// import 'package:demo_app/features/skeleton/settings/presentation/ui/widgets/location_info_update.dart';

class RequestToChangeDialogMobile extends StatefulWidget {
  const RequestToChangeDialogMobile({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.isExclate,
    this.isToShowImage,
    this.isSetting = false,
  });

  final String title;
  final String imageUrl;
  final bool isExclate;
  final bool? isSetting;
  final bool? isToShowImage;

  @override
  State<RequestToChangeDialogMobile> createState() =>
      _RequestToChangeDialogMobileState();
}

class _RequestToChangeDialogMobileState
    extends State<RequestToChangeDialogMobile> {
  String? requestType;
  late MultiSelectController _controller;
  List<ValueItem<dynamic>> optionsD = [];

  @override
  void initState() {
    _controller = MultiSelectController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    TextStyle headersStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: FontConstants.fontSize018.h,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.inverseSurface,
      height: 1.6,
    );

    ButtonStyle buttonStyle(Color color) => ElevatedButton.styleFrom(
          minimumSize: Size(0.068.w, 0.05.h),
          backgroundColor: color,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        );

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 0.04.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          height: widget.isSetting == true
              ? optionsD.isEmpty
                  ? 0.24.h
                  : 0.8.h
              : 0.8.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.03.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0.01.h, bottom: 0.01.h),
                    child: FiltersAppBar(
                      imageUrl: "assets/images/case.svg",
                      title: "Request to Change",
                    ),
                  ),
                  ColumnRequestData(
                    title: "Section",
                    isOptional: false,
                    isTextField: false,
                    isExpanded: false,
                    hint: "Section",
                    isDescription: true,
                    isRequestDialogMobile: true,
                    dropdownValue: requestType,
                    dropDownValueState: (value) {
                      setState(() {
                        optionsD = [];
                        requestType = value;
                      });
                    },
                  ),
                  SizedBox(height: 0.01.h),
                  if (requestType != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 0.00.h),
                            child: Text("Fields".tr, style: headersStyle),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 0.045.h,
                            child: MultiSelectDropDown(
                              // showClearIcon removed in multi_dropdown v2
                              borderRadius: 8,
                              dropdownBorderRadius: 8,
                              selectedOptionIcon: const Icon(Icons.check, size: 16),
                              clearIcon: const Icon(Icons.close, size: 16),
                              padding: EdgeInsets.only(
                                right: Get.locale.toString().contains('en')
                                    ? 0.04.w
                                    : 0.0.w,
                                left: Get.locale.toString().contains('en')
                                    ? 0.0.w
                                    : 0.04.w,
                              ),
                              borderColor: Colors.transparent,
                              borderWidth: 1.1,
                              hint: "Fields".tr,
                              dropdownHeight: 0.16.h,
                              optionsBackgroundColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              hintColor: Theme.of(context).colorScheme.scrim,
                              hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: FontConstants.fontSize016.h,
                                height: 1.8,
                                color: AppColors.colorGrey,
                              ),
                              controller: _controller,
                              onOptionSelected: (options) {
                                setState(() => optionsD = options);
                              },
                              radiusGeometry: BorderRadius.circular(8),
                              fieldBackgroundColor: lightMode
                                  ? AppColors.colorLightGrey
                                  : AppColors.colorBlack,
                              dropdownBackgroundColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              selectedOptionBackgroundColor: Colors.transparent,
                              options: requestType == "Personal Information".tr
                                  ? [
                                      ValueItem(label: "Personal Data".tr, value: '1'),
                                      ValueItem(label: 'Contact Information'.tr, value: '2'),
                                      ValueItem(label: 'Location Information'.tr, value: '3'),
                                    ]
                                  : requestType == "Health Insurance".tr
                                      ? [
                                          ValueItem(label: "Health Insurance".tr, value: '1'),
                                          ValueItem(label: 'Emergency Contact Information'.tr, value: '2'),
                                        ]
                                      : [
                                          ValueItem(label: "Additional Information".tr, value: '1'),
                                        ],
                              selectionType: SelectionType.multi,
                              chipConfig: ChipConfig(
                                deleteIcon: Icon(Icons.cancel,
                                    size: 0.02.h,
                                    color: AppColors.textButton),
                                labelStyle: AppFontStyle.cairoRegularStyle.copyWith(
                                  color: AppColors.textButton,
                                  fontSize: FontConstants.fontSize016.h,
                                  height: Get.locale.toString().contains('en') ? 1.5 : 1.2,
                                ),
                                wrapType: WrapType.scroll,
                                radius: 8,
                              ),
                              optionTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
                                color: Theme.of(context).colorScheme.scrim,
                                fontSize: FontConstants.fontSize016.h,
                                height: 1.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (optionsD.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 0.02.h, bottom: 0.01.h),
                          child: SizedBox(
                            width: 0.515.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Current".tr, style: headersStyle),
                                Text("New".tr, style: headersStyle),
                              ],
                            ),
                          ),
                        ),
                      _buildOptionSection(optionsD, "Additional Information".tr,
                          'assets/icons/add_info_title.svg', AdditionalInfoUpdate()),
                      _buildOptionSection(optionsD, "Health Insurance".tr,
                          'assets/icons/Hospital.svg', const HealthInsuranceUpdate(isRequestMobile: true)),
                      _buildOptionSection(optionsD, "Emergency Contact Information".tr,
                          'assets/icons/UsersGroup.svg', const EmergencyContactInfoUpdate(isRequestMobile: true)),
                      _buildOptionSection(optionsD, "Personal Data".tr,
                          'assets/icons/personalInfo.svg', const PersonalDataUpdate()),
                      _buildOptionSection(optionsD, "Contact Information".tr,
                          'assets/icons/contactInfoPhone.svg', ContactInfoUpdate(isRequestMobile: true)),
                    ],
                  ),
                  if (optionsD.isNotEmpty) SizedBox(height: 0.02.h),
                  if (optionsD.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MainCustomIconButton(
                          onPressed: () {},
                          buttonText: "Send".tr,
                          buttonStyle: widget.isSetting == false &&
                                  requestType == null
                              ? buttonStyle(AppColors.greyBack)
                              : buttonStyle(AppColors.signOut),
                        ),
                      ],
                    ),
                  SizedBox(height: 0.015.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionSection(List<ValueItem<dynamic>> options, String label,
      String iconPath, Widget content) {
    final match = options.any((item) => item.label.tr == label);
    if (!match) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 0.01.h, top: 0.01.h),
          child: SettingsHeader(
            isRequestDialogSmallSize: true,
            imagePath: iconPath,
            text: label,
            hideDiv: true,
          ),
        ),
        content,
      ],
    );
  }
}
