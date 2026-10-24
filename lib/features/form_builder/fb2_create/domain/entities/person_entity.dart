/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: person_entity.dart
/// Description: `PersonEntity`, one employee as the Form Builder shows it.
///              Plain data: built by `PersonEntityFactory` (data layer).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:intl/intl.dart';

/// One employee as the Form Builder shows it.
class PersonEntity {
  String department, id;
  bool isSelected;
  String image;
  String arabicName;
  String englishName;
  String titleEnglish;
  String titleArabic;
  String phone;

  /// The department's English name, filled in by the factory.
  String departmentNameEnglish;

  /// The department's Arabic name, filled in by the factory.
  String departmentNameArabic;

  PersonEntity({
    required this.department,
    required this.id,
    required this.isSelected,
    required this.image,
    required this.arabicName,
    required this.englishName,
    required this.titleEnglish,
    required this.titleArabic,
    required this.phone,
    this.departmentNameEnglish = '',
    this.departmentNameArabic = '',
  });

  /// Method Name: [copy]
  ///
  /// Purpose: an unselected copy of this person.
  ///
  /// Returns: a new [PersonEntity].
  PersonEntity copy() => PersonEntity(
        department: department,
        id: id,
        isSelected: false,
        image: image,
        arabicName: arabicName,
        englishName: englishName,
        titleEnglish: titleEnglish,
        titleArabic: titleArabic,
        phone: phone,
        departmentNameEnglish: departmentNameEnglish,
        departmentNameArabic: departmentNameArabic,
      );

  /// True when the app is showing Arabic (the locale set by the l10n loader).
  static bool get _arabic => Intl.getCurrentLocale().startsWith('ar');

  /// The name in the app's language.
  String get name => _arabic ? arabicName : englishName;

  /// The job title in the app's language.
  String get title => _arabic ? titleArabic : titleEnglish;

  /// The department name in the app's language, or 'N/A' when unknown.
  String get departmentName {
    final String value = _arabic
        ? (departmentNameArabic.isNotEmpty
            ? departmentNameArabic
            : departmentNameEnglish)
        : (departmentNameEnglish.isNotEmpty
            ? departmentNameEnglish
            : departmentNameArabic);
    return value.isEmpty ? 'N/A' : value;
  }
}
