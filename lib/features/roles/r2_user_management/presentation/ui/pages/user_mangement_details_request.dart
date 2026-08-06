import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_controller.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/mobile_phone_model.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:grc_module/generated/l10n.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../../external/knowledge_hub_module/core/custom_dialog_manager.dart';
// REMOVED_MODULE: import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
part '../widgets/umdr_methods1.dart';
part '../widgets/umdr_methods2.dart';
part '../widgets/umdr_methods3.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';


class UserManagementDetailsRequestSettings extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String? requestId;

  const UserManagementDetailsRequestSettings({
    super.key,
    required this.requestData,
    this.requestId,
  });

  @override
  State<UserManagementDetailsRequestSettings> createState() =>
      _UserManagementDetailsRequestSettingsState();
}

class _UserManagementDetailsRequestSettingsState
    extends State<UserManagementDetailsRequestSettings> {
  late TextEditingController requestNoteController;
  bool submitted = false;
  bool isProcessing = false;
  bool isLoading = true;

  String status = 'pending';
  int requestTime = 0;
  String createdByID = '';
  String createdByEmail = '';
  String section = '';

  List<Map<String, String>> changes = [];
  Map<String, dynamic>? completeRequestData;

  @override
  void initState() {
    super.initState();
    requestNoteController = TextEditingController();
    _fetchCompleteRequestData();
  }




  @override
  void dispose() {
    requestNoteController.dispose();
    super.dispose();
  }






















  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final employeeController = Get.find<MainCoreEmployeeController>();
    final creatorEmployee =
    employeeController.getLocaleEmployee(createdByEmail);

    final String creatorName = creatorEmployee != null
        ? employeeController.getEmployeeName(createdByEmail)
        : 'Unknown User';

    final String creatorTitle = creatorEmployee != null
        ? employeeController.getEmployeeJobTitle(createdByEmail)
        : '-';

    final String creatorDepartment = creatorEmployee != null
        ? employeeController.getEmployeeDepartmentName(createdByEmail)
        : '-';

    final String creatorPhone = () {
      if (creatorEmployee?.mobilePhone == null) return '-';
      final phone = isArabic
          ? "${creatorEmployee?.mobilePhone?.phone} ${creatorEmployee?.mobilePhone?.countryCode}"
          : "${creatorEmployee?.mobilePhone?.countryCode} ${creatorEmployee?.mobilePhone?.phone}";
      if (phone.trim().isEmpty || phone == ' ') return '-';
      return phone.replaceAll(RegExp(r'[\[\]]'), '');
    }();

    final String creatorEmail = creatorEmployee?.email ?? createdByEmail;

    final String creatorPhoto = creatorEmployee != null
        ? employeeController.getEmployeePhoto(createdByEmail)
        : "assets/icons_assets/main_icons_assets/male_avatar.svg";

    final bool isNetworkPhoto = creatorPhoto.startsWith('http');

    final contentWidget = _buildContent(
      lightMode,
      isMobile,
      isArabic,
      creatorName,
      creatorTitle,
      creatorDepartment,
      creatorPhone,
      creatorEmail,
      creatorPhoto,
      isNetworkPhoto,
    );

    if (isMobile) {
      return Scaffold(
        body: SideFrameMasterServices(
          titleText: S.of(context).userManagement,
          onFirstTap: () => Navigator.of(context).pop(),
          secondTitle: S.of(context).requests,
          onSecondTap: () => Navigator.pop(context),
          thirdTitle: S.of(context).requestDetails,
          child: SingleChildScrollView(child: contentWidget),
        ),
      );
    }

    return SideFrameMasterServices(
      titleText: S.of(context).userManagement,
      onFirstTap: () => Navigator.of(context).pop(),
      secondTitle: S.of(context).requests,
      onSecondTap: () => Navigator.pop(context),
      thirdTitle: S.of(context).requestDetails,
      child: SingleChildScrollView(child: contentWidget),
    );
  }
}
