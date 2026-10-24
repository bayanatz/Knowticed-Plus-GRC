/// Module: services / sv6_services_requests / data
///
///*************************** FILE INFO ****************************///
/// File Name: service_filter_model.dart
/// Purpose: View-model holding the active service-request filter state.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

class ServiceFilterModel {
  // Map keys
  static const String kSearchQuery = 'searchQuery';
  static const String kSelectedDepartment = 'selectedDepartment';
  static const String kUserEmail = 'userEmail';
  static const String kUserDepartment = 'userDepartment';

  final String searchQuery;
  final String selectedDepartment;
  final String userEmail;
  final String userDepartment;

  ServiceFilterModel({
    required this.searchQuery,
    required this.selectedDepartment,
    required this.userEmail,
    required this.userDepartment,
  });

  factory ServiceFilterModel.initial() {
    return ServiceFilterModel(
      searchQuery: '',
      selectedDepartment: 'All',
      userEmail: '',
      userDepartment: '',
    );
  }

  factory ServiceFilterModel.fromMap(Map<String, dynamic> map) {
    return ServiceFilterModel(
      searchQuery: map[kSearchQuery]?.toString() ?? '',
      selectedDepartment: map[kSelectedDepartment]?.toString() ?? 'All',
      userEmail: map[kUserEmail]?.toString() ?? '',
      userDepartment: map[kUserDepartment]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      kSearchQuery: searchQuery,
      kSelectedDepartment: selectedDepartment,
      kUserEmail: userEmail,
      kUserDepartment: userDepartment,
    };
  }

  ServiceFilterModel copyWith({
    String? searchQuery,
    String? selectedDepartment,
    String? userEmail,
    String? userDepartment,
  }) {
    return ServiceFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      userEmail: userEmail ?? this.userEmail,
      userDepartment: userDepartment ?? this.userDepartment,
    );
  }
}
