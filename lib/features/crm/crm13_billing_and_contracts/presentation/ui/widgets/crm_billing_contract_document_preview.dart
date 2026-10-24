// ****************** FILE INFO ******************
// File Name: crm_billing_contract_document_preview.dart
// Purpose: Presentational document preview for Billing and Contract controls
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';

class CrmBillingContractDocumentPreview extends StatelessWidget {
  final CrmBillingContractModel item;

  const CrmBillingContractDocumentPreview({
    super.key,
    required this.item,
  });

  bool get _isContract => item.id == CrmBillingContractModel.contractControlId;

  @override
  Widget build(BuildContext context) {
    final List<CrmBilingualNoteModel> nonEmptySections = item.contractSections
        .where((section) =>
            section.textEn.trim().isNotEmpty ||
            section.textAr.trim().isNotEmpty)
        .toList();
    final List<CrmBilingualNoteModel> nonEmptyNotes = item.notes
        .where((note) =>
            note.textEn.trim().isNotEmpty || note.textAr.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 56.sp, vertical: 48.sp),
      color: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          SizedBox(height: 42.sp),
          if (_isContract) ...<Widget>[
            _buildBilingualBlock(
              title: 'Contract body',
              englishText: item.contractTerms,
              arabicText: item.contractTermsAr,
            ),
            if (nonEmptySections.isNotEmpty) ...<Widget>[
              SizedBox(height: 28.sp),
              _buildListBlock('Sections', nonEmptySections),
            ],
          ] else
            _buildBilingualBlock(
              title: 'Billing message',
              englishText: item.messageEn,
              arabicText: item.messageAr,
            ),
          if (_isContract) ...<Widget>[
            SizedBox(height: 28.sp),
            _buildBilingualBlock(
              title: 'Message',
              englishText: item.messageEn,
              arabicText: item.messageAr,
            ),
          ],
          if (nonEmptyNotes.isNotEmpty) ...<Widget>[
            SizedBox(height: 28.sp),
            _buildListBlock('Notes', nonEmptyNotes),
          ],
          SizedBox(height: 72.sp),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              _isContract
                  ? 'THANK YOU FOR YOUR TRUST'
                  : 'THANK YOU FOR USING OUR SERVICES',
              style: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            _isContract ? 'CONTRACT' : 'BILLING',
            style: StyleText.fontSize24Weight600.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              'REFERENCE',
              style: StyleText.fontSize12Weight600.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 6.sp),
            Text(
              item.code,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBilingualBlock({
    required String title,
    required String englishText,
    required String arabicText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title.toUpperCase(),
          style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.sp),
        if (englishText.trim().isNotEmpty)
          Text(
            englishText,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        if (englishText.trim().isNotEmpty && arabicText.trim().isNotEmpty)
          SizedBox(height: 12.sp),
        if (arabicText.trim().isNotEmpty)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                arabicText,
                textAlign: TextAlign.right,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        if (englishText.trim().isEmpty && arabicText.trim().isEmpty)
          Text(
            '—',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
      ],
    );
  }

  Widget _buildListBlock(
    String title,
    List<CrmBilingualNoteModel> values,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title.toUpperCase(),
          style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.sp),
        ...values.map(
          (value) => Padding(
            padding: EdgeInsets.only(bottom: 10.sp),
            child: _buildBilingualValue(value),
          ),
        ),
      ],
    );
  }

  Widget _buildBilingualValue(CrmBilingualNoteModel value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            value.textEn,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
        SizedBox(width: 20.sp),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              value.textAr,
              textAlign: TextAlign.right,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
