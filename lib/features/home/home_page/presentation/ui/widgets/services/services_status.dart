import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/constants/constant.dart';
import 'package:demo_app/core/helper/main_helper/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/standard_container.dart';
import 'package:percentages_with_animation/percentages_with_animation.dart';

import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

class ServicesStatus extends StatefulWidget {
  ServicesStatus({required this.model, super.key});

  final HomeComponentModel model;

  @override
  State<ServicesStatus> createState() => _ServicesStatusState();
}

class _ServicesStatusState extends State<ServicesStatus> {
  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;
    return SizedBox(
      width: isMobile ? 295.w : 315.w,
      height: isMobile ? 115.h : 130.h,
      child: StandardContainer(
        child: FutureBuilder<Map<String, int>>(
          future: _fetchServicesStatusCounts(),
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
            final counts = snapshot.data ?? {
              'branchsla': 0,
              'cancel': 0,
              'rejected': 0,
              'inprogress': 0,
              'approved': 0,
              'done': 0,
            };

            final totalServices = counts.values.fold<int>(0, (sum, count) => sum + count);

            return Column(
              spacing: 7.sp,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).serviceStatus,
                      style: isMobile
                          ? StyleText.fontSize12Weight500.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white)
                          : AppTextStyles.font14BlackCairoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SvgPicture.asset(
                      'assets/icons_assets/home_assets/service.svg',
                      width: isMobile ? 12.w : 20.w,
                      height: isMobile ? 12.h : 20.h,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                Container(
                  height: isMobile ? 65.sp : 80.sp,
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      spacing: 7.h,
                      children: [
                        _buildProgressIndicator(
                          color: Color(0xFF960000),
                          title: 'Breached SLA'.tr,
                          count: counts['branchsla'] ?? 0,
                          totalServices: totalServices,
                        ),
                        _buildProgressIndicator(
                          color: Color(0xFFDF0000),
                          title: 'Canceled'.tr,
                          count: counts['cancel'] ?? 0,
                          totalServices: totalServices,
                        ),
                        _buildProgressIndicator(
                          color: Color(0xFFDF1C1C),
                          title: 'Rejected'.tr,
                          count: counts['rejected'] ?? 0,
                          totalServices: totalServices,
                        ),
                        _buildProgressIndicator(
                          color: Color(0xFFE5B800),
                          title: 'In Progress'.tr,
                          count: counts['inprogress'] ?? 0,
                          totalServices: totalServices,
                        ),
                        _buildProgressIndicator(
                          color: Color(0xFF4BB609),
                          title: 'Approved'.tr,
                          count: counts['approved'] ?? 0,
                          totalServices: totalServices,
                        ),
                        _buildProgressIndicator(
                          color: Color(0xFF3B890A),
                          title: 'Done'.tr,
                          count: counts['done'] ?? 0,
                          totalServices: totalServices,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  /// Fetch service status counts for the logged-in user from Firebase
  Future<Map<String, int>> _fetchServicesStatusCounts() async {
    final stopwatch = Stopwatch()..start();

    try {
      print("┌─────────────────────────────────────┐");
      print("│  SERVICES STATUS - FETCH            │");
      print("└─────────────────────────────────────┘");

      final firestore = FirebaseFirestore.instance;
      final employeeController = Get.find<MainCoreEmployeeController>();
      final employeeEmail = employeeController.employeeEntity?.email;

      print("👤 Employee Email: $employeeEmail");

      if (employeeEmail == null || employeeEmail.isEmpty) {
        print("❌ ERROR: Employee email is null or empty");
        return {
          'branchsla': 0,
          'cancel': 0,
          'rejected': 0,
          'inprogress': 0,
          'approved': 0,
          'done': 0,
        };
      }

      final fullCollectionPath = getBaseUrl(FirestoreCollections.requestServices);
      final pathSegments = fullCollectionPath.split('/');

      print("📂 Collection Path: $fullCollectionPath");

      if (pathSegments.length != 3) {
        print("❌ ERROR: Invalid path segments: ${pathSegments.length}");
        return {
          'branchsla': 0,
          'cancel': 0,
          'rejected': 0,
          'inprogress': 0,
          'approved': 0,
          'done': 0,
        };
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
        return {
          'branchsla': 0,
          'cancel': 0,
          'rejected': 0,
          'inprogress': 0,
          'approved': 0,
          'done': 0,
        };
      }

      int branchSlaCount = 0;
      int cancelCount = 0;
      int rejectedCount = 0;
      int inProgressCount = 0;
      int approvedCount = 0;
      int doneCount = 0;

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
            case 'branchsla':
            case 'breached sla':
              branchSlaCount++;
              print("   🔴 COUNTED AS BREACHED SLA (total now: $branchSlaCount)");
              break;
            case 'cancel':
            case 'canceled':
              cancelCount++;
              print("   🚫 COUNTED AS CANCELED (total now: $cancelCount)");
              break;
            case 'rejected':
              rejectedCount++;
              print("   ❌ COUNTED AS REJECTED (total now: $rejectedCount)");
              break;
            case 'inprogress':
              inProgressCount++;
              print("   🔄 COUNTED AS IN PROGRESS (total now: $inProgressCount)");
              break;
            case 'approved':
              approvedCount++;
              print("   ✅ COUNTED AS APPROVED (total now: $approvedCount)");
              break;
            case 'done':
              doneCount++;
              print("   ✔️ COUNTED AS DONE (total now: $doneCount)");
              break;
            case 'pending':
              print("   ⏳ PENDING - Not shown in ServicesStatus widget");
              break;
            default:
              print("   ℹ️  State '$finalState' not tracked in ServicesStatus");
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
      print("   🔴 Breached SLA: $branchSlaCount");
      print("   🚫 Canceled: $cancelCount");
      print("   ❌ Rejected: $rejectedCount");
      print("   🔄 In Progress: $inProgressCount");
      print("   ✅ Approved: $approvedCount");
      print("   ✔️  Done: $doneCount");
      print("   ⏱️  Time: ${stopwatch.elapsedMilliseconds}ms");
      print("═════════════════════════════════════\n");

      return {
        'branchsla': branchSlaCount,
        'cancel': cancelCount,
        'rejected': rejectedCount,
        'inprogress': inProgressCount,
        'approved': approvedCount,
        'done': doneCount,
      };
    } catch (e, stackTrace) {
      stopwatch.stop();
      print("═════════════════════════════════════");
      print("❌ FATAL ERROR");
      print("   Error: $e");
      print("   Stack: $stackTrace");
      print("   Time: ${stopwatch.elapsedMilliseconds}ms");
      print("═════════════════════════════════════\n");
      return {
        'branchsla': 0,
        'cancel': 0,
        'rejected': 0,
        'inprogress': 0,
        'approved': 0,
        'done': 0,
      };
    }
  }

  // Build loading state
  Widget _buildLoadingState() {
    return Column(
      spacing: 7.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services Status'.tr,
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
        Expanded(
          child: Center(
            child: SizedBox(
              width: 20.sp,
              height: 20.sp,
              child: CircleProgressMaster(),
            ),
          ),
        ),
      ],
    );
  }

  // Build error state
  Widget _buildErrorState() {
    return Column(
      spacing: 7.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services Status'.tr,
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
        Expanded(
          child: Center(
            child: Text(
              'Error loading data'.tr,
              style: AppTextStyles.font12SecondaryBlackCairoRegular,
            ),
          ),
        ),
      ],
    );
  }

  // Build progress indicator with real data
  Widget _buildProgressIndicator({
    required Color color,
    required String title,
    required int count,
    required int totalServices,
  }) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;
    // Calculate percentage (avoid division by zero)
    final percentage = totalServices > 0 ? ((count / totalServices) * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5.sp,
      children: [
        Row(
          children: [
            Text(
                title,
                style: isMobile
                    ? StyleText.fontSize10Weight500.copyWith(
                    color: lightMode
                        ? AppColors.secondaryText
                        : AppColors.white)
                    : AppTextStyles.font12SecondaryBlackCairoRegular),
            Spacer(),
            Text(
              count.toString(),
              style: isMobile
                  ? StyleText.fontSize10Weight500.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.white)
                  : AppTextStyles.font12BlackCairoBold,
            ),
          ],
        ),
        LinearPercentage(
          leftTextRightPadding: 0,
          rightTextRightPadding: 0,
          currentPercentage: percentage.toDouble(),
          maxPercentage: 100,
          backgroundHeight: 10.sp,
          percentageHeight: 10.sp,
          leftRightText: LeftRightText.none,
          showPercentageOnPercentageView: false,
          percentageOnPercentageViewTextStyle: const TextStyle(color: Colors.white),
          backgroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.secondaryButton,
          ),
          percentageDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
          ),
          onCurrentValue: (currentValue) {},
        ),
      ],
    );
  }
}