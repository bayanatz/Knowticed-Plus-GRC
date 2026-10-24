// ****************** FILE INFO ******************
// File Name: crm_merge_history_details_page.dart
// Purpose: Responsive merge-history details page matching the approved mobile UI.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/dialogs/confirm_dialog.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_cubit.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_state.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmMergeHistoryDetailsPage extends StatefulWidget {
  final CrmMergeHistoryModel history;

  const CrmMergeHistoryDetailsPage({
    super.key,
    required this.history,
  });

  @override
  State<CrmMergeHistoryDetailsPage> createState() =>
      _CrmMergeHistoryDetailsPageState();
}

class _CrmMergeHistoryDetailsPageState
    extends State<CrmMergeHistoryDetailsPage> {
  late bool _isUndone;

  @override
  void initState() {
    super.initState();
    _isUndone = widget.history.isRolledBack;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmClients,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Duplicates Review & Merge',
          arabicName: 'مراجعة ودمج المكررات',
        ),
        thirdTitle: widget.history.masterClientName,
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: BlocBuilder<CrmDuplicatesCubit, CrmDuplicatesState>(
          builder: (BuildContext context, CrmDuplicatesState state) {
            final CrmMergeHistoryDetailsData details =
                state.mergeHistoryDetailsFor(widget.history);
            final CrmUndoAvailability undoAvailability =
                state.undoAvailabilityFor(widget.history);

            final Widget content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildSections(context, details),
                if (undoAvailability.isAvailable) ...<Widget>[
                  SizedBox(height: context.isPhone ? 160.sp : 32.sp),
                  _buildUndoBanner(
                    context,
                    undoAvailability,
                    state.undoExpiryLabel(undoAvailability),
                  ),
                  SizedBox(height: 16.sp),
                ],
              ],
            );

            if (context.isPhone) return content;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: content,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSections(
    BuildContext context,
    CrmMergeHistoryDetailsData details,
  ) {
    final Widget detailsSection = CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Merge Details',
        arabicName: 'تفاصيل الدمج',
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
      child: _buildMergeDetails(details),
    );
    final Widget summarySection = CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Merge Summary',
        arabicName: 'ملخص الدمج',
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      child: _buildMergeSummary(details),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (context.isPhone) ...<Widget>[
          detailsSection,
          SizedBox(height: 16.sp),
          summarySection,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: detailsSection),
              SizedBox(width: 16.sp),
              Expanded(child: summarySection),
            ],
          ),
        SizedBox(height: 16.sp),
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Merge Preview',
            arabicName: 'معاينة الدمج',
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
          child: _buildMergePreview(details.preview),
        ),
      ],
    );
  }

  Widget _buildMergeDetails(CrmMergeHistoryDetailsData details) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              FormatHelper.localizedString(
                englishName: 'By',
                arabicName: 'بواسطة',
              ),
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(width: 12.sp),
            Container(
              width: 26.sp,
              height: 26.sp,
              decoration: const BoxDecoration(
                color: AppColors.disabledGrey,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmPerson,
                width: 16.sp,
                height: 16.sp,
                color: AppColors.text,
              ),
            ),
            SizedBox(width: 10.sp),
            Expanded(
              child: Text(
                widget.history.mergedBy,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize14Weight500,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.sp),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildInlineValue(
                label: S.current.date,
                value: details.dateLabel,
              ),
            ),
            SizedBox(width: 16.sp),
            Expanded(
              child: _buildInlineValue(
                label: S.current.time,
                value: details.timeLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInlineValue({
    required String label,
    required String value,
  }) {
    return Row(
      children: <Widget>[
        Text(
          '$label:',
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
        SizedBox(width: 8.sp),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize14Weight500,
          ),
        ),
      ],
    );
  }

  Widget _buildMergeSummary(CrmMergeHistoryDetailsData details) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildSummaryItem(
            label: FormatHelper.localizedString(
              englishName: 'Fields Updated',
              arabicName: 'الحقول المحدثة',
            ),
            value: details.fieldsUpdatedCount,
          ),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          child: _buildSummaryItem(
            label: FormatHelper.localizedString(
              englishName: 'New Values',
              arabicName: 'قيم جديدة',
            ),
            value: details.newValuesCount,
          ),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          child: _buildSummaryItem(
            label: FormatHelper.localizedString(
              englishName: 'Unchanged',
              arabicName: 'بدون تغيير',
            ),
            value: details.unchangedCount,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({required String label, required int value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ),
        SizedBox(width: 6.sp),
        Text(value.toString(), style: StyleText.fontSize14Weight500),
      ],
    );
  }

  Widget _buildMergePreview(CrmMergePreviewData preview) {
    return Column(
      children: <Widget>[
        _buildPreviewRow(
          label: FormatHelper.localizedString(
            englishName: 'Full Name',
            arabicName: 'الاسم الكامل',
          ),
          value: preview.fullName,
        ),
        SizedBox(height: 16.sp),
        _buildPreviewRow(label: S.current.crmPhone, value: preview.phone),
        SizedBox(height: 16.sp),
        _buildPreviewRow(label: S.current.crmEmail, value: preview.email),
        SizedBox(height: 16.sp),
        _buildPreviewRow(label: S.current.jobTitle, value: preview.jobTitle),
      ],
    );
  }

  Widget _buildPreviewRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 88.sp,
          child: Text(
            label,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ),
        SizedBox(width: 12.sp),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize14Weight500,
          ),
        ),
      ],
    );
  }

  Widget _buildUndoBanner(
    BuildContext context,
    CrmUndoAvailability availability,
    String expiryLabel,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Row(
        children: <Widget>[
          CustomSvgImage(
            assetPath: AppAssets.crmUndo,
            width: 24.sp,
            height: 24.sp,
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  FormatHelper.localizedString(
                    englishName: 'Undo Available',
                    arabicName: 'التراجع متاح',
                  ),
                  style: StyleText.fontSize12Weight500,
                ),
                SizedBox(height: 2.sp),
                Text(
                  FormatHelper.localizedString(
                    englishName: 'You can undo this merge until $expiryLabel',
                    arabicName: 'يمكنك التراجع عن هذا الدمج حتى $expiryLabel',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.sp),
          customButton(
            title: FormatHelper.localizedString(
              englishName: 'Undo',
              arabicName: 'تراجع',
            ),
            width: 72.sp,
            color: _isUndone ? AppColors.disabledGrey : AppColors.primary,
            textColor: AppColors.text,
            textStyle: StyleText.fontSize12Weight500,
            function: _isUndone
                ? () {}
                : () => _showUndoConfirmationDialog(context, availability),
          ),
        ],
      ),
    );
  }

  void _showUndoConfirmationDialog(
    BuildContext context,
    CrmUndoAvailability availability,
  ) {
    ConfirmDialog().show(
      context,
      title: FormatHelper.localizedString(
        englishName: 'Undo Merge',
        arabicName: 'التراجع عن الدمج',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Are you sure you want to undo this merge?',
        arabicName: 'هل أنت متأكد من التراجع عن هذا الدمج؟',
      ),
      icon: AppAssets.crmUndo,
      onCancel: () {},
      onCancelText: S.current.cancel,
      onConfirmText: FormatHelper.localizedString(
        englishName: 'Undo',
        arabicName: 'تراجع',
      ),
      onConfirm: () => _undoMerge(context, availability),
    );
  }

  Future<void> _undoMerge(
    BuildContext context,
    CrmUndoAvailability availability,
  ) async {
    if (!availability.isAvailable || _isUndone) return;
    final bool succeeded = await context
        .read<CrmDuplicatesCubit>()
        .rollbackMerge(widget.history.id);
    if (!mounted || !context.mounted) return;
    if (succeeded) {
      setState(() => _isUndone = true);
      return;
    }
    await CrmControlDialogs.showErrorDialog(
      context: context,
      title: S.current.error,
      subtitle: FormatHelper.localizedString(
        englishName: 'Unable to undo this merge. Please try again.',
        arabicName: 'تعذر التراجع عن هذا الدمج. يرجى المحاولة مرة أخرى.',
      ),
    );
  }
}
