/// ******************* FILE INFO *******************
/// File Name: upload_file_details.dart
/// Description: upload and edit data which come from bulk upload
/// Created by: Amr Mesbah
import 'package:get/get.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_controller.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/custom/23-custom_check_box.dart';

import 'dart:convert';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
import 'package:grc_module/core/custom/37-custom_navigate.dart';

import 'package:grc_module/core/theme/app_theme.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/upload_file_details_toggle.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// REMOVED: company_contact_info not available
import 'package:grc_module/generated/l10n.dart';
// REMOVED: employee_personal_info not available
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/sheard.dart';

import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/core/theme/app_colors.dart' show AppColors;
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
part '../widgets/upload_methods1.dart';
part '../widgets/upload_methods2.dart';
part '../widgets/upload_customexceltextfield.dart';
part '../widgets/upload_build_page.dart';
part '../widgets/upload_build_b.dart';
part '../widgets/upload_build_c.dart';


class UploadFileDetailsTabletRoles extends StatefulWidget {
  const UploadFileDetailsTabletRoles({super.key, required this.formData, required this.validationErrors,this.selectedFileName});

  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final String? selectedFileName;

  @override
  State<UploadFileDetailsTabletRoles> createState() => _UploadFileDetailsTabletRolesState();
}

class _UploadFileDetailsTabletRolesState extends State<UploadFileDetailsTabletRoles> {

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
