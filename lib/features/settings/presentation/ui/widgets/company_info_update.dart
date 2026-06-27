import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';

class CompanyInfoUpdateConent extends StatefulWidget {
  const CompanyInfoUpdateConent({super.key});

  @override
  State<CompanyInfoUpdateConent> createState() =>
      _CompanyInfoUpdateConentState();
}

class _CompanyInfoUpdateConentState extends State<CompanyInfoUpdateConent> {
  // Company information text fields controllers
  TextEditingController companyName = TextEditingController();
  TextEditingController taxNumber = TextEditingController();
  TextEditingController birthDate = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController stateOrProvince = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController streetAddress = TextEditingController();
  TextEditingController code = TextEditingController();

// Contact information text fields controllers
  TextEditingController contactFirstName = TextEditingController();
  TextEditingController contactLastName = TextEditingController();
  TextEditingController contactEmail = TextEditingController();
  TextEditingController contactPhone = TextEditingController();
  CompanyController addCompanyController = Get.find();
  @override
  Widget build(BuildContext context) {
    double widthSpace = 0.02.w;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.name(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Company Name"
                          : "اسم الشركة غير صالح",
                    );
                  },
                  'Enter Company Name'.tr, // hintText
                  addCompanyController
                      .company!.companyName!.companyName!.last!.capitalize,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(width: widthSpace),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.name(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Company Name"
                          : "اسم الشركة غير صالح",
                    );
                  },
                  'Enter Company Name'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.insurancePolicyNumber(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Tax Number"
                          : "رقم الضريبة غير صالح",
                    );
                  },
                  'Enter Tax Number'.tr, // hintText
                  addCompanyController.company!.taxNumber!.taxNumber!.last!,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: 0.02.w,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.insurancePolicyNumber(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Tax Number"
                          : "رقم الضريبة غير صالح",
                    );
                  },
                  'Enter Tax Number'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon

                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.text(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Street Address"
                            : "عنوان الشارع غير صحيح");
                  },
                  'Enter Street Address'.tr, // hintText
                  addCompanyController
                      .company!.companyAddress!.address!.last!.capitalize,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: 0.02.w,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.text(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Street Address"
                            : "عنوان الشارع غير صحيح");
                  },
                  'Enter Street Address'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon

                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) async {},
                  (value) {},
                  'Enter City'.tr,
                  // (address != null
                  //         ? address!.subAdministrativeArea
                  //         : widget.userProfile.city!.cities!.lastOrNull !=
                  //                 null
                  //             ? capitalize(
                  //                 '${widget.userProfile.city!.cities!.lastOrNull}')
                  //             : widget
                  //                 .userProfile.city!.cities!.lastOrNull) ??
                  addCompanyController.company!.city!.city!.last!.capitalize,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: 0.02.w,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) async {},
                  (value) {},
                  'Enter City'.tr,
                  // (address != null
                  //         ? address!.subAdministrativeArea
                  //         : widget.userProfile.city!.cities!.lastOrNull !=
                  //                 null
                  //             ? capitalize(
                  //                 '${widget.userProfile.city!.cities!.lastOrNull}')
                  //             : widget
                  //                 .userProfile.city!.cities!.lastOrNull) ??
                  '',
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.zipCode(
                      value,
                    );
                  },

                  'Zip Code or Postal Code'.tr, // hintText
                  addCompanyController.company!.zipCode!.zipCode!.last!,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: widthSpace,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.zipCode(
                      value,
                    );
                  },

                  'Zip Code or Postal Code'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) async {},
                  (value) {},
                  'Enter State Or Province'.tr,
                  // (address != null
                  //         ? address!.administrativeArea
                  //         : widget.userProfile.state!.states!.lastOrNull !=
                  //                 null
                  //             ? capitalize(
                  //                 '${widget.userProfile.state!.states!.lastOrNull}')
                  //             : widget
                  //                 .userProfile.state!.states!.lastOrNull) ??
                  addCompanyController
                      .company!.province!.province!.last!.capitalize,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: 0.02.w,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) async {},
                  (value) {},
                  'Enter State Or Province'.tr,
                  // (address != null
                  //         ? address!.administrativeArea
                  //         : widget.userProfile.state!.states!.lastOrNull !=
                  //                 null
                  //             ? capitalize(
                  //                 '${widget.userProfile.state!.states!.lastOrNull}')
                  //             : widget
                  //                 .userProfile.state!.states!.lastOrNull) ??
                  '',
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) async {},
                  (value) {},
                  'Enter Country'.tr,
                  // (address != null
                  //         ? address!.country
                  //         : widget.userProfile.country!.countries!
                  //                     .lastOrNull !=
                  //                 null
                  //             ? capitalize(
                  //                 '${widget.userProfile.country!.countries!.lastOrNull}')
                  //             : widget.userProfile.country!.countries!
                  //                 .lastOrNull) ??
                  addCompanyController
                      .company!.country!.country!.last!.capitalize,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: widthSpace,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) async {},
                  (value) {},
                  'Enters Country'.tr,
                  // (address != null
                  //         ? address!.country
                  //         : widget.userProfile.country!.countries!
                  //                     .lastOrNull !=
                  //                 null
                  //             ? capitalize(
                  //                 '${widget.userProfile.country!.countries!.lastOrNull}')
                  //             : widget.userProfile.country!.countries!
                  //                 .lastOrNull) ??
                  '',
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
