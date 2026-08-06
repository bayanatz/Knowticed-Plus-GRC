import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:lottie/lottie.dart';
import 'package:grc_module/core/custom/loading.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:grc_module/core/network/get_base_url.dart';

import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:grc_module/core/network/api_constants.dart';

class SocialController {
  SettingsController settingsController;

  SocialController({required this.settingsController}) {
    _initializeControllers();
  }

  // Track only current values for the last field
  String currentGraduateFrom = '';
  String currentUniversity = '';
  String currentYearOfGraduation = '';
  String currentGpa = '';

  String? bio;
  String? nameOfCertificate;
  String? issueBy;
  String? issueDate;

  List<TextEditingController> skillsControllers = [];
  List<TextEditingController> hobbiesControllers = [];
  TextEditingController bioController = TextEditingController();
  List<Map<String, TextEditingController>> academicHistoryFields = [];
  List<Map<String, TextEditingController>> certificateFields = [];
  List<Map<String, TextEditingController>> skillsFields = [];

  List<String?> skillss = [];
  List<String?> hobbiess = [];

  bool changeSkill = false;
  bool changeHobby = false;
  bool changeCertificate = false;
  bool changeBio = false;
  bool changeAcademicHistory = false;

  /// ✅ Show success dialog with Lottie animation
  void _showSuccessDialog() {
    bool lightMode = Theme.of(Get.context!).brightness == Brightness.light;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          width: 411.w,
          decoration: BoxDecoration(
            color: lightMode ? AppColors.white : AppColors.chatBackground,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(24.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/approved.json',
                width: 100.w,
                height: 100.h,
                repeat: false,
              ),

              SizedBox(height: 16.h),

              // Success Text
              Text(
                S.of(Get.context!).successMessage,
                style: StyleText.fontSize18Weight500.copyWith(
                  color: AppColors.text
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isDialogOpen == true) {
        Get.back(); // Close success dialog
      }
    });
  }

  /// Initialize controllers with employee data
  void _initializeControllers() {
    bioController.text = settingsController.employee?.bio.isNotEmpty ?? false
        ? settingsController.employee!.bio.last
        : "";

    // Add listener to bio controller
    bioController.addListener(() {
      changeBio = true;
    });
  }

  void restartController() {
    restartVariables();
    getCertificates();
    getAcademicHistory();
    getSkills();
    getHobbies();
  }

  void restartVariables() {
    bio = null;
    nameOfCertificate = null;
    issueBy = null;
    issueDate = null;

    currentGraduateFrom = '';
    currentUniversity = '';
    currentYearOfGraduation = '';
    currentGpa = '';

    changeBio = false;
    changeAcademicHistory = false;
    changeSkill = false;
    changeHobby = false;

    // ✅ This will now notify the listener in Bio widget and trigger setState
    String newBio = settingsController.employee?.bio.isNotEmpty ?? false
        ? settingsController.employee!.bio.last
        : "";

    bioController.text = newBio; // ← listener fires → setState → UI updates
  }

  getCertificates() {
    // Certificate implementation if needed
  }

  /// Get academic history from employee data
  getAcademicHistory() {
    academicHistoryFields.clear();

    List<Map<String, dynamic>> academicHistory =
        settingsController.employee?.academicHistory ?? [];

    print('🔍 Loading academic history from Firebase:');
    print('   Total entries: ${academicHistory.length}');

    for (int i = 0; i < academicHistory.length; i++) {
      Map<String, dynamic> history = academicHistory[i];

      String graduateFrom = _extractValue(history['Graduate_From']);
      String university = _extractValue(history['University']);
      String year = _extractValue(history['Year_Of_Graduation']);
      String gpa = _extractValue(history['GPA']);

      print('   Academic $i: graduateFrom="$graduateFrom", university="$university", year="$year", gpa="$gpa"');

      // Only add if there's actual data
      if (graduateFrom.isNotEmpty || university.isNotEmpty || year.isNotEmpty || gpa.isNotEmpty) {
        var graduateFromController = TextEditingController(text: graduateFrom);
        var universityController = TextEditingController(text: university);
        var yearController = TextEditingController(text: year);
        var gpaController = TextEditingController(text: gpa);

        // Add listeners
        graduateFromController.addListener(() => changeAcademicHistory = true);
        universityController.addListener(() => changeAcademicHistory = true);
        yearController.addListener(() => changeAcademicHistory = true);
        gpaController.addListener(() => changeAcademicHistory = true);

        academicHistoryFields.add({
          'graduateFrom': graduateFromController,
          'university': universityController,
          'yearOfGraduation': yearController,
          'gpa': gpaController,
        });
      }
    }

    print('   Loaded ${academicHistoryFields.length} non-empty academic entries');

    if (academicHistoryFields.isEmpty) {
      addAcademicHistoryField();
    }
  }

  /// Get skills from employee data
  getSkills() {
    skillsFields.clear();
    skillsControllers.clear();
    skillss.clear();

    dynamic skillsData = settingsController.employee?.skills;

    print('🔍 Loading skills from Firebase:');
    print('   Skills data type: ${skillsData.runtimeType}');
    print('   Skills data: $skillsData');

    if (skillsData == null) {
      print('   No skills data found');
      addSkillField();
      return;
    }

    List<dynamic> skills = skillsData is List ? skillsData : [];
    print('   Total skills in Firebase: ${skills.length}');

    for (int i = 0; i < skills.length; i++) {
      dynamic skill = skills[i];
      String skillName = '';
      String skillLevel = '';

      print('   Processing skill $i: $skill (type: ${skill.runtimeType})');

      if (skill is Map) {
        dynamic items = skill['items'];
        print('      Map format - items: $items');
        if (items is List && items.isNotEmpty) {
          skillName = items[0]?.toString() ?? '';
          skillLevel = items.length > 1 ? (items[1]?.toString() ?? '') : '';
        }
      } else if (skill is List) {
        print('      List format: $skill');
        if (skill.isNotEmpty) {
          skillName = skill[0]?.toString() ?? '';
          skillLevel = skill.length > 1 ? (skill[1]?.toString() ?? '') : '';
        }
      }

      print('      Extracted - name: "$skillName", level: "$skillLevel"');

      if (skillName.isNotEmpty) {
        var skillNameController = TextEditingController(text: skillName);
        var skillLevelController = TextEditingController(text: skillLevel);

        // Add listeners
        skillNameController.addListener(() => changeSkill = true);
        skillLevelController.addListener(() => changeSkill = true);

        skillsFields.add({
          'skillName': skillNameController,
          'skillLevel': skillLevelController,
        });

        skillsControllers.add(TextEditingController(text: skillName));
        skillss.add(skillLevel.isEmpty ? skillName : '$skillName - $skillLevel');
      } else {
        print('      ⏭️ Skipped (empty skill)');
      }
    }

    print('   Loaded ${skillsFields.length} non-empty skills');

    if (skillsFields.isEmpty) {
      print('   No skills found, adding empty field');
      addSkillField();
    }
  }

  /// Get hobbies from employee data
  getHobbies() {
    hobbiesControllers.clear();
    hobbiess.clear();

    dynamic hobbiesData = settingsController.employee?.hobbies;

    print('🔍 Loading hobbies from Firebase:');
    print('   Hobbies data type: ${hobbiesData.runtimeType}');
    print('   Hobbies data: $hobbiesData');

    if (hobbiesData == null) {
      print('   No hobbies data found');
      addHobbyField();
      return;
    }

    List<dynamic> hobbies = hobbiesData is List ? hobbiesData : [];
    print('   Total hobbies in Firebase: ${hobbies.length}');

    for (int i = 0; i < hobbies.length; i++) {
      dynamic hobby = hobbies[i];
      String hobbyString = '';

      print('   Processing hobby $i: $hobby (type: ${hobby.runtimeType})');

      if (hobby is Map) {
        dynamic items = hobby['items'];
        print('      Map format - items: $items');
        if (items is List && items.isNotEmpty) {
          hobbyString = items.join(', ');
        }
      } else if (hobby is List) {
        print('      List format: $hobby');
        if (hobby.isNotEmpty) {
          hobbyString = hobby.join(', ');
        }
      }

      print('      Extracted hobby: "$hobbyString"');

      if (hobbyString.isNotEmpty) {
        var hobbyController = TextEditingController(text: hobbyString);
        hobbyController.addListener(() => changeHobby = true);

        hobbiesControllers.add(hobbyController);
        hobbiess.add(hobbyString);
      } else {
        print('      ⏭️ Skipped (empty hobby)');
      }
    }

    print('   Loaded ${hobbiesControllers.length} non-empty hobbies');

    if (hobbiesControllers.isEmpty) {
      print('   No hobbies found, adding empty field');
      addHobbyField();
    }
  }

  /// Helper method to extract value from various formats
  String _extractValue(dynamic data) {
    if (data == null) return '';

    if (data is List && data.isNotEmpty) {
      return data[0]?.toString() ?? '';
    } else if (data is String) {
      return data;
    }

    return '';
  }

  // ============= ADD FIELD METHODS =============

  void addSkillField() {
    print('➕ Adding new skill field');
    var skillNameController = TextEditingController();
    var skillLevelController = TextEditingController();

    skillNameController.addListener(() {
      print('   Skill name changed: ${skillNameController.text}');
      changeSkill = true;
    });
    skillLevelController.addListener(() {
      print('   Skill level changed: ${skillLevelController.text}');
      changeSkill = true;
    });

    skillsFields.add({
      'skillName': skillNameController,
      'skillLevel': skillLevelController,
    });
    skillsControllers.add(TextEditingController());
    skillss.add(null);
    changeSkill = true;

    print('   Total skill fields now: ${skillsFields.length}');
  }

  void addHobbyField() {
    print('➕ Adding new hobby field');
    var hobbyController = TextEditingController();
    hobbyController.addListener(() {
      print('   Hobby changed: ${hobbyController.text}');
      changeHobby = true;
    });

    hobbiesControllers.add(hobbyController);
    hobbiess.add(null);
    changeHobby = true;

    print('   Total hobby fields now: ${hobbiesControllers.length}');
  }

  void addAcademicHistoryField() {
    print('➕ Adding new academic history field');
    var graduateFromController = TextEditingController();
    var universityController = TextEditingController();
    var yearController = TextEditingController();
    var gpaController = TextEditingController();

    graduateFromController.addListener(() {
      print('   Graduate from changed: ${graduateFromController.text}');
      changeAcademicHistory = true;
    });
    universityController.addListener(() {
      print('   University changed: ${universityController.text}');
      changeAcademicHistory = true;
    });
    yearController.addListener(() {
      print('   Year changed: ${yearController.text}');
      changeAcademicHistory = true;
    });
    gpaController.addListener(() {
      print('   GPA changed: ${gpaController.text}');
      changeAcademicHistory = true;
    });

    academicHistoryFields.add({
      'graduateFrom': graduateFromController,
      'university': universityController,
      'yearOfGraduation': yearController,
      'gpa': gpaController,
    });

    currentGraduateFrom = '';
    currentUniversity = '';
    currentYearOfGraduation = '';
    currentGpa = '';

    changeAcademicHistory = true;

    print('   Total academic history fields now: ${academicHistoryFields.length}');
  }

  // ============= REMOVE FIELD METHODS =============

  void removeAcademicHistoryField(int index) {
    if (academicHistoryFields.length > 1) {
      academicHistoryFields[index]['graduateFrom']?.dispose();
      academicHistoryFields[index]['university']?.dispose();
      academicHistoryFields[index]['yearOfGraduation']?.dispose();
      academicHistoryFields[index]['gpa']?.dispose();
      academicHistoryFields.removeAt(index);
      changeAcademicHistory = true;
    }
  }

  void removeSkillField(int index) {
    if (skillsFields.length > 1) {
      skillsFields[index]['skillName']?.dispose();
      skillsFields[index]['skillLevel']?.dispose();
      skillsFields.removeAt(index);

      skillsControllers[index].dispose();
      skillsControllers.removeAt(index);

      skillss.removeAt(index);
      changeSkill = true;
    }
  }

  void removeHobbyField(int index) {
    if (hobbiesControllers.length > 1) {
      hobbiesControllers[index].dispose();
      hobbiesControllers.removeAt(index);
      hobbiess.removeAt(index);
      changeHobby = true;
    }
  }

  // ============= UPDATE METHODS =============

  void updateCurrentAcademicValues(String fieldName, String value) {
    if (academicHistoryFields.isEmpty) return;

    changeAcademicHistory = true;

    switch (fieldName) {
      case 'graduateFrom':
        currentGraduateFrom = value;
        break;
      case 'university':
        currentUniversity = value;
        break;
      case 'yearOfGraduation':
        currentYearOfGraduation = value;
        break;
      case 'gpa':
        currentGpa = value;
        break;
    }
  }

  Map<String, String> getCurrentAcademicValues() {
    if (academicHistoryFields.isEmpty) return {};

    int lastIndex = academicHistoryFields.length - 1;
    return {
      'graduateFrom': academicHistoryFields[lastIndex]['graduateFrom']?.text ?? '',
      'university': academicHistoryFields[lastIndex]['university']?.text ?? '',
      'yearOfGraduation': academicHistoryFields[lastIndex]['yearOfGraduation']?.text ?? '',
      'gpa': academicHistoryFields[lastIndex]['gpa']?.text ?? '',
    };
  }

  // ============= SAVE TO FIREBASE =============

  /// ✅ Get the correct company ID dynamically
  Future<String> _getCompanyIdAsync() async {
    print('🏢 Getting Company ID from ApiConstants...');

    // ✅ ApiConstants.baseUri is set at login time as "Demo/{companyId}"
    String baseUri = ApiConstants.baseUri; // e.g. "Demo/75440689"
    String companyId = baseUri.split("/").last;

    print('   ApiConstants.baseUri: $baseUri');
    print('   ✅ Company ID: $companyId');

    return companyId;
  }

  Future<void> updateAllSocialInformation() async {
    try {
      print('========================================');
      print('🚀 Starting updateAllSocialInformation');
      print('========================================');
      print('📍 Current Employee ID: ${settingsController.employee?.id}');
      print('📍 Current Employee Email: ${settingsController.employee?.email.lastOrNull}');

      showLoadingIndicator();

      // ✅ PREPARE UPDATE MAP - Direct Firebase update
      Map<String, dynamic> updateMap = {};
      bool hasChanges = false;

      // === BIO UPDATE ===
      String currentBio = settingsController.employee?.bio.isNotEmpty ?? false
          ? settingsController.employee!.bio.last
          : "";
      String newBio = bioController.text.trim();

      print('\n📝 Bio Check:');
      print('   Current: "$currentBio"');
      print('   New: "$newBio"');
      print('   changeBio flag: $changeBio');

      if (currentBio != newBio || changeBio) {
        print('   ✅ Bio will be updated');
        updateMap['Bio'] = [newBio];
        updateMap['Bio_Status'] = [''];
        hasChanges = true;
        changeBio = false;
      }

      // === ACADEMIC HISTORY UPDATE ===
      print('\n🎓 Academic History Check:');
      print('   changeAcademicHistory flag: $changeAcademicHistory');
      print('   Total fields: ${academicHistoryFields.length}');

      if (changeAcademicHistory && academicHistoryFields.isNotEmpty) {
        print('   ✅ Academic history will be updated');

        List<Map<String, dynamic>> allAcademicEntries = [];

        for (int i = 0; i < academicHistoryFields.length; i++) {
          var field = academicHistoryFields[i];
          String graduateFrom = field['graduateFrom']!.text.trim();
          String university = field['university']!.text.trim();
          String yearOfGrad = field['yearOfGraduation']!.text.trim();
          String gpaValue = field['gpa']!.text.trim();

          print('   Field $i:');
          print('      graduateFrom: "$graduateFrom"');
          print('      university: "$university"');
          print('      yearOfGrad: "$yearOfGrad"');
          print('      gpa: "$gpaValue"');

          // Only add non-empty entries
          if (graduateFrom.isNotEmpty || university.isNotEmpty || yearOfGrad.isNotEmpty) {
            Map<String, dynamic> academicEntry = {
              'Graduate_From': [graduateFrom],
              'Graduate_From_Status': [''],
              'University': [university],
              'University_Status': [''],
              'Year_Of_Graduation': [yearOfGrad],
              'Year_Of_Graduation_Status': [''],
              'GPA': [gpaValue],
              'GPA_Status': [''],
            };

            allAcademicEntries.add(academicEntry);
            print('      ✅ Added to batch');
          } else {
            print('      ⏭️ Skipped (empty)');
          }
        }

        if (allAcademicEntries.isNotEmpty) {
          updateMap['Academic_History'] = allAcademicEntries;
          print('   📦 Total academic entries to save: ${allAcademicEntries.length}');
          hasChanges = true;
        }

        changeAcademicHistory = false;
      }

      // === SKILLS UPDATE ===
      print('\n🎯 Skills Check:');
      print('   changeSkill flag: $changeSkill');
      print('   Total skill fields: ${skillsFields.length}');

      if (changeSkill && skillsFields.isNotEmpty) {
        print('   ✅ Skills will be updated');

        List<Map<String, dynamic>> allSkillEntries = [];

        for (int i = 0; i < skillsFields.length; i++) {
          var field = skillsFields[i];
          String skillName = field['skillName']!.text.trim();
          String skillLevel = field['skillLevel']!.text.trim();

          print('   Skill $i:');
          print('      name: "$skillName"');
          print('      level: "$skillLevel"');

          if (skillName.isNotEmpty) {
            List<String> skillItems = [skillName];
            if (skillLevel.isNotEmpty) {
              skillItems.add(skillLevel);
            }

            allSkillEntries.add({'items': skillItems});
            print('      ✅ Added: $skillItems');
          } else {
            print('      ⏭️ Skipped (empty)');
          }
        }

        if (allSkillEntries.isNotEmpty) {
          updateMap['Skills'] = allSkillEntries;
          print('   📦 Total skills to save: ${allSkillEntries.length}');
          hasChanges = true;
        }

        changeSkill = false;
      }

      // === HOBBIES UPDATE ===
      print('\n🎨 Hobbies Check:');
      print('   changeHobby flag: $changeHobby');
      print('   Total hobby controllers: ${hobbiesControllers.length}');

      if (changeHobby && hobbiesControllers.isNotEmpty) {
        print('   ✅ Hobbies will be updated');

        List<Map<String, dynamic>> allHobbyEntries = [];

        for (int i = 0; i < hobbiesControllers.length; i++) {
          var controller = hobbiesControllers[i];
          String hobbyText = controller.text.trim();

          print('   Hobby $i: "$hobbyText"');

          if (hobbyText.isNotEmpty) {
            allHobbyEntries.add({'items': [hobbyText]});
            print('      ✅ Added');
          } else {
            print('      ⏭️ Skipped (empty)');
          }
        }

        if (allHobbyEntries.isNotEmpty) {
          updateMap['Hobbies'] = allHobbyEntries;
          print('   📦 Total hobbies to save: ${allHobbyEntries.length}');
          hasChanges = true;
        }

        changeHobby = false;
      }

      // === SAVE TO FIREBASE ===
      print('\n📊 FINAL Summary:');
      print('   hasChanges: $hasChanges');
      print('   Update map keys: ${updateMap.keys.toList()}');

      if (hasChanges) {
        String? employeeId = settingsController.employee?.id;

        if (employeeId == null || employeeId.isEmpty) {
          throw Exception('Employee ID is null');
        }

        // ✅ Dynamically get the correct company ID
        String companyId = await _getCompanyIdAsync();

        print('\n💾 Saving to Firebase...');
        print('   Company ID: $companyId');
        print('   Employee ID: $employeeId');
        print('   Path: Demo/$companyId/Employees_Info/$employeeId');
        print('   Data to update: $updateMap');

        try {
          await FirebaseFirestore.instance
              .collection(getBaseUrl('Employees_Info'))
              .doc(employeeId)
              .update(updateMap);

          print('✅ Successfully saved to Firebase');

          hideLoadingIndicator();
          _showSuccessDialog();

          print('\n🔄 Reloading employee data from Firebase...');
          await settingsController.getEmployee();
          restartController();

          print('✅ Reload complete');
          print('   Bio: ${settingsController.employee?.bio.lastOrNull}');
          print('   Academic History count: ${settingsController.employee?.academicHistory.length}');
          print('   Skills count: ${settingsController.employee?.skills.length}');
          print('   Hobbies count: ${settingsController.employee?.hobbies.length}');

          print('========================================');
          print('🏁 updateAllSocialInformation completed');
          print('========================================\n');
        } catch (error) {
          print('❌ Firebase save error: $error');
          hideLoadingIndicator();

          Get.snackbar(
            'Error',
            'Failed to save: ${error.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          throw error;
        }
      } else {
        print('⚠️ No changes detected');
        hideLoadingIndicator();

        Get.snackbar(
          'Info',
          'No changes detected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

    } catch (e, stackTrace) {
      print('========================================');
      print('❌ ERROR: $e');
      print('Stack trace: $stackTrace');
      print('========================================');

      hideLoadingIndicator();

      Get.snackbar(
        'Error',
        'Failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void dispose() {
    bioController.dispose();

    for (var controller in skillsControllers) {
      controller.dispose();
    }

    for (var controller in hobbiesControllers) {
      controller.dispose();
    }

    for (var field in skillsFields) {
      field['skillName']?.dispose();
      field['skillLevel']?.dispose();
    }

    for (var field in academicHistoryFields) {
      field['graduateFrom']?.dispose();
      field['university']?.dispose();
      field['yearOfGraduation']?.dispose();
      field['gpa']?.dispose();
    }

    for (var field in certificateFields) {
      field['nameOfCertificate']?.dispose();
      field['issueBy']?.dispose();
      field['issueDate']?.dispose();
    }
  }
}