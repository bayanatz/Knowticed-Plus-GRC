/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/ui/pages
/// ************************* FILE INFO *************************** ///
/// File Name: creating_knowledge_hub.dart
/// Description: Created to handle creating and submitting new knowledge file to firebase.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
/// Updated: Added dropdown for owning department selection with permission check
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';

import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/domain/entities/knowledge_draft.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_state.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/creating_knowledge_confirmation_dialog.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/ui/widgets/action_buttons.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/ui/widgets/configuration_section.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/ui/widgets/image_and_document_section.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';

part 'creating_knowledge_hub.data.dart';
part 'creating_knowledge_hub.actions.dart';
part '../widgets/creating_knowledge_hub.actions/creating_knowledge_hub_actions_logic.dart';

class CreatingKnowledgeHub extends StatefulWidget {
  final String? knowledgeId;
  const CreatingKnowledgeHub({super.key, this.knowledgeId});

  @override
  State<CreatingKnowledgeHub> createState() => _CreatingKnowledgeHubState();
}

class _CreatingKnowledgeHubState extends State<CreatingKnowledgeHub>
    with
        _CreatingKnowledgeHubData,
        _CreatingKnowledgeHubActions,
        _CreatingKnowledgeHubActionsLogic {
  @override
  void initState() {
    super.initState();

    // ✅ Set edit mode
    _isEditMode = widget.knowledgeId != null;

    _initializeData();

    // ✅ Fetch knowledge data if editing
    if (_isEditMode) {
      khLog('📝 EDIT MODE - Fetching knowledge: ${widget.knowledgeId}');
      context.read<CreateKnowledgeCubit>().fetchKnowledgeByKnowledgeId(
        widget.knowledgeId!,
      );
    }
  }

  @override
  void dispose() {
    _englishController.dispose();
    _arabicController.dispose();
    _englishDescController.dispose();
    _arabicDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    // (Knowledge Hub bug report p.14 / p.19 — "loading
    // indicator in whole page"). `_isUploading` was already set around every
    // upload but nothing drew it: creating showed a small spinner INSIDE the
    // confirmation dialog, and saving an edit showed nothing at all after the
    // Reason Of Editing dialog closed. The page now puts one full-page modal
    // overlay over itself for as long as an upload runs, for both paths.
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildPageBody(context, isMobile)),
          if (_isUploading && !_suppressPageOverlay)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: AppColors.totalBlack.withValues(alpha: 0.5),
                  child: Center(
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: CircleProgressMaster.inline(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.lightPrimary,
                        ),
                        backgroundColor: AppColors.white.withValues(alpha: 0.6),
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageBody(BuildContext context, bool isMobile) {
    return _buildEmployeeDataWrapper(
      child: SideFrameMasterServices(
        titleText: S.of(context).knowledge_hub,
        onFirstTap: () => Navigator.of(context).maybePop(),
        secondTitle: _isEditMode
            ? S
                  .of(context)
                  .editingDocumentDetails(
                    KhLocale.pick(
                      context,
                      en: submittedDocument?.currentNameEnglish ?? '',
                      ar: submittedDocument?.currentNameArabic ?? '',
                    ),
                  )
            : S.of(context).creating_knowledge_hub,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ImageDocumentSection(
                isMobile: isMobile,
                selectedImage: _selectedImage,
                selectedDocument: _selectedDocument,
                documentFileName: _documentFileName,
                documentSize: _documentSize,
                documentUploadedDate: _documentUploadedDate,
                documentExtension: _documentExtension,
                submittedDocument: submittedDocument,
                pickImage: _pickImage,
                pickDocument: _pickDocument,
                removeDocument: _removeDocument,
                englishController: _englishController,
                arabicController: _arabicController,
                englishDescController: _englishDescController,
                arabicDescController: _arabicDescController,
                documentNameFormKey: _documentNameFormKey,
                documentDescriptionKey: _documentDescriptionKey,
                onChanged: () => setState(() {}),
              ),
              SizedBox(height: 15.h),
              ConfigurationSection(
                dropDownMenuText: _dropDownMenuText,
                employeeDepartment: _getSelectedOwningDepartmentName(
                  context,
                ), //
                limitDepartmentAvailability: _limitDepartmentAvailability,
                schedulePublishing: _schedulePublishing,
                startDate: _startDate,
                startTime: _startTime,
                endDate: _endDate,
                endTime: _endTime,
                availableDepartments: _availableDepartments,
                departmentSelections: _departmentSelections,
                submittedDocument: submittedDocument,
                selectedOwningDepartmentId: _selectedOwningDepartmentId,
                onDocTypeChanged: (value) {
                  if (value != null) {
                    setState(() => _dropDownMenuText = value.toString());
                    khLog('You choose $value');
                  }
                },
                onOwningDepartmentChanged: (departmentId) {
                  setState(() => _selectedOwningDepartmentId = departmentId);
                  khLog('Selected owning department: $departmentId');
                },
                onLimitDepartmentToggle: (value) =>
                    setState(() => _limitDepartmentAvailability = value),
                onSchedulePublishingToggle: (value) =>
                    setState(() => _schedulePublishing = value),
                onStartDateSelected: (date) =>
                    setState(() => _startDate = date),
                onStartTimeSelected: (time) =>
                    setState(() => _startTime = time),
                onEndDateSelected: (date) => setState(() => _endDate = date),
                onEndTimeSelected: (time) => setState(() => _endTime = time),
                onDepartmentAdded: (departmentName) {
                  setState(() => _departmentSelections[departmentName] = true);
                },
                onDepartmentRemoved: (departmentName) {
                  setState(() => _departmentSelections[departmentName] = false);
                },
              ),
              SizedBox(height: 20.sp),
              ActionButtonsSection(
                onDiscard: () => Navigator.of(context).pop(),
                onSubmit: _handleSubmitForApproval,
                isFormComplete: _isFormComplete(),
                isEditing: _isEditMode,
              ),
              SizedBox(height: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
