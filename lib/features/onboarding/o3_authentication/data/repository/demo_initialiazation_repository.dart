///************************** FILE INFO **************************///
/// File Name: demo_initialiazation_repository.dart
/// Purpose: Contains the repository for demo data initialization feature.
/// Author: Amr Mesbah
/// Created At: 4/1/2025
/// Updated: 9/12/2025 - Structure now created by admin app, just validate here
/// ✅ SIMPLIFIED VERSION: Admin app creates structure, this just validates

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/data_source/remote_data_source.dart' hide Right;
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';

import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_company_model.dart';

class DemoInitializationRepository {
  DemoRemoteDataSource demoRemoteDataSource = DemoRemoteDataSource();

  /// function name: startDemoAdminData
  /// function purpose: Validate that demo structure exists (created by admin app)
  /// parameters:
  ///           companyModel - DemoCompanyModel - the company model to validate
  /// ✅ SIMPLIFIED: Just check if structure exists, no creation needed
  startDemoAdminData({required DemoCompanyModel companyModel}) async {
    debugPrint("========== 🚀 START DEMO ADMIN DATA VALIDATION ==========");
    Either<Failure, dynamic> result;

    try {
      // ✅ Check if Demo structure already exists
      debugPrint("🔍 Checking if Demo/${companyModel.requestId} structure exists...");

      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection(getBaseUrl('Employees_Info'))
          .doc('1')
          .get();

      if (employeeDoc.exists) {
        debugPrint("✅ Demo structure already exists - created by admin app");
        debugPrint("✅ Employee ID: 1");
        debugPrint("✅ Email: ${companyModel.contactInformation.email.values.last}");

        // Return the existing employee
        NewEmployeeModelHistory employee = NewEmployeeModelHistory.fromMap(
            employeeDoc.data() as Map<String, dynamic>);

        result = Right(employee);
      } else {
        debugPrint("❌ ERROR: Demo structure does not exist!");
        debugPrint("❌ Admin app should have created this structure");
        debugPrint("❌ Path checked: Demo/${companyModel.requestId}/Employees_Info/1");

        result = Left(FirebaseFailure(
            "Demo structure not found. Please contact administrator."));
      }
    } catch (e, stackTrace) {
      debugPrint("❌ ERROR during validation: $e");
      debugPrint("❌ Stack trace: $stackTrace");

      result = Left(FirebaseFailure(
          "Failed to validate demo structure: ${e.toString()}"));
    }

    debugPrint("========== END DEMO ADMIN DATA VALIDATION ==========");
    return result;
  }
}