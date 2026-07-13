import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/constants/constant.dart';
import 'package:demo_app/core/helper/main_helper/helper_function.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/standard_container.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

import 'package:demo_app/generated/l10n.dart';

import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';

/// Helper function to safely get the first element from an array field
String getFirstArrayElement(dynamic field, {String defaultValue = ''}) {
  if (field is List && field.isNotEmpty) {
    final firstElement = field.first;
    return firstElement?.toString().trim() ?? defaultValue;
  } else if (field is String) {
    return field.trim();
  }
  return defaultValue;
}

// Model for service request data
class ServiceRequestModel {
  final String id;
  final String serviceName;
  final String department;
  final String category;
  final Timestamp? createdAt;

  ServiceRequestModel({
    required this.id,
    required this.serviceName,
    required this.department,
    required this.category,
    this.createdAt,
  });

  factory ServiceRequestModel.fromFirestore(Map<String, dynamic> data, String docId) {
    // Get service name from serviceNameEnglish array (first element)
    final serviceName = getFirstArrayElement(
      data['serviceNameEnglish'],
      defaultValue: 'Unknown Service',
    );

    // Get department from departmentRequester array (first element)
    final department = getFirstArrayElement(
      data['departmentRequester'],
      defaultValue: 'Unknown Department',
    );

    // Category might not exist in array format, try different fields
    final category = getFirstArrayElement(
      data['categoryTitle'],
      defaultValue: 'Service',
    );

    return ServiceRequestModel(
      id: docId,
      serviceName: serviceName,
      department: department,
      category: category,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}

class RequestService extends StatefulWidget {
  RequestService({required this.model, super.key});
  HomeComponentModel model;

  @override
  State<RequestService> createState() => _RequestServiceState();
}

class _RequestServiceState extends State<RequestService> {
  List<ServiceRequestModel> recentRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentRequests();
  }

  /// Fetches the last 2 service requests for the current user
  Future<void> _fetchRecentRequests() async {
    try {
      print("┌─────────────────────────────────────┐");
      print("│  REQUEST SERVICE - FETCH RECENT     │");
      print("└─────────────────────────────────────┘");

      final firestore = FirebaseFirestore.instance;
      final employeeController = Get.find<MainCoreEmployeeController>();
      final employeeEmail = employeeController.employeeEntity?.email;

      print("👤 Employee Email: $employeeEmail");

      if (employeeEmail == null || employeeEmail.isEmpty) {
        print("❌ ERROR: Employee email is null or empty");
        if (mounted) {
          setState(() {
            recentRequests = [];
            isLoading = false;
          });
        }
        return;
      }

      final fullCollectionPath = getBaseUrl(FirestoreCollections.requestServices);
      final pathSegments = fullCollectionPath.split('/');

      print("📂 Collection Path: $fullCollectionPath");

      if (pathSegments.length != 3) {
        print("❌ ERROR: Invalid path segments: ${pathSegments.length}");
        if (mounted) {
          setState(() {
            recentRequests = [];
            isLoading = false;
          });
        }
        return;
      }

      final requestsCollection = firestore
          .collection(pathSegments[0])
          .doc(pathSegments[1])
          .collection(pathSegments[2]);

      print("⏳ Executing query...");

      // Get all documents (don't use orderBy to avoid index requirement)
      final snapshot = await requestsCollection.get();

      print("✅ Query completed: ${snapshot.docs.length} total documents\n");

      if (snapshot.docs.isEmpty) {
        print("⚠️  No documents found");
        if (mounted) {
          setState(() {
            recentRequests = [];
            isLoading = false;
          });
        }
        return;
      }

      List<ServiceRequestModel> userRequests = [];
      final employeeEmailLower = employeeEmail.toLowerCase().trim();
      print("🔍 Filtering for: '$employeeEmailLower'\n");

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;

          // Get email from emailRequester array (first element)
          final requestEmail = getFirstArrayElement(
            data['emailRequester'],
          ).toLowerCase();

          if (requestEmail.isEmpty) {
            print("   ⚠️  No emailRequester in ${doc.id}");
            continue;
          }

          // Check if belongs to user
          final belongsToUser = requestEmail == employeeEmailLower;

          if (!belongsToUser) {
            continue;
          }

          // Get service name for logging
          final serviceName = getFirstArrayElement(
            data['serviceNameEnglish'],
            defaultValue: 'Unknown',
          );

          // Add to user requests
          userRequests.add(ServiceRequestModel.fromFirestore(data, doc.id));
          print("   ✅ Added request: ${doc.id} - $serviceName");
        } catch (e) {
          print("   ⚠️  ERROR processing document ${doc.id}: $e");
        }
      }

      // Sort by timestamps array (last element is most recent timestamp)
      userRequests.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      // Take only the 2 most recent
      final recentTwo = userRequests.take(2).toList();

      print("\n═════════════════════════════════════");
      print("📊 FINAL RESULTS:");
      print("   Total documents checked: ${snapshot.docs.length}");
      print("   User's total requests: ${userRequests.length}");
      print("   Showing recent: ${recentTwo.length}");
      if (recentTwo.isNotEmpty) {
        print("   Recent requests:");
        for (var req in recentTwo) {
          print("     - ${req.serviceName}");
        }
      }
      print("═════════════════════════════════════\n");

      if (mounted) {
        setState(() {
          recentRequests = recentTwo;
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print("═════════════════════════════════════");
      print("❌ FATAL ERROR");
      print("   Error: $e");
      print("   Stack: $stackTrace");
      print("═════════════════════════════════════\n");

      if (mounted) {
        setState(() {
          recentRequests = [];
          isLoading = false;
        });
      }
    }
  }

  /// Navigate to RequestServicesToggle with service details
  void _navigateToServiceDetails(ServiceRequestModel service) {
    print("🔗 Navigating to service details: ${service.id}");

    // TODO: Replace with your actual navigation route
    // Example navigation options:

    // Option 1: If using named routes
    // Get.toNamed(
    //   '/request-services-toggle',
    //   arguments: {
    //     'serviceId': service.id,
    //     'serviceName': service.serviceName,
    //     'department': service.department,
    //   },
    // );

    // Option 2: If using direct widget navigation
    // Get.to(() => RequestServicesToggle(
    //   serviceId: service.id,
    //   serviceName: service.serviceName,
    //   department: service.department,
    // ));

    // Option 3: If the page exists in your routes
    Get.toNamed(
      '/request-services-toggle',
      arguments: service.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;

    return SizedBox(
      width: isMobile ? 250.sp : 315.sp,
      height: isMobile ? 115.sp : 130.sp,
      child: StandardContainer(
        child: isLoading
            ? _buildLoadingState(isMobile, lightMode)
            : recentRequests.isEmpty
            ? _buildEmptyState(isMobile, lightMode)
            : Column(
          spacing: isMobile ? 11.sp : 15.sp,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).requestedService,
                  style: isMobile
                      ? StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text)
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
            // Display recent requests (max 2)
            ...recentRequests.map((service) => _buildServiceItem(
              service: service,
              isMobile: isMobile,
              lightMode: lightMode,
            )),
          ],
        ),
      ),
    );
  }

  /// Build individual service request item
  Widget _buildServiceItem({
    required ServiceRequestModel service,
    required bool isMobile,
    required bool lightMode,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(5.sp),
          decoration: BoxDecoration(
            color: AppColors.secondaryButton,
            borderRadius: BorderRadius.circular(4.sp),
          ),
          child: SvgPicture.asset(
            width: isMobile ? 12.w : 20.w,
            height: isMobile ? 12.h : 20.h,
            'assets/icons_assets/home_assets/service.svg',
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 5.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 2.sp,
            children: [
              Text(
                service.serviceName,
                style: isMobile
                    ? StyleText.fontSize10Weight500.copyWith(color: AppColors.text)
                    : AppTextStyles.font12BlackCairoRegular
                    .copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                service.department,
                style: isMobile
                    ? StyleText.fontSize8Weight400.copyWith(color: AppColors.text)
                    : AppTextStyles.font10SecondaryBlackCairoRegular,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 5.sp),
        customButton(
          width: 37.w,
          height: 25.h,
          radius: 4.r,
          color: AppColors.primary,
          textStyle: AppTextStyles.font10BlackCairoRegular.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textButton,
          ),
          title: S.of(context).view,
          function: () => _navigateToServiceDetails(service),
        ),
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState(bool isMobile, bool lightMode) {
    return Column(
      spacing: isMobile ? 11.sp : 15.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).requestedService,
              style: isMobile
                  ? StyleText.fontSize12Weight500.copyWith(color: AppColors.text)
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
        Expanded(
          child: Center(
            child: SizedBox(
              width: 20.sp,
              height: 20.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState(bool isMobile, bool lightMode) {
    return Column(
      spacing: isMobile ? 11.sp : 15.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).requestedService,
              style: isMobile
                  ? StyleText.fontSize12Weight500.copyWith(color: AppColors.text)
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
        Expanded(
          child: Center(
            child: Text(
              S.of(context).no_data_available ?? 'No recent requests',
              style: isMobile
                  ? StyleText.fontSize10Weight500
                  .copyWith(color: AppColors.secondaryText)
                  : AppTextStyles.font12SecondaryBlackCairoRegular,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}