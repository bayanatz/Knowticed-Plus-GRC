/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/submission_details_contents
///
///*************************** FILE INFO ****************************///
/// File Name: published_content.info_card.dart
/// Description: `_buildDocumentInfoCard()`, `_buildInfoRow()` — split out of `published_content.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'published_content.dart';

/// Document info card, info rows, status button + error dialog (split from published_content.dart, §7).

Widget _buildDocumentInfoCard(
  BuildContext context, {
  required String publishDate,
  required String documentName,
  required String documentNameAr,
  required String documentType,
  required String owningDepartment,
  required String documentDescription,
  required String documentExtension,
  required bool isMobile,
  required String currentStatus,
  required bool lightMode,
  required String knowledgeId,
  List<String>? limitedDepartments,
  required List<String>? statusHistory,
  String? startDate,
  String? endDate,
  String? startTime,
  String? endTime,
  required String createdBy,
}) {
  final _InfoCardDates dates = _InfoCardDates(
    startDate: startDate,
    endDate: endDate,
    startTime: startTime,
    endTime: endTime,
  );
  return Stack(
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.card,
        ),
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSubmittedDocumentHeader(
              context,
              documentName: documentName,
              documentDescription: documentDescription,
              documentExtension: documentExtension,
              isMobile: isMobile,
              lightMode: lightMode,
            ),
            SizedBox(height: 15.h),
            if (isMobile)
              ..._buildInfoRowsMobile(
                context,
                documentDescription: documentDescription,
                documentType: documentType,
                owningDepartment: owningDepartment,
                dates: dates,
                lightMode: lightMode,
              )
            else
              _buildInfoRowsWide(
                context,
                documentType: documentType,
                owningDepartment: owningDepartment,
                dates: dates,
                lightMode: lightMode,
              ),
            SizedBox(height: 15.h),
            if (limitedDepartments != null && limitedDepartments.isNotEmpty)
              _buildLimitedDepartments(context, limitedDepartments),
            ..._buildStatusReasons(context, currentStatus, knowledgeId),
            _buildStatusRow(
              context,
              knowledgeId: knowledgeId,
              currentStatus: currentStatus,
              isMobile: isMobile,
              lightMode: lightMode,
              documentName: documentName,
              documentNameAr: documentNameAr,
            ),
          ],
        ),
      ),
      PositionedDirectional(
        end: 8.w,
        top: 8.h,
        child: buildSubmissionDate(context, submissionDate: publishDate),
      ),
    ],
  );
}

/// The approval justification, removal reason or rejection row that goes
/// with [currentStatus].
List<Widget> _buildStatusReasons(
  BuildContext context,
  String currentStatus,
  String knowledgeId,
) {
  final SubmissionsCubit cubit = context.read<SubmissionsCubit>();
  return [
    if (currentStatus == 'approved' || currentStatus == 'published')
      _buildReasonFromCubit(
        context,
        reason: cubit.getApprovalReason(knowledgeId),
        label: S.of(context).approvalJustification,
        color: AppColors.green,
      ),
    if (currentStatus == 'removed')
      _buildReasonFromCubit(
        context,
        reason: cubit.getRemovalReason(knowledgeId),
        label: S.of(context).reasonOfRemoving,
        color: AppColors.darkRed,
      ),
    if (currentStatus == 'rejected') ...[
      _buildRejectionRow(context),
      SizedBox(height: 15.h),
    ],
  ];
}

/// The scheduled start / end of the document, as stored.
class _InfoCardDates {
  const _InfoCardDates({
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
}

/// Status label, colour and icon for the status button.
Map<String, dynamic> _statusInfo(BuildContext context, String status) {
  Widget icon(String asset, {double? size}) => CustomSvgImage(
        assetPath: asset,
        height: size ?? 20.sp,
        width: size ?? 20.sp,
        fit: BoxFit.cover,
      );
  switch (status) {
    case 'rejected':
      return {
        'text': S.of(context).rejected,
        'color': AppColors.red,
        'widget': SizedBox(
          width: 15.w,
          height: 15.h,
          child: CustomSvgImage(
            assetPath:
                'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg',
            height: 20.h,
            width: 20.w,
            fit: BoxFit.cover,
          ),
        ),
      };
    case 'pending_approval':
    case 'scheduled':
      return {
        'text': S.of(context).pending,
        'color': AppColors.orange,
        'widget': Container(
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: CustomSvgImage(
            assetPath:
                'assets/icons_assets/main_icons_assets/ic_status_pending.svg',
            height: 20.h,
            width: 20.w,
            fit: BoxFit.cover,
          ),
        ),
      };
    case 'published':
      return {
        'text': S.of(context).published,
        'color': AppColors.green,
        'widget': icon(
          'assets/icons_assets/main_icons_assets/ic_status_published.svg',
        ),
      };
    case 'approved':
      return {
        'text': S.of(context).approved,
        'color': AppColors.lightGreen,
        'widget': icon(
          'assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg',
        ),
      };
    case 'archived':
      return {
        'text': S.of(context).archive,
        'color': AppColors.secondaryBlack,
        'widget': icon(
          'assets/icons_assets/knowledge_hub_assets/ic_status_archived.svg',
        ),
      };
    case 'removed':
      return {
        'text': S.of(context).removed,
        'color': AppColors.darkRed,
        'widget': icon(
          'assets/icons_assets/main_icons_assets/ic_status_document_removed.svg',
        ),
      };
    default:
      return {
        'text': status,
        'color': AppColors.primary,
        'widget': Icon(Icons.info, color: AppColors.colorWhite, size: 20.sp),
      };
  }
}

/// Phone layout: description, then one info row per line.
List<Widget> _buildInfoRowsMobile(
  BuildContext context, {
  required String documentDescription,
  required String documentType,
  required String owningDepartment,
  required _InfoCardDates dates,
  required bool lightMode,
}) {
  final S s = S.of(context);
  final String? startDate = dates.startDate;
  final String? endDate = dates.endDate;
  return [
    // 14/10/2026 — KH mobile report p.11/p.19 "Add document description":
    // the text has its "Document Description:" heading, as on the hub.
    Row(
      children: [
        CustomSvgImage(
          assetPath:
              'assets/icons_assets/knowledge_hub_assets/ic_file_description_light.svg',
          fit: BoxFit.fill,
          width: 16.w,
          height: 16.h,
        ),
        SizedBox(width: 5.w),
        Text(
          '${s.document_description}:',
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    ),
    SizedBox(height: 8.h),
    Text(
      documentDescription,
      style: StyleText.fontSize12Weight400.copyWith(
        color: lightMode ? AppColors.secondaryText : AppColors.white,
      ),
    ),
    SizedBox(height: 15.h),
    _buildInfoRow(
      context,
      iconPath: 'assets/icons_assets/knowledge_hub_assets/ic_file_type.svg',
      label: '${s.document_type}: ',
      value: documentType,
      lightMode: lightMode,
    ),
    SizedBox(height: 15.h),
    _buildInfoRow(
      context,
      iconPath:
          'assets/icons_assets/main_icons_assets/ic_org_department_owner.svg',
      label: "${s.owning_department}: ",
      value: owningDepartment,
      lightMode: lightMode,
    ),
    if (startDate != null && startDate.isNotEmpty) ...[
      SizedBox(height: 15.h),
      _buildInfoRow(
        context,
        iconPath: 'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
        label: '${s.start_date}: ',
        value: _dateAtTime(context, startDate, dates.startTime),
        lightMode: lightMode,
      ),
    ],
    if (endDate != null && endDate.isNotEmpty) ...[
      SizedBox(height: 15.h),
      _buildInfoRow(
        context,
        iconPath: 'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
        label: '${s.end_date}: ',
        value: _dateAtTime(context, endDate, dates.endTime),
        lightMode: lightMode,
      ),
    ],
  ];
}

/// Tablet / desktop layout: two columns of info rows.
Widget _buildInfoRowsWide(
  BuildContext context, {
  required String documentType,
  required String owningDepartment,
  required _InfoCardDates dates,
  required bool lightMode,
}) {
  final S s = S.of(context);
  final String? startDate = dates.startDate;
  final String? endDate = dates.endDate;
  return Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            iconPath:
                'assets/icons_assets/knowledge_hub_assets/ic_file_type.svg',
            label: '${s.document_type}: ',
            value: documentType,
            lightMode: lightMode,
          ),
          SizedBox(height: 15.h),
          _buildInfoRow(
            context,
            iconPath:
                'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
            label: '${s.start_date}: ',
            value: startDate == null
                ? "-"
                : _dateAtTime(context, startDate, dates.startTime),
            lightMode: lightMode,
          ),
        ],
      ),
      SizedBox(width: 50.w),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            iconPath:
                'assets/icons_assets/main_icons_assets/ic_org_department_owner.svg',
            label: "${s.owning_department}: ",
            value: owningDepartment,
            lightMode: lightMode,
          ),
          SizedBox(height: 15.h),
          _buildInfoRow(
            context,
            iconPath:
                'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
            label: '${s.end_date}: ',
            value: endDate == null
                ? "-"
                : _dateAtTime(context, endDate, dates.endTime),
            lightMode: lightMode,
          ),
        ],
      ),
    ],
  );
}

/// LIMITED DEPARTMENTS SECTION
Widget _buildLimitedDepartments(
  BuildContext context,
  List<String> limitedDepartments,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CustomSvgImage(
            assetPath:
                'assets/icons_assets/knowledge_hub_assets/ic_org_department_limited.svg',
            fit: BoxFit.cover,
          ),
          SizedBox(width: 5.w),
          Text(
            '${S.of(context).limitedDepartmentAvailability}:',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
      SizedBox(height: 8.h),
      Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: limitedDepartments.map((department) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              KhLocale.department(context, department),
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          );
        }).toList(),
      ),
      SizedBox(height: 15.h),
    ],
  );
}

/// The approval justification or the removal reason, loaded by the cubit.
/// Shows nothing while there is no reason.
Widget _buildReasonFromCubit(
  BuildContext context, {
  required Future<String?> reason,
  required String label,
  required Color color,
}) {
  return FutureBuilder<String?>(
    future: reason,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return SizedBox(
          height: 20.h,
          child: Center(
            child: SizedBox(
              width: 16.w,
              height: 16.h,
              child: CircleProgressMaster(),
            ),
          ),
        );
      }
      final String? text = snapshot.data;
      if (text == null || text.isEmpty) return SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_status.svg',
                fit: BoxFit.cover,
                width: 16.w,
                height: 16.h,
                color: color,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label: ',
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: color,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
        ],
      );
    },
  );
}

/// REJECTION REASON
Widget _buildRejectionRow(BuildContext context) {
  return Row(
    children: [
      CustomSvgImage(
        assetPath: 'assets/icons_assets/main_icons_assets/ic_status.svg',
        fit: BoxFit.fill,
        color: AppColors.red,
      ),
      SizedBox(width: 5.w),
      Text(
        '${S.of(context).reasonOfRejection}: ',
        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
      ),
      Text(
        S.of(context).reasonOfRejection,
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.blackButton,
        ),
      ),
    ],
  );
}

/// STATUS BUTTON AND SEND REMINDER
Widget _buildStatusRow(
  BuildContext context, {
  required String knowledgeId,
  required String currentStatus,
  required bool isMobile,
  required bool lightMode,
  required String documentName,
  required String documentNameAr,
}) {
  final Map<String, dynamic> statusInfo = _statusInfo(context, currentStatus);
  final bool isPending =
      currentStatus == 'pending_approval' || currentStatus == 'scheduled';
  return Row(
    mainAxisAlignment: isMobile
        ? MainAxisAlignment.center
        : (isPending ? MainAxisAlignment.start : MainAxisAlignment.end),
    children: [
      if (isPending) ...[
        _buildSendReminderButton(
          context,
          isMobile: isMobile,
          knowledgeId: knowledgeId,
          documentName: documentName,
          documentNameAr: documentNameAr,
        ),
        Spacer(),
        _buildStatusButton(
          statusInfo: statusInfo,
          width: isMobile ? 140.w : 185.w,
          lightMode: lightMode,
        ),
      ] else
        _buildStatusButton(
          statusInfo: statusInfo,
          width: isMobile ? ScreenUtil().screenWidth - 80.w : 200.w,
          lightMode: lightMode,
        ),
    ],
  );
}

/// KH-SUBMIT-04: reminds the author's supervisor and says whether that
/// worked.
Widget _buildSendReminderButton(
  BuildContext context, {
  required bool isMobile,
  required String knowledgeId,
  required String documentName,
  required String documentNameAr,
}) {
  return GestureDetector(
    onTapDown: (_) => HapticController.medium(),
    onTap: () async {
      final bool sent =
          await context.read<SubmissionsCubit>().sendReviewReminder(
                knowledgeId: knowledgeId,
                documentNameEn: documentName,
                documentNameAr: documentNameAr,
              );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sent ? S.of(context).reminderSent : S.of(context).reminderFailed,
          ),
        ),
      );
    },
    child: Container(
      height: 36.sp,
      width: isMobile ? 150.w : 185.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_time_reminder_bell.svg',
              fit: BoxFit.cover,
              width: 20.w,
              height: 20.h,
              color: AppColors.textButton,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            S.of(context).sendReminder,
            style: StyleText.fontSize13Weight500.copyWith(
              color: AppColors.textButton,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildInfoRow(
  BuildContext context, {
  required String iconPath,
  required String label,
  required String value,
  required bool lightMode,
}) {
  return Row(
    children: [
      CustomSvgImage(
        width: 16.w,
        height: 16.h,
        assetPath: iconPath,
        fit: BoxFit.fill,
      ),
      SizedBox(width: 5.w),
      Text(
        label,
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      Text(
        value,
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.blackButton,
        ),
      ),
    ],
  );
}

/// "[date] at [time]" in the UI language, or just [date] without a time.
String _dateAtTime(BuildContext context, String date, String? time) =>
    (time == null || time.isEmpty)
        ? date
        : S.of(context).khDateAtTime(date, time);
