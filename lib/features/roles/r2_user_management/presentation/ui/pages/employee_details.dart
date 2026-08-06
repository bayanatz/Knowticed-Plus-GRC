import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';

import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/custom/circle_progress.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import 'package:grc_module/features/services_management_module/s6_services_requests/presentation/ui/widgets/custom_button_with_image.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/pages/showEditUserAccessDialog.dart';
import 'dart:ui' as ui;

import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/roles/r2_user_management/domain/entity/user_permission_entity.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/user_mangment_permission.dart';
import 'package:grc_module/core/helper/role/constants.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/features/roles/r5_system_logs/role_log_service.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/widgets/asscess_grand_widget.dart';

import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
part '../widgets/employee_details_methods1.dart';
part '../widgets/employee_details_methods2.dart';
part '../widgets/employee_details_methods3.dart';
part '../widgets/employee_details_methods4.dart';

class RoleEmployeeDetailsPage extends StatefulWidget {
  final UserPermissionEntity userPermission;

  const RoleEmployeeDetailsPage({super.key, required this.userPermission});

  @override
  State<RoleEmployeeDetailsPage> createState() =>
      _RoleEmployeeDetailsPageState();
}

class _RoleEmployeeDetailsPageState extends State<RoleEmployeeDetailsPage> {
  final MainCoreEmployeeController employeeController =
  Get.find<MainCoreEmployeeController>();

  EmployeeEntityPro? currentEmployeeEntity;

  bool _permissionsLoaded = false;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, List<String>> _modulePermissions = {};
  List<String> activeModuleStrings = [];

  // ── Shared month lists ────────────────────────────────────────────────────
  static const _enMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  // ── Master date formatter ─────────────────────────────────────────────────
  /// Always returns Western numerals: "24 Aug 2023" / "24 أغسطس 2023"
  String _formatDate(String? rawDate, bool isArabic) {
    if (rawDate == null || rawDate.isEmpty || rawDate == '-') return '-';

    DateTime? parsed;
    try {
      // 1. ISO with T  e.g. "2023-08-24T10:30:00"
      if (rawDate.contains('T')) {
        parsed = DateTime.parse(rawDate);
      }
      // 2. Space-separated timestamp  e.g. "2026-01-09 16:20:58.514133"
      else if (rawDate.contains('-') && rawDate.contains(' ')) {
        parsed = DateTime.parse(rawDate.replaceFirst(' ', 'T'));
      }
      // 3. Pure date  e.g. "2023-08-24"
      else if (rawDate.contains('-') && !rawDate.contains(' ')) {
        parsed = DateTime.parse(rawDate);
      }
      // 4. dd/MM/yyyy
      else if (rawDate.contains('/')) {
        final parts = rawDate.split('/');
        if (parts.length == 3) {
          parsed = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      // 5. Already a readable string — try common EN formats
      else if (rawDate.contains(' ') || rawDate.contains(',')) {
        final formats = [
          'dd MMM yyyy',
          'MMM dd, yyyy',
          'dd MMMM yyyy',
          'MMMM dd, yyyy',
          'MMM dd yyyy',
          'dd MMM yyyy, hh:mm a',
        ];
        for (final fmt in formats) {
          try {
            parsed = DateFormat(fmt, 'en').parse(rawDate);
            break;
          } catch (_) {}
        }
      }
    } catch (_) {}

    if (parsed == null) return rawDate; // give up — return as-is

    // Build string manually → always Western numerals
    final day   = parsed.day.toString().padLeft(2, '0');
    final month = isArabic
        ? _arMonths[parsed.month - 1]
        : _enMonths[parsed.month - 1];
    final year  = parsed.year.toString();
    return '$day $month $year';
  }

  @override
  void initState() {
    super.initState();
    RoleLogService.log(RoleLogService.pageEmployeeDetails);
    _loadEmployeeData();
    _initializePage();
  }












  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).platformControlsAndManagement,
          onFirstTap: () => Navigator.pop(context),
          secondTitle: S.of(context).employeeDetails,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 200.h,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleProgressMaster(),
                  SizedBox(height: 16.sp),
                  Text(
                    S.of(context).loadingEmployeeDetails,
                    style: StyleText.fontSize16Weight400
                        .copyWith(color: AppColors.text),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).platformControlsAndManagement,
          onFirstTap: () => Navigator.pop(context),
          secondTitle: S.of(context).employeeDetails,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 16.sp),
                Text(S.of(context).errorLoadingData,
                    style: StyleText.fontSize16Weight400),
                SizedBox(height: 8.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.sp),
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.font12BlackCairoRegular,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16.sp),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _initializePage();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: Text(S.of(context).retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _buildContent();
  }













}
