/// Module: Core · Helper · Phone · Country Lookup Helper
/// Description: Pure country lookups (flag / dial code) by dial-code string,
///              extracted out of settings widgets so UI code no longer needs
///              its own try/catch around `countries.firstWhere` (§11.2).
/// Author: Knowticed Team
/// Date: 01/07/2026
/// Dependencies: core/helper/main_helper/countries.dart
/// Revision History:
///   - 01/07/2026: Extracted from ContactInformation widget
///       (_getCountryFlag / _getDialCode).
library;

import 'package:grc_module/core/helper/main_helper/countries.dart';

///*************************** FILE INFO ****************************///
/// File Name: country_lookup_helper.dart
/// Purpose: Resolve a country's flag/dial-code from its dial-code string,
///          defaulting to Egypt when no match is found.

Country _resolveCountry(String countryDialCode) {
  return countries.firstWhere(
    (country) => country.dialCode == countryDialCode,
    orElse: () => countries.firstWhere((c) => c.code == 'EG'),
  );
}

/// Returns the flag emoji for [countryDialCode], defaulting to Egypt's flag.
String countryFlagForDialCode(String countryDialCode) =>
    _resolveCountry(countryDialCode).flag;

/// Returns the "+<dialCode>" string for [countryDialCode], defaulting to
/// Egypt's dial code.
String dialCodeForCountry(String countryDialCode) =>
    '+${_resolveCountry(countryDialCode).dialCode}';
