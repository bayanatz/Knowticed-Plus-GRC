part of '../pages/user_mangement_details_request.dart';

extension UmdrMethods1 on _UserManagementDetailsRequestSettingsState {
  Future<void> _fetchCompleteRequestData() async {
    try {
      if (widget.requestId == null || widget.requestId!.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final String basePath = getBaseUrl('Modules');
      final docSnapshot = await FirebaseFirestore.instance
          .doc('$basePath/roles')
          .collection('Employees_Request')
          .doc(widget.requestId)
          .get();

      if (!docSnapshot.exists) {
        setState(() => isLoading = false);
        return;
      }

      completeRequestData = docSnapshot.data();
      _initializeWithCompleteData();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }
  void _initializeWithCompleteData() {
    if (completeRequestData == null) {
      setState(() => isLoading = false);
      return;
    }

    createdByEmail = completeRequestData!['employeeEmail'] ?? '';
    createdByID = completeRequestData!['employeeId'] ?? '';
    status = completeRequestData!['status'] ?? 'pending';
    section = completeRequestData!['section'] ?? 'Personal Information';

    final requestDate = completeRequestData!['requestDate'];
    if (requestDate != null) {
      if (requestDate is int) {
        requestTime = requestDate;
      } else if (requestDate is Timestamp) {
        requestTime = requestDate.millisecondsSinceEpoch;
      }
    }

    requestNoteController.text = FormatHelper.capitalize(
        completeRequestData!['requestNote']?.toString() ?? '');

    _parseChanges();
    setState(() => isLoading = false);
  }
  void _parseChanges() {
    try {
      final changesData = completeRequestData!['changes'];

      if (changesData is List && changesData.isNotEmpty) {
        changes = changesData.map((change) {
          if (change is Map) {
            return {
              'fieldName': change['fieldName']?.toString() ?? '',
              'oldValue': change['oldValue']?.toString() ?? '',
              'newValue': change['newValue']?.toString() ?? '',
            };
          }
          return <String, String>{};
        }).where((c) => c['fieldName']?.isNotEmpty == true).toList();
      } else {
        final whatChanged =
            completeRequestData!['whatChanged']?.toString().trim() ?? '';
        final oldValue = completeRequestData!['oldValue']?.toString() ?? '';
        final newValue = completeRequestData!['newValue']?.toString() ?? '';

        if (whatChanged.isNotEmpty) {
          changes = [
            {'fieldName': whatChanged, 'oldValue': oldValue, 'newValue': newValue}
          ];
        } else {
          changes = [];
        }
      }
    } catch (e) {
      changes = [];
    }
  }
  String _mapFieldName(String requestFieldName) {
    final fieldMappings = {
      'first_name': 'firstName',
      'middle_name': 'middleName',
      'last_name': 'lastName',
      'first_name_arabic': 'firstNameInArabic',
      'middle_name_arabic': 'middleNameInArabic',
      'last_name_arabic': 'lastNameInArabic',
      'email': 'email',
      'gender': 'gender',
      'date_of_birth': 'birthDay',
      'marital_status': 'maritalStatus',
      'street': 'street',
      'city': 'city',
      'province': 'province',
      'country': 'country',
      'postalCode': 'postalCode',
      'postal_code': 'postalCode',
      'phone': 'mobilePhone.phones',
      'Phone': 'mobilePhone.phones',
      'country_code': 'mobilePhone.countryCode',
      'Country_Code': 'mobilePhone.countryCode',
      'country_app': 'mobilePhone.countryApp',
      'Country_App': 'mobilePhone.countryApp',
      'insuranceName': 'insuranceName',
      'insurance_name': 'insuranceName',
      'Insurance_Name': 'insuranceName',
      'insurancePolicyNumber': 'insurancePolicyNumber',
      'insurance_policy_number': 'insurancePolicyNumber',
      'Insurance_Policy_Number': 'insurancePolicyNumber',
      'firstContactFirstName': 'firstContactFirstName',
      'firstContactLastName': 'firstContactLastName',
      'firstContactRelationship': 'firstContactRelationship',
      'firstContactEmail': 'firstContactEmail',
      'firstContactPhone': 'firstContactPhone',
      'secondContactFirstName': 'secondContactFirstName',
      'secondContactLastName': 'secondContactLastName',
      'secondContactRelationship': 'secondContactRelationship',
      'secondContactEmail': 'secondContactEmail',
      'secondContact_email': 'secondContactEmail',
      'secondContactPhone': 'secondContactPhone',
    };
    return fieldMappings[requestFieldName] ?? requestFieldName;
  }
  Future<void> _updateEmployeeData() async {
    final employeeController = Get.find<MainCoreEmployeeController>();
    final employeeEntity = employeeController.getLocaleEmployee(createdByEmail);

    if (employeeEntity == null) throw Exception('Employee not found');

    final employeeId = employeeEntity.id;
    if (employeeId == null || employeeId.isEmpty)
      throw Exception('Employee ID not found');

    final String basePath = getBaseUrl('Employees_Info');
    final employeeDoc =
    await FirebaseFirestore.instance.doc('$basePath/$employeeId').get();

    if (!employeeDoc.exists) throw Exception('Employee document not found');

    var employeeHistory =
    NewEmployeeModelHistory.fromMap(employeeDoc.data());

    for (var change in changes) {
      final fieldName = change['fieldName']!;
      final newValue = change['newValue']!;
      final modelFieldName = _mapFieldName(fieldName);

      if (modelFieldName.startsWith('mobilePhone.')) {
        await _updateMobilePhoneField(
          employeeId: employeeId,
          basePath: basePath,
          employeeHistory: employeeHistory,
          modelFieldName: modelFieldName,
          newValue: newValue,
        );
      } else {
        employeeHistory =
            employeeHistory.updateFieldSynchronized(modelFieldName, newValue);
      }
    }

    if (!changes
        .any((c) => _mapFieldName(c['fieldName']!).startsWith('mobilePhone.'))) {
      await FirebaseFirestore.instance
          .doc('$basePath/$employeeId')
          .update(employeeHistory.toMap());
    }
  }
  Future<void> _updateMobilePhoneField({
    required String employeeId,
    required String basePath,
    required NewEmployeeModelHistory employeeHistory,
    required String modelFieldName,
    required String newValue,
  }) async {
    final phoneFieldName = modelFieldName.split('.').last;
    MobilePhone? currentPhone;

    if (employeeHistory.mobilePhone != null &&
        employeeHistory.mobilePhone!.isNotEmpty) {
      currentPhone = employeeHistory.mobilePhone!.last;
    }
    currentPhone ??= MobilePhone();

    final now = Timestamp.now();
    List<String> updatedPhones = List.from(currentPhone.phones ?? []);
    List<String> updatedCountryCodes =
    List.from(currentPhone.countryCode ?? []);
    List<String> updatedCountryApps = List.from(currentPhone.countryApp ?? []);
    List<Timestamp> updatedTimestamps =
    List.from(currentPhone.timestamps ?? []);

    switch (phoneFieldName) {
      case 'phones':
        updatedPhones.add(newValue);
        break;
      case 'countryCode':
        updatedCountryCodes.add(newValue);
        break;
      case 'countryApp':
        updatedCountryApps.add(newValue);
        break;
    }
    updatedTimestamps.add(now);

    final updatedPhone = MobilePhone(
      phones: updatedPhones,
      countryCode: updatedCountryCodes,
      countryApp: updatedCountryApps,
      timestamps: updatedTimestamps,
    );

    await FirebaseFirestore.instance
        .doc('$basePath/$employeeId')
        .update({'Mobile_Phone': (updatedPhone.toMap())});
  }
  String _formatValueForDisplay(String value, String fieldName) {
    bool isDateField = fieldName.toLowerCase().contains('date') ||
        fieldName.toLowerCase().contains('birth') ||
        fieldName.toLowerCase().contains('_of_');

    if (!isDateField) return value;

    try {
      DateTime? dateTime;
      if (value.contains('T')) {
        dateTime = DateTime.tryParse(value);
      } else if (value.contains('-') && value.split('-').length == 3) {
        dateTime = DateTime.tryParse(value);
      } else if (value.contains('/')) {
        List<String> parts = value.split('/');
        if (parts.length == 3) {
          int month = int.tryParse(parts[0]) ?? 0;
          int day = int.tryParse(parts[1]) ?? 0;
          int year = int.tryParse(parts[2]) ?? 0;
          if (year < 100) year += (year <= 30) ? 2000 : 1900;
          if (month > 0 && day > 0 && year > 0) {
            dateTime = DateTime(year, month, day);
          }
        }
      } else if (int.tryParse(value) != null) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(value));
      }
      if (dateTime != null) return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {}

    return value;
  }
  // ─── CORE: update status in Firestore ────────────────────────────────────
  Future<void> _updateRequestStatus(String newStatus) async {
    if (widget.requestId == null) return;

    setState(() => isProcessing = true);

    try {
      final String basePath = getBaseUrl('Modules');

      if (newStatus == 'approved') {
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'approved'
                  ? 'Request approved successfully ✓'
                  : 'Request rejected ✗',
            ),
            backgroundColor:
            newStatus == 'approved' ? Color(0xFF34C759) : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isProcessing = false);
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
  // ─── Confirmation dialog via CustomDialogManager ─────────────────────────
  Future<void> _showConfirmDialog({required String action}) async {
    final isApprove = action == 'approved';

    await CustomDialogManager.showDialogFlow(
      context: context,

      // ── Confirm step ──────────────────────────────────────────────────────
      confirmLottie: isApprove
          ? 'assets/lottie/confirm_approve.json'   // ← swap with your actual lottie paths
          : 'assets/lottie/confirm_reject.json',
      confirmTitle: isApprove
          ? 'Approve Request'
          : 'Reject Request',
      confirmSubtitle: isApprove
          ? 'Are you sure you want to approve this request?'
          : 'Are you sure you want to reject this request?',
      confirmYesText: isApprove ? S.of(context).approve : S.of(context).reject,
      confirmNoText: 'Cancel',

      // ── What happens when the user taps YES ───────────────────────────────
      onConfirm: () {
        _updateRequestStatus(action);
      },

      // ── No comment dialog needed ──────────────────────────────────────────
      comment: false,

      // ── Success step ──────────────────────────────────────────────────────
      successLottie: isApprove
          ? 'assets/lottie/success_approve.json'   // ← swap with your actual lottie paths
          : 'assets/lottie/success_reject.json',
      successTitle: isApprove
          ? 'Request Approved'
          : 'Request Rejected',
      successSubtitle: isApprove
          ? 'The request has been approved successfully.'
          : 'The request has been rejected.',
    );
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
        return 'assets/icons_assets/main_icons_assets/approve_icon.svg';
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
  String _getFieldLabel(String fieldKey) {
    final labelMap = {
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
      'secondContact_email': 'Emergency Contact Email',
      'secondContactEmail': 'Emergency Contact Email',
      'secondContactPhone': 'Emergency Contact Phone',
      'secondContactFirstName': 'Emergency Contact First Name',
      'secondContactLastName': 'Emergency Contact Last Name',
      'secondContactRelationship': 'Emergency Contact Relationship',
      'firstContactEmail': 'Primary Contact Email',
      'firstContactPhone': 'Primary Contact Phone',
      'firstContactFirstName': 'Primary Contact First Name',
      'firstContactLastName': 'Primary Contact Last Name',
      'firstContactRelationship': 'Primary Contact Relationship',
      'insuranceName': 'Insurance Name',
      'insurance_name': 'Insurance Name',
      'Insurance_Name': 'Insurance Name',
      'insurancePolicyNumber': 'Insurance Policy Number',
      'insurance_policy_number': 'Insurance Policy Number',
      'Insurance_Policy_Number': 'Insurance Policy Number',
    };
    return labelMap[fieldKey] ?? _formatFieldName(fieldKey);
  }
  String _formatFieldName(String fieldKey) {
    return fieldKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }
}
