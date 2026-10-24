// ****************** FILE INFO ******************
// File Name: crm_billing_contract_details_page.dart
// Purpose: Details / View page for CRM Billing & Contract template matching Figma design
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/presentation/ui/widgets/crm_billing_color_tile.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/presentation/ui/widgets/crm_billing_files_section.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmBillingContractDetailsPage extends StatefulWidget {
  final CrmBillingContractModel item;

  const CrmBillingContractDetailsPage({
    super.key,
    required this.item,
  });

  @override
  State<CrmBillingContractDetailsPage> createState() =>
      _CrmBillingContractDetailsPageState();
}

class _CrmBillingContractDetailsPageState
    extends State<CrmBillingContractDetailsPage> {
  late CrmBillingContractModel _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  Future<void> _onEdit([String? initialUploadField]) async {
    final dynamic result =
        await CrmNavigationHelper.navigateToControlBillingContractForm(
      context,
      arguments: <String, dynamic>{
        'item': _currentItem,
        'mode': 'edit',
        if (initialUploadField != null)
          'initialUploadField': initialUploadField,
      },
    );

    if (!mounted || result is! Map<String, dynamic>) return;
    final String action = (result['action'] ?? '').toString();

    if (action == 'save') {
      final CrmBillingContractModel? updated =
          result['item'] as CrmBillingContractModel?;
      if (updated != null) {
        setState(() => _currentItem = updated);
        CrmNavigationHelper.pop(
          context,
          <String, dynamic>{'action': 'save', 'item': updated},
        );
      }
    }
  }

  Color _parseHex(String hex, Color fallback) {
    try {
      final String cleanHex = hex.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        return Color(int.parse('0xFF$cleanHex'));
      } else if (cleanHex.length == 8) {
        return Color(int.parse('0x$cleanHex'));
      }
    } catch (_) {
      return fallback;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final bool isBilling =
        _currentItem.id == CrmBillingContractModel.billingControlId;
    final String pageTitle = isBilling ? S.current.crmBilling : 'Contract';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlBillingAndContracts,
        fourthTitle: pageTitle,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Bar with Edit button (Icon only on mobile)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomEditIcon(
                    onTap: _onEdit,
                  ),
                ],
              ),
              SizedBox(height: 16.sp),

              // Section 1: Files
              CrmBillingFilesSection(
                logoUrl: _currentItem.logoUrl,
                digitalSealUrl: _currentItem.digitalSealUrl,
                watermarkUrl: _currentItem.watermarkUrl,
                signatureUrl: _currentItem.signatureUrl,
                onLogoUpload: () => _onEdit(CrmBillingContractModel.LOGO_URL),
                onDigitalSealUpload: () =>
                    _onEdit(CrmBillingContractModel.DIGITAL_SEAL_URL),
                onWatermarkUpload: () =>
                    _onEdit(CrmBillingContractModel.WATERMARK_URL),
                onSignatureUpload: () =>
                    _onEdit(CrmBillingContractModel.SIGNATURE_URL),
              ),
              SizedBox(height: 16.sp),

              if (!isBilling) ...<Widget>[
                _buildContractBodySection(),
                SizedBox(height: 16.sp),
                _buildContractSectionsSection(),
                SizedBox(height: 16.sp),
              ],

              _buildMessageSection(),
              SizedBox(height: 16.sp),

              // Section 3: Notes (Collapsible)
              _buildNotesSection(),
              SizedBox(height: 16.sp),

              // Section 4: Colors (Collapsible)
              _buildColorsSection(),
              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageSection() {
    return CrmSectionCard(
      title: S.current.crmMessage,
      showHideToggle: true,
      child: Column(
        children: <Widget>[
          CustomTextField(
            initialValue: _currentItem.messageEn,
            label: 'Message',
            hint: 'Description',
            readOnly: true,
            maxLines: 4,
            height: 104.sp,
            maxLength: 500,
            showCharCount: true,
            textDirection: TextDirection.ltr,
            fillColor: AppColors.background,
          ),
          SizedBox(height: 16.sp),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomTextField(
              initialValue: _currentItem.messageAr,
              label: 'رساله',
              hint: 'اكتب هنا',
              readOnly: true,
              maxLines: 4,
              height: 104.sp,
              maxLength: 500,
              showCharCount: true,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              fillColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractBodySection() {
    return CrmSectionCard(
      title: 'Contract body',
      showHideToggle: true,
      child: Column(
        children: <Widget>[
          CustomTextField(
            initialValue: _currentItem.contractTerms,
            label: 'Text',
            hint: 'Description',
            readOnly: true,
            maxLines: 4,
            height: 104.sp,
            maxLength: 500,
            showCharCount: true,
            fillColor: AppColors.background,
          ),
          SizedBox(height: 16.sp),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomTextField(
              initialValue: _currentItem.contractTermsAr,
              label: 'نص',
              hint: 'اكتب هنا',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              readOnly: true,
              maxLines: 4,
              height: 104.sp,
              maxLength: 500,
              showCharCount: true,
              fillColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractSectionsSection() {
    return _buildBilingualItemsSection(
      title: 'Sections',
      items: _currentItem.contractSections,
    );
  }

  Widget _buildNotesSection() {
    return _buildBilingualItemsSection(
      title: S.current.crmNotes,
      items: _currentItem.notes,
    );
  }

  Widget _buildBilingualItemsSection({
    required String title,
    required List<CrmBilingualNoteModel> items,
  }) {
    final List<CrmBilingualNoteModel> displayItems = items.isNotEmpty
        ? items
        : const <CrmBilingualNoteModel>[
            CrmBilingualNoteModel(),
            CrmBilingualNoteModel(),
            CrmBilingualNoteModel(),
          ];

    return CrmSectionCard(
      title: title,
      showHideToggle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(displayItems.length, (int index) {
          final CrmBilingualNoteModel item = displayItems[index];
          final String itemLabel = title == 'Sections'
              ? FormatHelper.localizedString(
                  englishName: 'Section ${index + 1}',
                  arabicName: 'قسم ${index + 1}',
                )
              : FormatHelper.localizedString(
                  englishName: 'Note ${index + 1}',
                  arabicName: 'ملاحظة ${index + 1}',
                );

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < displayItems.length - 1 ? 16.sp : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemLabel,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8.sp),
                buildResponsiveFields(
                  context: context,
                  left: CustomTextField(
                    initialValue: item.textEn,
                    hint: 'Text Here',
                    readOnly: true,
                    fillColor: AppColors.background,
                  ),
                  right: Directionality(
                    textDirection: TextDirection.rtl,
                    child: CustomTextField(
                      initialValue: item.textAr,
                      hint: 'اكتب هنا',
                      textAlign: TextAlign.right,
                      readOnly: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildColorsSection() {
    final Color textColor = _parseHex(
      _currentItem.textColorHex,
      AppColors.black,
    );
    final Color highlightColor = _parseHex(
      _currentItem.highlightColorHex,
      AppColors.grey,
    );

    return CrmSectionCard(
      title: S.current.crmColors,
      showHideToggle: true,
      child: buildResponsiveFields(
        context: context,
        left: CrmBillingColorTile(
          label: S.current.crmTextColor,
          hex: _currentItem.textColorHex.isNotEmpty
              ? _currentItem.textColorHex
              : '#2d2d2d',
          color: textColor,
        ),
        right: CrmBillingColorTile(
          label: S.current.crmHighlightingColor,
          hex: _currentItem.highlightColorHex.isNotEmpty
              ? _currentItem.highlightColorHex
              : '#9e9e9e',
          color: highlightColor,
        ),
      ),
    );
  }
}
