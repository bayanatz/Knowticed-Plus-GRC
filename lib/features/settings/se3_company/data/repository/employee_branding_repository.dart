// PORTED into services_app under features/settings.
// Source: services_app features/employees/employee_branding/data/repo/employee_branding_repository.dart
// Imports rewired to the equivalents that already exist in services_app.

/// ************************ FILE INFO ********************************///
/// File Name: employee_branding_repository.dart
/// Author: Amr Mesbah
/// Created: 2026-01-25
/// Purpose: Repository for employee branding CRUD operations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/features/settings/se3_company/domain/entities/employee_branding_model.dart';

class EmployeeBrandingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get collection path for Employee_Data
  String _getEmployeeDataPath() {
    String companyId = ApiConstants.baseUri.split("/").last;
    return 'Demo/$companyId/Employee_Data';
  }

  /// Initialize Employee_Data collection for all employees
  /// This should be called once when implementing this feature
  Future<void> initializeEmployeeDataCollection({
    String? companyLogo,
    String? companyPrimaryColor,
    String? companySecondaryColor,
    String? companyFontEnglish,
    String? companyFontArabic,
  }) async {
    print('🔄 ===== INITIALIZE EMPLOYEE_DATA COLLECTION START =====');

    try {
      String companyId = ApiConstants.baseUri.split("/").last;

      // Check if Employee_Data collection already has documents
      QuerySnapshot existingDocs = await _db
          .collection(_getEmployeeDataPath())
          .limit(1)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        print('ℹ️ Employee_Data collection already initialized');
        print('🔄 ===== INITIALIZE EMPLOYEE_DATA COLLECTION END =====');
        return;
      }

      print('🔄 Employee_Data collection is empty - initializing...');

      // Get all employees from Employees_Info
      QuerySnapshot employeesSnapshot = await _db
          .collection('Demo/$companyId/Employees_Info')
          .get();

      print('🔄 Found ${employeesSnapshot.docs.length} employees to initialize');

      WriteBatch batch = _db.batch();
      int count = 0;

      for (var doc in employeesSnapshot.docs) {
        Map<String, dynamic> employeeData = doc.data() as Map<String, dynamic>;

        // Get employee ID from document
        String? employeeId = employeeData['ID'];

        if (employeeId == null || employeeId.isEmpty) {
          print('⚠️ Skipping employee with no ID: ${doc.id}');
          continue;
        }

        // Create default branding using company branding
        EmployeeBrandingModel defaultBranding = EmployeeBrandingModel.fromCompanyBranding(
          employeeId: employeeId,
          companyLogo: companyLogo,
          companyPrimaryColor: companyPrimaryColor,
          companySecondaryColor: companySecondaryColor,
          companyFontEnglish: companyFontEnglish,
          companyFontArabic: companyFontArabic,
        );

        // Add to batch
        DocumentReference brandingRef = _db
            .collection(_getEmployeeDataPath())
            .doc(employeeId);

        batch.set(brandingRef, defaultBranding.toMap());
        count++;

        print('✅ Queued employee $employeeId for initialization');
      }

      // Commit batch
      print('🔄 Committing batch with $count employees...');
      await batch.commit();
      print('✅ Successfully initialized $count employee branding documents');

      print('🔄 ===== INITIALIZE EMPLOYEE_DATA COLLECTION END =====');
    } catch (e, stackTrace) {
      print('❌ ERROR initializing Employee_Data collection: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get employee branding by employee ID
  Future<EmployeeBrandingModel?> getEmployeeBranding(String employeeId) async {
    print('🔍 ===== GET EMPLOYEE BRANDING START =====');
    print('🔍 Employee ID: $employeeId');

    try {
      DocumentSnapshot doc = await _db
          .collection(_getEmployeeDataPath())
          .doc(employeeId)
          .get();

      if (doc.exists) {
        print('✅ Employee branding found');
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        EmployeeBrandingModel branding = EmployeeBrandingModel.fromMap(data);
        print('🔍 Logo: ${branding.logo}');
        print('🔍 Primary Color: ${branding.primaryColor}');
        print('🔍 Secondary Color: ${branding.secondaryColor}');
        print('🔍 Font English: ${branding.fontEnglish}');
        print('🔍 Font Arabic: ${branding.fontArabic}');
        print('🔍 ===== GET EMPLOYEE BRANDING END (SUCCESS) =====');
        return branding;
      } else {
        print('⚠️ No branding found for employee $employeeId');
        print('🔍 ===== GET EMPLOYEE BRANDING END (NOT FOUND) =====');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ ERROR getting employee branding: $e');
      print('❌ Stack trace: $stackTrace');
      print('🔍 ===== GET EMPLOYEE BRANDING END (ERROR) =====');
      return null;
    }
  }

  /// Save or update employee branding
  Future<void> saveEmployeeBranding(EmployeeBrandingModel branding) async {
    print('💾 ===== SAVE EMPLOYEE BRANDING START =====');
    print('💾 Employee ID: ${branding.employeeId}');

    try {
      // Update timestamp
      branding = branding.copyWith(timestamp: Timestamp.now());

      await _db
          .collection(_getEmployeeDataPath())
          .doc(branding.employeeId)
          .set(branding.toMap(), SetOptions(merge: true));

      print('✅ Employee branding saved successfully');
      print('💾 ===== SAVE EMPLOYEE BRANDING END =====');
    } catch (e, stackTrace) {
      print('❌ ERROR saving employee branding: $e');
      print('❌ Stack trace: $stackTrace');
      print('💾 ===== SAVE EMPLOYEE BRANDING END (ERROR) =====');
      rethrow;
    }
  }

  /// Reset employee branding to company defaults
  Future<void> resetToCompanyBranding({
    required String employeeId,
    String? companyLogo,
    String? companyPrimaryColor,
    String? companySecondaryColor,
    String? companyFontEnglish,
    String? companyFontArabic,
  }) async {
    print('🔄 ===== RESET EMPLOYEE BRANDING START =====');
    print('🔄 Employee ID: $employeeId');

    try {
      EmployeeBrandingModel defaultBranding = EmployeeBrandingModel.fromCompanyBranding(
        employeeId: employeeId,
        companyLogo: companyLogo,
        companyPrimaryColor: companyPrimaryColor,
        companySecondaryColor: companySecondaryColor,
        companyFontEnglish: companyFontEnglish,
        companyFontArabic: companyFontArabic,
      );

      await saveEmployeeBranding(defaultBranding);

      print('✅ Employee branding reset to company defaults');
      print('🔄 ===== RESET EMPLOYEE BRANDING END =====');
    } catch (e, stackTrace) {
      print('❌ ERROR resetting employee branding: $e');
      print('❌ Stack trace: $stackTrace');
      print('🔄 ===== RESET EMPLOYEE BRANDING END (ERROR) =====');
      rethrow;
    }
  }

  /// Delete employee branding (use company defaults)
  Future<void> deleteEmployeeBranding(String employeeId) async {
    print('🗑️ ===== DELETE EMPLOYEE BRANDING START =====');
    print('🗑️ Employee ID: $employeeId');

    try {
      await _db
          .collection(_getEmployeeDataPath())
          .doc(employeeId)
          .delete();

      print('✅ Employee branding deleted');
      print('🗑️ ===== DELETE EMPLOYEE BRANDING END =====');
    } catch (e, stackTrace) {
      print('❌ ERROR deleting employee branding: $e');
      print('❌ Stack trace: $stackTrace');
      print('🗑️ ===== DELETE EMPLOYEE BRANDING END (ERROR) =====');
      rethrow;
    }
  }

  /// Check if Employee_Data collection exists and is initialized
  Future<bool> isInitialized() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_getEmployeeDataPath())
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ ERROR checking if initialized: $e');
      return false;
    }
  }
}