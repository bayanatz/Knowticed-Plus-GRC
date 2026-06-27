import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/circle_progress.dart';
import 'package:demo_app/core/custom/circle_progress.dart';

import 'package:demo_app/features/home/widgets/standard_container.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/home/helper/knowledge_hub_module/knowledge_dashboard_stub.dart';
// REMOVED_MODULE: import '../../../../../knowledge_hub_module/knowledge_hub/presentation/cubit/dashboard_cubit/dashboard_states.dart';
import '../../../../data/models/home_component_model.dart';

class KnowledgeHubOverview extends StatelessWidget {
  final HomeComponentModel model;

  const KnowledgeHubOverview({required this.model, super.key});

  /// ✅ Filter status counts by current user's email
  Map<String, int> _filterStatusCountsByUser(
      Map<String, int> allStatusCounts,
      DashboardCubit cubit,
      String userEmail,
      ) {
    Map<String, int> userCounts = {
      'published': 0,
      'approved': 0,
      'pending_approval': 0,
      'rejected': 0,
    };

    // Get all documents
    final allDocuments = cubit.getAllDocuments();

    for (var doc in allDocuments) {
      // ✅ Only count documents created by this user
      if (doc.currentCreatedByEmail.toLowerCase().trim() != userEmail.toLowerCase().trim()) {
        continue;
      }

      // Skip if no status history
      if (doc.status.isEmpty) continue;

      // Get the LAST status (current status)
      String currentStatus = doc.status.last.toLowerCase();

      // Count based on the exact last status
      if (currentStatus == 'published') {
        userCounts['published'] = (userCounts['published'] ?? 0) + 1;
      } else if (currentStatus == 'approved') {
        userCounts['approved'] = (userCounts['approved'] ?? 0) + 1;
      } else if (currentStatus == 'pending_approval') {
        userCounts['pending_approval'] = (userCounts['pending_approval'] ?? 0) + 1;
      } else if (currentStatus == 'rejected') {
        userCounts['rejected'] = (userCounts['rejected'] ?? 0) + 1;
      }
    }

    return userCounts;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get current logged-in user's email
    final employeeController = Get.find<MainCoreEmployeeController>();
    final String? currentUserEmail = employeeController.employeeEntity?.email;

    if (currentUserEmail == null) {
      return SizedBox(
        width: 400.sp,
        child: StandardContainer(
          child: Center(
            child: Text(
              'User not logged in',
              style: AppTextStyles.font14BlackCairoRegular,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 400.sp,
      child: StandardContainer(
        child: BlocProvider(
          create: (_) => DashboardCubit()..loadDashboard(),
          child: BlocBuilder<DashboardCubit, DashboardStates>(
          builder: (context, state) {
            // Default values
            int totalPublished = 0;
            int totalApproved = 0;
            int totalPending = 0;
            int totalRejected = 0;

            // ✅ Extract and filter data from loaded state
            if (state is DashboardLoaded) {
              // Get the cubit instance to access document list
              final cubit = context.read<DashboardCubit>();

              // Filter counts by current user
              final userCounts = _filterStatusCountsByUser(
                state.statusCounts,
                cubit,
                currentUserEmail,
              );

              totalPublished = userCounts['published'] ?? 0;
              totalApproved = userCounts['approved'] ?? 0;
              totalPending = userCounts['pending_approval'] ?? 0;
              totalRejected = userCounts['rejected'] ?? 0;
            }

            return Column(
              spacing: 15.sp,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).knowledge_hub,  // ✅ Changed to "My Knowledge Hub"
                      style: AppTextStyles.font16BlackCairoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SvgPicture.asset(
                      'assets/skeleton/home/icons/knowledge_hub.svg',
                      width: 20,
                      height: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),

                // Show loading indicator
                if (state is DashboardLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.sp),
                    child: const Center(
                      child: CircleProgressMaster(),
                    ),
                  )
                // Show error message
                else if (state is DashboardError)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.sp),
                    child: Center(
                      child: Text(
                        'Error loading data'.tr,
                        style: AppTextStyles.font14BlackCairoRegular
                            .copyWith(color: Colors.red),
                      ),
                    ),
                  )
                // Show empty state
                else if (state is DashboardEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.sp),
                      child: Center(
                        child: Text(
                          'No data available'.tr,
                          style: AppTextStyles.font14BlackCairoRegular,
                        ),
                      ),
                    )
                  // Show data
                  else
                    Row(
                      spacing: 5.sp,
                      children: [
                        _staticItem(
                          title: S.of(context).published,
                          number: totalPublished,
                          icon: 'assets/skeleton/home/icons/inventory.svg',
                        ),
                        _staticItem(
                          title: S.of(context).approved,
                          number: totalApproved,
                          icon: 'assets/skeleton/home/icons/approved_services.svg',
                        ),
                        _staticItem(
                          title: S.of(context).pending,
                          number: totalPending,
                          icon: 'assets/skeleton/home/icons/knowledge_hub_pending.svg',
                        ),
                        _staticItem(
                          title: S.of(context).rejected,
                          number: totalRejected,
                          icon: 'assets/skeleton/home/icons/knowledge_hub_rejected.svg',
                        ),
                      ],
                    ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }

  Widget _staticItem({
    required String title,
    required int number,
    required String icon,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(5.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6.sp,
          children: [
            SvgPicture.asset(icon),
            FittedBox(
              child: Text(
                title,
                style: AppTextStyles.font14BlackCairoRegular,
              ),
            ),
            const SizedBox.shrink(),
            Text(
              number.toString(),
              style: AppTextStyles.font14BlackSemiBoldCairo,
            ),
          ],
        ),
      ),
    );
  }
}