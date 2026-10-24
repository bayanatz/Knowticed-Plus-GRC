/// Module: services / sv1_home_page_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: home_services_department_utils.dart
/// Purpose: Pure department-name normalization/localization helpers for the
///          home services page (maps free-text department strings — English or
///          Arabic, various spellings — to one of the fixed canonical
///          department keys used for filtering/counting).
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: none
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from home_page_services.dart
///     (fix item 1c — build-method/class-size decomposition).
library;

class HomeServicesDepartmentUtils {
  const HomeServicesDepartmentUtils._();

  /// Normalizes a free-text department string (English/Arabic, various
  /// spellings) to one of the fixed canonical department keys.
  static String normalize(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return '';
    }

    final k = raw.trim().toLowerCase();

    if (k == 'executive' || k.contains('executive') || k == 'exec') {
      return 'Executive';
    }

    if (k == 'customer support' ||
        (k.contains('customer') && k.contains('support')) ||
        k == 'support' ||
        k == 'customer service') {
      return 'Customer Support';
    }

    if (k == 'operations' || k.contains('operation') || k == 'ops') {
      return 'Operations';
    }

    if (k == 'finance' ||
        k.contains('financ') ||
        k == 'accounting' ||
        k.contains('account')) {
      return 'Finance';
    }

    if (k == 'information technology' ||
        k == 'it' ||
        k.contains('information') ||
        k.contains('technology') ||
        k == 'tech' ||
        k.contains('it ') ||
        k.startsWith('it')) {
      return 'Information Technology';
    }

    if (k == 'human resources' ||
        k == 'hr' ||
        k.contains('human') ||
        k.contains('resource') ||
        k == 'personnel') {
      return 'Human Resources';
    }

    if (k == 'marketing' ||
        k.contains('marketing') ||
        k.startsWith('market') ||
        k.startsWith('mark') ||
        k == 'mkt') {
      return 'Marketing';
    }

    if (k == 'sales' ||
        k.contains('sales') ||
        k == 'salse' ||
        k.startsWith('sale') ||
        k == 'business development') {
      return 'Sales';
    }

    if (k == 'data management' ||
        (k.contains('data') && k.contains('management')) ||
        k == 'data' ||
        k == 'data analytics') {
      return 'Data Management';
    }

    if (k == 'compliance & legal' ||
        k.contains('compliance') ||
        k.contains('legal') ||
        k == 'compliance' ||
        k == 'legal') {
      return 'Compliance & Legal';
    }

    if (k == 'software' ||
        k.contains('software') ||
        k == 'development' ||
        k.contains('dev') ||
        k == 'engineering') {
      return 'Software';
    }

    // Older records stored the department name in Arabic; these are stored
    // data values being matched, not UI text (rule H23 — UI labels come from
    // MainCoreDepartmentCubit / S.of(context)).
    if (k.contains('التنفيذي')) return 'Executive';
    if (k.contains('دعم العملاء')) return 'Customer Support';
    if (k.contains('العمليات')) return 'Operations';
    if (k.contains('المالية')) return 'Finance';
    if (k.contains('تقنية المعلومات') || k == 'it') {
      return 'Information Technology';
    }
    if (k.contains('الموارد البشرية')) return 'Human Resources';
    if (k.contains('التسويق')) return 'Marketing';
    if (k.contains('المبيعات')) return 'Sales';
    if (k.contains('إدارة البيانات')) return 'Data Management';
    if (k.contains('الامتثال') || k.contains('القانون')) {
      return 'Compliance & Legal';
    }
    if (k.contains('البرمجيات')) return 'Software';

    return raw.trim();
  }
}
