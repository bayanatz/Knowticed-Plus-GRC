import 'package:grc_module/core/custom/37-custom_navigate.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s2_details_service/details_service/widget/info_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/pages/user_mangement_details_request.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/core/custom/cross_axis_count_helper.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/ui/pages/details_request.dart';
import 'package:grc_module/features/roles/r5_system_logs/role_log_service.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
part '../widgets/request_page_approval_methods1.dart';


class RequestPageApproval extends StatefulWidget {
  const RequestPageApproval({super.key});

  @override
  State<RequestPageApproval> createState() => _RequestPageApprovalState();
}

class _RequestPageApprovalState extends State<RequestPageApproval> {
  String selectStatus = "All";

  int totalRequests = 0;
  int pendingCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;

  List<Map<String, dynamic>> allRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];

  TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  // Track which cards are being actioned (to show loading per card)
  Set<String> _actioningIds = {};

  @override
  void initState() {
    super.initState();
    RoleLogService.log(RoleLogService.pageRequestApproval);
    _fetchRequestsFromFirebase();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterRequests();
  }

  Future<void> _fetchRequestsFromFirebase() async {
    setState(() {
      isLoading = true;
    });

    try {
      final MainCoreEmployeeController employeeController =
      Get.find<MainCoreEmployeeController>();
      final String? employeeId = employeeController.employeeEntity?.id;

      if (employeeId == null || employeeId.isEmpty) {
        throw Exception('Employee ID not found');
      }

      final String basePath = getBaseUrl('Modules');

      final querySnapshot = await FirebaseFirestore.instance
          .doc('$basePath/roles')
          .collection('Employees_Request')
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('requestDate', descending: true)
          .get();

      List<Map<String, dynamic>> requests = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        requests.add({
          'id': doc.id,
          'title': data['section'] ?? 'Personal Information',
          'dateRequested': data['requestDate']?.millisecondsSinceEpoch ?? 0,
          'status': data['status'] ?? 'pending',
          'requestNote': data['requestNote'] ?? '',
          'employeeId': data['employeeId'] ?? '',
          'employeeEmail': data['employeeEmail'] ?? '',
          'section': data['section'] ?? '',
          'whatChanged': data['whatChanged'] ?? '',
          'oldValue': data['oldValue'] ?? '',
          'newValue': data['newValue'] ?? '',
        });
      }

      setState(() {
        allRequests = requests;
        _updateCounts();
        _filterRequests();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        S.of(context).error,
        'Failed to load requests: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }








  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return isLoading
        ? Center(child: CircleProgress())
        : RefreshIndicator(
      onRefresh: _fetchRequestsFromFirebase,
      child: SideFrameMasterServices(
        titleText: "User Management",
        onFirstTap: () {
          Navigator.of(context).pop();
        },
        secondTitle: S.of(context).requests,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: filterSection()),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      height: 36.h,
                      labelStyle: StyleText.fontSize16Weight400.copyWith(
                        color:   AppColors.text
                      ),
                      hint: Localizations.localeOf(context).languageCode == 'ar' ? 'بحث' : 'Search',
                      contentPadding: EdgeInsets.symmetric(vertical: 5.h),
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Icons.search),
                      borderRadius: BorderRadius.circular(8),
                      fillColor: AppColors.card,
                      onChanged: (val) {
                        _onSearchChanged();
                      },
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Container(
                    width: isMobile ? 38.w : 100.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColors.card,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isMobile
                            ? Center(
                            child: CustomSvgImage(
                              assetPath:
                              "assets/icons_assets/main_icons_assets/sort_lines.svg",
                              width: 20.w,
                              height: 20.h,
                              fit: BoxFit.scaleDown,
                              color: AppColors.secondaryText,
                            ))
                            : Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Center(
                              child: CustomSvgImage(
                                assetPath:
                                "assets/icons_assets/main_icons_assets/sort_lines.svg",
                                width: 20.w,
                                height: 20.h,
                                fit: BoxFit.scaleDown,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              S.of(context).sort,
                              style: StyleText.fontSize16Weight500
                                  .copyWith(
                                  color: AppColors.secondaryText),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 20.h),
              filteredRequests.isEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 150.h),
                  Center(
                    child: Lottie.asset(
                      "assets/lottie_assets/notification_lottie_assets/empty.json",
                      width: 300.w,
                      height: 300.h,
                      repeat: true,
                    ),
                  ),
                ],
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: CrossAxisCountHelper
                      .getCrossAxisCountForDefaultTablet2(context),
                  mainAxisSpacing: 15.sp,
                  crossAxisSpacing: 15.sp,
                  // ── slightly taller card to fit action buttons ──
                  mainAxisExtent: 200.sp,
                ),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = filteredRequests[index];
                  final status = request['status'] ?? 'pending';
                  final statusColor = _getStatusColor(status);
                  final requestId = request['id'] as String;
                  final isPending = status == 'pending';
                  final isActioning =
                  _actioningIds.contains(requestId);

                  final employeeController =
                  Get.find<MainCoreEmployeeController>();
                  final employeeEmail =
                      request['employeeEmail'] ?? '';

                  final jobTitle = employeeEmail.isNotEmpty
                      ? employeeController
                      .getEmployeeJobTitle(employeeEmail)
                      : '-';
                  final department = employeeEmail.isNotEmpty
                      ? employeeController
                      .getEmployeeDepartmentName(employeeEmail)
                      : '-';

                  return GestureDetector(
                    onTap: () {
                      navigateTo(
                        context,
                        UserManagementDetailsRequestSettings(
                          requestId: requestId,
                          requestData: {
                            'employeeId': request['employeeId'],
                            'employeeEmail':
                            request['employeeEmail'],
                            'section': request['section'],
                            'whatChanged': request['whatChanged'],
                            'oldValue': request['oldValue'],
                            'newValue': request['newValue'],
                            'status': request['status'],
                            'requestDate': request['dateRequested'],
                            'requestNote': request['requestNote'],
                          },
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: AppColors.card,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ── Header row ──────────────────────
                            Row(
                              children: [
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(4.r),
                                    color: AppColors.background,
                                  ),
                                  child: Center(
                                    child: CustomSvgImage(
                                      assetPath: request["section"] ==
                                          "Personal Information"
                                          ? "assets/icons_assets/main_icons_assets/person_outline.svg"
                                          : "assets/icons_assets/main_icons_assets/health_insurance_card.svg",
                                      width: 30.w,
                                      height: 30.h,
                                      fit: BoxFit.fill,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Expanded(
                                  child: Text(
                                    request['title'] ?? 'Request',
                                    style: StyleText
                                        .fontSize14Weight500
                                        .copyWith(
                                        color: AppColors.text),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            // ── Date ────────────────────────────
                            _infoRow(
                              icon: "assets/icons_assets/roles_assets/calendar.svg",
                              label: "Request By: ",
                              value: _formatDate(
                                  request['dateRequested']),
                              lightMode: lightMode,
                            ),
                            SizedBox(height: 8.h),

                            // ── Job Title ───────────────────────
                            _infoRow(
                              icon: "assets/icons_assets/main_icons_assets/id_badge_card.svg",
                              label:
                              "${S.of(context).jobTitle}: ",
                              value: FormatHelper.capitalize(
                                  jobTitle),
                              lightMode: lightMode,
                              ellipsis: true,
                            ),
                            SizedBox(height: 8.h),

                            // ── Department ──────────────────────
                            _infoRow(
                              icon: "assets/icons_assets/roles_assets/department_hierarchy_people.svg",
                              label:
                              "${S.of(context).department}: ",
                              value: FormatHelper.capitalize(
                                  department),
                              lightMode: lightMode,
                              ellipsis: true,
                            ),
                            SizedBox(height: 8.h),

                            // ── Status ──────────────────────────
                            Row(
                              children: [
                                CustomSvgImage(
                                  assetPath: "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                                  width: 14.w,
                                  height: 14.h,
                                  fit: BoxFit.scaleDown,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "${S.of(context).status}: ",
                                  style: StyleText
                                      .fontSize12Weight400
                                      .copyWith(
                                      color: AppColors.text),
                                ),
                                Text(
                                  _getStatusLabel(status),
                                  style: StyleText
                                      .fontSize12Weight400
                                      .copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



}
