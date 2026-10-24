/// Module: services / sv2_create_single_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: provider_selection_cubit_helpers.dart
/// Purpose: UI/format helpers extracted from provider_selection_cubit (§7
///          split).
/// Author: Amr Mesbah
/// Created At: 18/10/2026

part of 'provider_selection_cubit.dart';

extension ProviderSelectionHelpers on ProviderSelectionCubit {
  String formatPhoneNumber(dynamic mobilePhone) {
    if (mobilePhone == null) return '';

    var countryCode = mobilePhone.countryCode ?? '';
    var phone = mobilePhone.phone ?? '';

    countryCode = countryCode.replaceAll('[', '').replaceAll(']', '').trim();
    phone = phone.replaceAll('[', '').replaceAll(']', '').trim();

    if (countryCode.isEmpty || phone.isEmpty) return '';

    return '+$countryCode $phone';
  }
}
