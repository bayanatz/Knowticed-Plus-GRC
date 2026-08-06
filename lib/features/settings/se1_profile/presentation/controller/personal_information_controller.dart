import 'package:flutter/material.dart';
import 'package:grc_module/core/helper/main_helper/phone_number.dart';

import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';

class PersonalInformationController {
  SettingsController settingsController;
  PersonalInformationController({required this.settingsController});

  // personal information text field controllers
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController birthDate = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController stateOrProvince = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController streetAddress = TextEditingController();
  TextEditingController code = TextEditingController();
  // variables used to check if the user has changed the personal information
  String? firstName2;
  String? middleName2;
  String? lastName2;

  String? email2;
  PhoneNumber? phone2;
  String? address2;
  String? country2;
  String? city2;
  String? province2;

  String? selectedGender;
  String? selectedNationality;
  String? selectedMaritalStatus;
  String? birthDate2;

  /// Method Name: initPersonalInformation
  /// Purpose: Initialize the personal information text field controllers
  initPersonalInformation() {
    firstName.text =
        settingsController.employee?.firstName?.last ?? '';
    lastName.text =
        settingsController.employee?.lastName?.last ?? '';
    country.text = settingsController.employee?.country?.last ?? '';
    city.text = settingsController.employee?.city?.last ?? '';
    stateOrProvince.text =
        settingsController.employee?.province?.last ?? '';
    email.text = settingsController.employee?.email?.last ?? '';
   /* phone.text = settingsController.employee?.
    phone?.phones?.last ?? '';*/
/*    streetAddress.text =
        settingsController.employee?.street?.street?.last ?? '';
    code.text = settingsController.employee?.country?.countryCode?.last ?? '';*/
  }

  firstNameOnChanged(String value) {
    firstName2 = value.trim().toLowerCase();
  }

  lastNameOnChanged(String value) {
    lastName2 = value.trim().toLowerCase();
  }

  middleNameOnChanged(String value) {
    middleName2 = value.trim().toLowerCase();
  }
}
