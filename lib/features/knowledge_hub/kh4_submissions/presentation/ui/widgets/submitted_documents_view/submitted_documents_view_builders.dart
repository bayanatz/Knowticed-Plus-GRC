/// Module: knowledge_hub/kh4_submissions/presentation/ui/widgets/submitted_documents_view
///
///*************************** FILE INFO ****************************///
/// File Name: submitted_documents_view_builders.dart
/// Description: UI builder methods of `_SubmittedDocumentsViewState` — split out of `submitted_documents_view.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../submitted_documents_view.dart';

// Split from submitted_documents_view.dart to keep every file under 700 lines.

extension _SubmittedDocumentsViewStateBuilders on _SubmittedDocumentsViewState {
  Widget _buildSubmissionsGrid(BuildContext context, bool isMobile) {
    final bool isPhone = ContextExtension(context).isPhone;
    final submissions = context.read<SubmissionsCubit>().filteredKnowledge;

    if (submissions.isEmpty) {
      return _buildNoFilterResultsState(context);
    }

    // CREATE ANIMATIONS IF NOT CREATED
    if (!_animationsCreated || _slideAnimations.length != submissions.length) {
      _createSlideAnimations(submissions.length);
      // Play animation after creation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playGridAnimation();
      });
    }

    // The grid lays out at its full height and lets the page do all the
    // scrolling (a fixed-height inner grid swallowed the drag).
    return SizedBox(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20.sp),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
          // 11/10/2026 — the Figma card is 80 tall; a few sp of slack so a
          // larger text scale doesn't clip the date row.
          mainAxisExtent: isPhone ? 84.sp : 86.sp,
          crossAxisSpacing: 10.sp,
          mainAxisSpacing: 10.sp,
        ),
        itemCount: submissions.length,
        itemBuilder: (context, index) =>
            _buildAnimatedSubmissionCell(context, submissions[index], index),
      ),
    );
  }

  /// One grid cell, sliding and fading in with the grid animation.
  Widget _buildAnimatedSubmissionCell(
    BuildContext context,
    CreateKnowledgeModel submission,
    int index,
  ) {
    return SlideTransition(
      position: _slideAnimations.length > index
          ? _slideAnimations[index]
          : AlwaysStoppedAnimation(Offset.zero),
      child: FadeTransition(
        opacity: _fadeAnimations.length > index
            ? _fadeAnimations[index]
            : AlwaysStoppedAnimation(1.0),
        child: GestureDetector(
          onTap: () {
            HapticController.low(); // list row: on the tap (X-117)
            _openSubmissionDetails(context, submission);
          },
          child: _buildSubmissionCard(context, submission),
        ),
      ),
    );
  }

  /// Opens the details screen of [submission], with its own cubit and the
  /// file picker its comment box uses injected at the route.
  void _openSubmissionDetails(
    BuildContext context,
    CreateKnowledgeModel submission,
  ) {
    khLog(submission.currentKnowledgeId, name: 'SUBMISSION_TAP');
    final DateTime? uploadDate = _getTimestampDate(submission.timestamps.first);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepositoryProvider<MediaPickerService>.value(
          value: KnowledgeHubDI.mediaPicker,
          child: BlocProvider(
            create: (context) => KnowledgeHubDI.submissionsCubit(),
            child: SubmissionDetailsScreen(
              createdBy: submission.currentCreatedByEmail,
              statusHistory: submission.status,
              documentNameAr: submission.currentNameArabic,
              documentName: submission.currentNameEnglish,
              documentEnglishDescription: submission.currentDescriptionEnglish,
              documentEnglishDescriptionAr: submission.currentDescriptionArabic,
              documentExtension: submission.currentDocumentExtension,
              documentType: submission.currentKnowledgeDocumentType,
              fileType: submission.currentKnowledgeDocumentType,
              fileUrl: submission.currentDocumentUrl,
              knowledgeId: submission.currentKnowledgeId,
              owningDepartment: submission.currentOwningDepartment,
              submissionDate: uploadDate != null
                  ? KhLocale.formatDate(context, uploadDate, 'dd MMM yyyy')
                  : S.of(context).notAvailable,
              currentStatus: submission.currentStatus,
              limitedDepartments: submission.currentLimitedDepartmentsList,
              startDate: _firstOrSelf(submission.startDateTime),
              endDate: _firstOrSelf(submission.endDateTime),
              startTime: submission.currentStartTime,
              endTime: submission.currentEndTime,
            ),
          ),
        ),
      ),
    );
  }

  /// REDESIGNED 11/10/2026 — Figma "MESBAH" node 5291:25967.
  ///   ┌──────────────────────────────── Status: Archive ┐
  ///   │ [icon]  Title (12 medium)                       │
  ///   │ 40×45   Owning Department: Marketing (10)       │
  ///   │         Publish Date: …          End Date: …    │
  ///   └─────────────────────────────────────────────────┘
  /// The status sits on its OWN line above the title (pinned to the end), so
  /// a long title can never run under it.
  Widget _buildSubmissionCard(
    BuildContext context,
    CreateKnowledgeModel submission,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: AppColors.card,
      ),
      // Figma geometry: icon at (10, 15), text column at x=60 starting y=20,
      // status centred at y=13, card 80 tall.
      padding: EdgeInsetsDirectional.fromSTEB(10.sp, 15.sp, 10.sp, 8.sp),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            top: -6.sp,
            end: 0,
            child: _buildCardStatus(context, submission.currentStatus),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardThumbnail(submission),
              SizedBox(width: 10.sp),
              Expanded(child: _buildCardTexts(context, submission)),
            ],
          ),
        ],
      ),
    );
  }
}

/// The first entry of a stored list field, or the value itself.
dynamic _firstOrSelf(dynamic value) =>
    (value is List && value.isNotEmpty) ? value.first : value;

/// "Status: <status>" in the top-end corner of the card, 8 regular.
Widget _buildCardStatus(BuildContext context, String status) {
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 140.sp),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "${S.of(context).status}: ",
            style: StyleText.fontSize8Weight400.copyWith(
              height: 1,
              color: AppColors.secondaryText,
            ),
          ),
          TextSpan(
            text: _getStatusDisplay(context, status),
            style: StyleText.fontSize8Weight400.copyWith(
              height: 1,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

/// File icon (40×45) — or the cover image with the file badge on it, when
/// the document has one.
Widget _buildCardThumbnail(CreateKnowledgeModel submission) {
  final String fileIcon = getFileIcon(submission.currentDocumentExtension);
  return SizedBox(
    width: 40.sp,
    height: 45.sp,
    child: submission.currentImageUrl.isNotEmpty
        ? Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: Image.network(
                    submission.currentImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: 2.sp,
                end: 2.sp,
                child: CustomSvgImage(
                  assetPath: fileIcon,
                  height: 20.sp,
                  width: 18.sp,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          )
        : CustomSvgImage(
            assetPath: fileIcon,
            width: 40.sp,
            height: 45.sp,
            fit: BoxFit.contain,
          ),
  );
}

/// Title, owning department and the two dates of the card.
Widget _buildCardTexts(BuildContext context, CreateKnowledgeModel submission) {
  final bool lightMode = Theme.of(context).brightness == Brightness.light;
  final String owning = submission.currentOwningDepartment;
  final String departmentName = owning.isEmpty
      ? S.of(context).notAvailable
      : KhLocale.department(context, owning);
  final dateInfo = _getDateInfoByStatus(
    context,
    submission.currentStatus,
    _getTimestampDate(submission.timestamps.first),
    _getTimestampDate(submission.timestamps.last),
    _firstOrSelf(submission.startDateTime),
    _firstOrSelf(submission.endDateTime),
  );
  String formatDate(DateTime? date) => date == null
      ? S.of(context).notAvailable
      : KhLocale.formatDate(context, date, 'dd MMM yyyy');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(height: 5.sp), // title at y=20
      Text(
        KhLocale.pick(
          context,
          en: submission.currentNameEnglish,
          ar: submission.currentNameArabic,
        ),
        style: StyleText.fontSize12Weight500.copyWith(
          height: 1,
          color: AppColors.blackButton,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: 10.sp),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "${S.of(context).owning_department}: ",
              style: StyleText.fontSize10Weight500.copyWith(
                height: 1,
                color: AppColors.secondaryText,
              ),
            ),
            TextSpan(
              text: departmentName,
              style: StyleText.fontSize10Weight500.copyWith(
                height: 1,
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: 10.sp),
      // Each date may use up to half the row; the free space between them
      // comes from spaceBetween.
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: _cardDate(
              label: FormatHelper.capitalize("${dateInfo['firstLabel']} "),
              value: formatDate(dateInfo['firstDate']),
              lightMode: lightMode,
            ),
          ),
          if (dateInfo['secondLabel'] != null) ...[
            SizedBox(width: 8.sp),
            Flexible(
              child: _cardDate(
                label: "${dateInfo['secondLabel']}",
                value: formatDate(dateInfo['secondDate']),
                lightMode: lightMode,
              ),
            ),
          ],
        ],
      ),
    ],
  );
}

/// One "Label: value" date on the submission card — label in the muted
/// colour, value in the text colour, both 8 regular (Figma 5291:25967).
Widget _cardDate({
  required String label,
  required String value,
  required bool lightMode,
}) {
  // The labels arrive inconsistently ("Publish Date", "Rejected Date: : ",
  // "End Date: "…). Strip any trailing colons/spaces and add exactly one ": ",
  // so every date reads "Label: value".
  final String cleanLabel = '${label.replaceAll(RegExp(r'[\s:：]+$'), '')}: ';
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: cleanLabel,
          style: StyleText.fontSize8Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        TextSpan(
          text: value,
          style: StyleText.fontSize8Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      ],
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
