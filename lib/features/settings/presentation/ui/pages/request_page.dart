import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/side_frame_master.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/circle_progress.dart';
// navigate helpers (inlined from removed inventory_module)
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s2_details_service/details_service/widget/info_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:demo_app/core/helper/main_helper/cross_axis_count_helper.dart';
import '../../../../../generated/l10n.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import '../../../../employee/presentation/controller/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/core/new_theme.dart';
import '../../../../employee/data/models/emplyees_model/new_employee_model.dart';
import 'details_request.dart';

void navigateTo(context, widget) => Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

bool isTabletLandscape(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;
  return size.width >= 600 && isLandscape;
}

class MyRequestPage extends StatefulWidget {
  const MyRequestPage({super.key});

  @override
  State<MyRequestPage> createState() => _MyRequestPageState();
}

class _MyRequestPageState extends State<MyRequestPage> {
  String selectStatus = "All";

  int totalRequests = 0;
  int pendingCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;

  List<Map<String, dynamic>> allRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];

  TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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

  // ✅ NEW: Translation helper for request titles
  String _translateTitle(String englishTitle) {
    // Check current locale
    bool isArabic = Get.locale?.languageCode == 'ar';

    if (!isArabic) {
      return englishTitle; // Return English if not Arabic
    }

    // Translate to Arabic
    switch (englishTitle) {
      case 'Emergency Contact':
        return 'جهة الاتصال في حالات الطوارئ';
      case 'Health Insurance':
        return 'التأمين الصحي';
      default:
        return englishTitle; // Return original if no translation found
    }
  }

  Future<void> _fetchRequestsFromFirebase() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get employee ID from MainCoreEmployeeController
      final MainCoreEmployeeController employeeController = Get.find<MainCoreEmployeeController>();
      final String? employeeId = employeeController.employeeEntity?.id;

      if (employeeId == null || employeeId.isEmpty) {
        throw Exception('Employee ID not found');
      }

      print('📥 Fetching requests for employee: $employeeId');

      // ✅ FIXED: Fetch from the correct path
      final String rolesDocPath = '${getBaseUrl('Modules')}/roles';

      print('📍 Fetching from path: $rolesDocPath/Employees_Request');

      final querySnapshot = await FirebaseFirestore.instance
          .doc(rolesDocPath)
          .collection('Employees_Request')
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('requestDate', descending: true)
          .get();

      print('📊 Found ${querySnapshot.docs.length} requests');

      // Parse requests
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
          'employeeEmail': data['employeeEmail'] ?? '', // ✅ Add this
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

      print('✅ Requests loaded successfully');
      print('🔍 Filtered ${allRequests.length} requests');
    } catch (e) {
      print('❌ Error fetching requests: $e');
      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        'Error'.tr,
        'Failed to load requests: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _updateCounts() {
    totalRequests = allRequests.length;
    pendingCount = allRequests.where((r) => r['status'] == 'pending').length;
    approvedCount = allRequests.where((r) => r['status'] == 'approved').length;
    rejectedCount = allRequests.where((r) => r['status'] == 'rejected').length;
  }

  void _filterRequests() {
    List<Map<String, dynamic>> filtered = List.from(allRequests);

    // Filter by status
    if (selectStatus != "All") {
      filtered = filtered.where((request) {
        if (selectStatus == S.of(context).Approved) {
          return request['status'] == 'approved';
        } else if (selectStatus == 'Pending') {
          return request['status'] == 'pending';
        } else if (selectStatus == 'Rejected') {
          return request['status'] == 'rejected';
        }
        return true;
      }).toList();
    }

    // Filter by search text (search in title)
    if (searchController.text.isNotEmpty) {
      final searchText = searchController.text.toLowerCase();
      filtered = filtered.where((request) {
        final title = request['title'].toString().toLowerCase();
        final translatedTitle = _translateTitle(request['title']).toLowerCase();
        return title.contains(searchText) || translatedTitle.contains(searchText);
      }).toList();
    }

    setState(() {
      filteredRequests = filtered;
    });

    print('🔍 Filtered ${filteredRequests.length} requests');
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.lightGreen;
      case 'pending':
        return AppColors.yellow;
      case 'rejected':
        return Colors.red[500]!;
      default:
        return AppColors.secondaryText;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return S.of(context).Approved;
      case 'pending':
        return S.of(context).pending;
      case 'rejected':
        return S.of(context).rejected;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return !isMobile ?
    SizedBox(
      height: 550.h,
      child: SingleChildScrollView(
        child: Column(
          children: [

            // filter
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                filterSection(),
              ],
            ),
            //space
            SizedBox(height: 20.h),
            // search and sort
            Row(
              children: [
                AppSearchTextField(
                  controller: searchController,
                  onChanged: (val) {
                    // Search is handled by listener
                  },
                ),
                SizedBox(width: 15.w),
                Container(
                  width: isMobile ? 38.w : 100.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: lightMode
                          ? AppColors.white
                          : AppColors.chatBackground),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isMobile
                          ? Center(
                          child: CustomSvg(
                            assetPath: "assets/images/Sort_services.svg",
                            width: 20.w,
                            height: 20.h,
                            fit: BoxFit.scaleDown,
                            color: lightMode
                                ? AppColors.secondaryText
                                : AppColors.grey ,
                          ))
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: CustomSvg(
                              assetPath: "assets/images/Sort_services.svg",
                              width: 20.w,
                              height: 20.h,
                              fit: BoxFit.scaleDown,
                              color: lightMode
                                  ? AppColors.secondaryText
                                  : AppColors.grey ,

                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            S.of(context).sort,
                            style: StyleText.fontSize16Weight500.copyWith(
                                color: lightMode
                                    ? AppColors.secondaryText
                                    : AppColors.grey),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),


            SizedBox(height: 20.h),

            // Show message if no requests found
            filteredRequests.isEmpty
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(height: 150.h),
                Lottie.asset(
                    "assets/lottie/empty.json",
                    width: 250.w,
                    height: 250.h,
                    repeat: true
                ),
              ],
            )
                : SizedBox(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : !isTabletLandscape(context) ? 2 : 2,
                  mainAxisSpacing: 10.sp,
                  crossAxisSpacing: 10.sp,
                  mainAxisExtent: 145.sp,
                ),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = filteredRequests[index];
                  final status = request['status'] ?? 'pending';
                  final statusColor = _getStatusColor(status);

                  return GestureDetector(
                      onTap: () {
                        navigateTo(
                          context,
                          DetailsRequestSettings(
                            requestId: request['id'], // ✅ Add requestId
                            requestData: {
                              'employeeId': request['employeeId'],
                              'employeeEmail': request['employeeEmail'], // ✅ Add
                              'status': request['status'],
                              'requestDate': request['dateRequested'], // ✅ Fix field name
                              'requestNote': request['requestNote'],
                              'section': request['section'], // ✅ Add
                              'whatChanged': request['whatChanged'], // ✅ Add
                              'oldValue': request['oldValue'], // ✅ Add
                              'newValue': request['newValue'], // ✅ Add
                            },
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: lightMode
                                ? AppColors.white
                                : AppColors.chatBackground),
                        child: Padding(
                          padding: EdgeInsets.all(15.sp),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      width: 50.w,
                                      height: 50.h,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4.r),
                                          color: lightMode
                                              ? AppColors.background
                                              : AppColors.background),
                                      child: Center(
                                        child: CustomSvg(
                                          assetPath: "assets/employee_request.svg",
                                          width: 28.w,
                                          height: 28.h,
                                          fit: BoxFit.scaleDown,
                                          color: lightMode
                                              ? AppColors.blackButton
                                              : AppColors.white,
                                        ),
                                      )),
                                  SizedBox(width: 5.w),
                                  Expanded(
                                    child: Text(
                                      // ✅ FIXED: Translate title based on locale
                                      _translateTitle(request['title'] ?? 'Request'),
                                      style: StyleText.fontSize14Weight500.copyWith(
                                          color: lightMode
                                              ? AppColors.blackButton
                                              : AppColors.white),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  )
                                ],
                              ),

                              // space
                              SizedBox(height: 12.h),
                              // Date Requested
                              Row(
                                children: [
                                  CustomSvg(
                                    assetPath: "assets/calender.svg",
                                    width: 14.w,
                                    height: 14.h,
                                    fit: BoxFit.scaleDown,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "${S.of(context).dateRequested}: ",
                                    style: StyleText.fontSize12Weight400.copyWith(
                                        color: lightMode
                                            ? AppColors.secondaryText
                                            : AppColors.grey),
                                  ),
                                  Text(
                                    _formatDate(request['dateRequested']),
                                    style: StyleText.fontSize12Weight400.copyWith(
                                        color: lightMode
                                            ? AppColors.blackButton
                                            : AppColors.white),
                                  ),
                                ],
                              ),
                              // space
                              SizedBox(height: 12.h),
                              // Status
                              Row(
                                children: [
                                  CustomSvg(
                                    assetPath: "assets/status.svg",
                                    width: 12.w,
                                    height: 12.h,
                                    fit: BoxFit.fill,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "${S.of(context).status}: ",
                                    style: StyleText.fontSize12Weight400.copyWith(
                                        color: lightMode
                                            ? AppColors.secondaryText
                                            : AppColors.grey),
                                  ),
                                  Text(
                                    _getStatusLabel(status),
                                    style: StyleText.fontSize12Weight400.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    )

        : SideFrameMaster(
      titleText: S.of(context).settings,
      secondTitle: S.of(context).requests ,
      onFirstTap: (){
        Navigator.pop(context);
      },
      onSecondTap: (){
        Navigator.pop(context);
      },
      child: Column(
        children: [

          // filter
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              filterSection(),
            ],
          ),
          //space
          SizedBox(height: 20.h),
          // search and sort
          Row(
            children: [
              AppSearchTextField(
                controller: searchController,
                onChanged: (val) {
                  // Search is handled by listener
                },
              ),
              SizedBox(width: 15.w),
              Container(
                width: isMobile ? 38.w : 100.w,
                height: 38.h,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.card
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isMobile
                        ? Center(
                        child: CustomSvg(
                          assetPath: "assets/images/Sort_services.svg",
                          width: 20.w,
                          height: 20.h,
                          fit: BoxFit.scaleDown,
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey ,
                        ))
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: CustomSvg(
                            assetPath: "assets/images/Sort_services.svg",
                            width: 20.w,
                            height: 20.h,
                            fit: BoxFit.scaleDown,
                            color: lightMode
                                ? AppColors.secondaryText
                                : AppColors.grey ,

                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          S.of(context).sort,
                          style: StyleText.fontSize16Weight500.copyWith(
                              color: lightMode
                                  ? AppColors.secondaryText
                                  : AppColors.grey),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),

          SizedBox(height: 20.h),

          // Show message if no requests found
          filteredRequests.isEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(height: 150.h),
              Lottie.asset(
                  "assets/lottie/empty.json",
                  width: 250.w,
                  height: 250.h,
                  repeat: true
              ),
            ],
          )
              : SizedBox(

            child: GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : !isTabletLandscape(context) ? 2 : 2,
                mainAxisSpacing: 15.sp,
                crossAxisSpacing: 15.sp,
                mainAxisExtent: 139.sp,
              ),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                final status = request['status'] ?? 'pending';
                final statusColor = _getStatusColor(status);

                return GestureDetector(
                    onTap: () {
                      print('🔍 Navigating with data:');
                      print('   - id: ${request['id']}');
                      print('   - status: "${request['status']}"'); // ✅ Check status here
                      print('   - section: ${request['section']}');
                      print('   - whatChanged: ${request['whatChanged']}');

                      navigateTo(
                        context,
                        DetailsRequestSettings(
                          requestId: request['id'],
                          requestData: {
                            'employeeId': request['employeeId'],
                            'employeeEmail': request['employeeEmail'],
                            'status': request['status'], // ✅ Make sure this is passed
                            'requestDate': request['dateRequested'],
                            'requestNote': request['requestNote'],
                            'section': request['section'],
                            'whatChanged': request['whatChanged'],
                            'oldValue': request['oldValue'],
                            'newValue': request['newValue'],
                          },
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColors.card
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    width: 50.w,
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4.r),
                                        color: AppColors.background,
                                    ),
                                    child: Center(
                                      child: CustomSvg(
                                        assetPath: "assets/employee_request.svg",
                                        width: 28.w,
                                        height: 28.h,
                                        fit: BoxFit.scaleDown,
                                        color: AppColors.text
                                      ),
                                    )),
                                SizedBox(width: 5.w),
                                Expanded(
                                  child: Text(
                                    // ✅ FIXED: Translate title based on locale
                                    _translateTitle(request['title'] ?? 'Request'),
                                    style: StyleText.fontSize14Weight500.copyWith(
                                        color: AppColors.text),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                )
                              ],
                            ),

                            // space
                            SizedBox(height: 12.h),
                            // Date Requested
                            Row(
                              children: [
                                CustomSvg(
                                  assetPath: "assets/calender.svg",
                                  width: 14.w,
                                  height: 14.h,
                                  fit: BoxFit.scaleDown,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "${S.of(context).dateRequested}: ",
                                  style: StyleText.fontSize12Weight400.copyWith(
                                      color: AppColors.secondaryText),
                                ),
                                Text(
                                  _formatDate(request['dateRequested']),
                                  style: StyleText.fontSize12Weight400.copyWith(
                                      color: AppColors.text),
                                ),
                              ],
                            ),
                            // space
                            SizedBox(height: 12.h),
                            // Status
                            Row(
                              children: [
                                CustomSvg(
                                  assetPath: "assets/status.svg",
                                  width: 12.w,
                                  height: 12.h,
                                  fit: BoxFit.fill,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "${S.of(context).status}: ",
                                  style: StyleText.fontSize12Weight400.copyWith(
                                      color: AppColors.secondaryText),
                                ),
                                Text(
                                  _getStatusLabel(status),
                                  style: StyleText.fontSize12Weight400.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filterSection() {
    final s = S.of(context);

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _statusChip("$totalRequests", s.all,
                isSelected: selectStatus == s.all,
                onTap: () {
                  setState(() {
                    selectStatus = s.all;
                    _filterRequests();
                  });
                },
                labelColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.secondaryText
                    : AppColors.grey),
            _statusChip("$approvedCount", s.Approved,
                isSelected: selectStatus == s.Approved,
                onTap: () {
                  setState(() {
                    selectStatus = s.Approved;
                    _filterRequests();
                  });
                },
                labelColor: AppColors.lightGreen),
            _statusChip("$pendingCount", s.pending,
                isSelected: selectStatus == s.pending,
                onTap: () {
                  setState(() {
                    selectStatus = s.pending;
                    _filterRequests();
                  });
                },
                labelColor: AppColors.yellow),
            _statusChip("$rejectedCount", s.rejected,
                isSelected: selectStatus == s.rejected,
                onTap: () {
                  setState(() {
                    selectStatus = s.rejected;
                    _filterRequests();
                  });
                },
                labelColor: Colors.red[500]!),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String count, String label,
      {required bool isSelected, required Color labelColor, required VoidCallback onTap})
  {
    var light = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color:
                   isSelected
                  ? AppColors.primary
                  : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight400.copyWith(
                  color: light
                      ? isSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText
                      : isSelected
                      ? AppColors.textButton
                      : AppColors.grey,
                )
                    : StyleText.fontSize20Weight500.copyWith(
                  color: light
                      ? isSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText
                      : isSelected
                      ? AppColors.textButton
                      : AppColors.grey,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          SizedBox(
            child: Text(
              label,
              style: isMobile
                  ? StyleText.fontSize14Weight600.copyWith(color: labelColor)
                  : StyleText.fontSize16Weight600.copyWith(color: labelColor),
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}