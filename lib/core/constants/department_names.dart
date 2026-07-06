// ******************* FILE INFO *******************
// File Name: department_names
// Description: Shared English->Arabic department-name lookup.
// Module: core / constants / services_management
// *************************************************

/// Centralised English -> Arabic department-name map.
///
/// Previously this bilingual map was duplicated inline across several S5/S6
/// widgets and pages (§13 / §15 / §17 — no duplicated data maps in widgets).
class DepartmentNames {
  const DepartmentNames._();

  /// Arabic label for the catch-all "Other" department bucket.
  static const String otherAr = 'أخرى';

  static const Map<String, String> enToAr = {
    "Executive": "الإدارة التنفيذية",
    "Customer Support": "دعم العملاء",
    "Finance": "المالية",
    "Operations": "العمليات",
    "Information Technology": "تقنية المعلومات",
    "Human Resources": "الموارد البشرية",
    "Marketing": "التسويق",
    "Sales": "المبيعات",
    "Data Management": "إدارة البيانات",
    "Compliance & Legal": "الامتثال والشؤون القانونية",
    "Software": "البرمجيات",
  };
}
