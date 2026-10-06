/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: build_social_update.dart
/// Purpose: Diff two social profiles and produce the Firestore update map.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N02. This logic used to be ~150 lines inlined in
/// `SocialController.updateAllSocialInformation`, interleaved with loading
/// indicators, snackbars and the Firestore call, and driven by five `changeX`
/// booleans that text-field listeners set. Two consequences of that design are
/// fixed by moving to a value diff:
///
///   * A listener fired on *any* text change, including the programmatic
///     `bioController.text = …` in `restartVariables()` — so simply opening the
///     page could mark the bio dirty.
///   * Clearing every skill or hobby produced an empty entry list, which the
///     old code skipped with `if (allSkillEntries.isNotEmpty)`, so a deletion
///     of the last row silently never persisted.

import 'package:grc_module/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:grc_module/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:grc_module/features/settings/se2_social/domain/entities/social_profile.dart';

class BuildSocialUpdate {
  const BuildSocialUpdate();

  /// Function Name: [call]
  ///
  /// Purpose: Build the set of changed top-level fields.
  ///
  /// Parameters:
  /// - [original]: the profile as loaded from the employee record.
  /// - [edited]: the profile as the user left it.
  ///
  /// Returns: [Map<String, dynamic>] — empty when nothing changed, which is
  ///          the caller's signal to skip the write entirely.
  Map<String, dynamic> call({
    required SocialProfile original,
    required SocialProfile edited,
  }) {
    final Map<String, dynamic> update = <String, dynamic>{};

    final String bio = edited.bio.trim();
    if (bio != original.bio.trim()) {
      update[SocialProfile.fieldBio] = <String>[bio];
      // Written alongside the value, as before: a changed bio resets its
      // approval status.
      update[SocialProfile.fieldBioStatus] = <String>[''];
    }

    // ADDED 24/8/2026. Diffed separately from [bio] on purpose: editing the
    // English text must not stamp the Arabic one, or every save would reset an
    // approval nobody touched.
    final String bioInArabic = edited.bioInArabic.trim();
    if (bioInArabic != original.bioInArabic.trim()) {
      update[SocialProfile.fieldBioInArabic] = <String>[bioInArabic];
      update[SocialProfile.fieldBioInArabicStatus] = <String>[''];
    }

    final List<AcademicEntry> academic = _cleanAcademic(edited.academicHistory);
    if (!_sameAcademic(academic, _cleanAcademic(original.academicHistory))) {
      update[SocialProfile.fieldAcademicHistory] = academic
          .map((AcademicEntry e) => <String, dynamic>{
                AcademicEntry.fieldDegree: <String>[e.degree.trim()],
                AcademicEntry.fieldDegreeStatus: <String>[''],
                AcademicEntry.fieldUniversity: <String>[e.university.trim()],
                AcademicEntry.fieldUniversityStatus: <String>[''],
                AcademicEntry.fieldGraduationYear: <String>[
                  e.graduationYear.trim()
                ],
                AcademicEntry.fieldGraduationYearStatus: <String>[''],
                AcademicEntry.fieldGpa: <String>[e.gpa.trim()],
                AcademicEntry.fieldGpaStatus: <String>[''],
              })
          .toList();
    }

    final List<SkillEntry> skills = _cleanSkills(edited.skills);
    if (!_sameSkills(skills, _cleanSkills(original.skills))) {
      update[SocialProfile.fieldSkills] = skills
          .map((SkillEntry s) => <String, dynamic>{
                SkillEntry.fieldItems: <String>[
                  s.name.trim(),
                  if (s.level.trim().isNotEmpty) s.level.trim(),
                ],
              })
          .toList();
    }

    final List<String> hobbies = _cleanHobbies(edited.hobbies);
    if (!_sameStrings(hobbies, _cleanHobbies(original.hobbies))) {
      update[SocialProfile.fieldHobbies] = hobbies
          .map((String h) => <String, dynamic>{
                SocialProfile.fieldHobbyItems: <String>[h],
              })
          .toList();
    }

    return update;
  }

  /// Blank rows exist only so the form has something to type into; they are
  /// never persisted.
  static List<AcademicEntry> _cleanAcademic(List<AcademicEntry> entries) =>
      entries.where((AcademicEntry e) => !e.isEmpty).toList();

  static List<SkillEntry> _cleanSkills(List<SkillEntry> entries) =>
      entries.where((SkillEntry e) => !e.isEmpty).toList();

  static List<String> _cleanHobbies(List<String> hobbies) => hobbies
      .map((String h) => h.trim())
      .where((String h) => h.isNotEmpty)
      .toList();

  static bool _sameAcademic(List<AcademicEntry> a, List<AcademicEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameSkills(List<SkillEntry> a, List<SkillEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameStrings(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
