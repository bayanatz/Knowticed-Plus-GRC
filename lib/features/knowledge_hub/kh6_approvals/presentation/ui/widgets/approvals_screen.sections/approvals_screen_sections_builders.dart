/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets/approvals_screen.sections
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_screen_sections_builders.dart
/// Description: UI builder methods of `_ApprovalsScreenSections` — split out of `approvals_screen.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/approvals_screen.dart';

// Split from approvals_screen.sections.dart to keep every file under 700 lines.

extension _ApprovalsScreenSectionsBuilders on _ApprovalsScreenSections {
  Widget buildDocumentCard(
    BuildContext context,
    CreateKnowledgeModel approvals,
    ApprovalsCubit cubit,
  ) {
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () => _openApprovalDetails(context, approvals, cubit),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchCardData(cubit, approvals),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingCard(context);
          }
          final Map<String, dynamic>? data = snapshot.data;
          if (snapshot.hasError || data == null) {
            return _buildErrorCard(context, approvals);
          }
          return _buildLoadedCard(context, approvals, data);
        },
      ),
    );
  }

  /// Loads the card's details, then opens the document's approval screen.
  Future<void> _openApprovalDetails(
    BuildContext context,
    CreateKnowledgeModel approvals,
    ApprovalsCubit cubit,
  ) async {
    final localizedName = _getLocalizedName(approvals);
    final localizedDesc = _getLocalizedDescription(approvals);
    await _fetchCardData(cubit, approvals);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ApprovalsDetailsScreen(
            documentName: localizedName,
            knowledgeId: approvals.currentKnowledgeId,
            fileName: approvals.currentDocumentFileName,
            fileType: approvals.currentKnowledgeDocumentType,
            fileUrl: approvals.currentDocumentUrl,
            department: approvals.currentOwningDepartment,
            documentDesc: localizedDesc,
            createdByEmail: approvals.currentCreatedByEmail,
            createdTimestamp: approvals.currentTimestamp,
            status: approvals.currentStatus,
            fileExtension: approvals.currentDocumentExtension,
            startDate: approvals.currentStartDateTime,
            endDate: approvals.currentEndDateTime,
            startTime: approvals.currentStartTime,
            endTime: approvals.currentEndTime,
          ),
        ),
      ),
    );
  }

  /// The document card once its author and department are loaded.
  Widget _buildLoadedCard(
    BuildContext context,
    CreateKnowledgeModel approvals,
    Map<String, dynamic> data,
  ) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final String rawDepartmentName = data['departmentName'] as String? ?? '';
    final String departmentName = rawDepartmentName.isEmpty
        ? S.of(context).khUnknownDepartment
        : rawDepartmentName;
    final creatorData = data['creatorData'] as EmployeeData?;
    _debugEmployeeData(creatorData);

    return approvalsDocumentCard(
      context,
      status: approvals.currentStatus,
      statusColor: _getStatusColor(approvals.currentStatus),
      fileExtension: approvals.currentDocumentExtension,
      fileImage: approvals.currentImageUrl.isNotEmpty
          ? approvals.currentImageUrl
          : null,
      fileName: FormatHelper.capitalize(_getLocalizedName(approvals)),
      department: _getLocalizedDepartmentName(departmentName),
      requestedBy: FormatHelper.capitalize(
        _getLocalizedEmployeeNameExplicit(creatorData),
      ),
      jobTitle: _getLocalizedJobTitle(creatorData),
      uploadDate: _getTimestampDate(approvals.currentTimestamp),
      lastEditDate: _getTimestampDate(approvals.currentTimestamp),
      onApprove: () => _showApproveConfirmationDialog(
        context,
        approvals.currentKnowledgeId,
        isMobile,
        lightMode,
      ),
      onReject: () => _showRejectConfirmationDialog(
        context,
        approvals.currentKnowledgeId,
        isMobile,
        lightMode,
      ),
    );
  }
}
