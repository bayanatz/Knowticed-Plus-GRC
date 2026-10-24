/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/ui/widgets/creating_knowledge_hub.actions
///
///*************************** FILE INFO ****************************///
/// File Name: creating_knowledge_hub_actions_logic.dart
/// Description: Logic and event handlers of `_CreatingKnowledgeHubActions` — split out of `creating_knowledge_hub.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/creating_knowledge_hub.dart';

mixin _CreatingKnowledgeHubActionsLogic
    on
        State<CreatingKnowledgeHub>,
        _CreatingKnowledgeHubData,
        _CreatingKnowledgeHubActions {
  /// "HH:mm" of [time], or null.
  String? _hhmm(TimeOfDay? time) => time == null
      ? null
      : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  /// Builds the draft from the form and asks the cubit to save it. True only
  /// when the files were uploaded and the document saved (KH-CREATE-04); on
  /// failure an error toast is shown and the form keeps its values.
  @override
  Future<bool> _submitToFirebase({required bool isEditing}) async {
    if (!_validateForm()) return false;

    // KH-CREATE-10: never save a placeholder identity.
    final String? authorEmail = _employeeEmail;
    final String? owningDepartmentName = _getOwningDepartmentForSubmission();
    if (authorEmail == null ||
        authorEmail.isEmpty ||
        owningDepartmentName == null) {
      Fluttertoast.showToast(
        msg: S.of(context).accountDataLoadError,
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }

    final CreateKnowledgeCubit cubit = context.read<CreateKnowledgeCubit>();
    final CreateKnowledgeModel? existing = isEditing
        ? cubit.currentKnowledgeDocument
        : null;
    final String status = _getKnowledgeStatus(isEditing: isEditing);

    final KnowledgeDraft draft = KnowledgeDraft(
      nameEnglish: _englishController.text.trim(),
      nameArabic: _arabicController.text.trim(),
      descriptionEnglish: _englishDescController.text.trim(),
      descriptionArabic: _arabicDescController.text.trim(),
      documentType: _dropDownMenuText,
      owningDepartment: owningDepartmentName,
      limitedDepartments: _limitDepartmentAvailability
          ? _selectedDepartments
          : const [],
      schedulePublishing: _schedulePublishing,
      startDateTime: (_schedulePublishing && _startDate != null)
          ? _combineDateTime(_startDate, _startTime, isEnd: false)
          : null,
      endDateTime: (_schedulePublishing && _endDate != null)
          ? _combineDateTime(_endDate, _endTime, isEnd: true)
          : null,
      startTime: _schedulePublishing ? _hhmm(_startTime) : null,
      endTime: _schedulePublishing ? _hhmm(_endTime) : null,
      imageUrl: existing?.currentImageUrl,
      documentUrl: _selectedDocument == null
          ? existing?.currentDocumentUrl
          : null,
      documentFileName: _selectedDocument != null
          ? (_documentFileName ?? 'document')
          : (existing?.currentDocumentFileName ?? 'document'),
      documentExtension: _selectedDocument != null
          ? (_documentExtension ?? '')
          : (existing?.currentDocumentExtension ?? ''),
      documentSize: _selectedDocument != null
          ? _documentSize
          : (existing?.currentDocumentSize ?? 0),
      createdByEmail: authorEmail,
      status: status,
    );

    setState(() => _isUploading = true);
    final bool saved = await cubit.submitKnowledge(
      draft: draft,
      newImage: _selectedImage,
      newDocument: _selectedDocument,
      newDocumentFileName: _documentFileName,
      editingKnowledgeId: isEditing ? widget.knowledgeId : null,
      notifySupervisor: status == 'pending_approval',
    );
    if (!mounted) return saved;
    setState(() => _isUploading = false);
    if (!saved) {
      Fluttertoast.showToast(
        msg: S.of(context).error,
        toastLength: Toast.LENGTH_LONG,
      );
    }
    return saved;
  }

  /// Pre-fill form when editing
  @override
  void _preFillFormData(CreateKnowledgeModel knowledge) {
    khLog('═══════════════════════════════════════');
    khLog('📝 PRE-FILLING FORM DATA FOR EDIT');
    khLog('═══════════════════════════════════════');

    // Set text fields
    _englishController.text = knowledge.currentNameEnglish;
    _arabicController.text = knowledge.currentNameArabic;
    _englishDescController.text = knowledge.currentDescriptionEnglish;
    _arabicDescController.text = knowledge.currentDescriptionArabic;

    // Store the existing document info FIRST
    submittedDocument = knowledge;

    // Set document type
    _dropDownMenuText = knowledge.currentKnowledgeDocumentType;

    // ✅ Set owning department from knowledge data
    String owningDeptName = knowledge.currentOwningDepartment;
    String? deptId = _departmentController.getDepartmentIdFromDepartmentName(
      departmentName: owningDeptName.toLowerCase(),
    );
    if (deptId != null && deptId != "none") {
      _selectedOwningDepartmentId = deptId;
      khLog('✓ Owning Department ID set: $deptId');
    }

    khLog('✓ Text fields set:');
    khLog('   EN Name: ${knowledge.currentNameEnglish}');
    khLog('   AR Name: ${knowledge.currentNameArabic}');
    khLog('✓ Document Type: $_dropDownMenuText');

    // Set scheduling info - CHECK if dates exist, then enable toggle
    if (knowledge.currentStartDateTime != null ||
        knowledge.currentEndDateTime != null) {
      _schedulePublishing = true;
      khLog('✓ Schedule Publishing: ENABLED');

      if (knowledge.currentStartDateTime != null) {
        final startDate = knowledge.currentStartDateTime!.toDate();
        _startDate = startDate;
        _startTime = TimeOfDay.fromDateTime(startDate);
        khLog('✓ Start Date: $startDate');
      }

      if (knowledge.currentEndDateTime != null) {
        final endDate = knowledge.currentEndDateTime!.toDate();
        _endDate = endDate;
        _endTime = TimeOfDay.fromDateTime(endDate);
        khLog('✓ End Date: $endDate');
      }
    } else {
      _schedulePublishing = false;
      khLog('✓ Schedule Publishing: DISABLED');
    }

    // Set department limitations - CHECK if departments exist, then enable toggle
    if (knowledge.limitedDepartments.isNotEmpty) {
      _limitDepartmentAvailability = true;
      khLog('✓ Limited Departments: ENABLED');

      // Parse and set selected departments
      List<String> limitedDepts = _parseLimitedDepartments(
        knowledge.limitedDepartments,
      );

      khLog('   Found ${limitedDepts.length} limited departments:');
      for (String dept in limitedDepts) {
        _departmentSelections[dept] = true;
        khLog('   - $dept');
      }
    } else {
      _limitDepartmentAvailability = false;
      khLog('✓ Limited Departments: DISABLED (public access)');
    }

    khLog('═══════════════════════════════════════');
    khLog('✅ FORM PRE-FILL COMPLETE');
    khLog('   📋 Document Type: $_dropDownMenuText');
    khLog('   🔄 Schedule Publishing: $_schedulePublishing');
    khLog('   🏢 Limit Departments: $_limitDepartmentAvailability');
    khLog('═══════════════════════════════════════\n');

    // Force rebuild to show the data - ONLY ONE setState at the end
    if (mounted) setState(() {});
  }
}
