import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/constants/constant.dart';
import 'package:demo_app/core/helper/main_helper/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/circle_progress.dart';

import 'package:demo_app/features/home/home_page/presentation/ui/widgets/standard_container.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

class ServiceOverview extends StatefulWidget {
  final HomeComponentModel model;

  const ServiceOverview({required this.model, super.key});

  @override
  State<ServiceOverview> createState() => _ServiceOverviewState();
}

class _ServiceOverviewState extends State<ServiceOverview> {
  bool isLoading = true;
  int totalServices = 0;
  int totalRequests = 0;
  int totalSLA = 0;
  int totalDone = 0;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  Future<void> _loadServiceData() async {
    setState(() => isLoading = true);
    try {
      await Future.wait([
        _fetchTotalServices(),
        _fetchRequestStatistics(),
      ]);
    } catch (e) {
      print('Error loading service data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchTotalServices() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(getBaseUrl(FirestoreCollections.createServices))
          .get();
      if (mounted) setState(() => totalServices = snapshot.docs.length);
    } catch (e) {
      print('Error fetching total services: $e');
    }
  }

  Future<void> _fetchRequestStatistics() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final employeeController = Get.find<MainCoreEmployeeController>();
      final employeeEmail = employeeController.employeeEntity?.email;

      if (employeeEmail == null || employeeEmail.isEmpty) {
        if (mounted) setState(() { totalRequests = 0; totalSLA = 0; totalDone = 0; });
        return;
      }

      final fullCollectionPath = getBaseUrl(FirestoreCollections.requestServices);
      final pathSegments = fullCollectionPath.split('/');

      if (pathSegments.length != 3) {
        if (mounted) setState(() { totalRequests = 0; totalSLA = 0; totalDone = 0; });
        return;
      }

      final requestsCollection = firestore
          .collection(pathSegments[0])
          .doc(pathSegments[1])
          .collection(pathSegments[2]);

      final employeeEmailLower = employeeEmail.toLowerCase().trim();

      final snapshot = await requestsCollection
          .where('Email_Requester', arrayContains: employeeEmailLower)
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) setState(() { totalRequests = 0; totalSLA = 0; totalDone = 0; });
        return;
      }

      int requests = 0;
      int slaCount = 0;
      int doneCount = 0;

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          requests++;
          final finalState = _resolveFinalState(data);
          if (finalState == 'done') doneCount++;
          if (finalState == 'branchsla' || finalState == 'breached sla') slaCount++;
        } catch (e) {
          print('Error processing service document: $e');
        }
      }

      if (mounted) {
        setState(() {
          totalRequests = requests;
          totalSLA = slaCount;
          totalDone = doneCount;
        });
      }
    } catch (e) {
      print('Error fetching request statistics: $e');
      if (mounted) setState(() { totalRequests = 0; totalSLA = 0; totalDone = 0; });
    }
  }

  String _resolveFinalState(Map<String, dynamic> data) {
    String finalState = 'pending';
    if (data['state'] is List) {
      final stateList = data['state'] as List;
      if (stateList.isNotEmpty) {
        finalState = stateList.last?.toString().toLowerCase().trim() ?? 'pending';
      }
    } else if (data['state'] is String) {
      finalState = (data['state'] as String).toLowerCase().trim();
    }
    return finalState;
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;

    return SizedBox(
        width: isMobile ? 210 : 315.w,  // ,
      // height: isMobile ? 115.h : 130.h,
      child: StandardContainer(
        child: isLoading
            ? Center(
          child: SizedBox(width: 24, height: 24, child: CircleProgressMaster()),
        )
            : Column(
          spacing: isMobile ? 12.h : 6.h,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service'.tr,
                  style: isMobile
                      ? StyleText.fontSize12Weight500.copyWith(
                      color: lightMode ? AppColors.blackButton : AppColors.white)
                      : AppTextStyles.font14BlackCairoMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                SvgPicture.asset(
                  'assets/icons_assets/home_assets/service.svg',
                  width: isMobile ? 12.w : 20.w,
                  height: isMobile ? 12.h : 20.h,
                  fit: BoxFit.fill,
                  color: AppColors.primary,
                ),
              ],
            ),

            SizedBox(height: 6.h),
            // ✅ FIX: Row with Expanded items, no spacing property
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStaticItem(
                  title: 'Services'.tr,
                  number: totalServices,
                  icon: 'assets/icons_assets/home_assets/service_total_services.svg',
                ),
                SizedBox(width: 4.w),
                _buildStaticItem(
                  title: S.of(context).requests,
                  number: totalRequests,
                  icon: 'assets/icons_assets/home_assets/service_total_requests.svg',
                ),
                SizedBox(width: 4.w),
                _buildStaticItem(
                  title: 'SLA'.tr,
                  number: totalSLA,
                  icon: 'assets/icons_assets/home_assets/service_total_sla.svg',
                ),
                SizedBox(width: 4.w),
                _buildStaticItem(
                  title: 'Done'.tr,
                  number: totalDone,
                  icon: 'assets/icons_assets/home_assets/service_total_done.svg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticItem({
    required String title,
    required int number,
    required String icon,
  }) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;

    // ✅ FIX: Expanded takes equal share of available space — no fixed width
    return Expanded(
      child: Container(
        width: 45,
        padding: EdgeInsets.all(5.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: isMobile ? 3.h : 6.h,
          children: [
            SvgPicture.asset(
              icon,
              width: isMobile ? 12.w : 20.w,
              height: isMobile ? 12.h : 20.h,
              fit: BoxFit.fill,
            ),
            const SizedBox.shrink(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                title,
                style: isMobile
                    ? StyleText.fontSize10Weight500.copyWith(
                    color: lightMode ? AppColors.blackButton : AppColors.white)
                    : AppTextStyles.font14BlackCairoRegular,
                maxLines: 1,
              ),
            ),
            const SizedBox.shrink(),
            Text(
              number.toString(),
              style: isMobile
                  ? StyleText.fontSize12Weight500.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white)
                  : AppTextStyles.font14BlackSemiBoldCairo,
            ),
          ],
        ),
      ),
    );
  }
}