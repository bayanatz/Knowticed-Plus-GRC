import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/constants/constant.dart';
import 'package:demo_app/core/helper/main_helper/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/standard_container.dart';

import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

class MyRequestServices extends StatefulWidget {
  MyRequestServices({required this.model, super.key});
  HomeComponentModel model;

  @override
  State<MyRequestServices> createState() => _MyRequestServicesState();
}

class _MyRequestServicesState extends State<MyRequestServices> {
  Map<String, int> statusCounts = {
    'approved': 0,
    'pending': 0,
    'rejected': 0,
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServiceStatusData();
  }

  /// Fetches and calculates service states using correct logic from MyServices
  Future<Map<String, int>> calculateServiceStates() async {
    try {
      print("┌─────────────────────────────────────┐");
      print("│  MY REQUEST SERVICES - FETCH        │");
      print("└─────────────────────────────────────┘");

      final firestore = FirebaseFirestore.instance;
      final employeeController = Get.find<MainCoreEmployeeController>();
      final employeeEmail = employeeController.employeeEntity?.email;

      print("👤 Employee Email: $employeeEmail");

      if (employeeEmail == null || employeeEmail.isEmpty) {
        print("❌ ERROR: Employee email is null or empty");
        return {'approved': 0, 'pending': 0, 'rejected': 0};
      }

      final fullCollectionPath = getBaseUrl(FirestoreCollections.requestServices);
      final pathSegments = fullCollectionPath.split('/');

      print("📂 Collection Path: $fullCollectionPath");

      if (pathSegments.length != 3) {
        print("❌ ERROR: Invalid path segments: ${pathSegments.length}");
        return {'approved': 0, 'pending': 0, 'rejected': 0};
      }

      final requestsCollection = firestore
          .collection(pathSegments[0])
          .doc(pathSegments[1])
          .collection(pathSegments[2]);

      print("⏳ Executing query...");
      final snapshot = await requestsCollection.get();

      print("✅ Query completed: ${snapshot.docs.length} total documents\n");

      if (snapshot.docs.isEmpty) {
        print("⚠️  No documents found");
        return {'approved': 0, 'pending': 0, 'rejected': 0};
      }

      int approvedCount = 0;
      int pendingCount = 0;
      int rejectedCount = 0;
      int userRequestsCount = 0;

      final employeeEmailLower = employeeEmail.toLowerCase().trim();
      print("🔍 Filtering for: '$employeeEmailLower'\n");

      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        print("─────────────────────────────────────");
        print("📄 [${i + 1}/${snapshot.docs.length}] ${doc.id}");

        try {
          final data = doc.data() as Map<String, dynamic>;

          // Get email from Email_Requester array
          String? requestEmail;
          if (data['Email_Requester'] is List && (data['Email_Requester'] as List).isNotEmpty) {
            requestEmail = (data['Email_Requester'] as List)[0]?.toString().toLowerCase().trim() ?? '';
            print("   📧 Email_Requester: '$requestEmail'");
          }

          if (requestEmail == null || requestEmail.isEmpty) {
            print("   ⚠️  No Email_Requester found");
            print("   ❌ Not user's request\n");
            continue;
          }

          // Check if belongs to user
          final belongsToUser = requestEmail == employeeEmailLower;

          if (!belongsToUser) {
            print("   ❌ Not user's request (email doesn't match)\n");
            continue;
          }

          userRequestsCount++;
          print("   ✅ USER'S REQUEST");

          // Get state - check both array and string types
          String finalState = 'pending'; // default

          print("   🔍 Checking state field...");
          print("   State type: ${data['state'].runtimeType}");
          print("   State value: ${data['state']}");

          if (data['state'] is List) {
            final stateList = data['state'] as List;
            print("   📊 State is List with ${stateList.length} elements");
            print("   📊 Full state array: $stateList");

            if (stateList.isNotEmpty) {
              // Get the LAST state in the array
              final lastState = stateList.last;
              print("   📊 Last element: $lastState (${lastState.runtimeType})");

              finalState = lastState?.toString().toLowerCase().trim() ?? 'pending';
              print("   📊 Final state from last element: '$finalState'");
            }
          } else if (data['state'] is String) {
            finalState = (data['state'] as String).toLowerCase().trim();
            print("   📊 State is String: '$finalState'");
          } else {
            print("   ⚠️  State is unexpected type: ${data['state'].runtimeType}");
          }

          print("   🎯 FINAL STATE TO COUNT: '$finalState'");

          // Count based on final state
          switch (finalState) {
            case 'approved':
              approvedCount++;
              print("   ✅✅✅ COUNTED AS APPROVED (total now: $approvedCount)");
              break;
            case 'pending':
              pendingCount++;
              print("   ⏳⏳⏳ COUNTED AS PENDING (total now: $pendingCount)");
              break;
            case 'rejected':
              rejectedCount++;
              print("   ❌❌❌ COUNTED AS REJECTED (total now: $rejectedCount)");
              break;
            default:
              print("   ℹ️  NOT COUNTED - State '$finalState' doesn't match approved/pending/rejected");
          }
          print("");
        } catch (e, stackTrace) {
          print("   ⚠️  ERROR processing document: $e");
          print("   Stack: $stackTrace\n");
        }
      }

      print("═════════════════════════════════════");
      print("📊 FINAL RESULTS:");
      print("   Total documents checked: ${snapshot.docs.length}");
      print("   User's requests found: $userRequestsCount");
      print("   ✅ Approved: $approvedCount");
      print("   ⏳ Pending: $pendingCount");
      print("   ❌ Rejected: $rejectedCount");
      print("═════════════════════════════════════\n");

      return {
        'approved': approvedCount,
        'pending': pendingCount,
        'rejected': rejectedCount,
      };
    } catch (e, stackTrace) {
      print("═════════════════════════════════════");
      print("❌ FATAL ERROR");
      print("   Error: $e");
      print("   Stack: $stackTrace");
      print("═════════════════════════════════════\n");
      return {'approved': 0, 'pending': 0, 'rejected': 0};
    }
  }

  Future<void> loadServiceStatusData() async {
    final counts = await calculateServiceStates();
    if (mounted) {
      setState(() {
        statusCounts = counts;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    // Calculate total
    int total = statusCounts.values.fold(0, (sum, count) => sum + count);

    return SizedBox(
        width: 130.sp,
        height: isMobile ? 115.sp : 130.sp,
        child: StandardContainer(
            child: isLoading
                ? Center(
              child: SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
                : Column(
              spacing: 4.sp,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).myRequests,
                      style: AppTextStyles.font14BlackCairoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SvgPicture.asset(
                      'assets/icons_assets/home_assets/service.svg',
                      width: 20,
                      height: 20,
                      color: AppColors.primary,
                    )
                  ],
                ),
                // Text(
                //   'Total'.tr + ' $total',
                //   style: AppTextStyles.font14BlackSemiBoldCairo
                //       .copyWith(color: AppColors.secondaryText),
                // ),
                SizedBox(height: 2.sp),
                Column(
                  spacing: 7.sp,
                  children: [
                    item(
                        color: AppColors.green,
                        number: '${statusCounts['approved'] ?? 0}',
                        icon: 'assets/icons_assets/home_assets/approved_services.svg',
                        onTap: () {
                          // Navigate to approved services
                          // Get.toNamed('/approved-services');
                        }),
                    item(
                        color: AppColors.yellow,
                        number: '${statusCounts['pending'] ?? 0}',
                        icon: 'assets/skeleton/home/icons/pending.svg',
                        onTap: () {
                          // Navigate to pending services
                          // Get.toNamed('/pending-services');
                        }),
                    item(
                        color: AppColors.red,
                        number: '${statusCounts['rejected'] ?? 0}',
                        icon: 'assets/icons_assets/home_assets/my_section_rejected.svg',
                        onTap: () {
                          // Navigate to rejected services
                          // Get.toNamed('/rejected-services');
                        }),
                  ],
                )
              ],
            )));
  }

  Widget item({
    required Color color,
    required String number,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        spacing: 4.sp,
        children: [
          SvgPicture.asset(
            icon,
            width: 15,
            height: 15,
            color: color,
          ),
          Text(
            number,
            style: AppTextStyles.font12BlackCairoRegular
                .copyWith(fontWeight: FontWeight.bold, color: color),
          )
        ],
      ),
    );
  }
}