/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: provider_data.dart
/// Purpose: Lightweight provider/employee data model used by the services home
///          screen.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

class ProviderData {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String gender;
  final String title;
  final String state;
  final String lastNameInArabic;
  final String firstNameInArabic;
  final String role;

  ProviderData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.gender,
    required this.title,
    required this.state,
    required this.lastNameInArabic,
    required this.firstNameInArabic,
    required this.role,
  });
}
