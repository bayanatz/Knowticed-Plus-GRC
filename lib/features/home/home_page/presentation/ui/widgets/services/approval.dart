import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/constants/constant.dart';
import 'package:demo_app/core/helper/main_helper/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/standard_container.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

class MyServices extends StatefulWidget {
  MyServices({required this.model, super.key});

  final HomeComponentModel model;

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {

  @override
  Widget build(BuildContext context) {

    var isMobile = context.isPhone;
    return SizedBox(
      height: isMobile ? 115.h : 130.h,
      width: isMobile ? 260.sp : 315.sp,
      child: StandardContainer(
        child: FutureBuilder<Map<String, int>>(
          future: _fetchMyServicesCounts(),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            // Error state
            if (snapshot.hasError) {
              return _buildErrorState();
            }

            // Success state
            final counts = snapshot.data ?? {'approved': 0, 'pending': 0, 'rejected': 0};

            return Column(
              spacing: isMobile ?  11.sp : 15.sp,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).approvals,
                      style: isMobile ? StyleText.fontSize12Weight500.copyWith(
                        color:
                            AppColors.text
                      ) : AppTextStyles.font14BlackCairoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SvgPicture.asset(
                      'assets/icons_assets/home_assets/service.svg',
                      width: isMobile ? 13.w  : 20.w,
                      height: isMobile ? 13.h  : 20.h,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: isMobile ?  MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStaticItem(
                      title: S.of(context).approved,
                      number: counts['approved'] ?? 0,
                      icon: 'assets/icons_assets/home_assets/approved_services.svg',
                    ),
                    isMobile ? SizedBox(width: 40.sp): SizedBox(),
                    _buildStaticItem(
                      title: S.of(context).pending,
                      number: counts['pending'] ?? 0,
                      icon: 'assets/icons_assets/home_assets/pending_services.svg',
                    ),
                    isMobile ? SizedBox(width: 40.sp): SizedBox(),

                    _buildStaticItem(
                      title: S.of(context).rejected,
                      number: counts['rejected'] ?? 0,
                      icon: 'assets/icons_assets/home_assets/rejected_services.svg',
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Fetch service counts from Firebase
  Future<Map<String, int>> _fetchMyServicesCounts() async {
    final stopwatch = Stopwatch()..start();

    try {
      print("┌─────────────────────────────────────┐");
      print("│  FETCHING MY SERVICES COUNTS        │");
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

      final employeeEmailLower = employeeEmail.toLowerCase().trim();

      // ✅ CRITICAL FIX: Query Firestore to filter by current user's email
      print("🔍 Querying for user: '$employeeEmailLower'");
      print("⏳ Executing filtered query...");

      final snapshot = await requestsCollection
          .where('Email_Requester', arrayContains: employeeEmailLower)
          .get();

      print("✅ Query completed: ${snapshot.docs.length} documents for this user\n");

      if (snapshot.docs.isEmpty) {
        print("⚠️  No documents found for this user");
        return {'approved': 0, 'pending': 0, 'rejected': 0};
      }

      int approvedCount = 0;
      int pendingCount = 0;
      int rejectedCount = 0;

      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        print("─────────────────────────────────────");
        print("📄 [${i + 1}/${snapshot.docs.length}] ${doc.id}");

        try {
          final data = doc.data() as Map<String, dynamic>;

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

      stopwatch.stop();

      print("═════════════════════════════════════");
      print("📊 FINAL RESULTS:");
      print("   User's requests found: ${snapshot.docs.length}");
      print("   ✅ Approved: $approvedCount");
      print("   ⏳ Pending: $pendingCount");
      print("   ❌ Rejected: $rejectedCount");
      print("   ⏱️  Time: ${stopwatch.elapsedMilliseconds}ms");
      print("═════════════════════════════════════\n");

      return {
        'approved': approvedCount,
        'pending': pendingCount,
        'rejected': rejectedCount,
      };
    } catch (e, stackTrace) {
      stopwatch.stop();
      print("═════════════════════════════════════");
      print("❌ FATAL ERROR");
      print("   Error: $e");
      print("   Stack: $stackTrace");
      print("   Time: ${stopwatch.elapsedMilliseconds}ms");
      print("═════════════════════════════════════\n");
      return {'approved': 0, 'pending': 0, 'rejected': 0};
    }
  }

  // Resolve final state from service data (same logic as AdminDashboard)
  String _resolveFinalState(Map<String, dynamic> data) {
    final stateField = (data['state']?.toString().toLowerCase().trim()) ?? '';

    // FIRST: Check for final statuses in outer state (these override approval cycle)
    if (['done', 'inprogress', 'cancel', 'canceled', 'branchsla', 'breached sla']
        .contains(stateField)) {
      return stateField == 'canceled' ? 'cancel' : stateField;
    }

    // SECOND: Check approval cycle for approval process states
    if (data['approvalCycle'] is Map<String, dynamic>) {
      final approvalMap = data['approvalCycle'] as Map<String, dynamic>;
      final valueList = approvalMap['value'];
      if (valueList is List) {
        final states = valueList
            .map((e) => (e['state']?.toString().toLowerCase().trim() ?? ''))
            .where((s) => s.isNotEmpty)
            .toList();

        // Check for rejection/cancellation in approval cycle
        if (states.contains('cancel') || states.contains('canceled')) {
          return 'cancel';
        }
        if (states.contains('rejected')) {
          return 'rejected';
        }

        // Check if all approved
        if (states.isNotEmpty && states.every((s) => s == 'approved')) {
          return 'approved';
        }

        // Check for pending in approval cycle
        if (states.contains('pending')) {
          return 'pending';
        }
      }
    }

    // THIRD: Check outer state for approved/pending/rejected
    if (stateField.isNotEmpty &&
        ['approved', 'pending', 'rejected'].contains(stateField)) {
      return stateField;
    }

    // DEFAULT
    return 'pending';
  }

  // Build loading state
  Widget _buildLoadingState() {
    return Column(
      spacing: 15.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Services'.tr,
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SvgPicture.asset(
              'assets/icons_assets/home_assets/service.svg',
              width: 20,
              height: 20,
              color: AppColors.primary,
            ),
          ],
        ),
        Center(
          child: SizedBox(
            width: 20.sp,
            height: 20.sp,
            child: CircleProgressMaster(),
          ),
        ),
      ],
    );
  }

  // Build error state
  Widget _buildErrorState() {
    return Column(
      spacing: 15.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Services'.tr,
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SvgPicture.asset(
              'assets/icons_assets/home_assets/service.svg',
              width: 20,
              height: 20,
              color: AppColors.primary,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStaticItem(
              title: 'Approved',
              number: 0,
              icon: 'assets/icons_assets/home_assets/approved_services.svg',
            ),
            _buildStaticItem(
              title: 'Pending',
              number: 0,
              icon: 'assets/icons_assets/home_assets/pending_services.svg',
            ),
            _buildStaticItem(
              title: 'Rejected',
              number: 0,
              icon: 'assets/icons_assets/home_assets/rejected_services.svg',
            ),
          ],
        ),
      ],
    );
  }

  // Build static item widget
  Widget _buildStaticItem({
    required String title,
    required int number,
    required String icon,
  }) {
    var isMobile = context.isPhone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: isMobile ? 10.sp : 12.sp,
      children: [
        SvgPicture.asset(icon , width: isMobile ? 12.w : 20.w, height: isMobile ? 12.h : 20.h, fit: BoxFit.scaleDown,),
        Text(
          title,
          style: isMobile ?AppTextStyles.font12BlackCairoRegular :   AppTextStyles.font14BlackCairoRegular,
        ),
        Text(
          number.toString(),
          style: isMobile ?AppTextStyles.font12BlackCairoRegular : AppTextStyles.font14BlackSemiBoldCairo,
        ),
      ],
    );
  }
}