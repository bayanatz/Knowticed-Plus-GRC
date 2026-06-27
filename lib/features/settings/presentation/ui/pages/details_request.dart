import 'package:demo_app/features/settings/core_widgets/main_widget/side_frame_master.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/theme/app_theme.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../generated/l10n.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../external/knowledge_hub_module/knowledge_hub/presentation/ui/widgets/customed_text_field.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import '../../../../employee/data/models/emplyees_model/new_employee_model.dart';
import '../../../../employee/presentation/controller/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/core/custom_textformfield.dart';

class DetailsRequestSettings extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String? requestId;

  const DetailsRequestSettings({
    super.key,
    required this.requestData,
    this.requestId,
  });

  @override
  State<DetailsRequestSettings> createState() => _DetailsRequestSettingsState();
}

class _DetailsRequestSettingsState extends State<DetailsRequestSettings> {
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

    print('🔍 DEBUG - Initial RequestData received:');
    print('   - Keys: ${widget.requestData.keys.toList()}');
    print('   - Request ID: ${widget.requestId}');

    _fetchCompleteRequestData();
  }

  /// ✅ Fetch the complete request document from Firebase
  Future<void> _fetchCompleteRequestData() async {
    try {
      if (widget.requestId == null || widget.requestId!.isEmpty) {
        print('❌ No request ID provided');
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('📥 Fetching complete request data from Firebase...');
      print('   Request ID: ${widget.requestId}');

      final String basePath = getBaseUrl('Modules');
      final String docPath = '$basePath/roles';

      print('   Path: $docPath/Employees_Request/${widget.requestId}');

      final docSnapshot = await FirebaseFirestore.instance
          .doc(docPath)
          .collection('Employees_Request')
          .doc(widget.requestId)
          .get();

      if (!docSnapshot.exists) {
        print('❌ Request document not found');
        setState(() {
          isLoading = false;
        });
        return;
      }

      completeRequestData = docSnapshot.data();

      print('✅ Complete document fetched');
      print('   - Keys: ${completeRequestData?.keys.toList()}');

      _initializeWithCompleteData();

    } catch (e, stackTrace) {
      print('❌ Error fetching complete request data: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        isLoading = false;
      });
    }
  }

  /// ✅ Initialize all fields with the complete data
  void _initializeWithCompleteData() {
    if (completeRequestData == null) {
      print('⚠️ Complete request data is null');
      setState(() {
        isLoading = false;
      });
      return;
    }

    print('🔄 Initializing with complete data...');

    createdByEmail = completeRequestData!['employeeEmail'] ?? '';
    createdByID = completeRequestData!['employeeId'] ?? '';
    status = completeRequestData!['status'] ?? 'pending';
    section = completeRequestData!['section'] ?? 'Personal Information';

    print('   Employee: $createdByEmail ($createdByID)');
    print('   Status: "$status"');
    print('   Section: "$section"');

    // Parse request date
    final requestDate = completeRequestData!['requestDate'];
    if (requestDate != null) {
      if (requestDate is int) {
        requestTime = requestDate;
      } else if (requestDate is Timestamp) {
        requestTime = requestDate.millisecondsSinceEpoch;
      }
    }

    // Initialize request note controller
    requestNoteController = TextEditingController(
      text: completeRequestData!['requestNote'] ?? '',
    );

    // ✅ Parse changes
    _parseChanges();

    setState(() {
      isLoading = false;
    });

    print('✅ Initialization complete');
  }

  /// ✅ Parse the changes from Firebase (handles both array and single-field format)
  void _parseChanges() {
    try {
      print('🔍 Parsing changes:');

      // ✅ Check if 'changes' array exists (future format)
      final changesData = completeRequestData!['changes'];

      if (changesData is List && changesData.isNotEmpty) {
        // Handle array format
        changes = changesData.map((change) {
          if (change is Map) {
            return {
              'fieldName': change['fieldName']?.toString() ?? '',
              'oldValue': change['oldValue']?.toString() ?? '',
              'newValue': change['newValue']?.toString() ?? '',
            };
          }
          return <String, String>{};
        }).where((change) => change['fieldName']?.isNotEmpty == true).toList();

        print('✅ Parsed ${changes.length} changes from array format');
        for (var i = 0; i < changes.length; i++) {
          print('   Change ${i + 1}:');
          print('      - Field: ${changes[i]['fieldName']}');
          print('      - Old: "${changes[i]['oldValue']}"');
          print('      - New: "${changes[i]['newValue']}"');
        }
      }
      // ✅ Handle current single-field format
      else {
        final whatChanged = completeRequestData!['whatChanged']?.toString().trim() ?? '';
        final oldValue = completeRequestData!['oldValue']?.toString() ?? '';
        final newValue = completeRequestData!['newValue']?.toString() ?? '';

        print('   - whatChanged: "$whatChanged"');
        print('   - oldValue: "$oldValue"');
        print('   - newValue: "$newValue"');

        if (whatChanged.isNotEmpty) {
          changes = [
            {
              'fieldName': whatChanged,
              'oldValue': oldValue,
              'newValue': newValue,
            }
          ];

          print('✅ Parsed 1 change from single-field format:');
          print('   - Field: $whatChanged');
          print('   - Old: "${oldValue.isEmpty ? '(empty)' : oldValue}"');
          print('   - New: "${newValue.isEmpty ? '(empty)' : newValue}"');
        } else {
          print('⚠️ No whatChanged field found or it is empty');
          changes = [];
        }
      }

      print('📊 Total changes parsed: ${changes.length}');

    } catch (e, stackTrace) {
      print('❌ Error parsing changes: $e');
      print('Stack trace: $stackTrace');
      changes = [];
    }
  }

  @override
  void dispose() {
    requestNoteController.dispose();
    super.dispose();
  }

  /// ✅ Map field names from request to NewEmployeeModelHistory field names
  String _mapFieldName(String requestFieldName) {
    final fieldMappings = {
      // Basic fields
      'first_name': 'firstName',
      'middle_name': 'middleName',
      'last_name': 'lastName',
      'first_name_arabic': 'firstNameInArabic',
      'middle_name_arabic': 'middleNameInArabic',
      'last_name_arabic': 'lastNameInArabic',
      'email': 'email',
      'phone': 'mobilePhone',
      'gender': 'gender',
      'date_of_birth': 'birthDay',
      'marital_status': 'maritalStatus',

      // Address fields
      'street': 'street',
      'city': 'city',
      'province': 'province',
      'country': 'country',
      'postal_code': 'postalCode',
      'postalCode': 'postalCode',

      // Health Insurance
      'insurance_name': 'insuranceName',
      'insuranceName': 'insuranceName',
      'Insurance_Name': 'insuranceName',
      'insurance_policy_number': 'insurancePolicyNumber',
      'insurancePolicyNumber': 'insurancePolicyNumber',
      'Insurance_Policy_Number': 'insurancePolicyNumber',

      // ✅ Emergency Contact fields
      'secondContact_name': 'secondContactName',
      'secondContact_email': 'secondContactEmail',
      'secondContact_phone': 'secondContactPhone',
      'secondContact_relationship': 'secondContactRelationship',
    };

    return fieldMappings[requestFieldName] ?? requestFieldName;
  }

  /// ✅ Update ALL changed fields in employee data
  Future<void> _updateEmployeeData() async {
    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      final employeeEntity = employeeController.getLocaleEmployee(createdByEmail);

      if (employeeEntity == null) {
        print('❌ Error: Employee not found for email: $createdByEmail');
        throw Exception('Employee not found');
      }

      final employeeId = employeeEntity.id;

      if (employeeId == null || employeeId.isEmpty) {
        print('❌ Error: Employee ID is null or empty');
        throw Exception('Employee ID not found');
      }

      print('📍 Updating employee: $employeeId');
      print('📍 Number of fields to update: ${changes.length}');

      final String basePath = getBaseUrl('Employees_Info');

      final employeeDoc = await FirebaseFirestore.instance
          .doc('$basePath/$employeeId')
          .get();

      if (!employeeDoc.exists) {
        print('❌ Error: Employee document does not exist');
        throw Exception('Employee document not found');
      }

      final docData = employeeDoc.data();
      var employeeHistory = NewEmployeeModelHistory.fromMap(docData);

      print('📝 Starting field updates...');

      // ✅ Update ALL changed fields
      for (var i = 0; i < changes.length; i++) {
        final change = changes[i];
        final fieldName = change['fieldName']!;
        final newValue = change['newValue']!;

        print('\n--- Updating field ${i + 1}/${changes.length} ---');
        print('   Field: $fieldName');
        print('   New value: $newValue');

        final modelFieldName = _mapFieldName(fieldName);
        print('   Mapped to: $modelFieldName');

        employeeHistory = employeeHistory.updateFieldSynchronized(
          modelFieldName,
          newValue,
        );

        print('   ✅ Updated successfully');
      }

      print('\n💾 Saving updated employee data...');

      final updatedMap = employeeHistory.toMap();
      await FirebaseFirestore.instance
          .doc('$basePath/$employeeId')
          .update(updatedMap);

      print('✅ All fields updated successfully in Firebase');

    } catch (e, stackTrace) {
      print('❌ Error updating employee data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// ✅ Update request status in Firebase
  Future<void> _updateRequestStatus(String newStatus) async {
    if (widget.requestId == null) {
      print('❌ Error: No request ID provided');
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final String basePath = getBaseUrl('Modules');

      if (newStatus == 'approved') {
        print('🔄 Approving request - updating employee data...');
        await _updateEmployeeData();
      }

      await FirebaseFirestore.instance
          .doc('$basePath/roles')
          .collection('Employees_Request')
          .doc(widget.requestId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        status = newStatus;
        isProcessing = false;
      });

      print('✅ Request status updated to: $newStatus');
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      print('❌ Error updating request: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _translateSectionTitle(String englishTitle) {
    bool isArabic = Get.locale?.languageCode == 'ar';
    if (!isArabic) return englishTitle;

    switch (englishTitle) {
      case 'Personal Information':
        return 'المعلومات الشخصية';
      case 'Emergency Contact':
        return 'جهة الاتصال في حالات الطوارئ';
      case 'Health Insurance':
        return 'التأمين الصحي';
      default:
        return englishTitle;
    }
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Color(0xFF34C759);
      case 'pending':
        return Color(0xffFF814A);
      case 'rejected':
        return Colors.red[500]!;
      default:
        return AppColors.secondaryText;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'assets/state_icon/approve_icon.svg';
      case 'pending':
        return 'assets/state_icon/pending_icon.svg';
      case 'rejected':
        return 'assets/state_icon/rejected_icon.svg';
      default:
        return 'assets/state_icon/rejected_icon.svg';
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return S.of(context).Approved;
      case 'pending':
        return S.of(context).Pending;
      case 'rejected':
        return S.of(context).Rejected;
      default:
        return status;
    }
  }

  /// ✅ Get human-readable field labels with translations
  String _getFieldLabel(String fieldKey) {
    final labelMap = {
      // Basic fields
      'first_name': S.of(context).firstName,
      'middle_name': S.of(context).middleName,
      'last_name': S.of(context).lastName,
      'street': S.of(context).streetName,
      'city': S.of(context).city,
      'province': S.of(context).stateOrProvince,
      'country': S.of(context).country,
      'email': S.of(context).email,
      'phone': S.of(context).phoneNumber,
      'gender': S.of(context).gender,
      'date_of_birth': S.of(context).birthday,
      'marital_status': S.of(context).maritalStatus,

      // ✅ Emergency Contact (use fallback if translation doesn't exist)
      'secondContact_name': 'Emergency Contact Name',
      'secondContact_email': 'Emergency Contact Email',
      'secondContact_phone': 'Emergency Contact Phone',
      'secondContact_relationship': 'Emergency Contact Relationship',

      // ✅ Health Insurance
      'insurance_name': 'Insurance Name',
      'insuranceName': 'Insurance Name',
      'Insurance_Name': 'Insurance Name',
      'insurance_policy_number': 'Insurance Policy Number',
      'insurancePolicyNumber': 'Insurance Policy Number',
      'Insurance_Policy_Number': 'Insurance Policy Number',
    };

    return labelMap[fieldKey] ?? _formatFieldName(fieldKey);
  }

  /// ✅ Format field name as fallback (converts "secondContact_email" → "Second Contact Email")
  String _formatFieldName(String fieldKey) {
    return fieldKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  Widget _buildContent(bool lightMode, bool isMobile) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (changes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: Text(
            'No changes found in this request',
            style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.secondaryText
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(lightMode),
        SizedBox(height: 8.h),

        ...changes.map((change) => _buildSection(
          lightMode: lightMode,
          sectionTitle: _translateSectionTitle(section),
          isMobile: isMobile,
          fieldName: change['fieldName']!,
          oldValue: change['oldValue']!,
          newValue: change['newValue']!,
        )).toList(),

        _buildRequestNoteSection(lightMode),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildHeader(bool lightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          S.of(context).requestDetails,
          style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.text
          ),
        ),
        Spacer(),
        Text(
          "${S.of(context).requestedDate}: ",
          style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText
          ),
        ),
        Text(
          _formatDate(requestTime),
          style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required bool lightMode,
    required String sectionTitle,
    required bool isMobile,
    required String fieldName,
    required String oldValue,
    required String newValue,
  })
  {
    return Column(
      children: [
        Container(
          // ✅ Remove height: 320.h
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: AppColors.card,
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 15.sp,left: 15.sp,top: 5.sp), // Changed to all for consistent padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ✅ Add this
              children: [
                SizedBox(height: 15.h),
                _buildSectionHeader(lightMode, sectionTitle),
                SizedBox(height: 20.h),

                isMobile
                    ? Column(
                  mainAxisSize: MainAxisSize.min, // ✅ Add this
                  children: [
                    _buildDataColumn(
                      lightMode: lightMode,
                      title: S.of(context).current_details,
                      titleColor: AppColors.text,
                      value: oldValue,
                      fieldName: fieldName,
                    ),
                    SizedBox(height: 12.h), // Add spacing between columns
                    _buildDataColumn(
                      lightMode: lightMode,
                      title: S.of(context).new_details,
                      titleColor: Colors.green,
                      value: newValue,
                      fieldName: fieldName,
                    ),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDataColumn(
                        lightMode: lightMode,
                        title: S.of(context).current_details,
                        titleColor: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                        value: oldValue,
                        fieldName: fieldName,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildDataColumn(
                        lightMode: lightMode,
                        title: S.of(context).new_details,
                        titleColor: Colors.green,
                        value: newValue,
                        fieldName: fieldName,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSectionHeader(bool lightMode, String sectionTitle) {
    bool isInsuranceSection =
        sectionTitle.contains('Insurance') || sectionTitle.contains('التأمين');

    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: AppColors.primary.withOpacity(.15),
          ),
          child: Center(
            child: CustomSvg(
              assetPath: isInsuranceSection
                  ? "assets/Insurance Details.svg"
                  : "assets/Emergency Contact.svg",
              width: 16.w,
              height: 16.h,
              fit: BoxFit.fill,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          sectionTitle,
          style: StyleText.fontSize18Weight500.copyWith(
              color: AppColors.text
          ),
        )
      ],
    );
  }

  Widget _buildDataColumn({
    required bool lightMode,
    required String title,
    required Color titleColor,
    required String value,
    required String fieldName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: StyleText.fontSize16Weight600.copyWith(
            color: titleColor,
          ),
        ),
        SizedBox(height: 15.h),
        CustomTextField(
          label: _getFieldLabel(fieldName),
          hint: _getFieldLabel(fieldName),
          controller: TextEditingController(text: value.isEmpty ? '-' : value),
          enabled: false,
          fillColor: title.contains('current') || title.contains('الحالية')
              ? (lightMode ? AppColors.background : AppColors.background)
              : null,
        ),
      ],
    );
  }

  Widget _buildRequestNoteSection(bool lightMode) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: AppColors.card
      ),
      child: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          children: [
            CustomTextField(
              hint: S.of(context).requestNote,
              controller: requestNoteController,
              enabled: false,
              label: S.of(context).requestNote,
              maxLines: 3,
              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            ),
            SizedBox(height: 20.h),

            _buildStatusButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: _getStatusColor(status)),
          ),
          width: 200.w,
          height: 36.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSvg(
                assetPath: _getStatusIcon(status),
                width: 24.w,
                height: 24.h,
                fit: BoxFit.scaleDown,
              ),
              SizedBox(width: 8.w),
              Text(
                _getStatusLabel(status),
                style: StyleText.fontSize16Weight500.copyWith(
                  color: _getStatusColor(status),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final contentWidget = _buildContent(lightMode, isMobile);

    if (isMobile) {
      return Scaffold(
        body: SideFrameMaster(
          titleText: S.of(context).settings,
          onFirstTap: () {},
          secondTitle: S.of(context).requestDetails,
          child: SingleChildScrollView(
            child: contentWidget,
          ),
        ),
      );
    }

    return SideFrameMasterServices(
      titleText: S.of(context).settings,
      onFirstTap: () {
        Navigator.pop(context);
      },
      secondTitle: S.of(context).requestDetails,
      onSecondTap: () {},
      child: SingleChildScrollView(
        child: contentWidget,
      ),
    );
  }
}