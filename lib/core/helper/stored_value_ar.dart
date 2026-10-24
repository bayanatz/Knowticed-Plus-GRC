/// Module: core / helper
///
/// Shows a saved English value (country, city, industry, company size,
/// relationship, language …) in Arabic on the Arabic screen. DISPLAY ONLY —
/// the stored text is never changed (Moataz 23/10/2026: "why is it not
/// translated?").
library;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/countries_list.dart';
import 'package:knowticed_plus/core/helper/location_data_service.dart';

abstract final class StoredValueAr {
  static const Map<String, String> _ar = <String, String>{
    'Egypt': 'مصر',
    'Saudi Arabia': 'السعودية',
    'United Arab Emirates': 'الإمارات العربية المتحدة',
    'Kuwait': 'الكويت',
    'Cairo': 'القاهرة',
    'Cairo Governorate': 'محافظة القاهرة',
    'Giza': 'الجيزة',
    'Alexandria': 'الإسكندرية',
    'Nasr City': 'مدينة نصر',
    'Sheikh Zayed': 'الشيخ زايد',
    'New Administrative Capital': 'العاصمة الإدارية الجديدة',
    'Entertainment': 'الترفيه',
    'Food Services': 'خدمات الأغذية',
    'Government': 'حكومي',
    'Utilities': 'المرافق',
    'Administration': 'الإدارة',
    'Business': 'الأعمال',
    'Transportation': 'النقل',
    'Education': 'التعليم',
    'Real Estate': 'العقارات',
    'Construction': 'الإنشاءات',
    'Healthcare': 'الرعاية الصحية',
    'Manufacturing': 'التصنيع',
    'Engineering': 'الهندسة',
    'Financial Services': 'الخدمات المالية',
    'Online Retail': 'التجزئة عبر الإنترنت',
    'Hospitality': 'الضيافة',
    'Other': 'أخرى',
    'Spouse': 'الزوج / الزوجة',
    'Mother': 'الأم',
    'Father': 'الأب',
    'Brother': 'الأخ',
    'Sister': 'الأخت',
    'Son': 'الابن',
    'Daughter': 'الابنة',
    'Friend': 'صديق',
    'Arabic': 'العربية',
    'English': 'الإنجليزية',
    'French': 'الفرنسية',
    'German': 'الألمانية',
    'Spanish': 'الإسبانية',
    'Italian': 'الإيطالية',
    'Turkish': 'التركية',
    'Urdu': 'الأردية',
    'Hindi': 'الهندية',
    'Chinese': 'الصينية',
    'Parent': 'الوالد/الوالدة',
    'Child': 'ابن/ابنة',
    'Sibling': 'أخ/أخت',
    'Relative': 'قريب',
  };

  /// [value] in Arabic when the screen is Arabic and a translation is known;
  /// company sizes ("500 To 1000", also "To 1000 500") become "500 إلى 1000".
  static String of(BuildContext context, String value) {
    final String v = value.trim();
    // Get.locale, not Localizations: this is also called from initState.
    if (Get.locale?.languageCode != 'ar') {
      // English screen: a value saved while the app was in Arabic (country
      // picked on the Arabic screen) is shown in English (Moataz 23/10/2026).
      return _enOf(v) ??
          LocationDataService.instance.translatePlace(v, toArabic: false) ??
          value;
    }
    final String? country = _countryAr[v.toLowerCase()];
    if (country != null) return country;
    final String? place =
        LocationDataService.instance.translatePlace(v, toArabic: true);
    if (place != null) return place;
    final String? hit = _ar[v] ?? _ar[_titleCase(v)];
    if (hit != null) return hit;
    final List<int> n = RegExp(r'\d+')
        .allMatches(v)
        .map((Match m) => int.parse(m.group(0)!))
        .toList()
      ..sort();
    if (n.length == 2 && v.toLowerCase().contains('to')) {
      return '${n[0]} إلى ${n[1]}';
    }
    if (n.length == 1 && v.endsWith('+') && RegExp(r'^\d+\+$').hasMatch(v)) {
      return '+${n[0]}';
    }
    return value;
  }

  static final Map<String, String> _countryAr = <String, String>{
    for (final Country c in countries)
      if (c.nameTranslations['ar'] != null)
        c.name.toLowerCase(): c.nameTranslations['ar']!,
  };

  static final Map<String, String> _toEn = <String, String>{
    for (final Country c in countries)
      if (c.nameTranslations['ar'] != null) c.nameTranslations['ar']!: c.name,
    for (final MapEntry<String, String> e in _ar.entries) e.value: e.key,
  };

  static String? _enOf(String v) => _toEn[v];

  static String _titleCase(String s) => s
      .split(' ')
      .map((String w) => w.isEmpty
          ? w
          : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}
