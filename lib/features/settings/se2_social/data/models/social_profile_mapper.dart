/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_profile_mapper.dart
/// Purpose: Read a [SocialProfile] out of the raw employee history model.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N01. The parsing below is a straight port of
/// `getSkills` / `getHobbies` / `getAcademicHistory` from the controller,
/// including their tolerance for the three shapes each collection has been
/// stored in over time (`{'items': [...]}`, a bare `List`, and — for academic
/// fields — either a single-element list or a plain string). That tolerance is
/// deliberate: production documents contain all of them.

import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:grc_module/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:grc_module/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:grc_module/features/settings/se2_social/domain/entities/social_profile.dart';

abstract class SocialProfileMapper {
  /// Function Name: [fromEmployee]
  ///
  /// Purpose: Build the read model for the social page.
  ///
  /// Parameters:
  /// - [employee]: the loaded employee, or `null` before it has loaded.
  ///
  /// Returns: [SocialProfile] — [SocialProfile.empty] for a null employee.
  static SocialProfile fromEmployee(NewEmployeeModelHistory? employee) {
    if (employee == null) return SocialProfile.empty;

    return SocialProfile(
      bio: employee.bio.isNotEmpty ? employee.bio.last : '',
      bioInArabic:
          employee.bioInArabic.isNotEmpty ? employee.bioInArabic.last : '',
      academicHistory: _academic(employee.academicHistory),
      skills: _skills(employee.skills),
      hobbies: _hobbies(employee.hobbies),
    );
  }

  static List<AcademicEntry> _academic(List<Map<String, dynamic>>? raw) {
    if (raw == null) return const <AcademicEntry>[];

    final List<AcademicEntry> entries = <AcademicEntry>[];
    for (final Map<String, dynamic> history in raw) {
      final AcademicEntry entry = AcademicEntry(
        degree: _value(history[AcademicEntry.fieldDegree]),
        university: _value(history[AcademicEntry.fieldUniversity]),
        graduationYear: _value(history[AcademicEntry.fieldGraduationYear]),
        gpa: _value(history[AcademicEntry.fieldGpa]),
      );
      if (!entry.isEmpty || entry.gpa.isNotEmpty) entries.add(entry);
    }
    return entries;
  }

  static List<SkillEntry> _skills(List<dynamic>? raw) {
    if (raw == null) return const <SkillEntry>[];

    final List<SkillEntry> entries = <SkillEntry>[];
    for (final dynamic skill in raw) {
      final List<dynamic> items = _items(skill);
      if (items.isEmpty) continue;

      final String name = items.first?.toString() ?? '';
      final String level =
          items.length > 1 ? (items[1]?.toString() ?? '') : '';
      if (name.isNotEmpty) entries.add(SkillEntry(name: name, level: level));
    }
    return entries;
  }

  static List<String> _hobbies(List<dynamic>? raw) {
    if (raw == null) return const <String>[];

    final List<String> hobbies = <String>[];
    for (final dynamic hobby in raw) {
      final List<dynamic> items = _items(hobby);
      if (items.isEmpty) continue;

      final String text = items.join(', ');
      if (text.isNotEmpty) hobbies.add(text);
    }
    return hobbies;
  }

  /// Accepts both `{'items': [...]}` and a bare list.
  static List<dynamic> _items(dynamic value) {
    if (value is Map) {
      final dynamic items = value[SkillEntry.fieldItems];
      return items is List ? items : const <dynamic>[];
    }
    if (value is List) return value;
    return const <dynamic>[];
  }

  /// Academic fields are stored either as a one-element list or a plain string.
  static String _value(dynamic data) {
    if (data == null) return '';
    if (data is List) return data.isEmpty ? '' : (data.first?.toString() ?? '');
    if (data is String) return data;
    return '';
  }
}
