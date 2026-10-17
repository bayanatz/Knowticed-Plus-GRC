/// Module: roles / r2_user_management / presentation / ui / pages
///
/// ******************* FILE INFO *******************
/// File Name: upload_file_details.dart
/// Description: upload and edit data which come from bulk upload
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Created by: Amr Mesbah
library;

import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_controller.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:grc_module/core/custom/inputs/custom_check_box.dart';


import 'package:grc_module/core/custom/helpers/custom_svg.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/custom/navigation/custom_side_frame_master.dart';

import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

// REMOVED: company_contact_info not available
import 'package:grc_module/generated/l10n.dart';
// REMOVED: employee_personal_info not available
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/sheard.dart';

import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/core/theme/app_colors.dart' show AppColors;
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/custom/buttons/custom_button_with_svg.dart';
// ADDED 9/10/2026 — user-limit pre-check in `uploadToFirebase`.
import 'package:grc_module/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:grc_module/features/roles/r2_user_management/domain/services/module_user_limit_rule.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
part '../widgets/upload_methods1.dart';
part '../widgets/upload_methods2.dart';
part '../widgets/upload_customexceltextfield.dart';
part '../widgets/upload_build_page.dart';
part '../widgets/upload_build_b.dart';
part '../widgets/upload_build_c.dart';

class UploadFileDetailsTabletRoles extends StatefulWidget {
  const UploadFileDetailsTabletRoles({
    super.key,
    required this.formData,
    required this.validationErrors,
    this.selectedFileName,
  });

  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final String? selectedFileName;

  @override
  State<UploadFileDetailsTabletRoles> createState() =>
      _UploadFileDetailsTabletRolesState();
}

class _UploadFileDetailsTabletRolesState
    extends State<UploadFileDetailsTabletRoles> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  List<Map<String, GlobalKey>> fieldKeys = [];

  final _formKey = GlobalKey<FormState>();
  List<Map<String, TextEditingController>> formData = [];
  List<Map<String, TextEditingController>> filteredData = [];
  List<Map<String, String>> validationErrors = [];
  Set<int> selectedRows = {};
  String primaryKey = 'Employee ID';
  String searchQuery = '';
  final List<String> expectedHeaders = [
    'Employee ID',
    'Current Role Type',
    'Desired Role Type',
    'Access Granted',
    'Access Revoked',
    'Status',
  ];

  @override
  void initState() {
    super.initState();

    formData = widget.formData;
    validationErrors = widget.validationErrors;
    filteredData = List.from(widget.formData);

    focusNodes = List.generate(formData.length, (i) {
      final map = <String, FocusNode>{};
      for (final key in formData[i].keys) {
        map[key] = FocusNode();
      }
      return map;
    });

    fieldKeys = List.generate(formData.length, (i) {
      final map = <String, GlobalKey>{};
      for (final key in formData[i].keys) {
        map[key] = GlobalKey();
      }
      return map;
    });

    // Initialize error locations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateErrorLocations();
    });
  }

  int currentPage = 0;

  String? selectedFileName;

  final ScrollController _scrollController = ScrollController();

  final Map<String, String> columnToFirestoreField = {
    'Employee ID': 'employeeId',
    'Current Role Type': 'currentRoleType',
    'Desired Role Type': 'Role',
    'Access Granted': 'From_Date',
    'Access Revoked': 'To_Date',
    'Status': 'status',
  };

  //////////////////////////////////////////////////////////////////////////////////

  List<Map<String, FocusNode>> focusNodes = [];
  List<MapEntry<int, String>> errorLocations = [];
  int currentErrorIndex = -1; // Start with -1 to indicate no selection

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }
}
