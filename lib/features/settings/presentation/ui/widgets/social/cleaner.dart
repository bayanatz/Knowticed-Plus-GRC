import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/constants/api_constants.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/core/network/get_base_url.dart';

/// ✅ USE THIS ONCE TO CLEAN YOUR FIREBASE DATA
/// Call this method BEFORE using the update function
class FirebaseDataCleaner {

  /// Clean empty skills, hobbies, and academic history for a specific employee
  static Future<void> cleanEmployeeData({
    required String companyId,
    required String employeeId,
  }) async {
    try {
      print('🧹 Starting Firebase data cleanup...');
      print('   Company ID: $companyId');
      print('   Employee ID: $employeeId');

      showLoadingIndicator();

      // Get the employee document
      DocumentReference docRef = FirebaseFirestore.instance

          .collection(getBaseUrl('Employees_Info'))
          .doc(employeeId);

      DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        print('❌ Employee document not found!');
        hideLoadingIndicator();
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // ✅ Clean Skills
      List<dynamic> skills = data['Skills'] ?? [];
      print('\n📍 Original Skills count: ${skills.length}');

      List<List<String>> cleanedSkills = [];
      for (var skill in skills) {
        if (skill is List && skill.isNotEmpty) {
          String skillName = skill[0].toString().trim();
          if (skillName.isNotEmpty) {
            if (skill.length > 1) {
              cleanedSkills.add([skillName, skill[1].toString()]);
            } else {
              cleanedSkills.add([skillName]);
            }
          }
        }
      }
      print('✅ Cleaned Skills count: ${cleanedSkills.length}');
      print('   Skills: $cleanedSkills');

      // ✅ Clean Hobbies
      List<dynamic> hobbies = data['Hobbies'] ?? [];
      print('\n📍 Original Hobbies count: ${hobbies.length}');

      List<List<String>> cleanedHobbies = [];
      for (var hobby in hobbies) {
        if (hobby is List && hobby.isNotEmpty) {
          String hobbyText = hobby.join(', ').trim();
          if (hobbyText.isNotEmpty) {
            cleanedHobbies.add([hobbyText]);
          }
        }
      }
      print('✅ Cleaned Hobbies count: ${cleanedHobbies.length}');
      print('   Hobbies: $cleanedHobbies');

      // ✅ Clean Academic History
      List<dynamic> academicHistory = data['Academic_History'] ?? [];
      print('\n📍 Original Academic History count: ${academicHistory.length}');

      List<Map<String, dynamic>> cleanedAcademicHistory = [];
      for (var history in academicHistory) {
        if (history is Map) {
          String graduateFrom = (history['Graduate_From'] as List?)?.first?.toString()?.trim() ?? '';
          String university = (history['University'] as List?)?.first?.toString()?.trim() ?? '';
          String year = (history['Year_Of_Graduation'] as List?)?.first?.toString()?.trim() ?? '';
          String gpa = (history['GPA'] as List?)?.first?.toString()?.trim() ?? '';

          if (graduateFrom.isNotEmpty || university.isNotEmpty || year.isNotEmpty) {
            cleanedAcademicHistory.add({
              'Graduate_From': [graduateFrom],
              'Graduate_From_Status': [''],
              'University': [university],
              'University_Status': [''],
              'Year_Of_Graduation': [year],
              'Year_Of_Graduation_Status': [''],
              'GPA': [gpa],
              'GPA_Status': [''],
            });
          }
        }
      }
      print('✅ Cleaned Academic History count: ${cleanedAcademicHistory.length}');

      // ✅ Update Firebase with cleaned data
      await docRef.update({
        'Skills': cleanedSkills,
        'Hobbies': cleanedHobbies,
        'Academic_History': cleanedAcademicHistory,
      });

      print('\n✅ Firebase cleanup completed successfully!');
      print('========================================\n');

      hideLoadingIndicator();

      Get.snackbar(
        'Success',
        'Firebase data cleaned successfully!\nSkills: ${cleanedSkills.length}, Hobbies: ${cleanedHobbies.length}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );

    } catch (e) {
      print('❌ Error cleaning Firebase data: $e');
      hideLoadingIndicator();

      Get.snackbar(
        'Error',
        'Failed to clean data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    }
  }
}