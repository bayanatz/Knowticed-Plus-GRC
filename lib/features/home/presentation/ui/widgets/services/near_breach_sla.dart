import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/constants/constant.dart';
import 'package:demo_app/core/helper/main_helper/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/features/home/widgets/standard_container.dart';

import 'package:demo_app/features/home/core_widgets/main_widget/custom_icon_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import '../../../../../employee/presentation/controller/main_core_employee_controller.dart';
import '../../../../data/models/home_component_model.dart';

class NearBreachedSLA extends StatefulWidget {
  NearBreachedSLA({required this.model, super.key});
  final HomeComponentModel model;

  @override
  State<NearBreachedSLA> createState() => _NearBreachedSLAState();
}

class _NearBreachedSLAState extends State<NearBreachedSLA> {
  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;

    return SizedBox(
      width: isMobile ? 300.sp : 320.sp,
      height: 155.sp,
      child: StandardContainer(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchNearBreachedSLA(),
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
            // Success state
            final data = snapshot.data ?? {'percentage': 0, 'services': []};
            final percentage = (data['percentage'] as int?) ?? 0;
            final services = List<Map<String, dynamic>>.from(
                ((data['services'] ?? []) as List).map((e) => Map<String, dynamic>.from(e))
            );
            return Column(
              spacing: 9.sp,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Near Breached SLA'.tr,
                      style: AppTextStyles.font14BlackCairoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$percentage%',
                      style: AppTextStyles.font14BlackCairoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 1.sp),
                // Show last 2 services or empty state
                if (services.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No near breached SLA services'.tr,
                        style: AppTextStyles.font12SecondaryBlackCairoRegular,
                      ),
                    ),
                  )
                else
                  ...services.map((service) => _buildServiceItem(service)).toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Fetch last 2 services near breached SLA for the logged-in user
  Future<Map<String, dynamic>> _fetchNearBreachedSLA() async {
    try {
      print("┌─────────────────────────────────────┐");
      print("│  NEAR BREACHED SLA - FETCH          │");
      print("└─────────────────────────────────────┘");

      final firestore = FirebaseFirestore.instance;
      final employeeController = Get.find<MainCoreEmployeeController>();
      final employeeEmail = employeeController.employeeEntity?.email;

      print("👤 Employee Email: $employeeEmail");

      if (employeeEmail == null || employeeEmail.isEmpty) {
        print("❌ ERROR: Employee email is null or empty");
        return {'percentage': 0, 'services': []};
      }

      final fullCollectionPath = getBaseUrl(FirestoreCollections.requestServices);
      final pathSegments = fullCollectionPath.split('/');

      print("📂 Collection Path: $fullCollectionPath");

      if (pathSegments.length != 3) {
        print("❌ ERROR: Invalid path segments: ${pathSegments.length}");
        return {'percentage': 0, 'services': []};
      }

      final requestsCollection = firestore
          .collection(pathSegments[0])
          .doc(pathSegments[1])
          .collection(pathSegments[2]);

      final employeeEmailLower = employeeEmail.toLowerCase().trim();

      // ✅ Query Firestore to filter by current user's email
      print("🔍 Querying for user: '$employeeEmailLower'");
      print("⏳ Executing filtered query...");

      final snapshot = await requestsCollection
          .where('emailRequester', arrayContains: employeeEmailLower)
          .get();

      print("✅ Query completed: ${snapshot.docs.length} documents for this user\n");

      if (snapshot.docs.isEmpty) {
        print("⚠️  No documents found for this user");
        return {'percentage': 0, 'services': []};
      }

      // Filter for near breached SLA services
      List<Map<String, dynamic>> nearBreachedServices = [];
      int totalUserServices = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;

          // Get final state
          String finalState = _resolveFinalState(data);

          // Check if service is near breached SLA
          // You can customize this logic based on your SLA tracking fields
          // For now, we'll check if there's a field indicating near breach
          if (_isNearBreachedSLA(data, finalState)) {
            nearBreachedServices.add({
              'id': doc.id,
              'serviceName': _getServiceName(data),
              'department': _getDepartmentName(data),
              'data': data,
            });
          }
        } catch (e) {
          print("   ⚠️  ERROR processing document: $e");
        }
      }

      // Sort by timestamp or SLA time (most urgent first) and get last 2
      nearBreachedServices.sort((a, b) {
        // You can customize sorting based on your timestamp field
        final aTime = (a['data']['timestamps'] as List?)?.last ?? '';
        final bTime = (b['data']['timestamps'] as List?)?.last ?? '';
        return bTime.compareTo(aTime);
      });

      // Get only the last 2 services
      final lastTwoServices = nearBreachedServices.take(2).toList();

      // Calculate percentage
      int percentage = totalUserServices > 0
          ? ((nearBreachedServices.length / totalUserServices) * 100).round()
          : 0;

      print("═════════════════════════════════════");
      print("📊 NEAR BREACHED SLA RESULTS:");
      print("   Total user services: $totalUserServices");
      print("   Near breached services: ${nearBreachedServices.length}");
      print("   Showing last 2: ${lastTwoServices.length}");
      print("   Percentage: $percentage%");
      print("═════════════════════════════════════\n");

      return {
        'percentage': percentage,
        'services': lastTwoServices,
      };
    } catch (e, stackTrace) {
      print("═════════════════════════════════════");
      print("❌ FATAL ERROR");
      print("   Error: $e");
      print("   Stack: $stackTrace");
      print("═════════════════════════════════════\n");
      return {'percentage': 0, 'services': []};
    }
  }

  /// Resolve final state from service data
  String _resolveFinalState(Map<String, dynamic> data) {
    String finalState = 'pending';

    if (data['state'] is List) {
      final stateList = data['state'] as List;
      if (stateList.isNotEmpty) {
        final lastState = stateList.last;
        finalState = lastState?.toString().toLowerCase().trim() ?? 'pending';
      }
    } else if (data['state'] is String) {
      finalState = (data['state'] as String).toLowerCase().trim();
    }

    return finalState;
  }

  /// Check if service is near breached SLA
  /// Customize this based on your SLA tracking logic
  bool _isNearBreachedSLA(Map<String, dynamic> data, String state) {
    // Option 1: Check if there's a specific field for near breach
    if (data.containsKey('nearBreachSLA') && data['nearBreachSLA'] == true) {
      return true;
    }

    // Option 2: Check if SLA percentage is above certain threshold
    if (data.containsKey('slaPercentage')) {
      final slaPercentage = data['slaPercentage'];
      if (slaPercentage is num && slaPercentage >= 80 && slaPercentage < 100) {
        return true;
      }
    }

    // Option 3: Check if state indicates near breach
    if (state == 'nearbreachsla' || state == 'near breached sla') {
      return true;
    }

    // Add more conditions based on your data structure
    return false;
  }

  /// Get service name from data
  String _getServiceName(Map<String, dynamic> data) {
    if (data['serviceTitle'] is List && (data['serviceTitle'] as List).isNotEmpty) {
      return (data['serviceTitle'] as List).last?.toString() ?? 'Unknown Service';
    } else if (data['serviceTitle'] is String) {
      return data['serviceTitle'] as String;
    } else if (data['serviceName'] is String) {
      return data['serviceName'] as String;
    }
    return 'Unknown Service';
  }

  /// Get department name from data
  String _getDepartmentName(Map<String, dynamic> data) {
    if (data['department'] is List && (data['department'] as List).isNotEmpty) {
      return (data['department'] as List).last?.toString() ?? 'Unknown Department';
    } else if (data['department'] is String) {
      return data['department'] as String;
    } else if (data['departmentName'] is String) {
      return data['departmentName'] as String;
    }
    return 'Unknown Department';
  }

  /// Build service item widget
  Widget _buildServiceItem(Map<String, dynamic> service) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.sp),
            decoration: BoxDecoration(
              color: AppColors.secondaryButton,
              borderRadius: BorderRadius.circular(4.sp),
            ),
            child: SvgPicture.asset(
              'assets/skeleton/home/icons/service.svg',
              color: AppColors.text,
              width: 20.w,
              height: 20.h,
            ),
          ),
          SizedBox(width: 5.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 4.sp,
              children: [
                Text(
                  service['serviceName'] ?? 'Unknown Service',
                  style: AppTextStyles.font12BlackCairoRegular
                      .copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  service['department'] ?? 'Unknown Department',
                  style: AppTextStyles.font10SecondaryBlackCairoRegular,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 5.sp),
          CustomIconButton(
            height: 30.sp,
            textStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textButton,
            ),
            iconPath: 'assets/skeleton/home/icons/service_message.svg',
            buttonText: '',
            onTap: () {
              // Handle tap - navigate to service details
              print("Tapped service: ${service['id']}");
            },
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Column(
      spacing: 9.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Near Breached SLA'.tr,
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '...',
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 20.sp,
              height: 20.sp,
              child: CircleProgressMaster()
            ),
          ),
        ),
      ],
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Column(
      spacing: 9.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Near Breached SLA'.tr,
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '0%',
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
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
}